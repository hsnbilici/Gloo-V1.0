import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/features/loading/breathing_letter.dart';

void main() {
  group('BreathingLetter', () {
    testWidgets('renders the letter text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BreathingLetter(
                letter: 'G',
                color: Color(0xFF00E5FF),
                phase: 0.0,
                animate: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('G'), findsOneWidget);
    });

    testWidgets('renders at correct size (52x60)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BreathingLetter(
                letter: 'L',
                color: Color(0xFFFFD700),
                phase: 0.0,
                animate: false,
              ),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(BreathingLetter));
      expect(size.width, 52.0);
      expect(size.height, 60.0);
    });

    testWidgets('renders without breathController when animate is false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BreathingLetter(
                letter: 'O',
                color: Color(0xFFFF69B4),
                phase: 1.0,
                animate: false,
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      expect(find.text('O'), findsOneWidget);
    });
  });
}
