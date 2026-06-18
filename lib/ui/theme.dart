import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/provider_manager.dart';
import 'app_colors.dart';
import 'theme_palette.dart';
export 'app_colors.dart';
export 'theme_palette.dart';

class GlassCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(prismThemeProvider);
    return Container(
      width: width,
      height: height,
      child: Material(
        color: AppColors.glassTileColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: AppColors.borderTransparent),
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

ThemeData getLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.obsidianBackground,
    primaryColor: AppColors.accentIndigo,
    colorScheme: ColorScheme.light(
      primary: AppColors.accentIndigo,
      secondary: AppColors.accentPurple,
      surface: AppColors.slateCard,
      error: AppColors.errorRed,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.03),
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
