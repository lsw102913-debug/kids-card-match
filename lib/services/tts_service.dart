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
      await _flutterTts.setPitch(1.3);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS init error (fallback enabled): $e');
    }
  }

  /// When cards match
  Future<void> speakCardMatch(String cardName) async {
    try {
      if (!_isInitialized) await init();
      await _flutterTts.stop();
      await _flutterTts.setPitch(1.3);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.speak('해린아 $cardName 맞았어!');
    } catch (e) {
      debugPrint('TTS speak error: $e');
    }
  }

  /// When cards do NOT match (Playful, funny tone for Hae-rin!)
  Future<void> speakMismatch() async {
    try {
      if (!_isInitialized) await init();
      await _flutterTts.stop();
      // Funny, high-spirited, playful tone
      await _flutterTts.setPitch(1.48);
      await _flutterTts.setSpeechRate(0.55);
      await _flutterTts.speak('해린아 이건 아닌데??');
    } catch (e) {
      debugPrint('TTS mismatch error: $e');
    }
  }

  /// When the entire game is cleared
  Future<void> speakVictory() async {
    try {
      if (!_isInitialized) await init();
      await _flutterTts.stop();
      await _flutterTts.setPitch(1.35);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.speak('우와 해린이 최고! 모든 짝을 다 찾았어요! 만점!');
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
