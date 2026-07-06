import 'dart:typed_data';

import 'package:contour/app/session.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Adapter stub: records the last request and answers with a fixed status.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.statusCode);

  final int statusCode;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    lastRequest = options;
    return ResponseBody.fromString('{}', statusCode,
        headers: {'content-type': ['application/json']});
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Authorization header carries the raw token (legacy convention)',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final session = Session(prefs);
    await session.signIn('tok-123', ApiMode.remote);

    final adapter = _StubAdapter(200);
    session.dio.httpClientAdapter = adapter;

    await session.dio.get('/ping');
    expect(adapter.lastRequest?.headers['Authorization'], 'tok-123');
  });

  test('401 clears the session so the router returns to login', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final session = Session(prefs);
    await session.signIn('tok-456', ApiMode.remote);
    expect(session.isAuthenticated, isTrue);

    session.dio.httpClientAdapter = _StubAdapter(401);

    await expectLater(session.dio.get('/records'), throwsA(isA<DioException>()));
    expect(session.isAuthenticated, isFalse);
  });

  test('non-401 failures keep the session', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final session = Session(prefs);
    await session.signIn('tok-789', ApiMode.remote);

    session.dio.httpClientAdapter = _StubAdapter(500);

    await expectLater(session.dio.get('/x'), throwsA(isA<DioException>()));
    expect(session.isAuthenticated, isTrue);
  });
}
