import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/data/local/local_repository.dart';
import 'package:gloo/features/character/character_screen.dart';
import 'package:gloo/providers/user_provider.dart';

import '../data/local/fake_secure_storage.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'onboarding_done': true,
      'colorblind_prompt_shown': true,
      'analytics_enabled': true,
      'gel_energy': 100,
    });
  });

  Widget buildCharacter() {
    return ProviderScope(
      overrides: [
        localRepositoryProvider.overrideWith((_) async {
          final prefs = await SharedPreferences.getInstance();
          return LocalRepository(prefs, secureStorage: FakeSecureStorage());
        }),
      ],
      child: const MaterialApp(home: CharacterScreen()),
    );
  }

  group('CharacterScreen', () {
    testWidgets('renders screen without errors', (tester) async {
      await tester.pumpWidget(buildCharacter());
      await tester.pumpAndSettle();

      expect(find.byType(CharacterScreen), findsOneWidget);
    });

    testWidgets('shows KARAKTER title', (tester) async {
      await tester.pumpWidget(buildCharacter());
      await tester.pumpAndSettle();

      expect(find.text('KARAKTER'), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(buildCharacter());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('shows talent section header', (tester) async {
      await tester.pumpWidget(buildCharacter());
      await tester.pumpAndSettle();

      expect(find.text('YETENEKLER'), findsOneWidget);
    });

    testWidgets('shows energy display with bolt icon', (tester) async {
      await tester.pumpWidget(buildCharacter());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
    });
  });
}
