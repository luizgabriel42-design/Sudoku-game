/// Solucionador lógico: aplica as técnicas humanas, uma por vez.
///
/// Todas as deduções são sólidas (nunca chutam). Por isso, se o
/// solucionador resolve um puzzle, a solução é única.
library;

import 'grid.dart';
import 'techniques.dart';

/// Procura todos os passos de uma técnica no estado atual.
/// Com [firstOnly], retorna assim que achar o primeiro.
List<SolveStep> findSteps(CandidateGrid g, Technique t,
    {bool firstOnly = false}) {
  switch (t) {
    case Technique.lastBlankCell:
      return _lastBlank(g, firstOnly);
    case Technique.lastRemainingCell:
      return _hiddenSingles(g, 18, 27, t, firstOnly);
    case Technique.singleCandidate:
      return _nakedSingles(g, firstOnly);
    case Technique.hiddenSingle:
      return _hiddenSingles(g, 0, 18, t, firstOnly);
    case Technique.nakedPair:
      return _nakedSubset(g, 2, t, firstOnly);
    case Technique.intersectionRemoval:
      return _intersection(g, firstOnly);
    case Technique.hiddenPair:
      return _hiddenSubset(g, 2, t, firstOnly);
    case Technique.nakedTriplet:
      return _nakedSubset(g, 3, t, firstOnly);
    case Technique.hiddenTriplet:
      return _hiddenSubset(g, 3, t, firstOnly);
    case Technique.nakedQuad:
      return _nakedSubset(g, 4, t, firstOnly);
    case Technique.hiddenQuad:
      return _hiddenSubset(g, 4, t, firstOnly);
    case Technique.xWing:
      return _fish(g, 2, t, firstOnly);
    case Technique.xyWing:
      return _wings(g, false, firstOnly);
    case Technique.xyzWing:
      return _wings(g, true, firstOnly);
    case Technique.swordfish:
      return _fish(g, 3, t, firstOnly);
    case Technique.jellyfish:
      return _fish(g, 4, t, firstOnly);
    case Technique.simpleColoring:
      return _coloring(g, firstOnly);
    case Technique.xCycle:
      return const [];
  }
}

/// Próximo passo pela técnica mais simples disponível, até [maxTier].
SolveStep? nextStep(CandidateGrid g, {int maxTier = 5}) {
  for (final t in Technique.values) {
    if (!t.implemented || t.tier > maxTier) continue;
    final r = findSteps(g, t, firstOnly: true);
    if (r.isNotEmpty) return r.first;
  }
  return null;
}

class LogicalResult {
  final bool solved;
  final List<SolveStep> steps;
  final Technique? hardest;
  final List<int> values;

  const LogicalResult(this.solved, this.steps, this.hardest, this.values);

  int get maxTier => hardest?.tier ?? 0;
}

LogicalResult solveLogically(List<int> givens,
    {int maxTier = 5, bool recordSteps = true}) {
  final g = CandidateGrid.fromValues(givens);
  final steps = <SolveStep>[];
  Technique? hardest;
  while (!g.solved) {
    final s = nextStep(g, maxTier: maxTier);
    if (s == null) break;
    applyStep(g, s);
    if (recordSteps) steps.add(s);
    if (hardest == null || s.technique.index > hardest.index) {
      hardest = s.technique;
    }
  }
  return LogicalResult(g.solved, steps, hardest, g.values);
}

// ---------------------------------------------------------------------------
// Técnicas que preenchem uma célula
// ---------------------------------------------------------------------------

List<SolveStep> _lastBlank(CandidateGrid g, bool first) {
  final out = <SolveStep>[];
  final seen = <int>{};
  for (var u = 0; u < 27; u++) {
    var empty = -1;
    var n = 0;
    for (final c in Units.all[u]) {
      if (g.values[c] == 0) {
        n++;
        empty = c;
      }
    }
    if (n == 1 && popCount(g.cands[empty]) == 1 && seen.add(empty)) {
      final d = digitsOf(g.cands[empty]).first;
      out.add(SolveStep(
        technique: Technique.lastBlankCell,
        cell: empty,
        digit: d,
        patternCells: [empty],
        patternDigits: [d],
        units: [u],
      ));
      if (first) return out;
    }
  }
  return out;
}

