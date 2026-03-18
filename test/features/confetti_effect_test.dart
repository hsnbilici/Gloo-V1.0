import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/features/game_screen/effects/confetti_effect.dart';

void main() {
  testWidgets('ConfettiEffect renders and self-dismisses', (tester) async {
    bool dismissed = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ConfettiEffect(onDismiss: () => dismissed = true),
      ),
    ));
    expect(find.byType(ConfettiEffect), findsOneWidget);
    // Pump past full duration
    await tester.pump(const Duration(milliseconds: 2600));
    expect(dismissed, isTrue);
  });
}
