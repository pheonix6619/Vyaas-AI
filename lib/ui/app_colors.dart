// lib/ui/app_colors.dart
import 'package:flutter/material.dart';
import 'theme_palette.dart';

/// Glass tile styling options for personalization.
enum GlassTileStyle { defaultTheme, accent, palette, neutral }

class AppColors {
  static ThemePalette currentPalette = ThemePalette.midnightNavy;
  static bool isDark = true;
  static GlassTileStyle glassTileStyle = GlassTileStyle.defaultTheme;
  static double glassOpacity = 0.6;

  // ─── Backgrounds ────────────────────────────────────────────────────────────
  static Color get obsidianBackground {
    if (!isDark) return const Color(0xFFF8FAFC); // Slate 50
    switch (currentPalette) {
      case ThemePalette.nordicForest:
        return const Color(0xFF0B0F0C);
      case ThemePalette.midnightNavy:
        return const Color(0xFF090B11);
      case ThemePalette.sunsetOrange:
      case ThemePalette.lavenderPurple:
      case ThemePalette.oceanTeal:
        return const Color(0xFF090B11);
    }
  }

  // ─── Card Surfaces ──────────────────────────────────────────────────────────
  static Color get slateCard {
    if (!isDark) {
      // Light mode: clean white/near-white surfaces
      switch (currentPalette) {
        case ThemePalette.nordicForest:
          return const Color(0xFFEDF7F0);
        case ThemePalette.midnightNavy:
          return const Color(0xFFEFF3FB);
        case ThemePalette.sunsetOrange:
          return const Color(0xFFFFF5EE);
        case ThemePalette.lavenderPurple:
          return const Color(0xFFF5EDFF);
        case ThemePalette.oceanTeal:
          return const Color(0xFFEDF8F7);
      }
    }
    switch (currentPalette) {
      case ThemePalette.nordicForest:
        return const Color(0xFF161D18);
      case ThemePalette.midnightNavy:
        return const Color(0xFF131824);
      case ThemePalette.sunsetOrange:
      case ThemePalette.lavenderPurple:
      case ThemePalette.oceanTeal:
        return const Color(0xFF131824);
    }
  }

  // ─── Accent Colors ─────────────────────────────────────────────────────────
  static Color get accentIndigo {
    switch (currentPalette) {
      case ThemePalette.nordicForest:
        return const Color(0xFF10B981);
      case ThemePalette.midnightNavy:
        return const Color(0xFF2563EB);
      case ThemePalette.sunsetOrange:
        return const Color(0xFFFF6B35);
      case ThemePalette.lavenderPurple:
        return const Color(0xFF9B59B6);
      case ThemePalette.oceanTeal:
        return const Color(0xFF009688);
    }
  }

  static Color get accentPurple {
    switch (currentPalette) {
      case ThemePalette.nordicForest:
        return const Color(0xFF34D399);
      case ThemePalette.midnightNavy:
        return const Color(0xFFF43F5E);
      case ThemePalette.sunsetOrange:
        return const Color(0xFFFF3B30);
      case ThemePalette.lavenderPurple:
        return const Color(0xFFE91E63);
      case ThemePalette.oceanTeal:
        return const Color(0xFF00BCD4);
    }
  }

  // ─── Semantic Colors ────────────────────────────────────────────────────────
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);

  // ─── Text Colors (theme-aware) ──────────────────────────────────────────────
  static Color get textPrimary =>
      isDark ? const Color(0xFFF3F4F6) : const Color(0xFF0F172A);

  static Color get textSecondary =>
      isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B);

  // ─── Borders (theme-aware) ──────────────────────────────────────────────────
  static Color get borderTransparent =>
      isDark ? const Color(0x15FFFFFF) : const Color(0x18000000);

  // ─── Gradients ─────────────────────────────────────────────────────────────
  static LinearGradient get accentGradient => LinearGradient(
    colors: [accentIndigo, accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Aliases ────────────────────────────────────────────────────────────────
  static Color get surface => slateCard;
  static Color get accentPrimary => accentIndigo;
  static Color get accentSecondary => accentPurple;

  // ─── Glass Tile Color ───────────────────────────────────────────────────────
  /// Returns the glass tile background tint based on the selected style.
  static Color get glassTileColor {
    // Base neutral glass color using user-chosen opacity (0.0 = fully transparent, 1.0 = fully opaque)
    final baseColor = isDark
        ? const Color(0xFF0F172A).withValues(alpha: glassOpacity) // Dark Slate base
        : const Color(0xFFFFFFFF).withValues(alpha: glassOpacity); // White base

    switch (glassTileStyle) {
      case GlassTileStyle.accent:
        // Blend a subtle 8% tint of accentIndigo over the base color
        return Color.alphaBlend(
          accentIndigo.withValues(alpha: 0.08),
          baseColor,
        );
      case GlassTileStyle.palette:
        // Blend a subtle 8% tint of accentPurple over the base color
        return Color.alphaBlend(
          accentPurple.withValues(alpha: 0.08),
          baseColor,
        );
      case GlassTileStyle.neutral:
        // Blend a subtle 4% tint of neutral slate over the base color
        return Color.alphaBlend(
          isDark
              ? const Color(0xFF1E293B).withValues(alpha: 0.04)
              : const Color(0xFFF1F5F9).withValues(alpha: 0.04),
          baseColor,
        );
      case GlassTileStyle.defaultTheme:
        // Blend a subtle 6% tint of the theme card color over the base color
        return Color.alphaBlend(
          slateCard.withValues(alpha: 0.06),
          baseColor,
        );
    }
  }
}