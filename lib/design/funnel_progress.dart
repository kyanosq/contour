import 'package:flutter/material.dart';

import 'tick_ruler.dart';
import 'tokens.dart';

/// Funnel step indicator: "01 · 被测人" over a highlighted tick band.
class FunnelProgress extends StatelessWidget {
  const FunnelProgress({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.label,
  });

  final int step;
  final int totalSteps;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              step.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFeatures: Numerals.features,
                color: accentOf(context),
                letterSpacing: 1,
              ),
            ),
            Text(
              ' / ${totalSteps.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFeatures: Numerals.features,
                color: scheme.onSurfaceVariant,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: Sp.x2),
            Text(
              '·  $label',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: Sp.x2),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: step / totalSteps),
          duration: Motion.emphasized,
          curve: Motion.easeOut,
          builder: (context, v, _) => TickRuler(
            height: 12,
            highlightFraction: v,
            highlightColor: accentOf(context),
          ),
        ),
      ],
    );
  }
}
