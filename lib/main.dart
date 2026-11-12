import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'data/game_store.dart';
import 'theme/tokens.dart';
import 'ui/home_screen.dart';
import 'ui/strings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(UmiSudokuApp(store: PrefsGameStore()));
}

class UmiSudokuApp extends StatelessWidget {
  const UmiSudokuApp({super.key, required this.store});

  final GameStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: S.appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(UmiPalette.umi),
      home: HomeScreen(store: store),
    );
  }
}
