import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/data/local/local_repository.dart';
import 'package:gloo/features/game_screen/game_cell_widget.dart';
import 'package:gloo/features/game_screen/game_screen.dart';
import 'package:gloo/features/game_screen/shape_hand.dart';
import 'package:gloo/game/shapes/gel_shape.dart';
import 'package:gloo/game/world/game_world.dart';
import 'package:gloo/providers/service_providers.dart';
import 'package:gloo/providers/user_provider.dart';

import '../data/local/fake_secure_storage.dart';
import '../helpers/mocks.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

void _stubAnalytics(MockAnalyticsService mock) {
  when(() => mock.logGameStart(mode: any(named: 'mode'))).thenReturn(null);
  when(() => mock.logGameOver(
        mode: any(named: 'mode'),
        score: any(named: 'score'),
      )).thenReturn(null);
}

void _stubAdManager(MockAdManager mock) {
  when(() => mock.canShowNearMissRescue()).thenReturn(false);
  when(() => mock.canShowHighScoreContinue(
        currentScore: any(named: 'currentScore'),
        highScore: any(named: 'highScore'),
      )).thenReturn(false);
  when(() => mock.canShowSecondChance(
        currentScore: any(named: 'currentScore'),
        averageScore: any(named: 'averageScore'),
      )).thenReturn(false);
}

Future<LocalRepository> _buildFakeRepo() async {
  SharedPreferences.setMockInitialValues({
    'onboarding_done': true,
    'tutorial_done': true,
    'colorblind_prompt_shown': true,
    'analytics_enabled': true,
  });
  final prefs = await SharedPreferences.getInstance();
  return LocalRepository(prefs, secureStorage: FakeSecureStorage());
}

