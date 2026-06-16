// lib/theme/prism_theme.dart
import 'package:flutter/material.dart';
import '../ui/theme_palette.dart';

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

  static PrismTheme dark() => PrismTheme.fromPalette(ThemePalette.midnightNavy, true);

  static PrismTheme light() => PrismTheme.fromPalette(ThemePalette.midnightNavy, false);

  static PrismTheme fromPalette(ThemePalette palette, bool isDark) {
    // Base colors for each palette
    Color accentIndigo;
    Color accentAmber;
    Color accentRose;
    Color accentMint;
    Color backgroundLayer1;
    Color backgroundLayer2;
    LinearGradient backgroundGradient;
    Color glassBase;
    Color glassBorder;
    Color textPrimary;
    Color textSecondary;

    if (palette == ThemePalette.nordicForest) {
      // Nordic Forest palette
      accentIndigo = const Color(0xFF10B981); // mint green
      accentAmber = const Color(0xFFFFA030);
      accentRose = const Color(0xFF34D399); // sage
      accentMint = const Color(0xFF40C4AA);
      if (isDark) {
        backgroundLayer1 = const Color(0xFF0B1F40);
        backgroundLayer2 = const Color(0xFF1A3C2E);
        backgroundGradient = const LinearGradient(
          colors: [Color(0xFF0B1F40), Color(0xFF1A3C2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        glassBase = const Color(0xFF090B11).withOpacity(0.12);
        glassBorder = const Color(0xFFCBD5E0).withOpacity(0.3);
        textPrimary = const Color(0xFFF3F4F6);
        textSecondary = const Color(0xFF9CA3AF);
      } else {
        backgroundLayer1 = const Color(0xFF85C1FF);
        backgroundLayer2 = const Color(0xFFA8E6CF);
        backgroundGradient = const LinearGradient(
          colors: [Color(0xFF85C1FF), Color(0xFFA8E6CF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        glassBase = Colors.white.withOpacity(0.15);
        glassBorder = Colors.white.withOpacity(0.5);
        textPrimary = const Color(0xFF0A0F1C);
        textSecondary = const Color(0xFF4A5568);
      }
    } else {
      // Midnight Navy palette (default)
      accentIndigo = const Color(0xFF2563EB);
      accentAmber = const Color(0xFFFFA030);
      accentRose = const Color(0xFFFF5C6D);
      accentMint = const Color(0xFF40C4AA);
      if (isDark) {
        backgroundLayer1 = const Color(0xFF0B1F40);
        backgroundLayer2 = const Color(0xFF3B2480);
        backgroundGradient = const LinearGradient(
          colors: [Color(0xFF0B1F40), Color(0xFF3B2480)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        glassBase = const Color(0xFF090B11).withOpacity(0.12);
        glassBorder = const Color(0xFFCBD5E0).withOpacity(0.3);
        textPrimary = const Color(0xFFF3F4F6);
        textSecondary = const Color(0xFF9CA3AF);
      } else {
        backgroundLayer1 = const Color(0xFF85C1FF);
        backgroundLayer2 = const Color(0xFFFFC0CB);
        backgroundGradient = const LinearGradient(
          colors: [Color(0xFF85C1FF), Color(0xFFFFC0CB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        glassBase = Colors.white.withOpacity(0.15);
        glassBorder = Colors.white.withOpacity(0.5);
        textPrimary = const Color(0xFF0A0F1C);
        textSecondary = const Color(0xFF4A5568);
      }
    }

    return PrismTheme._(
      isDark: isDark,
      glassBase: glassBase,
      glassBorder: glassBorder,
      backgroundLayer1: backgroundLayer1,
      backgroundLayer2: backgroundLayer2,
      backgroundGradient: backgroundGradient,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      accentIndigo: accentIndigo,
      accentAmber: accentAmber,
      accentRose: accentRose,
      accentMint: accentMint,
    );
  }

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