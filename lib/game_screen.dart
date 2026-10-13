import 'package:flutter/material.dart';
import 'models/card_item.dart';
import 'models/game_data.dart';
import 'widgets/confetti_overlay.dart';
import 'widgets/game_card_widget.dart';
import 'widgets/victory_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  CardCategory _currentCategory = CardCategory.dinosaurs;
  Difficulty _currentDifficulty = Difficulty.medium;

  List<CardItem> _cards = [];
  int? _firstFlippedIndex;
  bool _isProcessing = false;
  int _moves = 0;
  int _matchedPairs = 0;

  final ConfettiController _confettiController = ConfettiController();

  // Public getters for testing
  List<CardItem> get cards => _cards;
  int get moves => _moves;
  int get matchedPairs => _matchedPairs;
  bool get isGameOver => _matchedPairs == _currentDifficulty.pairCount && _cards.isNotEmpty;
  Difficulty get currentDifficulty => _currentDifficulty;
  CardCategory get currentCategory => _currentCategory;

  @override
  void initState() {
    super.initState();
    startNewGame();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void startNewGame({Difficulty? difficulty, CardCategory? category}) {
    setState(() {
      if (difficulty != null) _currentDifficulty = difficulty;
      if (category != null) _currentCategory = category;

      _cards = GameData.generateDeck(
        category: _currentCategory,
        difficulty: _currentDifficulty,
      );
      _firstFlippedIndex = null;
      _isProcessing = false;
      _moves = 0;
      _matchedPairs = 0;
    });
  }

  void onCardTapped(int index) {
    if (_isProcessing) return;
    if (index < 0 || index >= _cards.length) return;
    final card = _cards[index];
    if (card.isMatched || card.isFaceUp) return;

    setState(() {
      card.isFaceUp = true;
    });

    if (_firstFlippedIndex == null) {
      // First card flipped
      _firstFlippedIndex = index;
    } else {
      // Second card flipped
      final firstIndex = _firstFlippedIndex!;
      final firstCard = _cards[firstIndex];
      _moves++;
      _isProcessing = true;

      if (firstCard.pairId == card.pairId) {
        // MATCH!
        setState(() {
          firstCard.isMatched = true;
          card.isMatched = true;
          _matchedPairs++;
          _firstFlippedIndex = null;
          _isProcessing = false;
        });

        // Spectacular celebration burst with praise banner
        _confettiController.blast(message: '우와! ${card.name} 짝을 찾았어요! 🎉');

        // Check victory
        if (_matchedPairs == _currentDifficulty.pairCount) {
          Future.delayed(const Duration(milliseconds: 650), () {
            if (mounted) _showVictoryDialog();
          });
        }
      } else {
        // MISMATCH -> Flip back after brief delay
        Future.delayed(const Duration(milliseconds: 850), () {
          if (mounted) {
            setState(() {
              firstCard.isFaceUp = false;
              card.isFaceUp = false;
              _firstFlippedIndex = null;
              _isProcessing = false;
            });
          }
        });
      }
    }
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => VictoryDialog(
        moves: _moves,
        onPlayAgain: () => startNewGame(),
        onChangeLevel: () => _openLevelPicker(),
      ),
    );
  }

  void _openLevelPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '어떤 난이도로 도전해볼까요? 🌟',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: Difficulty.values.map(
                  (d) {
                    final isSelected = _currentDifficulty == d;
                    return ActionChip(
                      avatar: isSelected
                          ? const Icon(Icons.check, size: 18, color: Colors.white)
                          : null,
                      label: Text(d.title),
                      labelStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : const Color(0xFF37474F),
                      ),
                      backgroundColor: isSelected
                          ? const Color(0xFFFF4081)
                          : const Color(0xFFF0F4F8),
                      onPressed: () {
                        Navigator.pop(ctx);
                        startNewGame(difficulty: d);
                      },
                    );
                  },
                ).toList(),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FE),
      body: ConfettiOverlay(
        controller: _confettiController,
        child: SafeArea(
          child: Column(
            children: [
              // Landscape Sleek Top Bar
              _buildLandscapeTopBar(),
              // Main Card Grid maximized in landscape
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                  child: _buildCardGrid(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLandscapeTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Theme Selectors (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...GameData.themes.map((theme) {
                    final isSelected = _currentCategory == theme.category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text('${theme.icon} ${theme.title}'),
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF455A64),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFFFF80AB),
                        backgroundColor: const Color(0xFFF5F7FA),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFFFF80AB) : Colors.transparent,
                        ),
                        onSelected: (val) {
                          if (val) startNewGame(category: theme.category);
                        },
                      ),
                    );
                  }),
                  // Difficulty Selector Pill
                  ActionChip(
                    avatar: const Text('🎮'),
                    label: Text(_currentDifficulty.title),
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0277BD),
                    ),
                    backgroundColor: const Color(0xFFE1F5FE),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onPressed: _openLevelPicker,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Status Pills (Moves & Matches)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '🎯 시도: $_moves',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE65100),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFCE4EC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '⭐ 짝: $_matchedPairs / ${_currentDifficulty.pairCount}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC2185B),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Restart button
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 26, color: Color(0xFFFF4081)),
            tooltip: '새 게임 시작',
            visualDensity: VisualDensity.compact,
            onPressed: () => startNewGame(),
          ),
        ],
      ),
    );
  }

  Widget _buildCardGrid() {
    final crossCount = _currentDifficulty.crossAxisCount;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        final rowCount = (_cards.length / crossCount).ceil();

        const spacing = 10.0;
        final itemWidth = (availableWidth - (crossCount - 1) * spacing) / crossCount;
        final itemHeight = (availableHeight - (rowCount - 1) * spacing) / rowCount;
        final aspectRatio = (itemWidth / itemHeight).clamp(0.7, 1.4);

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (context, index) {
            return GameCardWidget(
              key: ValueKey('card_${_cards[index].id}'),
              card: _cards[index],
              onTap: () => onCardTapped(index),
            );
          },
        );
      },
    );
  }
}
