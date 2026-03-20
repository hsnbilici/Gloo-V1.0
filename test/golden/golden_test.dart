// Golden / snapshot tests for key Gloo widgets.
//
// Generate baselines:
//   flutter test --update-goldens test/golden/
//
// Run against baselines:
//   flutter test test/golden/
//
// Notes:
// • flutter_animate causes pumpAndSettle() to time-out — use pump(Duration).
// • GameOverOverlay is a ConsumerWidget; wrap in ProviderScope with
//   stringsProvider overridden to StringsEn() for deterministic text.
// • TutorialOverlay is a Positioned widget; it must live inside a Stack.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/core/l10n/strings_en.dart';
import 'package:gloo/core/models/game_mode.dart';
import 'package:gloo/features/game_screen/game_over_overlay.dart';
import 'package:gloo/features/game_screen/game_over_widgets.dart';
import 'package:gloo/features/game_screen/level_complete_overlay.dart';
import 'package:gloo/features/game_screen/tutorial_overlay.dart';
import 'package:gloo/providers/locale_provider.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// Dark-themed MaterialApp consistent with Gloo's game screens.
Widget _darkApp({required Widget child}) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: kBgDark,
        body: child,
      ),
    );

/// Same but wrapped in ProviderScope with English strings override.
Widget _darkProviderApp({required Widget child}) => ProviderScope(
      overrides: [
        stringsProvider.overrideWithValue(StringsEn()),
      ],
      child: _darkApp(child: child),
    );

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // 1. GameOverOverlay — classic mode, normal score
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('GameOverOverlay classic matches golden', (tester) async {
    await tester.pumpWidget(
      _darkProviderApp(
        child: SizedBox(
          width: 400,
          height: 800,
          child: GameOverOverlay(
            score: 1234,
            mode: GameMode.classic,
            filledCells: 42,
            totalCells: 80,
            isNewHighScore: false,
            onReplay: () {},
            onHome: () {},
          ),
        ),
      ),
    );
    // Let flutter_animate transitions settle (avoids pumpAndSettle timeout)
    await tester.pump(const Duration(seconds: 2));

    await expectLater(
      find.byType(GameOverOverlay),
      matchesGoldenFile('goldens/game_over_classic.png'),
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 2. GameOverOverlay — new high-score badge visible
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('GameOverOverlay new-high-score matches golden', (tester) async {
    await tester.pumpWidget(
      _darkProviderApp(
        child: SizedBox(
          width: 400,
          height: 800,
          child: GameOverOverlay(
            score: 9999,
            mode: GameMode.timeTrial,
            filledCells: 70,
            totalCells: 80,
            isNewHighScore: true,
            onReplay: () {},
            onHome: () {},
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    await expectLater(
      find.byType(GameOverOverlay),
      matchesGoldenFile('goldens/game_over_high_score.png'),
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 3. TutorialOverlay — step 0 (point-up arrow, no dismiss button)
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('TutorialOverlay step 0 matches golden', (tester) async {
    await tester.pumpWidget(
      _darkApp(
        child: SizedBox(
          width: 400,
          height: 800,
          child: Stack(
            children: [
              TutorialOverlay(
                step: 0,
                message: 'Select a shape from your hand.',
                onDismiss: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    await expectLater(
      find.byType(TutorialOverlay),
      matchesGoldenFile('goldens/tutorial_step0.png'),
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 4. TutorialOverlay — last step with dismiss button (pointDown)
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('TutorialOverlay last step with dismiss matches golden',
      (tester) async {
    await tester.pumpWidget(
      _darkApp(
        child: SizedBox(
          width: 400,
          height: 800,
          child: Stack(
            children: [
              TutorialOverlay(
                step: 2,
                message: 'Tap a cell to place the shape!',
                dismissLabel: 'Got it!',
                pointDown: true,
                onDismiss: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    await expectLater(
      find.byType(TutorialOverlay),
      matchesGoldenFile('goldens/tutorial_step2_dismiss.png'),
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 5. LevelCompleteOverlay — standalone (no external provider deps)
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('LevelCompleteOverlay matches golden', (tester) async {
    await tester.pumpWidget(
      _darkApp(
        child: SizedBox(
          width: 400,
          height: 800,
          child: LevelCompleteOverlay(
            score: 4200,
            levelId: 5,
            onNextLevel: () {},
            onLevelList: () {},
            onHome: () {},
            nextLevelLabel: 'Next Level',
            levelListLabel: 'Level List',
            mainMenuLabel: 'Main Menu',
            levelLabel: 'Level',
            completedLabel: 'COMPLETED!',
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    await expectLater(
      find.byType(LevelCompleteOverlay),
      matchesGoldenFile('goldens/level_complete.png'),
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 6. GameOverModeBadge sub-widget
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('GameOverModeBadge matches golden', (tester) async {
    await tester.pumpWidget(
      _darkApp(
        child: Center(
          child: GameOverModeBadge(
            label: 'CLASSIC',
            color: kCyan,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    await expectLater(
      find.byType(GameOverModeBadge),
      matchesGoldenFile('goldens/game_over_mode_badge.png'),
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 7. NewRecordBadge sub-widget
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('NewRecordBadge matches golden', (tester) async {
    await tester.pumpWidget(
      _darkApp(
        child: Center(
          child: NewRecordBadge(
            label: 'NEW RECORD!',
            color: kGold,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    await expectLater(
      find.byType(NewRecordBadge),
      matchesGoldenFile('goldens/new_record_badge.png'),
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 8. GameOverStatRow sub-widget
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('GameOverStatRow matches golden', (tester) async {
    await tester.pumpWidget(
      _darkApp(
        child: Center(
          child: const GameOverStatRow(
            label: 'Grid Fill',
            value: '%52',
            color: kCyan,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    await expectLater(
      find.byType(GameOverStatRow),
      matchesGoldenFile('goldens/game_over_stat_row.png'),
    );
  });
}
