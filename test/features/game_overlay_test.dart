import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/features/game_screen/game_overlay.dart';
import 'package:gloo/game/world/game_world.dart';

void main() {
  Widget buildOverlay({
    required GameMode mode,
    required GlooGame game,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Scaffold(
          body: GameOverlay(game: game, mode: mode),
        ),
      ),
    );
  }

  GlooGame createGame(GameMode mode) {
    final game = GlooGame(mode: mode);
    game.startGame();
    return game;
  }

  // ─── Mod bazlı HUD ────────────────────────────────────────────────────────

  group('GameOverlay HUD', () {
    testWidgets('classic mode shows FillBar with percentage', (tester) async {
      final game = createGame(GameMode.classic);

      await tester.pumpWidget(buildOverlay(
        mode: GameMode.classic,
        game: game,
      ));
      await tester.pumpAndSettle();

      // FillBar shows percentage text
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('timeTrial mode shows countdown time', (tester) async {
      final game = createGame(GameMode.timeTrial);

      await tester.pumpWidget(buildOverlay(
        mode: GameMode.timeTrial,
        game: game,
      ));
      // Use pump() instead of pumpAndSettle() to avoid periodic timer firing
      await tester.pump();

      // CountdownBar shows time in m:ss format (90 seconds = 1:30)
      expect(find.text('1:30'), findsOneWidget);

      // Cancel the countdown timer to avoid pending timer assertion
      game.pauseGame();
    });

    testWidgets('colorChef mode shows chef progress', (tester) async {
      final game = createGame(GameMode.colorChef);

      await tester.pumpWidget(buildOverlay(
        mode: GameMode.colorChef,
        game: game,
      ));
      await tester.pumpAndSettle();

      // ChefTargetBar shows progress/required in RichText (0/3)
      expect(
        find.textContaining('0/3', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('zen mode shows zen indicator instead of score label',
        (tester) async {
      final game = createGame(GameMode.zen);

      await tester.pumpWidget(buildOverlay(
        mode: GameMode.zen,
        game: game,
      ));
      await tester.pumpAndSettle();

      // Zen mode shows 'HUZUR' instead of 'SCORE'
      expect(find.text('HUZUR'), findsOneWidget);
      expect(find.text('SCORE'), findsNothing);
    });

    testWidgets('non-zen modes show SCORE label', (tester) async {
      final game = createGame(GameMode.classic);

      await tester.pumpWidget(buildOverlay(
        mode: GameMode.classic,
        game: game,
      ));
      await tester.pumpAndSettle();

      expect(find.text('SCORE'), findsOneWidget);
    });
  });

  // ─── Ortak HUD öğeleri ──────────────────────────────────────────────────────

  group('GameOverlay common elements', () {
    testWidgets('shows mode label', (tester) async {
      final game = createGame(GameMode.classic);

      await tester.pumpWidget(buildOverlay(
        mode: GameMode.classic,
        game: game,
      ));
      await tester.pumpAndSettle();

      expect(find.text('CLASSIC'), findsOneWidget);
    });

    testWidgets('shows pause button', (tester) async {
      final game = createGame(GameMode.classic);

      await tester.pumpWidget(buildOverlay(
        mode: GameMode.classic,
        game: game,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    });

    testWidgets('shows initial score of 0', (tester) async {
      final game = createGame(GameMode.classic);

      await tester.pumpWidget(buildOverlay(
        mode: GameMode.classic,
        game: game,
      ));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);
    });
  });
}
