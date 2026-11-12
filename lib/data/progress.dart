/// Histórico de partidas concluídas e tudo o que deriva dele:
/// estatísticas, desafios diários e (em achievements.dart) conquistas.
///
/// As telas falam só com [ProgressController]. O armazenamento fica atrás
/// de [ProgressStore]; no futuro, uma implementação remota entra aqui para
/// sincronizar com o servidor.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../engine/game.dart';
import '../engine/generator.dart';
import 'achievements.dart';

/// Uma partida encerrada (vitória ou derrota).
class GameRecord {
  final String id;
  final Difficulty difficulty;
  final String? tag;
  final bool won;
  final int mistakes;
  final int hints;
  final int seconds;
  final int finishedAt; // ms desde 1970

  const GameRecord({
    required this.id,
    required this.difficulty,
    required this.tag,
    required this.won,
    required this.mistakes,
    required this.hints,
    required this.seconds,
    required this.finishedAt,
  });

  /// Data do desafio diário (AAAAMMDD), ou null se não for um.
  int? get dailyDate {
    final t = tag;
    if (t == null || !t.startsWith('daily:')) return null;
    return int.tryParse(t.substring(6));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'difficulty': difficulty.name,
        'tag': tag,
        'won': won,
        'mistakes': mistakes,
        'hints': hints,
        'seconds': seconds,
        'finishedAt': finishedAt,
      };

  factory GameRecord.fromJson(Map<String, dynamic> j) => GameRecord(
        id: j['id'] as String,
        difficulty: Difficulty.values.byName(j['difficulty'] as String),
        tag: j['tag'] as String?,
        won: j['won'] as bool,
        mistakes: j['mistakes'] as int,
        hints: j['hints'] as int,
        seconds: j['seconds'] as int,
        finishedAt: j['finishedAt'] as int,
      );
}

class DifficultyStats {
  final int started;
  final int won;
  final int flawless;
  final int? bestTime;
  final int? averageTime;
  final int currentStreak;
  final int bestStreak;

  const DifficultyStats({
    required this.started,
    required this.won,
    required this.flawless,
    required this.bestTime,
    required this.averageTime,
    required this.currentStreak,
    required this.bestStreak,
  });

  /// Taxa de vitória em porcentagem inteira.
  int get winRate => started == 0 ? 0 : (won * 100 / started).round();
}

abstract class ProgressStore {
  Future<String?> load();
  Future<void> save(String json);
}

class PrefsProgressStore implements ProgressStore {
  static const _key = 'progress_v1';

  @override
  Future<String?> load() async =>
      (await SharedPreferences.getInstance()).getString(_key);

  @override
  Future<void> save(String json) async {
    await (await SharedPreferences.getInstance()).setString(_key, json);
  }
}

/// Só em memória: usado nos testes.
class MemoryProgressStore implements ProgressStore {
  String? value;

  @override
  Future<String?> load() async => value;

  @override
  Future<void> save(String json) async => value = json;
}

class ProgressController extends ChangeNotifier {
  ProgressController({this.store});

  final ProgressStore? store;

  /// Partidas encerradas, em ordem cronológica.
  final List<GameRecord> history = [];

  /// Partidas iniciadas por dificuldade.
  final Map<String, int> started = {};

  Future<void> load() async {
    final raw = await store?.load();
    if (raw != null) _read(raw);
  }

