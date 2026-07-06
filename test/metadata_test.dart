import 'package:contour/capture/level.dart';
import 'package:contour/capture/metadata.dart';
import 'package:contour/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('capture metadata contract', () {
    test('view meta carries contract keys with rounded values', () {
      final level = readLevel(1.02, -9.7, 0.8);
      final meta = buildViewMeta(
        view: 'front',
        level: level,
        gx: 1.02,
        gy: -9.7,
        gz: 0.8,
        imageWidth: 1080,
        imageHeight: 1440,
        lens: 'back',
      );
      expect(meta['view'], 'front');
      expect(meta.containsKey('pitch_deg'), isTrue);
      expect(meta.containsKey('roll_deg'), isTrue);
      expect(meta['gravity'], hasLength(3));
      expect(meta['width'], 1080);
      expect(meta['height'], 1440);
      expect(meta['lens'], 'back');
      expect(meta['ts'], isA<String>());
      // rounding: pitch to 2 decimals
      final pitch = meta['pitch_deg'] as double;
      expect(pitch, closeTo(level.pitchDeg, 0.01));
      expect((pitch * 100).roundToDouble() / 100, pitch);
    });

    test('pitch sign follows gravity z leakage', () {
      final tiltedBack = readLevel(0, -9.4, 2.5); // screen up → +z
      expect(tiltedBack.pitchDeg, greaterThan(5));
      final tiltedFwd = readLevel(0, -9.4, -2.5);
      expect(tiltedFwd.pitchDeg, lessThan(-5));
    });

    test('gravity plausibility rejects zero/absurd vectors', () {
      expect(gravityPlausible(0, 0, 0), isFalse);
      expect(gravityPlausible(0, -9.8, 0), isTrue);
      expect(gravityPlausible(0, -30, 0), isFalse);
    });

    test('CaptureMetadata wraps views under the contract root', () {
      final cm = CaptureMetadata();
      cm.putView('front', {'view': 'front', 'pitch_deg': 1.2});
      cm.putView('side', {'view': 'side', 'pitch_deg': -0.4});
      final s = cm.toJsonString();
      expect(s, contains('"views"'));
      expect(s, contains('"front"'));
      expect(s, contains('"side"'));
    });

    test('device info carries platform + client marker', () {
      final d = buildDeviceInfo(appVersion: '1.0.0 (1)');
      expect(d['capture_client'], 'contour');
      expect(d['app_version'], '1.0.0 (1)');
      expect(d['platform'], isNotEmpty);
    });
  });
}
