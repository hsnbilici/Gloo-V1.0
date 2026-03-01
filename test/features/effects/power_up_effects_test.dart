import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/features/game_screen/effects/power_up_effects.dart';

void main() {
  // ─── PowerUpActivateEffect ────────────────────────────────────────────

  group('PowerUpActivateEffect', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PowerUpActivateEffect(
              color: Colors.cyan,
              onDismiss: () {},
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
        MaterialApp(
          home: Scaffold(
            body: PowerUpActivateEffect(
              color: Colors.cyan,
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );
      // Timer is 800ms
      await tester.pumpAndSettle(const Duration(milliseconds: 900));
      expect(dismissed, isTrue);
    });

    testWidgets('disposes without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PowerUpActivateEffect(
              color: Colors.cyan,
              onDismiss: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpWidget(
        const MaterialApp(home: SizedBox()),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  // ─── BombExplosionEffect ──────────────────────────────────────────────

  group('BombExplosionEffect', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BombExplosionEffect(
            cellSize: 40,
            onDismiss: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('calls onDismiss when animation completes', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: BombExplosionEffect(
            cellSize: 40,
            onDismiss: () => dismissed = true,
          ),
        ),
      );
      // Animation duration is 650ms
      await tester.pumpAndSettle();
      expect(dismissed, isTrue);
    });

    testWidgets('disposes without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BombExplosionEffect(
            cellSize: 40,
            onDismiss: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpWidget(
        const MaterialApp(home: SizedBox()),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  // ─── UndoRewindEffect ─────────────────────────────────────────────────

  group('UndoRewindEffect', () {
    testWidgets('renders without error (empty cells)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UndoRewindEffect(
              cells: const [],
              cellSize: 40,
              gridGap: 2,
              onDismiss: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without error (with cells)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UndoRewindEffect(
              cells: const [(0, 0), (1, 2), (3, 4)],
              cellSize: 40,
              gridGap: 2,
              onDismiss: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('calls onDismiss when animation completes', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UndoRewindEffect(
              cells: const [(1, 1)],
              cellSize: 40,
              gridGap: 2,
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );
      // Animation duration is 600ms
      await tester.pumpAndSettle();
      expect(dismissed, isTrue);
    });

    testWidgets('disposes without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UndoRewindEffect(
              cells: const [(0, 0)],
              cellSize: 40,
              gridGap: 2,
              onDismiss: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpWidget(
        const MaterialApp(home: SizedBox()),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
