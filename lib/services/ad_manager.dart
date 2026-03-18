import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'consent_service.dart';

/// AdMob reklam yöneticisi — singleton.
///
/// Web platformunda no-op: [kIsWeb] true iken tüm metodlar sessizce döner.
/// `google_mobile_ads` web'de çalışmaz; platform guard ile korunmuştur.
///
/// GDD 3.2 kuralları:
/// - Interstitial: her 4 oyun sonrası (oyun ortasında asla)
/// - Rewarded: "Bir can daha kazan" — oyuncu isteğiyle
/// - Banner: yalnızca ana menüde, oyun ekranında asla
/// - Anti-frustration: 5 dk içinde 2 kayıp → ekstra reklam gösterilmez
///
/// Faz 4 eklemeleri:
/// - Loss aversion tetikleyici noktaları
/// - Günlük hard cap: 8 interstitial, 5 rewarded teklif
/// - Yeni oyuncu koruması: ilk 3 oyunda reklam yok
class AdManager {
  AdManager._();
  static final AdManager _instance = AdManager._();
  factory AdManager() => _instance;

  bool _initialized = false;
  bool _adsRemoved = false;

  int _gamesPlayed = 0;
  DateTime? _lastLossTime;
  int _recentLosses = 0;

  // Faz 4: Günlük limitler
  int _dailyInterstitialCount = 0;
  int _dailyRewardedOfferCount = 0;
  DateTime? _lastDailyReset;
  DateTime? _lastRewardedTime;

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  BannerAd? _bannerAd;

  // ── AdMob etkinlik bayrağı ───────────────────────────────────────────────
  // --dart-define=AD_ENABLED=true ile aktif edilir. Varsayılan: devre dışı.
  // Gerçek AdMob ID'ler alındığında CI/local build'da bu flag açılır.
  static const _adEnabled =
      bool.fromEnvironment('AD_ENABLED', defaultValue: false);

  // ── Reklam ID'leri ───────────────────────────────────────────────────────
  // --dart-define ile inject edilir. Boş ise test ID kullanılır.
  static const _bannerIdIos = String.fromEnvironment('AD_BANNER_IOS');
  static const _bannerIdAndroid = String.fromEnvironment('AD_BANNER_ANDROID');
  static const _interstitialIdIos =
      String.fromEnvironment('AD_INTERSTITIAL_IOS');
  static const _interstitialIdAndroid =
      String.fromEnvironment('AD_INTERSTITIAL_ANDROID');
  static const _rewardedIdIos = String.fromEnvironment('AD_REWARDED_IOS');
  static const _rewardedIdAndroid =
      String.fromEnvironment('AD_REWARDED_ANDROID');

  static const _kTestBannerIos = 'ca-app-pub-3940256099942544/2435281174';
  static const _kTestBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const _kTestInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';
  static const _kTestInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const _kTestRewardedIos = 'ca-app-pub-3940256099942544/1712485313';
  static const _kTestRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';

  static String get _kBanner => _isIOS
      ? (_bannerIdIos.isNotEmpty ? _bannerIdIos : _kTestBannerIos)
      : (_bannerIdAndroid.isNotEmpty ? _bannerIdAndroid : _kTestBannerAndroid);
  static String get _kInterstitial => _isIOS
      ? (_interstitialIdIos.isNotEmpty
          ? _interstitialIdIos
          : _kTestInterstitialIos)
      : (_interstitialIdAndroid.isNotEmpty
          ? _interstitialIdAndroid
          : _kTestInterstitialAndroid);
  static String get _kRewarded => _isIOS
      ? (_rewardedIdIos.isNotEmpty ? _rewardedIdIos : _kTestRewardedIos)
      : (_rewardedIdAndroid.isNotEmpty
          ? _rewardedIdAndroid
          : _kTestRewardedAndroid);

  static bool get _isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  // Faz 4: Sabitler
  static const int _maxDailyInterstitial = 8;
  static const int _maxDailyRewardedOffer = 5;
  static const int _newPlayerProtection = 3; // İlk 3 oyunda reklam yok

  // ── Init ──────────────────────────────────────────────────────────────────
  Future<void> initialize() async {
    if (kIsWeb || _initialized || !_adEnabled) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    _loadInterstitial();
    _loadRewarded();
    if (kDebugMode) debugPrint('AdManager: initialized');
  }

  /// IAP satın alımı sonrası reklamları kaldırır.
  void setAdsRemoved(bool removed) {
    _adsRemoved = removed;
    if (removed) {
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _rewardedAd?.dispose();
      _rewardedAd = null;
      disposeBanner();
    }
  }

  bool get adsRemoved => _adsRemoved;

  /// Oynanan oyun sayısını dışarıdan ayarla (kalıcılık için).
  void setGamesPlayed(int count) => _gamesPlayed = count;
  int get gamesPlayed => _gamesPlayed;

