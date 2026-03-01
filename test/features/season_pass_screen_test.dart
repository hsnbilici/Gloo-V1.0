import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/features/season_pass/season_pass_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'onboarding_done': true,
      'colorblind_prompt_shown': true,
      'analytics_enabled': true,
    });
  });

  Widget buildSeasonPass() {
    return const ProviderScope(
      child: MaterialApp(home: SeasonPassScreen()),
    );
  }

  group('SeasonPassScreen', () {
    testWidgets('renders screen without errors', (tester) async {
      await tester.pumpWidget(buildSeasonPass());
      await tester.pumpAndSettle();

      expect(find.byType(SeasonPassScreen), findsOneWidget);
    });

    testWidgets('shows SEZON PASI title', (tester) async {
      await tester.pumpWidget(buildSeasonPass());
      await tester.pumpAndSettle();

      expect(find.text('SEZON PASI'), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(buildSeasonPass());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('shows XP progress bar', (tester) async {
      await tester.pumpWidget(buildSeasonPass());
      await tester.pumpAndSettle();

      expect(find.textContaining('XP'), findsWidgets);
    });

    testWidgets('shows tier display', (tester) async {
      await tester.pumpWidget(buildSeasonPass());
      await tester.pumpAndSettle();

      // Default state is tier 0, so the tier display shows "Tier 0/50"
      expect(find.textContaining('Tier'), findsOneWidget);
    });
  });
}
