import 'dart:typed_data';

import '../models/models.dart';

/// A user-facing failure with a presentable message.
class ApiFailure implements Exception {
  ApiFailure(this.message, {this.unauthorized = false});

  final String message;
  final bool unauthorized;

  @override
  String toString() => message;
}

/// The measurement backend contract. Two implementations:
///  * [RemoteMeasureApi] — the production customerwx protocol.
///  * [DemoMeasureApi]  — local deterministic fixtures (体验模式 / evaluation).
abstract interface class MeasureApi {
  /// Exchange credentials for an auth token. [credentials] carries either
  /// {username, password} or {deviceId} exactly like the legacy checkUser.
  Future<String> login(Map<String, String> credentials);

  Future<RecordPage> records({required int pageNum, required int pageSize});

  /// Upload photos + subject and receive editable measurements.
  Future<MeasureResult> measure({
    required Subject subject,
    required Uint8List frontJpeg,
    required Uint8List sideJpeg,
    Map<String, dynamic>? captureMetadata,
    Map<String, dynamic>? deviceInfo,
  });

  /// Persist (possibly hand-corrected) measurements.
  Future<void> save({
    required Subject subject,
    required MeasureResult result,
  });

  Future<MeasureResult> recordDetail(int id);

  Future<void> deleteRecord(int id);

  /// Server-side account deletion (注销).
  Future<void> cancelAccount();

  /// Remote privacy policy text; implementations must fall back gracefully.
  Future<String?> privacyPolicy();
}
