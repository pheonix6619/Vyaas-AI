// lib/ui/app_colors.dart
import 'package:flutter/material.dart';
import 'theme_palette.dart';

class AppColors {
  static ThemePalette currentPalette = ThemePalette.midnightNavy;

  static Color get obsidianBackground {
    switch (currentPalette) {
      case ThemePalette.nordicForest:
        return const Color(0xFF0B0F0C); // Deep near-black forest green
      case ThemePalette.midnightNavy:
        return const Color(0xFF090B11); // Deep midnight space navy
      case ThemePalette.sunsetOrange:
      case ThemePalette.lavenderPurple:
      case ThemePalette.oceanTeal:
      default:
        return const Color(0xFF090B11);
    }
  }

  static Color get slateCard {
    switch (currentPalette) {
      case ThemePalette.nordicForest:
        return const Color(0xFF161D18); // Dark spruce/slate green
      case ThemePalette.midnightNavy:
        return const Color(0xFF131824); // Rich dark navy
      case ThemePalette.sunsetOrange:
      case ThemePalette.lavenderPurple:
      case ThemePalette.oceanTeal:
      default:
        return const Color(0xFF131824);
    }
  }

  static Color get accentIndigo {
    switch (currentPalette) {
      case ThemePalette.nordicForest:
        return const Color(0xFF10B981); // Fresh mint green
      case ThemePalette.midnightNavy:
        return const Color(0xFF2563EB); // Intense cobalt blue
      case ThemePalette.sunsetOrange:
        return const Color(0xFFFF6B35);
      case ThemePalette.lavenderPurple:
        return const Color(0xFF9B59B6);
      case ThemePalette.oceanTeal:
        return const Color(0xFF009688);
      default:
        return const Color(0xFF2563EB);
    }
  }

  static Color get accentPurple {
    switch (currentPalette) {
      case ThemePalette.nordicForest:
        return const Color(0xFF34D399); // Soft sage green
      case ThemePalette.midnightNavy:
        return const Color(0xFFF43F5E); // Vibrant coral red
      case ThemePalette.sunsetOrange:
        return const Color(0xFFFF3B30);
      case ThemePalette.lavenderPurple:
        return const Color(0xFFE91E63);
      case ThemePalette.oceanTeal:
        return const Color(0xFF00BCD4);
      default:
        return const Color(0xFFF43F5E);
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