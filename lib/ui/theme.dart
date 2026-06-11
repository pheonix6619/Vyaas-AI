import 'package:flutter/material.dart';
import '../providers/provider_manager.dart';

class AppColors {
  static ThemePalette currentPalette = ThemePalette.midnightNavy;

  static Color get obsidianBackground {
    switch (currentPalette) {
      case ThemePalette.nordicForest:
        return const Color(0xFF0B0F0C); // Deep near-black forest green
      case ThemePalette.midnightNavy:
        return const Color(0xFF090B11); // Deep midnight space navy
    }
  }

  static Color get slateCard {
    switch (currentPalette) {
      case ThemePalette.nordicForest:
        return const Color(0xFF161D18); // Dark spruce/slate green
      case ThemePalette.midnightNavy:
        return const Color(0xFF131824); // Rich dark navy
    }
  }

  static Color get accentIndigo {
    switch (currentPalette) {
      case ThemePalette.nordicForest:
        return const Color(0xFF10B981); // Fresh mint green
      case ThemePalette.midnightNavy:
        return const Color(0xFF2563EB); // Intense cobalt blue
    }
  }

  static Color get accentPurple {
    switch (currentPalette) {
      case ThemePalette.nordicForest:
        return const Color(0xFF34D399); // Soft sage green
      case ThemePalette.midnightNavy:
        return const Color(0xFFF43F5E); // Vibrant coral red
    }
  }
  
  static const Color successGreen = Color(0xFF10B981); // hsl(150, 80%, 38%)
  static const Color warningAmber = Color(0xFFF59E0B); // hsl(38, 92%, 50%)
  static const Color errorRed = Color(0xFFEF4444); // hsl(0, 84%, 60%)
  
  static const Color textPrimary = Color(0xFFF3F4F6); // Slate 100
  static const Color textSecondary = Color(0xFF9CA3AF); // Slate 400
  static const Color borderTransparent = Color(0x15FFFFFF); // 1px translucent border
  
  static LinearGradient get accentGradient => LinearGradient(
    colors: [accentIndigo, accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: Material(
        color: AppColors.slateCard.withValues(alpha: 0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(color: AppColors.borderTransparent),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}

ThemeData getDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.obsidianBackground,
    primaryColor: AppColors.accentIndigo,
    colorScheme: ColorScheme.dark(
      primary: AppColors.accentIndigo,
      secondary: AppColors.accentPurple,
      surface: AppColors.slateCard,
      error: AppColors.errorRed,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.02),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderTransparent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderTransparent),
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
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
      backgroundColor: AppColors.obsidianBackground,
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
    textTheme: const TextTheme(
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
