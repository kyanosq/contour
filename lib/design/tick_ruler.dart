import 'package:flutter/material.dart';

/// The ruler-tick motif — Contour's decorative DNA.
///
/// A horizontal run of ticks: every [majorEvery]-th tick is tall, the rest
/// short. Used as section ornament, progress band, and inside the tape
/// pickers. Pure paint, no layout cost.
class TickRuler extends StatelessWidget {
  const TickRuler({
    super.key,
    this.height = 14,
    this.gap = 6,
    this.majorEvery = 5,
    this.color,
    this.highlightColor,
    this.highlightFraction,
  });

  final double height;
  final double gap;
  final int majorEvery;
  final Color? color;

  /// When set, ticks left of this 0..1 fraction use [highlightColor] —
  /// turning the ruler into a progress band.
  final double? highlightFraction;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final base = color ??
        Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.45);
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(double.infinity, height),
        painter: _TickPainter(
          base: base,
          gap: gap,
          majorEvery: majorEvery,
          highlight: highlightColor,
          highlightFraction: highlightFraction,
        ),
      ),
    );
  }
}

class _TickPainter extends CustomPainter {
  _TickPainter({
    required this.base,
    required this.gap,
    required this.majorEvery,
    this.highlight,
    this.highlightFraction,
  });

  final Color base;
  final double gap;
  final int majorEvery;
  final Color? highlight;
  final double? highlightFraction;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    final n = (size.width / gap).floor();
    final cutoff =
        highlightFraction == null ? -1.0 : size.width * highlightFraction!;
    for (var i = 0; i <= n; i++) {
      final x = i * gap;
      final major = i % majorEvery == 0;
      paint.color = (x <= cutoff && highlight != null) ? highlight! : base;
      final h = major ? size.height : size.height * 0.45;
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x, size.height - h),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_TickPainter old) =>
      old.base != base ||
      old.highlight != highlight ||
      old.highlightFraction != highlightFraction ||
      old.gap != gap ||
      old.majorEvery != majorEvery;
}
