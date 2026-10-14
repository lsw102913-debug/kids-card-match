import 'package:flutter/material.dart';
import '../models/game_data.dart';
import '../services/score_service.dart';

class VictoryDialog extends StatelessWidget {
  final int moves;
  final Difficulty difficulty;
  final ScoreResult? scoreResult;
  final VoidCallback onPlayAgain;
  final VoidCallback onChangeLevel;

  const VictoryDialog({
    super.key,
    required this.moves,
    required this.difficulty,
    this.scoreResult,
    required this.onPlayAgain,
    required this.onChangeLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 12,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 6),
                  const Text('🏆', style: TextStyle(fontSize: 36)),
                  const SizedBox(width: 6),
                  const Text('⭐', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    '참 잘했어요! 만점! 🎉',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFF4081),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Current Play Summary Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🎮 ${difficulty.title}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '🎯 시도: $moves회',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE65100),
                      ),
                    ),
                    if (scoreResult != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        '⏱️ 시간: ${scoreResult!.newRecord.formattedTime}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF00897B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Leaderboard (Top 5)
              if (scoreResult != null) _buildLeaderboardCard(),

              const SizedBox(height: 14),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF80AB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onPlayAgain();
                      },
                      child: const Text(
                        '한 번 더! 🔄',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF80D8FF),
                        foregroundColor: const Color(0xFF01579B),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onChangeLevel();
                      },
                      child: const Text(
                        '난이도 변경 🆙',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardCard() {
    final result = scoreResult!;
    final top5 = result.top5;
    final currentRecord = result.newRecord;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7FE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1BEE7), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('🏅', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              const Text(
                '명예의 전당 Top 5',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4A148C),
                ),
              ),
              const Spacer(),
              if (result.isInTop5)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4081),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '🎉 ${result.rank}위 등극!',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Top 5 Rows
          ...List.generate(5, (index) {
            final rank = index + 1;
            final hasRecord = index < top5.length;
            final record = hasRecord ? top5[index] : null;
            final isCurrentRun = hasRecord && record == currentRecord;

            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isCurrentRun
                    ? const Color(0xFFFFF0F5)
                    : (index.isEven ? Colors.white : const Color(0xFFF5F5FA)),
                borderRadius: BorderRadius.circular(8),
                border: isCurrentRun
                    ? Border.all(color: const Color(0xFFFF4081), width: 1.5)
                    : null,
              ),
              child: Row(
                children: [
                  _buildRankBadge(rank),
                  const SizedBox(width: 8),
                  if (hasRecord) ...[
                    Text(
                      record!.formattedTime,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isCurrentRun ? const Color(0xFFFF4081) : const Color(0xFF263238),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '(${record.moves}회 시도)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (isCurrentRun)
                      const Text(
                        '✨ 해린이 이번 기록!',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFF4081),
                        ),
                      ),
                  ] else ...[
                    Text(
                      '- 도전 대기 중 🎯 -',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),

          // OUTSIDE TOP 5 NOTICE
          if (!result.isInTop5) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFB300), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🚩', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        '이번 기록: ${currentRecord.formattedTime} (${result.rank}위 - 순위권 밖)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    top5.isNotEmpty
                        ? '아쉽지만 5등(${top5.last.formattedTime})까지 조금만 더 힘내봐요! 해린이 다음엔 5등 안에 쏙! 💪'
                        : '다음엔 더 빠르게 5등 안에 도전해봐요! 해린이 화이팅! 💖',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6D4C41),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    switch (rank) {
      case 1:
        return const Text('🥇 1위', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold));
      case 2:
        return const Text('🥈 2위', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold));
      case 3:
        return const Text('🥉 3위', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold));
      default:
        return Text(
          '  $rank위',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF78909C),
          ),
        );
    }
  }
}
