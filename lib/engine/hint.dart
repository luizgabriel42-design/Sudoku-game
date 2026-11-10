/// Dicas: sempre UMA jogada, que preenche UM quadrado novo.
library;

import 'grid.dart';
import 'logical_solver.dart';
import 'techniques.dart';

class Hint {
  /// Cadeia lógica até o preenchimento. O último passo é sempre o
  /// preenchimento; os anteriores (se houver) são eliminações de candidatos
  /// necessárias para chegar nele. Vazia quando [direct] é verdadeiro.
  final List<SolveStep> steps;

  final int cell;
  final int digit;

  /// "Solução direta": nenhuma técnica implementada se aplica, então a dica
  /// apenas revela o valor correto do quadrado.
  final bool direct;

  const Hint({
    required this.steps,
    required this.cell,
    required this.digit,
    this.direct = false,
  });

  /// Técnica mais avançada da cadeia: é a que a dica ensina.
  Technique? get technique {
    Technique? t;
    for (final s in steps) {
      if (t == null || s.technique.index > t.index) t = s.technique;
    }
    return t;
  }
}

/// Calcula a dica para o estado atual.
///
/// Usa os candidatos reais do tabuleiro (não as anotações do jogador) e
/// ignora valores errados. Prefere a técnica mais simples que leve a um
/// preenchimento; se for preciso eliminar candidatos antes, a cadeia inclui
/// só as eliminações de que o preenchimento depende.
///
/// Retorna `null` se o tabuleiro já está completo.
Hint? computeHint(List<int> values, List<int> solution) {
  final clean = List<int>.generate(
      kCells, (i) => values[i] == solution[i] ? values[i] : 0);
  if (!clean.contains(0)) return null;

  final start = CandidateGrid.fromValues(clean);
  final g = start.copy();
  final chain = <SolveStep>[];

  for (var iter = 0; iter < 60; iter++) {
    final p = _firstPlacement(g);
    if (p != null) return _build(start, [...chain, p]);

    final elims = _allEliminations(g);
    if (elims.isEmpty) break;

    // Uma única eliminação já libera um preenchimento?
    for (final e in elims) {
      final g2 = g.copy();
      applyStep(g2, e);
      final p2 = _firstPlacement(g2);
      if (p2 != null) return _build(start, [...chain, e, p2]);
    }

    applyStep(g, elims.first);
    chain.add(elims.first);
  }

  // Solução direta: revela a célula com menos candidatos.
  var best = -1;
  var bestN = 10;
  for (var c = 0; c < kCells; c++) {
    if (clean[c] != 0) continue;
    final n = popCount(start.cands[c]);
    if (n < bestN) {
      bestN = n;
      best = c;
    }
  }
  return Hint(
      steps: const [], cell: best, digit: solution[best], direct: true);
}

SolveStep? _firstPlacement(CandidateGrid g) {
  for (final t in Technique.values) {
    if (!t.isPlacement) continue;
    final r = findSteps(g, t, firstOnly: true);
    if (r.isNotEmpty) return r.first;
  }
  return null;
}

List<SolveStep> _allEliminations(CandidateGrid g) {
  final out = <SolveStep>[];
  for (final t in Technique.values) {
    if (t.isPlacement || !t.implemented) continue;
    out.addAll(findSteps(g, t));
  }
  return out;
}

Hint _build(CandidateGrid start, List<SolveStep> steps) {
  var cur = steps;
  // Remove eliminações de que o preenchimento final não depende.
  for (var i = cur.length - 2; i >= 0; i--) {
    final trial = List<SolveStep>.of(cur)..removeAt(i);
    final replayed = _replay(start, trial);
    if (replayed != null) cur = replayed;
  }
  final last = cur.last;
  return Hint(steps: cur, cell: last.cell!, digit: last.digit!);
}

/// Reaplica a cadeia a partir de [start], conferindo que cada passo ainda é
/// encontrado pela sua técnica. Retorna os passos reencontrados, ou `null`
/// se algum deixou de valer.
List<SolveStep>? _replay(CandidateGrid start, List<SolveStep> steps) {
  final g = start.copy();
  final out = <SolveStep>[];
  for (final s in steps) {
    SolveStep? found;
    for (final cand in findSteps(g, s.technique)) {
      if (cand.key == s.key) {
        found = cand;
        break;
      }
    }
    if (found == null) return null;
    applyStep(g, found);
    out.add(found);
  }
  return out;
}
