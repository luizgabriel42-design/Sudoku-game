/// Tokens de design. Ajuste as cores e medidas aqui; as telas só leem daqui.
library;

import 'package:flutter/material.dart';

/// Paleta de um tema.
class UmiPalette {
  final Color background; // fundo principal e tabuleiro
  final Color surface; // cards e cabeçalhos
  final Color success; // acertos, conquistas desbloqueadas
  final Color ink; // textos e linhas
  final Color accent; // botões e seleção
  final Color error; // erros e alertas (com moderação)
  final Brightness brightness;

  const UmiPalette({
    required this.background,
    required this.surface,
    required this.success,
    required this.ink,
    required this.accent,
    required this.error,
    required this.brightness,
  });

  /// Tema padrão: Umi (névoa do mar).
  static const umi = UmiPalette(
    background: Color(0xFFF3EBDD), // areia
    surface: Color(0xFFDCE8F0), // azul-névoa
    success: Color(0xFFCFE3D6), // verde-chá
    ink: Color(0xFF4A5968), // grafite suave
    accent: Color(0xFF7FA7C4), // azul-profundo suave
    error: Color(0xFFE8A598), // coral suave
    brightness: Brightness.light,
  );

  /// Tema alternativo: Sakura.
  static const sakura = UmiPalette(
    background: Color(0xFFFBF7F4), // off-white quente
    surface: Color(0xFFF4D6DC), // rosa-pétala
    success: Color(0xFFDDE8D8),
    ink: Color(0xFF6B5B6E), // cinza-ameixa
    accent: Color(0xFFD9A3B0),
    error: Color(0xFFE39A8C),
    brightness: Brightness.light,
  );

  /// Tema escuro: tinta suave, nunca preto puro.
  static const dark = UmiPalette(
    background: Color(0xFF1F2A33),
    surface: Color(0xFF2B3A46),
    success: Color(0xFF3F5A4E),
    ink: Color(0xFFDCE8F0),
    accent: Color(0xFF7FA7C4),
    error: Color(0xFFE8A598),
    brightness: Brightness.dark,
  );
}

/// Medidas compartilhadas.
class UmiMetrics {
  static const double radiusCard = 20;
  static const double radiusButton = 28;
  static const double minTouch = 48; // alvo mínimo de toque (dp)
  static const double gap = 16;

  /// Opacidade das estampas decorativas (seigaiha, kasumi, ondas).
  static const double patternOpacity = 0.10;
}

ThemeData buildTheme(UmiPalette p) {
  final scheme = ColorScheme.fromSeed(
    seedColor: p.accent,
    brightness: p.brightness,
  ).copyWith(
    surface: p.background,
    primary: p.accent,
    onSurface: p.ink,
    error: p.error,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.background,
    appBarTheme: AppBarTheme(
      backgroundColor: p.surface,
      foregroundColor: p.ink,
      elevation: 0,
    ),
  );
}
