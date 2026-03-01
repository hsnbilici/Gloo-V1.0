import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/features/home_screen/home_screen.dart';
import 'package:gloo/providers/audio_provider.dart';
import 'package:gloo/providers/user_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'onboarding_done': true,
      'colorblind_prompt_shown': true,
      'analytics_enabled': true,
    });
  });

  Widget buildApp({bool glooPlus = false, int streak = 0}) {
    final overrides = <Override>[
      streakProvider.overrideWith((ref) async => streak),
    ];

    if (glooPlus) {
      overrides.add(
        appSettingsProvider.overrideWith((ref) {
          final n = AppSettingsNotifier();
          n.setGlooPlus(enabled: true);
          return n;
        }),
      );
    }

    return ProviderScope(
      overrides: overrides,
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  // ─── Mod kartları ───────────────────────────────────────────────────────────

  group('HomeScreen mode cards', () {
    testWidgets('renders all 6 mode card labels', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Classic'), findsOneWidget);
      expect(find.text('Color Chef'), findsOneWidget);
      expect(find.text('Time Trial'), findsOneWidget);
      expect(find.text('Zen'), findsOneWidget);
      expect(find.text('Levels'), findsOneWidget);
      expect(find.text('Duel'), findsOneWidget);
    });

    testWidgets('renders mode card subtitles', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Play until the grid is full'), findsOneWidget);
      expect(find.text('Synthesize the target color'), findsOneWidget);
    });

    testWidgets('Zen mode shows GLOO+ lock when not subscribed',
        (tester) async {
      await tester.pumpWidget(buildApp(glooPlus: false));
      await tester.pumpAndSettle();

      expect(find.text('GLOO+'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    });

    testWidgets('Zen mode has no lock when subscribed', (tester) async {
      await tester.pumpWidget(buildApp(glooPlus: true));
      await tester.pumpAndSettle();

      expect(find.text('GLOO+'), findsNothing);
    });
  });

  // ─── Alt navigasyon çubuğu ──────────────────────────────────────────────────

  group('HomeScreen bottom bar', () {
    testWidgets('renders 4 navigation items', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Leaderboard'), findsOneWidget);
      expect(find.text('Collection'), findsOneWidget);
      expect(find.text('Shop'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });

  // ─── Streak rozeti ─────────────────────────────────────────────────────────

  group('HomeScreen streak badge', () {
    testWidgets('shows streak badge when streak >= 2', (tester) async {
      await tester.pumpWidget(buildApp(streak: 5));
      await tester.pumpAndSettle();

      expect(find.text('5 DAYS'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
    });

    testWidgets('hidden when streak < 2', (tester) async {
      await tester.pumpWidget(buildApp(streak: 1));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.local_fire_department_rounded), findsNothing);
    });
  });

  // ─── Günlük bulmaca banner'ı ────────────────────────────────────────────────

  group('HomeScreen daily banner', () {
    testWidgets('renders daily puzzle banner', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Daily Puzzle'), findsOneWidget);
    });
  });
}
