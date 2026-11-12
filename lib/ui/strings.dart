/// Textos da interface, em português (padrão) e inglês.
///
/// O idioma ativo fica em [S.lang] e é trocado nas Configurações.
/// Todos os textos ficam aqui, fora das telas.
library;

import '../data/achievements.dart';
import '../engine/daily.dart';
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

  // Navegação e progresso
  static String get tabHome => _t('Início', 'Home');
  static String get tabDiary => _t('Diário', 'Daily');
  static String get tabStats => _t('Estatísticas', 'Statistics');
  static String get play => _t('Jogar', 'Play');
  static String get done => _t('Concluído', 'Completed');
  static String get futureDay =>
      _t('Disponível no dia', 'Available on the day');
  static String get monthTrophy => _t('Troféu do mês', 'Monthly trophy');
  static String get achievementsTitle => _t('Conquistas', 'Achievements');
  static String get suggestions => _t('Sugestões', 'Suggestions');
  static String get unlocked => _t('Desbloqueadas', 'Unlocked');
  static String get locked => _t('Bloqueadas', 'Locked');
  static String get newAchievement =>
      _t('Conquista desbloqueada', 'Achievement unlocked');
  static String get prizes => _t('Prêmios', 'Prizes');
  static String get challenges => _t('Desafios', 'Challenges');
  static String get adventures => _t('Aventuras', 'Adventures');
  static String get events => _t('Eventos', 'Events');
  static String get history => _t('Histórico', 'History');
  static String get noHistory =>
      _t('Nenhum jogo concluído ainda.', 'No finished games yet.');
  static String get victory => _t('Vitória', 'Win');
  static String get defeat => _t('Derrota', 'Loss');
  static String get games => _t('Jogos', 'Games');
  static String get gamesStarted => _t('Jogos iniciados', 'Games started');
  static String get gamesWon => _t('Jogos ganhos', 'Games won');
  static String get winRate => _t('Taxa de vitória', 'Win rate');
  static String get flawlessWins => _t('Vitórias sem erros', 'Flawless wins');
  static String get bestTime => _t('Melhor tempo', 'Best time');
  static String get averageTime => _t('Tempo médio', 'Average time');
  static String get streaks => _t('Sequências', 'Streaks');
  static String get currentStreak =>
      _t('Sequência atual de vitórias', 'Current win streak');
  static String get bestStreak =>
      _t('Melhor sequência de vitórias', 'Best win streak');
  static String get syncSoon => _t(
      'Entrar para sincronizar · em breve', 'Sign in to sync · coming soon');
  static String get hints => _t('Dicas', 'Hints');

  static String rarity(Rarity r) => switch (r) {
        Rarity.uncommon => _t('Incomum', 'Uncommon'),
        Rarity.rare => _t('Rara', 'Rare'),
        Rarity.epic => _t('Épica', 'Epic'),
      };

  static String animal(Animal a) => switch (a) {
        Animal.crane => _t('Grou', 'Crane'),
        Animal.owl => _t('Coruja', 'Owl'),
        Animal.butterfly => _t('Borboleta', 'Butterfly'),
        Animal.turtle => _t('Tartaruga', 'Turtle'),
        Animal.fox => _t('Raposa', 'Fox'),
        Animal.deer => _t('Cervo', 'Deer'),
        Animal.dragonfly => _t('Libélula', 'Dragonfly'),
        Animal.cat => _t('Gato', 'Cat'),
        Animal.swallow => _t('Andorinha', 'Swallow'),
        Animal.frog => _t('Sapo', 'Frog'),
        Animal.monkey => _t('Macaco', 'Monkey'),
        Animal.koi => _t('Carpa', 'Koi'),
      };

  static String monthName(int month) => (lang == AppLanguage.pt
      ? const [
          'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
          'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
        ]
      : const [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ])[month - 1];

  static String monthShort(int month) =>
      monthName(month).substring(0, 3).toLowerCase();

  // Ajuda
  static String get secHelp => _t('Ajuda', 'Help');
  static String get strategies => _t('Estratégias', 'Strategies');
  static String get learn => _t('Aprender', 'Learn');
  static String get learnMore => _t('Aprender mais', 'Learn more');
  static String get example => _t('Exemplo', 'Example');
  static String get howToFind => _t('Como aplicar', 'How to apply');
  static String get levelBasic => _t('Básica', 'Basic');
  static String get levelIntermediate => _t('Intermediária', 'Intermediate');
  static String get levelAdvanced => _t('Avançada', 'Advanced');
  static String get howToPlay => _t('Como jogar', 'How to play');
  static String get backup => _t('Backup', 'Backup');
  static String get backupExport => _t('Exportar', 'Export');
  static String get backupExportBody => _t(
      'Copie o texto abaixo e guarde em um lugar seguro. Ele contém suas '
          'configurações, histórico e jogos em andamento.',
      'Copy the text below and keep it somewhere safe. It holds your '
          'settings, history and games in progress.');
  static String get copy => _t('Copiar', 'Copy');
  static String get copied => _t('Copiado.', 'Copied.');
  static String get backupImport => _t('Restaurar', 'Restore');
  static String get backupImportBody => _t(
      'Cole aqui um backup exportado antes. Os dados atuais serão substituídos.',
      'Paste a backup exported earlier. Current data will be replaced.');
  static String get backupOk => _t('Backup restaurado.', 'Backup restored.');
  static String get backupBad =>
      _t('Este texto não é um backup válido.', 'This text is not a valid backup.');
  static String get setSound => _t('Efeitos sonoros', 'Sound effects');
  static String get setCompletion =>
      _t('Animação ao concluir um número', 'Animation when a number is done');
  static String get setCompletionSub => _t(
      'Os quadrados piscam quando as nove cópias de um número são colocadas.',
      'Cells flash when all nine copies of a number are placed.');

  /// Seções da tela "Como jogar": (título, texto).
  static List<(String, String)> get howToPlaySections => [
        (
          _t('Objetivo', 'Goal'),
          _t(
              'Preencha o tabuleiro de modo que cada linha, cada coluna e cada bloco 3x3 tenha os números de 1 a 9, sem repetir.',
              'Fill the board so that every row, every column and every 3x3 block has the numbers 1 to 9, with no repeats.')
        ),
        (
          _t('Colocar números', 'Placing numbers'),
          _t(
              'Toque em um quadrado vazio e depois em um número. Um número errado fica em vermelho e conta um erro; toque em Apagar ou coloque outro número para corrigir.',
              'Tap an empty cell and then a number. A wrong number turns red and counts as a mistake; tap Erase or place another number to fix it.')
        ),
        (
          _t('Destacar números', 'Highlighting numbers'),
          _t(
              'Sem nenhum quadrado selecionado, tocar em um número do teclado destaca todos os iguais no tabuleiro. Toque de novo no quadrado selecionado para tirar a seleção.',
              'With no cell selected, tapping a number on the keypad highlights all equal ones on the board. Tap the selected cell again to deselect it.')
        ),
        (
          _t('Notas', 'Notes'),
          _t(
              'Ative Notas para anotar candidatos em um quadrado. Notas avançadas preenche todas as possibilidades de uma vez.',
              'Turn on Notes to pencil candidates into a cell. Auto notes fills in every possibility at once.')
        ),
        (
          _t('Número primeiro', 'Number first'),
          _t(
              'Toque e segure um número para travá-lo. Depois, cada quadrado tocado recebe esse número. Toque e segure de novo para destravar.',
              'Touch and hold a number to lock it. Then every cell you tap gets that number. Touch and hold again to unlock.')
        ),
        (
          _t('Dicas', 'Hints'),
          _t(
              'A dica mostra a estratégia que resolve o próximo passo, destaca os quadrados envolvidos e preenche um único quadrado. Toque em Aprender mais para estudar a estratégia.',
              'A hint shows the strategy that solves the next step, highlights the cells involved and fills a single cell. Tap Learn more to study the strategy.')
        ),
        (
          _t('Desafio diário', 'Daily challenge'),
          _t(
              'Todo dia há um tabuleiro novo, igual para todos os jogadores. Conclua todos os dias de um mês para ganhar o troféu do mês.',
              'Every day there is a new board, the same for all players. Complete every day of a month to earn the monthly trophy.')
        ),
      ];

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
        final el = cells(s.eliminations.map((e) => e.cell).toSet().toList());
        final first = cell(s.patternCells.first);
        return switch (s.variant) {
          1 => _t(
              'Os quadrados $pc formam um ciclo do $ds em que dois elos '
                  'fortes se encontram em $first. Por isso $first é $ds.',
              'Cells $pc form a loop for $ds where two strong links meet at '
                  '$first. So $first is $ds.'),
          2 => _t(
              'Os quadrados $pc formam um ciclo do $ds em que dois elos '
                  'fracos se encontram em $first. Por isso $first perde o $ds.',
              'Cells $pc form a loop for $ds where two weak links meet at '
                  '$first. So $first loses $ds.'),
          _ => _t(
              'Os quadrados $pc formam um ciclo do $ds que alterna elos '
                  'fortes e fracos. Quem vê as duas pontas de um elo fraco '
                  'perde o $ds: $el.',
              'Cells $pc form a loop for $ds alternating strong and weak '
                  'links. Cells seeing both ends of a weak link lose $ds: '
                  '$el.'),
        };
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
