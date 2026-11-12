/// Menu de estratégias: lista das 18 técnicas e a página de cada uma,
/// com explicação, exemplo de tabuleiro e passo a passo.
library;

import 'package:material_ui/material_ui.dart';

import '../data/settings.dart';
import '../data/strategy_examples.dart';
import '../engine/grid.dart';
import '../engine/techniques.dart';
import '../theme/tokens.dart';
import 'strategy_texts.dart';
import 'strings.dart';

String _level(Technique t) => switch (t.tier) {
      1 || 2 => S.levelBasic,
      3 => S.levelIntermediate,
      _ => S.levelAdvanced,
    };

class StrategiesScreen extends StatelessWidget {
  const StrategiesScreen({super.key, required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    final p = settings.value.palette(MediaQuery.platformBrightnessOf(context));
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        foregroundColor: p.ink,
        title: Text(S.strategies),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: Technique.values.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final t = Technique.values[i];
          return Material(
            color: p.board,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: Key('strategy-${t.name}'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) =>
                    StrategyDetailScreen(settings: settings, technique: t),
              )),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(S.technique(t),
                              style: TextStyle(
                                  color: p.ink,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600)),
                          Text(_level(t),
                              style: TextStyle(
                                  color: p.ink.withAlpha(160), fontSize: 13)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: p.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(S.learn,
                          style: TextStyle(
                              color: p.userDigit,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class StrategyDetailScreen extends StatelessWidget {
  const StrategyDetailScreen(
      {super.key, required this.settings, required this.technique});

  final SettingsController settings;
  final Technique technique;

  @override
  Widget build(BuildContext context) {
    final p = settings.value.palette(MediaQuery.platformBrightnessOf(context));
    final text = strategyTexts[technique]!;
    final example = strategyExamples[technique];
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        foregroundColor: p.ink,
        title: Text(S.technique(technique)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Text(_level(technique).toUpperCase(),
              style: TextStyle(
                  color: p.userDigit,
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(text.summary,
              key: const Key('strategy-summary'),
              style: TextStyle(color: p.ink, fontSize: 16, height: 1.4)),
          if (example != null) ...[
            _title(S.example, p),
            AspectRatio(
              aspectRatio: 1,
              // Builder: o estilo de texto precisa vir de dentro do Scaffold.
              child: Builder(
                builder: (context) => CustomPaint(
                  key: const Key('strategy-example'),
                  painter: ExampleBoardPainter(
                    example: example,
                    palette: p,
                    textStyle: DefaultTextStyle.of(context).style,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: p.success.withAlpha(150),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(S.step(example.step),
                  style: TextStyle(color: p.ink, fontSize: 14, height: 1.35)),
            ),
          ],
          _title(S.howToFind, p),
          for (var i = 0; i < text.steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: p.surface, shape: BoxShape.circle),
                    child: Text('${i + 1}',
                        style: TextStyle(
                            color: p.ink, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(text.steps[i],
                        style: TextStyle(
                            color: p.ink, fontSize: 15, height: 1.35)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _title(String t, UmiPalette p) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Text(t,
            style: TextStyle(
                color: p.ink, fontSize: 18, fontWeight: FontWeight.w600)),
      );
}

/// Tabuleiro de exemplo: destaca o padrão em verde, o quadrado a preencher
/// em azul e os candidatos eliminados em coral, riscados.
class ExampleBoardPainter extends CustomPainter {
  ExampleBoardPainter({
    required this.example,
    required this.palette,
    this.textStyle = const TextStyle(),
  });

  final StrategyExample example;
  final UmiPalette palette;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final p = palette;
    final step = example.step;
    final cell = size.width / 9;
    final outer = RRect.fromRectAndRadius(
        Offset.zero & size, const Radius.circular(12));
    final pattern = step.patternCells.toSet();
    final removed = {for (final e in step.eliminations) e.cell * 10 + e.digit};

    canvas.save();
    canvas.clipRRect(outer);
    canvas.drawRect(Offset.zero & size, Paint()..color = p.board);

    // Unidades envolvidas, em tom suave.
    for (final u in step.units) {
      for (final c in Units.all[u]) {
        canvas.drawRect(
            Rect.fromLTWH(colOf(c) * cell, rowOf(c) * cell, cell, cell),
            Paint()..color = p.surface.withAlpha(130));
      }
    }

    for (var c = 0; c < kCells; c++) {
      final rect = Rect.fromLTWH(colOf(c) * cell, rowOf(c) * cell, cell, cell);
      final value = example.values.codeUnitAt(c) - 48;
      if (c == step.cell) {
        canvas.drawRect(rect, Paint()..color = p.accent.withAlpha(120));
      } else if (pattern.contains(c)) {
        canvas.drawRect(rect, Paint()..color = p.success);
      }
      if (value != 0) {
        _text(canvas, '$value', rect.center, cell * 0.58, p.ink,
            FontWeight.w500);
        continue;
      }
      if (c == step.cell) {
        _text(canvas, '${step.digit}', rect.center, cell * 0.62, p.userDigit,
            FontWeight.w700);
        continue;
      }
      final sub = cell / 3;
      for (var d = 1; d <= 9; d++) {
        if ((example.cands[c] & bit(d)) == 0) continue;
        final center = Offset(rect.left + ((d - 1) % 3 + 0.5) * sub,
            rect.top + ((d - 1) ~/ 3 + 0.5) * sub);
        final gone = removed.contains(c * 10 + d);
        final key = pattern.contains(c) && step.patternDigits.contains(d);
        _text(
            canvas,
            '$d',
            center,
            sub * 0.80,
            gone
                ? p.wrongDigit
                : key
                    ? p.userDigit
                    : p.ink.withAlpha(150),
            gone || key ? FontWeight.w700 : FontWeight.w400);
        if (gone) {
          canvas.drawLine(
              center + Offset(-sub * 0.32, sub * 0.32),
              center + Offset(sub * 0.32, -sub * 0.32),
              Paint()
                ..color = p.wrongDigit
                ..strokeWidth = 1.5);
        }
      }
    }

    final thin = Paint()
      ..color = p.ink.withAlpha(60)
      ..strokeWidth = 1;
    final thick = Paint()
      ..color = p.ink
      ..strokeWidth = 2;
    for (var i = 1; i < 9; i++) {
      final paint = i % 3 == 0 ? thick : thin;
      canvas.drawLine(Offset(i * cell, 0), Offset(i * cell, size.height), paint);
      canvas.drawLine(Offset(0, i * cell), Offset(size.width, i * cell), paint);
    }
    canvas.restore();
    canvas.drawRRect(
        outer.deflate(1),
        Paint()
          ..color = p.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  void _text(Canvas canvas, String text, Offset center, double fontSize,
      Color color, FontWeight weight) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle.copyWith(
            fontSize: fontSize, color: color, fontWeight: weight, height: 1),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(ExampleBoardPainter old) =>
      old.example != example || old.palette != palette;
}
