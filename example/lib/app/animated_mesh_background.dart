import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnimatedMeshBackground extends StatelessWidget {
  const AnimatedMeshBackground({
    required this.seedColor,
    required this.isDark,
    super.key,
  });

  final Color seedColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final baseColor =
        isDark ? const Color(0xFF0D0D0D) : const Color(0xFFFAFAFA);

    return RepeatingAnimationBuilder<double>(
      duration: const Duration(seconds: 35),
      animatable: Tween<double>(begin: 0, end: math.pi * 2),
      builder: (context, phase, _) {
        return CustomPaint(
          painter: _AnimatedMeshPainter(
            seedColor: seedColor,
            phase: phase,
            baseColor: baseColor,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _AnimatedMeshPainter extends CustomPainter {
  _AnimatedMeshPainter({
    required this.seedColor,
    required this.phase,
    required this.baseColor,
  });

  final Color seedColor;
  final double phase;
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [seedColor.withValues(alpha: 0.04), Colors.transparent],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width / 2 + (math.cos(phase) * 100),
            size.height / 3 + (math.sin(phase) * 50),
          ),
          radius: 500,
        ),
      );

    canvas
      ..drawRect(Offset.zero & size, Paint()..color = baseColor)
      ..drawCircle(
        Offset(
          size.width / 2 + math.cos(phase) * 100,
          size.height / 3 + math.sin(phase) * 50,
        ),
        500,
        paint,
      );
  }

  @override
  bool shouldRepaint(covariant _AnimatedMeshPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.seedColor != seedColor ||
      oldDelegate.baseColor != baseColor;
}
