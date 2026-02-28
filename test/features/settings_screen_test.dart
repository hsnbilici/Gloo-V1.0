import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/features/settings/settings_screen.dart';
import 'package:gloo/providers/audio_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'onboarding_done': true,
      'colorblind_prompt_shown': true,
      'analytics_enabled': true,
    });
  });

  Widget buildSettings({AudioSettings? initialSettings}) {
    final overrides = <Override>[];
    if (initialSettings != null) {
      overrides.add(
        audioSettingsProvider.overrideWith((ref) {
          final n = AudioSettingsNotifier();
          if (!initialSettings.sfxEnabled) n.toggleSfx();
          if (initialSettings.colorBlindMode) n.toggleColorBlindMode();
          if (!initialSettings.analyticsEnabled) n.toggleAnalytics();
          return n;
        }),
      );
    }

    return ProviderScope(
      overrides: overrides,
      child: const MaterialApp(home: SettingsScreen()),
    );
  }

  group('SettingsScreen', () {
    testWidgets('renders settings title', (tester) async {
      await tester.pumpWidget(buildSettings());
      await tester.pumpAndSettle();

      // Settings title should be visible (localized)
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('shows audio section with toggle tiles', (tester) async {
      await tester.pumpWidget(buildSettings());
      await tester.pumpAndSettle();

      // Should have switch controls for sfx/music/haptics
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(buildSettings());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });
  });
}
