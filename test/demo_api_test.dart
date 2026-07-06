import 'dart:typed_data';

import 'package:contour/api/demo_api.dart';
import 'package:contour/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Subject _subject({double h = 172, double w = 65}) => Subject(
      name: '测试者',
      contact: '13800000000',
      heightCm: h,
      weightKg: w,
    );

Future<DemoMeasureApi> _api() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return DemoMeasureApi(prefs, latency: Duration.zero);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('demo measure api', () {
    test('produces exactly 21 parts with the canonical field names', () async {
      final api = await _api();
      final r = await api.measure(
        subject: _subject(),
        frontJpeg: Uint8List(0),
        sideJpeg: Uint8List(0),
      );
      expect(r.parts, hasLength(21));
      expect([for (final p in r.parts) p.nameZh], demoFieldsZh);
    });

    test('deterministic: same inputs → identical values', () async {
      final api = await _api();
      Future<List<double>> run() async => [
            for (final p in (await api.measure(
              subject: _subject(),
              frontJpeg: Uint8List(0),
              sideJpeg: Uint8List(0),
            ))
                .parts)
              p.value,
          ];
      expect(await run(), await run());
    });

    test('anthropometric plausibility for 172cm/65kg male', () async {
      final api = await _api();
      final r = await api.measure(
        subject: _subject(),
        frontJpeg: Uint8List(0),
        sideJpeg: Uint8List(0),
      );
      double v(String name) =>
          r.parts.firstWhere((p) => p.nameZh == name).value;
      expect(v('胸围'), inInclusiveRange(85, 100));
      expect(v('腰围'), inInclusiveRange(68, 85));
      expect(v('臀围'), inInclusiveRange(88, 100));
      expect(v('领围'), inInclusiveRange(34, 42));
      expect(v('总肩宽'), inInclusiveRange(42, 49));
      expect(v('左裤长'), inInclusiveRange(98, 108));
    });

    test('taller/heavier subject measures larger', () async {
      final api = await _api();
      final small = await api.measure(
        subject: _subject(h: 160, w: 50),
        frontJpeg: Uint8List(0),
        sideJpeg: Uint8List(0),
      );
      final big = await api.measure(
        subject: _subject(h: 190, w: 95),
        frontJpeg: Uint8List(0),
        sideJpeg: Uint8List(0),
      );
      double v(MeasureResult r, String n) =>
          r.parts.firstWhere((p) => p.nameZh == n).value;
      for (final f in ['胸围', '腰围', '臀围', '左裤长', '总肩宽']) {
        expect(v(big, f), greaterThan(v(small, f)), reason: f);
      }
    });

    test('save → records → detail → delete round trip persists', () async {
      final api = await _api();
      final subject = _subject();
      final r = await api.measure(
        subject: subject,
        frontJpeg: Uint8List(0),
        sideJpeg: Uint8List(0),
      );
      await api.save(subject: subject, result: r);

      final page = await api.records(pageNum: 1, pageSize: 20);
      expect(page.total, 1);
      expect(page.records.first.customerName, '测试者');
      expect(page.records.first.qrCode, startsWith('CONTOUR-'));

      final detail = await api.recordDetail(page.records.first.id);
      expect(detail.parts, hasLength(21));
      expect(detail.parts.first.nameZh, isNotEmpty);

      await api.deleteRecord(page.records.first.id);
      final after = await api.records(pageNum: 1, pageSize: 20);
      expect(after.total, 0);
    });

    test('failNext hook surfaces a retryable failure once', () async {
      final api = await _api();
      api.failNext = true;
      expect(
        () => api.records(pageNum: 1, pageSize: 10),
        throwsA(isA<Object>()),
      );
      // next call succeeds
      final page = await api.records(pageNum: 1, pageSize: 10);
      expect(page.total, 0);
    });
  });
}
