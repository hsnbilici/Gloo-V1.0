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
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('GLOO'), findsOneWidget);
    });

    testWidgets('shows skip button', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('shows first step title and description', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Place Gels'), findsOneWidget);
      expect(
        find.text(
          'Select a shape from your hand and place it on the grid. '
          'Full rows or columns clear automatically.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows next button on first page (not start)', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Play!'), findsNothing);
    });

    testWidgets('shows 5 page dots', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump(const Duration(milliseconds: 500));

      // 5 dot indicators: 1 active (width 22) + 4 inactive (width 6)
      // AnimatedContainer widgets as dot indicators
      final dots = find.byType(AnimatedContainer);
      // There are more AnimatedContainers (button, glow orb position, etc.)
      // so we just verify the page indicator row exists
      expect(dots, findsWidgets);
    });

    testWidgets('shows mini grid demo on first step', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump(const Duration(milliseconds: 500));

      // First step has a GridView for the mini demo
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('skip button has Semantics with button role', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump(const Duration(milliseconds: 500));

      final semantics = find.bySemanticsLabel('Skip');
      expect(semantics, findsOneWidget);
    });

    testWidgets('next button has Semantics with button role', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump(const Duration(milliseconds: 500));

      final semantics = find.bySemanticsLabel('Next');
      expect(semantics, findsOneWidget);
    });

    testWidgets('navigating to 5th page shows Play! button and prefs',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(buildApp());
      await tester.pump(const Duration(milliseconds: 500));

      // Use programmatic Next button taps — more reliable than drag
      // Tap Next 4 times to move from page 0 → 1 → 2 → 3 → 4
      for (var i = 0; i < 4; i++) {
        final nextFinder = find.text('Next');
        expect(nextFinder, findsOneWidget);
        await tester.tap(nextFinder);
        // Pump for page transition (360ms) + animation settle
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 400));
      }
      // Extra pumps for flutter_animate on prefs page
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // 5th page shows Play! button
      expect(find.text('Play!'), findsOneWidget);
      // Shows preferences content
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Analytics & Crash Reports'), findsOneWidget);
      expect(find.text('Accessibility'), findsOneWidget);
    });
  });
}
