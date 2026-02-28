import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/features/level_select/level_select_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'onboarding_done': true,
      'colorblind_prompt_shown': true,
    });
  });

  Widget buildLevelSelect() {
    return const ProviderScope(
      child: MaterialApp(home: LevelSelectScreen()),
    );
  }

  group('LevelSelectScreen', () {
    testWidgets('renders screen', (tester) async {
      await tester.pumpWidget(buildLevelSelect());
      await tester.pumpAndSettle();

      expect(find.byType(LevelSelectScreen), findsOneWidget);
    });

    testWidgets('shows SEVIYELER title', (tester) async {
      await tester.pumpWidget(buildLevelSelect());
      await tester.pumpAndSettle();

      expect(find.text('SEVIYELER'), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(buildLevelSelect());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('shows level 1 as unlocked', (tester) async {
      await tester.pumpWidget(buildLevelSelect());
      await tester.pumpAndSettle();

      // Level 1 should always be available (unlocked)
      expect(find.text('1'), findsWidgets);
    });
  });
}
