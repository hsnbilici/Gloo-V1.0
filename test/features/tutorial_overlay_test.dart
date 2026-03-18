import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/features/game_screen/tutorial_overlay.dart';

void main() {
  testWidgets('TutorialOverlay displays message', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            TutorialOverlay(
              step: 0,
              message: 'Tap a shape',
              pointDown: true,
              onDismiss: () {},
            ),
          ],
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Tap a shape'), findsOneWidget);
  });

  testWidgets('TutorialOverlay shows dismiss button on last step',
      (tester) async {
    bool dismissed = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            TutorialOverlay(
              step: 2,
              message: 'Done!',
              dismissLabel: 'Got it!',
              onDismiss: () => dismissed = true,
            ),
          ],
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Got it!'), findsOneWidget);
    await tester.tap(find.text('Got it!'));
    expect(dismissed, isTrue);
  });
}
