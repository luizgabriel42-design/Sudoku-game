/// Estado e regras de uma partida. Dart puro, serializável em JSON.
library;

import 'generator.dart';
import 'grid.dart';
import 'hint.dart';

enum GameStatus { playing, won, lost }

enum PlaceOutcome { ignored, correct, mistake, won, lost }

/// Regras configuráveis (vêm das Configurações do app).
class GameRules {
  final bool mistakeLimitEnabled;
  final int mistakeLimit;
  final bool autoRemoveNotes;
  final bool preventWrongNotes;

  const GameRules({
    this.mistakeLimitEnabled = true,
    this.mistakeLimit = 3,
    this.autoRemoveNotes = true,
    this.preventWrongNotes = true,
  });

  /// O modo Casual nunca tem limite de erros.
  GameRules forDifficulty(Difficulty d) => d == Difficulty.casual
      ? GameRules(
          mistakeLimitEnabled: false,
          mistakeLimit: mistakeLimit,
          autoRemoveNotes: autoRemoveNotes,
          preventWrongNotes: preventWrongNotes,
        )
      : this;

  Map<String, dynamic> toJson() => {
        'mistakeLimitEnabled': mistakeLimitEnabled,
        'mistakeLimit': mistakeLimit,
        'autoRemoveNotes': autoRemoveNotes,
        'preventWrongNotes': preventWrongNotes,
      };

  factory GameRules.fromJson(Map<String, dynamic> j) => GameRules(
        mistakeLimitEnabled: j['mistakeLimitEnabled'] as bool? ?? true,
        mistakeLimit: j['mistakeLimit'] as int? ?? 3,
        autoRemoveNotes: j['autoRemoveNotes'] as bool? ?? true,
        preventWrongNotes: j['preventWrongNotes'] as bool? ?? true,
      );
}

class SudokuGame {
  static const int _undoCap = 200;

  final Puzzle puzzle;
  GameRules rules;

  /// Valor de cada célula (0 = vazia). Pode conter valores errados.
  final List<int> values;

  /// Anotações de cada célula, como máscara de bits.
  final List<int> notes;

  int mistakes;
  int hintsUsed;
  int directHintsUsed;
  int elapsedSeconds;
  GameStatus status;

  /// Pilha de desfazer: cada item guarda valores (81) + notas (81).
  final List<List<int>> _undo;

  SudokuGame._(this.puzzle, this.rules, this.values, this.notes, this.mistakes,
      this.hintsUsed, this.directHintsUsed, this.elapsedSeconds, this.status,
      this._undo);

  factory SudokuGame.start(Puzzle puzzle,
      {GameRules rules = const GameRules()}) {
    return SudokuGame._(
      puzzle,
      rules.forDifficulty(puzzle.difficulty),
      List<int>.of(puzzle.givens),
      List<int>.filled(kCells, 0),
      0,
      0,
      0,
      0,
      GameStatus.playing,
      <List<int>>[],
    );
  }

  bool isGiven(int cell) => puzzle.givens[cell] != 0;

  bool isCorrect(int cell) =>
      values[cell] != 0 && values[cell] == puzzle.solution[cell];

  bool isWrong(int cell) =>
      values[cell] != 0 && values[cell] != puzzle.solution[cell];

  /// Pistas e acertos ficam travados.
  bool isLocked(int cell) => isGiven(cell) || isCorrect(cell);

  bool get canUndo => _undo.isNotEmpty && status == GameStatus.playing;

  bool get isComplete {
    for (var c = 0; c < kCells; c++) {
      if (values[c] != puzzle.solution[c]) return false;
    }
    return true;
  }

  /// Quantas vezes o dígito ainda falta ser colocado corretamente.
  int remaining(int digit) {
    var placed = 0;
    for (var c = 0; c < kCells; c++) {
      if (values[c] == digit && puzzle.solution[c] == digit) placed++;
    }
    return 9 - placed;
  }

  bool isDigitComplete(int digit) => remaining(digit) == 0;

  void _snapshot() {
    _undo.add([...values, ...notes]);
    if (_undo.length > _undoCap) _undo.removeAt(0);
  }

  void _removeNotesAround(int cell, int digit) {
    final m = ~bit(digit);
    for (final p in Units.peers[cell]) {
      notes[p] &= m;
    }
  }

  /// Coloca um número. Um valor errado conta um erro e fica marcado na
  /// célula até ser apagado ou corrigido.
  PlaceOutcome place(int cell, int digit) {
    if (status != GameStatus.playing) return PlaceOutcome.ignored;
    if (isLocked(cell) || values[cell] == digit) return PlaceOutcome.ignored;

    _snapshot();
    values[cell] = digit;
    notes[cell] = 0;

    if (digit == puzzle.solution[cell]) {
      if (rules.autoRemoveNotes) _removeNotesAround(cell, digit);
      if (isComplete) {
        status = GameStatus.won;
        return PlaceOutcome.won;
      }
      return PlaceOutcome.correct;
    }

    mistakes++;
    if (rules.mistakeLimitEnabled && mistakes >= rules.mistakeLimit) {
      status = GameStatus.lost;
      return PlaceOutcome.lost;
    }
    return PlaceOutcome.mistake;
  }

