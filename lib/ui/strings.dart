/// Textos da interface em português.
///
/// Fase 3: estes textos migram para arquivos de tradução (pt-BR e en).
/// Por isso ficam todos concentrados aqui, fora das telas.
library;

import '../engine/generator.dart';
import '../engine/grid.dart';
import '../engine/hint.dart';
import '../engine/techniques.dart';

class S {
  static const appName = 'Umi Sudoku';
  static const continueGame = 'Continuar';
  static const newGame = 'Novo jogo';
  static const dailyChallenge = 'Desafio diário';
  static const special = 'Especial';
  static const soon = 'Em breve';
  static const mistakes = 'Erros';
  static const paused = 'Jogo pausado';
  static const resume = 'Retomar';
  static const undo = 'Desfazer';
  static const erase = 'Apagar';
  static const autoNotes = 'Notas avançadas';
  static const notes = 'Notas';
  static const on = 'ATIVO';
  static const off = 'DESATIVADO';
  static const hint = 'Dica';
  static const apply = 'Aplicar';
  static const close = 'Fechar';
  static const directSolution = 'Solução direta';
  static const directSolutionBody =
      'Nenhuma das estratégias conhecidas se aplica agora. '
      'O valor correto deste quadrado é';
  static const won = 'Parabéns!';
  static const wonBody = 'Você concluiu o tabuleiro.';
  static const lost = 'Fim de jogo';
  static const lostBody = 'Você atingiu o limite de erros.';
  static const tryAgain = 'Tentar de novo';
  static const home = 'Início';
  static const time = 'Tempo';
  static const hintsUsed = 'Dicas usadas';
  static const noMistakes = 'Vitória sem erros';
  static const generating = 'Preparando o tabuleiro…';

  static String difficulty(Difficulty d) => switch (d) {
        Difficulty.casual => 'Casual',
        Difficulty.easy => 'Fácil',
        Difficulty.medium => 'Médio',
        Difficulty.hard => 'Difícil',
        Difficulty.expert => 'Expert',
        Difficulty.nightmare => 'Pesadelo',
      };

  static String technique(Technique t) => switch (t) {
        Technique.lastBlankCell => 'Last Blank Cell',
        Technique.lastRemainingCell => 'Last Remaining Cell',
        Technique.singleCandidate => 'Single Candidate',
        Technique.hiddenSingle => 'Hidden Single',
        Technique.nakedPair => 'Naked Pair',
        Technique.intersectionRemoval => 'Intersection Removal',
        Technique.hiddenPair => 'Hidden Pair',
        Technique.nakedTriplet => 'Naked Triplet',
        Technique.hiddenTriplet => 'Hidden Triplet',
        Technique.nakedQuad => 'Naked Quad',
        Technique.hiddenQuad => 'Hidden Quad',
        Technique.xWing => 'X-Wing',
        Technique.xyWing => 'XY-Wing',
        Technique.xyzWing => 'XYZ-Wing',
        Technique.swordfish => 'Swordfish',
        Technique.jellyfish => 'Jellyfish',
        Technique.simpleColoring => 'Simple Coloring',
        Technique.xCycle => 'XCycle',
      };

  static String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  static String _cap(String t) =>
      t.isEmpty ? t : t[0].toUpperCase() + t.substring(1);

  static String cell(int c) => 'L${rowOf(c) + 1}C${colOf(c) + 1}';

  static String cells(List<int> cs) => cs.map(cell).join(', ');

  /// "na linha 2", "na coluna 5", "no bloco 7".
  static String inUnit(int u) {
    if (Units.isRow(u)) return 'na linha ${u + 1}';
    if (Units.isCol(u)) return 'na coluna ${u - 8}';
    return 'no bloco ${u - 17}';
  }

  /// "da linha 2", "da coluna 5", "do bloco 7".
  static String ofUnit(int u) {
    if (Units.isRow(u)) return 'da linha ${u + 1}';
    if (Units.isCol(u)) return 'da coluna ${u - 8}';
    return 'do bloco ${u - 17}';
  }

  /// Explica um passo lógico em uma frase.
  static String step(SolveStep s) {
    final ds = s.patternDigits.join(', ');
    final u = s.units.isNotEmpty ? inUnit(s.units.first) : '';
    final of = s.units.isNotEmpty ? ofUnit(s.units.first) : '';
    switch (s.technique) {
      case Technique.lastBlankCell:
        return 'Só falta um quadrado $u. O número que resta é ${s.digit}.';
      case Technique.lastRemainingCell:
      case Technique.hiddenSingle:
        return '${_cap(u)}, o ${s.digit} só cabe no quadrado ${cell(s.cell!)}.';
      case Technique.singleCandidate:
        return 'No quadrado ${cell(s.cell!)} só é possível o ${s.digit}: '
            'os outros números já aparecem na linha, coluna ou bloco.';
      case Technique.nakedPair:
      case Technique.nakedTriplet:
      case Technique.nakedQuad:
        return '${_cap(u)}, os quadrados ${cells(s.patternCells)} só podem '
            'conter $ds. Esses números saem dos outros quadrados $of.';
      case Technique.hiddenPair:
      case Technique.hiddenTriplet:
      case Technique.hiddenQuad:
        return '${_cap(u)}, os números $ds só cabem em ${cells(s.patternCells)}. '
            'Os outros candidatos desses quadrados são eliminados.';
      case Technique.intersectionRemoval:
        final to = inUnit(s.units.last);
        final ofTo = ofUnit(s.units.last);
        return '${_cap(u)}, o $ds só cabe em quadrados que também ficam $to. '
            'Por isso ele sai do restante $ofTo.';
      case Technique.xWing:
      case Technique.swordfish:
      case Technique.jellyfish:
        return 'O $ds forma um ${technique(s.technique)} nos quadrados '
            '${cells(s.patternCells)}. Ele é eliminado das outras posições '
            'das linhas ou colunas que cruzam o padrão.';
      case Technique.xyWing:
      case Technique.xyzWing:
        final z = s.eliminations.first.digit;
        return 'O pivô ${cell(s.patternCells[0])} e as asas '
            '${cell(s.patternCells[1])} e ${cell(s.patternCells[2])} garantem '
            'um $z em um deles. Quadrados que veem todos perdem o $z.';
      case Technique.simpleColoring:
        return 'Os quadrados ${cells(s.patternCells)} formam uma cadeia de '
            'pares do $ds, pintada em duas cores alternadas. Uma das cores é '
            'a verdadeira, o que elimina o $ds de: '
            '${cells(s.eliminations.map((e) => e.cell).toList())}.';
      case Technique.xCycle:
        return '';
    }
  }

  /// Texto completo da dica: os passos de eliminação e o preenchimento.
  static List<String> hintLines(Hint h) {
    if (h.direct) {
      return ['$directSolutionBody ${h.digit} (${cell(h.cell)}).'];
    }
    final out = <String>[];
    for (var i = 0; i < h.steps.length; i++) {
      final s = h.steps[i];
      final prefix = h.steps.length > 1 ? '${i + 1}. ' : '';
      final name = h.steps.length > 1 ? '${technique(s.technique)}: ' : '';
      out.add('$prefix$name${step(s)}');
    }
    return out;
  }
}
