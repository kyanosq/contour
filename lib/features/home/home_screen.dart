import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/measure_flow.dart';
import '../../app/records_store.dart';
import '../../design/tick_ruler.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../l10n/app_localizations.dart';
import 'dress_form_art.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecordsStore>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final count = context.watch<RecordsStore>().total;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sp.x6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Sp.x4),
              // wordmark row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.brandMark,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 6,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l.taglineSub,
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.2,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => context.push('/settings'),
                    tooltip: l.homeSettings,
                    icon: Icon(
                      Icons.tune_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              // hero
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: Sp.x4),
                        child: AspectRatio(
                          aspectRatio: 0.72,
                          child: DressFormArt(
                            bandLabels: [
                              l.homeHeroBust,
                              l.homeHeroWaist,
                              l.homeHeroHip,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Text(
                      l.tagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: Sp.x6),
                  ],
                ),
              ),

              // actions
              BrassButton(
                label: l.homeStart,
                icon: Icons.straighten_rounded,
                onPressed: () {
                  context.read<MeasureFlow>().reset();
                  context.push('/subject');
                },
              ),
              const SizedBox(height: Sp.x2),
              Text(
                l.homeStartSub,
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: Sp.x5),
              ContourCard(
                padding: const EdgeInsets.symmetric(
                    horizontal: Sp.x5, vertical: Sp.x4),
                onTap: () => context.push('/records'),
                child: Row(
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 22, color: brassOf(context)),
                    const SizedBox(width: Sp.x3),
                    Expanded(
                      child: Text(
                        l.homeRecords,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: Motion.standard,
                      child: count == 0
                          ? const SizedBox.shrink()
                          : Container(
                              key: ValueKey(count),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Sp.x3, vertical: 4),
                              decoration: BoxDecoration(
                                color: brassOf(context)
                                    .withValues(alpha: 0.14),
                                borderRadius:
                                    BorderRadius.circular(Corners.chip),
                              ),
                              child: Text(
                                l.homeRecordsCount(count),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: Numerals.features,
                                  color: brassOf(context),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: Sp.x2),
                    Icon(Icons.chevron_right_rounded,
                        color: scheme.onSurfaceVariant),
                  ],
                ),
              ),
              const SizedBox(height: Sp.x4),
              const TickRuler(height: 10),
              const SizedBox(height: Sp.x4),
            ],
          ),
        ),
      ),
    );
  }
}
