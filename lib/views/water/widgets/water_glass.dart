import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:mealio/core/theme/app_colors.dart';

/// Animated glass that fills with water (two waves + bubbles). level: 0..1.
/// Works at any size (details scale down for small glasses).
class WaterGlass extends StatefulWidget {
  final double level;
  final double width;
  final double height;
  const WaterGlass({
    super.key,
    required this.level,
    this.width = 140,
    this.height = 180,
  });

  @override
  State<WaterGlass> createState() => _WaterGlassState();
}

class _WaterGlassState extends State<WaterGlass>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: widget.level.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, level, _) => AnimatedBuilder(
          animation: _wave,
          builder: (context, _) => CustomPaint(
            size: Size(widget.width, widget.height),
            painter: _GlassPainter(level: level, phase: _wave.value),
          ),
        ),
      ),
    );
  }
}

class _GlassPainter extends CustomPainter {
  final double level;
  final double phase;
  _GlassPainter({required this.level, required this.phase});

  Path _glass(Size s, double r) {
    final w = s.width, h = s.height;
    return Path()
      ..moveTo(w * 0.06, 0)
      ..lineTo(w * 0.94, 0)
      ..lineTo(w * 0.84, h - r)
      ..quadraticBezierTo(w * 0.83, h, w * 0.70, h)
      ..lineTo(w * 0.30, h)
      ..quadraticBezierTo(w * 0.17, h, w * 0.16, h - r)
      ..close();
  }

  Path _wavePath(double w, double h, double top, double amp, double ph) {
    final p = Path()
      ..moveTo(0, h)
      ..lineTo(0, top);
    for (double x = 0; x <= w; x += 2) {
      p.lineTo(
        x,
        top + math.sin((x / w) * 2 * math.pi + ph * 2 * math.pi) * amp,
      );
    }
    p
      ..lineTo(w, h)
      ..close();
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final k = (w / 140).clamp(0.4, 1.6); // detail scale
    final glass = _glass(size, (h * 0.06).clamp(4.0, 14.0));

    // Glass body tint
    canvas.drawPath(glass, Paint()..color = const Color(0x143B8FD9));

    if (level > 0) {
      final water = h * level;
      final top = h - water;
      final amp = level >= 1 ? 0.8 * k : 6.0 * k;

      canvas.save();
      canvas.clipPath(glass);

      // Back wave
      canvas.drawPath(
        _wavePath(w, h, top, amp * 0.8, phase + 0.5),
        Paint()..color = const Color(0x806BB8F2),
      );
      // Front wave
      canvas.drawPath(
        _wavePath(w, h, top, amp, phase),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.waterLight, AppColors.water],
          ).createShader(Rect.fromLTWH(0, top - amp, w, water + amp)),
      );
      // Bubbles (skipped on tiny glasses)
      if (level > 0.08 && w >= 60) {
        for (var i = 0; i < 5; i++) {
          final t = (phase + i * 0.2) % 1.0;
          final bx =
              w * (0.30 + 0.10 * i) + math.sin(t * 2 * math.pi + i) * 4 * k;
          final by = h - t * water;
          canvas.drawCircle(
            Offset(bx, by),
            (1.5 + (i % 3)) * k,
            Paint()..color = const Color(0x66FFFFFF),
          );
        }
      }
      canvas.restore();
    }

    // Outline
    canvas.drawPath(
      glass,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (3 * k).clamp(1.6, 3.5)
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF9CCBF2),
    );
    // Highlight
    canvas.drawLine(
      Offset(w * 0.15, h * 0.10),
      Offset(w * 0.22, h * 0.78),
      Paint()
        ..color = const Color(0x66FFFFFF)
        ..strokeWidth = (4 * k).clamp(1.8, 5.0)
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GlassPainter old) =>
      old.level != level || old.phase != phase;
}
