import 'package:flutter_test/flutter_test.dart';
import 'package:umi_sudoku/data/achievements.dart';
import 'package:umi_sudoku/data/progress.dart';
import 'package:umi_sudoku/engine/game.dart';
import 'package:umi_sudoku/engine/generator.dart';

final _base = generatePuzzle(Difficulty.easy, 1);

/// Partida encerrada de mentira, com os campos que o histórico usa.
SudokuGame _finished(
  Difficulty d, {
  bool won = true,
  int seconds = 100,
  int mistakes = 0,
  int hints = 0,
  String? tag,
}) {
  final puzzle = Puzzle(
      givens: _base.givens, solution: _base.solution, difficulty: d, seed: 1);
  return SudokuGame.start(puzzle, tag: tag)
    ..status = won ? GameStatus.won : GameStatus.lost
    ..elapsedSeconds = seconds
    ..mistakes = mistakes
    ..hintsUsed = hints;
}

Achievement _a(String id) => achievements.firstWhere((a) => a.id == id);

void main() {
  test('são 22 conquistas com ids únicos', () {
    expect(achievements.length, 22);
    expect({for (final a in achievements) a.id}.length, 22);
  });

  test('estatísticas por dificuldade', () {
    final p = ProgressController();
    for (var i = 0; i < 4; i++) {
      p.recordStart(Difficulty.easy);
    }
    p.recordFinish(_finished(Difficulty.easy, seconds: 120));
    p.recordFinish(_finished(Difficulty.easy, won: false, mistakes: 3));
    p.recordFinish(_finished(Difficulty.easy, seconds: 60, mistakes: 1));
    p.recordFinish(_finished(Difficulty.hard, seconds: 500));

    final s = p.statsFor(Difficulty.easy);
    expect(s.started, 4);
    expect(s.won, 2);
    expect(s.winRate, 50);
    expect(s.flawless, 1);
    expect(s.bestTime, 60);
    expect(s.averageTime, 90);
    expect(s.currentStreak, 1);
    expect(s.bestStreak, 1);

    final h = p.statsFor(Difficulty.hard);
    expect(h.started, 1); // sem registro de início: conta as encerradas
    expect(h.won, 1);
    expect(p.statsFor(Difficulty.expert).bestTime, isNull);
  });

  test('registrar a mesma partida duas vezes não duplica', () {
    final p = ProgressController();
    final g = _finished(Difficulty.easy);
    p.recordFinish(g);
    p.recordFinish(g);
    expect(p.history.length, 1);
    // Partida ainda em andamento não entra no histórico.
    p.recordFinish(SudokuGame.start(_base));
    expect(p.history.length, 1);
  });

  test('conquistas são desbloqueadas na partida certa', () {
    final p = ProgressController();
    final first = p.recordFinish(_finished(Difficulty.easy, seconds: 200));
    expect(first.map((a) => a.id), contains('flawless1'));
    expect(_a('wins3').unlocked(p), isFalse);
    expect(_a('wins3').current(p), 1);

    p.recordFinish(_finished(Difficulty.easy, mistakes: 1, seconds: 200));
    final third = p.recordFinish(_finished(Difficulty.easy, mistakes: 1, seconds: 200));
    expect(third.map((a) => a.id), contains('wins3'));
    expect(_a('wins3').unlocked(p), isTrue);
    expect(_a('fastEasy').unlocked(p), isFalse);

    final fast = p.recordFinish(_finished(Difficulty.easy, seconds: 170, hints: 1));
    expect(fast.map((a) => a.id), contains('fastEasy'));

    // Derrota não desbloqueia nada e quebra a sequência.
    expect(p.recordFinish(_finished(Difficulty.expert, won: false)), isEmpty);
    expect(p.bestStreakOverall, 4);
    expect(_a('expert1').unlocked(p), isFalse);
    expect(_a('nohints5').current(p), 3);
  });

  test('desafios diários e troféu do mês', () {
    final p = ProgressController();
    expect(ProgressController.daysInMonth(2026, 2), 28);
    for (var d = 1; d <= 27; d++) {
      p.recordFinish(_finished(Difficulty.medium,
          tag: 'daily:${20260200 + d}', mistakes: 1));
    }
    expect(p.dailyWinsInMonth(2026, 2), 27);
    expect(p.monthComplete(2026, 2), isFalse);
    expect(p.dailyDone(DateTime(2026, 2, 27)), isTrue);
    expect(p.dailyDone(DateTime(2026, 2, 28)), isFalse);

    // Uma derrota no dia 28 não conta.
    p.recordFinish(
        _finished(Difficulty.medium, tag: 'daily:20260228', won: false));
    expect(p.monthComplete(2026, 2), isFalse);

    final last = p.recordFinish(
        _finished(Difficulty.medium, tag: 'daily:20260228', mistakes: 1));
    expect(p.monthComplete(2026, 2), isTrue);
    expect(p.monthsCompleted, 1);
    expect(last.map((a) => a.id), contains('month1'));
    expect(_a('daily7').unlocked(p), isTrue);
    expect(_a('daily30').current(p), 28);
  });

  test('histórico sobrevive a salvar e carregar', () async {
    final store = MemoryProgressStore();
    final p = ProgressController(store: store);
    p.recordStart(Difficulty.easy);
    p.recordFinish(_finished(Difficulty.easy, tag: 'daily:20261110'));
    expect(store.value, isNotNull);

    final q = ProgressController(store: store);
    await q.load();
    expect(q.history.length, 1);
    expect(q.history.single.dailyDate, 20261110);
    expect(q.started['easy'], 1);
    expect(q.statsFor(Difficulty.easy).won, 1);
  });
}
