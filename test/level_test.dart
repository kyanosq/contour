import 'package:contour/capture/level.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('level math', () {
    test('upright portrait phone reads level', () {
      final r = readLevel(0, -9.81, 0);
      expect(r.radial, lessThan(0.01));
      expect(r.pitchDeg.abs(), lessThan(0.5));
      expect(r.rollDeg.abs(), lessThan(0.5));
    });

    test('screen-up flat phone reads far off level', () {
      final r = readLevel(0, 0, -9.81);
      expect(r.radial, greaterThan(0.9));
    });

    test('mild tilt maps proportionally to bubble offset', () {
      // ~6° roll → about half of the 12° full scale
      final r = readLevel(1.02, -9.75, 0);
      expect(r.dx.abs(), closeTo(0.5, 0.1));
      expect(r.dy.abs(), lessThan(0.1));
    });

    test('gate hysteresis: enters level below 0.32, leaves above 0.45', () {
      final gate = LevelGate();
      expect(gate.update(readLevel(3.0, -9.0, 2.5)), isFalse);
      expect(gate.update(readLevel(0.2, -9.8, 0.2)), isTrue);
      // small wobble below exit threshold stays level
      expect(gate.update(readLevel(0.7, -9.7, 0.3)), isTrue);
      // large tilt exits
      expect(gate.update(readLevel(3.5, -8.8, 2.5)), isFalse);
    });

    test('zero vector degrades gracefully', () {
      final r = readLevel(0, 0, 0);
      expect(r.radial, 0);
    });
  });
}
