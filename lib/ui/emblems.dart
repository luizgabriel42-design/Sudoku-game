/// Emblemas originais: selo (hanko) dos animais, troféu e estampas dos
/// motivos mensais (asanoha, bambu, kumo, carpa e garça).
library;

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../engine/daily.dart';

/// Ideograma de cada animal, usado como selo decorativo. O nome do animal
/// sempre aparece por extenso ao lado, no idioma do app.
String animalKanji(Animal a) => switch (a) {
      Animal.crane => '鶴',
      Animal.owl => '梟',
      Animal.butterfly => '蝶',
      Animal.turtle => '亀',
      Animal.fox => '狐',
      Animal.deer => '鹿',
      Animal.dragonfly => '蜻',
      Animal.cat => '猫',
      Animal.swallow => '燕',
      Animal.frog => '蛙',
      Animal.monkey => '猿',
      Animal.koi => '鯉',
    };

/// Selo no estilo hanko (carimbo de assinatura japonês).
class HankoSeal extends StatelessWidget {
  const HankoSeal({
    super.key,
    required this.animal,
    required this.color,
    this.size = 44,
    this.filled = false,
  });

  final Animal animal;
  final Color color;
  final double size;

  /// Preenchido: selo carimbado (fundo na cor, ideograma claro).
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? color : null,
        borderRadius: BorderRadius.circular(size * 0.2),
        border: Border.all(color: color, width: size * 0.06),
      ),
      child: Text(
        animalKanji(animal),
        style: TextStyle(
          fontSize: size * 0.58,
          height: 1.1,
          color: filled ? const Color(0xFFFBF7EE) : color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Taça de troféu desenhada em vetor.
class TrophyPainter extends CustomPainter {
  TrophyPainter({required this.fill, required this.line});

  final Color fill;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fillPaint = Paint()..color = fill;
    final stroke = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeJoin = StrokeJoin.round;

    // Alças.
    final handle = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
        Rect.fromCircle(center: Offset(w * 0.24, h * 0.27), radius: w * 0.13),
        math.pi / 2, math.pi, false, handle);
    canvas.drawArc(
        Rect.fromCircle(center: Offset(w * 0.76, h * 0.27), radius: w * 0.13),
        -math.pi / 2, math.pi, false, handle);

    // Bojo.
    final bowl = Path()
      ..moveTo(w * 0.22, h * 0.10)
      ..lineTo(w * 0.78, h * 0.10)
      ..quadraticBezierTo(w * 0.80, h * 0.52, w * 0.50, h * 0.58)
      ..quadraticBezierTo(w * 0.20, h * 0.52, w * 0.22, h * 0.10)
      ..close();
    canvas.drawPath(bowl, fillPaint);
    canvas.drawPath(bowl, stroke);

    // Haste e base.
    final stem = Rect.fromLTRB(w * 0.45, h * 0.58, w * 0.55, h * 0.74);
    canvas.drawRect(stem, fillPaint);
    canvas.drawRect(stem, stroke);
    for (final r in [
      Rect.fromLTRB(w * 0.32, h * 0.74, w * 0.68, h * 0.83),
      Rect.fromLTRB(w * 0.24, h * 0.83, w * 0.76, h * 0.93),
    ]) {
      final rr = RRect.fromRectAndRadius(r, Radius.circular(w * 0.02));
      canvas.drawRRect(rr, fillPaint);
      canvas.drawRRect(rr, stroke);
    }
  }

  @override
  bool shouldRepaint(TrophyPainter old) =>
      old.fill != fill || old.line != line;
}

/// Estampa de fundo de cada motivo mensal.
class MotifPainter extends CustomPainter {
  MotifPainter({required this.motif, required this.color});

  final Motif motif;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    switch (motif) {
      case Motif.asanoha:
        // Malha de triângulos (folha de cânhamo).
        const s = 22.0;
        final hgt = s * math.sqrt(3) / 2;
        for (var y = -hgt; y < size.height + hgt; y += hgt) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
        }
        for (var x = -size.height; x < size.width + size.height; x += s) {
          canvas.drawLine(Offset(x, 0),
              Offset(x + size.height / math.sqrt(3), size.height), p);
          canvas.drawLine(Offset(x + size.height / math.sqrt(3), 0),
              Offset(x, size.height), p);
        }
      case Motif.bamboo:
        // Hastes de bambu com nós.
        for (var x = 10.0; x < size.width; x += 26) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
          canvas.drawLine(Offset(x + 7, 0), Offset(x + 7, size.height), p);
          final shift = (x / 26).floor().isEven ? 0.0 : 18.0;
          for (var y = 14.0 + shift; y < size.height; y += 36) {
            canvas.drawLine(Offset(x - 1, y), Offset(x + 8, y), p);
          }
        }
      case Motif.kumo:
        // Nuvens em três arcos.
        var row = 0;
        for (var y = 14.0; y < size.height + 10; y += 26) {
          final off = row.isOdd ? 22.0 : 0.0;
          for (var x = -10.0 + off; x < size.width; x += 44) {
            for (var i = 0; i < 3; i++) {
              canvas.drawArc(
                  Rect.fromCircle(center: Offset(x + i * 9, y), radius: 6),
                  math.pi, math.pi, false, p);
            }
            canvas.drawLine(Offset(x - 8, y), Offset(x + 26, y), p);
          }
          row++;
        }
      case Motif.carp:
        // Escamas.
        var row = 0;
        for (var y = 0.0; y < size.height + 12; y += 11) {
          final off = row.isOdd ? 11.0 : 0.0;
          for (var x = -11.0 + off; x < size.width + 11; x += 22) {
            canvas.drawArc(
                Rect.fromCircle(center: Offset(x, y), radius: 11),
                0, math.pi, false, p);
          }
          row++;
        }
      case Motif.heron:
        // Água corrente (ryusui).
        for (var y = 8.0; y < size.height; y += 14) {
          final path = Path()..moveTo(0, y);
          for (var x = 0.0; x <= size.width; x += 4) {
            path.lineTo(x, y + math.sin(x / 16 + y / 9) * 4);
          }
          canvas.drawPath(path, p);
        }
    }
  }

  @override
  bool shouldRepaint(MotifPainter old) =>
      old.motif != motif || old.color != color;
}
