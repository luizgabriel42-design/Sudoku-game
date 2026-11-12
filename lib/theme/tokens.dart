/// Tokens de design. Ajuste as cores e medidas aqui; as telas só leem daqui.
library;

import 'package:material_ui/material_ui.dart';

/// Paleta de um tema.
class UmiPalette {
  final Color background; // fundo principal
  final Color board; // fundo do tabuleiro
  final Color surface; // cards, cabeçalhos e região destacada
  final Color success; // acertos, dicas, conquistas desbloqueadas
  final Color ink; // textos, linhas e pistas
  final Color accent; // botões e seleção
  final Color userDigit; // números colocados pelo jogador
  final Color error; // fundo de alerta (com moderação)
  final Color wrongDigit; // número errado
  final Brightness brightness;

  const UmiPalette({
    required this.background,
    required this.board,
    required this.surface,
    required this.success,
    required this.ink,
    required this.accent,
    required this.userDigit,
    required this.error,
    required this.wrongDigit,
    required this.brightness,
  });

  /// Tema padrão: Umi (névoa do mar).
  static const umi = UmiPalette(
    background: Color(0xFFF3EBDD), // areia
    board: Color(0xFFFBF7EE),
    surface: Color(0xFFDCE8F0), // azul-névoa
    success: Color(0xFFCFE3D6), // verde-chá
    ink: Color(0xFF4A5968), // grafite suave
    accent: Color(0xFF7FA7C4), // azul-profundo suave
    userDigit: Color(0xFF3E78A6),
    error: Color(0xFFE8A598), // coral suave
    wrongDigit: Color(0xFFC96A5A),
    brightness: Brightness.light,
  );

  /// Tema alternativo: Sakura.
  static const sakura = UmiPalette(
    background: Color(0xFFFBF7F4), // off-white quente
    board: Color(0xFFFFFCFA),
    surface: Color(0xFFF4D6DC), // rosa-pétala
    success: Color(0xFFDDE8D8),
    ink: Color(0xFF6B5B6E), // cinza-ameixa
    accent: Color(0xFFD9A3B0),
    userDigit: Color(0xFFB0607A),
    error: Color(0xFFE8A598),
    wrongDigit: Color(0xFFC96A5A),
    brightness: Brightness.light,
  );

  /// Tema escuro: tinta suave, nunca preto puro.
  static const dark = UmiPalette(
    background: Color(0xFF1F2A33),
    board: Color(0xFF25323D),
    surface: Color(0xFF2B3A46),
    success: Color(0xFF3F5A4E),
    ink: Color(0xFFDCE8F0),
    accent: Color(0xFF7FA7C4),
    userDigit: Color(0xFF9CC4E0),
    error: Color(0xFFE8A598),
    wrongDigit: Color(0xFFF0A898),
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
    primary: p.userDigit,
    onSurface: p.ink,
    error: p.wrongDigit,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.background,
    appBarTheme: AppBarTheme(
      backgroundColor: p.background,
      foregroundColor: p.ink,
      elevation: 0,
    ),
  );
}
