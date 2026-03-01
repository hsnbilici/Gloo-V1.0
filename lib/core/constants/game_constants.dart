abstract final class GameConstants {
  // Izgara boyutları (varsayılan — seviye modu dinamik override eder)
  static const int gridCols = 8;
  static const int gridRows = 10;
  static const int shapesInHand = 3;

  // Performans hedefleri
  static const int targetFps = 60;
  static const double frameBudgetMs = 1000 / targetFps; // 16.7ms

  // Jel fizik parametreleri
  static const double springStiffness = 800.0;
  static const double springDamping = 15.0;
  static const double springMass = 1.0;
  static const double settleTolerance = 0.001;

  // Jel deformasyon
  static const double deformDuration = 0.3; // saniye
  static const int bezierControlPoints = 8;

  // Parçacık efekti
  static const int burstParticleCount = 14; // Faz 4: 16→14 (8 yerine)
  static const double particleDuration = 0.4; // saniye

  // Near-miss eşikleri
  static const double nearMissThreshold = 0.85;
  static const double criticalNearMissThreshold = 0.95;

  // Video kayıt
  static const int preEventBufferSeconds = 3;
  static const int postEventSeconds = 2;

  // Zaman Koşusu
  static const int timeTrialDuration = 90; // saniye
  static const int timeTrialLineClearBonus = 2; // satır başına kazanılan saniye

  // Skor katsayıları
  static const int singleLineClear = 100;
  static const int multiLineClear = 300;
  static const double comboMultiplier = 1.5;
  static const int colorSynthesisBonus = 50;

  // Pil koruması
  static const int lowBatteryThreshold = 20; // yüzde

  // ─── Faz 4: Yeni sabitler ──────────────────────────────────────────────────

  // Düello modu
  static const int duelDuration = 120; // saniye (2 dakika)
  static const int duelObstacleCooldownMs = 3000; // 3 saniye engel cooldown

  // Ekran sarsıntısı
  static const double shakeAmplitudeEpic = 4.0; // piksel
  static const double shakeAmplitudeLarge = 2.0;
  static const int shakeDurationEpic = 300; // ms
  static const int shakeDurationLarge = 200;

  // Freeze power-up
  static const int freezeDuration = 10; // saniye

  // Merhamet mekanizması
  static const int mercyLossThreshold = 3; // Ardışık kayıp eşiği
  static const int mercyNoClearThreshold = 5; // Temizleme olmadan hamle eşiği
  static const double mercyDifficultyMultiplier = 0.7;

  // Ada sistemi: ilk N oyundan sonra görünür
  static const int islandUnlockGames = 50;

  // Sezon pası
  static const int seasonDurationWeeks = 8;
  static const int seasonTotalTiers = 50;
}
