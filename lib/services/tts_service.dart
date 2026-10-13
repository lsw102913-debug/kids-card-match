import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage('ko-KR');
      // Cheerful, friendly voice suitable for 4-5 year old children
      await _flutterTts.setPitch(1.3);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS init error (fallback enabled): $e');
    }
  }

  Future<void> speakCardMatch(String cardName) async {
    try {
      if (!_isInitialized) await init();
      await _flutterTts.stop();
      // Cheerful praise with card name!
      await _flutterTts.speak('$cardName!');
    } catch (e) {
      debugPrint('TTS speak error: $e');
    }
  }

  Future<void> speakVictory() async {
    try {
      if (!_isInitialized) await init();
      await _flutterTts.stop();
      await _flutterTts.speak('우와! 참 잘했어요! 만점이에요!');
    } catch (e) {
      debugPrint('TTS victory speak error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }
}
