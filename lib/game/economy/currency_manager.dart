/// Jel Özü — oyun içi soft currency yöneticisi.
///
/// Kazanım kaynakları:
/// - Satır temizleme: 1 Jel Özü / satır
/// - Kombo bonus: medium=2, large=3, epic=5
/// - Renk sentezi: 1 Jel Özü / sentez
/// - Günlük giriş: 3 Jel Özü
/// - Reklam izleme: 5 Jel Özü (opsiyonel)
///
/// Ortalama kazanım: ~15 Jel Özü / oyun
/// Net birikim: ~4-9 Jel Özü / oyun (1-2 power-up kullanımı sonrası)
class CurrencyManager {
  CurrencyManager({int initialBalance = 0}) : _balance = initialBalance;

  int _balance;
  int _earnedThisGame = 0;
  int _spentThisGame = 0;

  int get balance => _balance;
  int get earnedThisGame => _earnedThisGame;
  int get spentThisGame => _spentThisGame;

  void Function(int newBalance)? onBalanceChanged;

  // ─── Kazanım ──────────────────────────────────────────────────────────────

  /// Satır temizleme ödülü.
  void earnFromLineClear(int lineCount) {
    _earn(lineCount);
  }

  /// Kombo bonus ödülü.
  void earnFromCombo(String comboTier) {
    final bonus = switch (comboTier) {
      'medium' => 2,
      'large' => 3,
      'epic' => 5,
      _ => 0,
    };
    if (bonus > 0) _earn(bonus);
  }

  /// Renk sentezi ödülü.
  void earnFromSynthesis(int synthesisCount) {
    _earn(synthesisCount);
  }

  /// Günlük giriş ödülü.
  void earnDailyLogin() {
    _earn(3);
  }

  /// Reklam izleme ödülü.
  void earnFromAd() {
    _earn(5);
  }

  /// Gloo+ aboneler için bonus çarpan (%50 ekstra).
  void applyGlooPlusBonus(int baseEarned) {
    final bonus = (baseEarned * 0.5).round();
    if (bonus > 0) _earn(bonus);
  }

  void _earn(int amount) {
    _balance += amount;
    _earnedThisGame += amount;
    onBalanceChanged?.call(_balance);
  }

  // ─── Harcama ──────────────────────────────────────────────────────────────

  /// Belirtilen miktarı harcar. Yeterliyse true döner.
  bool spend(int amount) {
    if (_balance < amount) return false;
    _balance -= amount;
    _spentThisGame += amount;
    onBalanceChanged?.call(_balance);
    return true;
  }

  /// Bakiye yeterli mi?
  bool canAfford(int cost) => _balance >= cost;

  // ─── Oyun başı sıfırlama ─────────────────────────────────────────────────

  void resetGameStats() {
    _earnedThisGame = 0;
    _spentThisGame = 0;
  }

  /// Bakiyeyi dışarıdan ayarla (SharedPreferences yükleme için).
  void setBalance(int value) {
    _balance = value;
    onBalanceChanged?.call(_balance);
  }
}

/// Jel Özü sabit maliyetleri.
abstract final class CurrencyCosts {
  static const int rotate = 3;
  static const int bomb = 8;
  static const int peek = 2;
  static const int undo = 5;
  static const int rainbow = 10;
  static const int freeze = 6;

  /// PvP savunma power-up'ları.
  static const int shield = 3;
  static const int reflect = 8;
}
