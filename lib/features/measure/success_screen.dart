import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/measure_flow.dart';
import '../../app/records_store.dart';
import '../../design/tick_ruler.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../l10n/app_localizations.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  /// iPad requires a popover anchor; anchor the sheet to the button.
  static void _shareQr(BuildContext btnContext, String qr) {
    final box = btnContext.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    SharePlus.instance.share(
      ShareParams(text: qr, sharePositionOrigin: origin),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final records = context.watch<RecordsStore>();
    final latest = records.records.isEmpty ? null : records.records.first;
    final qr = latest?.qrCode;
    final subjectName = context.read<MeasureFlow>().subject.name;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sp.x6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // accent check
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Motion.emphasized,
                curve: Motion.spring,
                builder: (context, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Container(
                  width: 84,
                  height: 84,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentOf(context).withValues(alpha: 0.14),
                    border: Border.all(color: accentOf(context), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: accentOf(context).withValues(alpha: 0.38),
                        blurRadius: 44,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(Icons.check_rounded,
                      size: 42, color: accentOf(context)),
                ),
              ),
              const SizedBox(height: Sp.x6),
              Text(
                l.successTitle,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: Sp.x2),
              Text(
                l.successSub,
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: Sp.x8),
              if (qr != null && qr.isNotEmpty)
                Center(
                  child: ContourCard(
                    padding: const EdgeInsets.all(Sp.x5),
                    child: Column(
                      children: [
                        // White plate: scanners need dark-on-light; an
                        // inverted QR on the dark theme would not read.
                        Container(
                          padding: const EdgeInsets.all(Sp.x3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(Corners.control),
                          ),
                          child: SizedBox(
                            width: 156,
                            height: 156,
                            child: QrImageView(
                              data: qr,
                              version: QrVersions.auto,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: Color(0xFF0B1020),
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: Color(0xFF0B1020),
                              ),
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: Sp.x3),
                        SizedBox(width: 168, child: TickRuler(height: 8)),
                        const SizedBox(height: Sp.x2),
                        Text(
                          subjectName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurfaceVariant,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Spacer(),
              if (qr != null && qr.isNotEmpty)
                Builder(
                  builder: (btnContext) => AccentButton(
                    label: l.successShare,
                    icon: Icons.ios_share_rounded,
                    onPressed: () => _shareQr(btnContext, qr),
                  ),
                ),
              const SizedBox(height: Sp.x3),
              Row(
                children: [
                  Expanded(
                    child: ThreadButton(
                      label: l.successNewMeasure,
                      onPressed: () {
                        context.read<MeasureFlow>().reset();
                        context.go('/subject');
                      },
                    ),
                  ),
                  Expanded(
                    child: ThreadButton(
                      label: l.successDone,
                      onPressed: () => context.go('/'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Sp.x4),
            ],
          ),
        ),
      ),
    );
  }
}