List<SolveStep> _hiddenSingles(
    CandidateGrid g, int from, int to, Technique t, bool first) {
  final out = <SolveStep>[];
  final seen = <int>{};
  for (var u = from; u < to; u++) {
    for (var d = 1; d <= 9; d++) {
      final m = bit(d);
      var where = -1;
      var n = 0;
      for (final c in Units.all[u]) {
        if ((g.cands[c] & m) != 0) {
          n++;
          where = c;
        }
      }
      if (n == 1 && seen.add(where * 10 + d)) {
        out.add(SolveStep(
          technique: t,
          cell: where,
          digit: d,
          patternCells: [where],
          patternDigits: [d],
          units: [u],
        ));
        if (first) return out;
      }
    }
  }
  return out;
}

List<SolveStep> _nakedSingles(CandidateGrid g, bool first) {
  final out = <SolveStep>[];
  for (var c = 0; c < kCells; c++) {
    if (g.values[c] == 0 && popCount(g.cands[c]) == 1) {
      final d = digitsOf(g.cands[c]).first;
      out.add(SolveStep(
        technique: Technique.singleCandidate,
        cell: c,
        digit: d,
        patternCells: [c],
        patternDigits: [d],
      ));
      if (first) return out;
    }
  }
  return out;
}

// ---------------------------------------------------------------------------
// Técnicas que eliminam candidatos
// ---------------------------------------------------------------------------

List<SolveStep> _nakedSubset(CandidateGrid g, int n, Technique t, bool first) {
  final out = <SolveStep>[];
  for (var u = 0; u < 27; u++) {
    final unit = Units.all[u];
    final empties = [
      for (final c in unit)
        if (g.values[c] == 0) c,
    ];
    if (empties.length <= n) continue;
    final pool = [
      for (final c in empties)
        if (popCount(g.cands[c]) >= 2 && popCount(g.cands[c]) <= n) c,
    ];
    if (pool.length < n) continue;
    for (final combo in combinations(pool, n)) {
      var union = 0;
      for (final c in combo) {
        union |= g.cands[c];
      }
      if (popCount(union) != n) continue;
      final elims = <Elimination>[];
      for (final c in empties) {
        if (combo.contains(c)) continue;
        for (final d in digitsOf(g.cands[c] & union)) {
          elims.add(Elimination(c, d));
        }
      }
      if (elims.isEmpty) continue;
      out.add(SolveStep(
        technique: t,
        eliminations: elims,
        patternCells: combo,
        patternDigits: digitsOf(union),
        units: [u],
      ));
      if (first) return out;
    }
  }
  return out;
}

List<SolveStep> _hiddenSubset(
    CandidateGrid g, int n, Technique t, bool first) {
  final out = <SolveStep>[];
  for (var u = 0; u < 27; u++) {
    final unit = Units.all[u];
    final digits = <int>[];
    for (var d = 1; d <= 9; d++) {
      var count = 0;
      for (final c in unit) {
        if (g.has(c, d)) count++;
      }
      if (count >= 1 && count <= n) digits.add(d);
    }
    if (digits.length < n) continue;
    for (final combo in combinations(digits, n)) {
      var mask = 0;
      for (final d in combo) {
        mask |= bit(d);
      }
      final cells = [
        for (final c in unit)
          if ((g.cands[c] & mask) != 0) c,
      ];
      if (cells.length != n) continue;
      final elims = <Elimination>[];
      for (final c in cells) {
        for (final d in digitsOf(g.cands[c] & ~mask)) {
          elims.add(Elimination(c, d));
        }
      }
      if (elims.isEmpty) continue;
      out.add(SolveStep(
        technique: t,
        eliminations: elims,
        patternCells: cells,
        patternDigits: combo,
        units: [u],
      ));
      if (first) return out;
    }
  }
  return out;
}

