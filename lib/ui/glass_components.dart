// lib/ui/glass_components.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/prism_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double blurSigma;
  final double borderWidth;
  final double borderRadius;
  final Color? borderColorOverride;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.blurSigma = 16.0,
    this.borderWidth = 0.5,
    this.borderRadius = 16.0,
    this.borderColorOverride,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.prismTheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColorOverride ?? theme.glassBorder,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.glassBase,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class GlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;

  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.backgroundColor,
    this.borderColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.prismTheme;
    final bgColor = backgroundColor ?? theme.accentIndigo;
    
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: borderRadius,
      borderColorOverride: borderColor,
      blurSigma: 12.0,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          padding: padding,
          backgroundColor: bgColor.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          shadowColor: Colors.black26,
          elevation: elevation ?? 0,
        ),
        child: child,
      ),
    );
  }
}

class AnimatedGlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  
  const AnimatedGlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.backgroundColor,
  });
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: onPressed != null ? 1.0 : 0.9,
        duration: const Duration(milliseconds: 150),
        child: GlassButton(
          onPressed: onPressed,
          borderRadius: borderRadius,
          padding: padding,
          backgroundColor: backgroundColor,
          child: child,
        ),
      ),
    );
  }
}