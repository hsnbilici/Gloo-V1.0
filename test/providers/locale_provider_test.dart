import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      expect(
          codes,
          containsAll([
            'en',
            'tr',
            'de',
            'zh',
            'ja',
            'ko',
            'ru',
            'es',
            'ar',
            'fr',
            'hi',
            'pt'
          ]));
    });

    test('Turkish is listed first', () {
      expect(kLanguageOptions.first.code, 'tr');
    });
  });

  // ─── LocaleNotifier ────────────────────────────────────────────────────

  group('LocaleNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('setLocale changes state', () {
      container.read(localeProvider.notifier).setLocale(const Locale('tr'));
      expect(container.read(localeProvider).languageCode, 'tr');
    });

    test('setLocale to Japanese', () {
      container.read(localeProvider.notifier).setLocale(const Locale('ja'));
      expect(container.read(localeProvider).languageCode, 'ja');
    });

    test('setLocale to Arabic', () {
      container.read(localeProvider.notifier).setLocale(const Locale('ar'));
      expect(container.read(localeProvider).languageCode, 'ar');
    });

    test('initial state is a valid locale', () {
      final locale = container.read(localeProvider);
      expect(locale.languageCode.isNotEmpty, isTrue);
    });
  });
}
