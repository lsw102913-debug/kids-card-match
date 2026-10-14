import 'package:flutter/material.dart';
import 'models/card_item.dart';
import 'models/game_data.dart';
import 'services/sound_service.dart';
import 'services/tts_service.dart';
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
  final TtsService _ttsService = TtsService();
  final SoundService _soundService = SoundService();

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
    _ttsService.init();
    startNewGame();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _ttsService.stop();
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

    // 1) Play cute bubble pop sound effect when card is tapped!
    _soundService.playCardTap();

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

        // 1) Read card name aloud cheerfully via TTS!
        _ttsService.speakCardMatch(card.name);

        // 2) Spectacular celebration burst with praise banner
        _confettiController.blast(message: '우와! ${card.name}! 🎉');

        // Check victory
        if (_matchedPairs == _currentDifficulty.pairCount) {
          Future.delayed(const Duration(milliseconds: 650), () {
            if (mounted) {
              _ttsService.speakVictory();
              _showVictoryDialog();
            }
          });
        }
      } else {
        // MISMATCH!
        // 1) Playful TTS voice for Hae-rin: "해린아 이건 아닌데??"
        _ttsService.speakMismatch();

        // 2) Show funny toast banner
        _confettiController.showMismatch('해린아 이건 아닌데?? 😜');

        // Flip back after brief delay
        Future.delayed(const Duration(milliseconds: 1050), () {
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
              // Main Card Grid maximized in landscape with ZERO clipping
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                  child: _buildAdaptiveCardGrid(),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
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
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF455A64),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFFFF80AB),
                        backgroundColor: const Color(0xFFF5F7FA),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0277BD),
                    ),
                    backgroundColor: const Color(0xFFE1F5FE),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    onPressed: _openLevelPicker,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Status Pills (Moves & Matches)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '🎯 시도: $_moves',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE65100),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFCE4EC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '⭐ 짝: $_matchedPairs / ${_currentDifficulty.pairCount}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC2185B),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Restart button
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 24, color: Color(0xFFFF4081)),
            tooltip: '새 게임 시작',
            visualDensity: VisualDensity.compact,
            onPressed: () => startNewGame(),
          ),
        ],
      ),
    );
  }

  /// Adaptive Card Grid that GUARANTEES 100% of cards fit without ANY scrolling or clipping!
  Widget _buildAdaptiveCardGrid() {
    final cols = _currentDifficulty.crossAxisCount;
    final rows = _currentDifficulty.rowCount;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availW = constraints.maxWidth;
        final availH = constraints.maxHeight;

        // Dynamic spacing based on card density so dense cards have compact gaps
        final spacing = cols >= 8 ? 6.0 : (cols >= 6 ? 8.0 : 10.0);

        final totalSpacingH = (cols - 1) * spacing;
        final totalSpacingV = (rows - 1) * spacing;

        final rawCardW = (availW - totalSpacingH) / cols;
        final rawCardH = (availH - totalSpacingV) / rows;

        double targetCardW = rawCardW;
        double targetCardH = rawCardH;

        const maxAspect = 1.05;
        const minAspect = 0.55;

        if (targetCardW / targetCardH > maxAspect) {
          targetCardW = targetCardH * maxAspect;
        } else if (targetCardW / targetCardH < minAspect) {
          targetCardH = targetCardW / minAspect;
        }

        final gridWidth = (targetCardW * cols) + totalSpacingH;
        final gridHeight = (targetCardH * rows) + totalSpacingV;
        final childAspect = targetCardW / targetCardH;

        return Center(
          child: SizedBox(
            width: gridWidth.clamp(0.0, availW),
            height: gridHeight.clamp(0.0, availH),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: childAspect,
              ),
              itemBuilder: (context, index) {
                return GameCardWidget(
                  key: ValueKey('card_${_cards[index].id}'),
                  card: _cards[index],
                  onTap: () => onCardTapped(index),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
