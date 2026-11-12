/// Tela inicial: continuar, novo jogo e desafio diário.
library;

export 'launcher.dart' show PuzzleFactory, generateInBackground;

import 'package:material_ui/material_ui.dart';

import '../data/game_store.dart';
import '../data/progress.dart';
import '../data/settings.dart';
import '../engine/daily.dart';
import '../engine/game.dart';
import '../engine/generator.dart';
import '../theme/tokens.dart';
import 'achievements_screen.dart';
import 'launcher.dart';
import 'patterns.dart';
import 'prizes_screen.dart';
import 'saved_games_screen.dart';
import 'settings_screen.dart';
import 'strings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.store,
    this.puzzleFactory = generateInBackground,
    this.settings,
    this.progress,
    this.now,
  });

  final GameStore store;
  final PuzzleFactory puzzleFactory;
  final SettingsController? settings;
  final ProgressController? progress;

  /// Relógio injetável para os testes.
  final DateTime Function()? now;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Partidas em andamento, da mais recente para a mais antiga.
  List<SudokuGame> _saved = const [];

  late final SettingsController _settings =
      widget.settings ?? SettingsController();
  late final ProgressController _progress =
      widget.progress ?? ProgressController();
  late final GameLauncher _launcher = GameLauncher(
    store: widget.store,
    settings: _settings,
    progress: _progress,
    factory: widget.puzzleFactory,
  );

  UmiPalette get _p =>
      _settings.value.palette(MediaQuery.platformBrightnessOf(context));
  DateTime get _today => (widget.now ?? DateTime.now)();

  void _onSettings() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettings);
    _loadSaved();
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettings);
    super.dispose();
  }

  Future<void> _loadSaved() async {
    final games = await loadSavedGames(widget.store);
    if (mounted) setState(() => _saved = games);
  }

  Future<void> _open(SudokuGame game) async {
    await _launcher.open(context, game);
    await _loadSaved();
  }

  Future<void> _push(Widget screen) async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => screen));
    await _loadSaved();
  }

  Future<void> _openSavedList() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) =>
          SavedGamesScreen(
              store: widget.store, settings: _settings, progress: _progress),
    ));
    await _loadSaved();
  }

  Future<void> _newGame() async {
    final difficulty = await showModalBottomSheet<Difficulty>(
      context: context,
      backgroundColor: _p.board,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => NewGameSheet(palette: _p),
    );
    if (difficulty == null || !mounted) return;
    await _launcher.startNew(
        context, difficulty, _today.microsecondsSinceEpoch & 0x7FFFFFFF);
    await _loadSaved();
  }

  Future<void> _daily() async {
    await _launcher.playDaily(context, _today);
    await _loadSaved();
  }

  @override
  Widget build(BuildContext context) {
    final saved = _saved.isEmpty ? null : _saved.first;
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
                  Row(
                    children: [
                      IconButton(
                        key: const Key('open-settings'),
                        icon: const Icon(Icons.settings_outlined),
                        color: _p.ink,
                        onPressed: () =>
                            _push(SettingsScreen(
                                settings: _settings,
                                store: widget.store,
                                progress: _progress)),
                      ),
                      const Spacer(),
                      IconButton(
                        key: const Key('open-achievements'),
                        icon: const Icon(Icons.military_tech_outlined),
                        color: _p.ink,
                        onPressed: () => _push(AchievementsScreen(
                            settings: _settings, progress: _progress)),
                      ),
                      IconButton(
                        key: const Key('open-prizes'),
                        icon: const Icon(Icons.emoji_events_outlined),
                        color: _p.ink,
                        onPressed: () => _push(PrizesScreen(
                            settings: _settings,
                            progress: _progress,
                            year: _today.year)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
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
                  if (saved != null) ...[
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
                  if (_saved.isNotEmpty) ...[
                    TextButton.icon(
                      key: const Key('saved-games'),
                      onPressed: _openSavedList,
                      icon: Icon(Icons.folder_open_outlined, color: _p.ink),
                      label: Text('${S.savedGames} (${_saved.length})',
                          style: TextStyle(color: _p.ink, fontSize: 16)),
                    ),
                    const SizedBox(height: 8),
                  ],
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
        onTap: _daily,
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
    final fg = filled ? _p.board : _p.userDigit;
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
