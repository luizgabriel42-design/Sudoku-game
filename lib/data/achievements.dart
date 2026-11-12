/// As 22 conquistas e seus critérios. Tudo é calculado a partir do
/// histórico, então nada aqui precisa ser salvo à parte.
library;

import '../engine/generator.dart';
import '../ui/strings.dart';
import 'progress.dart';

enum Rarity { uncommon, rare, epic }

class Achievement {
  final String id;
  final Rarity rarity;
  final int target;
  final int Function(ProgressController p) _current;
  final String _namePt, _nameEn, _descPt, _descEn;

  const Achievement(this.id, this.rarity, this.target, this._current,
      this._namePt, this._nameEn, this._descPt, this._descEn);

  String get name => S.lang == AppLanguage.pt ? _namePt : _nameEn;
  String get description => S.lang == AppLanguage.pt ? _descPt : _descEn;

  int current(ProgressController p) {
    final c = _current(p);
    return c > target ? target : c;
  }

  double progress(ProgressController p) => current(p) / target;
  bool unlocked(ProgressController p) => _current(p) >= target;
}

int _wins(ProgressController p) => p.wins.length;
int _daily(ProgressController p) => p.dailyWins.length;
int _flawless(ProgressController p) =>
    p.wins.where((r) => r.mistakes == 0).length;
int _noHints(ProgressController p) => p.wins.where((r) => r.hints == 0).length;
int _under(ProgressController p, Difficulty d, int seconds) {
  final f = p.fastest(d);
  return f != null && f < seconds ? 1 : 0;
}

int _levels(ProgressController p) =>
    {for (final r in p.wins) r.difficulty}.length;

final List<Achievement> achievements = [
  const Achievement('wins3', Rarity.uncommon, 3, _wins, 'Primeiras ondas',
      'First waves', 'Conclua 3 jogos.', 'Complete 3 games.'),
  const Achievement('wins10', Rarity.uncommon, 10, _wins, 'Maré crescente',
      'Rising tide', 'Conclua 10 jogos.', 'Complete 10 games.'),
  const Achievement('wins25', Rarity.uncommon, 25, _wins, 'Navegante',
      'Navigator', 'Conclua 25 jogos.', 'Complete 25 games.'),
  const Achievement('wins50', Rarity.rare, 50, _wins, 'Correnteza', 'Current',
      'Conclua 50 jogos.', 'Complete 50 games.'),
  const Achievement('wins100', Rarity.rare, 100, _wins, 'Mar aberto',
      'Open sea', 'Conclua 100 jogos.', 'Complete 100 games.'),
  const Achievement('wins300', Rarity.epic, 300, _wins, 'Oceano', 'Ocean',
      'Conclua 300 jogos.', 'Complete 300 games.'),
  const Achievement('daily1', Rarity.uncommon, 1, _daily, 'Primeiro amanhecer',
      'First dawn', 'Conclua 1 desafio diário.', 'Complete 1 daily challenge.'),
  const Achievement('daily7', Rarity.uncommon, 7, _daily, 'Sete marés',
      'Seven tides', 'Conclua 7 desafios diários.',
      'Complete 7 daily challenges.'),
  const Achievement('daily30', Rarity.rare, 30, _daily, 'Trinta luas',
      'Thirty moons', 'Conclua 30 desafios diários.',
      'Complete 30 daily challenges.'),
  Achievement('month1', Rarity.epic, 1, (p) => p.monthsCompleted,
      'Mês completo', 'Full month',
      'Conclua todos os desafios diários de um mês.',
      'Complete every daily challenge of a month.'),
  const Achievement('flawless1', Rarity.uncommon, 1, _flawless, 'Água limpa',
      'Clear water', 'Vença um jogo sem erros.',
      'Win a game with no mistakes.'),
  const Achievement('flawless10', Rarity.rare, 10, _flawless,
      'Espelho d\'água', 'Still water', 'Vença 10 jogos sem erros.',
      'Win 10 games with no mistakes.'),
  const Achievement('nohints5', Rarity.uncommon, 5, _noHints, 'Por conta própria',
      'On your own', 'Vença 5 jogos sem usar dicas.',
      'Win 5 games without hints.'),
  Achievement('medium1', Rarity.uncommon, 1, (p) => p.winsOf(Difficulty.medium),
      'Além da praia', 'Past the shore', 'Vença um jogo Médio.',
      'Win a Medium game.'),
  Achievement('hard1', Rarity.uncommon, 1, (p) => p.winsOf(Difficulty.hard),
      'Águas fundas', 'Deep waters', 'Vença um jogo Difícil.',
      'Win a Hard game.'),
  Achievement('expert1', Rarity.rare, 1, (p) => p.winsOf(Difficulty.expert),
      'Mergulhador', 'Diver', 'Vença um jogo Expert.', 'Win an Expert game.'),
  Achievement(
      'nightmare1', Rarity.rare, 1, (p) => p.winsOf(Difficulty.nightmare),
      'Olho da tempestade', 'Eye of the storm', 'Vença um jogo Pesadelo.',
      'Win a Nightmare game.'),
  Achievement(
      'nightmare10', Rarity.epic, 10, (p) => p.winsOf(Difficulty.nightmare),
      'Senhor das tormentas', 'Storm master', 'Vença 10 jogos Pesadelo.',
      'Win 10 Nightmare games.'),
  Achievement('fastEasy', Rarity.uncommon, 1,
      (p) => _under(p, Difficulty.easy, 180), 'Vento a favor', 'Tailwind',
      'Vença um jogo Fácil em menos de 3 minutos.',
      'Win an Easy game in under 3 minutes.'),
  Achievement('fastExpert', Rarity.epic, 1,
      (p) => _under(p, Difficulty.expert, 600), 'Relâmpago', 'Lightning',
      'Vença um jogo Expert em menos de 10 minutos.',
      'Win an Expert game in under 10 minutes.'),
  Achievement('streak5', Rarity.rare, 5, (p) => p.bestStreakOverall,
      'Maré de sorte', 'Winning tide', 'Vença 5 jogos seguidos.',
      'Win 5 games in a row.'),
  Achievement('levels6', Rarity.epic, 6, _levels, 'Sete mares', 'Seven seas',
      'Vença ao menos um jogo em cada um dos 6 níveis.',
      'Win at least one game on each of the 6 levels.'),
];
