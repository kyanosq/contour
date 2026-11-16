import 'package:flutter/foundation.dart';

import '../models/models.dart';

/// State of one measuring funnel run: subject → photos → result.
/// Lives at app scope; [reset] starts a fresh run.
class MeasureFlow extends ChangeNotifier {
  Subject subject = Subject();

  Uint8List? frontJpeg;
  Uint8List? sideJpeg;
  final CaptureMetadata captureMetadata = CaptureMetadata();
  Map<String, dynamic>? deviceInfo;

  MeasureResult? result;

  /// True when both photos exist and measuring can start.
  bool get readyToMeasure => frontJpeg != null && sideJpeg != null;

  void reset() {
    final units = subject.units; // unit preference survives runs
    subject = Subject(units: units);
    frontJpeg = null;
    sideJpeg = null;
    captureMetadata.views.clear();
    deviceInfo = null;
    result = null;
    notifyListeners();
  }

  void setPhoto(String view, Uint8List jpeg, Map<String, dynamic> meta) {
    if (view == 'front') {
      frontJpeg = jpeg;
    } else {
      sideJpeg = jpeg;
    }
    captureMetadata.putView(view, meta);
    notifyListeners();
  }

  /// Merge extra keys (e.g. the user-marked belt line) into an already
  /// captured view's metadata.
  void annotateView(String view, Map<String, dynamic> extra) {
    captureMetadata.views[view]?.addAll(extra);
  }

  void setResult(MeasureResult r) {
    result = r;
    notifyListeners();
  }

  void touch() => notifyListeners();
}
