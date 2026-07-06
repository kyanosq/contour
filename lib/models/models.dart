import 'dart:convert';

/// Gender codes as the customerwx protocol expects.
enum Gender {
  male('1'),
  female('2');

  final String code;
  const Gender(this.code);

  static Gender fromCode(dynamic code) =>
      Gender.values.where((g) => g.code == '$code').firstOrNull ?? Gender.male;
}

/// Garment fit — the model's `top_fit` stratification input.
enum TopFit {
  fit('fit'),
  loose('loose');

  final String code;
  const TopFit(this.code);
}

/// Display unit system. Storage is ALWAYS metric (cm/kg); imperial is a view.
enum UnitSystem { metric, imperial }

/// Unit codes the legacy protocol expects (heightunitid / weightunitid).
extension UnitCodes on UnitSystem {
  String get heightCode => this == UnitSystem.metric ? '1' : '2';
  String get weightCode => this == UnitSystem.metric ? '1' : '2';
}

const double cmPerInch = 2.54;
const double lbPerKg = 2.2046;

double cmToInch(double cm) => cm / cmPerInch;
double inchToCm(double inch) => inch * cmPerInch;
double kgToLb(double kg) => kg * lbPerKg;
double lbToKg(double lb) => lb / lbPerKg;

/// Client mirror of the server-side data-collection standard
/// (MeasurePlatform model_config input_validation).
abstract final class CaptureStandard {
  static const double minHeightCm = 120;
  static const double maxHeightCm = 220;
  static const double minWeightKg = 30;
  static const double maxWeightKg = 200;

  static bool heightValid(double cm) => cm >= minHeightCm && cm <= maxHeightCm;
  static bool weightValid(double kg) => kg >= minWeightKg && kg <= maxWeightKg;
}

/// The person being measured, plus capture-time declarations.
class Subject {
  Subject({
    this.name = '',
    this.contact = '',
    this.gender = Gender.male,
    this.topFit = TopFit.fit,
    this.heightCm = 172,
    this.weightKg = 65,
    this.units = UnitSystem.metric,
  });

  String name;
  String contact;
  Gender gender;
  TopFit topFit;
  double heightCm;
  double weightKg;
  UnitSystem units;

  /// Legacy-protocol request fields (numbers rendered in the DISPLAY unit,
  /// exactly like the original client did).
  Map<String, dynamic> toParams() {
    final height = units == UnitSystem.metric ? heightCm : cmToInch(heightCm);
    final weight = units == UnitSystem.metric ? weightKg : kgToLb(weightKg);
    return {
      'name': name,
      'tel': contact,
      'gender': gender.code,
      'height': height.toStringAsFixed(2),
      'weight': weight.toStringAsFixed(2),
      'heightunitid': units.heightCode,
      'weightunitid': units.weightCode,
      'top_fit': topFit.code,
    };
  }
}

/// One measured part. Values are stored in the unit the server returned
/// (display unit), same as the legacy client contract.
class Part {
  Part({
    required this.partId,
    required this.nameZh,
    required this.nameEn,
    required this.value,
    this.lower,
    this.upper,
  });

  final int partId;
  final String nameZh;
  final String nameEn;
  double value;
  final double? lower;
  final double? upper;

  bool get valid {
    if (lower != null && value < lower!) return false;
    if (upper != null && value > upper!) return false;
    return true;
  }

  factory Part.fromJson(Map<String, dynamic> json, {required bool metric}) {
    final raw = double.tryParse('${json['partValue']}') ?? 0;
    // Legacy edit envelope: ±10 cm (±4 in) around the model's estimate.
    final delta = metric ? 10.0 : 4.0;
    return Part(
      partId: json['partId'] as int,
      nameZh: json['partName'] as String? ?? '',
      nameEn: json['partEnName'] as String? ?? '',
      value: raw,
      lower: ((raw - delta).clamp(0, double.infinity) * 100).round() / 100,
      upper: ((raw + delta) * 100).round() / 100,
    );
  }

  Map<String, dynamic> toJson() => {
        'partId': partId,
        'partValue': value.toStringAsFixed(2),
      };
}

/// Result of a measurement request (legacy TempDetails).
class MeasureResult {
  MeasureResult({
    this.customerId,
    this.pzUserDetailId,
    this.measureId,
    this.date,
    required this.parts,
  });

  final int? customerId;
  final String? pzUserDetailId;
  final int? measureId;
  final String? date;
  final List<Part> parts;

  factory MeasureResult.fromJson(Map<String, dynamic> json,
      {required bool metric}) {
    return MeasureResult(
      customerId: json['customerId'] as int?,
      pzUserDetailId: json['pzUserDetailId'] as String?,
      measureId: json['measureId'] as int?,
      date: json['date'] as String?,
      parts: [
        for (final p in (json['partValues'] as List<dynamic>? ?? []))
          Part.fromJson(p as Map<String, dynamic>, metric: metric),
      ],
    );
  }

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'pzUserDetailId': pzUserDetailId,
        'measureId': measureId,
        'date': date,
        'partValues': [for (final p in parts) p.toJson()],
      };
}

/// A saved measurement record (list row).
class MeasureRecord {
  MeasureRecord({
    required this.id,
    this.customerName,
    this.tel,
    this.gender,
    this.qrCode,
    this.operationTime,
    this.imgF,
    this.imgS,
  });

  final int id;
  final String? customerName;
  final String? tel;
  final String? gender;
  final String? qrCode;
  final String? operationTime;
  final String? imgF;
  final String? imgS;

  factory MeasureRecord.fromJson(Map<String, dynamic> json) => MeasureRecord(
        id: int.tryParse('${json['id']}') ?? 0,
        customerName: json['customerName'] as String?,
        tel: json['tel'] as String?,
        gender: '${json['gender'] ?? ''}',
        qrCode: json['qrCode'] as String?,
        operationTime: json['operationTime'] as String?,
        imgF: json['imgF'] as String?,
        imgS: json['imgS'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerName': customerName,
        'tel': tel,
        'gender': gender,
        'qrCode': qrCode,
        'operationTime': operationTime,
        'imgF': imgF,
        'imgS': imgS,
      };
}

class RecordPage {
  RecordPage({required this.total, required this.records});

  final int total;
  final List<MeasureRecord> records;
}

/// Capture-time metadata, one entry per view. Key names follow the
/// MeasurePlatform capture_metadata contract (views.front / views.side).
class CaptureMetadata {
  final Map<String, Map<String, dynamic>> views = {};

  void putView(String view, Map<String, dynamic> meta) => views[view] = meta;

  String toJsonString() => jsonEncode({'views': views});
}

/// Device info blob persisted server-side for training audits.
Map<String, dynamic> deviceInfoJson({
  required String platform,
  required String model,
  required String appVersion,
}) =>
    {
      'platform': platform,
      'model': model,
      'app_version': appVersion,
      'capture_client': 'contour',
    };
