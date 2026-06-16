/// Typography system for Vyaas AI
/// Uses Outfit for display/headings, Inter for body
library typography;

import 'package:flutter/material.dart';
import 'app_colors.dart';

// Outfit font
const String _outfitFont = 'Outfit';
// Inter font
const String _interFont = 'Inter';

/// Returns TextTheme with Outfit + Inter
TextTheme vyaasTextTheme({bool dark = true}) {
  final base = dark ? Typography.material2021().white : Typography.material2021().black;
  
  return base.copyWith(
    displayLarge: base.displayLarge?.copyWith(
      fontFamily: _outfitFont,
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    displayMedium: base.displayMedium?.copyWith(
      fontFamily: _outfitFont,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    displaySmall: base.displaySmall?.copyWith(
      fontFamily: _outfitFont,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    headlineMedium: base.headlineMedium?.copyWith(
      fontFamily: _outfitFont,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleMedium: base.titleMedium?.copyWith(
      fontFamily: _outfitFont,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    bodyLarge: base.bodyLarge?.copyWith(
      fontFamily: _interFont,
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    bodyMedium: base.bodyMedium?.copyWith(
      fontFamily: _interFont,
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: AppColors.textSecondary,
    ),
    labelSmall: base.labelSmall?.copyWith(
      fontFamily: _interFont,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
  );
}