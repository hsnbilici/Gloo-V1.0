import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/features/game_screen/effects/cell_effects.dart';

void main() {
  // ─── CellBurstEffect ─────────────────────────────────────────────────

  group('CellBurstEffect', () {
    testWidgets('renders without error (zero delay)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CellBurstEffect(
            color: Colors.red,
            cellSize: 40,
            delay: Duration.zero,
            onDismiss: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without error (with delay)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CellBurstEffect(
            color: Colors.blue,
            cellSize: 30,
            delay: const Duration(milliseconds: 200),
            onDismiss: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });

    testWidgets('calls onDismiss when animation completes', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: CellBurstEffect(
            color: Colors.green,
            cellSize: 40,
            delay: Duration.zero,
            onDismiss: () => dismissed = true,
          ),
        ),
      );
      // Animation duration is 580ms
      await tester.pumpAndSettle();
      expect(dismissed, isTrue);
    });

    testWidgets('disposes without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CellBurstEffect(
            color: Colors.red,
            cellSize: 40,
            delay: Duration.zero,
            onDismiss: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      // Replace with empty container to trigger dispose
      await tester.pumpWidget(
        const MaterialApp(home: SizedBox()),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('disposes while delay timer is pending', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CellBurstEffect(
            color: Colors.red,
            cellSize: 40,
            delay: const Duration(seconds: 5),
            onDismiss: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      // Dispose before the delay timer fires
      await tester.pumpWidget(
        const MaterialApp(home: SizedBox()),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  // ─── IceBreakEffect ───────────────────────────────────────────────────

  group('IceBreakEffect', () {
    testWidgets('renders without error (zero delay)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: IceBreakEffect(
            cellSize: 40,
            delay: Duration.zero,
            onDismiss: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without error (with delay)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: IceBreakEffect(
            cellSize: 40,
            delay: const Duration(milliseconds: 150),
            onDismiss: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
    });

    testWidgets('calls onDismiss when animation completes', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: IceBreakEffect(
            cellSize: 40,
            delay: Duration.zero,
            onDismiss: () => dismissed = true,
          ),
        ),
      );
      // Animation duration is 500ms
      await tester.pumpAndSettle();
      expect(dismissed, isTrue);
    });

    testWidgets('disposes without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: IceBreakEffect(
            cellSize: 40,
            delay: Duration.zero,
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

  // ─── LineSweepEffect ──────────────────────────────────────────────────

  group('LineSweepEffect', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LineSweepEffect(
            cols: 8,
            cellSize: 40,
            gap: 4,
            onDismiss: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('calls onDismiss on completion', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: LineSweepEffect(
            cols: 8,
            cellSize: 40,
            gap: 4,
            onDismiss: () => dismissed = true,
          ),
        ),
      );
      // Animation duration is 300ms — pumpAndSettle drives to completion
      await tester.pumpAndSettle();
      expect(dismissed, isTrue);
    });

    testWidgets('disposes cleanly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LineSweepEffect(
            cols: 8,
            cellSize: 40,
            gap: 4,
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

    testWidgets('respects reduce motion — immediate dismiss', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: LineSweepEffect(
              cols: 8,
              cellSize: 40,
              gap: 4,
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );
      await tester.pump(); // postFrameCallback fires
      expect(dismissed, isTrue);
    });
  });

  // ─── ColorSynthesisBloomEffect ────────────────────────────────────────

  group('ColorSynthesisBloomEffect', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ColorSynthesisBloomEffect(
            color: Colors.purple,
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
          home: ColorSynthesisBloomEffect(
            color: Colors.orange,
            cellSize: 40,
            onDismiss: () => dismissed = true,
          ),
        ),
      );
      // Animation duration is 700ms
      await tester.pumpAndSettle();
      expect(dismissed, isTrue);
    });

    testWidgets('disposes without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ColorSynthesisBloomEffect(
            color: Colors.teal,
            cellSize: 40,
            onDismiss: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpWidget(
        const MaterialApp(home: SizedBox()),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
