import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_card_match/game_screen.dart';
import 'package:kids_card_match/models/game_data.dart';
import 'package:kids_card_match/widgets/victory_dialog.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  testWidgets('Test 20-card mode matching and flipping on various screen sizes', (tester) async {
    final sizes = [
      const Size(640, 360),
      const Size(720, 360),
      const Size(780, 360),
      const Size(800, 360),
      const Size(844, 390),
      const Size(915, 412),
      const Size(360, 780), // In case rotated
    ];

    for (final size in sizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: GameScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final state = tester.state<GameScreenState>(find.byType(GameScreen));
      state.startNewGame(difficulty: Difficulty.master);
      await tester.pumpAndSettle();

      expect(state.cards.length, 20);

      // Flip every pair one by one
      for (int i = 0; i < 20; i++) {
        state.onCardTapped(i);
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      final err = tester.takeException();
      if (err != null) {
        debugPrint('Found error on size $size: $err');
      }
      expect(err, isNull, reason: 'Error on size $size');
    }
  });

  testWidgets('Complete all 10 pairs in Master difficulty and show victory dialog', (tester) async {
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: GameScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final state = tester.state<GameScreenState>(find.byType(GameScreen));
    state.startNewGame(difficulty: Difficulty.master);
    await tester.pumpAndSettle();

    expect(state.cards.length, 20);

    // Group cards by pairId
    final pairs = <int, List<int>>{};
    for (int i = 0; i < state.cards.length; i++) {
      final pid = state.cards[i].pairId;
      pairs.putIfAbsent(pid, () => []).add(i);
    }

    expect(pairs.length, 10);

    // Match all pairs sequentially
    for (final pair in pairs.values) {
      state.onCardTapped(pair[0]);
      await tester.pump(const Duration(milliseconds: 50));
      state.onCardTapped(pair[1]);
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Wait for victory delay (700ms) and confetti
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.byType(VictoryDialog), findsOneWidget);
    final err = tester.takeException();
    expect(err, isNull);
  });
}