  /// O dígito já aparece na linha, coluna ou bloco da célula?
  bool conflicts(int cell, int digit) {
    for (final p in Units.peers[cell]) {
      if (values[p] == digit) return true;
    }
    return false;
  }

  /// Alterna uma anotação. Retorna falso se a ação foi recusada.
  bool toggleNote(int cell, int digit) {
    if (status != GameStatus.playing || values[cell] != 0) return false;
    final m = bit(digit);
    final adding = (notes[cell] & m) == 0;
    if (adding && rules.preventWrongNotes && conflicts(cell, digit)) {
      return false;
    }
    _snapshot();
    notes[cell] ^= m;
    return true;
  }

  bool erase(int cell) {
    if (status != GameStatus.playing || isLocked(cell)) return false;
    if (values[cell] == 0 && notes[cell] == 0) return false;
    _snapshot();
    values[cell] = 0;
    notes[cell] = 0;
    return true;
  }

  /// Desfaz a última ação. Erros já contados não são devolvidos.
  bool undo() {
    if (!canUndo) return false;
    final s = _undo.removeLast();
    for (var c = 0; c < kCells; c++) {
      values[c] = s[c];
      notes[c] = s[kCells + c];
    }
    return true;
  }

  /// Notas Avançadas: preenche todas as anotações possíveis.
  void fillAutoNotes() {
    if (status != GameStatus.playing) return;
    _snapshot();
    for (var c = 0; c < kCells; c++) {
      if (values[c] != 0) {
        notes[c] = 0;
        continue;
      }
      // Só valores corretos contam: um erro não deve esconder candidatos.
      var used = 0;
      for (final p in Units.peers[c]) {
        if (isCorrect(p)) used |= bit(values[p]);
      }
      notes[c] = kAllDigits & ~used;
    }
  }

  Hint? hint() => status == GameStatus.playing
      ? computeHint(values, puzzle.solution)
      : null;

  /// Aplica a dica: preenche exatamente um quadrado.
  PlaceOutcome applyHint(Hint h) {
    if (status != GameStatus.playing) return PlaceOutcome.ignored;
    _snapshot();
    values[h.cell] = h.digit;
    notes[h.cell] = 0;
    if (rules.autoRemoveNotes) _removeNotesAround(h.cell, h.digit);
    hintsUsed++;
    if (h.direct) directHintsUsed++;
    if (isComplete) {
      status = GameStatus.won;
      return PlaceOutcome.won;
    }
    return PlaceOutcome.correct;
  }

  /// Completar Automaticamente: quando todas as células vazias têm um único
  /// valor possível, preenche o restante de uma vez. Retorna verdadeiro se
  /// completou o tabuleiro.
  bool autoCompleteIfTrivial() {
    if (status != GameStatus.playing) return false;
    final clean = List<int>.generate(
        kCells, (i) => isCorrect(i) ? values[i] : 0);
    final g = CandidateGrid.fromValues(clean);
    var empties = 0;
    for (var c = 0; c < kCells; c++) {
      if (clean[c] != 0) continue;
      empties++;
      if (popCount(g.cands[c]) != 1) return false;
    }
    if (empties == 0) return false;
    _snapshot();
    for (var c = 0; c < kCells; c++) {
      values[c] = puzzle.solution[c];
      notes[c] = 0;
    }
    status = GameStatus.won;
    return true;
  }

  Map<String, dynamic> toJson() => {
        'schema': 1,
        'puzzle': puzzle.toJson(),
        'rules': rules.toJson(),
        'values': values.join(),
        'notes': notes,
        'mistakes': mistakes,
        'hintsUsed': hintsUsed,
        'directHintsUsed': directHintsUsed,
        'elapsedSeconds': elapsedSeconds,
        'status': status.name,
        'undo': _undo.length > 50 ? _undo.sublist(_undo.length - 50) : _undo,
      };

  factory SudokuGame.fromJson(Map<String, dynamic> j) {
    final valuesStr = j['values'] as String;
    return SudokuGame._(
      Puzzle.fromJson(Map<String, dynamic>.from(j['puzzle'] as Map)),
      GameRules.fromJson(Map<String, dynamic>.from(j['rules'] as Map)),
      List<int>.generate(kCells, (i) => valuesStr.codeUnitAt(i) - 48),
      List<int>.from(j['notes'] as List),
      j['mistakes'] as int,
      j['hintsUsed'] as int,
      j['directHintsUsed'] as int? ?? 0,
      j['elapsedSeconds'] as int,
      GameStatus.values.byName(j['status'] as String),
      [
        for (final s in (j['undo'] as List? ?? const []))
          List<int>.from(s as List),
      ],
    );
  }
}
