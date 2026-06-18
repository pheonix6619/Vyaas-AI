import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'app_colors.dart';

class AtsRadialGauge extends StatelessWidget {
  final double score;
  final double size;
  final String? title;
  final bool animate;

  const AtsRadialGauge({
    super.key,
    required this.score,
    this.size = 160.0,
    this.title,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (score / 100).clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadialGaugePainter(
          progress: progress,
          score: score,
          animate: animate,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              Text(
                '${score.round()}%',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadialGaugePainter extends CustomPainter {
  final double progress;
  final double score;
  final bool animate;
  
  _RadialGaugePainter({
    required this.progress,
    required this.score,
    this.animate = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 4;
    
    // Background circle
    final bgPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, bgPaint);
    
    // Gradient progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      colors: [
        AppColors.accentPrimary,
        AppColors.accentSecondary,
        AppColors.accentPrimary,
      ],
      stops: const [0.0, 0.8, 1.0],
      transform: GradientRotation(math.pi * -0.5),
    );
    
    final fgPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;
    
    // Animation controller (would be managed externally for production)
    final sweepAngle = math.pi * 2 * progress;
    canvas.drawArc(rect, math.pi * -0.5, sweepAngle, false, fgPaint);
    
    // Magenta overflow marker if score > 85
    if (score > 85) {
      final overflowAngle = math.pi * 2 * ((score - 85).clamp(0.0, 15) / 15);
      final overflowPaint = Paint()
        ..color = AppColors.accentSecondary
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4;
      canvas.drawArc(
        rect.deflate(6),
        math.pi * -0.5 + sweepAngle,
        overflowAngle,
        false,
        overflowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadialGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.score != score;
  }
}