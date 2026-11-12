/// Estatísticas por dificuldade e histórico de partidas.
library;

import 'package:material_ui/material_ui.dart';

import '../data/progress.dart';
import '../data/settings.dart';
import '../engine/daily.dart';
import '../engine/generator.dart';
import '../theme/tokens.dart';
import 'emblems.dart';
import 'strings.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.settings, required this.progress});

  final SettingsController settings;
  final ProgressController progress;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([settings, progress]),
      builder: (context, _) {
        final p = settings.value.palette(MediaQuery.platformBrightnessOf(context));
        return DefaultTabController(
          length: Difficulty.values.length,
          initialIndex: Difficulty.easy.index,
          child: Scaffold(
            backgroundColor: p.background,
            appBar: AppBar(
              backgroundColor: p.background,
              foregroundColor: p.ink,
              automaticallyImplyLeading: false,
              title: Text(S.tabStats),
              actions: [
                IconButton(
                  key: const Key('open-history'),
                  icon: const Icon(Icons.history),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => HistoryScreen(
                          settings: settings, progress: progress),
                    ),
                  ),
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                labelColor: p.ink,
                unselectedLabelColor: p.ink.withAlpha(130),
                indicatorColor: p.userDigit,
                tabs: [
                  for (final d in Difficulty.values) Tab(text: S.difficulty(d)),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                for (final d in Difficulty.values) _page(d, p),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _page(Difficulty d, UmiPalette p) {
    final s = progress.statsFor(d);
    String time(int? t) => t == null ? '–' : S.formatTime(t);
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: MotifPainter(
                motif: Motif.asanoha, color: p.accent.withAlpha(22)),
          ),
        ),
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _group(S.games, Icons.grid_on, p, [
              (S.gamesStarted, '${s.started}', 'started'),
              (S.gamesWon, '${s.won}', 'won'),
              (S.winRate, '${s.winRate}%', 'rate'),
              (S.flawlessWins, '${s.flawless}', 'flawless'),
            ]),
            _group(S.time, Icons.hourglass_bottom, p, [
              (S.bestTime, time(s.bestTime), 'best'),
              (S.averageTime, time(s.averageTime), 'avg'),
            ]),
            _group(S.streaks, Icons.star_outline, p, [
              (S.currentStreak, '${s.currentStreak}', 'streak'),
              (S.bestStreak, '${s.bestStreak}', 'best-streak'),
            ]),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.surface.withAlpha(140),
                borderRadius: BorderRadius.circular(UmiMetrics.radiusCard),
              ),
              child: Row(
                children: [
                  Icon(Icons.cloud_off_outlined, color: p.ink.withAlpha(130)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(S.syncSoon,
                        style: TextStyle(color: p.ink.withAlpha(150))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _group(String title, IconData icon, UmiPalette p,
      List<(String, String, String)> rows) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: p.userDigit, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      color: p.ink, fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: p.board,
              borderRadius: BorderRadius.circular(UmiMetrics.radiusCard),
            ),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0)
                    Divider(height: 1, color: p.ink.withAlpha(30), indent: 16, endIndent: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(rows[i].$1,
                              style: TextStyle(
                                  color: p.ink.withAlpha(190), fontSize: 15)),
                        ),
                        Text(rows[i].$2,
                            key: Key('stat-${rows[i].$3}'),
                            style: TextStyle(
                                color: p.ink,
                                fontSize: 18,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen(
      {super.key, required this.settings, required this.progress});

  final SettingsController settings;
  final ProgressController progress;

  @override
  Widget build(BuildContext context) {
    final p = settings.value.palette(MediaQuery.platformBrightnessOf(context));
    final records = progress.history.reversed.toList();
    String two(int n) => n.toString().padLeft(2, '0');
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        foregroundColor: p.ink,
        title: Text(S.history),
      ),
      body: records.isEmpty
          ? Center(
              child: Text(S.noHistory,
                  style: TextStyle(color: p.ink, fontSize: 16)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final r = records[i];
                final d = DateTime.fromMillisecondsSinceEpoch(r.finishedAt);
                final daily = r.dailyDate != null;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: p.board,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        r.won
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        color: r.won ? p.userDigit : p.wrongDigit,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${daily ? '${S.dailyChallenge} · ' : ''}'
                              '${S.difficulty(r.difficulty)} · '
                              '${r.won ? S.victory : S.defeat}',
                              style: TextStyle(
                                  color: p.ink,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${S.formatTime(r.seconds)} · '
                              '${S.mistakes}: ${r.mistakes} · '
                              '${S.hints}: ${r.hints}',
                              style: TextStyle(
                                  color: p.ink.withAlpha(180), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${two(d.day)}/${two(d.month)}/${d.year}',
                        style:
                            TextStyle(color: p.ink.withAlpha(150), fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
