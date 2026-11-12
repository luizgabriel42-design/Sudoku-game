import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:umi_sudoku/data/game_store.dart';
import 'package:umi_sudoku/data/progress.dart';
import 'package:umi_sudoku/data/settings.dart';
import 'package:umi_sudoku/engine/game.dart';
import 'package:umi_sudoku/engine/generator.dart';
import 'package:umi_sudoku/engine/grid.dart';
import 'package:umi_sudoku/ui/game_screen.dart';
import 'package:umi_sudoku/ui/achievements_screen.dart';
import 'package:umi_sudoku/ui/app_shell.dart';
import 'package:umi_sudoku/ui/home_screen.dart';
import 'package:umi_sudoku/ui/saved_games_screen.dart';
import 'package:umi_sudoku/ui/settings_screen.dart';
import 'package:umi_sudoku/ui/strings.dart';

/// Simula a tela de um celular em pé.
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

Future<void> _tapKey(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pump();
}

Future<Puzzle> _syncFactory(Difficulty d, int seed) async =>
    generatePuzzle(d, 1);

void main() {
  testWidgets('início: novo jogo abre a tela de jogo e salva a partida',
      (tester) async {
    _phone(tester);
    final store = MemoryGameStore();
    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(store: store, puzzleFactory: _syncFactory),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('continue')), findsNothing);
    await tester.tap(find.byKey(const Key('new-game')));
    await tester.pumpAndSettle();

    // Todos os níveis aparecem, inclusive Pesadelo, sem bloqueio.
    for (final d in Difficulty.values) {
      expect(find.byKey(Key('difficulty-${d.name}')), findsOneWidget);
    }
    await tester.tap(find.byKey(const Key('difficulty-nightmare')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('board')), findsOneWidget);
    expect(find.text(S.difficulty(Difficulty.nightmare)), findsOneWidget);
    expect(find.text('${S.mistakes}: 0/3'), findsOneWidget);
    expect(store.games.length, 1);

    // Voltar mostra o botão Continuar.
    await tester.tap(find.byKey(const Key('back')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('continue')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('jogo: acerto, erro, notas, desfazer e pausa', (tester) async {
    _phone(tester);
    final p = generatePuzzle(Difficulty.easy, 9);
    final game = SudokuGame.start(p);
    final store = MemoryGameStore();
    await tester.pumpWidget(
        MaterialApp(home: GameScreen(game: game, store: store)));
    await tester.pump();

    final c = game.values.indexOf(0);
    final right = p.solution[c];
    final wrong = right % 9 + 1;

    await _tapCell(tester, c);
    await _tapKey(tester, 'num-$wrong');
    expect(game.mistakes, 1);
    expect(game.isWrong(c), isTrue);
    expect(find.text('${S.mistakes}: 1/3'), findsOneWidget);

    await _tapKey(tester, 'num-$right');
    expect(game.isCorrect(c), isTrue);
    expect(store.games.keys.single, game.id);
    final saved = SudokuGame.fromJson(
        jsonDecode(store.games[game.id]!) as Map<String, dynamic>);
    expect(saved.values[c], right);

    // Modo notas em outra célula vazia.
    final other = game.values.indexOf(0);
    await _tapCell(tester, other);
    await _tapKey(tester, 'action-notes');
    expect(find.text(S.on), findsOneWidget);
    await _tapKey(tester, 'num-${p.solution[other]}');
    expect(game.values[other], 0);
    expect(game.notes[other] & bit(p.solution[other]), isNot(0));

    await _tapKey(tester, 'action-undo');
    expect(game.notes[other], 0);

    // Pausar esconde o tabuleiro.
    await _tapKey(tester, 'pause');
    expect(find.byKey(const Key('board')), findsNothing);
    expect(find.text(S.paused), findsOneWidget);
    await _tapKey(tester, 'resume');
    expect(find.byKey(const Key('board')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('dica: mostra a técnica e preenche um único quadrado',
      (tester) async {
    _phone(tester);
    final p = generatePuzzle(Difficulty.hard, 5);
    final game = SudokuGame.start(p);
    await tester.pumpWidget(MaterialApp(
        home: GameScreen(game: game, store: MemoryGameStore())));
    await tester.pump();

    final before = game.values.where((v) => v != 0).length;
    await _tapKey(tester, 'action-hint');
    expect(find.byKey(const Key('hint-card')), findsOneWidget);
    // O teclado some enquanto a dica está aberta.
    expect(find.byKey(const Key('num-1')), findsNothing);

    await _tapKey(tester, 'hint-apply');
    expect(find.byKey(const Key('hint-card')), findsNothing);
    expect(game.hintsUsed, 1);
    expect(game.values.where((v) => v != 0).length, before + 1);
    for (var c = 0; c < kCells; c++) {
      if (game.values[c] != 0) expect(game.values[c], p.solution[c]);
    }
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('vitória: último número mostra o resumo e limpa o salvamento',
      (tester) async {
    _phone(tester);
    final p = generatePuzzle(Difficulty.easy, 3);
    final game = SudokuGame.start(p);
    final empties = [
      for (var c = 0; c < kCells; c++)
        if (game.values[c] == 0) c,
    ];
    for (final c in empties.skip(1)) {
      game.place(c, p.solution[c]);
    }
    final store = MemoryGameStore();
    await store.save(game.id, jsonEncode(game.toJson()));
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => GameScreen(game: game, store: store),
            )),
            child: const Text('abrir'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    final last = empties.first;
    await _tapCell(tester, last);
    await _tapKey(tester, 'num-${p.solution[last]}');
    await tester.pumpAndSettle();

    expect(game.status, GameStatus.won);
    expect(find.text(S.won), findsOneWidget);
    expect(find.text(S.noMistakes), findsOneWidget);
    expect(store.games, isEmpty);

    await tester.tap(find.byKey(const Key('end-home')));
    await tester.pumpAndSettle();
    expect(find.text('abrir'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('derrota: três erros encerram e permitem tentar de novo',
      (tester) async {
    _phone(tester);
    final p = generatePuzzle(Difficulty.easy, 4);
    final game = SudokuGame.start(p);
    await tester.pumpWidget(MaterialApp(
        home: GameScreen(game: game, store: MemoryGameStore())));
    await tester.pump();

    final c = game.values.indexOf(0);
    final wrongs = [
      for (var d = 1; d <= 9; d++)
        if (d != p.solution[c]) d,
    ];
    await _tapCell(tester, c);
    for (final w in wrongs.take(3)) {
      await _tapKey(tester, 'num-$w');
    }
    await tester.pumpAndSettle();
    expect(find.text(S.lost), findsOneWidget);

    await tester.tap(find.byKey(const Key('end-retry')));
    await tester.pumpAndSettle();
    expect(find.text('${S.mistakes}: 0/3'), findsOneWidget);
    expect(find.byKey(const Key('board')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  BoardPainter painter(WidgetTester tester) => tester
      .widget<CustomPaint>(find.descendant(
          of: find.byKey(const Key('board')),
          matching: find.byType(CustomPaint)))
      .painter! as BoardPainter;

  testWidgets('tocar em um número do teclado destaca os iguais no tabuleiro',
      (tester) async {
    _phone(tester);
    final p = generatePuzzle(Difficulty.easy, 9);
    final game = SudokuGame.start(p);
    await tester.pumpWidget(MaterialApp(
        home: GameScreen(game: game, store: MemoryGameStore())));
    await tester.pump();

    // Sem célula selecionada: só destaca, não joga.
    final before = List<int>.of(game.values);
    await _tapKey(tester, 'num-5');
    expect(painter(tester).focusDigit, 5);
    expect(game.values, before);
    expect(game.mistakes, 0);

    await _tapKey(tester, 'num-7');
    expect(painter(tester).focusDigit, 7);

    // Selecionar uma pista passa o destaque para o número dela.
    final given = game.values.indexWhere((v) => v != 0 && v != 7);
    await _tapCell(tester, given);
    expect(painter(tester).focusDigit, game.values[given]);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('teclado numérico fica logo abaixo do tabuleiro', (tester) async {
    _phone(tester);
    final game = SudokuGame.start(generatePuzzle(Difficulty.easy, 9));
    await tester.pumpWidget(MaterialApp(
        home: GameScreen(game: game, store: MemoryGameStore())));
    await tester.pump();
    final board = tester.getRect(find.byKey(const Key('board')));
    final pad = tester.getRect(find.byKey(const Key('num-1')));
    final actions = tester.getRect(find.byKey(const Key('action-undo')));
    expect(board.bottom <= pad.top, isTrue);
    expect(pad.bottom <= actions.top, isTrue);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('configurações: limite de erros, cronômetro e idioma',
      (tester) async {
    _phone(tester);
    final settings = SettingsController();
    addTearDown(() => S.lang = AppLanguage.pt);
    final game = SudokuGame.start(generatePuzzle(Difficulty.easy, 9));
    await tester.pumpWidget(MaterialApp(
      home: GameScreen(
          game: game, store: MemoryGameStore(), settings: settings),
    ));
    await tester.pump();
    expect(find.text('Erros: 0/3'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);

    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('set-mistakeLimit')));
    await tester.pumpAndSettle();
    expect(settings.value.mistakeLimitEnabled, isFalse);

    await tester.scrollUntilVisible(
        find.byKey(const Key('set-showTimer')), 200);
    await tester.tap(find.byKey(const Key('set-showTimer')));
    await tester.pumpAndSettle();
    expect(settings.value.showTimer, isFalse);

    await tester.scrollUntilVisible(
        find.byKey(const Key('set-language-AppLanguage.en')), 200);
    await tester
        .ensureVisible(find.byKey(const Key('set-language-AppLanguage.en')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('set-language-AppLanguage.en')));
    await tester.pumpAndSettle();
    expect(settings.value.language, AppLanguage.en);
    expect(find.text('Settings'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Mistakes: 0'), findsOneWidget);
    expect(find.text('00:00'), findsNothing);
    expect(find.text('Undo'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  test('configurações sobrevivem a salvar e carregar', () {
    const a = AppSettings(
      mistakeLimit: 5,
      showTimer: false,
      theme: ThemeChoice.sakura,
      language: AppLanguage.en,
    );
    final b = AppSettings.fromJson(
        jsonDecode(jsonEncode(a.toJson())) as Map<String, dynamic>);
    expect(b.mistakeLimit, 5);
    expect(b.showTimer, isFalse);
    expect(b.theme, ThemeChoice.sakura);
    expect(b.language, AppLanguage.en);
    expect(AppSettings.fromJson(const {}).mistakeLimit, 3);
  });

  testWidgets('novo jogo não apaga o anterior; lista permite continuar e apagar',
      (tester) async {
    _phone(tester);
    final store = MemoryGameStore();
    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(store: store, puzzleFactory: _syncFactory),
    ));
    await tester.pumpAndSettle();

    Future<void> startGame(String difficulty) async {
      await tester.tap(find.byKey(const Key('new-game')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('difficulty-$difficulty')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('back')));
      await tester.pumpAndSettle();
    }

    await startGame('easy');
    await startGame('hard');
    expect(store.games.length, 2);
    expect(find.text('${S.savedGames} (2)'), findsOneWidget);

    await tester.tap(find.byKey(const Key('saved-games')));
    await tester.pumpAndSettle();
    expect(find.text(S.difficulty(Difficulty.easy)), findsOneWidget);
    expect(find.text(S.difficulty(Difficulty.hard)), findsOneWidget);

    // Apagar um dos jogos, com confirmação.
    final games = await loadSavedGames(store);
    final easy =
        games.firstWhere((g) => g.puzzle.difficulty == Difficulty.easy);
    await tester.tap(find.byKey(Key('delete-${easy.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete')));
    await tester.pumpAndSettle();
    expect(store.games.length, 1);
    expect(find.text(S.difficulty(Difficulty.easy)), findsNothing);

    // Continuar o que sobrou.
    final hard = (await loadSavedGames(store)).single;
    await tester.tap(find.byKey(Key('saved-${hard.id}')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('board')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('app em segundo plano pausa o tempo da partida', (tester) async {
    _phone(tester);
    final game = SudokuGame.start(generatePuzzle(Difficulty.easy, 9));
    final store = MemoryGameStore();
    await tester.pumpWidget(
        MaterialApp(home: GameScreen(game: game, store: store)));
    await tester.pump(const Duration(seconds: 3));
    expect(game.elapsedSeconds, 3);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    // Em segundo plano a tela não é redesenhada; o salvamento já ocorreu.
    expect(store.games.containsKey(game.id), isTrue);

    await tester.pump(const Duration(seconds: 10));
    expect(game.elapsedSeconds, 3);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    // Continua pausado até o jogador retomar.
    expect(find.text(S.paused), findsOneWidget);
    await _tapKey(tester, 'resume');
    await tester.pump(const Duration(seconds: 2));
    expect(game.elapsedSeconds, 5);
    await tester.pumpWidget(const SizedBox());
  });

  SudokuGame finished(Difficulty d, {String? tag, bool won = true}) {
    final base = generatePuzzle(Difficulty.easy, 1);
    return SudokuGame.start(
        Puzzle(
            givens: base.givens,
            solution: base.solution,
            difficulty: d,
            seed: 1),
        tag: tag)
      ..status = won ? GameStatus.won : GameStatus.lost
      ..elapsedSeconds = 90;
  }

  testWidgets('vitória entra no histórico e anuncia a conquista',
      (tester) async {
    _phone(tester);
    final p = generatePuzzle(Difficulty.easy, 3);
    final game = SudokuGame.start(p);
    final empties = [
      for (var c = 0; c < kCells; c++)
        if (game.values[c] == 0) c,
    ];
    for (final c in empties.skip(1)) {
      game.place(c, p.solution[c]);
    }
    final progress = ProgressController();
    await tester.pumpWidget(MaterialApp(
      home: GameScreen(
          game: game, store: MemoryGameStore(), progress: progress),
    ));
    await tester.pump();
    await _tapCell(tester, empties.first);
    await _tapKey(tester, 'num-${p.solution[empties.first]}');
    await tester.pumpAndSettle();

    expect(progress.history.length, 1);
    expect(progress.history.single.won, isTrue);
    expect(find.textContaining(S.newAchievement), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('abas: diário mostra dias concluídos, futuros e meses anteriores',
      (tester) async {
    _phone(tester);
    final progress = ProgressController()
      ..recordFinish(finished(Difficulty.medium, tag: 'daily:20261109'));
    final store = MemoryGameStore();
    await tester.pumpWidget(MaterialApp(
      home: AppShell(
        store: store,
        settings: SettingsController(),
        progress: progress,
        puzzleFactory: _syncFactory,
        now: () => DateTime(2026, 11, 10, 15),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('new-game')), findsOneWidget);

    await tester.tap(find.byKey(const Key('tab-diary')));
    await tester.pumpAndSettle();
    expect(find.text('Novembro 2026'), findsOneWidget);
    expect(find.textContaining('1/30'), findsOneWidget);

    FilledButton playButton() =>
        tester.widget<FilledButton>(find.byKey(const Key('daily-play')));

    // Hoje: disponível.
    expect(playButton().onPressed, isNotNull);
    expect(find.text(S.play), findsOneWidget);

    // Ontem: já concluído.
    await tester.tap(find.byKey(const Key('day-9')));
    await tester.pump();
    expect(find.text(S.done), findsOneWidget);
    expect(playButton().onPressed, isNull);

    // Amanhã: bloqueado.
    await tester.tap(find.byKey(const Key('day-11')));
    await tester.pump();
    expect(find.text(S.futureDay), findsOneWidget);
    expect(playButton().onPressed, isNull);

    // Mês anterior é jogável; mês futuro não abre.
    await tester.tap(find.byKey(const Key('month-prev')));
    await tester.pump();
    expect(find.text('Outubro 2026'), findsOneWidget);
    expect(playButton().onPressed, isNotNull);
    await tester.tap(find.byKey(const Key('month-next')));
    await tester.pump();
    expect(find.text('Novembro 2026'), findsOneWidget);

    // Jogar o desafio de hoje abre o tabuleiro e marca a partida como diária.
    await tester.tap(find.byKey(const Key('day-10')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('daily-play')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('board')), findsOneWidget);
    final saved = await loadSavedGames(store);
    expect(saved.single.tag, 'daily:20261110');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('abas: estatísticas e conquistas refletem o histórico',
      (tester) async {
    _phone(tester);
    final progress = ProgressController()
      ..recordFinish(finished(Difficulty.easy))
      ..recordFinish(finished(Difficulty.easy))
      ..recordFinish(finished(Difficulty.easy, won: false));
    final settings = SettingsController();
    await tester.pumpWidget(MaterialApp(
      home: AppShell(
        store: MemoryGameStore(),
        settings: settings,
        progress: progress,
        puzzleFactory: _syncFactory,
        now: () => DateTime(2026, 11, 10),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tab-stats')));
    await tester.pumpAndSettle();

    String stat(String id) =>
        tester.widget<Text>(find.byKey(Key('stat-$id'))).data!;
    expect(stat('started'), '3');
    expect(stat('won'), '2');
    expect(stat('rate'), '67%');
    expect(stat('best'), '01:30');

    await tester.tap(find.byKey(const Key('open-history')));
    await tester.pumpAndSettle();
    expect(find.textContaining(S.victory), findsNWidgets(2));
    expect(find.textContaining(S.defeat), findsOneWidget);
    await tester.pumpWidget(const SizedBox());

    await tester.pumpWidget(MaterialApp(
      home: AchievementsScreen(settings: settings, progress: progress),
    ));
    await tester.pump();
    // Com duas vitórias sem erros: "Água limpa" e "Vento a favor".
    expect(find.text('2 / 22'), findsOneWidget);
    expect(find.text(S.suggestions.toUpperCase()), findsOneWidget);
    expect(find.text(S.unlocked.toUpperCase()), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
