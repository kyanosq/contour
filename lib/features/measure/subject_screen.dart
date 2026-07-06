import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/measure_flow.dart';
import '../../design/funnel_progress.dart';
import '../../design/tape_picker.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({super.key});

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  late final MeasureFlow flow = context.read<MeasureFlow>();
  late final TextEditingController _name = TextEditingController(
    text: flow.subject.name,
  );
  late final TextEditingController _contact = TextEditingController(
    text: flow.subject.contact,
  );

  String? _nameError;
  String? _contactError;
  String? _rangeError;

  final _metricsKey = GlobalKey();
  final _identityKey = GlobalKey();
  final _scroll = ScrollController();

  Subject get s => flow.subject;

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _continue() {
    final l = AppLocalizations.of(context);
    setState(() {
      s.name = _name.text.trim();
      s.contact = _contact.text.trim();
      _nameError = s.name.isEmpty ? l.errNameRequired : null;
      _contactError = s.contact.isEmpty ? l.errContactRequired : null;
      _rangeError = !CaptureStandard.heightValid(s.heightCm)
          ? l.errHeightRange
          : !CaptureStandard.weightValid(s.weightKg)
          ? l.errWeightRange
          : null;
    });
    if (_nameError != null || _contactError != null || _rangeError != null) {
      HapticFeedback.heavyImpact();
      // Bring the first offending section into view — it may be scrolled
      // out of (and lazily removed from) the list.
      final target = _rangeError != null ? _metricsKey : _identityKey;
      final ctx = target.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: Motion.emphasized,
          alignment: 0.1,
          curve: Curves.easeOutCubic,
        );
      } else {
        // Section not built yet (far off-screen): jump to list end/start.
        _scroll.animateTo(
          _rangeError != null ? 0 : _scroll.position.maxScrollExtent,
          duration: Motion.emphasized,
          curve: Curves.easeOutCubic,
        );
      }
      return;
    }
    context.push('/briefing');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final metric = s.units == UnitSystem.metric;

    return Scaffold(
      appBar: AppBar(title: Text(l.subjectTitle)),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(
                    Sp.x6,
                    Sp.x2,
                    Sp.x6,
                    Sp.x6,
                  ),
                  children: [
                    FunnelProgress(
                      step: 1,
                      totalSteps: 3,
                      label: l.subjectTitle,
                    ),
                    const SizedBox(height: Sp.x6),
                    Text(
                      l.subjectWho,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: Sp.x6),

                    // ---- gender + fit
                    SectionLabel(l.subjectGender.toUpperCase()),
                    const SizedBox(height: Sp.x3),
                    _Segmented<Gender>(
                      value: s.gender,
                      onChanged: (g) => setState(() => s.gender = g),
                      items: {
                        Gender.male: (Icons.male_rounded, l.genderMale),
                        Gender.female: (Icons.female_rounded, l.genderFemale),
                      },
                    ),
                    const SizedBox(height: Sp.x6),

                    // ---- metrics card with unit toggle
                    Row(
                      key: _metricsKey,
                      children: [
                        Expanded(
                          child: SectionLabel(
                            '${l.subjectHeight} · ${l.subjectWeight}'
                                .toUpperCase(),
                          ),
                        ),
                        _UnitToggle(
                          metric: metric,
                          onChanged: (m) => setState(() {
                            s.units = m
                                ? UnitSystem.metric
                                : UnitSystem.imperial;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sp.x3),
                    ContourCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sp.x4,
                        vertical: Sp.x5,
                      ),
                      child: Column(
                        children: [
                          _MetricBlock(
                            label: l.subjectHeight,
                            display: _heightDisplay(metric),
                            child: metric
                                ? TapePicker(
                                    key: const ValueKey('h-cm'),
                                    min: CaptureStandard.minHeightCm,
                                    max: CaptureStandard.maxHeightCm,
                                    step: 1,
                                    majorEvery: 5,
                                    value: s.heightCm.roundToDouble(),
                                    onChanged: (v) =>
                                        setState(() => s.heightCm = v),
                                  )
                                : TapePicker(
                                    key: const ValueKey('h-in'),
                                    min: 48, // 4'0"
                                    max: 86, // 7'2"
                                    step: 1,
                                    majorEvery: 6,
                                    value: cmToInch(s.heightCm).roundToDouble(),
                                    labelBuilder: (v, i) {
                                      if (v % 6 != 0) return null;
                                      final ft = v ~/ 12;
                                      final inch = (v % 12).round();
                                      return inch == 0 ? "$ft'" : "$ft'$inch\"";
                                    },
                                    onChanged: (v) => setState(
                                      () => s.heightCm = inchToCm(v),
                                    ),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: Sp.x4,
                            ),
                            child: Divider(color: scheme.outlineVariant),
                          ),
                          _MetricBlock(
                            label: l.subjectWeight,
                            display: _weightDisplay(metric),
                            child: metric
                                ? TapePicker(
                                    key: const ValueKey('w-kg'),
                                    min: CaptureStandard.minWeightKg,
                                    max: CaptureStandard.maxWeightKg,
                                    step: 0.5,
                                    majorEvery: 10,
                                    value: (s.weightKg * 2).roundToDouble() / 2,
                                    onChanged: (v) =>
                                        setState(() => s.weightKg = v),
                                  )
                                : TapePicker(
                                    key: const ValueKey('w-lb'),
                                    min: 66,
                                    max: 440,
                                    step: 1,
                                    majorEvery: 10,
                                    value: kgToLb(s.weightKg).roundToDouble(),
                                    onChanged: (v) =>
                                        setState(() => s.weightKg = lbToKg(v)),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    if (_rangeError != null) ...[
                      const SizedBox(height: Sp.x2),
                      _ErrorText(_rangeError!),
                    ],
                    const SizedBox(height: Sp.x6),

                    // ---- garment fit
                    SectionLabel(l.subjectFit.toUpperCase()),
                    const SizedBox(height: Sp.x3),
                    _Segmented<TopFit>(
                      value: s.topFit,
                      onChanged: (f) => setState(() => s.topFit = f),
                      items: {
                        TopFit.fit: (
                          Icons.accessibility_new_rounded,
                          l.fitTight,
                        ),
                        TopFit.loose: (Icons.checkroom_rounded, l.fitLoose),
                      },
                    ),
                    const SizedBox(height: Sp.x2),
                    Text(
                      l.subjectFitHint,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Sp.x6),

                    // ---- identity
                    SectionLabel(
                      l.subjectName.toUpperCase(),
                      key: _identityKey,
                    ),
                    const SizedBox(height: Sp.x3),
                    ContourCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sp.x5,
                        vertical: Sp.x2,
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _name,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: l.subjectName,
                              hintText: l.subjectNameHint,
                              border: InputBorder.none,
                              errorText: _nameError,
                            ),
                            onChanged: (_) {
                              if (_nameError != null) {
                                setState(() => _nameError = null);
                              }
                            },
                          ),
                          Divider(color: scheme.outlineVariant),
                          TextField(
                            controller: _contact,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: l.subjectContact,
                              hintText: l.subjectContactHint,
                              border: InputBorder.none,
                              errorText: _contactError,
                            ),
                            onChanged: (_) {
                              if (_contactError != null) {
                                setState(() => _contactError = null);
                              }
                            },
                          ),
                          const SizedBox(height: Sp.x2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(Sp.x6, Sp.x2, Sp.x6, Sp.x4),
                child: BrassButton(
                  label: l.subjectContinue,
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _continue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _heightDisplay(bool metric) {
    if (metric) return '${s.heightCm.round()}';
    final inches = cmToInch(s.heightCm).round();
    return "${inches ~/ 12}'${inches % 12}\"";
  }

  String _weightDisplay(bool metric) {
    if (metric) {
      final v = (s.weightKg * 2).round() / 2;
      return v == v.roundToDouble() ? '${v.round()}' : '$v';
    }
    return '${kgToLb(s.weightKg).round()}';
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.label,
    required this.display,
    required this.child,
  });

  final String label;
  final String display;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            AnimatedSwitcher(
              duration: Motion.fast,
              transitionBuilder: (child, a) =>
                  FadeTransition(opacity: a, child: child),
              child: Text(
                display,
                key: ValueKey(display),
                style: Numerals.display(context, size: 44),
              ),
            ),
          ],
        ),
        const SizedBox(height: Sp.x2),
        child,
      ],
    );
  }
}

class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.value,
    required this.onChanged,
    required this.items,
  });

  final T value;
  final ValueChanged<T> onChanged;
  final Map<T, (IconData, String)> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (final entry in items.entries) ...[
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(entry.key);
              },
              child: AnimatedContainer(
                duration: Motion.standard,
                curve: Motion.easeOut,
                height: 54,
                decoration: BoxDecoration(
                  color: value == entry.key
                      ? scheme.onSurface
                      : scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(Corners.control),
                  border: Border.all(
                    color: value == entry.key
                        ? Colors.transparent
                        : scheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      entry.value.$1,
                      size: 20,
                      color: value == entry.key
                          ? scheme.surface
                          : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: Sp.x2),
                    Text(
                      entry.value.$2,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: value == entry.key
                            ? scheme.surface
                            : scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (entry.key != items.keys.last) const SizedBox(width: Sp.x3),
        ],
      ],
    );
  }
}

class _UnitToggle extends StatelessWidget {
  const _UnitToggle({required this.metric, required this.onChanged});

  final bool metric;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    Widget chip(String label, bool selected, VoidCallback onTap) =>
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: AnimatedContainer(
            duration: Motion.standard,
            padding: const EdgeInsets.symmetric(horizontal: Sp.x3, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? scheme.onSurface : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? scheme.surface : scheme.onSurfaceVariant,
              ),
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          chip(l.unitMetric, metric, () => onChanged(true)),
          chip(l.unitImperial, !metric, () => onChanged(false)),
        ],
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.error_outline, size: 15, color: Atelier.danger),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12.5, color: Atelier.danger),
          ),
        ),
      ],
    );
  }
}
