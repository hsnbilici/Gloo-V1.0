import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/features/home_screen/home_screen.dart';
import 'package:gloo/features/home_screen/widgets/bottom_bar.dart';
import 'package:gloo/features/home_screen/widgets/dialogs.dart';
import 'package:gloo/features/game_screen/game_over_buttons.dart';
import 'package:gloo/providers/user_provider.dart';

/// Finds a [Semantics] widget with the given [label].
Finder findSemantics(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is Semantics && widget.properties.label == label,
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'onboarding_done': true,
      'colorblind_prompt_shown': true,
      'analytics_enabled': true,
    });
  });

  Widget buildHomeApp() {
    return ProviderScope(
      overrides: [
        streakProvider.overrideWith((ref) async => 0),
      ],
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  group('HomeScreen accessibility', () {
    testWidgets('mode cards have Semantics widgets with labels',
        (tester) async {
      await tester.pumpWidget(buildHomeApp());
      await tester.pumpAndSettle();

      // Each ModeCard wraps content with Semantics(label: label, button: true)
      expect(findSemantics('Classic'), findsOneWidget);
      expect(findSemantics('Color Chef'), findsOneWidget);
      expect(findSemantics('Time Trial'), findsOneWidget);
      expect(findSemantics('Zen'), findsOneWidget);
    });

    testWidgets('bottom bar items have Semantics widgets with labels',
        (tester) async {
      await tester.pumpWidget(buildHomeApp());
      await tester.pumpAndSettle();

      expect(findSemantics('Leaderboard'), findsOneWidget);
      expect(findSemantics('Shop'), findsOneWidget);
      expect(findSemantics('Settings'), findsOneWidget);
      expect(findSemantics('Collection'), findsOneWidget);
    });

    testWidgets('bottom bar items meet 44dp minimum tap target',
        (tester) async {
      await tester.pumpWidget(buildHomeApp());
      await tester.pumpAndSettle();

      final bottomItems = find.byType(BottomItem);
      expect(bottomItems, findsWidgets);

      for (final element in bottomItems.evaluate()) {
        final renderBox = element.renderObject! as RenderBox;
        expect(renderBox.size.height, greaterThanOrEqualTo(44.0),
            reason: 'BottomItem should be at least 44dp tall');
      }
    });
  });

  group('AgeGateDialog accessibility', () {
    testWidgets('age gate buttons have Semantics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AgeGateDialog(
              title: 'Age Check',
              message: 'Please confirm your age.',
              confirmLabel: 'I am 13 or older',
              under13Label: 'I am under 13',
            ),
          ),
        ),
      );

      expect(findSemantics('I am 13 or older'), findsOneWidget);
      expect(findSemantics('I am under 13'), findsOneWidget);
    });

    testWidgets('AgeGateDialog buttons are marked as buttons in Semantics',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AgeGateDialog(
              title: 'Age Check',
              message: 'Please confirm your age.',
              confirmLabel: 'I am 13 or older',
              under13Label: 'I am under 13',
            ),
          ),
        ),
      );

      final confirmFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'I am 13 or older' &&
            (widget.properties.button ?? false),
      );
      final under13Finder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'I am under 13' &&
            (widget.properties.button ?? false),
      );

      expect(confirmFinder, findsOneWidget);
      expect(under13Finder, findsOneWidget);
    });
  });

  group('ConsentDialog accessibility', () {
    testWidgets('consent dialog buttons have Semantics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConsentDialog(
              title: 'Analytics',
              message: 'Help us improve the app.',
              acceptLabel: 'Accept',
              declineLabel: 'Decline',
            ),
          ),
        ),
      );

      expect(findSemantics('Accept'), findsOneWidget);
      expect(findSemantics('Decline'), findsOneWidget);
    });
  });

  group('Game over buttons accessibility', () {
    testWidgets('ActionButton has Semantics with label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              label: 'Retry',
              icon: Icons.replay,
              accentColor: Colors.cyan,
              filled: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(findSemantics('Retry'), findsOneWidget);
    });

    testWidgets('SecondChanceButton has Semantics with label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecondChanceButton(
              color: Colors.cyan,
              onTap: () {},
              watchAdLabel: 'Watch Ad',
              secondChanceLabel: '+3 Moves',
            ),
          ),
        ),
      );

      expect(findSemantics('+3 Moves'), findsOneWidget);
    });
  });

}
