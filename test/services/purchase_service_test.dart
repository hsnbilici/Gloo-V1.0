import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:gloo/services/purchase_service.dart';

/// PurchaseService singleton'unun ilk erisiminde InAppPurchase.instance
/// Android billing client'e baglanmaya calisir ve test ortaminda
/// async PlatformException firlatir. Bu hatayi yakalamak icin singleton'u
/// main() seviyesinde (test zone'u disinda) olusturuyoruz.
late final PurchaseService _ps;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Singleton'u olustur ve async platform hatasinin tamamlanmasini bekle.
    // runZonedGuarded ile async PlatformException yakalanir.
    final completer = Completer<void>();
    runZonedGuarded(
      () {
        _ps = PurchaseService();
        // Android billing client async baglanti hatasinin islemci
        // dongusunden cikmasi icin bekle.
        Future<void>.delayed(const Duration(milliseconds: 200)).then((_) {
          if (!completer.isCompleted) completer.complete();
        });
      },
      (error, stack) {
        // PlatformException'i sessizce yakala — test ortaminda beklenen davranis
        if (!completer.isCompleted) completer.complete();
      },
    );
    await completer.future;
  });

  group('PurchaseService', () {
    setUp(() {
      _ps.onPurchaseUpdate = null;
    });

    // ── Singleton ───────────────────────────────────────────────────────────
    test('singleton returns same instance', () {
      final a = PurchaseService();
      final b = PurchaseService();
      expect(identical(a, b), isTrue);
    });

    // ── Urun ID sabitleri ───────────────────────────────────────────────────
    test('product ID constants are non-empty strings', () {
      expect(PurchaseService.kRemoveAds, isNotEmpty);
      expect(PurchaseService.kSoundCrystal, isNotEmpty);
      expect(PurchaseService.kSoundForest, isNotEmpty);
      expect(PurchaseService.kTexturePack, isNotEmpty);
      expect(PurchaseService.kStarterPack, isNotEmpty);
      expect(PurchaseService.kGlooPlusMonthly, isNotEmpty);
      expect(PurchaseService.kGlooPlusYearly, isNotEmpty);
    });

    test('product IDs follow gloo_ naming convention', () {
      expect(PurchaseService.kRemoveAds, startsWith('gloo_'));
      expect(PurchaseService.kSoundCrystal, startsWith('gloo_'));
      expect(PurchaseService.kSoundForest, startsWith('gloo_'));
      expect(PurchaseService.kTexturePack, startsWith('gloo_'));
      expect(PurchaseService.kStarterPack, startsWith('gloo_'));
      expect(PurchaseService.kGlooPlusMonthly, startsWith('gloo_'));
      expect(PurchaseService.kGlooPlusYearly, startsWith('gloo_'));
    });

    test('product IDs are unique', () {
      final ids = [
        PurchaseService.kRemoveAds,
        PurchaseService.kSoundCrystal,
        PurchaseService.kSoundForest,
        PurchaseService.kTexturePack,
        PurchaseService.kStarterPack,
        PurchaseService.kGlooPlusMonthly,
        PurchaseService.kGlooPlusYearly,
      ];
      expect(ids.toSet().length, ids.length);
    });

    test('product ID values match expected store IDs', () {
      expect(PurchaseService.kRemoveAds, 'gloo_remove_ads');
      expect(PurchaseService.kSoundCrystal, 'gloo_sound_crystal');
      expect(PurchaseService.kSoundForest, 'gloo_sound_forest');
      expect(PurchaseService.kTexturePack, 'gloo_texture_pack');
      expect(PurchaseService.kStarterPack, 'gloo_starter_pack');
      expect(PurchaseService.kGlooPlusMonthly, 'gloo_plus_monthly');
      expect(PurchaseService.kGlooPlusYearly, 'gloo_plus_yearly');
    });

    // ── allProductIds ───────────────────────────────────────────────────────
    test('allProductIds contains all 7 products', () {
      final all = PurchaseService.allProductIds;
      expect(all.length, 7);
      expect(all, contains(PurchaseService.kRemoveAds));
      expect(all, contains(PurchaseService.kSoundCrystal));
      expect(all, contains(PurchaseService.kSoundForest));
      expect(all, contains(PurchaseService.kTexturePack));
      expect(all, contains(PurchaseService.kStarterPack));
      expect(all, contains(PurchaseService.kGlooPlusMonthly));
      expect(all, contains(PurchaseService.kGlooPlusYearly));
    });

    test('allProductIds includes non-consumables and subscriptions', () {
      final all = PurchaseService.allProductIds;
      // 5 non-consumable + 2 subscription = 7
      expect(all.length, 7);
    });

    // ── isPurchased ─────────────────────────────────────────────────────────
    test('isPurchased returns false for unknown product', () {
      expect(_ps.isPurchased('nonexistent_product'), isFalse);
    });

    // ── unlockProducts ──────────────────────────────────────────────────────
    test('unlockProducts adds product to purchasedIds', () {
      _ps.unlockProducts([PurchaseService.kSoundCrystal]);
      expect(_ps.isPurchased(PurchaseService.kSoundCrystal), isTrue);
      expect(_ps.purchasedIds, contains(PurchaseService.kSoundCrystal));
    });

    test('unlockProducts with starter pack bundles all sub-products', () {
      _ps.unlockProducts([PurchaseService.kStarterPack]);

      expect(_ps.isPurchased(PurchaseService.kStarterPack), isTrue);
      expect(_ps.isPurchased(PurchaseService.kRemoveAds), isTrue);
      expect(_ps.isPurchased(PurchaseService.kSoundCrystal), isTrue);
      expect(_ps.isPurchased(PurchaseService.kSoundForest), isTrue);
      expect(_ps.isPurchased(PurchaseService.kTexturePack), isTrue);
    });

    test('unlockProducts with multiple items', () {
      _ps.unlockProducts([
        PurchaseService.kSoundCrystal,
        PurchaseService.kSoundForest,
      ]);
      expect(_ps.isPurchased(PurchaseService.kSoundCrystal), isTrue);
      expect(_ps.isPurchased(PurchaseService.kSoundForest), isTrue);
    });

    test('unlockProducts triggers onPurchaseUpdate callback', () {
      Set<String>? receivedIds;
      _ps.onPurchaseUpdate = (ids) => receivedIds = ids;

      _ps.unlockProducts([PurchaseService.kTexturePack]);

      expect(receivedIds, isNotNull);
      expect(receivedIds, contains(PurchaseService.kTexturePack));

      _ps.onPurchaseUpdate = null;
    });

    test(
        'unlockProducts with starter pack triggers callback with all sub-products',
        () {
      Set<String>? receivedIds;
      _ps.onPurchaseUpdate = (ids) => receivedIds = ids;

      _ps.unlockProducts([PurchaseService.kStarterPack]);

      expect(receivedIds, isNotNull);
      expect(receivedIds, contains(PurchaseService.kStarterPack));
      expect(receivedIds, contains(PurchaseService.kRemoveAds));
      expect(receivedIds, contains(PurchaseService.kSoundCrystal));
      expect(receivedIds, contains(PurchaseService.kSoundForest));
      expect(receivedIds, contains(PurchaseService.kTexturePack));

      _ps.onPurchaseUpdate = null;
    });

    // ── isGlooPlus ──────────────────────────────────────────────────────────
    test('isGlooPlus returns true with monthly subscription', () {
      _ps.unlockProducts([PurchaseService.kGlooPlusMonthly]);
      expect(_ps.isGlooPlus, isTrue);
    });

    test('isGlooPlus returns true with yearly subscription', () {
      _ps.unlockProducts([PurchaseService.kGlooPlusYearly]);
      expect(_ps.isGlooPlus, isTrue);
    });

    test('isGlooPlus returns true with both subscriptions', () {
      _ps.unlockProducts([
        PurchaseService.kGlooPlusMonthly,
        PurchaseService.kGlooPlusYearly,
      ]);
      expect(_ps.isGlooPlus, isTrue);
    });

    // ── adsRemoved ──────────────────────────────────────────────────────────
    test('adsRemoved returns true with kRemoveAds', () {
      _ps.unlockProducts([PurchaseService.kRemoveAds]);
      expect(_ps.adsRemoved, isTrue);
    });

    test('adsRemoved returns true with starter pack', () {
      _ps.unlockProducts([PurchaseService.kStarterPack]);
      expect(_ps.adsRemoved, isTrue);
    });

    test('adsRemoved returns true with Gloo+ monthly', () {
      _ps.unlockProducts([PurchaseService.kGlooPlusMonthly]);
      expect(_ps.adsRemoved, isTrue);
    });

    test('adsRemoved returns true with Gloo+ yearly', () {
      _ps.unlockProducts([PurchaseService.kGlooPlusYearly]);
      expect(_ps.adsRemoved, isTrue);
    });

    // ── priceOf ─────────────────────────────────────────────────────────────
    test('priceOf returns default fallback when products not loaded', () {
      expect(_ps.priceOf(PurchaseService.kRemoveAds), '\u2014');
    });

    test('priceOf returns custom fallback', () {
      expect(
        _ps.priceOf(PurchaseService.kRemoveAds, fallback: '\$2.99'),
        '\$2.99',
      );
    });

    test('priceOf returns fallback for unknown product', () {
      expect(_ps.priceOf('unknown_product_xyz', fallback: 'N/A'), 'N/A');
    });

    // ── products / purchasedIds unmodifiable ─────────────────────────────────
    test('products returns unmodifiable map', () {
      final map = _ps.products;
      expect(map, isA<Map<String, dynamic>>());
      expect(() => (map as dynamic).remove('test'), throwsUnsupportedError);
    });

    test('purchasedIds returns unmodifiable set', () {
      expect(
        () => _ps.purchasedIds.add('test'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    // ── pendingVerification ─────────────────────────────────────────────────
    test('pendingVerification returns unmodifiable set', () {
      expect(
        () => _ps.pendingVerification.add('test'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('pendingVerification is a set', () {
      expect(_ps.pendingVerification, isA<Set<String>>());
    });

    // ── buyProduct without products loaded ──────────────────────────────────
    test('buyProduct returns false when product not in map', () async {
      final result = await _ps.buyProduct('nonexistent_product');
      expect(result, isFalse);
    });

    test('buyProduct returns false for valid ID but not loaded', () async {
      final result = await _ps.buyProduct(PurchaseService.kRemoveAds);
      expect(result, isFalse);
    });

    test('buyProduct returns false for subscription ID not loaded', () async {
      final result = await _ps.buyProduct(PurchaseService.kGlooPlusMonthly);
      expect(result, isFalse);
    });

    // ── onPurchaseUpdate callback ───────────────────────────────────────────
    test('onPurchaseUpdate can be set and cleared', () {
      _ps.onPurchaseUpdate = (ids) {};
      expect(_ps.onPurchaseUpdate, isNotNull);

      _ps.onPurchaseUpdate = null;
      expect(_ps.onPurchaseUpdate, isNull);
    });

    test('onPurchaseUpdate is not called when null', () {
      _ps.onPurchaseUpdate = null;
      expect(
        () => _ps.unlockProducts([PurchaseService.kSoundCrystal]),
        returnsNormally,
      );
    });

    // ── dispose ─────────────────────────────────────────────────────────────
    test('dispose does not throw', () {
      expect(() => _ps.dispose(), returnsNormally);
    });

    // ── Starter Pack bundle completeness ────────────────────────────────────
    test('starter pack includes 4 sub-products plus itself', () {
      _ps.unlockProducts([PurchaseService.kStarterPack]);
      final afterIds = _ps.purchasedIds;

      expect(afterIds, contains(PurchaseService.kStarterPack));
      expect(afterIds, contains(PurchaseService.kRemoveAds));
      expect(afterIds, contains(PurchaseService.kSoundCrystal));
      expect(afterIds, contains(PurchaseService.kSoundForest));
      expect(afterIds, contains(PurchaseService.kTexturePack));
    });

    // ── Idempotent unlock ───────────────────────────────────────────────────
    test('unlockProducts is idempotent for same product', () {
      _ps.unlockProducts([PurchaseService.kSoundCrystal]);
      final count1 = _ps.purchasedIds.length;
      _ps.unlockProducts([PurchaseService.kSoundCrystal]);
      final count2 = _ps.purchasedIds.length;
      expect(count2, count1);
    });
  });
}
