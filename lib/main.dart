import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'data/game_store.dart';
import 'data/progress.dart';
import 'data/settings.dart';
import 'ui/app_shell.dart';
import 'theme/tokens.dart';
import 'ui/strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final settings = SettingsController(store: PrefsSettingsStore());
  final progress = ProgressController(store: PrefsProgressStore());
  await Future.wait([settings.load(), progress.load()]);
  runApp(UmiSudokuApp(
      store: PrefsGameStore(), settings: settings, progress: progress));
}

class UmiSudokuApp extends StatelessWidget {
  const UmiSudokuApp({
    super.key,
    required this.store,
    required this.settings,
    required this.progress,
  });

  final GameStore store;
  final SettingsController settings;
  final ProgressController progress;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final palette = settings.value
            .palette(MediaQuery.maybePlatformBrightnessOf(context) ??
                Brightness.light);
        return MaterialApp(
          title: S.appName,
          debugShowCheckedModeBanner: false,
          theme: buildTheme(palette),
          // Em telas largas (navegador no computador), mantém o formato
          // de celular.
          builder: (context, child) => ColoredBox(
            color: palette.background,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: child,
              ),
            ),
          ),
          home: AppShell(store: store, settings: settings, progress: progress),
        );
      },
    );
  }
}
