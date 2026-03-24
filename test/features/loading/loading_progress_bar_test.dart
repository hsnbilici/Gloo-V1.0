import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/features/loading/loading_progress_bar.dart';

void main() {
  group('LoadingProgressBar', () {
    testWidgets('renders with given progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: LoadingProgressBar(progress: 0.5),
            ),
          ),
        ),
      );

      expect(find.byType(LoadingProgressBar), findsOneWidget);
    });

    testWidgets('has correct dimensions (200x4)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: LoadingProgressBar(progress: 0.5),
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(LoadingProgressBar),
          matching: find.byType(SizedBox),
        ),
      );

      expect(sizedBox.width, 200);
      expect(sizedBox.height, 4);
    });

    testWidgets('progress 0.0 renders without crash', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: LoadingProgressBar(progress: 0.0),
            ),
          ),
        ),
      );

      expect(find.byType(LoadingProgressBar), findsOneWidget);
    });

    testWidgets('progress 1.0 renders full bar without crash', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: LoadingProgressBar(progress: 1.0),
            ),
          ),
        ),
      );

      expect(find.byType(LoadingProgressBar), findsOneWidget);
    });
  });
}
