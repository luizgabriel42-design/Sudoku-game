/// Lista de jogos iniciados e ainda não concluídos.
library;

import 'dart:convert';

import 'package:material_ui/material_ui.dart';

import '../data/game_store.dart';
import '../data/settings.dart';
import '../engine/game.dart';
import '../theme/tokens.dart';
import 'game_screen.dart';
import 'strings.dart';

/// Carrega as partidas em andamento, da mais recente para a mais antiga.
Future<List<SudokuGame>> loadSavedGames(GameStore store) async {
  final out = <SudokuGame>[];
  for (final json in await store.loadAll()) {
    try {
      final g = SudokuGame.fromJson(jsonDecode(json) as Map<String, dynamic>);
      if (g.status == GameStatus.playing) out.add(g);
    } catch (_) {
      // Salvamento ilegível: ignora.
    }
  }
  out.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return out;
}

class SavedGamesScreen extends StatefulWidget {
  const SavedGamesScreen({
    super.key,
    required this.store,
    required this.settings,
  });

  final GameStore store;
  final SettingsController settings;

  @override
  State<SavedGamesScreen> createState() => _SavedGamesScreenState();
}

class _SavedGamesScreenState extends State<SavedGamesScreen> {
  List<SudokuGame>? _games;

  UmiPalette get _p =>
      widget.settings.value.palette(MediaQuery.platformBrightnessOf(context));

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final games = await loadSavedGames(widget.store);
    if (mounted) setState(() => _games = games);
  }

  Future<void> _open(SudokuGame game) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => GameScreen(
          game: game, store: widget.store, settings: widget.settings),
    ));
    await _load();
  }

  Future<void> _delete(SudokuGame game) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _p.board,
        title: Text(S.deleteGame),
        content: Text(S.deleteGameBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(S.cancel),
          ),
          FilledButton(
            key: const Key('confirm-delete'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(S.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await widget.store.delete(game.id);
    await _load();
  }

  String _date(int ms) {
    if (ms == 0) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final games = _games;
    return Scaffold(
      backgroundColor: _p.background,
      appBar: AppBar(
        backgroundColor: _p.background,
        foregroundColor: _p.ink,
        title: Text(S.savedGames),
      ),
      body: games == null
          ? const SizedBox()
          : games.isEmpty
              ? Center(
                  child: Text(S.noSavedGames,
                      style: TextStyle(color: _p.ink, fontSize: 16)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: games.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _card(games[i]),
                ),
    );
  }

  Widget _card(SudokuGame g) {
    final percent = (g.progress * 100).round();
    final daily = g.tag != null && g.tag!.startsWith('daily:');
    final title = daily
        ? '${S.dailyChallenge} · ${S.difficulty(g.puzzle.difficulty)}'
        : S.difficulty(g.puzzle.difficulty);
    return Material(
      color: _p.board,
      borderRadius: BorderRadius.circular(UmiMetrics.radiusCard),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('saved-${g.id}'),
        onTap: () => _open(g),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: _p.ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      '${S.formatTime(g.elapsedSeconds)} · '
                      '$percent% ${S.completed} · '
                      '${S.mistakes}: ${g.mistakes}',
                      style:
                          TextStyle(color: _p.ink.withAlpha(190), fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: g.progress.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: _p.surface,
                        color: _p.userDigit,
                      ),
                    ),
                    if (g.updatedAt != 0) ...[
                      const SizedBox(height: 6),
                      Text(_date(g.updatedAt),
                          style: TextStyle(
                              color: _p.ink.withAlpha(140), fontSize: 12)),
                    ],
                  ],
                ),
              ),
              IconButton(
                key: Key('delete-${g.id}'),
                icon: const Icon(Icons.delete_outline),
                color: _p.ink,
                onPressed: () => _delete(g),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
