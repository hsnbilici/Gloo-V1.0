import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/game/economy/currency_manager.dart';

void main() {
  late CurrencyManager cm;

  setUp(() {
    cm = CurrencyManager();
  });

  // ─── Baslangic durumu ──────────────────────────────────────────────────────

  group('CurrencyManager initial state', () {
    test('default balance is 0', () {
      expect(cm.balance, 0);
    });

    test('custom initial balance', () {
      final cm2 = CurrencyManager(initialBalance: 100);
      expect(cm2.balance, 100);
    });

    test('game stats start at 0', () {
      expect(cm.earnedThisGame, 0);
      expect(cm.spentThisGame, 0);
    });
  });

  // ─── Kazanim ───────────────────────────────────────────────────────────────

  group('CurrencyManager earning', () {
    test('earnFromLineClear adds lineCount to balance', () {
      cm.earnFromLineClear(3);
      expect(cm.balance, 3);
      expect(cm.earnedThisGame, 3);
    });

    test('earnFromCombo medium adds 2', () {
      cm.earnFromCombo('medium');
      expect(cm.balance, 2);
    });

    test('earnFromCombo large adds 3', () {
      cm.earnFromCombo('large');
      expect(cm.balance, 3);
    });

    test('earnFromCombo epic adds 5', () {
      cm.earnFromCombo('epic');
      expect(cm.balance, 5);
    });

    test('earnFromCombo small adds 0', () {
      cm.earnFromCombo('small');
      expect(cm.balance, 0);
    });

    test('earnFromCombo unknown tier adds 0', () {
      cm.earnFromCombo('unknown');
      expect(cm.balance, 0);
    });

    test('earnFromSynthesis adds synthesis count', () {
      cm.earnFromSynthesis(2);
      expect(cm.balance, 2);
    });

    test('earnDailyLogin adds 3', () {
      cm.earnDailyLogin();
      expect(cm.balance, 3);
    });

    test('earnFromAd adds 5', () {
      cm.earnFromAd();
      expect(cm.balance, 5);
    });

    test('applyGlooPlusBonus adds 50% extra', () {
      cm.applyGlooPlusBonus(10);
      expect(cm.balance, 5); // 10 * 0.5 = 5
    });

    test('applyGlooPlusBonus rounds correctly', () {
      cm.applyGlooPlusBonus(3);
      expect(cm.balance, 2); // 3 * 0.5 = 1.5 → round = 2
    });

    test('earnings accumulate', () {
      cm.earnFromLineClear(2);
      cm.earnFromCombo('epic');
      cm.earnFromSynthesis(1);
      cm.earnDailyLogin();
      expect(cm.balance, 2 + 5 + 1 + 3);
      expect(cm.earnedThisGame, 11);
    });
  });

  // ─── Harcama ───────────────────────────────────────────────────────────────

  group('CurrencyManager spending', () {
    test('spend deducts from balance', () {
      cm.setBalance(20);
      final success = cm.spend(8);
      expect(success, isTrue);
      expect(cm.balance, 12);
      expect(cm.spentThisGame, 8);
    });

    test('spend fails when insufficient balance', () {
      cm.setBalance(5);
      final success = cm.spend(10);
      expect(success, isFalse);
      expect(cm.balance, 5);
      expect(cm.spentThisGame, 0);
    });

    test('spend exact balance succeeds', () {
      cm.setBalance(10);
      final success = cm.spend(10);
      expect(success, isTrue);
      expect(cm.balance, 0);
    });

    test('canAfford checks correctly', () {
      cm.setBalance(15);
      expect(cm.canAfford(10), isTrue);
      expect(cm.canAfford(15), isTrue);
      expect(cm.canAfford(16), isFalse);
      expect(cm.canAfford(0), isTrue);
    });
  });

  // ─── Oyun basi sifirlama ──────────────────────────────────────────────────

  group('CurrencyManager reset', () {
    test('resetGameStats clears game-specific counters', () {
      cm.earnFromLineClear(5);
      cm.setBalance(20);
      cm.spend(3);
      expect(cm.earnedThisGame, 5);
      expect(cm.spentThisGame, 3);

      cm.resetGameStats();
      expect(cm.earnedThisGame, 0);
      expect(cm.spentThisGame, 0);
      expect(cm.balance, 17); // Balance korunur
    });
  });

  // ─── setBalance ────────────────────────────────────────────────────────────

  group('CurrencyManager.setBalance', () {
    test('sets balance directly', () {
      cm.setBalance(999);
      expect(cm.balance, 999);
    });
  });

  // ─── onBalanceChanged callback ─────────────────────────────────────────────

  group('CurrencyManager callbacks', () {
    test('onBalanceChanged fires on earn', () {
      int? lastBalance;
      cm.onBalanceChanged = (b) => lastBalance = b;

      cm.earnFromLineClear(5);
      expect(lastBalance, 5);
    });

    test('onBalanceChanged fires on spend', () {
      int? lastBalance;
      cm.setBalance(20);
      cm.onBalanceChanged = (b) => lastBalance = b;

      cm.spend(7);
      expect(lastBalance, 13);
    });

    test('onBalanceChanged fires on setBalance', () {
      int? lastBalance;
      cm.onBalanceChanged = (b) => lastBalance = b;

      cm.setBalance(42);
      expect(lastBalance, 42);
    });
  });

  // ─── CurrencyCosts sabitleri ───────────────────────────────────────────────

  group('CurrencyCosts', () {
    test('power-up costs are defined', () {
      expect(CurrencyCosts.rotate, 3);
      expect(CurrencyCosts.bomb, 8);
      expect(CurrencyCosts.peek, 2);
      expect(CurrencyCosts.undo, 5);
      expect(CurrencyCosts.rainbow, 10);
      expect(CurrencyCosts.freeze, 6);
    });

    test('PvP costs are defined', () {
      expect(CurrencyCosts.shield, 3);
      expect(CurrencyCosts.reflect, 8);
    });
  });
}
