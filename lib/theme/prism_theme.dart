// lib/theme/prism_theme.dart
import 'package:flutter/material.dart';

class PrismTheme {
  final bool isDark;
  final Color glassBase;
  final Color glassBorder;
  final Color backgroundLayer1;
  final Color backgroundLayer2;
  final Gradient backgroundGradient;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentIndigo;
  final Color accentAmber;
  final Color accentRose;
  final Color accentMint;

  PrismTheme._({
    required this.isDark,
    required this.glassBase,
    required this.glassBorder,
    required this.backgroundLayer1,
    required this.backgroundLayer2,
    required this.backgroundGradient,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentIndigo,
    required this.accentAmber,
    required this.accentRose,
    required this.accentMint,
  });

  static PrismTheme light() => PrismTheme._(
    isDark: false,
    glassBase: Colors.white.withOpacity(0.15),
    glassBorder: Colors.white.withOpacity(0.5),
    backgroundLayer1: const Color(0xFF85C1FF),
    backgroundLayer2: const Color(0xFFEC407A),
    backgroundGradient: const LinearGradient(
      colors: [Color(0xFF85C1FF), Color(0xFFFFC0CB)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    textPrimary: const Color(0xFF0A0F1C),
    textSecondary: const Color(0xFF4A5568),
    accentIndigo: const Color(0xFF1E4BB3),
    accentAmber: const Color(0xFFFFA030),
    accentRose: const Color(0xFFFF5C6D),
    accentMint: const Color(0xFF40C4AA),
  );

  static PrismTheme dark() => PrismTheme._(
    isDark: true,
    glassBase: const Color(0xFF090B11).withOpacity(0.12),
    glassBorder: const Color(0xFFCBD5E0).withOpacity(0.3),
    backgroundLayer1: const Color(0xFF0B1F40),
    backgroundLayer2: const Color(0xFF3B2480),
    backgroundGradient: const LinearGradient(
      colors: [Color(0xFF0B1F40), Color(0xFF3B2480)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    textPrimary: const Color(0xFFF3F4F6),
    textSecondary: const Color(0xFF9CA3AF),
    accentIndigo: const Color(0xFF2563EB),
    accentAmber: const Color(0xFFFFA030),
    accentRose: const Color(0xFFFF5C6D),
    accentMint: const Color(0xFF40C4AA),
  );

  ThemeData toThemeData() {
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentIndigo,
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: accentIndigo,
        secondary: accentAmber,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
      ),
    );
  }
}

// PrismTheme extension for BuildContext
extension PrismThemeX on BuildContext {
  PrismTheme get prismTheme {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark ? PrismTheme.dark() : PrismTheme.light();
  }
}