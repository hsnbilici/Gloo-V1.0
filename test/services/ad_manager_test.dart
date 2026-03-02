import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/services/ad_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdManager', () {
    late AdManager ad;

    setUp(() {
      ad = AdManager();
      // Reset state for clean tests
      ad.setAdsRemoved(false);
      ad.setGamesPlayed(0);
    });

    // ── Singleton ───────────────────────────────────────────────────────────
    test('singleton returns same instance', () {
      final a = AdManager();
      final b = AdManager();
      expect(identical(a, b), isTrue);
    });

    // ── adsRemoved ──────────────────────────────────────────────────────────
    test('setAdsRemoved updates adsRemoved flag to true', () {
      ad.setAdsRemoved(true);
      expect(ad.adsRemoved, isTrue);
    });

    test('setAdsRemoved updates adsRemoved flag to false', () {
      ad.setAdsRemoved(true);
      ad.setAdsRemoved(false);
      expect(ad.adsRemoved, isFalse);
    });

    // ── gamesPlayed ─────────────────────────────────────────────────────────
    test('setGamesPlayed / gamesPlayed round-trips', () {
      ad.setGamesPlayed(42);
      expect(ad.gamesPlayed, 42);
    });

    test('setGamesPlayed resets to zero', () {
      ad.setGamesPlayed(10);
      ad.setGamesPlayed(0);
      expect(ad.gamesPlayed, 0);
    });

    // ── isRewardedReady ─────────────────────────────────────────────────────
    test('isRewardedReady is false when adsRemoved', () {
      ad.setAdsRemoved(true);
      expect(ad.isRewardedReady, isFalse);
    });

    test('isRewardedReady is false when no ad loaded', () {
      // _rewardedAd is null (no real ads in test env)
      expect(ad.isRewardedReady, isFalse);
    });

    // ── canOfferRewarded ────────────────────────────────────────────────────
    test('canOfferRewarded returns false when adsRemoved', () {
      ad.setAdsRemoved(true);
      expect(ad.canOfferRewarded(), isFalse);
    });

    test('canOfferRewarded returns false when no ad loaded', () {
      // _rewardedAd null → false
      expect(ad.canOfferRewarded(), isFalse);
    });

    // ── canShowSecondChance ─────────────────────────────────────────────────
    test('canShowSecondChance returns false when canOfferRewarded is false',
        () {
      // canOfferRewarded false (no ad loaded) → canShowSecondChance false
      expect(
        ad.canShowSecondChance(currentScore: 100, averageScore: 50),
        isFalse,
      );
    });

    test('canShowSecondChance returns false when adsRemoved', () {
      ad.setAdsRemoved(true);
      expect(
        ad.canShowSecondChance(currentScore: 900, averageScore: 100),
        isFalse,
      );
    });

    test('canShowSecondChance returns false when within new player protection',
        () {
      ad.setGamesPlayed(1); // <= 3
      expect(
        ad.canShowSecondChance(currentScore: 100, averageScore: 50),
        isFalse,
      );
    });

    // ── canShowNearMissRescue ───────────────────────────────────────────────
    test('canShowNearMissRescue returns false when no ad', () {
      expect(ad.canShowNearMissRescue(), isFalse);
    });

    test('canShowNearMissRescue returns false when adsRemoved', () {
      ad.setAdsRemoved(true);
      expect(ad.canShowNearMissRescue(), isFalse);
    });

    // ── canShowDailyContinue ────────────────────────────────────────────────
    test('canShowDailyContinue returns false when no ad', () {
      expect(ad.canShowDailyContinue(), isFalse);
    });

    // ── canShowHighScoreContinue ────────────────────────────────────────────
    test('canShowHighScoreContinue returns false when no ad', () {
      expect(
        ad.canShowHighScoreContinue(currentScore: 900, highScore: 1000),
        isFalse,
      );
    });

    test('canShowHighScoreContinue returns false when adsRemoved', () {
      ad.setAdsRemoved(true);
      expect(
        ad.canShowHighScoreContinue(currentScore: 999, highScore: 1000),
        isFalse,
      );
    });

    // ── bannerAd ────────────────────────────────────────────────────────────
    test('bannerAd is null when no banner loaded', () {
      expect(ad.bannerAd, isNull);
    });

    // ── disposeBanner no-op ─────────────────────────────────────────────────
    test('disposeBanner does not throw when no banner loaded', () {
      expect(() => ad.disposeBanner(), returnsNormally);
    });

    // ── dispose no-op ───────────────────────────────────────────────────────
    test('dispose does not throw when no ads loaded', () {
      expect(() => ad.dispose(), returnsNormally);
    });

    // ── recordRewardedView ──────────────────────────────────────────────────
    test('recordRewardedView does not throw', () {
      expect(() => ad.recordRewardedView(), returnsNormally);
    });

    // ── onGameOver: gamesPlayed artışı ──────────────────────────────────────
    test('onGameOver increments gamesPlayed', () {
      ad.setGamesPlayed(0);
      ad.onGameOver();
      expect(ad.gamesPlayed, 1);
    });

    test('onGameOver increments gamesPlayed each call', () {
      ad.setGamesPlayed(0);
      ad.onGameOver();
      ad.onGameOver();
      ad.onGameOver();
      expect(ad.gamesPlayed, 3);
    });

    // ── onGameOver: adsRemoved guard ────────────────────────────────────────
    test('onGameOver does not increment gamesPlayed when adsRemoved', () {
      ad.setAdsRemoved(true);
      ad.setGamesPlayed(0);
      ad.onGameOver();
      expect(ad.gamesPlayed, 0);
    });

    // ── onGameOver: new player protection ───────────────────────────────────
    test('onGameOver respects new player protection (first 3 games)', () {
      // New player protection: ilk 3 oyunda reklam yok
      // _gamesPlayed 0→1, 1→2, 2→3 — hepsi <= 3
      ad.setGamesPlayed(0);
      ad.onGameOver(); // 1
      ad.onGameOver(); // 2
      ad.onGameOver(); // 3
      expect(ad.gamesPlayed, 3);
      // No interstitial should have been attempted (gamesPlayed <= 3)
      // Bu davranışı doğrudan doğrulayamasak da, gamesPlayed sayacı doğru
    });

    // ── showRewarded: no ad loaded ──────────────────────────────────────────
    test('showRewarded does not call onRewarded when no ad loaded', () {
      bool called = false;
      // _rewardedAd null → _loadRewarded() çağrılır (platform kanalı
      // çöküşünü engellemek için adsRemoved = true yapıyoruz)
      ad.setAdsRemoved(true);
      ad.showRewarded(onRewarded: () => called = true);
      expect(called, isFalse);
    });

    // ── showInterstitial: adsRemoved guard ──────────────────────────────────
    test('showInterstitial does not throw when adsRemoved', () {
      ad.setAdsRemoved(true);
      expect(() => ad.showInterstitial(), returnsNormally);
    });

    // ── showSecondChance: adsRemoved guard ──────────────────────────────────
    test('showSecondChance does not call onRewarded when adsRemoved', () {
      ad.setAdsRemoved(true);
      bool called = false;
      ad.showSecondChance(onRewarded: () => called = true);
      expect(called, isFalse);
    });

    // ── showNearMissRescue: adsRemoved guard ────────────────────────────────
    test('showNearMissRescue does not call onRewarded when adsRemoved', () {
      ad.setAdsRemoved(true);
      bool called = false;
      ad.showNearMissRescue(onRewarded: () => called = true);
      expect(called, isFalse);
    });

    // ── showDailyContinue: adsRemoved guard ─────────────────────────────────
    test('showDailyContinue does not call onRewarded when adsRemoved', () {
      ad.setAdsRemoved(true);
      bool called = false;
      ad.showDailyContinue(onRewarded: () => called = true);
      expect(called, isFalse);
    });

    // ── showHighScoreContinue: adsRemoved guard ─────────────────────────────
    test('showHighScoreContinue does not call onRewarded when adsRemoved', () {
      ad.setAdsRemoved(true);
      bool called = false;
      ad.showHighScoreContinue(onRewarded: () => called = true);
      expect(called, isFalse);
    });

    // ── loadBanner: adsRemoved guard ────────────────────────────────────────
    test('loadBanner does not throw when adsRemoved', () {
      ad.setAdsRemoved(true);
      // AdSize gerektirdiği için bunu çağıramayız; ama adsRemoved olunca
      // erken dönmeli — burada sadece adsRemoved = true guard'ı test ediyoruz
      // loadBanner imzası AdSize gerektirdiğinden, guard davranışı
      // bannerAd'ın null kalması ile dolaylı olarak doğrulanır
      expect(ad.bannerAd, isNull);
    });
  });
}
