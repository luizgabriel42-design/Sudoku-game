/// Textos originais do menu de estratégias, em português e inglês.
library;

import '../engine/techniques.dart';
import 'strings.dart';

class StrategyText {
  final String _sumPt, _sumEn;
  final List<String> _stepsPt, _stepsEn;

  const StrategyText(this._sumPt, this._sumEn, this._stepsPt, this._stepsEn);

  /// O que a técnica é, em uma ou duas frases.
  String get summary => S.lang == AppLanguage.pt ? _sumPt : _sumEn;

  /// Como procurar e aplicar, passo a passo.
  List<String> get steps => S.lang == AppLanguage.pt ? _stepsPt : _stepsEn;
}

const Map<Technique, StrategyText> strategyTexts = {
  Technique.lastBlankCell: StrategyText(
    'Quando uma linha, coluna ou bloco tem só um quadrado vazio, ele recebe o único número que ainda falta ali.',
    'When a row, column or block has only one empty cell, it takes the only number still missing there.',
    [
      'Procure uma linha, coluna ou bloco com oito números preenchidos.',
      'Veja qual número de 1 a 9 ainda não aparece.',
      'Coloque esse número no quadrado vazio.',
    ],
    [
      'Look for a row, column or block with eight numbers filled in.',
      'Find which number from 1 to 9 is not there yet.',
      'Place that number in the empty cell.',
    ],
  ),
  Technique.lastRemainingCell: StrategyText(
    'Dentro de um bloco, um número às vezes só tem um lugar possível, porque as linhas e colunas vizinhas já bloqueiam os outros quadrados.',
    'Inside a block, a number sometimes has only one possible spot, because nearby rows and columns already block the other cells.',
    [
      'Escolha um número e um bloco onde ele ainda não aparece.',
      'Elimine os quadrados do bloco cuja linha ou coluna já tem esse número.',
      'Se sobrar um único quadrado, o número vai nele.',
    ],
    [
      'Pick a number and a block where it does not appear yet.',
      'Rule out the cells of the block whose row or column already has that number.',
      'If a single cell is left, the number goes there.',
    ],
  ),
  Technique.singleCandidate: StrategyText(
    'Um quadrado em que só um número é possível, porque todos os outros já aparecem na sua linha, coluna ou bloco.',
    'A cell where only one number is possible, because all the others already appear in its row, column or block.',
    [
      'Escolha um quadrado vazio.',
      'Risque todos os números que já estão na linha, na coluna e no bloco dele.',
      'Se restar apenas um, é a resposta.',
    ],
    [
      'Pick an empty cell.',
      'Cross out every number already in its row, column and block.',
      'If only one is left, that is the answer.',
    ],
  ),
  Technique.hiddenSingle: StrategyText(
    'Em uma linha ou coluna, um número só cabe em um dos quadrados vazios, mesmo que esse quadrado ainda tenha outros candidatos.',
    'In a row or column, a number fits in only one of the empty cells, even if that cell still has other candidates.',
    [
      'Escolha uma linha ou coluna e um número que falta nela.',
      'Veja em quais quadrados vazios esse número ainda é possível.',
      'Se for em apenas um, coloque o número ali.',
    ],
    [
      'Pick a row or column and a number missing from it.',
      'Check in which empty cells that number is still possible.',
      'If there is only one, place the number there.',
    ],
  ),
  Technique.nakedPair: StrategyText(
    'Dois quadrados da mesma linha, coluna ou bloco que só aceitam os mesmos dois números. Esses dois números ficam reservados para eles.',
    'Two cells in the same row, column or block that accept only the same two numbers. Those two numbers are reserved for them.',
    [
      'Use as notas para achar dois quadrados com exatamente os mesmos dois candidatos.',
      'Confirme que eles estão na mesma linha, coluna ou bloco.',
      'Apague esses dois números das notas dos outros quadrados dessa unidade.',
    ],
    [
      'Use notes to find two cells with exactly the same two candidates.',
      'Make sure they share a row, column or block.',
      'Remove those two numbers from the notes of the other cells in that unit.',
    ],
  ),
  Technique.intersectionRemoval: StrategyText(
    'Quando, em um bloco, um número só cabe em quadrados de uma mesma linha ou coluna, ele não pode aparecer no resto dessa linha ou coluna. O mesmo vale no sentido inverso.',
    'When, inside a block, a number only fits in cells of the same row or column, it cannot appear in the rest of that row or column. The reverse also holds.',
    [
      'Em um bloco, veja onde um número ainda é possível.',
      'Se todos os lugares ficam na mesma linha ou coluna, o número estará nesse trecho.',
      'Apague o número das notas do restante dessa linha ou coluna, fora do bloco.',
    ],
    [
      'In a block, see where a number is still possible.',
      'If all spots lie in the same row or column, the number will be in that segment.',
      'Remove the number from the notes in the rest of that row or column, outside the block.',
    ],
  ),
  Technique.hiddenPair: StrategyText(
    'Dois números que, em uma linha, coluna ou bloco, só cabem nos mesmos dois quadrados. Esses quadrados não podem ter mais nada.',
    'Two numbers that, in a row, column or block, fit only in the same two cells. Those cells cannot hold anything else.',
    [
      'Em uma unidade, procure dois números que aparecem nas notas de apenas dois quadrados, os mesmos para ambos.',
      'Esses dois quadrados serão ocupados por esses dois números.',
      'Apague os outros candidatos desses dois quadrados.',
    ],
    [
      'In a unit, look for two numbers that appear in the notes of only two cells, the same two for both.',
      'Those two cells will be taken by those two numbers.',
      'Remove the other candidates from those two cells.',
    ],
  ),
  Technique.nakedTriplet: StrategyText(
    'Três quadrados de uma unidade cujos candidatos, somados, são apenas três números. Nem todos precisam ter os três.',
    'Three cells in a unit whose candidates, combined, are only three numbers. Not every cell needs all three.',
    [
      'Procure três quadrados na mesma unidade com dois ou três candidatos cada.',
      'Confirme que, juntos, eles usam só três números.',
      'Apague esses três números dos outros quadrados da unidade.',
    ],
    [
      'Look for three cells in the same unit with two or three candidates each.',
      'Make sure that together they use only three numbers.',
      'Remove those three numbers from the other cells of the unit.',
    ],
  ),
  Technique.hiddenTriplet: StrategyText(
    'Três números que, em uma unidade, só cabem nos mesmos três quadrados. Os outros candidatos desses quadrados podem sair.',
    'Three numbers that, in a unit, only fit in the same three cells. The other candidates of those cells can go.',
    [
      'Em uma unidade, procure três números restritos aos mesmos três quadrados.',
      'Esses quadrados ficam reservados para esses números.',
      'Apague deles qualquer outro candidato.',
    ],
    [
      'In a unit, look for three numbers confined to the same three cells.',
      'Those cells are reserved for those numbers.',
      'Remove any other candidate from them.',
    ],
  ),
  Technique.nakedQuad: StrategyText(
    'A mesma ideia do par e da trinca, com quatro quadrados que, juntos, só aceitam quatro números.',
    'The same idea as the pair and the triplet, with four cells that together accept only four numbers.',
    [
      'Procure quatro quadrados da mesma unidade que usem, no total, quatro números.',
      'Esses números ficam reservados para os quatro quadrados.',
      'Apague-os dos demais quadrados da unidade.',
    ],
    [
      'Look for four cells in the same unit that use four numbers in total.',
      'Those numbers are reserved for the four cells.',
      'Remove them from the remaining cells of the unit.',
    ],
  ),
  Technique.hiddenQuad: StrategyText(
    'Quatro números que, em uma unidade, só cabem nos mesmos quatro quadrados. É raro e difícil de ver.',
    'Four numbers that, in a unit, only fit in the same four cells. It is rare and hard to spot.',
    [
      'Em uma unidade, procure quatro números restritos aos mesmos quatro quadrados.',
      'Esses quadrados ficam reservados para eles.',
      'Apague os outros candidatos desses quatro quadrados.',
    ],
    [
      'In a unit, look for four numbers confined to the same four cells.',
      'Those cells are reserved for them.',
      'Remove the other candidates from those four cells.',
    ],
  ),
  Technique.xWing: StrategyText(
    'Um número que, em duas linhas, só cabe nas mesmas duas colunas forma um retângulo. Ele ocupará dois cantos opostos, então sai do resto dessas colunas. Vale também trocando linhas por colunas.',
    'A number that, in two rows, only fits in the same two columns forms a rectangle. It will take two opposite corners, so it leaves the rest of those columns. It also works swapping rows and columns.',
    [
      'Escolha um número e procure duas linhas em que ele só tenha dois lugares.',
      'Confira se os lugares caem nas mesmas duas colunas.',
      'Apague o número dos outros quadrados dessas duas colunas.',
    ],
    [
      'Pick a number and look for two rows where it has only two spots.',
      'Check that the spots fall in the same two columns.',
      'Remove the number from the other cells of those two columns.',
    ],
  ),
  Technique.xyWing: StrategyText(
    'Um quadrado pivô com dois candidatos (X e Y) vê duas asas: uma com X e Z, outra com Y e Z. Qualquer que seja o pivô, uma das asas será Z.',
    'A pivot cell with two candidates (X and Y) sees two wings: one with X and Z, the other with Y and Z. Whatever the pivot is, one wing will be Z.',
    [
      'Ache um quadrado com dois candidatos: o pivô.',
      'Procure duas asas que ele vê, cada uma com um dos números do pivô e um terceiro número em comum (Z).',
      'Apague Z de todo quadrado que vê as duas asas.',
    ],
    [
      'Find a cell with two candidates: the pivot.',
      'Look for two wings it sees, each with one of the pivot numbers plus a shared third number (Z).',
      'Remove Z from every cell that sees both wings.',
    ],
  ),
  Technique.xyzWing: StrategyText(
    'Parecida com o XY-Wing, mas o pivô tem três candidatos (X, Y e Z). Um dos três quadrados será Z.',
    'Similar to the XY-Wing, but the pivot has three candidates (X, Y and Z). One of the three cells will be Z.',
    [
      'Ache um pivô com três candidatos.',
      'Procure duas asas que ele vê: uma com X e Z, outra com Y e Z.',
      'Apague Z dos quadrados que veem o pivô e as duas asas ao mesmo tempo.',
    ],
    [
      'Find a pivot with three candidates.',
      'Look for two wings it sees: one with X and Z, the other with Y and Z.',
      'Remove Z from the cells that see the pivot and both wings at once.',
    ],
  ),
  Technique.swordfish: StrategyText(
    'Um X-Wing ampliado: em três linhas, um número só cabe nas mesmas três colunas. Ele sai do resto dessas colunas.',
    'A bigger X-Wing: in three rows, a number only fits in the same three columns. It leaves the rest of those columns.',
    [
      'Escolha um número e procure três linhas em que ele tenha dois ou três lugares.',
      'Confira se todos os lugares cabem em apenas três colunas.',
      'Apague o número dos outros quadrados dessas colunas.',
    ],
    [
      'Pick a number and look for three rows where it has two or three spots.',
      'Check that all spots fit in only three columns.',
      'Remove the number from the other cells of those columns.',
    ],
  ),
  Technique.jellyfish: StrategyText(
    'A versão com quatro linhas e quatro colunas do X-Wing e do Swordfish. É bastante rara.',
    'The four-row, four-column version of the X-Wing and the Swordfish. It is quite rare.',
    [
      'Escolha um número e procure quatro linhas em que ele tenha de dois a quatro lugares.',
      'Confira se todos os lugares cabem em apenas quatro colunas.',
      'Apague o número dos outros quadrados dessas colunas.',
    ],
    [
      'Pick a number and look for four rows where it has two to four spots.',
      'Check that all spots fit in only four columns.',
      'Remove the number from the other cells of those columns.',
    ],
  ),
  Technique.simpleColoring: StrategyText(
    'Quando um número só tem dois lugares em uma unidade, um deles é o certo. Encadeando esses pares e pintando em duas cores alternadas, uma cor inteira é verdadeira e a outra é falsa.',
    'When a number has only two spots in a unit, one of them is right. Chaining these pairs and painting them in two alternating colors, one whole color is true and the other is false.',
    [
      'Escolha um número e ligue os quadrados que formam pares (únicos dois lugares em uma unidade).',
      'Pinte a cadeia alternando duas cores.',
      'Se dois quadrados da mesma cor se veem, essa cor é falsa. Se um quadrado de fora vê as duas cores, ele perde o número.',
    ],
    [
      'Pick a number and link the cells that form pairs (the only two spots in a unit).',
      'Paint the chain alternating two colors.',
      'If two cells of the same color see each other, that color is false. If an outside cell sees both colors, it loses the number.',
    ],
  ),
  Technique.xCycle: StrategyText(
    'Um ciclo fechado de um mesmo número que alterna elos fortes (únicos dois lugares em uma unidade) e elos fracos (quadrados que se veem).',
    'A closed loop for a single number that alternates strong links (the only two spots in a unit) and weak links (cells that see each other).',
    [
      'Escolha um número e monte um ciclo alternando elos fortes e fracos.',
      'Se o ciclo alterna perfeitamente, quem vê as duas pontas de um elo fraco perde o número.',
      'Se dois elos fortes se encontram em um quadrado, ele é o número. Se dois elos fracos se encontram, ele perde o número.',
    ],
    [
      'Pick a number and build a loop alternating strong and weak links.',
      'If the loop alternates perfectly, any cell seeing both ends of a weak link loses the number.',
      'If two strong links meet at a cell, it is the number. If two weak links meet, it loses the number.',
    ],
  ),
};
