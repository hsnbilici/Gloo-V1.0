import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gloo/providers/theme_provider.dart';
import 'package:gloo/data/local/local_repository.dart';

import '../data/local/fake_secure_storage.dart';

void main() {
  test('default theme mode is dark', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(themeModeProvider), ThemeMode.dark);
  });

  test('setThemeMode updates state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
    expect(container.read(themeModeProvider), ThemeMode.light);
  });

  group('LocalRepository theme persistence', () {
    test('round-trip: setThemeMode then getThemeMode', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalRepository(prefs, secureStorage: FakeSecureStorage());

      await repo.setThemeMode(ThemeMode.light);
      expect(await repo.getThemeMode(), ThemeMode.light);

      await repo.setThemeMode(ThemeMode.dark);
      expect(await repo.getThemeMode(), ThemeMode.dark);
    });

    test('returns dark when no value persisted', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalRepository(prefs, secureStorage: FakeSecureStorage());

      expect(await repo.getThemeMode(), ThemeMode.dark);
    });
  });
}
