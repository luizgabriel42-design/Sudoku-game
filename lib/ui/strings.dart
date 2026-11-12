/// Textos da interface, em português (padrão) e inglês.
///
/// O idioma ativo fica em [S.lang] e é trocado nas Configurações.
/// Todos os textos ficam aqui, fora das telas.
library;

import '../engine/generator.dart';
import '../engine/grid.dart';
import '../engine/hint.dart';
import '../engine/techniques.dart';

enum AppLanguage { pt, en }

class S {
  static AppLanguage lang = AppLanguage.pt;

  static String _t(String pt, String en) => lang == AppLanguage.pt ? pt : en;

  static const appName = 'Umi Sudoku';
  static String get continueGame => _t('Continuar', 'Continue');
  static String get newGame => _t('Novo jogo', 'New game');
  static String get dailyChallenge => _t('Desafio diário', 'Daily challenge');
  static String get special => _t('Especial', 'Special');
  static String get soon => _t('Em breve', 'Coming soon');
  static String get mistakes => _t('Erros', 'Mistakes');
  static String get paused => _t('Jogo pausado', 'Game paused');
  static String get resume => _t('Retomar', 'Resume');
  static String get undo => _t('Desfazer', 'Undo');
  static String get erase => _t('Apagar', 'Erase');
  static String get autoNotes => _t('Notas avançadas', 'Auto notes');
  static String get notes => _t('Notas', 'Notes');
  static String get on => _t('ATIVO', 'ON');
  static String get off => _t('DESATIVADO', 'OFF');
  static String get hint => _t('Dica', 'Hint');
  static String get apply => _t('Aplicar', 'Apply');
  static String get close => _t('Fechar', 'Close');
  static String get directSolution => _t('Solução direta', 'Direct solution');
  static String get directSolutionBody => _t(
      'Nenhuma das estratégias conhecidas se aplica agora. '
          'O valor correto deste quadrado é',
      'None of the known strategies applies right now. '
          'The correct value for this cell is');
  static String get won => _t('Parabéns!', 'Well done!');
  static String get wonBody =>
      _t('Você concluiu o tabuleiro.', 'You completed the board.');
  static String get lost => _t('Fim de jogo', 'Game over');
  static String get lostBody => _t('Você atingiu o limite de erros.',
      'You reached the mistake limit.');
  static String get tryAgain => _t('Tentar de novo', 'Try again');
  static String get home => _t('Início', 'Home');
  static String get time => _t('Tempo', 'Time');
  static String get hintsUsed => _t('Dicas usadas', 'Hints used');
  static String get noMistakes =>
      _t('Vitória sem erros', 'Flawless victory');
  static String get generating =>
      _t('Preparando o tabuleiro…', 'Preparing the board…');

  // Jogos iniciados
  static String get savedGames => _t('Jogos iniciados', 'Games in progress');
  static String get noSavedGames =>
      _t('Nenhum jogo em andamento.', 'No games in progress.');
  static String get deleteGame => _t('Apagar este jogo?', 'Delete this game?');
  static String get deleteGameBody => _t(
      'O progresso desta partida será perdido.',
      'The progress of this game will be lost.');
  static String get cancel => _t('Cancelar', 'Cancel');
  static String get delete => _t('Apagar', 'Delete');
  static String get completed => _t('concluído', 'completed');

