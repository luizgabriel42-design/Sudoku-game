/// Geometria do tabuleiro 9x9 e utilitários de máscara de bits.
///
/// Dart puro, sem dependência de Flutter. Um dígito `d` (1..9) é
/// representado pelo bit `1 << (d - 1)`.
library;

const int kCells = 81;
const int kAllDigits = 0x1FF;

int rowOf(int cell) => cell ~/ 9;
int colOf(int cell) => cell % 9;
int boxOf(int cell) => (cell ~/ 27) * 3 + (cell % 9) ~/ 3;

int bit(int digit) => 1 << (digit - 1);

int popCount(int mask) {
  var n = 0;
  var m = mask;
  while (m != 0) {
    m &= m - 1;
    n++;
  }
  return n;
}

List<int> digitsOf(int mask) => [
      for (var d = 1; d <= 9; d++)
        if ((mask & bit(d)) != 0) d,
    ];

/// Unidades (linhas, colunas, blocos) e vizinhança.
///
/// Índices em [all]: 0..8 linhas, 9..17 colunas, 18..26 blocos.
class Units {
  static final List<List<int>> rows =
      List.generate(9, (r) => List.generate(9, (i) => r * 9 + i));

  static final List<List<int>> cols =
      List.generate(9, (c) => List.generate(9, (i) => i * 9 + c));

  static final List<List<int>> boxes = List.generate(9, (b) {
    final r0 = (b ~/ 3) * 3;
    final c0 = (b % 3) * 3;
    return List.generate(9, (i) => (r0 + i ~/ 3) * 9 + c0 + i % 3);
  });

  static final List<List<int>> all = [...rows, ...cols, ...boxes];

  static final List<List<int>> peers = List.generate(kCells, (c) {
    final s = <int>{}
      ..addAll(rows[rowOf(c)])
      ..addAll(cols[colOf(c)])
      ..addAll(boxes[boxOf(c)])
      ..remove(c);
    return s.toList()..sort();
  });

  static final List<List<bool>> sees = List.generate(kCells, (a) {
    final row = List<bool>.filled(kCells, false);
    for (final p in peers[a]) {
      row[p] = true;
    }
    return row;
  });

  static bool isRow(int unit) => unit < 9;
  static bool isCol(int unit) => unit >= 9 && unit < 18;
  static bool isBox(int unit) => unit >= 18;
}

/// Todas as combinações de [k] elementos de [items], em ordem.
List<List<int>> combinations(List<int> items, int k) {
  final out = <List<int>>[];
  final cur = <int>[];
  void rec(int start) {
    if (cur.length == k) {
      out.add(List<int>.of(cur));
      return;
    }
    final need = k - cur.length;
    for (var i = start; i <= items.length - need; i++) {
      cur.add(items[i]);
      rec(i + 1);
      cur.removeLast();
    }
  }

  rec(0);
  return out;
}

/// Gerador pseudoaleatório próprio (xorshift32).
///
/// Não usamos `dart:math Random` porque a sequência dele pode mudar entre
/// versões do SDK. Com este gerador, a mesma semente produz o mesmo puzzle
/// em qualquer aparelho e versão do app, o que o desafio diário (e o futuro
/// modo online) exigem.
class Rng {
  int _s;

  Rng(int seed) : _s = seed & 0xFFFFFFFF {
    if (_s == 0) _s = 0x9E3779B9;
    // Descarta os primeiros valores para espalhar sementes pequenas.
    for (var i = 0; i < 8; i++) {
      next();
    }
  }

  int next() {
    var x = _s;
    x ^= (x << 13) & 0xFFFFFFFF;
    x ^= x >> 17;
    x ^= (x << 5) & 0xFFFFFFFF;
    _s = x & 0xFFFFFFFF;
    return _s;
  }

  int nextInt(int max) => next() % max;

  void shuffle(List<int> list) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final t = list[i];
      list[i] = list[j];
      list[j] = t;
    }
  }
}

/// Valores + candidatos de cada célula.
class CandidateGrid {
  final List<int> values;
  final List<int> cands;

  CandidateGrid._(this.values, this.cands);

  factory CandidateGrid.fromValues(List<int> source) {
    final values = List<int>.of(source);
    final cands = List<int>.filled(kCells, 0);
    for (var c = 0; c < kCells; c++) {
      if (values[c] != 0) continue;
      var used = 0;
      for (final p in Units.peers[c]) {
        final v = values[p];
        if (v != 0) used |= bit(v);
      }
      cands[c] = kAllDigits & ~used;
    }
    return CandidateGrid._(values, cands);
  }

  CandidateGrid copy() =>
      CandidateGrid._(List<int>.of(values), List<int>.of(cands));

  void place(int cell, int digit) {
    values[cell] = digit;
    cands[cell] = 0;
    final m = ~bit(digit);
    for (final p in Units.peers[cell]) {
      cands[p] &= m;
    }
  }

  bool eliminate(int cell, int digit) {
    final m = bit(digit);
    if ((cands[cell] & m) == 0) return false;
    cands[cell] &= ~m;
    return true;
  }

  bool has(int cell, int digit) => (cands[cell] & bit(digit)) != 0;

  bool get solved => !values.contains(0);
}
