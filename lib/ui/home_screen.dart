/// Tela inicial: continuar, novo jogo e desafio diário.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../data/game_store.dart';
import '../engine/daily.dart';
import '../engine/game.dart';
import '../engine/generator.dart';
import '../theme/tokens.dart';
import 'game_screen.dart';
import 'patterns.dart';
import 'strings.dart';

/// Cria um puzzle. O padrão gera em segundo plano para não travar a tela.
typedef PuzzleFactory = Future<Puzzle> Function(Difficulty difficulty, int seed);

Puzzle _generate((int, int) args) =>
    generatePuzzle(Difficulty.values[args.$1], args.$2);

Future<Puzzle> generateInBackground(Difficulty difficulty, int seed) =>
    compute(_generate, (difficulty.index, seed));

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.store,
    this.puzzleFactory = generateInBackground,
    this.palette = UmiPalette.umi,
    this.now,
  });

  final GameStore store;
  final PuzzleFactory puzzleFactory;
  final UmiPalette palette;

  /// Relógio injetável para os testes.
  final DateTime Function()? now;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SudokuGame? _saved;
  bool _loading = false;

  UmiPalette get _p => widget.palette;
  DateTime get _today => (widget.now ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    SudokuGame? game;
    try {
      final json = await widget.store.load();
      if (json != null) {
        game = SudokuGame.fromJson(jsonDecode(json) as Map<String, dynamic>);
        if (game.status != GameStatus.playing) game = null;
      }
    } catch (_) {
      // Salvamento ilegível: ignora e começa do zero.
      game = null;
    }
    if (mounted) setState(() => _saved = game);
  }

  Future<void> _open(SudokuGame game) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) =>
          GameScreen(game: game, store: widget.store, palette: _p),
    ));
    await _loadSaved();
  }

  Future<void> _start(Difficulty difficulty, int seed) async {
    setState(() => _loading = true);
    final puzzle = await widget.puzzleFactory(difficulty, seed);
    if (!mounted) return;
    setState(() => _loading = false);
    final game = SudokuGame.start(puzzle);
    await widget.store.save(jsonEncode(game.toJson()));
    await _open(game);
  }

  Future<void> _newGame() async {
    final difficulty = await showModalBottomSheet<Difficulty>(
      context: context,
      backgroundColor: _p.board,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => NewGameSheet(palette: _p),
    );
    if (difficulty == null) return;
    await _start(difficulty, _today.microsecondsSinceEpoch & 0x7FFFFFFF);
  }

  Future<void> _daily() =>
      _start(dailyDifficulty(_today), dailySeed(_today));

  @override
  Widget build(BuildContext context) {
    final saved = _saved;
    return Scaffold(
      backgroundColor: _p.background,
      body: Stack(
        children: [
          // Cabeçalho: seigaiha dissolvido pela névoa (kasumi).
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: SeigaihaPainter(
                    line: _p.accent.withAlpha(70),
                    fill: _p.surface,
                  ),
                ),
                Kasumi(color: _p.background),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 72),
                  Text(
                    'UMI',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _p.ink,
                      fontSize: 22,
                      letterSpacing: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    'SUDOKU',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _p.ink,
                      fontSize: 46,
                      letterSpacing: 6,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 56),
                  _dailyBanner(),
                  const Spacer(),
                  if (_loading)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: _p.accent),
                          const SizedBox(height: 12),
                          Text(S.generating, style: TextStyle(color: _p.ink)),
                        ],
                      ),
                    ),
                  if (saved != null && !_loading) ...[
                    _bigButton(
                      key: const Key('continue'),
                      filled: true,
                      title: S.continueGame,
                      subtitle: '${S.formatTime(saved.elapsedSeconds)} · '
                          '${S.difficulty(saved.puzzle.difficulty)}',
                      onTap: () => _open(saved),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (!_loading)
                    _bigButton(
                      key: const Key('new-game'),
                      filled: saved == null,
                      title: S.newGame,
                      onTap: _newGame,
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dailyBanner() {
    final d = _today;
    final date = '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
    return Material(
      color: _p.surface,
      borderRadius: BorderRadius.circular(UmiMetrics.radiusCard),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: const Key('daily'),
        onTap: _loading ? null : _daily,
        child: SizedBox(
          height: 96,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: WavesPainter(color: _p.accent)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(S.dailyChallenge,
                              style: TextStyle(
                                  color: _p.ink,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                            '$date · ${S.difficulty(dailyDifficulty(d))}',
                            style: TextStyle(color: _p.ink, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: _p.ink, size: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bigButton({
    required Key key,
    required bool filled,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final fg = filled ? Colors.white : _p.userDigit;
    return Material(
      color: filled ? _p.userDigit : _p.board,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UmiMetrics.radiusButton),
        side: BorderSide(color: _p.userDigit, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: key,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: TextStyle(
                        color: fg, fontSize: 20, fontWeight: FontWeight.w600)),
                if (subtitle != null)
                  Text(subtitle,
                      style: TextStyle(color: fg.withAlpha(220), fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Folha inferior com os níveis de dificuldade.
class NewGameSheet extends StatelessWidget {
  const NewGameSheet({super.key, required this.palette});

  final UmiPalette palette;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(S.newGame,
                  style: TextStyle(
                      color: p.ink, fontSize: 20, fontWeight: FontWeight.w600)),
            ),
            for (final d in Difficulty.values)
              ListTile(
                key: Key('difficulty-${d.name}'),
                leading: _dots(d.index + 1, p),
                title: Text(S.difficulty(d),
                    style: TextStyle(color: p.ink, fontSize: 17)),
                onTap: () => Navigator.of(context).pop(d),
              ),
            ListTile(
              enabled: false,
              leading: Icon(Icons.auto_awesome_outlined,
                  color: p.ink.withAlpha(110)),
              title: Text('${S.special} · ${S.soon}',
                  style: TextStyle(color: p.ink.withAlpha(110), fontSize: 17)),
            ),
          ],
        ),
      ),
    );
  }

  /// Indicador de nível: de 1 a 6 pontos preenchidos.
  Widget _dots(int level, UmiPalette p) {
    return SizedBox(
      width: 44,
      child: Wrap(
        spacing: 3,
        runSpacing: 3,
        children: [
          for (var i = 0; i < 6; i++)
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < level ? p.accent : p.surface,
              ),
            ),
        ],
      ),
    );
  }
}
