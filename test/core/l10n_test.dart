import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/core/l10n/app_strings.dart';

void main() {
  // ─── AppStrings.forLocale ───────────────────────────────────────────────

  group('AppStrings.forLocale', () {
    test('returns English for en', () {
      final strings = AppStrings.forLocale(const Locale('en'));
      expect(strings.scoreLabel, isNotEmpty);
    });

    test('returns Turkish for tr', () {
      final strings = AppStrings.forLocale(const Locale('tr'));
      expect(strings.scoreLabel, isNotEmpty);
    });

    test('returns German for de', () {
      final strings = AppStrings.forLocale(const Locale('de'));
      expect(strings.scoreLabel, isNotEmpty);
    });

    test('returns Chinese for zh', () {
      final strings = AppStrings.forLocale(const Locale('zh'));
      expect(strings.scoreLabel, isNotEmpty);
    });

    test('returns Japanese for ja', () {
      final strings = AppStrings.forLocale(const Locale('ja'));
      expect(strings.scoreLabel, isNotEmpty);
    });

    test('returns Korean for ko', () {
      final strings = AppStrings.forLocale(const Locale('ko'));
      expect(strings.scoreLabel, isNotEmpty);
    });

    test('returns Russian for ru', () {
      final strings = AppStrings.forLocale(const Locale('ru'));
      expect(strings.scoreLabel, isNotEmpty);
    });

    test('returns Spanish for es', () {
      final strings = AppStrings.forLocale(const Locale('es'));
      expect(strings.scoreLabel, isNotEmpty);
    });

    test('returns French for fr', () {
      final strings = AppStrings.forLocale(const Locale('fr'));
      expect(strings.scoreLabel, isNotEmpty);
    });

    test('returns Hindi for hi', () {
      final strings = AppStrings.forLocale(const Locale('hi'));
      expect(strings.scoreLabel, isNotEmpty);
    });

    test('returns Portuguese for pt', () {
      final strings = AppStrings.forLocale(const Locale('pt'));
      expect(strings.scoreLabel, isNotEmpty);
    });

    test('returns Arabic for ar', () {
      final strings = AppStrings.forLocale(const Locale('ar'));
      expect(strings.scoreLabel, isNotEmpty);
    });

    test('falls back to English for unsupported locale', () {
      final strings = AppStrings.forLocale(const Locale('sv'));
      final en = AppStrings.forLocale(const Locale('en'));
      expect(strings.scoreLabel, en.scoreLabel);
    });
  });

  // ─── All strings are complete ───────────────────────────────────────────

  group('String completeness', () {
    final locales = [
      'en',
      'tr',
      'de',
      'zh',
      'ja',
      'ko',
      'ru',
      'es',
      'fr',
      'hi',
      'pt',
      'ar'
    ];

    for (final code in locales) {
      test('$code has all required strings', () {
        final s = AppStrings.forLocale(Locale(code));

        // HUD
        expect(s.scoreLabel, isNotEmpty);
        expect(s.modeLabelClassic, isNotEmpty);
        expect(s.modeLabelColorChef, isNotEmpty);
        expect(s.modeLabelTimeTrial, isNotEmpty);
        expect(s.modeLabelZen, isNotEmpty);
        expect(s.modeLabelDaily, isNotEmpty);

        // Game over
        expect(s.gameOverTitle, isNotEmpty);
        expect(s.gameOverScoreLabel, isNotEmpty);
        expect(s.gameOverReplay, isNotEmpty);
        expect(s.gameOverHome, isNotEmpty);

        // Combos
        expect(s.comboSmall, isNotEmpty);
        expect(s.comboMedium, isNotEmpty);
        expect(s.comboLarge, isNotEmpty);
        expect(s.comboEpic, isNotEmpty);

        // Near-miss
        expect(s.nearMissStandard, isNotEmpty);
        expect(s.nearMissCritical, isNotEmpty);

        // Home screen
        expect(s.modeClassicName, isNotEmpty);
        expect(s.modeClassicDesc, isNotEmpty);
        expect(s.homeSubtitle, isNotEmpty);

        // Faz 4 modes
        expect(s.modeLevelName, isNotEmpty);
        expect(s.modeDuelName, isNotEmpty);

        // Settings
        expect(s.settingsTitle, isNotEmpty);

        // Shop
        expect(s.shopTitle, isNotEmpty);

        // Onboarding
        expect(s.onboardingStart, isNotEmpty);
      });
    }
  });
}
