import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  Uint8List? _cachedPopWav;

  Uint8List _getPopWav() {
    if (_cachedPopWav != null) return _cachedPopWav!;
    const sampleRate = 44100;
    const duration = 0.08; // 80ms
    final sampleCount = (sampleRate * duration).toInt();
    final dataSize = sampleCount * 2;
    final totalSize = 44 + dataSize;

    final bytes = ByteData(totalSize);
    // RIFF
    bytes.setUint8(0, 0x52); bytes.setUint8(1, 0x49); bytes.setUint8(2, 0x46); bytes.setUint8(3, 0x46);
    bytes.setUint32(4, totalSize - 8, Endian.little);
    // WAVE
    bytes.setUint8(8, 0x57); bytes.setUint8(9, 0x41); bytes.setUint8(10, 0x56); bytes.setUint8(11, 0x45);
    // fmt 
    bytes.setUint8(12, 0x66); bytes.setUint8(13, 0x6D); bytes.setUint8(14, 0x74); bytes.setUint8(15, 0x20);
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);  // PCM
    bytes.setUint16(22, 1, Endian.little);  // Mono
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, sampleRate * 2, Endian.little);
    bytes.setUint16(32, 2, Endian.little);
    bytes.setUint16(34, 16, Endian.little);
    // data
    bytes.setUint8(36, 0x64); bytes.setUint8(37, 0x61); bytes.setUint8(38, 0x74); bytes.setUint8(39, 0x61);
    bytes.setUint32(40, dataSize, Endian.little);

    // Cheerful Bubble Pop frequency sweep (520Hz -> 1050Hz with volume decay)
    for (int i = 0; i < sampleCount; i++) {
      final t = i / sampleRate;
      final progress = i / sampleCount;
      final freq = 520.0 + (550.0 * progress);
      final amp = pow(1.0 - progress, 2.0);
      final sample = (sin(2.0 * pi * freq * t) * amp * 26000.0).clamp(-32767.0, 32767.0).toInt();
      bytes.setInt16(44 + i * 2, sample, Endian.little);
    }

    _cachedPopWav = bytes.buffer.asUint8List();
    return _cachedPopWav!;
  }

  /// Play cute tactile and audio pop sound when card is tapped
  Future<void> playCardTap() async {
    try {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.lightImpact();
      final wav = _getPopWav();
      await _player.play(BytesSource(wav), mode: PlayerMode.lowLatency);
    } catch (_) {}
  }
}
