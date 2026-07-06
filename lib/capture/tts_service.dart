import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Thin, failure-silent wrapper over the platform TTS. Voice guidance is an
/// enhancement — any error degrades to visual-only, never blocks capture.
class TtsService {
  TtsService();

  FlutterTts? _tts;
  bool _ready = false;
  bool _failed = false;

  Future<void> _ensure(String languageCode) async {
    if (_ready || _failed) return;
    try {
      final tts = FlutterTts();
      await tts.setLanguage(languageCode == 'zh' ? 'zh-CN' : 'en-US');
      await tts.setSpeechRate(0.5);
      await tts.setVolume(1.0);
      _tts = tts;
      _ready = true;
    } catch (e) {
      debugPrint('TTS unavailable: $e');
      _failed = true;
    }
  }

  Future<void> speak(String text, {required String languageCode}) async {
    await _ensure(languageCode);
    if (!_ready) return;
    try {
      await _tts!.stop();
      await _tts!.speak(text);
    } catch (e) {
      debugPrint('TTS speak failed: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _tts?.stop();
    } catch (_) {}
  }

  void dispose() {
    _tts?.stop();
  }
}
