import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/game/economy/currency_manager.dart';

void main() {
  group('Inflation control', () {
    test('inflatedCost returns baseCost at 0 lifetime earnings', () {
      final cm = CurrencyManager(initialBalance: 100);
      expect(cm.inflatedCost(CurrencyCosts.rotate), CurrencyCosts.rotate);
    });

    test('inflatedCost increases with lifetime earnings', () {
      final cm = CurrencyManager(initialBalance: 100);
      cm.addLifetimeEarnings(1000);
      // 1 + 1000/1000 = 2.0 → rotate 3 * 2 = 6
      expect(cm.inflatedCost(CurrencyCosts.rotate), 6);
    });

    test('inflatedCost caps at 2x', () {
      final cm = CurrencyManager(initialBalance: 100);
      cm.addLifetimeEarnings(5000);
      // 1 + 5000/1000 = 6 → clamp 2.0 → rotate 3 * 2 = 6
      expect(cm.inflatedCost(CurrencyCosts.rotate), 6);
    });

    test('inflatedCost rounds up', () {
      final cm = CurrencyManager(initialBalance: 100);
      cm.addLifetimeEarnings(500);
      // 1 + 500/1000 = 1.5 → peek 2 * 1.5 = 3
      expect(cm.inflatedCost(CurrencyCosts.peek), 3);
    });

    test('lifetime earnings accumulate through _earn', () {
      final cm = CurrencyManager(initialBalance: 0);
      cm.earnFromLineClear(3);
      cm.earnFromCombo('epic');
      // 3 + 5 = 8 total
      expect(cm.lifetimeEarnings, 8);
    });

    test('setLifetimeEarnings restores persisted value', () {
      final cm = CurrencyManager(initialBalance: 0);
      cm.setLifetimeEarnings(1000);
      // 1 + 1000/1000 = 2.0 → rotate 3 * 2 = 6
      expect(cm.inflatedCost(CurrencyCosts.rotate), 6);
    });
  });
}
