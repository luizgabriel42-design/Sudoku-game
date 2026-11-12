/// Estampas decorativas originais do tema Umi: seigaiha (ondas
/// concêntricas), kasumi (névoa) e ondas estilizadas.
///
/// Ficam só em fundos e cabeçalhos, nunca atrás do tabuleiro.
library;

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Seigaiha: fileiras de arcos concêntricos sobrepostos.
class SeigaihaPainter extends CustomPainter {
  SeigaihaPainter({
    required this.line,
    required this.fill,
    this.radius = 26,
  });

  final Color line;
  final Color fill;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..color = fill;
    final stroke = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final r = radius;
    var rowIndex = 0;
    // De cima para baixo: cada fileira cobre a metade inferior da anterior.
    for (var y = 0.0; y < size.height + r; y += r / 2) {
      final offset = rowIndex.isOdd ? r : 0.0;
      for (var x = -r + offset; x < size.width + r; x += 2 * r) {
        final center = Offset(x, y + r);
        canvas.drawCircle(center, r, fillPaint);
        canvas.drawCircle(center, r, stroke);
        canvas.drawCircle(center, r * 0.70, stroke);
        canvas.drawCircle(center, r * 0.40, stroke);
      }
      rowIndex++;
    }
  }

  @override
  bool shouldRepaint(SeigaihaPainter old) =>
      old.line != line || old.fill != fill || old.radius != radius;
}

/// Ondas estilizadas: três faixas onduladas com cristas.
class WavesPainter extends CustomPainter {
  WavesPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    for (var layer = 0; layer < 3; layer++) {
      final paint = Paint()..color = color.withAlpha(40 + layer * 35);
      final base = size.height * (0.45 + layer * 0.18);
      final amp = size.height * (0.16 - layer * 0.03);
      final wave = size.width / (2.5 + layer);
      final path = Path()..moveTo(0, size.height);
      path.lineTo(0, base);
      for (var x = 0.0; x <= size.width; x += 4) {
        final y = base +
            math.sin((x / wave) * 2 * math.pi + layer * 1.3) * amp;
        path.lineTo(x, y);
      }
      path
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(WavesPainter old) => old.color != color;
}

/// Kasumi: névoa em degradê que dissolve a estampa no fundo.
class Kasumi extends StatelessWidget {
  const Kasumi({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withAlpha(0), color.withAlpha(150), color],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}
