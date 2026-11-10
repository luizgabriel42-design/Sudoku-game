/// Desafio diário: puzzle, animal e motivo definidos só pela data.
///
/// Tudo aqui é determinístico, sem depender do aparelho, para que todos os
/// jogadores recebam o mesmo desafio (base para a disputa online futura).
library;

import 'generator.dart';

enum Animal {
  crane, // grou
  owl, // coruja
  butterfly, // borboleta
  turtle, // tartaruga
  fox, // raposa
  deer, // cervo
  dragonfly, // libélula
  cat, // gato
  swallow, // andorinha
  frog, // sapo
  monkey, // macaco
  koi, // carpa-koi
}

enum Motif { asanoha, bamboo, kumo, carp, heron }

const List<Motif> _monthMotifs = [
  Motif.asanoha, // jan
  Motif.bamboo, // fev
  Motif.kumo, // mar
  Motif.carp, // abr
  Motif.asanoha, // mai
  Motif.bamboo, // jun
  Motif.kumo, // jul
  Motif.carp, // ago
  Motif.heron, // set
  Motif.asanoha, // out
  Motif.heron, // nov
  Motif.kumo, // dez
];

/// Animal do troféu do mês (1..12).
Animal monthAnimal(int month) => Animal.values[month - 1];

/// Motivo (estampa) do troféu do mês (1..12).
Motif monthMotif(int month) => _monthMotifs[month - 1];

/// Animal do dia: sequência fixa de 12 animais, um por dia.
Animal dayAnimal(DateTime date) {
  final days = DateTime.utc(date.year, date.month, date.day)
      .difference(DateTime.utc(2026, 1, 1))
      .inDays;
  return Animal.values[((days % 12) + 12) % 12];
}

int dailySeed(DateTime date) =>
    date.year * 10000 + date.month * 100 + date.day;

const List<Difficulty> _weekdayDifficulty = [
  Difficulty.medium, // segunda
  Difficulty.hard,
  Difficulty.medium,
  Difficulty.hard,
  Difficulty.expert, // sexta
  Difficulty.medium,
  Difficulty.hard, // domingo
];

Difficulty dailyDifficulty(DateTime date) =>
    _weekdayDifficulty[date.weekday - 1];

Puzzle dailyPuzzle(DateTime date) =>
    generatePuzzle(dailyDifficulty(date), dailySeed(date));
