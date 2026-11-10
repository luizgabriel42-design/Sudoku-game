/// Gerador de puzzles com solução única e dificuldade classificada.
library;

import 'grid.dart';
import 'logical_solver.dart';
import 'techniques.dart';

/// Níveis de dificuldade.
///
/// [maxTier] é o grupo de técnicas mais avançado que o puzzle pode exigir;
/// [minClues] é o mínimo de pistas que o gerador deixa no tabuleiro.
enum Difficulty {
  casual(1, 46, false, 1),
  easy(1, 38, false, 1),
  medium(2, 32, true, 20),
  hard(3, 28, true, 40),
  expert(4, 24, true, 60),
  nightmare(5, 22, true, 80);

  const Difficulty(
      this.maxTier, this.minClues, this.requireTier, this.maxAttempts);

  final int maxTier;
  final int minClues;

  /// Se verdadeiro, o puzzle precisa exigir ao menos uma técnica de [maxTier].
  final bool requireTier;
  final int maxAttempts;
}

class Puzzle {
  final List<int> givens;
  final List<int> solution;
  final Difficulty difficulty;
  final int seed;

  /// Técnica mais avançada necessária para resolver por lógica.
  final Technique? hardest;

  const Puzzle({
    required this.givens,
    required this.solution,
    required this.difficulty,
    required this.seed,
    this.hardest,
  });

  int get clueCount => givens.where((v) => v != 0).length;

  Map<String, dynamic> toJson() => {
        'givens': givens.join(),
        'solution': solution.join(),
        'difficulty': difficulty.name,
        'seed': seed,
        'hardest': hardest?.name,
      };

  factory Puzzle.fromJson(Map<String, dynamic> j) => Puzzle(
        givens: _parseGrid(j['givens'] as String),
        solution: _parseGrid(j['solution'] as String),
        difficulty: Difficulty.values.byName(j['difficulty'] as String),
        seed: j['seed'] as int,
        hardest: j['hardest'] == null
            ? null
            : Technique.values.byName(j['hardest'] as String),
      );
}

List<int> _parseGrid(String s) =>
    List<int>.generate(kCells, (i) => s.codeUnitAt(i) - 48);

/// Gera um puzzle determinístico: mesma dificuldade + mesma semente
/// produzem sempre o mesmo tabuleiro.
///
/// Remove pistas uma a uma enquanto o puzzle continuar resolvível só com
/// as técnicas permitidas para o nível. Como essas técnicas são sólidas,
/// a solução é única por construção.
Puzzle generatePuzzle(Difficulty difficulty, int seed) {
  Puzzle? best;
  var bestTier = -1;
  for (var attempt = 0; attempt < difficulty.maxAttempts; attempt++) {
    final rng = Rng((seed * 2654435761 + attempt * 40503 + 12345) & 0xFFFFFFFF);
    final solution = _fullGrid(rng);
    final givens = List<int>.of(solution);
    final order = List<int>.generate(kCells, (i) => i);
    rng.shuffle(order);

    var clues = kCells;
    for (final c in order) {
      if (clues <= difficulty.minClues) break;
      final saved = givens[c];
      givens[c] = 0;
      final r = solveLogically(givens,
          maxTier: difficulty.maxTier, recordSteps: false);
      if (r.solved) {
        clues--;
      } else {
        givens[c] = saved;
      }
    }

    final result = solveLogically(givens,
        maxTier: difficulty.maxTier, recordSteps: false);
    final puzzle = Puzzle(
      givens: givens,
      solution: solution,
      difficulty: difficulty,
      seed: seed,
      hardest: result.hardest,
    );
    if (!difficulty.requireTier || result.maxTier == difficulty.maxTier) {
      return puzzle;
    }
    if (result.maxTier > bestTier) {
      bestTier = result.maxTier;
      best = puzzle;
    }
  }
  return best!;
}

/// Tabuleiro completo e válido, preenchido por backtracking aleatório.
List<int> _fullGrid(Rng rng) {
  final v = List<int>.filled(kCells, 0);
  final rowM = List<int>.filled(9, 0);
  final colM = List<int>.filled(9, 0);
  final boxM = List<int>.filled(9, 0);

  bool fill(int c) {
    if (c == kCells) return true;
    final r = rowOf(c);
    final co = colOf(c);
    final b = boxOf(c);
    final digits = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    rng.shuffle(digits);
    for (final d in digits) {
      final m = bit(d);
      if (((rowM[r] | colM[co] | boxM[b]) & m) != 0) continue;
      v[c] = d;
      rowM[r] |= m;
      colM[co] |= m;
      boxM[b] |= m;
      if (fill(c + 1)) return true;
      v[c] = 0;
      rowM[r] &= ~m;
      colM[co] &= ~m;
      boxM[b] &= ~m;
    }
    return false;
  }

  fill(0);
  return v;
}

/// Conta soluções por força bruta, parando em [limit].
/// Usado em testes e como verificação independente do gerador.
int countSolutions(List<int> givens, {int limit = 2}) {
  final g = CandidateGrid.fromValues(givens);
  // Pistas contraditórias: nenhuma solução.
  for (var c = 0; c < kCells; c++) {
    final v = givens[c];
    if (v == 0) continue;
    for (final p in Units.peers[c]) {
      if (givens[p] == v) return 0;
    }
  }
  var count = 0;

  void search(CandidateGrid s) {
    if (count >= limit) return;
    var best = -1;
    var bestN = 10;
    for (var c = 0; c < kCells; c++) {
      if (s.values[c] != 0) continue;
      final n = popCount(s.cands[c]);
      if (n == 0) return;
      if (n < bestN) {
        bestN = n;
        best = c;
      }
    }
    if (best == -1) {
      count++;
      return;
    }
    for (final d in digitsOf(s.cands[best])) {
      final next = s.copy()..place(best, d);
      search(next);
      if (count >= limit) return;
    }
  }

  search(g);
  return count;
}
