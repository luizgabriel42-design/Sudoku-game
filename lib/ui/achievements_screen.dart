/// Conquistas: contador geral, sugestões, desbloqueadas e bloqueadas.
library;

import 'package:material_ui/material_ui.dart';

import '../data/achievements.dart';
import '../data/progress.dart';
import '../data/settings.dart';
import '../engine/daily.dart';
import '../theme/tokens.dart';
import 'emblems.dart';
import 'strings.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen(
      {super.key, required this.settings, required this.progress});

  final SettingsController settings;
  final ProgressController progress;

  @override
  Widget build(BuildContext context) {
    final p = settings.value.palette(MediaQuery.platformBrightnessOf(context));
    final done = [
      for (final a in achievements)
        if (a.unlocked(progress)) a,
    ];
    final pending = [
      for (final a in achievements)
        if (!a.unlocked(progress)) a,
    ];
    // Sugestões: as três mais próximas de serem concluídas.
    final byProgress = List<Achievement>.of(pending)
      ..sort((a, b) {
        final c = b.progress(progress).compareTo(a.progress(progress));
        return c != 0 ? c : a.target.compareTo(b.target);
      });
    final suggestions = byProgress.take(3).toList();
    final locked = [
      for (final a in pending)
        if (!suggestions.contains(a)) a,
    ];

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        foregroundColor: p.ink,
        title: Text(S.achievementsTitle),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter:
                  MotifPainter(motif: Motif.kumo, color: p.accent.withAlpha(28)),
            ),
          ),
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.military_tech,
                      color: const Color(0xFFD9B36A), size: 52),
                  const SizedBox(width: 8),
                  Text('${done.length} / ${achievements.length}',
                      key: const Key('achievements-count'),
                      style: TextStyle(
                          color: p.ink,
                          fontSize: 38,
                          fontWeight: FontWeight.w300)),
                ],
              ),
              if (suggestions.isNotEmpty) _header(S.suggestions, p),
              for (final a in suggestions) _tile(a, p),
              if (done.isNotEmpty) _header(S.unlocked, p),
              for (final a in done) _tile(a, p),
              if (locked.isNotEmpty) _header(S.locked, p),
              for (final a in locked) _tile(a, p),
            ],
          ),
        ],
      ),
    );
  }

  Widget _header(String title, UmiPalette p) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
        child: Text(title.toUpperCase(),
            style: TextStyle(
                color: p.ink.withAlpha(170),
                fontSize: 13,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600)),
      );

  Color _rarityColor(Rarity r, UmiPalette p) => switch (r) {
        Rarity.uncommon => const Color(0xFF7DB89A),
        Rarity.rare => p.userDigit,
        Rarity.epic => const Color(0xFFC9A04E),
      };

  Widget _tile(Achievement a, UmiPalette p) {
    final value = a.progress(progress);
    final unlocked = a.unlocked(progress);
    final color = _rarityColor(a.rarity, p);
    return Container(
      key: Key('achievement-${a.id}'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.board,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: value,
                  strokeWidth: 5,
                  backgroundColor: p.surface,
                  color: color,
                ),
                Center(
                  child: unlocked
                      ? Icon(Icons.check, color: color)
                      : Text('${(value * 100).floor()}%',
                          style: TextStyle(
                              color: p.ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.name,
                    style: TextStyle(
                        color: p.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w600)),
                Text(a.description,
                    style:
                        TextStyle(color: p.ink.withAlpha(190), fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${S.rarity(a.rarity)} · '
                      '${a.current(progress)}/${a.target}',
                      style: TextStyle(
                          color: p.ink.withAlpha(150), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
