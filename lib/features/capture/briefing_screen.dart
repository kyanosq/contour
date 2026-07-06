import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design/funnel_progress.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../l10n/app_localizations.dart';

class BriefingScreen extends StatelessWidget {
  const BriefingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final tips = [
      (Icons.checkroom_rounded, l.briefTip1),
      (Icons.crop_free_rounded, l.briefTip2),
      (Icons.accessibility_new_rounded, l.briefTip3),
      (Icons.stay_current_portrait_rounded, l.briefTip4),
      (Icons.light_mode_outlined, l.briefTip5),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.briefingTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.fromLTRB(Sp.x6, Sp.x2, Sp.x6, Sp.x6),
                children: [
                  FunnelProgress(
                      step: 2, totalSteps: 3, label: l.briefingTitle),
                  const SizedBox(height: Sp.x6),
                  Text(
                    l.briefingIntro,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: Sp.x6),
                  for (var i = 0; i < tips.length; i++) ...[
                    _TipRow(
                      index: i + 1,
                      icon: tips[i].$1,
                      text: tips[i].$2,
                    ),
                    if (i < tips.length - 1)
                      Padding(
                        padding: const EdgeInsets.only(left: 52),
                        child: Divider(color: scheme.outlineVariant),
                      ),
                  ],
                  const SizedBox(height: Sp.x6),
                  ContourCard(
                    padding: const EdgeInsets.all(Sp.x4),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded,
                            size: 20, color: accentOf(context)),
                        const SizedBox(width: Sp.x3),
                        Expanded(
                          child: Text(
                            l.briefingAuto,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Sp.x6, Sp.x2, Sp.x6, Sp.x4),
              child: AccentButton(
                label: l.briefingStart,
                icon: Icons.photo_camera_outlined,
                onPressed: () => context.push('/capture'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.index, required this.icon, required this.text});

  final int index;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sp.x4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              index.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFeatures: Numerals.features,
                color: accentOf(context),
              ),
            ),
          ),
          Icon(icon, size: 21, color: scheme.onSurfaceVariant),
          const SizedBox(width: Sp.x3),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
