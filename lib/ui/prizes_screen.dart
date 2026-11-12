/// Prêmios: troféus mensais dos desafios diários.
library;

import 'package:material_ui/material_ui.dart';

import '../data/progress.dart';
import '../data/settings.dart';
import '../engine/daily.dart';
import '../theme/tokens.dart';
import 'emblems.dart';
import 'strings.dart';

class PrizesScreen extends StatelessWidget {
  const PrizesScreen({
    super.key,
    required this.settings,
    required this.progress,
    required this.year,
  });

  final SettingsController settings;
  final ProgressController progress;
  final int year;

  @override
  Widget build(BuildContext context) {
    final p = settings.value.palette(MediaQuery.platformBrightnessOf(context));
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: p.background,
        appBar: AppBar(
          backgroundColor: p.background,
          foregroundColor: p.ink,
          title: Text(S.prizes),
          bottom: TabBar(
            labelColor: p.ink,
            unselectedLabelColor: p.ink.withAlpha(130),
            indicatorColor: p.userDigit,
            tabs: [
              Tab(text: S.challenges),
              Tab(text: S.adventures),
              Tab(text: S.events),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
              children: [
                for (var m = 1; m <= 12; m++) _trophy(m, p),
              ],
            ),
            _soon(p),
            _soon(p),
          ],
        ),
      ),
    );
  }

  Widget _soon(UmiPalette p) => Center(
        child: Text(S.soon,
            style: TextStyle(color: p.ink.withAlpha(150), fontSize: 18)),
      );

  Widget _trophy(int month, UmiPalette p) {
    final earned = progress.monthComplete(year, month);
    final count = progress.dailyWinsInMonth(year, month);
    final days = ProgressController.daysInMonth(year, month);
    return Container(
      key: Key('trophy-$month'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: earned ? p.surface : p.board,
        borderRadius: BorderRadius.circular(UmiMetrics.radiusCard),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: MotifPainter(
              motif: monthMotif(month),
              color: (earned ? p.accent : p.ink).withAlpha(earned ? 70 : 22),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: CustomPaint(
                          painter: TrophyPainter(
                            fill: earned
                                ? const Color(0xFFE8C98A)
                                : p.ink.withAlpha(35),
                            line: earned
                                ? const Color(0xFFB48F45)
                                : p.ink.withAlpha(90),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: HankoSeal(
                          animal: monthAnimal(month),
                          color: earned ? p.wrongDigit : p.ink.withAlpha(90),
                          size: 30,
                          filled: earned,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text('${S.monthShort(month)}. · ${S.animal(monthAnimal(month))}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: p.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text('$count/$days',
                    style:
                        TextStyle(color: p.ink.withAlpha(150), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
