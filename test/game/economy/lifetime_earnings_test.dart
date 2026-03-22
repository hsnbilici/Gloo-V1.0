import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gloo/game/economy/currency_manager.dart';
import 'package:gloo/data/local/local_repository.dart';

import '../../data/local/fake_secure_storage.dart';

void main() {
  // ─── CurrencyManager Enflasyon Testleri ──────────────────────────────────

  group('CurrencyManager inflation', () {
    test('0 earnings → inflatedCost(10) == 10', () {
      final cm = CurrencyManager();
      expect(cm.inflatedCost(10), 10);
    });

    test('500 earnings → inflatedCost(10) == 15', () {
      final cm = CurrencyManager(lifetimeEarnings: 500);
      // 1 + 500/1000 = 1.5 → 10 * 1.5 = 15
      expect(cm.inflatedCost(10), 15);
    });

    test('1000+ earnings → inflatedCost(10) == 20 (max 2x)', () {
      final cm = CurrencyManager(lifetimeEarnings: 1000);
      // 1 + 1000/1000 = 2.0 → 10 * 2.0 = 20
      expect(cm.inflatedCost(10), 20);
    });

    test('250 earnings → inflatedCost(10) == 13 (1.25x)', () {
      final cm = CurrencyManager(lifetimeEarnings: 250);
      // 1 + 250/1000 = 1.25 → 10 * 1.25 = 13 (ceil)
      expect(cm.inflatedCost(10), 13);
    });

    test('lifetimeEarnings increments with _earn calls', () {
      final cm = CurrencyManager();
      cm.earnFromLineClear(2);
      cm.earnFromCombo('large');
      cm.earnFromSynthesis(1);
      // 2 + 3 + 1 = 6
      expect(cm.lifetimeEarnings, 6);
    });
  });

  // ─── LocalRepository getLifetimeEarnings / saveLifetimeEarnings ──────────

  group('LocalRepository lifetime_earnings', () {
    late FakeSecureStorage fakeSecure;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      fakeSecure = FakeSecureStorage();
    });

    Future<LocalRepository> createRepo() async {
      final prefs = await SharedPreferences.getInstance();
      return LocalRepository(prefs, secureStorage: fakeSecure);
    }

    test('getLifetimeEarnings returns 0 by default', () async {
      final repo = await createRepo();
      expect(await repo.getLifetimeEarnings(), 0);
    });

    test('saveLifetimeEarnings + getLifetimeEarnings round-trip', () async {
      final repo = await createRepo();
      await repo.saveLifetimeEarnings(750);
      expect(await repo.getLifetimeEarnings(), 750);
    });

    test('saveLifetimeEarnings removes SharedPreferences fallback', () async {
      SharedPreferences.setMockInitialValues({'lifetime_earnings': 100});
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalRepository(prefs, secureStorage: fakeSecure);
      await repo.saveLifetimeEarnings(200);
      // SharedPreferences anahtari temizlenmeli
      expect(prefs.getInt('lifetime_earnings'), isNull);
      // SecureStorage'dan dogru deger okunmali
      expect(await repo.getLifetimeEarnings(), 200);
    });

    test(
        'getLifetimeEarnings falls back to SharedPreferences when secure is empty',
        () async {
      SharedPreferences.setMockInitialValues({'lifetime_earnings': 300});
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalRepository(prefs, secureStorage: fakeSecure);
      expect(await repo.getLifetimeEarnings(), 300);
    });

    test('exportAllData includes lifetime_earnings', () async {
      final repo = await createRepo();
      await repo.saveLifetimeEarnings(450);
      final data = await repo.exportAllData();
      final currency = data['currency'] as Map<String, dynamic>;
      expect(currency['lifetime_earnings'], 450);
    });

    test('exportAllData includes monetization section with products and codes',
        () async {
      final repo = await createRepo();
      await repo.addUnlockedProducts(['productA', 'productB']);
      await repo.addRedeemedCode('CODE123');
      final data = await repo.exportAllData();
      expect(data['monetization'], isNotNull);
      final monetization = data['monetization'] as Map<String, dynamic>;
      expect(monetization['unlocked_products'], isNotNull);
      expect(monetization['redeemed_codes'], isNotNull);
    });
  });
}