  /// Lê o histórico de um JSON. Em caso de dado ilegível, nada muda.
  bool _read(String raw) {
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      final newHistory = [
        for (final e in j['history'] as List)
          GameRecord.fromJson(Map<String, dynamic>.from(e as Map)),
      ];
      final newStarted = Map<String, int>.from(j['started'] as Map);
      history
        ..clear()
        ..addAll(newHistory);
      started
        ..clear()
        ..addAll(newStarted);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Substitui o histórico pelo de um backup e salva.
  bool importJson(String raw) {
    if (!_read(raw)) return false;
    store?.save(exportJson());
    return true;
  }

  String exportJson() => jsonEncode({
        'schema': 1,
        'history': [for (final r in history) r.toJson()],
        'started': started,
      });

  void _persist() {
    notifyListeners();
    store?.save(exportJson());
  }

  void recordStart(Difficulty d) {
    started[d.name] = (started[d.name] ?? 0) + 1;
    _persist();
  }

  /// Registra o fim de uma partida. Retorna as conquistas desbloqueadas
  /// por ela. Registrar a mesma partida duas vezes não tem efeito.
  List<Achievement> recordFinish(SudokuGame game, {DateTime? now}) {
    if (game.status == GameStatus.playing) return const [];
    if (history.any((r) => r.id == game.id)) return const [];
    final before = {
      for (final a in achievements)
        if (a.unlocked(this)) a.id,
    };
    history.add(GameRecord(
      id: game.id,
      difficulty: game.puzzle.difficulty,
      tag: game.tag,
      won: game.status == GameStatus.won,
      mistakes: game.mistakes,
      hints: game.hintsUsed,
      seconds: game.elapsedSeconds,
      finishedAt: (now ?? DateTime.now()).millisecondsSinceEpoch,
    ));
    _persist();
    return [
      for (final a in achievements)
        if (!before.contains(a.id) && a.unlocked(this)) a,
    ];
  }

  // ---- Estatísticas -------------------------------------------------------

  Iterable<GameRecord> get wins => history.where((r) => r.won);

  int winsOf(Difficulty d) => wins.where((r) => r.difficulty == d).length;

  int? fastest(Difficulty d) {
    int? best;
    for (final r in wins) {
      if (r.difficulty != d) continue;
      if (best == null || r.seconds < best) best = r.seconds;
    }
    return best;
  }

  /// Maior sequência de vitórias seguidas, em qualquer dificuldade.
  int get bestStreakOverall => _streaks(history).$2;

  static (int, int) _streaks(Iterable<GameRecord> records) {
    var current = 0;
    var best = 0;
    for (final r in records) {
      current = r.won ? current + 1 : 0;
      if (current > best) best = current;
    }
    return (current, best);
  }

  DifficultyStats statsFor(Difficulty d) {
    final records = history.where((r) => r.difficulty == d).toList();
    final won = records.where((r) => r.won).toList();
    final finished = records.length;
    final startedCount = started[d.name] ?? 0;
    final (current, best) = _streaks(records);
    int? bestTime;
    var total = 0;
    for (final r in won) {
      total += r.seconds;
      if (bestTime == null || r.seconds < bestTime) bestTime = r.seconds;
    }
    return DifficultyStats(
      started: startedCount > finished ? startedCount : finished,
      won: won.length,
      flawless: won.where((r) => r.mistakes == 0).length,
      bestTime: bestTime,
      averageTime: won.isEmpty ? null : (total / won.length).round(),
      currentStreak: current,
      bestStreak: best,
    );
  }

  // ---- Desafios diários ---------------------------------------------------

  /// Datas (AAAAMMDD) dos desafios diários vencidos.
  Set<int> get dailyWins => {
        for (final r in wins)
          if (r.dailyDate != null) r.dailyDate!,
      };

  bool dailyDone(DateTime date) =>
      dailyWins.contains(date.year * 10000 + date.month * 100 + date.day);

  static int daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  int dailyWinsInMonth(int year, int month) {
    final base = year * 10000 + month * 100;
    return dailyWins.where((d) => d > base && d <= base + 31).length;
  }

  /// O troféu do mês exige todos os desafios diários daquele mês.
  bool monthComplete(int year, int month) =>
      dailyWinsInMonth(year, month) == daysInMonth(year, month);

  int get monthsCompleted {
    final months = {for (final d in dailyWins) d ~/ 100};
    return months.where((m) => monthComplete(m ~/ 100, m % 100)).length;
  }
}
