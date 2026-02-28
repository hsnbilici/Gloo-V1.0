import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/features/collection/collection_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'onboarding_done': true,
      'colorblind_prompt_shown': true,
    });
  });

  Widget buildCollection({List<String>? discoveredColors}) {
    if (discoveredColors != null) {
      SharedPreferences.setMockInitialValues({
        'onboarding_done': true,
        'colorblind_prompt_shown': true,
        'discovered_colors': discoveredColors,
      });
    }

    return const ProviderScope(
      child: MaterialApp(home: CollectionScreen()),
    );
  }

  group('CollectionScreen', () {
    testWidgets('renders screen', (tester) async {
      await tester.pumpWidget(buildCollection());
      await tester.pumpAndSettle();

      expect(find.byType(CollectionScreen), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(buildCollection());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('shows progress count', (tester) async {
      await tester.pumpWidget(
        buildCollection(discoveredColors: ['orange', 'green']),
      );
      await tester.pumpAndSettle();

      // Should show count like "2/8"
      expect(find.textContaining('2'), findsWidgets);
    });
  });
}
