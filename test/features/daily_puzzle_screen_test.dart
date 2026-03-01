import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/features/daily_puzzle/daily_puzzle_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'onboarding_done': true,
      'colorblind_prompt_shown': true,
      'analytics_enabled': true,
    });
  });

  Widget buildDailyPuzzle() {
    return const ProviderScope(
      child: MaterialApp(home: DailyPuzzleScreen()),
    );
  }

  group('DailyPuzzleScreen', () {
    testWidgets('renders screen without errors', (tester) async {
      await tester.pumpWidget(buildDailyPuzzle());
      await tester.pumpAndSettle();

      expect(find.byType(DailyPuzzleScreen), findsOneWidget);
    });

    testWidgets('shows DAILY PUZZLE title (uppercased)', (tester) async {
      await tester.pumpWidget(buildDailyPuzzle());
      await tester.pumpAndSettle();

      // The title is rendered as toUpperCase()
      expect(find.text('DAILY PUZZLE'), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(buildDailyPuzzle());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });

    testWidgets('shows play button when not completed', (tester) async {
      await tester.pumpWidget(buildDailyPuzzle());
      await tester.pumpAndSettle();

      expect(find.text('Play Today'), findsOneWidget);
    });

    testWidgets('shows calendar card with current day', (tester) async {
      await tester.pumpWidget(buildDailyPuzzle());
      await tester.pumpAndSettle();

      final today = DateTime.now().day.toString();
      expect(find.text(today), findsOneWidget);
    });
  });
}
