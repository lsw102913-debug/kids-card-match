import 'package:flutter/material.dart';

class VictoryDialog extends StatelessWidget {
  final int moves;
  final VoidCallback onPlayAgain;
  final VoidCallback onChangeLevel;

  const VictoryDialog({
    super.key,
    required this.moves,
    required this.onPlayAgain,
    required this.onChangeLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 12,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cheerful Icon
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF9C4),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🏆', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 16),
            // Title
            const Text(
              '참 잘했어요! 🎉',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFF4081),
              ),
            ),
            const SizedBox(height: 8),
            // Star rating
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('⭐', style: TextStyle(fontSize: 32)),
                SizedBox(width: 6),
                Text('⭐', style: TextStyle(fontSize: 40)),
                SizedBox(width: 6),
                Text('⭐', style: TextStyle(fontSize: 32)),
              ],
            ),
            const SizedBox(height: 12),
            // Message
            Text(
              '우와! $moves번 만에 모두 찾았어요!\n우리 아이 기억력 최고예요! 👏',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF455A64),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF80AB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onPlayAgain();
                    },
                    child: const Text(
                      '한 번 더! 🔄',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF80D8FF),
                      foregroundColor: const Color(0xFF01579B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onChangeLevel();
                    },
                    child: const Text(
                      '난이도 변경 🆙',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
