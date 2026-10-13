import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_card_match/models/card_item.dart';
import 'package:kids_card_match/models/game_data.dart';
import 'package:kids_card_match/game_screen.dart';

void main() {
  group('GameData & Deck Generation Tests', () {
    test('Easy difficulty generates 4 cards (2 pairs)', () {
      final deck = GameData.generateDeck(
        category: CardCategory.animals,
        difficulty: Difficulty.easy,
      );
      expect(deck.length, 4);

      // Verify pair counts
      final pairCounts = <int, int>{};
      for (var card in deck) {
        pairCounts[card.pairId] = (pairCounts[card.pairId] ?? 0) + 1;
      }
      expect(pairCounts.length, 2);
      expect(pairCounts.values.every((cnt) => cnt == 2), isTrue);
    });

    test('Medium difficulty generates 6 cards (3 pairs)', () {
      final deck = GameData.generateDeck(
        category: CardCategory.fruits,
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
        category: CardCategory.vehicles,
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
  });

  group('Game Widget & Matching Interaction Tests', () {
    testWidgets('Tapping matching cards updates state and finds pair', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GameScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final stateFinder = find.byType(GameScreen);
      expect(stateFinder, findsOneWidget);
      final state = tester.state<GameScreenState>(stateFinder);

      expect(state.cards.length, 4); // Default easy mode
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

      // Now match the other pair to trigger victory
      final remainingIndices = [0, 1, 2, 3]
          .where((i) => i != 0 && i != secondCardIndex)
          .toList();
      expect(remainingIndices.length, 2);

      state.onCardTapped(remainingIndices[0]);
      await tester.pump();
      state.onCardTapped(remainingIndices[1]);
      await tester.pump();

      expect(state.matchedPairs, 2);
      expect(state.isGameOver, isTrue);

      // Pump to trigger victory dialog timer
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Verify victory dialog appeared
      expect(find.text('참 잘했어요! 🎉'), findsOneWidget);
    });
  });
}
