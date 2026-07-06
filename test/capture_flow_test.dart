import 'package:contour/capture/capture_flow.dart';
import 'package:contour/capture/level.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

LevelReading _level() =>
    const LevelReading(dx: 0.05, dy: 0.05, pitchDeg: 1, rollDeg: 1);
LevelReading _tilted() =>
    const LevelReading(dx: 0.9, dy: 0.7, pitchDeg: 10, rollDeg: 9);

void main() {
  group('capture flow machine', () {
    test('level held → countdown → auto shutter → review', () {
      fakeAsync((async) {
        var shots = 0;
        final counts = <int>[];
        final m = CaptureFlowMachine(
          holdDuration: const Duration(milliseconds: 500),
          tickInterval: const Duration(milliseconds: 300),
          onShutter: () async => shots++,
          onCount: counts.add,
        );
        m.onLevel(_tilted());
        expect(m.phase, CapturePhase.unlevel);
        m.onLevel(_level());
        expect(m.phase, CapturePhase.holding);
        async.elapse(const Duration(milliseconds: 550));
        expect(m.phase, CapturePhase.countdown);
        expect(m.countdown, 3);
        async.elapse(const Duration(milliseconds: 1000));
        expect(shots, 1);
        expect(m.phase, CapturePhase.review);
        expect(counts, [3, 2, 1]);
        m.dispose();
      });
    });

    test('losing level during countdown cancels it', () {
      fakeAsync((async) {
        var shots = 0;
        final m = CaptureFlowMachine(
          holdDuration: const Duration(milliseconds: 200),
          tickInterval: const Duration(milliseconds: 300),
          onShutter: () async => shots++,
        );
        m.onLevel(_level());
        async.elapse(const Duration(milliseconds: 250));
        expect(m.phase, CapturePhase.countdown);
        m.onLevel(_tilted());
        expect(m.phase, CapturePhase.unlevel);
        async.elapse(const Duration(seconds: 3));
        expect(shots, 0);
        m.dispose();
      });
    });

    test('manual shutter works with auto disabled', () {
      fakeAsync((async) {
        var shots = 0;
        final m = CaptureFlowMachine(onShutter: () async => shots++)
          ..autoShutter = false;
        m.manualShutter();
        async.elapse(Duration.zero);
        expect(shots, 1);
        expect(m.phase, CapturePhase.review);
        m.dispose();
      });
    });

    test('front confirm advances to side; side confirm completes', () {
      fakeAsync((async) {
        final m = CaptureFlowMachine(onShutter: () async {});
        m.manualShutter();
        async.elapse(Duration.zero);
        expect(m.view, CaptureView.front);
        expect(m.confirm(), isFalse);
        expect(m.view, CaptureView.side);
        expect(m.phase, CapturePhase.unlevel);
        m.manualShutter();
        async.elapse(Duration.zero);
        expect(m.confirm(), isTrue);
        m.dispose();
      });
    });

    test('retake returns to unlevel and re-arms the gate', () {
      fakeAsync((async) {
        final m = CaptureFlowMachine(onShutter: () async {});
        m.manualShutter();
        async.elapse(Duration.zero);
        expect(m.phase, CapturePhase.review);
        m.retake();
        expect(m.phase, CapturePhase.unlevel);
        expect(m.isLevel, isFalse);
        m.dispose();
      });
    });

    test('shutter ignored while shooting or reviewing', () {
      fakeAsync((async) {
        var shots = 0;
        final m = CaptureFlowMachine(onShutter: () async {
          shots++;
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });
        m.manualShutter();
        m.manualShutter(); // ignored: still shooting
        async.elapse(const Duration(milliseconds: 150));
        expect(m.phase, CapturePhase.review);
        m.manualShutter(); // ignored: reviewing
        async.elapse(const Duration(milliseconds: 200));
        expect(shots, 1);
        m.dispose();
      });
    });

    test('gate hysteresis holds countdown through small wobble', () {
      fakeAsync((async) {
        final m = CaptureFlowMachine(
          holdDuration: const Duration(milliseconds: 100),
          onShutter: () async {},
        );
        m.onLevel(_level());
        async.elapse(const Duration(milliseconds: 150));
        expect(m.phase, CapturePhase.countdown);
        // wobble inside hysteresis (radial ~0.40 < exit 0.45)
        m.onLevel(const LevelReading(
            dx: 0.28, dy: 0.28, pitchDeg: 3.4, rollDeg: 3.4));
        expect(m.phase, CapturePhase.countdown);
        m.dispose();
      });
    });
  });
}
