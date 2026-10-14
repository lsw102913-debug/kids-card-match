import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_card_match/game_screen.dart';
import 'package:kids_card_match/models/game_data.dart';
import 'package:kids_card_match/widgets/game_card_widget.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  group('Zero-Clip Adaptive Layout Screen Tests', () {
    final screenSizes = [
      const Size(800, 360),   // Compact landscape phone
      const Size(890, 390),   // Standard landscape phone
      const Size(920, 412),   // High-res landscape phone
      const Size(1024, 600),  // 7-inch tablet
      const Size(1280, 800),  // 10-inch tablet
    ];

    for (final size in screenSizes) {
      testWidgets('All difficulties fit perfectly without clipping on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        for (final diff in Difficulty.values) {
          await tester.pumpWidget(
            const MaterialApp(
              home: GameScreen(),
            ),
          );
          await tester.pumpAndSettle();

          final stateFinder = find.byType(GameScreen);
          final state = tester.state<GameScreenState>(stateFinder);

          // Change to difficulty
          state.startNewGame(difficulty: diff);
          await tester.pumpAndSettle();

          // Verify card count matches difficulty
          final cardFinders = find.byType(GameCardWidget);
          expect(cardFinders, findsNWidgets(diff.cardCount));

          // Verify zero flutter layout exceptions
          expect(tester.takeException(), isNull);

          // Verify all cards are visible within the screen bounds
          for (int i = 0; i < diff.cardCount; i++) {
            final cardElement = cardFinders.at(i);
            final cardRect = tester.getRect(cardElement);

            // Card must be within screen bounds
            expect(cardRect.top, greaterThanOrEqualTo(0.0), reason: 'Card $i top is off-screen on $diff');
            expect(cardRect.bottom, lessThanOrEqualTo(size.height), reason: 'Card $i bottom is off-screen on $diff');
            expect(cardRect.left, greaterThanOrEqualTo(0.0), reason: 'Card $i left is off-screen on $diff');
            expect(cardRect.right, lessThanOrEqualTo(size.width), reason: 'Card $i right is off-screen on $diff');
          }
        }
      });
    }
  });
}
