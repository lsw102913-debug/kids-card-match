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
      await _flutterTts.setSpeechRate(0.51);
      await _flutterTts.setPitch(1.32);
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
      '딩동댕! 해린아, $cardName 짝꿍 맞았네!',
      '정답! 우리 해린이 기억력 최고야!',
      '우와, 맞았어! 역시 해린이야!',
      '대단해! 해린이가 $cardName 짝을 쏙 찾았네!',
      '참 잘했어! 우리 해린이 멋쟁이!',
    ];
    final phrase = phrases[_rng.nextInt(phrases.length)];

    try {
      if (!_isInitialized) await init();
      await _flutterTts.stop();
      await _flutterTts.setPitch(1.32);
      await _flutterTts.setSpeechRate(0.50);
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
      '어라? 해린아, 다른 친구네~ 다시 찾아보자!',
      '앗 해린아, 아쉬워라! 다른 그림이야~',
      '에구구 해린아, 이건 짝꿍이 아니야~',
      '삐빅! 다른 친구네? 해린아 다시 해볼까?',
      '아이쿠! 해린아 짝꿍이 어디 숨었을까?',
    ];
    final phrase = phrases[_rng.nextInt(phrases.length)];

    try {
      if (!_isInitialized) await init();
      await _flutterTts.stop();
      // Playful, cheerful, high-spirited tone
      await _flutterTts.setPitch(1.46);
      await _flutterTts.setSpeechRate(0.52);
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
      await _flutterTts.setSpeechRate(0.50);
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
