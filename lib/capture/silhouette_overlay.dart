import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design/tokens.dart';

/// Dashed pose-guide silhouettes for the capture screen. Stylized single-line
/// figures (front A-pose / side profile), drawn from normalized anchor points
/// smoothed into curves — crafted to read as "stand like this", not anatomy.
class SilhouetteOverlay extends StatelessWidget {
  const SilhouetteOverlay({
    super.key,
    required this.side,
    this.color = Colors.white,
    this.opacity = 0.55,
  });

  /// false → front A-pose, true → side profile.
  final bool side;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: CustomPaint(
          key: ValueKey(side),
          painter: _SilhouettePainter(
            side: side,
            color: color.withValues(alpha: opacity),
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  _SilhouettePainter({required this.side, required this.color});

  final bool side;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Figure box: centered, 76% of height, bottom at 90%.
    final h = size.height * 0.76;
    final w = h * 0.42;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.90 - h / 2),
      width: w,
      height: h,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..color = color;

    final path = side ? _sidePath(rect) : _frontPath(rect);
    _drawDashed(canvas, path, paint, dash: 9, gap: 7);

    // Head (solid thin circle reads better than dashes)
    final headPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = color;
    canvas.drawCircle(
      Offset(rect.left + rect.width * 0.5, rect.top + rect.height * 0.055),
      rect.height * 0.052,
      headPaint,
    );
  }

  Offset _pt(Rect r, double x, double y) =>
      Offset(r.left + r.width * x, r.top + r.height * y);

  /// Smooth polyline via quadratic midpoint technique.
  Path _smooth(Rect r, List<(double, double)> pts) {
    final path = Path();
    if (pts.isEmpty) return path;
    final p0 = _pt(r, pts.first.$1, pts.first.$2);
    path.moveTo(p0.dx, p0.dy);
    for (var i = 1; i < pts.length - 1; i++) {
      final a = _pt(r, pts[i].$1, pts[i].$2);
      final b = _pt(r, pts[i + 1].$1, pts[i + 1].$2);
      final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
      path.quadraticBezierTo(a.dx, a.dy, mid.dx, mid.dy);
    }
    final last = _pt(r, pts.last.$1, pts.last.$2);
    path.lineTo(last.dx, last.dy);
    return path;
  }

  Path _frontPath(Rect r) {
    final path = Path();
    // Left half (mirrored for right). A-pose: arms out ~30°, feet apart.
    final left = <(double, double)>[
      (0.44, 0.115), // neck left
      (0.30, 0.165), // shoulder
      (0.20, 0.30), // elbow (out)
      (0.115, 0.435), // wrist
      (0.10, 0.475), // hand tip
      (0.175, 0.49), // hand inner
      (0.265, 0.36), // forearm inner
      (0.315, 0.27), // armpit
      (0.315, 0.42), // waist
      (0.28, 0.55), // hip out
      (0.30, 0.72), // knee
      (0.315, 0.875), // ankle
      (0.27, 0.925), // foot toe
      (0.40, 0.925), // foot inner
      (0.425, 0.875), // ankle inner
      (0.435, 0.72), // knee inner
      (0.50, 0.575), // crotch
    ];
    final right = [for (final p in left.reversed) (1 - p.$1, p.$2)];
    path.addPath(_smooth(r, [...left, ...right]), Offset.zero);
    return path;
  }

  Path _sidePath(Rect r) {
    final path = Path();
    // Profile facing right: back line down, foot, front line up.
    final outline = <(double, double)>[
      (0.46, 0.115), // nape
      (0.38, 0.20), // upper back
      (0.36, 0.33), // mid back
      (0.40, 0.47), // lumbar
      (0.435, 0.545), // seat
      (0.415, 0.62), // under seat
      (0.42, 0.75), // calf back
      (0.415, 0.875), // heel top
      (0.40, 0.925), // heel
      (0.62, 0.925), // toe
      (0.60, 0.86), // instep
      (0.575, 0.72), // shin
      (0.585, 0.60), // knee front
      (0.60, 0.50), // front hip
      (0.635, 0.40), // belly
      (0.625, 0.28), // chest
      (0.575, 0.185), // upper chest
      (0.555, 0.125), // chin base
    ];
    path.addPath(_smooth(r, outline), Offset.zero);
    // Arm (hangs slightly forward)
    final arm = <(double, double)>[
      (0.50, 0.20), // shoulder
      (0.52, 0.32), // elbow
      (0.545, 0.44), // wrist
      (0.55, 0.485), // hand
    ];
    path.addPath(_smooth(r, arm), Offset.zero);
    return path;
  }

  void _drawDashed(
    Canvas canvas,
    Path source,
    Paint paint, {
    required double dash,
    required double gap,
  }) {
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_SilhouettePainter old) =>
      old.side != side || old.color != color;
}

