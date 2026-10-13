import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_card_match/models/card_item.dart';
import 'package:kids_card_match/models/game_data.dart';
import 'package:kids_card_match/game_screen.dart';

void main() {
  group('GameData & Deck Generation Tests', () {
    test('Easy difficulty generates 4 cards (2 pairs)', () {
      final deck = GameData.generateDeck(
        category: CardCategory.dinosaurs,
        difficulty: Difficulty.easy,
      );
      expect(deck.length, 4);

      final pairCounts = <int, int>{};
      for (var card in deck) {
        pairCounts[card.pairId] = (pairCounts[card.pairId] ?? 0) + 1;
      }
      expect(pairCounts.length, 2);
      expect(pairCounts.values.every((cnt) => cnt == 2), isTrue);
    });

    test('Medium difficulty generates 6 cards (3 pairs)', () {
      final deck = GameData.generateDeck(
        category: CardCategory.animals,
        difficulty: Difficulty.medium,
      );
      expect(deck.length, 6);

      final pairCounts = <int, int>{};
      for (var card in deck) {
        pairCounts[card.pairId] = (pairCounts[card.pairId] ?? 0) + 1;
      }
      expect(pairCounts.length, 3);
      expect(pairCounts.values.every((cnt) => cnt == 2), isTrue);
    });

    test('Hard difficulty generates 12 cards (6 pairs)', () {
      final deck = GameData.generateDeck(
        category: CardCategory.fruits,
        difficulty: Difficulty.hard,
      );
      expect(deck.length, 12);

      final pairCounts = <int, int>{};
      for (var card in deck) {
        pairCounts[card.pairId] = (pairCounts[card.pairId] ?? 0) + 1;
      }
      expect(pairCounts.length, 6);
      expect(pairCounts.values.every((cnt) => cnt == 2), isTrue);
    });

    test('Expert difficulty generates 16 cards (8 pairs)', () {
      final deck = GameData.generateDeck(
        category: CardCategory.vehicles,
        difficulty: Difficulty.expert,
      );
      expect(deck.length, 16);

      final pairCounts = <int, int>{};
      for (var card in deck) {
        pairCounts[card.pairId] = (pairCounts[card.pairId] ?? 0) + 1;
      }
      expect(pairCounts.length, 8);
      expect(pairCounts.values.every((cnt) => cnt == 2), isTrue);
    });

    test('Master difficulty generates 20 cards (10 pairs) with dinosaurs', () {
      final deck = GameData.generateDeck(
        category: CardCategory.dinosaurs,
        difficulty: Difficulty.master,
      );
      expect(deck.length, 20);

      final pairCounts = <int, int>{};
      for (var card in deck) {
        pairCounts[card.pairId] = (pairCounts[card.pairId] ?? 0) + 1;
      }
      expect(pairCounts.length, 10);
      expect(pairCounts.values.every((cnt) => cnt == 2), isTrue);
    });
  });

  group('Game Widget & Matching Interaction Tests', () {
    testWidgets('Tapping matching cards updates state and finds pair in landscape', (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: GameScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final stateFinder = find.byType(GameScreen);
      expect(stateFinder, findsOneWidget);
      final state = tester.state<GameScreenState>(stateFinder);

      // Default medium mode = 6 cards
      expect(state.cards.length, 6);
      expect(state.moves, 0);
      expect(state.matchedPairs, 0);

      // Find indices of a matching pair
      final firstPairId = state.cards[0].pairId;
      final secondCardIndex = state.cards.indexWhere(
        (c) => c.pairId == firstPairId && c.id != state.cards[0].id,
      );
      expect(secondCardIndex, isNot(-1));

      // Tap first card
      state.onCardTapped(0);
      await tester.pump();
      expect(state.cards[0].isFaceUp, isTrue);

      // Tap matching second card
      state.onCardTapped(secondCardIndex);
      await tester.pump();

      expect(state.cards[0].isMatched, isTrue);
      expect(state.cards[secondCardIndex].isMatched, isTrue);
      expect(state.matchedPairs, 1);
      expect(state.moves, 1);
    });
  });
}
