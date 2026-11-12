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
import 'package:umi_sudoku/data/progress.dart';
import 'package:umi_sudoku/data/settings.dart';
import 'package:umi_sudoku/engine/game.dart';
import 'package:umi_sudoku/engine/generator.dart';
import 'package:umi_sudoku/engine/grid.dart';
import 'package:umi_sudoku/theme/tokens.dart';
import 'package:umi_sudoku/ui/game_screen.dart';
import 'package:umi_sudoku/ui/achievements_screen.dart';
import 'package:umi_sudoku/ui/app_shell.dart';
import 'package:umi_sudoku/ui/home_screen.dart';
import 'package:umi_sudoku/ui/prizes_screen.dart';
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

ProgressController _sampleProgress() {
  final base = generatePuzzle(Difficulty.easy, 1);
  final p = ProgressController();
  SudokuGame g(Difficulty d, {String? tag, bool won = true, int s = 240, int m = 0}) =>
      SudokuGame.start(
          Puzzle(
              givens: base.givens,
              solution: base.solution,
              difficulty: d,
              seed: 1),
          tag: tag)
        ..status = won ? GameStatus.won : GameStatus.lost
        ..elapsedSeconds = s
        ..mistakes = m;
  for (var d = 1; d <= 31; d++) {
    p.recordFinish(g(Difficulty.medium, tag: 'daily:${20261000 + d}', m: d % 3));
  }
  for (final d in [1, 2, 3, 5, 6, 8, 9]) {
    p.recordFinish(g(Difficulty.hard, tag: 'daily:${20261100 + d}', m: 1));
  }
  p.recordFinish(g(Difficulty.easy, s: 150));
  p.recordFinish(g(Difficulty.easy, s: 210, m: 1));
  p.recordFinish(g(Difficulty.easy, won: false, m: 3));
  p.recordFinish(g(Difficulty.expert, s: 540));
  return p;
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('capturas: diário, estatísticas, conquistas e prêmios',
      (tester) async {
    _phone(tester);
    final progress = _sampleProgress();
    final settings = SettingsController();
    await tester.pumpWidget(_app(AppShell(
      store: MemoryGameStore(),
      settings: settings,
      progress: progress,
      puzzleFactory: (d, s) async => generatePuzzle(d, 1),
      now: () => DateTime(2026, 11, 10),
    )));
    await tester.pumpAndSettle();
    await _shot(tester, '11-abas-inicio');
    await tester.tap(find.byKey(const Key('tab-diary')));
    await tester.pumpAndSettle();
    await _shot(tester, '12-diario');
    await tester.tap(find.byKey(const Key('month-prev')));
    await tester.pumpAndSettle();
    await _shot(tester, '13-diario-mes-completo');
    await tester.tap(find.byKey(const Key('tab-stats')));
    await tester.pumpAndSettle();
    await _shot(tester, '14-estatisticas');
    await tester.pumpWidget(const SizedBox());

    await tester.pumpWidget(
        _app(AchievementsScreen(settings: settings, progress: progress)));
    await tester.pump();
    await _shot(tester, '15-conquistas');
    await tester.pumpWidget(const SizedBox());

    await tester.pumpWidget(_app(
        PrizesScreen(settings: settings, progress: progress, year: 2026)));
    await tester.pump();
    await _shot(tester, '16-premios');
    await tester.pumpWidget(const SizedBox());
  });

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
    await store2.save(saved.id, _encode(saved));
    final other = SudokuGame.start(generatePuzzle(Difficulty.easy, 4),
        tag: 'daily:20261110')
      ..elapsedSeconds = 95;
    await store2.save(other.id, _encode(other));
    await tester.pumpWidget(_app(HomeScreen(
      store: store2,
      puzzleFactory: (d, s) async => generatePuzzle(d, 1),
      now: () => DateTime(2026, 11, 10),
    )));
    await tester.pumpAndSettle();
    await _shot(tester, '02-inicio-continuar');

    await tester.tap(find.byKey(const Key('saved-games')));
    await tester.pumpAndSettle();
    await _shot(tester, '10-jogos-iniciados');
    await tester.pageBack();
    await tester.pumpAndSettle();

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
