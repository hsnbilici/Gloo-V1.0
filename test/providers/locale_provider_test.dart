import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/providers/locale_provider.dart';

void main() {
  // ─── kLanguageOptions ───────────────────────────────────────────────────

  group('kLanguageOptions', () {
    test('has 12 language options', () {
      expect(kLanguageOptions.length, 12);
    });

    test('all have non-empty code and nativeName', () {
      for (final lang in kLanguageOptions) {
        expect(lang.code.isNotEmpty, isTrue,
            reason: 'Language code should not be empty');
        expect(lang.nativeName.isNotEmpty, isTrue,
            reason: 'Native name should not be empty');
      }
    });

    test('codes are unique', () {
      final codes = kLanguageOptions.map((l) => l.code).toSet();
      expect(codes.length, kLanguageOptions.length);
    });

    test('contains expected languages', () {
      final codes = kLanguageOptions.map((l) => l.code).toSet();
      expect(codes, containsAll(['en', 'tr', 'de', 'zh', 'ja', 'ko', 'ru', 'es', 'ar', 'fr', 'hi', 'pt']));
    });

    test('Turkish is listed first', () {
      expect(kLanguageOptions.first.code, 'tr');
    });
  });

  // ─── LocaleNotifier ────────────────────────────────────────────────────

  group('LocaleNotifier', () {
    test('setLocale changes state', () {
      final notifier = LocaleNotifier();
      notifier.setLocale(const Locale('tr'));
      expect(notifier.state.languageCode, 'tr');
    });

    test('setLocale to Japanese', () {
      final notifier = LocaleNotifier();
      notifier.setLocale(const Locale('ja'));
      expect(notifier.state.languageCode, 'ja');
    });

    test('setLocale to Arabic', () {
      final notifier = LocaleNotifier();
      notifier.setLocale(const Locale('ar'));
      expect(notifier.state.languageCode, 'ar');
    });

    test('initial state is a valid locale', () {
      final notifier = LocaleNotifier();
      expect(notifier.state.languageCode.isNotEmpty, isTrue);
    });
  });
}
