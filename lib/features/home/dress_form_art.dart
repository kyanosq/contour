import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../design/tokens.dart';

/// The Contour hero: a tailor's dress form drawn as a single measured
/// line, with accent measuring bands at bust / waist / hip. Animates in by
/// tracing the path (draw-in), like chalk on wool.
class DressFormArt extends StatefulWidget {
  const DressFormArt({
    super.key,
    this.animate = true,
    this.bandLabels = const [],
  });

  final bool animate;

  /// Optional labels rendered next to the three measuring bands
  /// (bust, waist, hip) — top to bottom.
  final List<String> bandLabels;

  @override
  State<DressFormArt> createState() => _DressFormArtState();
}

class _DressFormArtState extends State<DressFormArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _c.forward();
    } else {
      _c.value = 1;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => CustomPaint(
        painter: _DressFormPainter(
          progress: Curves.easeInOutCubic.transform(_c.value),
          ink: scheme.onSurface,
          accent: accentOf(context),
          thread: scheme.onSurfaceVariant,
          labels: widget.bandLabels,
        ),
      ),
    );
  }
}

class _DressFormPainter extends CustomPainter {
  _DressFormPainter({
    required this.progress,
    required this.ink,
    required this.accent,
    required this.thread,
    required this.labels,
  });

  final double progress;
  final Color ink;
  final Color accent;
  final Color thread;
  final List<String> labels;

  Offset _p(Size s, double x, double y) => Offset(s.width * x, s.height * y);

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..color = ink.withValues(alpha: 0.85);

    // ----- torso: symmetric silhouette of a dressmaker form -----
    final path = Path();
    // left side, from neck down
    path.moveTo(size.width * 0.435, size.height * 0.075);
    path.cubicTo(
      size.width * 0.435, size.height * 0.13,
      size.width * 0.40, size.height * 0.145,
      size.width * 0.315, size.height * 0.185, // shoulder
    );
    path.cubicTo(
      size.width * 0.245, size.height * 0.22,
      size.width * 0.235, size.height * 0.28,
      size.width * 0.245, size.height * 0.335, // bust
    );
    path.cubicTo(
      size.width * 0.255, size.height * 0.415,
      size.width * 0.305, size.height * 0.47,
      size.width * 0.315, size.height * 0.52, // waist pinch
    );
    path.cubicTo(
      size.width * 0.325, size.height * 0.585,
      size.width * 0.235, size.height * 0.63,
      size.width * 0.225, size.height * 0.72, // hip flare
    );
    path.cubicTo(
      size.width * 0.22, size.height * 0.775,
      size.width * 0.30, size.height * 0.815,
      size.width * 0.50, size.height * 0.815, // hem center
    );
    // right side (mirror)
    path.cubicTo(
      size.width * 0.70, size.height * 0.815,
      size.width * 0.78, size.height * 0.775,
      size.width * 0.775, size.height * 0.72,
    );
    path.cubicTo(
      size.width * 0.765, size.height * 0.63,
      size.width * 0.675, size.height * 0.585,
      size.width * 0.685, size.height * 0.52,
    );
    path.cubicTo(
      size.width * 0.695, size.height * 0.47,
      size.width * 0.745, size.height * 0.415,
      size.width * 0.755, size.height * 0.335,
    );
    path.cubicTo(
      size.width * 0.765, size.height * 0.28,
      size.width * 0.755, size.height * 0.22,
      size.width * 0.685, size.height * 0.185,
    );
    path.cubicTo(
      size.width * 0.60, size.height * 0.145,
      size.width * 0.565, size.height * 0.13,
      size.width * 0.565, size.height * 0.075,
    );
    // neck cap
    path.moveTo(size.width * 0.435, size.height * 0.075);
    path.cubicTo(
      size.width * 0.45, size.height * 0.045,
      size.width * 0.55, size.height * 0.045,
      size.width * 0.565, size.height * 0.075,
    );
    // stand: pole + foot
    path.moveTo(size.width * 0.5, size.height * 0.815);
    path.lineTo(size.width * 0.5, size.height * 0.945);
    path.moveTo(size.width * 0.36, size.height * 0.965);
    path.cubicTo(
      size.width * 0.42, size.height * 0.935,
      size.width * 0.58, size.height * 0.935,
      size.width * 0.64, size.height * 0.965,
    );

    // Trace-in animation.
    final metrics = path.computeMetrics().toList();
    final total = metrics.fold<double>(0, (a, m) => a + m.length);
    var remaining = total * progress;
    for (final m in metrics) {
      if (remaining <= 0) break;
      final take = remaining.clamp(0.0, m.length);
      canvas.drawPath(m.extractPath(0, take), line);
      remaining -= take;
    }

    // ----- measuring bands (appear after the form is mostly traced) -----
    final bandAlpha = ((progress - 0.72) / 0.28).clamp(0.0, 1.0);
    if (bandAlpha > 0) {
      final bands = <(double, double, double)>[
        (0.245, 0.755, 0.335), // bust:  xLeft, xRight, y
        (0.315, 0.685, 0.52), // waist
        (0.225, 0.775, 0.70), // hip
      ];
      final bandPaint = Paint()
        ..strokeWidth = 1.2
        ..color = accent.withValues(alpha: bandAlpha);
      final dot = Paint()..color = accent.withValues(alpha: bandAlpha);

      for (var i = 0; i < bands.length; i++) {
        final (x0, x1, y) = bands[i];
        final a = _p(size, x0, y);
        final b = _p(size, x1, y);
        canvas.drawLine(a, b, bandPaint);
        canvas.drawCircle(a, 2.4, dot);
        canvas.drawCircle(b, 2.4, dot);
        // small ruler ticks along the band
        final n = 8;
        for (var t = 1; t < n; t++) {
          final x = a.dx + (b.dx - a.dx) * t / n;
          canvas.drawLine(
            Offset(x, y * size.height - 2.5),
            Offset(x, y * size.height + 2.5),
            bandPaint..strokeWidth = 0.8,
          );
        }
        bandPaint.strokeWidth = 1.2;

        if (i < labels.length) {
          final tp = TextPainter(
            text: TextSpan(
              text: labels[i],
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w500,
                color: thread.withValues(alpha: bandAlpha),
              ),
            ),
            textDirection: ui.TextDirection.ltr,
          )..layout();
          tp.paint(
            canvas,
            Offset(b.dx + 8, b.dy - tp.height / 2),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_DressFormPainter old) =>
      old.progress != progress || old.ink != ink || old.accent != accent;
}
