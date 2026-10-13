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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      elevation: 12,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cheerful Trophy & Stars row
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('⭐', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 8),
                  Text('🏆', style: TextStyle(fontSize: 48)),
                  SizedBox(width: 8),
                  Text('⭐', style: TextStyle(fontSize: 28)),
                ],
              ),
              const SizedBox(height: 10),
              // Title
              const Text(
                '참 잘했어요! 만점이에요! 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFF4081),
                ),
              ),
              const SizedBox(height: 6),
              // Message
              Text(
                '우와! $moves번 만에 모든 짝을 다 찾았어요!\n기억력 천재 꼬마 친구 최고예요! 👏',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF455A64),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 18),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF80AB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
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
      ),
    );
  }
}
