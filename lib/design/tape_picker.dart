import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// A measuring-tape number picker: horizontal ruler that scrolls under a
/// fixed brass needle. Fling + snap come from [ListWheelScrollView] rotated
/// sideways; every tick passing the needle clicks the haptics.
///
/// Values are `min + i * step`. All in display units — unit conversion is the
/// caller's job.
class TapePicker extends StatefulWidget {
  const TapePicker({
    super.key,
    required this.min,
    required this.max,
    required this.step,
    required this.value,
    required this.onChanged,
    this.majorEvery = 5,
    this.labelBuilder,
    this.height = 92,
  });

  final double min;
  final double max;
  final double step;
  final double value;
  final ValueChanged<double> onChanged;

  /// Every n-th tick is tall and (by default) labeled.
  final int majorEvery;

  /// Label for tick index (null → no label). Defaults to the numeric value on
  /// major ticks.
  final String? Function(double value, int index)? labelBuilder;

  final double height;

  @override
  State<TapePicker> createState() => _TapePickerState();
}

class _TapePickerState extends State<TapePicker> {
  static const _tickExtent = 12.0;

  late FixedExtentScrollController _controller;

  int get _count => ((widget.max - widget.min) / widget.step).round() + 1;

  int _indexFor(double value) =>
      (((value - widget.min) / widget.step).round()).clamp(0, _count - 1);

  double _valueFor(int index) {
    final raw = widget.min + index * widget.step;
    return (raw * 1000).round() / 1000;
  }

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(
      initialItem: _indexFor(widget.value),
    );
  }

  @override
  void didUpdateWidget(TapePicker old) {
    super.didUpdateWidget(old);
    // External value change (e.g. unit switch) → recenter without animation.
    final target = _indexFor(widget.value);
    if (old.min != widget.min ||
        old.max != widget.max ||
        old.step != widget.step) {
      _controller.jumpToItem(target);
    } else if (_controller.hasClients &&
        _controller.selectedItem != target &&
        !_dragging) {
      _controller.jumpToItem(target);
    }
  }

  bool _dragging = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brass = brassOf(context);

    return SizedBox(
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The tape
          NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollStartNotification) _dragging = true;
              if (n is ScrollEndNotification) _dragging = false;
              return false;
            },
            child: RotatedBox(
              quarterTurns: -1,
              child: ListWheelScrollView.useDelegate(
                controller: _controller,
                itemExtent: _tickExtent,
                perspective: 0.0022,
                diameterRatio: 3.2,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (i) {
                  HapticFeedback.selectionClick();
                  widget.onChanged(_valueFor(i));
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: _count,
                  builder: (context, i) => RotatedBox(
                    quarterTurns: 1,
                    child: _Tick(
                      major: i % widget.majorEvery == 0,
                      label: _labelFor(i),
                      color: scheme.onSurfaceVariant,
                      labelColor: scheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Edge fades
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      scheme.surfaceContainerLow,
                      scheme.surfaceContainerLow.withValues(alpha: 0),
                      scheme.surfaceContainerLow.withValues(alpha: 0),
                      scheme.surfaceContainerLow,
                    ],
                    stops: const [0, 0.18, 0.82, 1],
                  ),
                ),
              ),
            ),
          ),
          // Brass needle
          IgnorePointer(
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: widget.height * 0.52,
                  decoration: BoxDecoration(
                    color: brass,
                    borderRadius: BorderRadius.circular(1),
                    boxShadow: [
                      BoxShadow(
                        color: brass.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _labelFor(int i) {
    if (widget.labelBuilder != null) {
      return widget.labelBuilder!(_valueFor(i), i);
    }
    if (i % widget.majorEvery != 0) return null;
    final v = _valueFor(i);
    return v == v.roundToDouble() ? '${v.round()}' : '$v';
  }
}

class _Tick extends StatelessWidget {
  const _Tick({
    required this.major,
    required this.label,
    required this.color,
    required this.labelColor,
  });

  final bool major;
  final String? label;
  final Color color;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    // The wheel's 3D projection can hand items a cross extent a hair smaller
    // than the picker height; lay out at natural size and let the bottom
    // breathe instead of clipping.
    return OverflowBox(
      maxHeight: double.infinity,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),
          Container(
            width: major ? 1.6 : 1.0,
            height: major ? 30 : 16,
            color: color.withValues(alpha: major ? 0.75 : 0.35),
          ),
          if (label != null) ...[
            const SizedBox(height: 7),
            // Item slots are one tick wide; let labels overflow visually
            // without wrapping (labels sit only on major ticks).
            SizedBox(
              height: 16,
              child: OverflowBox(
                maxWidth: 72,
                alignment: Alignment.topCenter,
                child: Text(
                  label!,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFeatures: Numerals.features,
                    color: labelColor.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
