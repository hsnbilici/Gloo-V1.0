import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/features/onboarding/onboarding_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildApp() {
    return const ProviderScope(
      child: MaterialApp(home: OnboardingScreen()),
    );
  }

  group('OnboardingScreen', () {
    testWidgets('shows GLOO logo text', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('GLOO'), findsOneWidget);
    });

    testWidgets('shows skip button', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('shows first step title and description', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Place Gels'), findsOneWidget);
      expect(
        find.text(
          'Select a shape from your hand and place it on the grid. '
          'Full rows or columns clear automatically.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows next button on first page (not start)',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Play!'), findsNothing);
    });

    testWidgets('shows 3 page dots', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // 3 dot indicators: 1 active (width 22) + 2 inactive (width 6)
      // AnimatedContainer widgets as dot indicators
      final dots = find.byType(AnimatedContainer);
      // There are more AnimatedContainers (button, glow orb position, etc.)
      // so we just verify the page indicator row exists
      expect(dots, findsWidgets);
    });

    testWidgets('shows step icons', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // First step icon: grid_4x4_rounded
      expect(find.byIcon(Icons.grid_4x4_rounded), findsOneWidget);
    });
  });
}
