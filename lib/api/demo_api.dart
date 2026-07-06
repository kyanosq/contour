import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import 'measure_api.dart';

/// The canonical 21 measurement fields (MeasurePlatform FIELDS_CN/EN order).
const demoFieldsZh = [
  '胸围', '通裆', '中腰', '领围', '总肩宽', '右腕围', '左腕围', '臀围', '腰围',
  '上臂围', '前肩宽', '左袖长', '左裤长', '右袖长', '右裤长', '后衣长',
  '前腰高', '前腰节长', '后腰高', '后腰节长', '腿根围',
];

const demoFieldsEn = [
  'Chest', 'U rise', 'Mid waist', 'Neck', 'Shoulder width', 'Right wrist',
  'Left wrist', 'Hip', 'Waist', 'Upper arm', 'Front shoulder', 'Left sleeve',
  'Left leg length', 'Right sleeve', 'Right leg length', 'Back length',
  'Front waist height', 'Front waist length', 'Back waist height',
  'Nape to waist', 'Thigh',
];

/// Deterministic anthropometric estimate (cm) for field [index] given the
/// subject. Not a medical model — plausible tailoring values derived from
/// height/weight/BMI with stable per-field jitter, so the demo feels real
/// and repeated runs are bit-identical (evaluation contract).
double demoEstimateCm({
  required int index,
  required double heightCm,
  required double weightKg,
  required Gender gender,
  required String seedText,
}) {
  final h = heightCm;
  final b = weightKg / pow(h / 100, 2); // BMI
  final male = gender == Gender.male;
  final d = b - 22.0;

  final shoulder = 0.26 * h + (male ? 1.0 : -1.0);
  final waist = 0.42 * h + 2.6 * d + (male ? 2 : -2);

  final base = switch (index) {
    0 => 0.53 * h + 1.8 * d + (male ? 0 : -2), // 胸围
    1 => 0.40 * h, // 通裆
    2 => waist + 2, // 中腰
    3 => 0.22 * h + 0.6 * d - (male ? 0 : 2), // 领围
    4 => shoulder, // 总肩宽
    5 || 6 => 0.095 * h + 0.25 * d, // 腕围
    7 => 0.54 * h + 2.0 * d + (male ? 0 : 3), // 臀围
    8 => waist, // 腰围
    9 => 0.165 * h + 1.0 * d, // 上臂围
    10 => shoulder - 3.5, // 前肩宽
    11 || 13 => 0.34 * h, // 袖长
    12 || 14 => 0.60 * h, // 裤长
    15 => 0.42 * h, // 后衣长
    16 => 0.595 * h, // 前腰高
    17 => 0.245 * h, // 前腰节长
    18 => 0.61 * h, // 后腰高
    19 => 0.24 * h, // 后腰节长
    _ => 0.31 * h + 1.6 * d, // 腿根围
  };

  // Stable jitter in [-0.9, +0.9] cm keyed by inputs + field.
  final seed = Object.hash(seedText, index, h.round(), weightKg.round());
  final jitter = ((seed % 1000) / 1000 - 0.5) * 1.8;
  return ((base + jitter) * 100).round() / 100;
}

/// Local, offline backend powering 体验模式 and automated evaluation.
class DemoMeasureApi implements MeasureApi {
  DemoMeasureApi(this._prefs, {this.latency = const Duration(milliseconds: 450)});

  final SharedPreferences _prefs;
  final Duration latency;

  static const _recordsKey = 'demo.records';
  static const _detailsKey = 'demo.details';
  static const _seqKey = 'demo.seq';

  /// Test hook: makes the next call fail once (error-state UX evaluation).
  bool failNext = false;

  Future<void> _work([double factor = 1]) async {
    await Future<void>.delayed(latency * factor);
    if (failNext) {
      failNext = false;
      throw ApiFailure('网络连接失败，请重试');
    }
  }

