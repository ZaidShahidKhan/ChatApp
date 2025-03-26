import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaveAnimation extends StatefulWidget {
  final double height;
  final Color primaryColor;
  final Color secondaryColor;
  final double opacity;
  final double width;

  const WaveAnimation({
    Key? key,
    this.height = 100,
    this.width = 60,
    this.primaryColor = const Color(0xFF8A3FFC),
    this.secondaryColor = const Color(0xFF06CAFC),
    this.opacity = 1.0,
  }) : super(key: key);

  @override
  State<WaveAnimation> createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<WaveAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.opacity,
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.width, widget.height),
            painter: WaveformPainter(
              animation: _waveController,
              primaryColor: widget.primaryColor,
              secondaryColor: widget.secondaryColor,
            ),
          );
        },
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final Animation<double> animation;
  final Color primaryColor;
  final Color secondaryColor;

  WaveformPainter({
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final centerY = height / 2;

    // Main horizontal line
    final linePaint = Paint()
      ..color = primaryColor.withOpacity(0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0;

    final linearGradient = LinearGradient(
      colors: [
        primaryColor.withOpacity(0.3),
        primaryColor.withOpacity(0.8),
        primaryColor.withOpacity(0.3),
      ],
      stops: const [0.0, 0.5, 1.0],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final rect = Rect.fromLTWH(0, centerY - 1, width, 2);
    linePaint.shader = linearGradient.createShader(rect);

    canvas.drawLine(
      Offset(0, centerY),
      Offset(width, centerY),
      linePaint,
    );

    // Animated wave above the line - MODERATE OPACITY
    final wavePaint = Paint()
      ..color = secondaryColor.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final waveGradient = LinearGradient(
      colors: [
        secondaryColor.withOpacity(0.2),
        secondaryColor.withOpacity(0.6),
        secondaryColor.withOpacity(0.2),
      ],
      stops: const [0.0, 0.5, 1.0],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final waveRect = Rect.fromLTWH(0, centerY - 20, width, 40);
    wavePaint.shader = waveGradient.createShader(waveRect);

    final path = Path();
    path.moveTo(0, centerY - 10);

    for (double i = 0; i <= width; i++) {
      path.lineTo(
        i,
        centerY - 10 + math.sin((i * 0.05) - (animation.value * math.pi * 2)) * 10,
      );
    }

    canvas.drawPath(path, wavePaint);

    // Second wave - MODERATE OPACITY, SLIGHT BLUR
    final wavePaint2 = Paint()
      ..color = secondaryColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5); // Moderate blur

    final waveGradient2 = LinearGradient(
      colors: [
        secondaryColor.withOpacity(0.1),
        secondaryColor.withOpacity(0.4),
        secondaryColor.withOpacity(0.1),
      ],
      stops: const [0.0, 0.5, 1.0],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final waveRect2 = Rect.fromLTWH(0, centerY - 40, width, 80);
    wavePaint2.shader = waveGradient2.createShader(waveRect2);

    final path2 = Path();
    path2.moveTo(0, centerY - 20);

    for (double i = 0; i <= width; i++) {
      path2.lineTo(
        i,
        centerY - 20 + math.sin((i * 0.03) - ((animation.value + 0.5) * math.pi * 2)) * 20,
      );
    }

    canvas.drawPath(path2, wavePaint2);
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) => true;
}