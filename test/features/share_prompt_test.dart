import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/features/game_screen/share_prompt_dialog.dart';

void main() {
  testWidgets('SharePromptDialog renders share and skip buttons', (tester) async {
    bool skipped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SharePromptDialog(
          title: 'Epic!',
          message: 'Share?',
          shareLabel: 'Share',
          skipLabel: 'Skip',
          onShare: () {},
          onSkip: () => skipped = true,
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    expect(skipped, isTrue);
  });
}
