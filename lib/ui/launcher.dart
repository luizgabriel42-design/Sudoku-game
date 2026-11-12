/// Abre partidas: novas, salvas e o desafio diário de qualquer data.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../data/game_store.dart';
import '../data/progress.dart';
import '../data/settings.dart';
import '../engine/daily.dart';
import '../engine/game.dart';
import '../engine/generator.dart';
import 'game_screen.dart';
import 'saved_games_screen.dart';
import 'strings.dart';

/// Cria um puzzle. O padrão gera em segundo plano para não travar a tela.
typedef PuzzleFactory = Future<Puzzle> Function(Difficulty difficulty, int seed);

Puzzle _generate((int, int) args) =>
    generatePuzzle(Difficulty.values[args.$1], args.$2);

Future<Puzzle> generateInBackground(Difficulty difficulty, int seed) =>
    compute(_generate, (difficulty.index, seed));

class GameLauncher {
  GameLauncher({
    required this.store,
    required this.settings,
    required this.progress,
    this.factory = generateInBackground,
  });

  final GameStore store;
  final SettingsController settings;
  final ProgressController progress;
  final PuzzleFactory factory;

  Future<void> open(BuildContext context, SudokuGame game) {
    return Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => GameScreen(
        game: game,
        store: store,
        settings: settings,
        progress: progress,
      ),
    ));
  }

  Future<void> startNew(BuildContext context, Difficulty difficulty, int seed,
      {String? tag}) async {
    final palette =
        settings.value.palette(MediaQuery.platformBrightnessOf(context));
    final navigator = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Material(
            color: palette.board,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: palette.accent),
                  const SizedBox(height: 16),
                  Text(S.generating, style: TextStyle(color: palette.ink)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    final puzzle = await factory(difficulty, seed);
    navigator.pop();
    final game =
        SudokuGame.start(puzzle, rules: settings.value.rules, tag: tag);
    progress.recordStart(difficulty);
    await store.save(game.id, jsonEncode(game.toJson()));
    if (!context.mounted) return;
    await open(context, game);
  }

  /// Desafio diário de [date]: retoma a partida se ela já foi iniciada.
  Future<void> playDaily(BuildContext context, DateTime date) async {
    final tag = 'daily:${dailySeed(date)}';
    for (final g in await loadSavedGames(store)) {
      if (g.tag == tag) {
        if (!context.mounted) return;
        return open(context, g);
      }
    }
    if (!context.mounted) return;
    await startNew(context, dailyDifficulty(date), dailySeed(date), tag: tag);
  }
}
