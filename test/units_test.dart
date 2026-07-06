import 'package:contour/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('unit conversion', () {
    test('cm→inch→cm round trip <0.1', () {
      for (final cm in [120.0, 150.0, 172.0, 199.5, 220.0]) {
        expect((inchToCm(cmToInch(cm)) - cm).abs(), lessThan(0.1));
      }
    });

    test('kg→lb→kg round trip <0.1', () {
      for (final kg in [30.0, 55.5, 75.0, 120.0, 200.0]) {
        expect((lbToKg(kgToLb(kg)) - kg).abs(), lessThan(0.1));
      }
    });

    test('known anchors', () {
      expect(cmToInch(172), closeTo(67.72, 0.02));
      expect(kgToLb(65), closeTo(143.3, 0.1));
      expect(inchToCm(69), closeTo(175.26, 0.01));
      expect(lbToKg(165), closeTo(74.84, 0.05));
    });
  });

  group('capture standard bounds', () {
    test('height 119 rejected, 120 ok, 220 ok, 221 rejected', () {
      expect(CaptureStandard.heightValid(119), isFalse);
      expect(CaptureStandard.heightValid(120), isTrue);
      expect(CaptureStandard.heightValid(220), isTrue);
      expect(CaptureStandard.heightValid(220.5), isFalse);
    });

    test('weight 29 rejected, 30 ok, 200 ok, 201 rejected', () {
      expect(CaptureStandard.weightValid(29.9), isFalse);
      expect(CaptureStandard.weightValid(30), isTrue);
      expect(CaptureStandard.weightValid(200), isTrue);
      expect(CaptureStandard.weightValid(201), isFalse);
    });
  });

  group('subject → legacy params', () {
    test('metric params use cm/kg codes and display values', () {
      final s = Subject(
        name: '张三',
        contact: '13800000000',
        gender: Gender.female,
        heightCm: 165,
        weightKg: 52.5,
      );
      final p = s.toParams();
      expect(p['gender'], '2');
      expect(p['height'], '165.00');
      expect(p['weight'], '52.50');
      expect(p['heightunitid'], '1');
      expect(p['weightunitid'], '1');
      expect(p['top_fit'], 'fit');
    });

    test('imperial params render display-unit numbers', () {
      final s = Subject(
        name: 'a',
        contact: 'b',
        heightCm: inchToCm(69),
        weightKg: lbToKg(165),
        units: UnitSystem.imperial,
        topFit: TopFit.loose,
      );
      final p = s.toParams();
      expect(double.parse(p['height'] as String), closeTo(69, 0.01));
      expect(double.parse(p['weight'] as String), closeTo(165, 0.05));
      expect(p['heightunitid'], '2');
      expect(p['top_fit'], 'loose');
    });
  });

  group('part edit envelope', () {
    test('±10cm envelope from server value; outside invalid', () {
      final part = Part.fromJson(
        {'partId': 1, 'partName': '胸围', 'partEnName': 'Chest',
         'partValue': '92.40'},
        metric: true,
      );
      expect(part.lower, closeTo(82.4, 0.01));
      expect(part.upper, closeTo(102.4, 0.01));
      expect(part.valid, isTrue);
      part.value = 102.4;
      expect(part.valid, isTrue);
      part.value = 102.9;
      expect(part.valid, isFalse);
      part.value = 82.0;
      expect(part.valid, isFalse);
    });

    test('imperial envelope is ±4in', () {
      final part = Part.fromJson(
        {'partId': 1, 'partName': '胸围', 'partEnName': 'Chest',
         'partValue': '36.00'},
        metric: false,
      );
      expect(part.lower, closeTo(32, 0.01));
      expect(part.upper, closeTo(40, 0.01));
    });
  });
}
