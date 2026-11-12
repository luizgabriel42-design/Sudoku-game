/// Diário: calendário mensal dos desafios diários, com o animal de cada dia
/// e o troféu do mês.
library;

import 'package:material_ui/material_ui.dart';

import '../data/progress.dart';
import '../data/settings.dart';
import '../engine/daily.dart';
import '../theme/tokens.dart';
import 'emblems.dart';
import 'patterns.dart';
import 'strings.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({
    super.key,
    required this.settings,
    required this.progress,
    required this.onPlay,
    this.now,
  });

  final SettingsController settings;
  final ProgressController progress;

  /// Abre o desafio diário da data escolhida.
  final Future<void> Function(DateTime date) onPlay;
  final DateTime Function()? now;

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  late DateTime _today;
  late int _year;
  late int _month;
  late int _day;

  UmiPalette get _p =>
      widget.settings.value.palette(MediaQuery.platformBrightnessOf(context));

  @override
  void initState() {
    super.initState();
    final n = (widget.now ?? DateTime.now)();
    _today = DateTime(n.year, n.month, n.day);
    _year = _today.year;
    _month = _today.month;
    _day = _today.day;
  }

  bool get _isCurrentMonth =>
      _year == _today.year && _month == _today.month;

  bool _isFuture(int day) => DateTime(_year, _month, day).isAfter(_today);

  void _shift(int delta) {
    final next = DateTime(_year, _month + delta);
    // Não navega para meses futuros.
    if (next.isAfter(DateTime(_today.year, _today.month))) return;
    setState(() {
      _year = next.year;
      _month = next.month;
      _day = _isCurrentMonth ? _today.day : 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.settings, widget.progress]),
      builder: (context, _) {
        final p = _p;
        final days = ProgressController.daysInMonth(_year, _month);
        final doneCount = widget.progress.dailyWinsInMonth(_year, _month);
        final trophy = widget.progress.monthComplete(_year, _month);
        final selected = DateTime(_year, _month, _day);
        final selectedDone = widget.progress.dailyDone(selected);
        final future = _isFuture(_day);
        return Scaffold(
          backgroundColor: p.background,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                // Cabeçalho do mês com o troféu.
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  height: 190,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(UmiMetrics.radiusCard),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(
                        painter: MotifPainter(
                          motif: monthMotif(_month),
                          color: p.accent.withAlpha(60),
                        ),
                      ),
                      CustomPaint(painter: WavesPainter(color: p.accent)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            IconButton(
                              key: const Key('month-prev'),
                              icon: const Icon(Icons.chevron_left),
                              color: p.ink,
                              onPressed: () => _shift(-1),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${S.monthName(_month)} $_year',
                                    key: const Key('month-title'),
                                    style: TextStyle(
                                        color: p.ink,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: 78,
                                    height: 78,
                                    child: CustomPaint(
                                      painter: TrophyPainter(
                                        fill: trophy
                                            ? const Color(0xFFE8C98A)
                                            : p.board.withAlpha(200),
                                        line: trophy
                                            ? const Color(0xFFB48F45)
                                            : p.ink.withAlpha(110),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${S.monthTrophy} · '
                                    '${S.animal(monthAnimal(_month))} · '
                                    '$doneCount/$days',
                                    style:
                                        TextStyle(color: p.ink, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              key: const Key('month-next'),
                              icon: const Icon(Icons.chevron_right),
                              color: _isCurrentMonth
                                  ? p.ink.withAlpha(60)
                                  : p.ink,
                              onPressed: _isCurrentMonth ? null : () => _shift(1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 7,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      for (var d = 1; d <= days; d++) _dayCell(d, p),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Cartão do dia selecionado.
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: p.board,
                    borderRadius: BorderRadius.circular(UmiMetrics.radiusCard),
                  ),
                  child: Row(
                    children: [
                      HankoSeal(
                        animal: dayAnimal(selected),
                        color: p.wrongDigit,
                        size: 52,
                        filled: selectedDone,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_day ${S.monthShort(_month)} · '
                              '${S.animal(dayAnimal(selected))}',
                              key: const Key('day-title'),
                              style: TextStyle(
                                  color: p.ink,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              future
                                  ? S.futureDay
                                  : S.difficulty(dailyDifficulty(selected)),
                              style: TextStyle(
                                  color: p.ink.withAlpha(180), fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        key: const Key('daily-play'),
                        onPressed: future || selectedDone
                            ? null
                            : () => widget.onPlay(selected),
                        child: Text(selectedDone ? S.done : S.play),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dayCell(int day, UmiPalette p) {
    final date = DateTime(_year, _month, day);
    final done = widget.progress.dailyDone(date);
    final future = _isFuture(day);
    final selected = day == _day;
    final isToday = date == _today;
    Color? fill;
    var fg = p.ink;
    if (selected) {
      fill = p.userDigit;
      fg = p.board;
    } else if (done) {
      fill = p.success;
    }
    if (future && !selected) fg = p.ink.withAlpha(80);
    return Padding(
      padding: const EdgeInsets.all(3),
      child: InkWell(
        key: Key('day-$day'),
        customBorder: const CircleBorder(),
        onTap: () => setState(() => _day = day),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill,
            border: isToday && !selected
                ? Border.all(color: p.userDigit, width: 2)
                : null,
          ),
          child: done && !selected
              ? Icon(Icons.check, size: 18, color: p.ink)
              : Text('$day',
                  style: TextStyle(
                      color: fg,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
