// Gera capturas de tela em build/screens para conferência visual.
// Não valida nada além de as telas renderizarem sem erro.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:umi_sudoku/data/game_store.dart';
import 'package:umi_sudoku/data/settings.dart';
import 'package:umi_sudoku/engine/game.dart';
import 'package:umi_sudoku/engine/generator.dart';
import 'package:umi_sudoku/engine/grid.dart';
import 'package:umi_sudoku/theme/tokens.dart';
import 'package:umi_sudoku/ui/game_screen.dart';
import 'package:umi_sudoku/ui/home_screen.dart';
import 'package:umi_sudoku/ui/settings_screen.dart';

const _root = Key('shot-root');

Future<void> _loadFonts() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null) return;
  final dir = '$flutterRoot/bin/cache/artifacts/material_fonts';
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    var any = false;
    for (final f in files) {
      final file = File('$dir/$f');
      if (!file.existsSync()) continue;
      final bytes = file.readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
      any = true;
    }
    if (any) await loader.load();
  }

  await load('Roboto', [
    'Roboto-Regular.ttf',
    'Roboto-Medium.ttf',
    'Roboto-Bold.ttf',
    'Roboto-Light.ttf',
  ]);
  await load('MaterialIcons', ['MaterialIcons-Regular.otf']);
}

Widget _app(Widget home) => RepaintBoundary(
      key: _root,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildTheme(UmiPalette.umi),
        home: home,
      ),
    );

Future<void> _shot(WidgetTester tester, String name) async {
  final boundary =
      tester.renderObject<RenderRepaintBoundary>(find.byKey(_root));
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    File('build/screens/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(data!.buffer.asUint8List());
  });
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

Future<void> _tapCell(WidgetTester tester, int cell) async {
  final rect = tester.getRect(find.byKey(const Key('board')));
  final size = rect.width / 9;
  await tester.tapAt(rect.topLeft +
      Offset((colOf(cell) + 0.5) * size, (rowOf(cell) + 0.5) * size));
  await tester.pump();
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('capturas: configurações e temas', (tester) async {
    _phone(tester);
    await tester.pumpWidget(
        _app(SettingsScreen(settings: SettingsController())));
    await tester.pump();
    await _shot(tester, '07-configuracoes');
    await tester.pumpWidget(const SizedBox());
    await _themeShots(tester, ThemeChoice.sakura, '08-tema-sakura');
    await _themeShots(tester, ThemeChoice.dark, '09-tema-escuro');
  });

  testWidgets('capturas: início e novo jogo', (tester) async {
    _phone(tester);
    final store = MemoryGameStore();
    final saved = SudokuGame.start(generatePuzzle(Difficulty.expert, 2))
      ..elapsedSeconds = 202;
    await tester.pumpWidget(_app(HomeScreen(
      store: store,
      puzzleFactory: (d, s) async => generatePuzzle(d, 1),
      now: () => DateTime(2026, 11, 10),
    )));
    await tester.pumpAndSettle();
    await _shot(tester, '01-inicio');

    // Com partida salva.
    await tester.pumpWidget(const SizedBox());
    final store2 = MemoryGameStore();
    await store2.save(_encode(saved));
    await tester.pumpWidget(_app(HomeScreen(
      store: store2,
      puzzleFactory: (d, s) async => generatePuzzle(d, 1),
      now: () => DateTime(2026, 11, 10),
    )));
    await tester.pumpAndSettle();
    await _shot(tester, '02-inicio-continuar');

    await tester.tap(find.byKey(const Key('new-game')));
    await tester.pumpAndSettle();
    await _shot(tester, '03-novo-jogo');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('capturas: jogo, notas, dica e pausa', (tester) async {
    _phone(tester);
    final p = generatePuzzle(Difficulty.hard, 5);
    final game = SudokuGame.start(p);
    // Adianta a partida: alguns acertos, um erro e notas.
    final empties = [
      for (var c = 0; c < kCells; c++)
        if (game.values[c] == 0) c,
    ];
    for (final c in empties.take(12)) {
      game.place(c, p.solution[c]);
    }
    game.place(empties[12], p.solution[empties[12]] % 9 + 1);
    game.fillAutoNotes();
    game.elapsedSeconds = 206;

    await tester.pumpWidget(
        _app(GameScreen(game: game, store: MemoryGameStore())));
    await tester.pump();
    await _tapCell(tester, empties[3]);
    await _shot(tester, '04-jogo');

    await tester.tap(find.byKey(const Key('action-hint')));
    await tester.pump();
    await _shot(tester, '05-dica');
    await tester.tap(find.byKey(const Key('hint-close')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('pause')));
    await tester.pump();
    await _shot(tester, '06-pausa');
    await tester.pumpWidget(const SizedBox());
  });
}

Future<void> _themeShots(WidgetTester tester, ThemeChoice theme, String name) async {
  final settings = SettingsController(initial: AppSettings(theme: theme));
  final p = generatePuzzle(Difficulty.hard, 5);
  final game = SudokuGame.start(p);
  final empties = [
    for (var c = 0; c < kCells; c++)
      if (game.values[c] == 0) c,
  ];
  for (final c in empties.take(12)) {
    game.place(c, p.solution[c]);
  }
  game.fillAutoNotes();
  await tester.pumpWidget(_app(
      GameScreen(game: game, store: MemoryGameStore(), settings: settings)));
  await tester.pump();
  await tester.tap(find.byKey(const Key('num-2')));
  await tester.pump();
  await _shot(tester, name);
  await tester.pumpWidget(const SizedBox());
}

String _encode(SudokuGame g) => jsonEncode(g.toJson());
