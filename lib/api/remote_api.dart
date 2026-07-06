import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../models/models.dart';
import 'measure_api.dart';

/// Production backend — a field-faithful port of the legacy emeasure
/// customerwx protocol (see docs/plan/product.md §6 for the endpoint map).
class RemoteMeasureApi implements MeasureApi {
  RemoteMeasureApi(this._dio);

  final Dio _dio;

  @override
  Future<String> login(Map<String, String> credentials) async {
    try {
      // Step 1: checkUser -> openid (accepts {username,password} or {deviceId}).
      final check =
          await _dio.post('/app/pzuserdetail/checkUser', data: credentials);
      final openid = '${check.data}';
      // Step 2: login -> raw token string used as the Authorization header.
      final login = await _dio.post('/login',
          queryParameters: {'username': openid, 'srdzflag': 'WX'});
      return '${login.data}';
    } on DioException catch (e) {
      throw _failure(e);
    }
  }

  @override
  Future<RecordPage> records({
    required int pageNum,
    required int pageSize,
  }) async {
    try {
      final res = await _dio.get('/app/customerwx/newCustomerWxList',
          queryParameters: {'pageSize': pageSize, 'pageNum': pageNum});
      final data = res.data as Map<String, dynamic>;
      return RecordPage(
        total: int.tryParse('${data['total']}') ?? 0,
        records: [
          for (final row in (data['data'] as List<dynamic>? ?? []))
            MeasureRecord.fromJson(row as Map<String, dynamic>),
        ],
      );
    } on DioException catch (e) {
      throw _failure(e);
    }
  }

  @override
  Future<MeasureResult> measure({
    required Subject subject,
    required Uint8List frontJpeg,
    required Uint8List sideJpeg,
    Map<String, dynamic>? captureMetadata,
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      final params = <String, dynamic>{
        ...subject.toParams(),
        'imgF': base64Encode(frontJpeg),
        'imgS': base64Encode(sideJpeg),
        'capture_metadata': ?captureMetadata,
        'device_info': ?deviceInfo,
      };
      final res =
          await _dio.post('/app/customerwx/newGetCustomerPart', data: params);
      return MeasureResult.fromJson(
        res.data as Map<String, dynamic>,
        metric: subject.units == UnitSystem.metric,
      );
    } on DioException catch (e) {
      throw _failure(e);
    }
  }

  @override
  Future<void> save({
    required Subject subject,
    required MeasureResult result,
  }) async {
    try {
      await _dio.post('/app/customerwx/newUpdateCustomerSize',
          data: {...subject.toParams(), ...result.toJson()});
    } on DioException catch (e) {
      throw _failure(e);
    }
  }

  @override
  Future<MeasureResult> recordDetail(int id) async {
    try {
      final res = await _dio
          .post('/app/customerwx/customerWxDetail', data: {'id': id});
      return MeasureResult.fromJson(
        res.data as Map<String, dynamic>,
        metric: true,
      );
    } on DioException catch (e) {
      throw _failure(e);
    }
  }

  @override
  Future<void> deleteRecord(int id) async {
    try {
      await _dio.delete('/app/customerwx', queryParameters: {'id': id});
    } on DioException catch (e) {
      throw _failure(e);
    }
  }

  @override
  Future<void> cancelAccount() async {
    try {
      await _dio.post('/app/pzuserdetail/cancel');
    } on DioException catch (e) {
      throw _failure(e);
    }
  }

  @override
  Future<String?> privacyPolicy() async {
    try {
      final res =
          await _dio.get('/privacyPolicy', queryParameters: {'type': 3});
      final data = res.data;
      if (data is Map<String, dynamic>) {
        return data['content'] as String? ?? data['data']?.toString();
      }
      return data?.toString();
    } on DioException {
      return null; // caller falls back to the built-in text
    }
  }

  ApiFailure _failure(DioException e) {
    final unauthorized = e.response?.statusCode == 401;
    final body = e.response?.data;
    String? serverMsg;
    if (body is Map<String, dynamic>) {
      serverMsg = (body['msg'] ?? body['message'])?.toString();
    }
    return ApiFailure(
      serverMsg ?? e.message ?? 'network error',
      unauthorized: unauthorized,
    );
  }
}
