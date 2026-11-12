/// Tela de jogo.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../data/game_store.dart';
import '../data/settings.dart';
import '../engine/game.dart';
import '../engine/grid.dart';
import '../engine/hint.dart';
import '../theme/tokens.dart';
import 'settings_screen.dart';
import 'strings.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.game,
    required this.store,
    this.settings,
  });

  final SudokuGame game;
  final GameStore store;

  /// Configurações compartilhadas; se ausente, usa os padrões.
  final SettingsController? settings;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with WidgetsBindingObserver {
  late SudokuGame _game = widget.game;
  int? _selected;
  bool _notesMode = false;

  /// Entrada número-primeiro: dígito travado por toque longo.
  int? _lockedDigit;

  /// Número tocado no teclado: destaca os iguais no tabuleiro.
  int? _padDigit;
  late final SettingsController _settings =
      widget.settings ?? SettingsController();
  bool _paused = false;
  Hint? _hint;
  Timer? _timer;

  AppSettings get _s => _settings.value;
  UmiPalette get _p =>
      _s.palette(MediaQuery.platformBrightnessOf(context));

  void _onSettings() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettings);
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _settings.removeListener(_onSettings);
    super.dispose();
  }

  /// App suspenso, em segundo plano ou fechado: pausa o tempo e salva.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) return;
    if (_game.status != GameStatus.playing) return;
    if (!_paused && mounted) setState(() => _paused = true);
    _save();
  }

  void _tick() {
    if (_paused || _game.status != GameStatus.playing) return;
    setState(() => _game.elapsedSeconds++);
    if (_game.elapsedSeconds % 5 == 0) _save();
  }

  /// Salva a partida a cada jogada; ao terminar, limpa o salvamento.
  void _save() {
    if (_game.status == GameStatus.playing) {
      _game.updatedAt = DateTime.now().millisecondsSinceEpoch;
      widget.store.save(_game.id, jsonEncode(_game.toJson()));
    } else {
      widget.store.delete(_game.id);
    }
  }

  void _onCellTap(int cell) {
    if (_hint != null) return;
    final locked = _lockedDigit;
    setState(() {
      // Tocar de novo na célula selecionada tira a seleção.
      _selected = (_selected == cell && locked == null) ? null : cell;
      _padDigit = null;
    });
    if (locked != null) _input(locked);
  }

  /// Toque em um número do teclado: destaca na hora os números iguais já
  /// presentes no tabuleiro e, se houver uma célula selecionada, joga nela.
  void _onDigit(int digit) {
    if (_lockedDigit != null) {
      setState(() => _lockedDigit = digit);
      return;
    }
    setState(() => _padDigit = digit);
    _input(digit);
  }

  void _onDigitLongPress(int digit) {
    if (!_s.numberFirst) return;
    setState(() => _lockedDigit = _lockedDigit == digit ? null : digit);
  }

  void _input(int digit) {
    final cell = _selected;
    if (cell == null) return;
    if (_notesMode) {
      setState(() => _game.toggleNote(cell, digit));
      _save();
      return;
    }
    var outcome = _game.place(cell, digit);
    if (outcome == PlaceOutcome.correct &&
        _s.autoComplete &&
        _game.autoCompleteIfTrivial()) {
      outcome = PlaceOutcome.won;
    }
    if ((outcome == PlaceOutcome.mistake || outcome == PlaceOutcome.lost) &&
        _s.vibrate) {
      HapticFeedback.mediumImpact();
    }
    setState(() {});
    _save();
    _afterOutcome(outcome);
  }

  void _afterOutcome(PlaceOutcome outcome) {
    if (outcome == PlaceOutcome.won) _showEnd(won: true);
    if (outcome == PlaceOutcome.lost) _showEnd(won: false);
  }

  void _undo() {
    setState(() => _game.undo());
    _save();
  }

  void _erase() {
    final cell = _selected;
    if (cell == null) return;
    setState(() => _game.erase(cell));
    _save();
  }

  void _autoNotes() {
    setState(() => _game.fillAutoNotes());
    _save();
  }

  void _showHint() {
    final h = _game.hint();
    if (h == null) return;
    setState(() {
      _hint = h;
      _selected = h.cell;
      _lockedDigit = null;
      _padDigit = null;
    });
  }

  void _applyHint() {
    final h = _hint;
    if (h == null) return;
    final outcome = _game.applyHint(h);
    setState(() => _hint = null);
    _save();
    _afterOutcome(outcome);
  }

  Future<void> _showEnd({required bool won}) async {
    final again = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: _p.board,
        title: Text(won ? S.won : S.lost),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(won ? S.wonBody : S.lostBody),
            const SizedBox(height: 12),
            Text('${S.time}: ${S.formatTime(_game.elapsedSeconds)}'),
            Text('${S.mistakes}: ${_game.mistakes}'),
            Text('${S.hintsUsed}: ${_game.hintsUsed}'),
            if (won && _game.mistakes == 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(S.noMistakes,
                    style: TextStyle(
                        color: _p.userDigit, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
        actions: [
          if (!won)
            TextButton(
              key: const Key('end-retry'),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(S.tryAgain),
            ),
          FilledButton(
            key: const Key('end-home'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(S.home),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (again == true) {
      setState(() {
        _game = SudokuGame.start(_game.puzzle,
            rules: _game.rules, id: _game.id, tag: _game.tag);
        _selected = null;
        _hint = null;
      });
      _save();
    } else {
      Navigator.of(context).pop();
    }
  }

  int get _focusDigit {
    if (_lockedDigit != null) return _lockedDigit!;
    if (_padDigit != null) return _padDigit!;
    final c = _selected;
    return c == null ? 0 : _game.values[c];
  }

  @override
  Widget build(BuildContext context) {
    // As regras acompanham as configurações mesmo com a partida em andamento.
    _game.rules = _s.rules.forDifficulty(_game.puzzle.difficulty);
    final hint = _hint;
    final hintCells = <int>{};
    if (hint != null) {
      for (final s in hint.steps) {
        hintCells.addAll(s.patternCells);
      }
    }
    return Scaffold(
      backgroundColor: _p.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            _infoBar(),
            // O tabuleiro ocupa a largura; o teclado vem logo abaixo dele.
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _paused
                        ? _pausedBox()
                        : LayoutBuilder(
                            builder: (context, box) => GestureDetector(
                              key: const Key('board'),
                              behavior: HitTestBehavior.opaque,
                              onTapUp: (d) {
                                final size = box.maxWidth / 9;
                                final col = (d.localPosition.dx / size)
                                    .floor()
                                    .clamp(0, 8)
                                    .toInt();
                                final row = (d.localPosition.dy / size)
                                    .floor()
                                    .clamp(0, 8)
                                    .toInt();
                                _onCellTap(row * 9 + col);
                              },
                              child: CustomPaint(
                                size: Size.square(box.maxWidth),
                                painter: BoardPainter(
                                  game: _game,
                                  palette: _p,
                                  selected: _selected,
                                  focusDigit: _focusDigit,
                                  hintCells: hintCells,
                                  hintTarget: hint?.cell,
                                  highlightSame: _s.highlightSame,
                                  highlightRegion: _s.highlightRegion,
                                  highlightNotes: _s.highlightNotes,
                                  textStyle: DefaultTextStyle.of(context).style,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
            if (hint != null)
              _hintCard(hint)
            else ...[
              const SizedBox(height: 4),
              _numberPad(),
              const SizedBox(height: 8),
              _actions(),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            key: const Key('back'),
            icon: const Icon(Icons.arrow_back),
            color: _p.ink,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          IconButton(
            key: const Key('open-settings'),
            icon: const Icon(Icons.settings_outlined),
            color: _p.ink,
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => SettingsScreen(settings: _settings),
            )),
          ),
        ],
      ),
    );
  }

  Widget _infoBar() {
    final style = TextStyle(color: _p.ink.withAlpha(190), fontSize: 16);
    final limit = _game.rules.mistakeLimitEnabled
        ? '${_game.mistakes}/${_game.rules.mistakeLimit}'
        : '${_game.mistakes}';
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              S.difficulty(_game.puzzle.difficulty),
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('${S.mistakes}: $limit', key: const Key('mistakes'), style: style),
          const SizedBox(width: 16),
          if (_s.showTimer)
            Text(S.formatTime(_game.elapsedSeconds), style: style),
          IconButton(
            key: const Key('pause'),
            icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
            color: _p.ink,
            onPressed: () => setState(() => _paused = !_paused),
          ),
        ],
      ),
    );
  }

  Widget _pausedBox() {
    return Container(
      decoration: BoxDecoration(
        color: _p.surface,
        borderRadius: BorderRadius.circular(UmiMetrics.radiusCard),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(S.paused, style: TextStyle(color: _p.ink, fontSize: 22)),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('resume'),
            onPressed: () => setState(() => _paused = false),
            child: Text(S.resume),
          ),
        ],
      ),
    );
  }

  Widget _actions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _action('undo', Icons.undo, S.undo, _game.canUndo ? _undo : null),
          _action('erase', Icons.backspace_outlined, S.erase, _erase),
          _action('auto-notes', Icons.auto_fix_high, S.autoNotes, _autoNotes),
          _action(
            'notes',
            Icons.edit_outlined,
            S.notes,
            () => setState(() => _notesMode = !_notesMode),
            badge: _notesMode ? S.on : S.off,
            active: _notesMode,
          ),
          _action(
            'hint',
            Icons.lightbulb_outline,
            S.hint,
            _showHint,
            badge: '${_game.hintsUsed}',
          ),
        ],
      ),
    );
  }

  Widget _action(String id, IconData icon, String label, VoidCallback? onTap,
      {String? badge, bool active = false}) {
    final color = onTap == null
        ? _p.ink.withAlpha(90)
        : active
            ? _p.userDigit
            : _p.ink;
    return Expanded(
      child: InkWell(
        key: Key('action-$id'),
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 2),
              Text(label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(color: color, fontSize: 11)),
              if (badge != null)
                Text(badge,
                    style: TextStyle(
                        color: color, fontSize: 9, letterSpacing: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _numberPad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          for (var d = 1; d <= 9; d++)
            Expanded(
              child: _digitKey(d),
            ),
        ],
      ),
    );
  }

  Widget _digitKey(int d) {
    final done = _game.isDigitComplete(d);
    final locked = _lockedDigit == d;
    return InkWell(
      key: Key('num-$d'),
      borderRadius: BorderRadius.circular(12),
      onTap: done ? null : () => _onDigit(d),
      onLongPress: done ? null : () => _onDigitLongPress(d),
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        decoration: BoxDecoration(
          color: locked ? _p.surface : null,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$d',
              style: TextStyle(
                fontSize: 30,
                color: done ? _p.ink.withAlpha(50) : _p.userDigit,
              ),
            ),
            Text(
              done || !_s.showRemaining ? '' : '${_game.remaining(d)}',
              style: TextStyle(fontSize: 10, color: _p.ink.withAlpha(150)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hintCard(Hint hint) {
    final t = hint.technique;
    final title = hint.direct || t == null ? S.directSolution : S.technique(t);
    return Container(
      key: const Key('hint-card'),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _p.board,
        borderRadius: BorderRadius.circular(UmiMetrics.radiusCard),
        border: Border.all(color: _p.success, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: _p.userDigit),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        color: _p.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 150),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final line in S.hintLines(hint))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(line,
                          style: TextStyle(color: _p.ink, fontSize: 14)),
                    ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                key: const Key('hint-close'),
                onPressed: () => setState(() => _hint = null),
                child: Text(S.close),
              ),
              const SizedBox(width: 8),
              FilledButton(
                key: const Key('hint-apply'),
                onPressed: _applyHint,
                child: Text(S.apply),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Desenha o tabuleiro: fundos de destaque, números, notas e linhas.
class BoardPainter extends CustomPainter {
  BoardPainter({
    required this.game,
    required this.palette,
    required this.selected,
    required this.focusDigit,
    required this.hintCells,
    required this.hintTarget,
    this.highlightSame = true,
    this.highlightRegion = true,
    this.highlightNotes = true,
    this.textStyle = const TextStyle(),
  });

  final SudokuGame game;
  final UmiPalette palette;
  final int? selected;
  final int focusDigit;
  final Set<int> hintCells;
  final int? hintTarget;
  final bool highlightSame;
  final bool highlightRegion;
  final bool highlightNotes;

  /// Estilo base (fonte do tema) para números e notas.
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final p = palette;
    final cell = size.width / 9;
    final outer = RRect.fromRectAndRadius(
        Offset.zero & size, const Radius.circular(12));

    canvas.save();
    canvas.clipRRect(outer);
    canvas.drawRect(Offset.zero & size, Paint()..color = p.board);

    final sel = selected;
    for (var c = 0; c < kCells; c++) {
      final rect =
          Rect.fromLTWH(colOf(c) * cell, rowOf(c) * cell, cell, cell);
      final value = game.values[c];

      Color? bg;
      if (c == hintTarget) {
        bg = p.success;
      } else if (hintCells.contains(c)) {
        bg = p.success.withAlpha(130);
      } else if (c == sel) {
        bg = p.accent.withAlpha(110);
      } else if (highlightSame && focusDigit != 0 && value == focusDigit) {
        bg = p.accent.withAlpha(60);
      } else if (highlightRegion &&
          sel != null &&
          (rowOf(c) == rowOf(sel) ||
              colOf(c) == colOf(sel) ||
              boxOf(c) == boxOf(sel))) {
        bg = p.surface.withAlpha(150);
      }
      if (bg != null) canvas.drawRect(rect, Paint()..color = bg);

      if (value != 0) {
        final color = game.isGiven(c)
            ? p.ink
            : game.isWrong(c)
                ? p.wrongDigit
                : p.userDigit;
        _text(canvas, '$value', rect.center, cell * 0.62, color,
            game.isGiven(c) ? FontWeight.w500 : FontWeight.w400);
      } else if (game.notes[c] != 0) {
        final sub = cell / 3;
        for (var d = 1; d <= 9; d++) {
          if ((game.notes[c] & bit(d)) == 0) continue;
          final center = Offset(
            rect.left + ((d - 1) % 3 + 0.5) * sub,
            rect.top + ((d - 1) ~/ 3 + 0.5) * sub,
          );
          final focused = highlightNotes && d == focusDigit;
          if (focused) {
            canvas.drawCircle(
                center, sub * 0.46, Paint()..color = p.accent.withAlpha(90));
          }
          _text(canvas, '$d', center, sub * 0.78,
              focused ? p.ink : p.ink.withAlpha(170),
              focused ? FontWeight.w700 : FontWeight.w400);
        }
      }
    }

    final thin = Paint()
      ..color = p.ink.withAlpha(60)
      ..strokeWidth = 1;
    final thick = Paint()
      ..color = p.ink
      ..strokeWidth = 2;
    for (var i = 1; i < 9; i++) {
      final paint = i % 3 == 0 ? thick : thin;
      canvas.drawLine(Offset(i * cell, 0), Offset(i * cell, size.height), paint);
      canvas.drawLine(Offset(0, i * cell), Offset(size.width, i * cell), paint);
    }
    canvas.restore();

    canvas.drawRRect(
      outer.deflate(1),
      Paint()
        ..color = p.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _text(Canvas canvas, String text, Offset center, double fontSize,
      Color color, FontWeight weight) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle.copyWith(
            fontSize: fontSize, color: color, fontWeight: weight, height: 1),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(BoardPainter old) => true;
}
