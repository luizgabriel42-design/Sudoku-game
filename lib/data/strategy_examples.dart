/// Exemplos de tabuleiro para o menu de estratégias.
///
/// Gerados automaticamente: cada um é um estado real de jogo em que a
/// técnica se aplica, conferido contra a solução. Não editar à mão.
library;

import '../engine/techniques.dart';

class StrategyExample {
  /// Valores das 81 células (0 = vazia).
  final String values;

  /// Candidatos de cada célula, como máscara de bits.
  final List<int> cands;
  final SolveStep step;

  const StrategyExample(this.values, this.cands, this.step);
}

const Map<Technique, StrategyExample> strategyExamples = {
  Technique.lastBlankCell: StrategyExample(
    '501000932263009180900123645327091056600235791159760320030012079090300210412987563',
    [0, 72, 0, 160, 72, 160, 0, 0, 0, 0, 0, 0, 16, 88, 0, 0, 0, 64, 0, 192, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 136, 0, 0, 128, 0, 0, 0, 136, 136, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 136, 128, 0, 48, 48, 0, 0, 136, 0, 0, 192, 0, 48, 0, 16, 40, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    SolveStep(technique: Technique.lastBlankCell, cell: 17, digit: 7, patternCells: [17], patternDigits: [7], units: [20]),
  ),
  Technique.lastRemainingCell: StrategyExample(
    '501000932263009180900123645327091056600235791159760320030012079090300210412987563',
    [0, 72, 0, 160, 72, 160, 0, 0, 0, 0, 0, 0, 16, 88, 0, 0, 0, 64, 0, 192, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 136, 0, 0, 128, 0, 0, 0, 136, 136, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 136, 128, 0, 48, 48, 0, 0, 136, 0, 0, 192, 0, 48, 0, 16, 40, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    SolveStep(technique: Technique.lastRemainingCell, cell: 1, digit: 4, patternCells: [1], patternDigits: [4], units: [18]),
  ),
  Technique.singleCandidate: StrategyExample(
    '501000932263009180900123645327091056600235791159760320030012079090300210412987563',
    [0, 72, 0, 160, 72, 160, 0, 0, 0, 0, 0, 0, 16, 88, 0, 0, 0, 64, 0, 192, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 136, 0, 0, 128, 0, 0, 0, 136, 136, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 136, 128, 0, 48, 48, 0, 0, 136, 0, 0, 192, 0, 48, 0, 16, 40, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    SolveStep(technique: Technique.singleCandidate, cell: 12, digit: 5, patternCells: [12], patternDigits: [5]),
  ),
  Technique.hiddenSingle: StrategyExample(
    '501000932263009180900123645327091056600235791159760320030012079090300210412987563',
    [0, 72, 0, 160, 72, 160, 0, 0, 0, 0, 0, 0, 16, 88, 0, 0, 0, 64, 0, 192, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 136, 0, 0, 128, 0, 0, 0, 136, 136, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 136, 128, 0, 48, 48, 0, 0, 136, 0, 0, 192, 0, 48, 0, 16, 40, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    SolveStep(technique: Technique.hiddenSingle, cell: 13, digit: 4, patternCells: [13], patternDigits: [4], units: [1]),
  ),
  Technique.nakedPair: StrategyExample(
    '970051204284739051150248000502097148491805000708410592619584327340100860820060410',
    [0, 0, 36, 32, 0, 0, 0, 132, 0, 0, 0, 0, 0, 0, 0, 32, 0, 0, 0, 0, 36, 0, 0, 0, 352, 68, 36, 0, 36, 0, 36, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 96, 68, 36, 0, 36, 0, 0, 0, 36, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 80, 0, 66, 2, 0, 0, 272, 0, 0, 80, 260, 0, 4, 0, 0, 272],
    SolveStep(technique: Technique.nakedPair, eliminations: [Elimination(7, 3)], patternCells: [25, 43], patternDigits: [3, 7], units: [16]),
  ),
  Technique.intersectionRemoval: StrategyExample(
    '467835219193742506582961030700026043635004072924370601306207090200000367879603020',
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 72, 0, 8, 0, 1, 129, 16, 0, 0, 256, 0, 0, 0, 0, 0, 1, 257, 0, 384, 0, 0, 0, 0, 0, 0, 0, 128, 0, 16, 0, 0, 24, 0, 0, 145, 0, 137, 0, 152, 0, 24, 1, 25, 401, 256, 0, 0, 0, 0, 0, 0, 0, 17, 0, 9, 0, 24],
    SolveStep(technique: Technique.intersectionRemoval, eliminations: [Elimination(66, 5)], patternCells: [58, 67, 76], patternDigits: [5], units: [13, 25]),
  ),
  Technique.hiddenPair: StrategyExample(
    '501000932263009180900123645327091056600235791159760320030012079090300210412987563',
    [0, 72, 0, 160, 72, 160, 0, 0, 0, 0, 0, 0, 16, 88, 0, 0, 0, 64, 0, 192, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 136, 0, 0, 128, 0, 0, 0, 136, 136, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 136, 128, 0, 48, 48, 0, 0, 136, 0, 0, 192, 0, 48, 0, 16, 40, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    SolveStep(technique: Technique.hiddenPair, eliminations: [Elimination(13, 7)], patternCells: [12, 13], patternDigits: [4, 5], units: [1]),
  ),
  Technique.nakedTriplet: StrategyExample(
    '391672800762085390004913200925006183173528009648391527019207038006830010037160050',
    [0, 0, 0, 0, 0, 0, 0, 8, 24, 0, 0, 0, 8, 0, 0, 0, 0, 9, 144, 144, 0, 0, 0, 0, 0, 96, 48, 0, 0, 0, 72, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 40, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 0, 0, 0, 24, 0, 40, 0, 0, 26, 16, 0, 0, 0, 264, 320, 0, 10, 138, 0, 0, 0, 0, 264, 256, 0, 10],
    SolveStep(technique: Technique.nakedTriplet, eliminations: [Elimination(25, 6)], patternCells: [18, 19, 26], patternDigits: [5, 6, 8], units: [2]),
  ),
  Technique.hiddenTriplet: StrategyExample(
    '501000932263009180900123645327091056600235791159760320030012079090300210412987563',
    [0, 72, 0, 160, 72, 160, 0, 0, 0, 0, 0, 0, 16, 88, 0, 0, 0, 64, 0, 192, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 136, 0, 0, 128, 0, 0, 0, 136, 136, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 136, 128, 0, 48, 48, 0, 0, 136, 0, 0, 192, 0, 48, 0, 16, 40, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    SolveStep(technique: Technique.hiddenTriplet, eliminations: [Elimination(60, 8)], patternCells: [56, 57, 60], patternDigits: [4, 5, 6], units: [6]),
  ),
  Technique.nakedQuad: StrategyExample(
    '030015200850030100021860500302176405519248736407593012073421050148659327095380041',
    [320, 0, 40, 320, 0, 0, 0, 160, 136, 0, 0, 40, 320, 0, 10, 0, 352, 264, 320, 0, 0, 0, 0, 8, 0, 320, 12, 0, 128, 0, 0, 0, 0, 0, 384, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 160, 0, 0, 0, 0, 128, 0, 0, 32, 0, 0, 0, 0, 0, 416, 0, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 34, 0, 0, 0, 0, 64, 32, 0, 0],
    SolveStep(technique: Technique.nakedQuad, eliminations: [Elimination(14, 4)], patternCells: [11, 12, 16, 17], patternDigits: [4, 6, 7, 9], units: [1]),
  ),
  Technique.hiddenQuad: StrategyExample(
    '501000932263009180900123645327091056600235791159760320030012079090300210412987563',
    [0, 72, 0, 160, 72, 160, 0, 0, 0, 0, 0, 0, 16, 88, 0, 0, 0, 64, 0, 192, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0, 136, 0, 0, 128, 0, 0, 0, 136, 136, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 136, 128, 0, 48, 48, 0, 0, 136, 0, 0, 192, 0, 48, 0, 16, 40, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    SolveStep(technique: Technique.hiddenQuad, eliminations: [Elimination(63, 8)], patternCells: [63, 65, 67, 68], patternDigits: [4, 5, 6, 7], units: [7]),
  ),
  Technique.xWing: StrategyExample(
    '700609418840705296600408730137006004060354187458071003080597361316842009070163842',
    [0, 2, 22, 0, 6, 0, 0, 0, 0, 0, 0, 5, 0, 5, 0, 0, 0, 0, 0, 258, 275, 0, 3, 0, 0, 0, 16, 0, 0, 0, 258, 128, 0, 256, 18, 0, 258, 0, 258, 0, 0, 0, 0, 0, 0, 0, 0, 0, 258, 0, 0, 288, 2, 0, 2, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 80, 0, 272, 0, 272, 0, 0, 0, 0, 0, 0],
    SolveStep(technique: Technique.xWing, eliminations: [Elimination(20, 9)], patternCells: [36, 38, 72, 74], patternDigits: [9]),
  ),
  Technique.xyWing: StrategyExample(
    '743862591250309087890507300169785230387904105425601809010403000000106050674258913',
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 33, 0, 9, 0, 40, 0, 0, 0, 0, 33, 0, 9, 0, 0, 42, 42, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 2, 0, 0, 32, 0, 0, 0, 0, 0, 4, 0, 0, 64, 0, 272, 0, 130, 0, 320, 0, 96, 98, 162, 256, 4, 130, 0, 320, 0, 72, 0, 138, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    SolveStep(technique: Technique.xyWing, eliminations: [Elimination(61, 7)], patternCells: [15, 60, 69], patternDigits: [4, 6, 7]),
  ),
  Technique.xyzWing: StrategyExample(
    '467835219193742506582961030700026043635004072924370601306207090200000367879603020',
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 72, 0, 8, 0, 1, 129, 16, 0, 0, 256, 0, 0, 0, 0, 0, 1, 257, 0, 384, 0, 0, 0, 0, 0, 0, 0, 128, 0, 16, 0, 0, 24, 0, 0, 145, 0, 137, 0, 152, 0, 24, 1, 25, 401, 256, 0, 0, 0, 0, 0, 0, 0, 17, 0, 9, 0, 24],
    SolveStep(technique: Technique.xyzWing, eliminations: [Elimination(67, 5)], patternCells: [66, 64, 76], patternDigits: [1, 4, 5]),
  ),
  Technique.swordfish: StrategyExample(
    '467835219193742506582961030700026043635004072924370601306207090200000367879603020',
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 72, 0, 8, 0, 1, 129, 16, 0, 0, 256, 0, 0, 0, 0, 0, 1, 257, 0, 384, 0, 0, 0, 0, 0, 0, 0, 128, 0, 16, 0, 0, 24, 0, 0, 145, 0, 137, 0, 152, 0, 24, 1, 25, 401, 256, 0, 0, 0, 0, 0, 0, 0, 17, 0, 9, 0, 24],
    SolveStep(technique: Technique.swordfish, eliminations: [Elimination(64, 4)], patternCells: [24, 26, 55, 60, 62, 78, 80], patternDigits: [4]),
  ),
  Technique.jellyfish: StrategyExample(
    '467835219193742506582961030700026043635004072924370601306207090200000367879603020',
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 72, 0, 8, 0, 1, 129, 16, 0, 0, 256, 0, 0, 0, 0, 0, 1, 257, 0, 384, 0, 0, 0, 0, 0, 0, 0, 128, 0, 16, 0, 0, 24, 0, 0, 145, 0, 137, 0, 152, 0, 24, 1, 25, 401, 256, 0, 0, 0, 0, 0, 0, 0, 17, 0, 9, 0, 24],
    SolveStep(technique: Technique.jellyfish, eliminations: [Elimination(29, 1)], patternCells: [39, 40, 58, 60, 65, 66, 67, 76, 78], patternDigits: [1]),
  ),
  Technique.simpleColoring: StrategyExample(
    '467835219193742506582961030700026043635004072924370601306207090200000367879603020',
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 72, 0, 8, 0, 1, 129, 16, 0, 0, 256, 0, 0, 0, 0, 0, 1, 257, 0, 384, 0, 0, 0, 0, 0, 0, 0, 128, 0, 16, 0, 0, 24, 0, 0, 145, 0, 137, 0, 152, 0, 24, 1, 25, 401, 256, 0, 0, 0, 0, 0, 0, 0, 17, 0, 9, 0, 24],
    SolveStep(technique: Technique.simpleColoring, eliminations: [Elimination(58, 8)], patternCells: [42, 60, 62], patternDigits: [8]),
  ),
  Technique.xCycle: StrategyExample(
    '467835219193742506582961030700026043635004072924370601306207090200000367879603020',
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 128, 0, 0, 0, 0, 0, 0, 0, 72, 0, 8, 0, 1, 129, 16, 0, 0, 256, 0, 0, 0, 0, 0, 1, 257, 0, 384, 0, 0, 0, 0, 0, 0, 0, 128, 0, 16, 0, 0, 24, 0, 0, 145, 0, 137, 0, 152, 0, 24, 1, 25, 401, 256, 0, 0, 0, 0, 0, 0, 0, 17, 0, 9, 0, 24],
    SolveStep(technique: Technique.xCycle, eliminations: [Elimination(40, 1)], patternCells: [40, 58, 60, 78, 76], patternDigits: [1], variant: 2),
  ),
};
