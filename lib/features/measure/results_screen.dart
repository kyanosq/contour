import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../api/measure_api.dart';
import '../../app/measure_flow.dart';
import '../../app/records_store.dart';
import '../../app/session.dart';
import '../../design/funnel_progress.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import 'part_grouping.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  int? _editingId;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final flow = context.watch<MeasureFlow>();
    final result = flow.result;

    if (result == null) {
      return Scaffold(
        body: Center(
          child: ThreadButton(
            label: l.commonBack,
            onPressed: () => context.go('/'),
          ),
        ),
      );
    }

    final metric = flow.subject.units == UnitSystem.metric;
    final unit = metric ? l.unitCm : l.unitIn;
    final groups = groupParts(result.parts);
    final invalidCount = result.parts.where((p) => !p.valid).length;

    return Scaffold(
      appBar: AppBar(title: Text(l.resultsTitle)),
      body: SafeArea(
        child: WorkingVeil(
          visible: _saving,
          child: Stack(
            children: [
              Positioned.fill(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    Sp.x6,
                    Sp.x2,
                    Sp.x6,
                    invalidCount > 0 ? 156 : 128,
                  ),
                  children: [
                    FunnelProgress(
                      step: 3,
                      totalSteps: 3,
                      label: l.resultsTitle,
                    ),
                    const SizedBox(height: Sp.x4),
                    _SubjectSummary(subject: flow.subject),
                    const SizedBox(height: Sp.x4),
                    Row(
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 15,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            l.resultsEditHint,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sp.x5),
                    for (final (gi, group) in groups.indexed) ...[
                      _StaggerIn(
                        order: gi,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SectionLabel(
                              _groupLabel(l, group.kind).toUpperCase(),
                            ),
                            const SizedBox(height: Sp.x3),
                            ContourCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Sp.x4,
                                vertical: Sp.x1,
                              ),
                              child: Column(
                                children: [
                                  for (
                                    var i = 0;
                                    i < group.parts.length;
                                    i++
                                  ) ...[
                                    _PartRow(
                                      part: group.parts[i],
                                      unit: unit,
                                      index: result.parts.indexOf(
                                        group.parts[i],
                                      ),
                                      editing:
                                          _editingId == group.parts[i].partId,
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        setState(
                                          () => _editingId =
                                              _editingId ==
                                                  group.parts[i].partId
                                              ? null
                                              : group.parts[i].partId,
                                        );
                                      },
                                      onChanged: (v) {
                                        setState(
                                          () => group.parts[i].value = v,
                                        );
                                        context.read<MeasureFlow>().touch();
                                      },
                                    ),
                                    if (i < group.parts.length - 1)
                                      Divider(color: scheme.outlineVariant),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Sp.x5),
                    ],
                  ],
                ),
              ),
              // Docked save bar — frosted so the sheet scrolls beneath it.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(
                        Sp.x6,
                        Sp.x3,
                        Sp.x6,
                        Sp.x4,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: 0.30),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (invalidCount > 0) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 15,
                                  color: Atelier.danger,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l.resultsInvalid(invalidCount),
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Atelier.danger,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Sp.x2),
                          ],
                          AccentButton(
                            label: _saving ? l.saving : l.resultsSave,
                            icon: Icons.bookmark_added_outlined,
                            onPressed: invalidCount > 0 || _saving
                                ? null
                                : _save,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _groupLabel(AppLocalizations l, PartKind kind) => switch (kind) {
    PartKind.girth => l.resultsGroupGirth,
    PartKind.length => l.resultsGroupLength,
    PartKind.width => l.resultsGroupWidth,
  };

  Future<void> _save() async {
    final flow = context.read<MeasureFlow>();
    final session = context.read<Session>();
    final records = context.read<RecordsStore>();
    setState(() => _saving = true);
    try {
      await session.api.save(subject: flow.subject, result: flow.result!);
      await records.refresh();
      if (mounted) context.pushReplacement('/success');
    } on ApiFailure catch (e) {
      if (mounted) showToast(context, e.message, error: true);
    } catch (e) {
      if (mounted) showToast(context, '$e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

/// Who these sizes belong to — the inputs were otherwise invisible from
/// here on, making mix-ups impossible to catch.
class _SubjectSummary extends StatelessWidget {
  const _SubjectSummary({required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final metric = subject.units == UnitSystem.metric;
    final height = metric
        ? '${subject.heightCm.round()} ${l.unitCm}'
        : '${cmToInch(subject.heightCm).toStringAsFixed(0)} ${l.unitIn}';
    final weight = metric
        ? '${subject.weightKg.round()} ${l.unitKg}'
        : '${kgToLb(subject.weightKg).toStringAsFixed(0)} ${l.unitLb}';
    final chips = <(IconData, String)>[
      (
        subject.gender == Gender.male
            ? Icons.male_rounded
            : Icons.female_rounded,
        subject.gender == Gender.male ? l.genderMale : l.genderFemale,
      ),
      (Icons.height_rounded, height),
      (Icons.monitor_weight_outlined, weight),
      (
        Icons.checkroom_rounded,
        subject.topFit == TopFit.fit ? l.fitTight : l.fitLoose,
      ),
    ];
    return ContourCard(
      padding: const EdgeInsets.symmetric(horizontal: Sp.x4, vertical: Sp.x3),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: accentOf(context).withValues(alpha: 0.16),
            child: Text(
              subject.name.isEmpty ? '·' : subject.name.characters.first,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: accentOf(context),
              ),
            ),
          ),
          const SizedBox(width: Sp.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Wrap(
                  spacing: Sp.x3,
                  runSpacing: 2,
                  children: [
                    for (final (icon, text) in chips)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 13, color: scheme.onSurfaceVariant),
                          const SizedBox(width: 3),
                          Text(
                            text,
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One-shot staggered entrance: fade + rise, ordered by [order].
class _StaggerIn extends StatelessWidget {
  const _StaggerIn({required this.order, required this.child});

  final int order;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + 90 * order),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - v)),
          child: child,
        ),
      ),
    );
  }
}

class _PartRow extends StatelessWidget {
  const _PartRow({
    required this.part,
    required this.unit,
    required this.index,
    required this.editing,
    required this.onTap,
    required this.onChanged,
  });

  final Part part;
  final String unit;
  final int index;
  final bool editing;
  final VoidCallback onTap;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final zh = Localizations.localeOf(context).languageCode == 'zh';
    final name = zh || part.nameEn.isEmpty ? part.nameZh : part.nameEn;
    final invalid = !part.valid;

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.standard,
        padding: const EdgeInsets.symmetric(vertical: Sp.x3),
        child: Column(
          children: [
            Row(
              children: [
                if (invalid) ...[
                  const Icon(
                    Icons.error_outline,
                    size: 15,
                    color: Atelier.danger,
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: invalid ? Atelier.danger : scheme.onSurface,
                    ),
                  ),
                ),
                _RollingNumber(
                  value: part.value,
                  delayMs: 40 * index,
                  style: Numerals.value(context, size: 24).copyWith(
                    color: invalid ? Atelier.danger : scheme.onSurface,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              duration: Motion.standard,
              sizeCurve: Motion.easeOut,
              crossFadeState: editing
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: Sp.x3),
                child: Row(
                  children: [
                    if (part.lower != null && part.upper != null)
                      Expanded(
                        child: Text(
                          l.resultsRangeBadge(
                            part.lower!.toStringAsFixed(1),
                            part.upper!.toStringAsFixed(1),
                          ),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      const Spacer(),
                    _Stepper(
                      onMinus: () =>
                          onChanged(((part.value - 0.5) * 100).round() / 100),
                      onPlus: () =>
                          onChanged(((part.value + 0.5) * 100).round() / 100),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.onMinus, required this.onPlus});

  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget btn(IconData icon, VoidCallback onTap) => InkWell(
      borderRadius: BorderRadius.circular(Corners.chip),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 44,
        height: 36,
        alignment: Alignment.center,
        child: Icon(icon, size: 19, color: scheme.onSurface),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Corners.chip),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.remove_rounded, onMinus),
          Container(width: 0.5, height: 20, color: scheme.outlineVariant),
          btn(Icons.add_rounded, onPlus),
        ],
      ),
    );
  }
}

/// Counts up from 0 on first appearance; snaps on subsequent edits.
class _RollingNumber extends StatefulWidget {
  const _RollingNumber({
    required this.value,
    required this.style,
    this.delayMs = 0,
  });

  final double value;
  final TextStyle style;
  final int delayMs;

  @override
  State<_RollingNumber> createState() => _RollingNumberState();
}

class _RollingNumberState extends State<_RollingNumber> {
  bool _rolled = false;

  @override
  Widget build(BuildContext context) {
    if (_rolled) {
      return Text(widget.value.toStringAsFixed(1), style: widget.style);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: widget.value),
      duration: Motion.numberRoll + Duration(milliseconds: widget.delayMs),
      curve: Curves.easeOutCubic,
      onEnd: () => setState(() => _rolled = true),
      builder: (context, v, _) =>
          Text(v.toStringAsFixed(1), style: widget.style),
    );
  }
}
