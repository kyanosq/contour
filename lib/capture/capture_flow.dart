import 'dart:async';

import 'package:flutter/foundation.dart';

import 'level.dart';

enum CaptureView { front, side }

enum CapturePhase {
  /// Waiting for the phone to be leveled.
  unlevel,

  /// Level — must hold for [holdDuration] before the countdown starts.
  holding,

  /// 3-2-1 auto-shutter countdown.
  countdown,

  /// Shutter fired; processing the photo.
  shooting,

  /// Photo taken for this view; user reviews retake/use.
  review,
}

/// The guided-capture state machine, camera-agnostic and fully unit-testable.
///
///   unlevel ⇄ holding → countdown(3,2,1) → shoot → review
///
/// Losing level anywhere before `shooting` falls back to `unlevel`.
class CaptureFlowMachine extends ChangeNotifier {
  CaptureFlowMachine({
    this.holdDuration = const Duration(milliseconds: 1000),
    this.countFrom = 3,
    this.tickInterval = const Duration(seconds: 1),
    required this.onShutter,
    this.onCount,
  });

  final Duration holdDuration;
  final int countFrom;
  final Duration tickInterval;

  /// Fired when the countdown completes — the camera layer takes the photo.
  final Future<void> Function() onShutter;

  /// Fired on each countdown tick (for TTS/haptics), with the current number.
  final void Function(int n)? onCount;

  final LevelGate _gate = LevelGate();

  CaptureView view = CaptureView.front;
  CapturePhase phase = CapturePhase.unlevel;
  int countdown = 0;
  bool autoShutter = true;

  Timer? _holdTimer;
  Timer? _countTimer;
  bool _disposed = false;

  bool get isLevel => _gate.isLevel;

  /// Feed a gravity reading; drives the whole machine.
  void onLevel(LevelReading r) {
    if (phase == CapturePhase.shooting || phase == CapturePhase.review) {
      return;
    }
    final level = _gate.update(r);
    if (level) {
      if (phase == CapturePhase.unlevel) {
        phase = CapturePhase.holding;
        _holdTimer?.cancel();
        if (autoShutter) {
          _holdTimer = Timer(holdDuration, _startCountdown);
        }
        notifyListeners();
      }
    } else {
      if (phase == CapturePhase.holding || phase == CapturePhase.countdown) {
        _cancelTimers();
        phase = CapturePhase.unlevel;
        countdown = 0;
        notifyListeners();
      }
    }
  }

  void _startCountdown() {
    if (_disposed || phase != CapturePhase.holding) return;
    phase = CapturePhase.countdown;
    countdown = countFrom;
    onCount?.call(countdown);
    notifyListeners();
    _countTimer = Timer.periodic(tickInterval, (t) {
      countdown -= 1;
      if (countdown <= 0) {
        t.cancel();
        _fire();
      } else {
        onCount?.call(countdown);
        notifyListeners();
      }
    });
  }

  /// Manual shutter — allowed whenever we're not already shooting/reviewing.
  void manualShutter() {
    if (phase == CapturePhase.shooting || phase == CapturePhase.review) {
      return;
    }
    _cancelTimers();
    _fire();
  }

  Future<void> _fire() async {
    phase = CapturePhase.shooting;
    countdown = 0;
    notifyListeners();
    await onShutter();
    if (_disposed) return;
    phase = CapturePhase.review;
    notifyListeners();
  }

  /// Review verdict: retake this view.
  void retake() {
    if (phase != CapturePhase.review) return;
    phase = CapturePhase.unlevel;
    _gate.update(const LevelReading(dx: 9, dy: 9, pitchDeg: 90, rollDeg: 90));
    notifyListeners();
  }

  /// Review verdict: keep the shot. Returns true when the whole session
  /// (front + side) is complete.
  bool confirm() {
    if (phase != CapturePhase.review) return false;
    if (view == CaptureView.front) {
      view = CaptureView.side;
      phase = CapturePhase.unlevel;
      notifyListeners();
      return false;
    }
    notifyListeners();
    return true;
  }

  void _cancelTimers() {
    _holdTimer?.cancel();
    _countTimer?.cancel();
    _holdTimer = null;
    _countTimer = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelTimers();
    super.dispose();
  }
}