/// The spirit-level ring: bubble + rotating chalk horizon (roll) + animated
/// nudge arrow (pitch/roll direction), with a snap pulse when it locks level.
class LevelRing extends StatefulWidget {
  const LevelRing({
    super.key,
    required this.dx,
    required this.dy,
    required this.level,
    this.rollDeg = 0,
    this.radius = 36,
  });

  final double dx;
  final double dy;
  final bool level;

  /// Left/right tilt in degrees — drives the horizon line.
  final double rollDeg;
  final double radius;

  @override
  State<LevelRing> createState() => _LevelRingState();
}

class _LevelRingState extends State<LevelRing> with TickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);
  late final AnimationController _snap = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void didUpdateWidget(covariant LevelRing old) {
    super.didUpdateWidget(old);
    if (!old.level && widget.level) {
      _snap.forward(from: 0); // lock-in pulse
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    _snap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.radius;
    const accent = Atelier.accentBright;
    final ringColor = widget.level
        ? accent
        : Colors.white.withValues(alpha: 0.85);
    return SizedBox(
      width: radius * 2 + 24,
      height: radius * 2 + 24,
      child: AnimatedBuilder(
        animation: Listenable.merge([_breath, _snap]),
        builder: (context, _) {
          final snapScale = 1 + 0.10 * math.sin(math.pi * _snap.value);
          return Transform.scale(
            scale: snapScale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size.square(radius * 2),
                  painter: _RingPainter(
                    color: ringColor,
                    level: widget.level,
                    rollDeg: widget.rollDeg,
                    bubble: Offset(widget.dx, widget.dy),
                    breath: _breath.value,
                  ),
                ),
                // bubble
                AnimatedContainer(
                  duration: const Duration(milliseconds: 90),
                  curve: Curves.linear,
                  transform: Matrix4.translationValues(
                    widget.dx * (radius - 9),
                    widget.dy * (radius - 9),
                    0,
                  ),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.level ? accent : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: widget.level
                            ? accent.withValues(alpha: 0.55)
                            : Colors.black.withValues(alpha: 0.35),
                        blurRadius: widget.level ? 12 : 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.color,
    required this.level,
    required this.rollDeg,
    required this.bubble,
    required this.breath,
  });

  final Color color;
  final bool level;
  final double rollDeg;

  /// Normalized bubble offset (-1..1 per axis).
  final Offset bubble;

  /// 0..1 oscillation for the nudge arrow.
  final double breath;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = level ? 2.4 : 1.6
      ..color = color;
    canvas.drawCircle(c, r, ring);

    // 4 cardinal ticks — the "gauge" character
    final tick = Paint()
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = color;
    for (final a in [0.0, 90.0, 180.0, 270.0]) {
      final rad = a * math.pi / 180;
      final dir = Offset.fromDirection(rad, r);
      canvas.drawLine(c + dir * ((r - 6) / r), c + dir, tick);
    }

    // Chalk horizon — rotates with roll, snaps flat + bright when level.
    // Fixed reference wings just outside the ring show "flat".
    final wing = Paint()
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.5);
    canvas.drawLine(
      Offset(c.dx - r - 12, c.dy),
      Offset(c.dx - r - 3, c.dy),
      wing,
    );
    canvas.drawLine(
      Offset(c.dx + r + 3, c.dy),
      Offset(c.dx + r + 12, c.dy),
      wing,
    );
    final horizonAngle = level ? 0.0 : rollDeg * math.pi / 180;
    final half = Offset.fromDirection(horizonAngle, r * 0.68);
    final horizon = Paint()
      ..strokeWidth = level ? 2.6 : 1.8
      ..strokeCap = StrokeCap.round
      ..color = level ? Atelier.accentBright : color.withValues(alpha: 0.9);
    if (level) {
      horizon.maskFilter = const MaskFilter.blur(BlurStyle.solid, 3);
    }
    canvas.drawLine(c - half, c + half, horizon);

    // Nudge arrow: from the bubble toward center, breathing — "push it home".
    if (!level && bubble.distance > 0.3) {
      final dirToCenter = -bubble / bubble.distance;
      final base =
          c +
          Offset(bubble.dx, bubble.dy) * (r - 9) +
          dirToCenter * (14 + 4 * breath);
      final tip = base + dirToCenter * 12;
      final ortho = Offset(-dirToCenter.dy, dirToCenter.dx);
      final arrow = Paint()
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.35 + 0.45 * breath);
      canvas.drawLine(tip, tip - dirToCenter * 7 + ortho * 5, arrow);
      canvas.drawLine(tip, tip - dirToCenter * 7 - ortho * 5, arrow);
      canvas.drawLine(base, tip, arrow);
    }

    // inner target circle
    canvas.drawCircle(
      c,
      9,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: 0.5),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.color != color ||
      old.level != level ||
      old.rollDeg != rollDeg ||
      old.bubble != bubble ||
      old.breath != breath;
}
