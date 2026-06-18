// lib/theme/prism_theme.dart
import 'package:flutter/material.dart';
import '../ui/theme_palette.dart';
import '../ui/app_colors.dart';

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

    switch (palette) {
      case ThemePalette.nordicForest:
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
          glassBase = const Color(0xFF090B11).withValues(alpha: 0.12);
          glassBorder = const Color(0xFFCBD5E0).withValues(alpha: 0.3);
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
          glassBase = Colors.white.withValues(alpha: 0.15);
          glassBorder = Colors.black.withValues(alpha: 0.08);
          textPrimary = const Color(0xFF0A0F1C);
          textSecondary = const Color(0xFF4A5568);
        }
        break;
      case ThemePalette.sunsetOrange:
        // Sunset Orange palette
        accentIndigo = const Color(0xFFFF6B35); // orange
        accentAmber = const Color(0xFFFFA030);
        accentRose = const Color(0xFFFF3B30); // red
        accentMint = const Color(0xFF4CD964); // green
        if (isDark) {
          backgroundLayer1 = const Color(0xFF3B1F0B);
          backgroundLayer2 = const Color(0xFF6B2E0B);
          backgroundGradient = const LinearGradient(
            colors: [Color(0xFF3B1F0B), Color(0xFF6B2E0B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
          glassBase = const Color(0xFF090B11).withValues(alpha: 0.12);
          glassBorder = const Color(0xFFCBD5E0).withValues(alpha: 0.3);
          textPrimary = const Color(0xFFF3F4F6);
          textSecondary = const Color(0xFF9CA3AF);
        } else {
          backgroundLayer1 = const Color(0xFFFFB380);
          backgroundLayer2 = const Color(0xFFFFD1A8);
          backgroundGradient = const LinearGradient(
            colors: [Color(0xFFFFB380), Color(0xFFFFD1A8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
          glassBase = Colors.white.withValues(alpha: 0.15);
          glassBorder = Colors.black.withValues(alpha: 0.08);
          textPrimary = const Color(0xFF0A0F1C);
          textSecondary = const Color(0xFF4A5568);
        }
        break;
      case ThemePalette.lavenderPurple:
        // Lavender Purple palette
        accentIndigo = const Color(0xFF9B59B6); // purple
        accentAmber = const Color(0xFFFFA030);
        accentRose = const Color(0xFFE91E63); // pink
        accentMint = const Color(0xFF00BCD4); // cyan
        if (isDark) {
          backgroundLayer1 = const Color(0xFF1A0B3B);
          backgroundLayer2 = const Color(0xFF3B0B6B);
          backgroundGradient = const LinearGradient(
            colors: [Color(0xFF1A0B3B), Color(0xFF3B0B6B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
          glassBase = const Color(0xFF090B11).withValues(alpha: 0.12);
          glassBorder = const Color(0xFFCBD5E0).withValues(alpha: 0.3);
          textPrimary = const Color(0xFFF3F4F6);
          textSecondary = const Color(0xFF9CA3AF);
        } else {
          backgroundLayer1 = const Color(0xFFD1B3FF);
          backgroundLayer2 = const Color(0xFFE8D1FF);
          backgroundGradient = const LinearGradient(
            colors: [Color(0xFFD1B3FF), Color(0xFFE8D1FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
          glassBase = Colors.white.withValues(alpha: 0.15);
          glassBorder = Colors.black.withValues(alpha: 0.08);
          textPrimary = const Color(0xFF0A0F1C);
          textSecondary = const Color(0xFF4A5568);
        }
        break;
      case ThemePalette.oceanTeal:
        // Ocean Teal palette
        accentIndigo = const Color(0xFF009688); // teal
        accentAmber = const Color(0xFFFFA030);
        accentRose = const Color(0xFF00BCD4); // cyan
        accentMint = const Color(0xFF4CAF50); // green
        if (isDark) {
          backgroundLayer1 = const Color(0xFF0B2A3B);
          backgroundLayer2 = const Color(0xFF0B4A5B);
          backgroundGradient = const LinearGradient(
            colors: [Color(0xFF0B2A3B), Color(0xFF0B4A5B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
          glassBase = const Color(0xFF090B11).withValues(alpha: 0.12);
          glassBorder = const Color(0xFFCBD5E0).withValues(alpha: 0.3);
          textPrimary = const Color(0xFFF3F4F6);
          textSecondary = const Color(0xFF9CA3AF);
        } else {
          backgroundLayer1 = const Color(0xFF80E0D8);
          backgroundLayer2 = const Color(0xFFA8F0E8);
          backgroundGradient = const LinearGradient(
            colors: [Color(0xFF80E0D8), Color(0xFFA8F0E8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
          glassBase = Colors.white.withValues(alpha: 0.15);
          glassBorder = Colors.black.withValues(alpha: 0.08);
          textPrimary = const Color(0xFF0A0F1C);
          textSecondary = const Color(0xFF4A5568);
        }
        break;
      case ThemePalette.midnightNavy:
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
          glassBase = const Color(0xFF090B11).withValues(alpha: 0.12);
          glassBorder = const Color(0xFFCBD5E0).withValues(alpha: 0.3);
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
          glassBase = Colors.white.withValues(alpha: 0.15);
          glassBorder = Colors.black.withValues(alpha: 0.08);
          textPrimary = const Color(0xFF0A0F1C);
          textSecondary = const Color(0xFF4A5568);
        }
        break;
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
      scaffoldBackgroundColor: AppColors.obsidianBackground,
      primaryColor: AppColors.accentIndigo,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: AppColors.accentIndigo,
              secondary: AppColors.accentPurple,
              surface: AppColors.slateCard,
              error: AppColors.errorRed,
            )
          : ColorScheme.light(
              primary: AppColors.accentIndigo,
              secondary: AppColors.accentPurple,
              surface: AppColors.slateCard,
              error: AppColors.errorRed,
            ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.03),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderTransparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderTransparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accentIndigo, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
        labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.currentPalette == ThemePalette.nordicForest ? Colors.black : Colors.white,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      fontFamily: 'Inter',
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}

// PrismTheme extension for BuildContext
extension PrismThemeX on BuildContext {
  PrismTheme get prismTheme {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return PrismTheme.fromPalette(AppColors.currentPalette, isDark);
  }
}