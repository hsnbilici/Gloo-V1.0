import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/core/l10n/strings_en.dart';
import 'package:gloo/features/game_screen/chef_level_overlay.dart';
import 'package:gloo/features/game_screen/game_dialogs.dart';
import 'package:gloo/features/game_screen/game_over_overlay.dart';
import 'package:gloo/features/game_screen/level_complete_overlay.dart';
import 'package:gloo/game/world/game_world.dart';
import 'package:gloo/providers/locale_provider.dart';

// All overlay widgets use flutter_animate, which creates non-settling timers.
// We use pump() with a sufficient duration instead of pumpAndSettle().

void main() {
  // ─── GameOverOverlay widget testleri ──────────────────────────────────────

  group('GameOverOverlay', () {
    Widget buildGameOver({
      int score = 1234,
      GameMode mode = GameMode.classic,
      int filledCells = 40,
      int totalCells = 80,
      bool isNewHighScore = false,
      bool showSecondChance = false,
    }) {
      return ProviderScope(
        child: MaterialApp(
          home: GameOverOverlay(
            score: score,
            mode: mode,
            filledCells: filledCells,
            totalCells: totalCells,
            isNewHighScore: isNewHighScore,
            showSecondChance: showSecondChance,
            onReplay: () {},
            onHome: () {},
          ),
        ),
      );
    }

    testWidgets('renders GAME OVER title', (tester) async {
      await tester.pumpWidget(buildGameOver());
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('GAME OVER'), findsOneWidget);
    });

    testWidgets('renders SCORE label', (tester) async {
      await tester.pumpWidget(buildGameOver());
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('SCORE'), findsOneWidget);
    });

    testWidgets('shows Play Again button', (tester) async {
      await tester.pumpWidget(buildGameOver());
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Play Again'), findsOneWidget);
    });

    testWidgets('shows Main Menu button', (tester) async {
      await tester.pumpWidget(buildGameOver());
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Main Menu'), findsOneWidget);
    });

    testWidgets('shows mode badge for classic mode', (tester) async {
      await tester.pumpWidget(buildGameOver(mode: GameMode.classic));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('CLASSIC'), findsOneWidget);
    });

    testWidgets('shows mode badge for colorChef mode', (tester) async {
      await tester.pumpWidget(buildGameOver(mode: GameMode.colorChef));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('COLOR CHEF'), findsOneWidget);
    });

    testWidgets('shows mode badge for timeTrial mode', (tester) async {
      await tester.pumpWidget(buildGameOver(mode: GameMode.timeTrial));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('TIME TRIAL'), findsOneWidget);
    });

    testWidgets('shows Grid Fill stat row', (tester) async {
      await tester.pumpWidget(buildGameOver(filledCells: 40, totalCells: 80));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Grid Fill'), findsOneWidget);
      expect(find.text('%50'), findsOneWidget);
    });

    testWidgets('shows NEW RECORD badge when isNewHighScore is true',
        (tester) async {
      await tester.pumpWidget(buildGameOver(isNewHighScore: true));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('NEW RECORD!'), findsOneWidget);
    });

    testWidgets('hides NEW RECORD badge when isNewHighScore is false',
        (tester) async {
      await tester.pumpWidget(buildGameOver(isNewHighScore: false));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('NEW RECORD!'), findsNothing);
    });

    testWidgets('shows second chance button when enabled', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: GameOverOverlay(
              score: 500,
              mode: GameMode.classic,
              filledCells: 20,
              totalCells: 80,
              isNewHighScore: false,
              showSecondChance: true,
              onSecondChance: () {},
              onReplay: () {},
              onHome: () {},
              secondChanceLabel: '+3 Moves',
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Watch Ad'), findsOneWidget);
      expect(find.text('+3 Moves'), findsOneWidget);
    });

    testWidgets('hides second chance button when disabled', (tester) async {
      await tester.pumpWidget(buildGameOver(showSecondChance: false));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Watch Ad'), findsNothing);
    });

    testWidgets('kModeColors maps correct color per mode', (tester) async {
      expect(kModeColors[GameMode.classic], kColorClassic);
      expect(kModeColors[GameMode.colorChef], kColorChef);
      expect(kModeColors[GameMode.timeTrial], kColorTimeTrial);
      expect(kModeColors[GameMode.zen], kColorZen);
      expect(kModeColors[GameMode.daily], kCyan);
    });
  });

  // ─── ChefLevelOverlay widget testleri ─────────────────────────────────────

  group('ChefLevelOverlay', () {
    Widget buildChefOverlay({
      int completedLevelIndex = 2,
      GelColor targetColor = GelColor.orange,
      bool isAllComplete = false,
    }) {
      return ProviderScope(
        overrides: [
          stringsProvider.overrideWithValue(StringsEn()),
        ],
        child: MaterialApp(
          home: ChefLevelOverlay(
            completedLevelIndex: completedLevelIndex,
            targetColor: targetColor,
            isAllComplete: isAllComplete,
            onContinue: () {},
            onHome: () {},
          ),
        ),
      );
    }

    testWidgets('renders LEVEL COMPLETE title', (tester) async {
      await tester.pumpWidget(buildChefOverlay());
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('LEVEL COMPLETE'), findsOneWidget);
    });

    testWidgets('shows target color display name', (tester) async {
      await tester.pumpWidget(buildChefOverlay(targetColor: GelColor.orange));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Orange'), findsOneWidget);
    });

    testWidgets('shows level number badge', (tester) async {
      await tester.pumpWidget(buildChefOverlay(completedLevelIndex: 4));
      await tester.pump(const Duration(seconds: 2));
      // completedLevelIndex 4 => level number 5 => "SEViYE 5" badge
      expect(find.textContaining('5'), findsWidgets);
    });

    testWidgets('shows Continue and Main Menu buttons when not all complete',
        (tester) async {
      await tester.pumpWidget(buildChefOverlay(isAllComplete: false));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Main Menu'), findsOneWidget);
    });

    testWidgets('shows ALL LEVELS DONE when isAllComplete is true',
        (tester) async {
      await tester.pumpWidget(buildChefOverlay(isAllComplete: true));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('ALL LEVELS DONE'), findsOneWidget);
    });

    testWidgets('hides Continue button when all complete', (tester) async {
      await tester.pumpWidget(buildChefOverlay(isAllComplete: true));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Continue'), findsNothing);
    });

    testWidgets('shows Main Menu even when all complete', (tester) async {
      await tester.pumpWidget(buildChefOverlay(isAllComplete: true));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Main Menu'), findsOneWidget);
    });
  });

  // ─── LevelCompleteOverlay widget testleri ─────────────────────────────────

  group('LevelCompleteOverlay', () {
    Widget buildLevelComplete({int score = 750, int levelId = 3}) {
      return MaterialApp(
        home: LevelCompleteOverlay(
          score: score,
          levelId: levelId,
          onNextLevel: () {},
          onLevelList: () {},
          onHome: () {},
          nextLevelLabel: 'Next Level',
          levelListLabel: 'Level List',
          mainMenuLabel: 'Main Menu',
          levelLabel: 'Level',
          completedLabel: 'COMPLETED!',
        ),
      );
    }

    testWidgets('renders COMPLETED text', (tester) async {
      await tester.pumpWidget(buildLevelComplete());
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('COMPLETED!'), findsOneWidget);
    });

    testWidgets('shows level ID', (tester) async {
      await tester.pumpWidget(buildLevelComplete(levelId: 7));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Level 7'), findsOneWidget);
    });

    testWidgets('shows Sonraki Seviye button', (tester) async {
      await tester.pumpWidget(buildLevelComplete());
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Next Level'), findsOneWidget);
    });

    testWidgets('shows Seviye Listesi button', (tester) async {
      await tester.pumpWidget(buildLevelComplete());
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Level List'), findsOneWidget);
    });

    testWidgets('shows Ana Menu button', (tester) async {
      await tester.pumpWidget(buildLevelComplete());
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Main Menu'), findsOneWidget);
    });
  });

  // ─── showGameOver / showChefLevelComplete / showLevelComplete fonksiyonlari

  // showGameOver, showChefLevelComplete, showLevelComplete use
  // addPostFrameCallback + showGeneralDialog with transitionDuration.
  // We need multiple pump() calls:
  //   1. pump() to schedule the postFrameCallback
  //   2. pump() to fire the callback (which calls showGeneralDialog)
  //   3. pump(transitionDuration) to let the dialog transition complete

  group('game_dialogs functions', () {
    testWidgets('showGameOver opens a dialog with GameOverOverlay',
        (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      showGameOver(
        context: capturedContext,
        score: 500,
        mode: GameMode.classic,
        filledCells: 10,
        totalCells: 80,
        isNewHighScore: false,
        showSecondChance: false,
        onSecondChance: null,
        onReplay: () {},
        onHome: () {},
      );

      // Fire postFrameCallback + render dialog + complete transition
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(GameOverOverlay), findsOneWidget);
      expect(find.text('GAME OVER'), findsOneWidget);
      // Clean up flutter_animate timers
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('showChefLevelComplete opens a dialog with ChefLevelOverlay',
        (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      showChefLevelComplete(
        context: capturedContext,
        completedIndex: 1,
        targetColor: GelColor.green,
        allComplete: false,
        onContinue: () {},
      );

      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(ChefLevelOverlay), findsOneWidget);
      expect(find.text('LEVEL COMPLETE'), findsOneWidget);
      // Clean up flutter_animate timers
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('showLevelComplete opens a dialog with LevelCompleteOverlay',
        (tester) async {
      late BuildContext capturedContext;
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              return Builder(
                builder: (ctx) {
                  capturedContext = ctx;
                  return const SizedBox();
                },
              );
            },
          ),
          GoRoute(
            path: '/levels',
            builder: (context, state) => const SizedBox(),
          ),
          GoRoute(
            path: '/game/level/:levelId',
            builder: (context, state) => const SizedBox(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      showLevelComplete(
        context: capturedContext,
        score: 900,
        levelId: 5,
        nextLevelLabel: 'Next Level',
        levelListLabel: 'Level List',
        mainMenuLabel: 'Main Menu',
        levelLabel: 'Level',
        completedLabel: 'COMPLETED!',
      );

      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(LevelCompleteOverlay), findsOneWidget);
      expect(find.text('Level 5'), findsOneWidget);
      expect(find.text('COMPLETED!'), findsOneWidget);
      // Clean up flutter_animate timers
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
