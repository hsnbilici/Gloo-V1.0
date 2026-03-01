import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/features/island/island_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'onboarding_done': true,
      'colorblind_prompt_shown': true,
      'analytics_enabled': true,
      'gel_energy': 200,
      'total_earned_energy': 500,
    });
  });

  Widget buildIsland() {
    return const ProviderScope(
      child: MaterialApp(home: IslandScreen()),
    );
  }

  group('IslandScreen', () {
    testWidgets('renders screen without errors', (tester) async {
      await tester.pumpWidget(buildIsland());
      await tester.pumpAndSettle();

      expect(find.byType(IslandScreen), findsOneWidget);
    });

    testWidgets('shows GLOO ADASI title', (tester) async {
      await tester.pumpWidget(buildIsland());
      await tester.pumpAndSettle();

      expect(find.text('GLOO ADASI'), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(buildIsland());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('shows energy display with bolt icon', (tester) async {
      await tester.pumpWidget(buildIsland());
      await tester.pumpAndSettle();

      // Bolt icon appears in the energy display and in building upgrade buttons
      expect(find.byIcon(Icons.bolt_rounded), findsWidgets);
    });
  });
}
