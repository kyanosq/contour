import 'dart:io';
import 'dart:math';

import 'level.dart';

/// Build the per-view capture metadata snapshot taken at shutter time.
/// Key names follow the MeasurePlatform capture_metadata contract
/// (mirrors the legacy iOS buildViewMeta).
Map<String, dynamic> buildViewMeta({
  required String view,
  required LevelReading level,
  required double gx,
  required double gy,
  required double gz,
  int? imageWidth,
  int? imageHeight,
  String lens = 'back',
}) {
  double r2(double v) => (v * 100).round() / 100;
  double r3(double v) => (v * 1000).round() / 1000;
  return {
    'view': view,
    'pitch_deg': r2(level.pitchDeg),
    'roll_deg': r2(level.rollDeg),
    'gravity': [r3(gx), r3(gy), r3(gz)],
    'lens': lens,
    'width': ?imageWidth,
    'height': ?imageHeight,
    'ts': DateTime.now().toUtc().toIso8601String(),
  };
}

/// Gravity magnitude sanity (used to reject bogus simulator streams).
bool gravityPlausible(double gx, double gy, double gz) {
  final g = sqrt(gx * gx + gy * gy + gz * gz);
  return g > 6.0 && g < 14.0;
}

Map<String, dynamic> buildDeviceInfo({required String appVersion}) => {
      'platform': Platform.operatingSystem,
      'os_version': Platform.operatingSystemVersion,
      'app_version': appVersion,
      'capture_client': 'contour',
    };
