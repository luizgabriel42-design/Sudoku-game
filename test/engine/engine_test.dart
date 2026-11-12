import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:umi_sudoku/data/strategy_examples.dart';
import 'package:umi_sudoku/engine/daily.dart';
import 'package:umi_sudoku/engine/game.dart';
import 'package:umi_sudoku/engine/generator.dart';
import 'package:umi_sudoku/engine/grid.dart';
import 'package:umi_sudoku/engine/hint.dart';
import 'package:umi_sudoku/engine/logical_solver.dart';
import 'package:umi_sudoku/engine/techniques.dart';

const _slow = Timeout(Duration(minutes: 10));

bool _validSolution(List<int> s) {
  for (final unit in Units.all) {
    var m = 0;
    for (final c in unit) {
      if (s[c] < 1 || s[c] > 9) return false;
      m |= bit(s[c]);
    }
    if (m != kAllDigits) return false;
  }
  return true;
}

/// Confere que cada passo lógico é sólido em relação à solução.
void _expectSound(SolveStep s, List<int> solution) {
  if (s.isPlacement) {
    expect(s.digit, solution[s.cell!], reason: 'preenchimento errado: $s');
  }
  for (final e in s.eliminations) {
    expect(e.digit == solution[e.cell], isFalse,
        reason: 'eliminou o valor correto: $s');
  }
}