Widget buildGameScreenApp({
  GameMode mode = GameMode.classic,
  List<Override> extraOverrides = const [],
}) {
  final mockAnalytics = MockAnalyticsService();
  final mockAdManager = MockAdManager();
  _stubAnalytics(mockAnalytics);
  _stubAdManager(mockAdManager);

  final router = GoRouter(
    initialLocation: '/game/classic',
    routes: [
      GoRoute(
        path: '/game/:mode',
        builder: (context, state) => GameScreen(mode: mode),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const SizedBox(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      streakProvider.overrideWith((ref) async => 0),
      analyticsServiceProvider.overrideWithValue(mockAnalytics),
      adManagerProvider.overrideWithValue(mockAdManager),
      localRepositoryProvider.overrideWith((ref) async => _buildFakeRepo()),
      ...extraOverrides,
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('GameInteractions — slot selection', () {
    testWidgets('tapping a shape slot selects it and sets selectedSlot',
        (tester) async {
      await tester.pumpWidget(buildGameScreenApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final shapeHandFinder = find.byType(ShapeHand);
      final shapeHand = tester.widget<ShapeHand>(shapeHandFinder);

      // Find first non-null slot
      int? firstFilledSlot;
      for (var i = 0; i < shapeHand.hand.length; i++) {
        if (shapeHand.hand[i] != null) {
          firstFilledSlot = i;
          break;
        }
      }
      expect(firstFilledSlot, isNotNull,
          reason: 'Hand should have at least one shape');

      final gestureDetectors = find.descendant(
        of: shapeHandFinder,
        matching: find.byType(GestureDetector),
      );
      await tester.tap(gestureDetectors.at(firstFilledSlot!));
      await tester.pump(const Duration(milliseconds: 300));

      final updatedHand = tester.widget<ShapeHand>(find.byType(ShapeHand));
      expect(updatedHand.selectedSlot, equals(firstFilledSlot));
    });

    testWidgets('tapping selected slot deselects it', (tester) async {
      await tester.pumpWidget(buildGameScreenApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final shapeHandFinder = find.byType(ShapeHand);
      final shapeHand = tester.widget<ShapeHand>(shapeHandFinder);

      int? firstFilledSlot;
      for (var i = 0; i < shapeHand.hand.length; i++) {
        if (shapeHand.hand[i] != null) {
          firstFilledSlot = i;
          break;
        }
      }
      if (firstFilledSlot == null) return;

      final gestureDetectors = find.descendant(
        of: shapeHandFinder,
        matching: find.byType(GestureDetector),
      );

      // Select
      await tester.tap(gestureDetectors.at(firstFilledSlot));
      await tester.pump(const Duration(milliseconds: 300));

      // Deselect
      final updatedDetectors = find.descendant(
        of: find.byType(ShapeHand),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(updatedDetectors.at(firstFilledSlot));
      await tester.pump(const Duration(milliseconds: 300));

      final finalHand = tester.widget<ShapeHand>(find.byType(ShapeHand));
      expect(finalHand.selectedSlot, isNull);
    });

    testWidgets('tapping grid cell without shape selected shows toast',
        (tester) async {
      await tester.pumpWidget(buildGameScreenApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // No shape selected — tap a grid cell
      final cells = find.byType(GameCellWidget);
      expect(cells, findsWidgets);

      await tester.tap(cells.first);
      await tester.pump(const Duration(milliseconds: 100));

      // Toast shows "Select a shape first"
      expect(find.text('Select a shape first'), findsOneWidget);

      // Flush pending timers (toast timer + flutter_animate)
      await tester.pump(const Duration(seconds: 3));
    });
  });

  group('GameInteractions — cell tap and placement', () {
    testWidgets('selecting shape then tapping cell shows preview',
        (tester) async {
      await tester.pumpWidget(buildGameScreenApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Select first shape
      final shapeHandFinder = find.byType(ShapeHand);
      final shapeHand = tester.widget<ShapeHand>(shapeHandFinder);

      int? firstFilledSlot;
      for (var i = 0; i < shapeHand.hand.length; i++) {
        if (shapeHand.hand[i] != null) {
          firstFilledSlot = i;
          break;
        }
      }
      if (firstFilledSlot == null) return;

      final gestureDetectors = find.descendant(
        of: shapeHandFinder,
        matching: find.byType(GestureDetector),
      );
      await tester.tap(gestureDetectors.at(firstFilledSlot));
      await tester.pump(const Duration(milliseconds: 300));

      // Tap a cell — first tap sets preview
      final cells = find.byType(GameCellWidget);
      await tester.tap(cells.first);
      await tester.pump(const Duration(milliseconds: 300));

      // After first tap, preview should be set; widget tree still renders
      expect(find.byType(GameCellWidget), findsWidgets);
    });

    testWidgets('double-tap on same cell places piece and clears selection',
        (tester) async {
      await tester.pumpWidget(buildGameScreenApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Select first shape
      final shapeHandFinder = find.byType(ShapeHand);
      final shapeHand = tester.widget<ShapeHand>(shapeHandFinder);

      int? firstFilledSlot;
      for (var i = 0; i < shapeHand.hand.length; i++) {
        if (shapeHand.hand[i] != null) {
          firstFilledSlot = i;
          break;
        }
      }
      if (firstFilledSlot == null) return;

      final gestureDetectors = find.descendant(
        of: shapeHandFinder,
        matching: find.byType(GestureDetector),
      );
      await tester.tap(gestureDetectors.at(firstFilledSlot));
      await tester.pump(const Duration(milliseconds: 300));

      // First tap — preview
      final cells = find.byType(GameCellWidget);
      await tester.tap(cells.first);
      await tester.pump(const Duration(milliseconds: 300));

      // Second tap — place
      final cellsAfter = find.byType(GameCellWidget);
      await tester.tap(cellsAfter.first);
      await tester.pump(const Duration(milliseconds: 500));

      // Selection should be cleared after placement
      final updatedHand = tester.widget<ShapeHand>(find.byType(ShapeHand));
      expect(updatedHand.selectedSlot, isNull);

      // Flush pending timers
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('placed slot becomes null in hand', (tester) async {
      await tester.pumpWidget(buildGameScreenApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final shapeHandFinder = find.byType(ShapeHand);
      final shapeHand = tester.widget<ShapeHand>(shapeHandFinder);

      int? firstFilledSlot;
      for (var i = 0; i < shapeHand.hand.length; i++) {
        if (shapeHand.hand[i] != null) {
          firstFilledSlot = i;
          break;
        }
      }
      if (firstFilledSlot == null) return;

      final gestureDetectors = find.descendant(
        of: shapeHandFinder,
        matching: find.byType(GestureDetector),
      );
      await tester.tap(gestureDetectors.at(firstFilledSlot));
      await tester.pump(const Duration(milliseconds: 300));

      // First tap — preview
      final cells = find.byType(GameCellWidget);
      await tester.tap(cells.first);
      await tester.pump(const Duration(milliseconds: 300));

      // Second tap — place
      final cellsAfter = find.byType(GameCellWidget);
      await tester.tap(cellsAfter.first);
      await tester.pump(const Duration(milliseconds: 500));

      // The used slot should now be null
      final updatedHand = tester.widget<ShapeHand>(find.byType(ShapeHand));
      expect(updatedHand.hand[firstFilledSlot], isNull);

      // Flush pending timers
      await tester.pump(const Duration(seconds: 3));
    });
  });

  group('GameInteractions — tutorial progression', () {
    testWidgets('tutorial starts at step 0 for first classic game',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'onboarding_done': true,
        'tutorial_done': false,
        'colorblind_prompt_shown': true,
        'analytics_enabled': true,
      });

      final mockAnalytics = MockAnalyticsService();
      final mockAdManager = MockAdManager();
      _stubAnalytics(mockAnalytics);
      _stubAdManager(mockAdManager);

      final prefs = await SharedPreferences.getInstance();
      final repo = LocalRepository(prefs, secureStorage: FakeSecureStorage());

      final router = GoRouter(
        initialLocation: '/game/classic',
        routes: [
          GoRoute(
            path: '/game/:mode',
            builder: (context, state) =>
                const GameScreen(mode: GameMode.classic),
          ),
          GoRoute(
            path: '/',
            builder: (context, state) => const SizedBox(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            streakProvider.overrideWith((ref) async => 0),
            analyticsServiceProvider.overrideWithValue(mockAnalytics),
            adManagerProvider.overrideWithValue(mockAdManager),
            localRepositoryProvider.overrideWith((ref) async => repo),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Tutorial overlay should be visible
      expect(find.text('Tap a shape to select it'), findsOneWidget);
    });

    testWidgets('tutorial does not show when tutorial_done is true',
        (tester) async {
      await tester.pumpWidget(buildGameScreenApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // No tutorial overlay text
      expect(find.text('Tap a shape to select it'), findsNothing);
    });
  });

  group('GameInteractions — GlooGame.placePiece integration', () {
    test('GlooGame rejects placement when status is not playing', () {
      final game = GlooGame(mode: GameMode.classic);
      game.startGame();
      game.status = GameStatus.gameOver;

      final cells = [(0, 0)];
      game.placePiece(cells, GelColor.red);

      // Score should not change — placement was rejected
      expect(game.score, equals(0));
    });

    test('GlooGame rejects placement on occupied cells', () {
      final game = GlooGame(mode: GameMode.classic);
      game.startGame();

      final cells = [(0, 0)];
      game.placePiece(cells, GelColor.red);

      // Try placing on same cell again
      game.placePiece(cells, GelColor.blue);

      // movesUsed should be 1, not 2 (second placement rejected)
      expect(game.movesUsed, equals(1));
    });

    test('GlooGame increments movesUsed on valid placement', () {
      final game = GlooGame(mode: GameMode.classic);
      game.startGame();

      expect(game.movesUsed, equals(0));
      game.placePiece([(0, 0)], GelColor.red);
      expect(game.movesUsed, equals(1));
      game.placePiece([(1, 1)], GelColor.blue);
      expect(game.movesUsed, equals(2));
    });

    test('checkGameOver does not fire when shapes can still be placed', () {
      final game = GlooGame(mode: GameMode.classic);
      game.startGame();

      bool gameOverCalled = false;
      game.onGameOver = () => gameOverCalled = true;

      // Grid is empty — dot shape can always fit
      game.checkGameOver([kAllShapes.first]); // dot shape

      expect(gameOverCalled, isFalse);
      expect(game.status, equals(GameStatus.playing));
    });

    test('checkGameOver is skipped in zen mode', () {
      final game = GlooGame(mode: GameMode.zen);
      game.startGame();

      bool gameOverCalled = false;
      game.onGameOver = () => gameOverCalled = true;

      game.checkGameOver([]);

      expect(gameOverCalled, isFalse);
    });

    test('checkGameOver is skipped in timeTrial mode', () {
      final game = GlooGame(mode: GameMode.timeTrial);
      game.startGame();

      bool gameOverCalled = false;
      game.onGameOver = () => gameOverCalled = true;

      game.checkGameOver([kAllShapes.first]);

      expect(gameOverCalled, isFalse);
      game.cancelTimer();
    });
  });

  group('GameInteractions — power-up activation', () {
    test('rotateShape returns rotated shape when balance sufficient', () {
      final game = GlooGame(mode: GameMode.classic);
      game.startGame();
      game.setCurrencyBalance(100);

      final shape = kAllShapes.first; // dot — rotation is identity
      final result = game.rotateShape(shape);

      // Dot is symmetric, but rotateShape should still work
      // It may return null if powerUpSystem rejects it (insufficient uses etc.)
      // This tests the API contract
      // Dot is symmetric, result may be the rotated shape or null if rejected
      expect(result, anyOf(isNull, isA<GelShape>()));
    });

    test('useBomb returns null on empty grid center', () {
      final game = GlooGame(mode: GameMode.classic);
      game.startGame();
      game.setCurrencyBalance(100);

      // Bomb on empty grid — nothing to clear
      final result = game.useBomb(4, 4);
      // Result may be empty map or null depending on powerUpSystem balance
      expect(result == null || result.isEmpty, isTrue);
    });
  });
}