  // Configurações
  static String get settings => _t('Configurações', 'Settings');
  static String get secHighlights => _t('Destaques', 'Highlights');
  static String get secMistakes => _t('Erros', 'Mistakes');
  static String get secGame => _t('Jogo', 'Game');
  static String get secAppearance => _t('Aparência', 'Appearance');
  static String get secFeedback => _t('Toque', 'Feedback');
  static String get setSame => _t('Destacar números iguais', 'Highlight same numbers');
  static String get setSameSub => _t(
      'Ao selecionar um número, as outras células com o mesmo número são destacadas.',
      'When a number is selected, other cells with the same number are highlighted.');
  static String get setRegion => _t('Destacar região', 'Highlight area');
  static String get setRegionSub => _t(
      'Destaca a linha, a coluna e o bloco da célula selecionada.',
      'Highlights the row, column and block of the selected cell.');
  static String get setNotesHl => _t('Destacar notas', 'Highlight notes');
  static String get setNotesHlSub => _t(
      'Ao selecionar um número, ele é destacado em todas as notas.',
      'When a number is selected, it is highlighted in all notes.');
  static String get setLimit => _t('Limite de erros', 'Mistake limit');
  static String setLimitSub(int n) => _t(
      'A partida termina ao atingir $n erros.',
      'The game ends after $n mistakes.');
  static String get setLimitValue => _t('Quantidade de erros', 'Number of mistakes');
  static String get setTimer => _t('Cronômetro', 'Timer');
  static String get setNumberFirst =>
      _t('Entrada número-primeiro', 'Number-first input');
  static String get setNumberFirstSub => _t(
      'Toque e segure um número para travá-lo e usá-lo em várias células.',
      'Touch and hold a number to lock it and use it on several cells.');
  static String get setRemaining => _t('Números restantes', 'Remaining numbers');
  static String get setRemainingSub => _t(
      'Mostra quantas vezes cada número ainda falta.',
      'Shows how many of each number are still missing.');
  static String get setAutoComplete =>
      _t('Completar automaticamente', 'Auto-complete');
  static String get setAutoCompleteSub => _t(
      'Quando só restam células com um único valor possível, o tabuleiro é concluído.',
      'When only cells with a single possible value remain, the board is completed.');
  static String get setPrevent =>
      _t('Prevenção de notas erradas', 'Prevent wrong notes');
  static String get setPreventSub => _t(
      'Impede anotar um número que já está na linha, coluna ou bloco.',
      'Blocks notes for a number already in the row, column or block.');
  static String get setAutoRemove =>
      _t('Remover notas automaticamente', 'Auto-remove notes');
  static String get setAutoRemoveSub => _t(
      'Ao colocar um número, ele sai das notas da linha, coluna e bloco.',
      'Placing a number removes it from notes in its row, column and block.');
  static String get setTheme => _t('Tema', 'Theme');
  static String get themeSystem => _t('Sistema', 'System');
  static String get themeDark => _t('Escuro', 'Dark');
  static String get setLanguage => _t('Idioma', 'Language');
  static String get setVibrate => _t('Vibrar ao errar', 'Vibrate on mistake');