List<SolveStep> _intersection(CandidateGrid g, bool first) {
  final out = <SolveStep>[];

  void tryStep(List<int> cells, int d, int fromUnit, int toUnit) {
    final elims = <Elimination>[];
    for (final c in Units.all[toUnit]) {
      if (!cells.contains(c) && g.has(c, d)) elims.add(Elimination(c, d));
    }
    if (elims.isEmpty) return;
    out.add(SolveStep(
      technique: Technique.intersectionRemoval,
      eliminations: elims,
      patternCells: cells,
      patternDigits: [d],
      units: [fromUnit, toUnit],
    ));
  }

  for (var d = 1; d <= 9; d++) {
    // Pointing: no bloco, o dígito só cabe em uma linha/coluna.
    for (var b = 0; b < 9; b++) {
      final cells = [
        for (final c in Units.boxes[b])
          if (g.has(c, d)) c,
      ];
      if (cells.length < 2) continue;
      final r = rowOf(cells.first);
      final c0 = colOf(cells.first);
      if (cells.every((c) => rowOf(c) == r)) tryStep(cells, d, 18 + b, r);
      if (cells.every((c) => colOf(c) == c0)) tryStep(cells, d, 18 + b, 9 + c0);
      if (first && out.isNotEmpty) return out;
    }
    // Claiming: na linha/coluna, o dígito só cabe em um bloco.
    for (var u = 0; u < 18; u++) {
      final cells = [
        for (final c in Units.all[u])
          if (g.has(c, d)) c,
      ];
      if (cells.length < 2) continue;
      final b = boxOf(cells.first);
      if (cells.every((c) => boxOf(c) == b)) tryStep(cells, d, u, 18 + b);
      if (first && out.isNotEmpty) return out;
    }
  }
  return out;
}

/// Peixes: X-Wing (n=2), Swordfish (n=3) e Jellyfish (n=4).
List<SolveStep> _fish(CandidateGrid g, int n, Technique t, bool first) {
  final out = <SolveStep>[];
  for (var d = 1; d <= 9; d++) {
    for (var orient = 0; orient < 2; orient++) {
      final byRows = orient == 0;
      int cellAt(int line, int pos) => byRows ? line * 9 + pos : pos * 9 + line;

      final masks = List<int>.filled(9, 0);
      final lines = <int>[];
      for (var i = 0; i < 9; i++) {
        var m = 0;
        for (var j = 0; j < 9; j++) {
          if (g.has(cellAt(i, j), d)) m |= 1 << j;
        }
        masks[i] = m;
        final pc = popCount(m);
        if (pc >= 2 && pc <= n) lines.add(i);
      }
      if (lines.length < n) continue;

      for (final combo in combinations(lines, n)) {
        var union = 0;
        for (final i in combo) {
          union |= masks[i];
        }
        if (popCount(union) != n) continue;
        final elims = <Elimination>[];
        for (var k = 0; k < 9; k++) {
          if (combo.contains(k)) continue;
          for (var j = 0; j < 9; j++) {
            if ((union & (1 << j)) != 0 && g.has(cellAt(k, j), d)) {
              elims.add(Elimination(cellAt(k, j), d));
            }
          }
        }
        if (elims.isEmpty) continue;
        final pattern = <int>[];
        final units = <int>[];
        for (final i in combo) {
          units.add(byRows ? i : 9 + i);
          for (var j = 0; j < 9; j++) {
            if ((masks[i] & (1 << j)) != 0) pattern.add(cellAt(i, j));
          }
        }
        for (var j = 0; j < 9; j++) {
          if ((union & (1 << j)) != 0) units.add(byRows ? 9 + j : j);
        }
        pattern.sort();
        out.add(SolveStep(
          technique: t,
          eliminations: elims,
          patternCells: pattern,
          patternDigits: [d],
          units: units,
        ));
        if (first) return out;
      }
    }
  }
  return out;
}