  // ── Günlük limit sıfırlama ───────────────────────────────────────────────
  void _checkDailyReset() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_lastDailyReset == null || _lastDailyReset!.isBefore(today)) {
      _dailyInterstitialCount = 0;
      _dailyRewardedOfferCount = 0;
      _lastDailyReset = today;
    }
  }

  // ── Interstitial ─────────────────────────────────────────────────────────
  void _loadInterstitial() {
    if (kIsWeb || _adsRemoved) return;
    InterstitialAd.load(
      adUnitId: _kInterstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) {
          if (kDebugMode)
            debugPrint('AdManager: interstitial load failed: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Oyun sonu sonrası çağrılır. Her 4 oyunda bir gösterir.
  /// Anti-frustration: 5 dk içinde 2 kayıp varsa göstermez.
  void onGameOver() {
    if (kIsWeb || _adsRemoved) return;

    _gamesPlayed++;
    _checkDailyReset();

    // Yeni oyuncu koruması
    if (_gamesPlayed <= _newPlayerProtection) return;

    // Anti-frustration kontrolü
    final now = DateTime.now();
    if (_lastLossTime != null && now.difference(_lastLossTime!).inMinutes < 5) {
      _recentLosses++;
    } else {
      _recentLosses = 1;
    }
    _lastLossTime = now;
    if (_recentLosses >= 2) return;

    // Günlük hard cap
    if (_dailyInterstitialCount >= _maxDailyInterstitial) return;

    if (_gamesPlayed % 4 != 0) return;

    showInterstitial();
  }

  void showInterstitial() {
    if (kIsWeb || _adsRemoved) return;
    if (!ConsentService().canShowAds) return;
    _checkDailyReset();
    if (_dailyInterstitialCount >= _maxDailyInterstitial) return;

    final ad = _interstitialAd;
    if (ad == null) {
      _loadInterstitial();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadInterstitial();
      },
    );
    ad.show();
    _interstitialAd = null;
    _dailyInterstitialCount++;
  }

  // ── Rewarded ──────────────────────────────────────────────────────────────
  void _loadRewarded() {
    if (kIsWeb || _adsRemoved) return;
    RewardedAd.load(
      adUnitId: _kRewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) {
          if (kDebugMode) debugPrint('AdManager: rewarded load failed: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  bool get isRewardedReady => !kIsWeb && !_adsRemoved && _rewardedAd != null;

  /// Rewarded video gösterir. [onRewarded] video izlendikten sonra çağrılır.
  void showRewarded({required VoidCallback onRewarded}) {
    if (kIsWeb || _adsRemoved) return;
    if (!ConsentService().canShowAds) return;
    final ad = _rewardedAd;
    if (ad == null) {
      _loadRewarded();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewarded();
      },
    );
    ad.show(
      onUserEarnedReward: (_, __) => onRewarded(),
    );
    _rewardedAd = null;
  }

  // ── Faz 4: Loss Aversion Tetikleyicileri ──────────────────────────────────

  /// Rewarded teklif edilebilir mi? (Günlük limit + cooldown kontrolü)
  bool canOfferRewarded() {
    if (kIsWeb || _adsRemoved) return false;
    if (!ConsentService().canShowAds) return false;
    _checkDailyReset();
    if (_dailyRewardedOfferCount >= _maxDailyRewardedOffer) return false;
    // Son 1 saatte reklam izlenmemişse
    if (_lastRewardedTime != null &&
        DateTime.now().difference(_lastRewardedTime!).inMinutes < 60) {
      return false;
    }
    return _rewardedAd != null;
  }

  /// Game Over anında "İkinci Şans" gösterilebilir mi?
  /// Koşul: Skor > kişisel ortalama × 0.8 VE yeni oyuncu koruması geçmiş.
  bool canShowSecondChance({
    required int currentScore,
    required int averageScore,
  }) {
    if (!canOfferRewarded()) return false;
    if (_gamesPlayed <= _newPlayerProtection) return false;
    return currentScore > (averageScore * 0.8);
  }

  /// Near-miss critical anında "Kurtarılabilir!" gösterilebilir mi?
  bool canShowNearMissRescue() {
    return canOfferRewarded();
  }

  /// Günlük bulmaca başarısızlık → "Devam et" gösterilebilir mi?
  bool canShowDailyContinue() {
    return canOfferRewarded();
  }

  /// High score yaklaşma → "Devam et" gösterilebilir mi?
  bool canShowHighScoreContinue({
    required int currentScore,
    required int highScore,
  }) {
    if (!canOfferRewarded()) return false;
    return currentScore >= (highScore * 0.9);
  }

  /// Rewarded video izledikten sonra çağrılır (takip için).
  void recordRewardedView() {
    _dailyRewardedOfferCount++;
    _lastRewardedTime = DateTime.now();
  }

  /// İkinci Şans: Rewarded izle → ekstra hamle ver.
  void showSecondChance({required VoidCallback onRewarded}) {
    recordRewardedView();
    showRewarded(onRewarded: onRewarded);
  }

  /// Near-miss kurtarma: Rewarded izle → Bomb power-up.
  void showNearMissRescue({required VoidCallback onRewarded}) {
    recordRewardedView();
    showRewarded(onRewarded: onRewarded);
  }

  /// Günlük bulmaca devam: Rewarded izle → devam et.
  void showDailyContinue({required VoidCallback onRewarded}) {
    recordRewardedView();
    showRewarded(onRewarded: onRewarded);
  }

  /// High score devam: Rewarded izle → 5 ekstra hamle.
  void showHighScoreContinue({required VoidCallback onRewarded}) {
    recordRewardedView();
    showRewarded(onRewarded: onRewarded);
  }

  // ── Banner ────────────────────────────────────────────────────────────────
  BannerAd? get bannerAd => _bannerAd;

  void loadBanner({required AdSize size}) {
    if (kIsWeb || _adsRemoved) return;
    if (!ConsentService().canShowAds) return;
    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: _kBanner,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (kDebugMode) debugPrint('AdManager: banner loaded');
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) debugPrint('AdManager: banner failed: $error');
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  void disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd?.dispose();
  }
}
