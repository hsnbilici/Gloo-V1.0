import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/core/utils/near_miss_detector.dart';
import 'package:gloo/features/game_screen/effects/feedback_effects.dart';
import 'package:gloo/game/systems/combo_detector.dart';

void main() {
  // ─── ComboEffect ──────────────────────────────────────────────────────

  group('ComboEffect', () {
    testWidgets('renders without error (small combo)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ComboEffect(
                combo: const ComboEvent(
                  size: 2,
                  tier: ComboTier.small,
                  multiplier: 1.2,
                ),
                onDismiss: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without error (epic combo)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ComboEffect(
                combo: const ComboEvent(
                  size: 5,
                  tier: ComboTier.epic,
                  multiplier: 3.0,
                ),
                onDismiss: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('calls onDismiss after timer', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ComboEffect(
                combo: const ComboEvent(
                  size: 3,
                  tier: ComboTier.medium,
                  multiplier: 1.5,
                ),
                onDismiss: () => dismissed = true,
              ),
            ),
          ),
        ),
      );
      // Timer is 1500ms
      await tester.pumpAndSettle(const Duration(milliseconds: 1600));
      expect(dismissed, isTrue);
    });

    testWidgets('disposes without error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ComboEffect(
                combo: const ComboEvent(
                  size: 2,
                  tier: ComboTier.small,
                  multiplier: 1.2,
                ),
                onDismiss: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SizedBox()),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('displays multiplier text', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ComboEffect(
                combo: const ComboEvent(
                  size: 4,
                  tier: ComboTier.large,
                  multiplier: 2.5,
                ),
                onDismiss: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('x2.5'), findsOneWidget);
    });
  });

  // ─── PlaceFeedbackEffect ──────────────────────────────────────────────

  group('PlaceFeedbackEffect', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlaceFeedbackEffect(
              count: 3,
              color: Colors.green,
              onDismiss: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('displays count text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlaceFeedbackEffect(
              count: 5,
              color: Colors.green,
              onDismiss: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('+5'), findsOneWidget);
    });

    testWidgets('calls onDismiss after timer', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlaceFeedbackEffect(
              count: 2,
              color: Colors.green,
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );
      // Timer is 650ms
      await tester.pumpAndSettle(const Duration(milliseconds: 700));
      expect(dismissed, isTrue);
    });

    testWidgets('disposes without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlaceFeedbackEffect(
              count: 1,
              color: Colors.blue,
              onDismiss: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpWidget(
        const MaterialApp(home: SizedBox()),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  // ─── NearMissEffect ───────────────────────────────────────────────────

  group('NearMissEffect', () {
    testWidgets('renders without error (standard)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: NearMissEffect(
                event: const NearMissEvent(
                  score: 0.7,
                  type: NearMissType.standard,
                ),
                onDismiss: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without error (critical)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: NearMissEffect(
                event: const NearMissEvent(
                  score: 0.95,
                  type: NearMissType.critical,
                ),
                onDismiss: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('calls onDismiss after timer', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: NearMissEffect(
                event: const NearMissEvent(
                  score: 0.8,
                  type: NearMissType.standard,
                ),
                onDismiss: () => dismissed = true,
              ),
            ),
          ),
        ),
      );
      // Timer is 2000ms; animation controller repeats
      // Pump 2100ms total then dispose to stop repeating animation
      await tester.pump(const Duration(milliseconds: 2100));
      expect(dismissed, isTrue);
    });

    testWidgets('disposes without error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: NearMissEffect(
                event: const NearMissEvent(
                  score: 0.8,
                  type: NearMissType.standard,
                ),
                onDismiss: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: SizedBox()),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