/// XY-Wing (pivô com 2 candidatos) e XYZ-Wing (pivô com 3).
/// Em [SolveStep.patternCells], o pivô vem primeiro.
List<SolveStep> _wings(CandidateGrid g, bool xyz, bool first) {
  final out = <SolveStep>[];
  final t = xyz ? Technique.xyzWing : Technique.xyWing;
  for (var pivot = 0; pivot < kCells; pivot++) {
    final pm = g.cands[pivot];
    if (popCount(pm) != (xyz ? 3 : 2)) continue;
    final biv = [
      for (final p in Units.peers[pivot])
        if (popCount(g.cands[p]) == 2) p,
    ];
    for (var i = 0; i < biv.length; i++) {
      for (var j = i + 1; j < biv.length; j++) {
        final p1 = biv[i];
        final p2 = biv[j];
        final m1 = g.cands[p1];
        final m2 = g.cands[p2];
        if (m1 == m2) continue;
        final common = m1 & m2;
        if (popCount(common) != 1) continue;
        if (xyz) {
          if ((m1 | m2) != pm) continue;
        } else {
          if ((m1 ^ m2) != pm) continue;
        }
        final z = digitsOf(common).first;
        final elims = <Elimination>[];
        for (var c = 0; c < kCells; c++) {
          if (c == pivot || c == p1 || c == p2) continue;
          if (!g.has(c, z)) continue;
          if (!Units.sees[c][p1] || !Units.sees[c][p2]) continue;
          if (xyz && !Units.sees[c][pivot]) continue;
          elims.add(Elimination(c, z));
        }
        if (elims.isEmpty) continue;
        out.add(SolveStep(
          technique: t,
          eliminations: elims,
          patternCells: [pivot, p1, p2],
          patternDigits: digitsOf(pm | m1 | m2),
        ));
        if (first) return out;
      }
    }
  }
  return out;
}

/// Simple Coloring: cadeias de um único dígito ligadas por pares conjugados
/// (unidades em que o dígito só cabe em duas células), pintadas em duas cores.
List<SolveStep> _coloring(CandidateGrid g, bool first) {
  final out = <SolveStep>[];
  for (var d = 1; d <= 9; d++) {
    final adj = <int, List<int>>{};
    for (var u = 0; u < 27; u++) {
      final cs = [
        for (final c in Units.all[u])
          if (g.has(c, d)) c,
      ];
      if (cs.length == 2) {
        (adj[cs[0]] ??= <int>[]).add(cs[1]);
        (adj[cs[1]] ??= <int>[]).add(cs[0]);
      }
    }
    final visited = <int>{};
    final starts = adj.keys.toList()..sort();
    for (final start in starts) {
      if (visited.contains(start)) continue;
      final color = <int, int>{start: 0};
      final queue = <int>[start];
      var qi = 0;
      while (qi < queue.length) {
        final c = queue[qi++];
        for (final nb in adj[c]!) {
          if (!color.containsKey(nb)) {
            color[nb] = 1 - color[c]!;
            queue.add(nb);
          }
        }
      }
      visited.addAll(queue);
      if (queue.length < 3) continue;

      final groups = [
        [
          for (final c in queue)
            if (color[c] == 0) c,
        ],
        [
          for (final c in queue)
            if (color[c] == 1) c,
        ],
      ];

      final elims = <Elimination>[];
      // Regra 1: duas células da mesma cor se veem; essa cor é falsa.
      int? bad;
      for (var k = 0; k < 2 && bad == null; k++) {
        final grp = groups[k];
        for (var i = 0; i < grp.length && bad == null; i++) {
          for (var j = i + 1; j < grp.length; j++) {
            if (Units.sees[grp[i]][grp[j]]) {
              bad = k;
              break;
            }
          }
        }
      }
      if (bad != null) {
        for (final c in groups[bad]) {
          elims.add(Elimination(c, d));
        }
      } else {
        // Regra 2: célula fora da cadeia que vê as duas cores perde o dígito.
        for (var c = 0; c < kCells; c++) {
          if (!g.has(c, d) || color.containsKey(c)) continue;
          final seesA = groups[0].any((x) => Units.sees[c][x]);
          final seesB = groups[1].any((x) => Units.sees[c][x]);
          if (seesA && seesB) elims.add(Elimination(c, d));
        }
      }
      if (elims.isEmpty) continue;
      out.add(SolveStep(
        technique: Technique.simpleColoring,
        eliminations: elims,
        patternCells: List<int>.of(queue)..sort(),
        patternDigits: [d],
      ));
      if (first) return out;
    }
  }
  return out;
}
