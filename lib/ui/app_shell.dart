/// Estrutura principal: abas Início, Diário e Estatísticas.
library;

import 'package:material_ui/material_ui.dart';

import '../data/game_store.dart';
import '../data/progress.dart';
import '../data/settings.dart';
import 'diary_screen.dart';
import 'home_screen.dart';
import 'launcher.dart';
import 'stats_screen.dart';
import 'strings.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.store,
    required this.settings,
    required this.progress,
    this.puzzleFactory = generateInBackground,
    this.now,
  });

  final GameStore store;
  final SettingsController settings;
  final ProgressController progress;
  final PuzzleFactory puzzleFactory;
  final DateTime Function()? now;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;

  late final GameLauncher _launcher = GameLauncher(
    store: widget.store,
    settings: widget.settings,
    progress: widget.progress,
    factory: widget.puzzleFactory,
  );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settings,
      builder: (context, _) {
        final p = widget.settings.value
            .palette(MediaQuery.platformBrightnessOf(context));
        // Só a aba ativa é construída; assim cada uma recarrega seus dados
        // ao ser aberta.
        final body = switch (_tab) {
          0 => HomeScreen(
              store: widget.store,
              settings: widget.settings,
              progress: widget.progress,
              puzzleFactory: widget.puzzleFactory,
              now: widget.now,
            ),
          1 => DiaryScreen(
              settings: widget.settings,
              progress: widget.progress,
              now: widget.now,
              onPlay: (date) => _launcher.playDaily(context, date),
            ),
          _ => StatsScreen(
              settings: widget.settings, progress: widget.progress),
        };
        return Scaffold(
          backgroundColor: p.background,
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            backgroundColor: p.board,
            indicatorColor: p.surface,
            destinations: [
              NavigationDestination(
                key: const Key('tab-home'),
                icon: Icon(Icons.home_outlined, color: p.ink),
                label: S.tabHome,
              ),
              NavigationDestination(
                key: const Key('tab-diary'),
                icon: Icon(Icons.calendar_month_outlined, color: p.ink),
                label: S.tabDiary,
              ),
              NavigationDestination(
                key: const Key('tab-stats'),
                icon: Icon(Icons.bar_chart_outlined, color: p.ink),
                label: S.tabStats,
              ),
            ],
          ),
        );
      },
    );
  }
}
