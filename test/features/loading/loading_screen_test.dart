import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/features/loading/loading_screen.dart';
import 'package:gloo/features/loading/loading_progress_bar.dart';

void main() {
  group('LoadingScreen', () {
    Widget buildSubject() {
      return ProviderScope(
        child: MaterialApp(
          home: const LoadingScreen(),
        ),
      );
    }

    testWidgets('renders 4 GLOO letters (G, L, O, O)', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('G'), findsOneWidget);
      expect(find.text('L'), findsOneWidget);
      // Two O letters
      expect(find.text('O'), findsNWidgets(2));
    });

    testWidgets('renders LoadingProgressBar widget', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(LoadingProgressBar), findsOneWidget);
    });
  });
}