  List<Map<String, dynamic>> _loadRecords() {
    final raw = _prefs.getString(_recordsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  Future<void> _storeRecords(List<Map<String, dynamic>> rows) =>
      _prefs.setString(_recordsKey, jsonEncode(rows));

  Map<String, dynamic> _loadDetails() {
    final raw = _prefs.getString(_detailsKey);
    return raw == null ? {} : jsonDecode(raw) as Map<String, dynamic>;
  }

  @override
  Future<String> login(Map<String, String> credentials) async {
    await _work(0.6);
    return 'demo-token';
  }

  @override
  Future<RecordPage> records({
    required int pageNum,
    required int pageSize,
  }) async {
    await _work(0.5);
    final rows = _loadRecords();
    final start = (pageNum - 1) * pageSize;
    final page = rows.skip(start).take(pageSize).toList();
    return RecordPage(
      total: rows.length,
      records: [for (final r in page) MeasureRecord.fromJson(r)],
    );
  }

  @override
  Future<MeasureResult> measure({
    required Subject subject,
    required Uint8List frontJpeg,
    required Uint8List sideJpeg,
    Map<String, dynamic>? captureMetadata,
    Map<String, dynamic>? deviceInfo,
  }) async {
    // Long enough that the measuring choreography reads as a considered
    // moment (and is capturable by the evaluation walkthrough).
    await _work(3.4);
    final metric = subject.units == UnitSystem.metric;
    final parts = <Map<String, dynamic>>[
      for (var i = 0; i < demoFieldsZh.length; i++)
        () {
          final cm = demoEstimateCm(
            index: i,
            heightCm: subject.heightCm,
            weightKg: subject.weightKg,
            gender: subject.gender,
            seedText: subject.name,
          );
          final v = metric ? cm : cmToInch(cm);
          return {
            'partId': i + 1,
            'partName': demoFieldsZh[i],
            'partEnName': demoFieldsEn[i],
            'partValue': v.toStringAsFixed(2),
          };
        }(),
    ];
    return MeasureResult.fromJson({
      'customerId': DateTime.now().millisecondsSinceEpoch % 100000,
      'pzUserDetailId': 'demo-${subject.name.hashCode.toRadixString(16)}',
      'measureId': _prefs.getInt(_seqKey) ?? 1,
      'date': _now(),
      'partValues': parts,
    }, metric: metric);
  }

  @override
  Future<void> save({
    required Subject subject,
    required MeasureResult result,
  }) async {
    await _work();
    final id = (_prefs.getInt(_seqKey) ?? 0) + 1;
    await _prefs.setInt(_seqKey, id);

    final rows = _loadRecords();
    rows.insert(0, {
      'id': id,
      'customerName': subject.name,
      'tel': subject.contact,
      'gender': subject.gender.code,
      'qrCode': 'CONTOUR-$id-${subject.name.hashCode.toRadixString(16)}',
      'operationTime': _now(),
    });
    await _storeRecords(rows);

    final details = _loadDetails();
    details['$id'] = result.toJson();
    await _prefs.setString(_detailsKey, jsonEncode(details));
  }

  @override
  Future<MeasureResult> recordDetail(int id) async {
    await _work(0.5);
    final raw = _loadDetails()['$id'];
    if (raw == null) throw ApiFailure('记录不存在');
    final json = (raw as Map<String, dynamic>);
    // Rebuild display names (stored payload keeps only id/value, like the
    // legacy protocol).
    final parts = (json['partValues'] as List).cast<Map<String, dynamic>>();
    return MeasureResult.fromJson({
      ...json,
      'partValues': [
        for (final p in parts)
          {
            'partName': demoFieldsZh[(p['partId'] as int) - 1],
            'partEnName': demoFieldsEn[(p['partId'] as int) - 1],
            ...p,
          },
      ],
    }, metric: true);
  }

  @override
  Future<void> deleteRecord(int id) async {
    await _work(0.5);
    final rows = _loadRecords()..removeWhere((r) => r['id'] == id);
    await _storeRecords(rows);
    final details = _loadDetails()..remove('$id');
    await _prefs.setString(_detailsKey, jsonEncode(details));
  }

  @override
  Future<void> cancelAccount() async {
    await _work();
    await _prefs.remove(_recordsKey);
    await _prefs.remove(_detailsKey);
    await _prefs.remove(_seqKey);
  }

  @override
  Future<String?> privacyPolicy() async => null; // built-in text is used

  String _now() {
    final t = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} '
        '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }
}