void main() {
  group('geometria', () {
    test('cada célula tem 20 vizinhas', () {
      for (var c = 0; c < kCells; c++) {
        expect(Units.peers[c].length, 20);
      }
    });

    test('Rng é determinístico', () {
      final a = Rng(42);
      final b = Rng(42);
      for (var i = 0; i < 100; i++) {
        expect(a.next(), b.next());
      }
    });
  });

  group('gerador', () {
    for (final d in Difficulty.values) {
      test('${d.name}: solução única, válida e dentro do nível', () {
        final n = d.maxTier >= 4 ? 3 : 6;
        final seen = <String, int>{};
        for (var seed = 1; seed <= n; seed++) {
          final sw = Stopwatch()..start();
          final p = generatePuzzle(d, seed);
          sw.stop();

          expect(_validSolution(p.solution), isTrue);
          for (var c = 0; c < kCells; c++) {
            if (p.givens[c] != 0) expect(p.givens[c], p.solution[c]);
          }
          expect(countSolutions(p.givens), 1, reason: 'solução não é única');

          final r = solveLogically(p.givens, maxTier: d.maxTier);
          expect(r.solved, isTrue);
          expect(r.values, p.solution);
          expect(r.maxTier <= d.maxTier, isTrue);
          for (final s in r.steps) {
            _expectSound(s, p.solution);
            seen[s.technique.name] = (seen[s.technique.name] ?? 0) + 1;
          }
          // ignore: avoid_print
          print('${d.name} seed=$seed pistas=${p.clueCount} '
              'tecnica=${p.hardest?.name} tempo=${sw.elapsedMilliseconds}ms');
        }
        // ignore: avoid_print
        print('${d.name}: técnicas usadas $seen');
      }, timeout: _slow);
    }

    test('fácil e casual só exigem as técnicas mais simples', () {
      for (final d in [Difficulty.casual, Difficulty.easy]) {
        final p = generatePuzzle(d, 7);
        expect(p.hardest!.tier, 1);
        expect(p.clueCount >= d.minClues, isTrue);
      }
    });

    test('médio exige técnica de nível 2', () {
      final p = generatePuzzle(Difficulty.medium, 11);
      expect(p.hardest!.tier, 2);
    });

    test('mesma semente gera o mesmo puzzle', () {
      final a = generatePuzzle(Difficulty.hard, 2026);
      final b = generatePuzzle(Difficulty.hard, 2026);
      expect(a.givens, b.givens);
      expect(a.solution, b.solution);
      final c = generatePuzzle(Difficulty.hard, 2027);
      expect(c.givens.join() == a.givens.join(), isFalse);
    }, timeout: _slow);

    test('countSolutions detecta múltiplas soluções e contradições', () {
      expect(countSolutions(List<int>.filled(kCells, 0)), 2);
      final bad = List<int>.filled(kCells, 0);
      bad[0] = 5;
      bad[1] = 5;
      expect(countSolutions(bad), 0);
    });
  });

  group('dicas', () {
    for (final d in [Difficulty.easy, Difficulty.hard, Difficulty.expert]) {
      test('${d.name}: cada dica preenche exatamente um quadrado correto',
          () {
        final p = generatePuzzle(d, 5);
        final values = List<int>.of(p.givens);
        var count = 0;
        final taught = <String>{};
        while (values.contains(0)) {
          final h = computeHint(values, p.solution)!;
          expect(values[h.cell], 0, reason: 'dica em célula já preenchida');
          expect(h.digit, p.solution[h.cell]);
          if (h.direct) {
            expect(h.steps, isEmpty);
          } else {
            expect(h.steps, isNotEmpty);
            expect(h.steps.last.isPlacement, isTrue);
            expect(h.steps.last.cell, h.cell);
            for (var i = 0; i < h.steps.length - 1; i++) {
              expect(h.steps[i].isPlacement, isFalse,
                  reason: 'a dica só pode preencher um quadrado');
            }
            for (final s in h.steps) {
              _expectSound(s, p.solution);
            }
            taught.add(h.technique!.name);
          }
          values[h.cell] = h.digit;
          count++;
          expect(count <= kCells, isTrue);
        }
        expect(values, p.solution);
        // ignore: avoid_print
        print('${d.name}: técnicas ensinadas nas dicas $taught');
      }, timeout: _slow);
    }

    test('ignora valores errados e retorna null com tabuleiro completo', () {
      final p = generatePuzzle(Difficulty.easy, 3);
      final values = List<int>.of(p.givens);
      final empty = values.indexOf(0);
      values[empty] = p.solution[empty] % 9 + 1; // valor errado
      final h = computeHint(values, p.solution)!;
      expect(h.digit, p.solution[h.cell]);
      expect(computeHint(p.solution, p.solution), isNull);
    });
  });

  group('partida', () {
    late Puzzle p;
    setUp(() => p = generatePuzzle(Difficulty.easy, 9));

    int firstEmpty(SudokuGame g) => g.values.indexOf(0);
    int wrongFor(Puzzle p, int cell) => p.solution[cell] % 9 + 1;

    test('acerto trava a célula e erro conta', () {
      final g = SudokuGame.start(p);
      final c = firstEmpty(g);
      expect(g.place(c, wrongFor(p, c)), PlaceOutcome.mistake);
      expect(g.mistakes, 1);
      expect(g.isWrong(c), isTrue);
      expect(g.place(c, p.solution[c]), PlaceOutcome.correct);
      expect(g.isLocked(c), isTrue);
      expect(g.place(c, wrongFor(p, c)), PlaceOutcome.ignored);
      expect(g.mistakes, 1);
    });

    test('limite de 3 erros encerra a partida', () {
      final g = SudokuGame.start(p);
      final c = firstEmpty(g);
      final wrongs = [
        for (var d = 1; d <= 9; d++)
          if (d != p.solution[c]) d,
      ];
      expect(g.place(c, wrongs[0]), PlaceOutcome.mistake);
      expect(g.place(c, wrongs[1]), PlaceOutcome.mistake);
      expect(g.place(c, wrongs[2]), PlaceOutcome.lost);
      expect(g.status, GameStatus.lost);
      expect(g.place(c, p.solution[c]), PlaceOutcome.ignored);
    });

    test('casual não tem limite de erros', () {
      final g = SudokuGame.start(generatePuzzle(Difficulty.casual, 9));
      final c = firstEmpty(g);
      final wrongs = [
        for (var d = 1; d <= 9; d++)
          if (d != g.puzzle.solution[c]) d,
      ];
      for (final w in wrongs.take(5)) {
        expect(g.place(c, w), PlaceOutcome.mistake);
      }
      expect(g.status, GameStatus.playing);
    });

    test('notas: prevenção de erro', () {
      final g = SudokuGame.start(p);
      final c = firstEmpty(g);

      // Um dígito que já está em uma vizinha é recusado.
      final peerValue = Units.peers[c]
          .map((x) => g.values[x])
          .firstWhere((v) => v != 0);
      expect(g.toggleNote(c, peerValue), isFalse);

    });

    test('notas: remoção automática e desfazer', () {
      final g = SudokuGame.start(p,
          rules: const GameRules(preventWrongNotes: false));
      final c = firstEmpty(g);
      final sol = p.solution[c];

      // Anota a solução de `c` em uma vizinha vazia e depois preenche `c`.
      final peer = Units.peers[c].firstWhere((x) => g.values[x] == 0);
      expect(g.toggleNote(peer, sol), isTrue);
      expect(g.notes[peer] & bit(sol), isNot(0));
      g.place(c, sol);
      expect(g.notes[peer] & bit(sol), 0);

      expect(g.undo(), isTrue);
      expect(g.values[c], 0);
      expect(g.notes[peer] & bit(sol), isNot(0));
    });

    test('notas avançadas contêm sempre a solução', () {
      final g = SudokuGame.start(p)..fillAutoNotes();
      for (var c = 0; c < kCells; c++) {
        if (g.values[c] == 0) {
          expect(g.notes[c] & bit(p.solution[c]), isNot(0));
        } else {
          expect(g.notes[c], 0);
        }
      }
    });

    test('vitória, contagem de restantes e dica aplicada', () {
      final g = SudokuGame.start(p);
      final h = g.hint()!;
      expect(g.applyHint(h), PlaceOutcome.correct);
      expect(g.hintsUsed, 1);
      expect(g.values[h.cell], h.digit);

      PlaceOutcome? last;
      for (var c = 0; c < kCells; c++) {
        if (g.values[c] == 0) last = g.place(c, p.solution[c]);
      }
      expect(last, PlaceOutcome.won);
      expect(g.status, GameStatus.won);
      for (var d = 1; d <= 9; d++) {
        expect(g.remaining(d), 0);
        expect(g.isDigitComplete(d), isTrue);
      }
    });

    test('completar automaticamente só quando o resto é trivial', () {
      final g = SudokuGame.start(p);
      expect(g.autoCompleteIfTrivial(), isFalse);
      final empties = [
        for (var c = 0; c < kCells; c++)
          if (g.values[c] == 0) c,
      ];
      for (final c in empties.skip(1)) {
        g.place(c, p.solution[c]);
      }
      expect(g.status, GameStatus.playing);
      expect(g.autoCompleteIfTrivial(), isTrue);
      expect(g.status, GameStatus.won);
      expect(g.values, p.solution);
    });

    test('salvar e restaurar em JSON preserva a partida', () {
      final g = SudokuGame.start(p);
      final c = firstEmpty(g);
      g.place(c, p.solution[c]);
      final other = firstEmpty(g);
      g.toggleNote(other, p.solution[other]);
      g.place(firstEmpty(g), wrongFor(p, firstEmpty(g)));
      g.elapsedSeconds = 123;

      final restored = SudokuGame.fromJson(
          jsonDecode(jsonEncode(g.toJson())) as Map<String, dynamic>);
      expect(restored.values, g.values);
      expect(restored.notes, g.notes);
      expect(restored.mistakes, g.mistakes);
      expect(restored.elapsedSeconds, 123);
      expect(restored.puzzle.givens, p.givens);
      expect(restored.puzzle.solution, p.solution);
      expect(restored.puzzle.difficulty, p.difficulty);
      expect(restored.canUndo, isTrue);
      expect(restored.undo(), isTrue);
    });
  });

  group('desafio diário', () {
    test('mesma data gera o mesmo puzzle e o mesmo animal', () {
      final d1 = DateTime(2026, 11, 10, 8);
      final d2 = DateTime(2026, 11, 10, 23, 59);
      expect(dailySeed(d1), 20261110);
      expect(dailyPuzzle(d1).givens, dailyPuzzle(d2).givens);
      expect(dayAnimal(d1), dayAnimal(d2));
    }, timeout: _slow);

    test('animais seguem sequência fixa de 12 dias', () {
      final start = DateTime(2026, 1, 1);
      for (var i = 0; i < 400; i++) {
        final day = DateTime(2026, 1, 1 + i);
        expect(dayAnimal(day), Animal.values[i % 12]);
      }
      expect(dayAnimal(start), Animal.crane);
      expect(dayAnimal(DateTime(2025, 12, 31)), Animal.koi);
    });

    test('troféus mensais: animal e motivo', () {
      expect(monthAnimal(1), Animal.crane);
      expect(monthAnimal(11), Animal.monkey);
      expect(monthAnimal(12), Animal.koi);
      expect(monthMotif(1), Motif.asanoha);
      expect(monthMotif(11), Motif.heron);
      for (var m = 1; m <= 12; m++) {
        expect(Animal.values.contains(monthAnimal(m)), isTrue);
      }
    });
  });

  test('as 18 técnicas do menu existem e estão implementadas', () {
    expect(Technique.values.length, 18);
    expect(Technique.values.every((t) => t.implemented), isTrue);
  });

  test('XCycle: todas as deduções são sólidas ao longo de vários jogos', () {
    var checked = 0;
    for (var seed = 1; seed <= 6; seed++) {
      final p = generatePuzzle(Difficulty.expert, seed);
      final g = CandidateGrid.fromValues(p.givens);
      while (!g.solved) {
        for (final s in findSteps(g, Technique.xCycle)) {
          _expectSound(s, p.solution);
          expect(s.isPlacement, isFalse);
          checked++;
        }
        final next = nextStep(g);
        if (next == null) break;
        applyStep(g, next);
      }
      expect(g.solved, isTrue);
    }
    // ignore: avoid_print
    print('XCycle: $checked deduções conferidas');
    expect(checked > 0, isTrue);
  }, timeout: _slow);

  test('exemplos do menu de estratégias batem com o solucionador', () {
    expect(strategyExamples.keys.toSet(), Technique.values.toSet());
    for (final e in strategyExamples.entries) {
      final values = [for (final ch in e.value.values.split('')) int.parse(ch)];
      final g = CandidateGrid.fromValues(values);
      for (var c = 0; c < kCells; c++) {
        g.cands[c] = e.value.cands[c];
      }
      final keys = findSteps(g, e.key).map((s) => s.key);
      expect(keys, contains(e.value.step.key),
          reason: 'exemplo de ${e.key.name} não é reproduzido');
    }
  });
}
