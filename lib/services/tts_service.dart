import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final Random _rng = Random();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage('ko-KR');
      // Slower, clearer, and warmer speech rate for 4-5 year old kids
      await _flutterTts.setSpeechRate(0.42);
      await _flutterTts.setPitch(1.35);
      await _flutterTts.setVolume(1.0);
      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS init error (fallback enabled): $e');
    }
  }

  /// When cards match (returns spoken phrase for UI banner sync)
  Future<String> speakCardMatch(String cardName) async {
    final phrases = [
      '우와! 해린아, $cardName 찾았다!',
      '딩동댕! $cardName 짝꿍 맞았네!',
      '정답! 해린이 기억력 최고야!',
      '우와, 맞았어! 역시 해린이야!',
      '대단해! $cardName 짝을 쏙 찾았네!',
    ];
    final phrase = phrases[_rng.nextInt(phrases.length)];

    try {
      if (!_isInitialized) await init();
      await _flutterTts.stop();
      // Cheerful, joyful praise with natural pauses
      await _flutterTts.setPitch(1.35);
      await _flutterTts.setSpeechRate(0.42); // relaxed, gentle speed
      await _flutterTts.speak(phrase);
    } catch (e) {
      debugPrint('TTS speak error: $e');
    }
    return phrase;
  }

  /// When cards do NOT match (returns spoken playful phrase)
  Future<String> speakMismatch() async {
    final phrases = [
      '해린아, 이건 아닌데?? 헤헤',
      '어라? 다른 친구네~ 다시 찾아보자!',
      '앗, 아쉬워라! 다른 그림이야~',
      '에구구, 이건 짝꿍이 아니야~',
      '삐빅! 다른 친구네? 해린아 다시 해볼까?',
    ];
    final phrase = phrases[_rng.nextInt(phrases.length)];

    try {
      if (!_isInitialized) await init();
      await _flutterTts.stop();
      // Slightly higher, expressive, playful cartoon-like tone
      await _flutterTts.setPitch(1.42);
      await _flutterTts.setSpeechRate(0.43); // comfortably paced
      await _flutterTts.speak(phrase);
    } catch (e) {
      debugPrint('TTS mismatch error: $e');
    }
    return phrase;
  }

  /// When the entire game is cleared
  Future<String> speakVictory() async {
    final victoryPhrases = [
      '우와! 해린이가 모든 짝을 다 찾았어요! 만점! 최고야!',
      '만세! 해린이 기억력 천재 인정! 너무너무 잘했어!',
    ];
    final phrase = victoryPhrases[_rng.nextInt(victoryPhrases.length)];

    try {
      if (!_isInitialized) await init();
      await _flutterTts.stop();
      await _flutterTts.setPitch(1.35);
      await _flutterTts.setSpeechRate(0.42);
      await _flutterTts.speak(phrase);
    } catch (e) {
      debugPrint('TTS victory speak error: $e');
    }
    return phrase;
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }
}