  static String difficulty(Difficulty d) => switch (d) {
        Difficulty.casual => 'Casual',
        Difficulty.easy => _t('Fácil', 'Easy'),
        Difficulty.medium => _t('Médio', 'Medium'),
        Difficulty.hard => _t('Difícil', 'Hard'),
        Difficulty.expert => 'Expert',
        Difficulty.nightmare => _t('Pesadelo', 'Nightmare'),
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

  /// Célula: "L2C5" em português, "R2C5" em inglês.
  static String cell(int c) =>
      '${_t('L', 'R')}${rowOf(c) + 1}C${colOf(c) + 1}';

  static String cells(List<int> cs) => cs.map(cell).join(', ');

  /// "na linha 2", "na coluna 5", "no bloco 7".
  static String inUnit(int u) {
    if (Units.isRow(u)) return _t('na linha ${u + 1}', 'in row ${u + 1}');
    if (Units.isCol(u)) return _t('na coluna ${u - 8}', 'in column ${u - 8}');
    return _t('no bloco ${u - 17}', 'in block ${u - 17}');
  }

  /// "da linha 2", "da coluna 5", "do bloco 7".
  static String ofUnit(int u) {
    if (Units.isRow(u)) return _t('da linha ${u + 1}', 'of row ${u + 1}');
    if (Units.isCol(u)) return _t('da coluna ${u - 8}', 'of column ${u - 8}');
    return _t('do bloco ${u - 17}', 'of block ${u - 17}');
  }

  /// Explica um passo lógico em uma frase.
  static String step(SolveStep s) {
    final ds = s.patternDigits.join(', ');
    final u = s.units.isNotEmpty ? inUnit(s.units.first) : '';
    final of = s.units.isNotEmpty ? ofUnit(s.units.first) : '';
    final pc = cells(s.patternCells);
    switch (s.technique) {
      case Technique.lastBlankCell:
        return _t('Só falta um quadrado $u. O número que resta é ${s.digit}.',
            'Only one cell is left $u. The missing number is ${s.digit}.');
      case Technique.lastRemainingCell:
      case Technique.hiddenSingle:
        return _t(
            '${_cap(u)}, o ${s.digit} só cabe no quadrado ${cell(s.cell!)}.',
            '${_cap(u)}, ${s.digit} can only go in cell ${cell(s.cell!)}.');
      case Technique.singleCandidate:
        return _t(
            'No quadrado ${cell(s.cell!)} só é possível o ${s.digit}: '
                'os outros números já aparecem na linha, coluna ou bloco.',
            'Cell ${cell(s.cell!)} can only be ${s.digit}: every other '
                'number already appears in its row, column or block.');
      case Technique.nakedPair:
      case Technique.nakedTriplet:
      case Technique.nakedQuad:
        return _t(
            '${_cap(u)}, os quadrados $pc só podem conter $ds. '
                'Esses números saem dos outros quadrados $of.',
            '${_cap(u)}, cells $pc can only hold $ds. '
                'Those numbers are removed from the other cells $of.');
      case Technique.hiddenPair:
      case Technique.hiddenTriplet:
      case Technique.hiddenQuad:
        return _t(
            '${_cap(u)}, os números $ds só cabem em $pc. '
                'Os outros candidatos desses quadrados são eliminados.',
            '${_cap(u)}, the numbers $ds only fit in $pc. '
                'The other candidates in those cells are removed.');
      case Technique.intersectionRemoval:
        final to = inUnit(s.units.last);
        final ofTo = ofUnit(s.units.last);
        return _t(
            '${_cap(u)}, o $ds só cabe em quadrados que também ficam $to. '
                'Por isso ele sai do restante $ofTo.',
            '${_cap(u)}, $ds only fits in cells that are also $to. '
                'So it is removed from the rest $ofTo.');
      case Technique.xWing:
      case Technique.swordfish:
      case Technique.jellyfish:
        return _t(
            'O $ds forma um ${technique(s.technique)} nos quadrados $pc. '
                'Ele é eliminado das outras posições das linhas ou colunas '
                'que cruzam o padrão.',
            'The number $ds forms a ${technique(s.technique)} in cells $pc. '
                'It is removed from the other positions of the rows or '
                'columns crossing the pattern.');
      case Technique.xyWing:
      case Technique.xyzWing:
        final z = s.eliminations.first.digit;
        final a = cell(s.patternCells[0]);
        final b = cell(s.patternCells[1]);
        final c = cell(s.patternCells[2]);
        return _t(
            'O pivô $a e as asas $b e $c garantem um $z em um deles. '
                'Quadrados que veem todos perdem o $z.',
            'Pivot $a and wings $b and $c guarantee a $z in one of them. '
                'Cells that see all of them lose $z.');
      case Technique.simpleColoring:
        final el = cells(s.eliminations.map((e) => e.cell).toList());
        return _t(
            'Os quadrados $pc formam uma cadeia de pares do $ds, pintada em '
                'duas cores alternadas. Uma das cores é a verdadeira, o que '
                'elimina o $ds de: $el.',
            'Cells $pc form a chain of pairs for $ds, painted in two '
                'alternating colors. One color is true, which removes $ds '
                'from: $el.');
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
