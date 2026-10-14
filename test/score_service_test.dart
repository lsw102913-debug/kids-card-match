import 'package:flutter_test/flutter_test.dart';
import 'package:kids_card_match/models/game_data.dart';
import 'package:kids_card_match/services/score_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ScoreService & Leaderboard Tests', () {
    final service = ScoreService();

    test('Recording new scores ranks them by fastest clear time', () async {
      // 1st entry: 20000ms (20.0s)
      final r1 = await service.recordClearTime(
        difficulty: Difficulty.master,
        clearTimeMs: 20000,
        moves: 15,
      );
      expect(r1.rank, 1);
      expect(r1.isInTop5, isTrue);
      expect(r1.top5.length, 1);
      expect(r1.newRecord.formattedTime, '20.0초');

      // 2nd entry: 15000ms (15.0s) -> should be new #1!
      final r2 = await service.recordClearTime(
        difficulty: Difficulty.master,
        clearTimeMs: 15000,
        moves: 12,
      );
      expect(r2.rank, 1);
      expect(r2.isInTop5, isTrue);
      expect(r2.top5.length, 2);
      expect(r2.top5.first.clearTimeMs, 15000);
      expect(r2.top5.last.clearTimeMs, 20000);

      // 3rd, 4th, 5th entries
      await service.recordClearTime(difficulty: Difficulty.master, clearTimeMs: 18000, moves: 14);
      await service.recordClearTime(difficulty: Difficulty.master, clearTimeMs: 22000, moves: 16);
      final r5 = await service.recordClearTime(difficulty: Difficulty.master, clearTimeMs: 25000, moves: 18);

      expect(r5.top5.length, 5);
      expect(r5.isInTop5, isTrue);

      // 6th entry: 35000ms -> should be rank 6 and OUTSIDE Top 5!
      final r6 = await service.recordClearTime(
        difficulty: Difficulty.master,
        clearTimeMs: 35000,
        moves: 24,
      );
      expect(r6.rank, 6);
      expect(r6.isInTop5, isFalse);
      expect(r6.top5.length, 5);
      expect(r6.top5.last.clearTimeMs, 25000);
      expect(r6.newRecord.formattedTime, '35.0초');
    });

    test('Different difficulties have isolated leaderboards', () async {
      await service.recordClearTime(difficulty: Difficulty.easy, clearTimeMs: 5000, moves: 2);
      await service.recordClearTime(difficulty: Difficulty.master, clearTimeMs: 40000, moves: 20);

      final easyRecords = await service.getTopRecords(Difficulty.easy);
      final masterRecords = await service.getTopRecords(Difficulty.master);

      expect(easyRecords.length, 1);
      expect(easyRecords.first.clearTimeMs, 5000);

      expect(masterRecords.length, 1);
      expect(masterRecords.first.clearTimeMs, 40000);
    });

    test('ScoreRecord formattedTime formats seconds and minutes correctly', () {
      final recSec = ScoreRecord(clearTimeMs: 14200, achievedAt: DateTime.now(), moves: 10);
      expect(recSec.formattedTime, '14.2초');

      final recMin = ScoreRecord(clearTimeMs: 75300, achievedAt: DateTime.now(), moves: 20);
      expect(recMin.formattedTime, '1분 15.3초');
    });
  });
}
