/// Técnicas lógicas e o formato de um passo de solução.
library;

import 'grid.dart';

/// As 18 técnicas do menu de estratégias, da mais simples à mais avançada.
/// A ordem do enum é a ordem em que o solucionador as tenta.
///
/// `tier` agrupa as técnicas para classificar a dificuldade do puzzle.
enum Technique {
  lastBlankCell(1),
  lastRemainingCell(1),
  singleCandidate(2),
  hiddenSingle(2),
  nakedPair(3),
  intersectionRemoval(3),
  hiddenPair(3),
  nakedTriplet(4),
  hiddenTriplet(4),
  nakedQuad(4),
  hiddenQuad(4),
  xWing(4),
  xyWing(4),
  xyzWing(5),
  swordfish(5),
  jellyfish(5),
  simpleColoring(5),
  xCycle(5);

  const Technique(this.tier);

  final int tier;

  /// Todas as técnicas do menu são aplicadas pelo solucionador.
  bool get implemented => true;

  /// Técnicas que preenchem uma célula diretamente.
  bool get isPlacement => tier <= 2;
}

class Elimination {
  final int cell;
  final int digit;

  const Elimination(this.cell, this.digit);

  @override
  String toString() => 'r${rowOf(cell) + 1}c${colOf(cell) + 1}<>$digit';
}

/// Um passo lógico: ou preenche uma célula ([cell]/[digit]) ou elimina
/// candidatos ([eliminations]).
class SolveStep {
  final Technique technique;
  final int? cell;
  final int? digit;
  final List<Elimination> eliminations;

  /// Células que formam o padrão (para destacar no tabuleiro).
  final List<int> patternCells;

  /// Dígitos envolvidos no padrão.
  final List<int> patternDigits;

  /// Unidades envolvidas (índices de [Units.all]).
  final List<int> units;

  /// Variante da técnica. No XCycle: 0 = ciclo contínuo, 1 = dois elos
  /// fortes no mesmo quadrado (ele recebe o dígito), 2 = dois elos fracos
  /// no mesmo quadrado (ele perde o dígito).
  final int variant;

  const SolveStep({
    required this.technique,
    this.cell,
    this.digit,
    this.eliminations = const [],
    this.patternCells = const [],
    this.patternDigits = const [],
    this.units = const [],
    this.variant = 0,
  });

  bool get isPlacement => cell != null;

  /// Identifica o padrão, independentemente de quais candidatos ele elimina.
  String get key => '${technique.name}|${patternCells.join(',')}|'
      '${patternDigits.join(',')}|${cell ?? ''}|${digit ?? ''}|$variant';

  @override
  String toString() => isPlacement
      ? '${technique.name}: r${rowOf(cell!) + 1}c${colOf(cell!) + 1}=$digit'
      : '${technique.name}: ${eliminations.join(' ')}';
}

void applyStep(CandidateGrid g, SolveStep s) {
  if (s.isPlacement) {
    g.place(s.cell!, s.digit!);
  } else {
    for (final e in s.eliminations) {
      g.eliminate(e.cell, e.digit);
    }
  }
}
