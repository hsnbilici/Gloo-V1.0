import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/features/game_screen/effects/ambient_effects.dart';

void main() {
  // ─── ScreenShake ──────────────────────────────────────────────────────

  group('ScreenShake', () {
    testWidgets('renders child without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScreenShake(
            intensity: 4.0,
            child: Text('Hello'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Hello'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders with custom duration', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScreenShake(
            intensity: 2.0,
            duration: Duration(milliseconds: 500),
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders with zero intensity', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScreenShake(
            intensity: 0.0,
            child: Text('No shake'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('No shake'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('animation completes without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScreenShake(
            intensity: 3.0,
            duration: Duration(milliseconds: 300),
            child: SizedBox(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('disposes without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScreenShake(
            intensity: 4.0,
            child: Text('Shake'),
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

  // ─── AmbientGelDroplets ───────────────────────────────────────────────

  group('AmbientGelDroplets', () {
    testWidgets('renders without error (defaults)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmbientGelDroplets(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders with custom parameters', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmbientGelDroplets(
              count: 5,
              baseColor: Colors.purple,
              speedFactor: 2.0,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders with zero count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmbientGelDroplets(count: 0),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles baseColor update', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmbientGelDroplets(
              baseColor: Colors.green,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Update with new color
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmbientGelDroplets(
              baseColor: Colors.red,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('disposes without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmbientGelDroplets(),
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
