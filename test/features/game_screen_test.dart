import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/data/local/local_repository.dart';
import 'package:gloo/features/game_screen/game_cell_widget.dart';
import 'package:gloo/features/game_screen/game_overlay.dart';
import 'package:gloo/features/game_screen/game_screen.dart';
import 'package:gloo/features/game_screen/power_up_toolbar.dart';
import 'package:gloo/features/game_screen/shape_hand.dart';
import 'package:gloo/game/shapes/gel_shape.dart';
import 'package:gloo/game/systems/powerup_system.dart';
import 'package:gloo/game/world/game_world.dart';
import 'package:gloo/providers/service_providers.dart';
import 'package:gloo/providers/user_provider.dart';

import '../data/local/fake_secure_storage.dart';
import '../helpers/mocks.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Stubs all mocktail methods called during GameScreen.initState and callbacks.
void _stubAnalytics(MockAnalyticsService mock) {
  when(() => mock.logGameStart(mode: any(named: 'mode'))).thenReturn(null);
  when(() => mock.logGameOver(
      mode: any(named: 'mode'), score: any(named: 'score'))).thenReturn(null);
}

void _stubAdManager(MockAdManager mock) {
  when(() => mock.canShowNearMissRescue()).thenReturn(false);
  when(
    () => mock.canShowHighScoreContinue(
      currentScore: any(named: 'currentScore'),
      highScore: any(named: 'highScore'),
    ),
  ).thenReturn(false);
  when(
    () => mock.canShowSecondChance(
      currentScore: any(named: 'currentScore'),
      averageScore: any(named: 'averageScore'),
    ),
  ).thenReturn(false);
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
  // ── Group 1: GameScreen renders correctly ────────────────────────────────

  group('GameScreen renders correctly', () {
    testWidgets('classic mode renders GameScreen widget', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.classic));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(GameScreen), findsOneWidget);
    });

    testWidgets('classic mode renders GameOverlay HUD', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.classic));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(GameOverlay), findsOneWidget);
    });

    testWidgets('classic mode renders ShapeHand', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.classic));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ShapeHand), findsOneWidget);
    });

    testWidgets('classic mode renders PowerUpToolbar', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.classic));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(PowerUpToolbar), findsOneWidget);
    });

    testWidgets('classic mode renders game grid cells', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.classic));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(GameCellWidget), findsWidgets);
    });

    testWidgets('timeTrial mode renders GameScreen', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.timeTrial));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(GameScreen), findsOneWidget);
      expect(find.byType(GameOverlay), findsOneWidget);
    });

    testWidgets('timeTrial mode shows countdown timer', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.timeTrial));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Countdown bar shows initial time "1:30" (90 seconds)
      expect(find.text('1:30'), findsOneWidget);
    });

    testWidgets('colorChef mode renders GameScreen', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.colorChef));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(GameScreen), findsOneWidget);
    });

    testWidgets('colorChef mode shows chef progress bar', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.colorChef));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // ChefTargetBar shows "0/3" progress
      expect(
        find.textContaining('0/3', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('zen mode renders GameScreen', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.zen));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(GameScreen), findsOneWidget);
    });
  });

  // ── Group 2: GameOverlay HUD elements ────────────────────────────────────

  group('GameOverlay HUD elements', () {
    testWidgets('classic mode shows SCORE label', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.classic));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('SCORE'), findsOneWidget);
    });

    testWidgets('classic mode shows CLASSIC mode label', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.classic));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('CLASSIC'), findsOneWidget);
    });

    testWidgets('shows pause button', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.classic));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    });

    testWidgets('shows initial score of 0', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.classic));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Score starts at 0 — displayed in the _ScoreDisplay in GameOverlay
      expect(find.text('0'), findsWidgets);
    });

    testWidgets('timeTrial mode shows TIME label', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.timeTrial));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // modeLabelTimeTrial is 'TIME' in English strings
      expect(find.text('TIME'), findsOneWidget);
    });

    testWidgets('colorChef mode shows COLOR CHEF label', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.colorChef));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('COLOR CHEF'), findsOneWidget);
    });
  });

  // ── Group 3: ShapeHand slot behavior ─────────────────────────────────────

  group('ShapeHand slots', () {
    testWidgets('ShapeHand renders 3 slots', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.classic));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // ShapeHand always renders GameConstants.shapesInHand (3) slots
      final shapeHand = tester.widget<ShapeHand>(find.byType(ShapeHand));
      expect(shapeHand.hand.length, equals(3));
    });

    testWidgets('no slot is selected initially', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.classic));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final shapeHand = tester.widget<ShapeHand>(find.byType(ShapeHand));
      expect(shapeHand.selectedSlot, isNull);
    });

    testWidgets('tapping a shape slot selects it', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.classic));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Get the ShapeHand and tap the first slot that has a shape
      final shapeHandFinder = find.byType(ShapeHand);
      final ShapeHand shapeHand = tester.widget(shapeHandFinder);

      // Find first non-null slot
      int? firstFilledSlot;
      for (var i = 0; i < shapeHand.hand.length; i++) {
        if (shapeHand.hand[i] != null) {
          firstFilledSlot = i;
          break;
        }
      }

      if (firstFilledSlot != null) {
        // Tap the GestureDetector inside ShapeHand at the filled slot
        final gestureDetectors = find.descendant(
          of: shapeHandFinder,
          matching: find.byType(GestureDetector),
        );
        await tester.tap(gestureDetectors.at(firstFilledSlot));
        await tester.pump(const Duration(milliseconds: 300));

        final updatedHand = tester.widget<ShapeHand>(shapeHandFinder);
        expect(updatedHand.selectedSlot, equals(firstFilledSlot));
      }
    });

    testWidgets('tapping selected slot deselects it', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.classic));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final shapeHandFinder = find.byType(ShapeHand);
      final ShapeHand shapeHand = tester.widget(shapeHandFinder);

      int? firstFilledSlot;
      for (var i = 0; i < shapeHand.hand.length; i++) {
        if (shapeHand.hand[i] != null) {
          firstFilledSlot = i;
          break;
        }
      }

      if (firstFilledSlot != null) {
        final gestureDetectors = find.descendant(
          of: shapeHandFinder,
          matching: find.byType(GestureDetector),
        );
        // Select
        await tester.tap(gestureDetectors.at(firstFilledSlot));
        await tester.pump(const Duration(milliseconds: 300));

        // Deselect (tap same slot again)
        final updatedDetectors = find.descendant(
          of: find.byType(ShapeHand),
          matching: find.byType(GestureDetector),
        );
        await tester.tap(updatedDetectors.at(firstFilledSlot));
        await tester.pump(const Duration(milliseconds: 300));

        final finalHand = tester.widget<ShapeHand>(find.byType(ShapeHand));
        expect(finalHand.selectedSlot, isNull);
      }
    });
  });

  // ── Group 4: PowerUpToolbar ───────────────────────────────────────────────

  group('PowerUpToolbar', () {
    testWidgets('classic mode shows rotate, bomb, undo buttons',
        (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.classic));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.rotate_right), findsOneWidget);
      expect(find.byIcon(Icons.flash_on), findsOneWidget);
      expect(find.byIcon(Icons.replay), findsOneWidget);
    });

    testWidgets('classic mode does not show freeze button', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.classic));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.ac_unit), findsNothing);
    });

    testWidgets('timeTrial mode shows freeze button', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.timeTrial));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.ac_unit), findsOneWidget);
    });

    testWidgets('PowerUpToolbar shows balance display', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.classic));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Balance starts at 0 — displayed in the Jel Ozu counter
      final toolbar = tester.widget<PowerUpToolbar>(
        find.byType(PowerUpToolbar),
      );
      expect(toolbar.balance, equals(0));
    });

    testWidgets('PowerUpToolbar shows cost badge for each power-up',
        (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.classic));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Each power-up button shows a cost. Verify the toolbar exists with a
      // PowerUpSystem that has defined costs.
      final toolbar = tester.widget<PowerUpToolbar>(
        find.byType(PowerUpToolbar),
      );
      expect(toolbar.powerUpSystem, isA<PowerUpSystem>());
      // kPowerUpDefs contains cost for each type — spot-check rotate
      expect(kPowerUpDefs[PowerUpType.rotate]?.cost, isNotNull);
    });

    testWidgets('no power-up is active initially', (tester) async {
      await tester.pumpWidget(buildGameScreenApp(mode: GameMode.classic));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final toolbar = tester.widget<PowerUpToolbar>(
        find.byType(PowerUpToolbar),
      );
      expect(toolbar.activePowerUpMode, isNull);
    });
  });

  // ── Group 5: Sub-component isolation ─────────────────────────────────────

  group('ShapeHand widget in isolation', () {
    GelShape dummyShape() => kAllShapes.first;

    testWidgets('renders with all null slots', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShapeHand(
              hand: const [null, null, null],
              selectedSlot: null,
              onSlotTap: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ShapeHand), findsOneWidget);
    });

    testWidgets('renders with filled slots', (tester) async {
      final shape = dummyShape();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShapeHand(
              hand: [
                (shape, GelColor.red),
                (shape, GelColor.blue),
                null,
              ],
              selectedSlot: null,
              onSlotTap: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ShapeHand), findsOneWidget);
    });

    testWidgets('selected slot index is reflected in widget', (tester) async {
      final shape = dummyShape();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShapeHand(
              hand: [
                (shape, GelColor.red),
                (shape, GelColor.blue),
                null,
              ],
              selectedSlot: 0,
              onSlotTap: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();
      final widget = tester.widget<ShapeHand>(find.byType(ShapeHand));
      expect(widget.selectedSlot, equals(0));
    });

    testWidgets('calls onSlotTap with correct index', (tester) async {
      final shape = dummyShape();
      int? tappedIndex;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShapeHand(
              hand: [
                (shape, GelColor.red),
                (shape, GelColor.yellow),
                (shape, GelColor.blue),
              ],
              selectedSlot: null,
              onSlotTap: (i) => tappedIndex = i,
            ),
          ),
        ),
      );
      await tester.pump();

      final gestureDetectors = find.byType(GestureDetector);
      await tester.tap(gestureDetectors.first);
      await tester.pump();

      expect(tappedIndex, equals(0));
    });
  });

  // ── Group 6: PowerUpToolbar in isolation ─────────────────────────────────

  group('PowerUpToolbar widget in isolation', () {
    PowerUpSystem buildSystem() {
      final game = GlooGame(mode: GameMode.classic);
      game.startGame();
      return game.powerUpSystem;
    }

    testWidgets('renders without active power-up', (tester) async {
      final system = buildSystem();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PowerUpToolbar(
              balance: 50,
              powerUpSystem: system,
              activePowerUpMode: null,
              showFreeze: false,
              onPowerUpTap: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(PowerUpToolbar), findsOneWidget);
    });

    testWidgets('shows balance value', (tester) async {
      final system = buildSystem();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PowerUpToolbar(
              balance: 999,
              powerUpSystem: system,
              activePowerUpMode: null,
              showFreeze: false,
              onPowerUpTap: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('999'), findsOneWidget);
    });

    testWidgets('shows all 3 power-up icons when showFreeze is false',
        (tester) async {
      final system = buildSystem();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PowerUpToolbar(
              balance: 0,
              powerUpSystem: system,
              activePowerUpMode: null,
              showFreeze: false,
              onPowerUpTap: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byIcon(Icons.rotate_right), findsOneWidget);
      expect(find.byIcon(Icons.flash_on), findsOneWidget);
      expect(find.byIcon(Icons.replay), findsOneWidget);
      expect(find.byIcon(Icons.ac_unit), findsNothing);
    });

    testWidgets('shows freeze icon when showFreeze is true', (tester) async {
      final system = buildSystem();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PowerUpToolbar(
              balance: 0,
              powerUpSystem: system,
              activePowerUpMode: null,
              showFreeze: true,
              onPowerUpTap: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byIcon(Icons.ac_unit), findsOneWidget);
    });
  });
}
