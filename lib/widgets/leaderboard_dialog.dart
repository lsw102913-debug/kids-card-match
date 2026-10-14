import 'package:flutter/material.dart';
import '../models/game_data.dart';
import '../services/score_service.dart';

class LeaderboardDialog extends StatefulWidget {
  final Difficulty initialDifficulty;

  const LeaderboardDialog({
    super.key,
    this.initialDifficulty = Difficulty.medium,
  });

  @override
  State<LeaderboardDialog> createState() => _LeaderboardDialogState();
}

class _LeaderboardDialogState extends State<LeaderboardDialog> {
  late Difficulty _selectedDifficulty;
  final ScoreService _scoreService = ScoreService();
  List<ScoreRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.initialDifficulty;
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    final list = await _scoreService.getTopRecords(_selectedDifficulty, limit: 5);
    if (mounted) {
      setState(() {
        _records = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 8),
                  const Text(
                    '명예의 전당 (Top 5)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4A148C),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Difficulty Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: Difficulty.values.map((d) {
                    final isSelected = _selectedDifficulty == d;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(d.title),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF37474F),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFFFF80AB),
                        backgroundColor: const Color(0xFFF0F4F8),
                        onSelected: (val) {
                          if (val) {
                            setState(() => _selectedDifficulty = d);
                            _loadRecords();
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // Records List
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F7FE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE1BEE7)),
                  ),
                  child: Column(
                    children: List.generate(5, (index) {
                      final rank = index + 1;
                      final hasRecord = index < _records.length;
                      final record = hasRecord ? _records[index] : null;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: index.isEven ? Colors.white : const Color(0xFFF5F5FA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _buildRankBadge(rank),
                            const SizedBox(width: 8),
                            if (hasRecord) ...[
                              Text(
                                record!.formattedTime,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF263238),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '(${record.moves}회 시도)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${record.achievedAt.month}/${record.achievedAt.day}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
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
                  ),
                ),
            ],
          ),
        ),
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
