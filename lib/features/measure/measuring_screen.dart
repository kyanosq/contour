import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../api/measure_api.dart';
import '../../app/measure_flow.dart';
import '../../app/session.dart';
import '../../design/glass.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../l10n/app_localizations.dart';

class MeasuringScreen extends StatefulWidget {
  const MeasuringScreen({super.key});

  @override
  State<MeasuringScreen> createState() => _MeasuringScreenState();
}

class _MeasuringScreenState extends State<MeasuringScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  Timer? _phaseTimer;
  int _phase = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _phaseTimer = Timer.periodic(const Duration(milliseconds: 1600), (_) {
      if (mounted && _error == null) setState(() => _phase = (_phase + 1) % 3);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  Future<void> _measure() async {
    final flow = context.read<MeasureFlow>();
    final session = context.read<Session>();
    setState(() => _error = null);
    if (!flow.readyToMeasure) {
      // Deep-linked or state lost — return to the funnel start.
      context.go('/subject');
      return;
    }
    try {
      final result = await session.api.measure(
        subject: flow.subject,
        frontJpeg: flow.frontJpeg!,
        sideJpeg: flow.sideJpeg!,
        captureMetadata: flow.captureMetadata.views.isEmpty
            ? null
            : {'views': flow.captureMetadata.views},
        deviceInfo: flow.deviceInfo,
      );
      flow.setResult(result);
      if (mounted) context.pushReplacement('/results');
    } on ApiFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    _phaseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final phases = [l.measuringPhase1, l.measuringPhase2, l.measuringPhase3];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sp.x8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error == null) ...[
                  Center(
                    child: GlassPanel(
                      radius: 130,
                      padding: const EdgeInsets.all(Sp.x8),
                      child: SizedBox(
                        width: 168,
                        height: 168,
                        child: AnimatedBuilder(
                          animation: _spin,
                          builder: (context, _) => CustomPaint(
                            painter: _MeasuringRingPainter(
                              t: _spin.value,
                              ink: scheme.onSurfaceVariant,
                              accent: accentOf(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: Sp.x8),
                  Text(
                    l.measuringTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: Sp.x3),
                  AnimatedSwitcher(
                    duration: Motion.standard,
                    child: Text(
                      phases[_phase],
                      key: ValueKey(_phase),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.cloud_off_rounded,
                    size: 44,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: Sp.x5),
                  Text(
                    l.measuringFailed,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: Sp.x2),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: Sp.x8),
                  AccentButton(
                    label: l.measuringRetry,
                    icon: Icons.refresh_rounded,
                    onPressed: _measure,
                  ),
                  const SizedBox(height: Sp.x3),
                  ThreadButton(
                    label: l.commonBack,
                    onPressed: () => context.pop(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The measuring instrument: a magnified spirit-level / coiled tape.
/// Static graduated dial + counter-rotating chalk tape + comet sweep with
/// glow + breathing chalk core. Same visual language as the capture ring.
class _MeasuringRingPainter extends CustomPainter {
  _MeasuringRingPainter({
    required this.t,
    required this.ink,
    required this.accent,
  });

  final double t;
  final Color ink;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = min(size.width, size.height) / 2 - 8;

    // Outer graduated dial (static).
    final tickPaint = Paint()
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    const n = 60;
    for (var i = 0; i < n; i++) {
      final a = 2 * pi * i / n;
      final major = i % 5 == 0;
      final inner = c + Offset.fromDirection(a, r - (major ? 14 : 8));
      final outer = c + Offset.fromDirection(a, r);
      tickPaint.color = ink.withValues(alpha: major ? 0.8 : 0.4);
      canvas.drawLine(inner, outer, tickPaint);
    }

    // Counter-rotating chalk ticks: radial marks drifting the other way —
    // the tape being drawn around the body.
    final tape = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = accent.withValues(alpha: 0.55);
    const dashes = 18;
    for (var i = 0; i < dashes; i++) {
      final a = 2 * pi * i / dashes - 2 * pi * t * 0.5;
      canvas.drawLine(
        c + Offset.fromDirection(a, r - 36),
        c + Offset.fromDirection(a, r - 27),
        tape,
      );
    }

    // Comet sweep — glow pass beneath the crisp pass.
    final arcRect = Rect.fromCircle(center: c, radius: r - 21);
    Shader sweepShader() => SweepGradient(
          startAngle: 0,
          endAngle: 2 * pi,
          transform: GradientRotation(2 * pi * t),
          colors: [accent.withValues(alpha: 0), accent],
          stops: const [0.62, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawArc(
      arcRect,
      2 * pi * t,
      pi * 1.25,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..shader = sweepShader()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawArc(
      arcRect,
      2 * pi * t,
      pi * 1.25,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..shader = sweepShader(),
    );

    // Breathing chalk core (2 pulses per revolution).
    final pulse = 0.5 + 0.5 * sin(4 * pi * t);
    canvas.drawCircle(
      c,
      9 + 4 * pulse,
      Paint()
        ..color = accent.withValues(alpha: 0.25 + 0.22 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(c, 4, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(_MeasuringRingPainter old) => old.t != t;
}
