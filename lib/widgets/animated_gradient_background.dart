import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;

  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<AnimatedGradientBackground> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? const [
            Color(0xFF0F0F0F),
            Color(0xFF1A1010),
            Color(0xFF101A10),
            Color(0xFF0F0F0F),
          ]
        : const [
            Color(0xFFF8FAFC),
            Color(0xFFFEF2F2),
            Color(0xFFF0FDF4),
            Color(0xFFF8FAFC),
          ];

    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
        ),
        // Animated blobs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _BlobPainter(_controller.value, isDark: isDark),
              size: Size.infinite,
            );
          },
        ),
        // Content
        widget.child,
      ],
    );
  }
}

class _BlobPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _BlobPainter(this.progress, {this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final alphaMultiplier = isDark ? 1.6 : 1.0;

    final paint1 = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.05 * alphaMultiplier)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.04 * alphaMultiplier)
      ..style = PaintingStyle.fill;

    final x1 = size.width * (0.7 + 0.1 * math.sin(progress * 2 * math.pi));
    final y1 = size.height * (0.2 + 0.05 * math.cos(progress * 2 * math.pi));
    canvas.drawCircle(Offset(x1, y1), size.width * 0.25, paint1);

    final x2 = size.width * (0.3 + 0.08 * math.cos(progress * 2 * math.pi));
    final y2 = size.height * (0.7 + 0.06 * math.sin(progress * 2 * math.pi));
    canvas.drawCircle(Offset(x2, y2), size.width * 0.2, paint2);

    final paint3 = Paint()
      ..color = AppColors.info.withValues(alpha: 0.03 * alphaMultiplier)
      ..style = PaintingStyle.fill;
    final x3 = size.width * (0.5 + 0.12 * math.sin(progress * 2 * math.pi + 1));
    final y3 = size.height * (0.4 + 0.08 * math.cos(progress * 2 * math.pi + 1));
    canvas.drawCircle(Offset(x3, y3), size.width * 0.18, paint3);
  }

  @override
  bool shouldRepaint(_BlobPainter old) =>
      old.progress != progress || old.isDark != isDark;
}
