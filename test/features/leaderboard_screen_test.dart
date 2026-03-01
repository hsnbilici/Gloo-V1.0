import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/features/leaderboard/leaderboard_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'onboarding_done': true,
      'colorblind_prompt_shown': true,
      'analytics_enabled': true,
    });
  });

  Widget buildLeaderboard() {
    return const ProviderScope(
      child: MaterialApp(home: LeaderboardScreen()),
    );
  }

  group('LeaderboardScreen', () {
    testWidgets('renders screen without errors', (tester) async {
      await tester.pumpWidget(buildLeaderboard());
      await tester.pumpAndSettle();

      expect(find.byType(LeaderboardScreen), findsOneWidget);
    });

    testWidgets('shows leaderboard title', (tester) async {
      await tester.pumpWidget(buildLeaderboard());
      await tester.pumpAndSettle();

      expect(find.text('Leaderboard'), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(buildLeaderboard());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('shows mode tabs (Classic and Time Trial)', (tester) async {
      await tester.pumpWidget(buildLeaderboard());
      await tester.pumpAndSettle();

      expect(find.text('Classic'), findsOneWidget);
      expect(find.text('Time Trial'), findsOneWidget);
    });

    testWidgets('shows filter options (Weekly and All Time)', (tester) async {
      await tester.pumpWidget(buildLeaderboard());
      await tester.pumpAndSettle();

      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('All Time'), findsOneWidget);
    });
  });
}
