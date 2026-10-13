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
  CardCategory _currentCategory = CardCategory.animals;
  Difficulty _currentDifficulty = Difficulty.easy;

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

        _confettiController.blast();

        // Check victory
        if (_matchedPairs == _currentDifficulty.pairCount) {
          Future.delayed(const Duration(milliseconds: 650), () {
            if (mounted) _showVictoryDialog();
          });
        }
      } else {
        // MISMATCH -> Flip back after brief delay
        Future.delayed(const Duration(milliseconds: 900), () {
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '난이도를 골라보아요! 🌟',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...Difficulty.values.map(
                (d) => ListTile(
                  title: Text(d.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  trailing: _currentDifficulty == d ? const Icon(Icons.check_circle, color: Colors.pink) : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    startNewGame(difficulty: d);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeInfo = GameData.themes.firstWhere((t) => t.category == _currentCategory);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(themeInfo.icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 8),
            Text(
              '${themeInfo.title} 짝 맞추기',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF37474F),
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 30, color: Color(0xFFFF4081)),
            tooltip: '새 게임 시작',
            onPressed: () => startNewGame(),
          ),
        ],
      ),
      body: ConfettiOverlay(
        controller: _confettiController,
        child: SafeArea(
          child: Column(
            children: [
              // Theme & Difficulty Bar
              _buildControlPanel(),
              const SizedBox(height: 8),
              // Status Indicator (Moves, Pairs)
              _buildStatusBar(),
              const SizedBox(height: 12),
              // Main Card Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildCardGrid(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Theme Selectors
          ...GameData.themes.map((theme) {
            final isSelected = _currentCategory == theme.category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('${theme.icon} ${theme.title}'),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF546E7A),
                ),
                selected: isSelected,
                selectedColor: const Color(0xFFFF80AB),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                side: BorderSide(
                  color: isSelected ? const Color(0xFFFF80AB) : const Color(0xFFE0E0E0),
                ),
                onSelected: (val) {
                  if (val) startNewGame(category: theme.category);
                },
              ),
            );
          }),
          const SizedBox(width: 8),
          // Difficulty Selector Button
          ActionChip(
            avatar: const Text('🎮'),
            label: Text(_currentDifficulty.title),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0277BD)),
            backgroundColor: const Color(0xFFE1F5FE),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: _openLevelPicker,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 6),
                Text(
                  '시도: $_moves 회',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF455A64),
                  ),
                ),
              ],
            ),
            Container(height: 20, width: 1.5, color: const Color(0xFFECEFF1)),
            Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 6),
                Text(
                  '찾은 짝: $_matchedPairs / ${_currentDifficulty.pairCount}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                  ),
                ),
              ],
            ),
          ],
        ),
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

        // Calculate aspect ratio that nicely fits the cards in the screen
        final itemWidth = (availableWidth - (crossCount - 1) * 12) / crossCount;
        final itemHeight = (availableHeight - (rowCount - 1) * 12) / rowCount;
        final aspectRatio = (itemWidth / itemHeight).clamp(0.72, 1.15);

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
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
