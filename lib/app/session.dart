import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/demo_api.dart';
import '../api/measure_api.dart';
import '../api/remote_api.dart';

/// Which backend the session talks to.
enum ApiMode { remote, demo }

/// App-wide session: auth token, backend mode, locale + theme preferences.
/// Single source of truth, persisted to [SharedPreferences].
class Session extends ChangeNotifier {
  Session(this._prefs, {MeasureApi? demoApi}) : _demoOverride = demoApi {
    _token = _prefs.getString(_kToken) ?? '';
    _mode = ApiMode.values.asNameMap()[_prefs.getString(_kMode)] ??
        ApiMode.remote;
    _localeTag = _prefs.getString(_kLocale) ?? '';
    _themeMode = ThemeMode.values.asNameMap()[_prefs.getString(_kTheme)] ??
        ThemeMode.system;
    _privacyAccepted = _prefs.getBool(_kPrivacy) ?? false;
    _dio = _buildDio();
  }

  static const _kToken = 'session.token';
  static const _kMode = 'session.mode';
  static const _kLocale = 'session.locale';
  static const _kTheme = 'session.theme';
  static const _kPrivacy = 'session.privacyAccepted';

  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://apistore.rcmtm.com',
  );

  final SharedPreferences _prefs;
  final MeasureApi? _demoOverride;

  late String _token;
  late ApiMode _mode;
  late String _localeTag;
  late ThemeMode _themeMode;
  late bool _privacyAccepted;
  late Dio _dio;

  MeasureApi? _api;
  String appVersion = '';

  bool get isAuthenticated => _token.isNotEmpty;
  ApiMode get mode => _mode;
  bool get isDemo => _mode == ApiMode.demo;
  String get token => _token;
  bool get privacyAccepted => _privacyAccepted;

  /// null = follow system.
  Locale? get locale => _localeTag.isEmpty ? null : Locale(_localeTag);
  ThemeMode get themeMode => _themeMode;

  MeasureApi get api => _api ??= switch (_mode) {
        ApiMode.demo => _demoOverride ?? DemoMeasureApi(_prefs),
        ApiMode.remote => RemoteMeasureApi(_dio),
      };

  Dio get dio => _dio;

  Future<void> loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion = '${info.version} (${info.buildNumber})';
    } catch (_) {
      appVersion = '1.0.0';
    }
    notifyListeners();
  }

  Future<void> signIn(String token, ApiMode mode) async {
    _token = token;
    _mode = mode;
    _api = null;
    await _prefs.setString(_kToken, token);
    await _prefs.setString(_kMode, mode.name);
    notifyListeners();
  }

  Future<void> signOut() async {
    _token = '';
    _api = null;
    await _prefs.remove(_kToken);
    notifyListeners();
  }

  Future<void> acceptPrivacy() async {
    _privacyAccepted = true;
    await _prefs.setBool(_kPrivacy, true);
    notifyListeners();
  }

  Future<void> setLocaleTag(String tag) async {
    _localeTag = tag;
    await _prefs.setString(_kLocale, tag);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_kTheme, mode.name);
    notifyListeners();
  }

  Dio _buildDio() {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {'X-Channel': 'contour'},
    ));
    dio.interceptors.add(AuthInterceptor(this));
    return dio;
  }
}

/// Injects the raw token as Authorization (legacy convention) and clears the
/// session on 401 so the router redirects to login.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this.session);

  final Session session;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (session.token.isNotEmpty) {
      options.headers['Authorization'] = session.token;
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401 && session.isAuthenticated) {
      session.signOut();
    }
    handler.next(err);
  }
}
