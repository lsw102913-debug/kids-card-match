import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_data.dart';

class ScoreRecord {
  final int clearTimeMs;
  final DateTime achievedAt;
  final int moves;

  const ScoreRecord({
    required this.clearTimeMs,
    required this.achievedAt,
    required this.moves,
  });

  String get formattedTime {
    final totalSeconds = clearTimeMs / 1000.0;
    if (totalSeconds < 60) {
      return '${totalSeconds.toStringAsFixed(1)}초';
    }
    final mins = clearTimeMs ~/ 60000;
    final secs = (clearTimeMs % 60000) / 1000.0;
    return '$mins분 ${secs.toStringAsFixed(1)}초';
  }

  Map<String, dynamic> toJson() => {
    'clearTimeMs': clearTimeMs,
    'achievedAt': achievedAt.toIso8601String(),
    'moves': moves,
  };

  factory ScoreRecord.fromJson(Map<String, dynamic> json) => ScoreRecord(
    clearTimeMs: json['clearTimeMs'] as int? ?? 0,
    achievedAt: DateTime.tryParse(json['achievedAt'] as String? ?? '') ?? DateTime.now(),
    moves: json['moves'] as int? ?? 0,
  );
}

class ScoreResult {
  final ScoreRecord newRecord;
  final int rank; // 1-indexed (1: 1st, 2: 2nd, etc.)
  final bool isInTop5;
  final List<ScoreRecord> top5;

  const ScoreResult({
    required this.newRecord,
    required this.rank,
    required this.isInTop5,
    required this.top5,
  });
}

class ScoreService {
  static final ScoreService _instance = ScoreService._internal();
  factory ScoreService() => _instance;
  ScoreService._internal();

  String _getKey(Difficulty difficulty) => 'leaderboard_v1_${difficulty.name}';

  /// Get top scores for a difficulty (up to [limit], default 5)
  Future<List<ScoreRecord>> getTopRecords(Difficulty difficulty, {int limit = 5}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_getKey(difficulty));
      if (jsonString == null || jsonString.isEmpty) return [];

      final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
      final records = list
          .map((item) => ScoreRecord.fromJson(item as Map<String, dynamic>))
          .toList();

      records.sort((a, b) {
        final timeCmp = a.clearTimeMs.compareTo(b.clearTimeMs);
        if (timeCmp != 0) return timeCmp;
        return a.moves.compareTo(b.moves);
      });

      return records.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting top records: $e');
      return [];
    }
  }

  /// Record a new game clear time and return the rank & leaderboard
  Future<ScoreResult> recordClearTime({
    required Difficulty difficulty,
    required int clearTimeMs,
    required int moves,
  }) async {
    final newRecord = ScoreRecord(
      clearTimeMs: clearTimeMs,
      achievedAt: DateTime.now(),
      moves: moves,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_getKey(difficulty));
      List<ScoreRecord> allRecords = [];

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
        allRecords = list
            .map((item) => ScoreRecord.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      allRecords.add(newRecord);
      allRecords.sort((a, b) {
        final timeCmp = a.clearTimeMs.compareTo(b.clearTimeMs);
        if (timeCmp != 0) return timeCmp;
        return a.moves.compareTo(b.moves);
      });

      // Find 1-based rank of the new record
      final rank = allRecords.indexOf(newRecord) + 1;
      final isInTop5 = rank <= 5;

      // Persist top 10 to keep storage tidy while allowing accurate rank lookup
      final toSave = allRecords.take(10).toList();
      final encoded = jsonEncode(toSave.map((r) => r.toJson()).toList());
      await prefs.setString(_getKey(difficulty), encoded);

      final top5 = allRecords.take(5).toList();

      return ScoreResult(
        newRecord: newRecord,
        rank: rank,
        isInTop5: isInTop5,
        top5: top5,
      );
    } catch (e) {
      debugPrint('Error recording clear time: $e');
      return ScoreResult(
        newRecord: newRecord,
        rank: 1,
        isInTop5: true,
        top5: [newRecord],
      );
    }
  }

  /// Reset records for difficulty (e.g. for testing)
  Future<void> clearRecords(Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getKey(difficulty));
  }
}
