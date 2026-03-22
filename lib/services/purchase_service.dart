import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../data/local/local_repository.dart';
import '../data/remote/remote_repository.dart';

/// Uygulama içi satın alma (IAP) ve Gloo+ abonelik yöneticisi.
///
/// Ürün tanımları GDD 3.2'ye uygundur:
///
/// **Starter Pack** (tek seferlik, $4.99):
///   Içerik: reklamsız + 2 ses paketi + 1 doku paketi.
///   Kanibalizasyon notu: Starter Pack yalnizca cosmetic ve reklam
///   avantajlari saglar. Gloo+'a ozel ozellikler (Zen modu, 2x Season
///   Pass XP, %50 Jel Ozu bonusu, erken erisim) dahil degildir.
///
/// **Gloo+** (abonelik, $1.99/ay veya $9.99/yil):
///   Ozel: Zen modu, 2x Season Pass XP, %50 Jel Ozu bonusu, erken
///   erisim, reklamsiz, tum ses paketleri.
///
/// Diger urunler:
/// - Reklamsız deneyim: $2.99 tek seferlik
/// - Ses paketi "Crystal ASMR": $1.99
/// - Ses paketi "Deep Forest": $1.99
/// - Jel Doku Paketi: $2.99
class PurchaseService {
  PurchaseService._();
  static final PurchaseService _instance = PurchaseService._();
  factory PurchaseService() => _instance;

  // ── Ürün ID'leri (App Store / Play Store'da tanımlanmalı) ────────────────
  static const kRemoveAds = 'gloo_remove_ads';
  static const kSoundCrystal = 'gloo_sound_crystal';
  static const kSoundForest = 'gloo_sound_forest';
  static const kTexturePack = 'gloo_texture_pack';
  static const kStarterPack = 'gloo_starter_pack';
  static const kGlooPlusMonthly = 'gloo_plus_monthly';
  static const kGlooPlusQuarter = 'gloo_plus_quarter';
  static const kGlooPlusYearly = 'gloo_plus_yearly';
  static const kJelOzu100 = 'gloo_jel_ozu_100';
  static const kJelOzu500 = 'gloo_jel_ozu_500';

  static const _kConsumableIds = <String>{
    kJelOzu100,
    kJelOzu500,
  };
  static const _kNonConsumableIds = <String>{
    kRemoveAds,
    kSoundCrystal,
    kSoundForest,
    kTexturePack,
    kStarterPack,
  };
  static const _kSubscriptionIds = <String>{
    kGlooPlusMonthly,
    kGlooPlusQuarter,
    kGlooPlusYearly,
  };

  static Set<String> get allProductIds => {
        ..._kConsumableIds,
        ..._kNonConsumableIds,
        ..._kSubscriptionIds,
      };

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _available = false;
  final Map<String, ProductDetails> _products = {};
  final Set<String> _purchasedIds = {};
  LocalRepository? _localRepo;

  bool get isAvailable => _available;
  Map<String, ProductDetails> get products => Map.unmodifiable(_products);
  Set<String> get purchasedIds => Set.unmodifiable(_purchasedIds);

  /// Satın alınmış bir ürün mü?
  bool isPurchased(String productId) => _purchasedIds.contains(productId);

  /// Gloo+ abonesi mi? (aylık veya yıllık)
  bool get isGlooPlus =>
      _purchasedIds.contains(kGlooPlusMonthly) ||
      _purchasedIds.contains(kGlooPlusQuarter) ||
      _purchasedIds.contains(kGlooPlusYearly);

  /// Reklamlar kaldırılmış mı? (doğrudan IAP veya Gloo+ ile)
  bool get adsRemoved =>
      _purchasedIds.contains(kRemoveAds) ||
      _purchasedIds.contains(kStarterPack) ||
      isGlooPlus;

  // Dışarıdan dinlemek için callback
  void Function(Set<String> purchasedIds)? onPurchaseUpdate;

  /// Consumable satın alma sonrası Jel Özü kredileme callback'i.
  void Function(int amount)? onConsumableFulfilled;

  /// Consumable ürünün Jel Özü miktarını döner.
  static int? jelOzuAmount(String productId) => switch (productId) {
        kJelOzu100 => 100,
        kJelOzu500 => 500,
        _ => null,
      };

  // ── Yaşam döngüsü ──────────────────────────────────────────────────────
  Future<void> initialize() async {
    try {
      _available = await _iap.isAvailable();
      if (!_available) {
        if (kDebugMode) debugPrint('PurchaseService: IAP not available');
        return;
      }

      // Satın alma akışını dinle
      _subscription = _iap.purchaseStream.listen(
        _handlePurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (error) {
          if (kDebugMode) debugPrint('PurchaseService: stream error $error');
        },
      );

      // Ürünleri yükle
      final response = await _iap.queryProductDetails(allProductIds);
      if (response.notFoundIDs.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('PurchaseService: not found: ${response.notFoundIDs}');
        }
      }
      for (final product in response.productDetails) {
        _products[product.id] = product;
      }

      if (kDebugMode)
        debugPrint('PurchaseService: ${_products.length} ürün yüklendi');

      // Önceki satın alımları ve aktif abonelikleri geri yükle.
      // Süresi dolmuş abonelikler restore edilmez → _purchasedIds'e eklenmez.
      await _iap.restorePurchases();
    } catch (e) {
      if (kDebugMode) debugPrint('PurchaseService: initialize error: $e');
    }
  }

  void dispose() {
    _subscription?.cancel();
  }

  // ── Satın alma ─────────────────────────────────────────────────────────
  Future<bool> buyProduct(String productId) async {
    final product = _products[productId];
    if (product == null) return false;

    final purchaseParam = PurchaseParam(productDetails: product);

    if (_kSubscriptionIds.contains(productId)) {
      return _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } else if (_kConsumableIds.contains(productId)) {
      return _iap.buyConsumable(purchaseParam: purchaseParam);
    } else {
      return _iap.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  /// Önceki satın alımları geri yükle (iOS App Store gerekliliği).
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  // Sunucu dogrulamasi beklemeden eklenen urunler (network hatasi durumunda).
  // SecureStorage'a persist edilir, sonraki baslatmada tekrar dogrulanir.
  // Key: productId, Value: receipt
  final Map<String, String> _pendingVerification = {};

  /// Network hatasi nedeniyle dogrulanamamis urunler.
  Set<String> get pendingVerification =>
      Set.unmodifiable(_pendingVerification.keys);

  /// Önceki oturumdan kalan doğrulanamamış ürünleri yükler ve yeniden doğrular.
  Future<void> loadPendingVerifications(LocalRepository localRepo) async {
    _localRepo = localRepo;
    final pending = await localRepo.getPendingVerificationMap();
    if (pending.isEmpty) return;
    _pendingVerification.addAll(pending);
    if (kDebugMode) {
      debugPrint(
          'PurchaseService: retrying ${pending.length} pending verifications');
    }
    final repo = RemoteRepository();
    final initialCount = pending.length;
    for (final entry in pending.entries.toList()) {
      final result = await repo.verifyPurchase(
        platform:
            defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        receipt: entry.value,
        productId: entry.key,
      );
      if (result == true) {
        _pendingVerification.remove(entry.key);
        if (kDebugMode) {
          debugPrint('PurchaseService: retry verified ${entry.key}');
        }
      } else if (result == false) {
        // Sunucu reddetti — pending'den cikar, urunu kaldir
        _pendingVerification.remove(entry.key);
        _purchasedIds.remove(entry.key);
        if (kDebugMode) {
          debugPrint('PurchaseService: retry rejected ${entry.key}');
        }
      }
      // result == null (network hatasi) → pending'de birak
    }
    await _persistPending();
    if (_pendingVerification.length != initialCount) {
      onPurchaseUpdate?.call(_purchasedIds);
    }
  }

  Future<void> _persistPending() async {
    await _localRepo?.savePendingVerificationMap(_pendingVerification);
  }

  /// Monthly subscription + 5-day grace period (35 days total).
  static const _kSubscriptionGraceDays = 35;

  /// Yerel depodan yüklenen ürünleri mevcut durum ile senkronize eder.
  /// Süresi dolmuş abonelikler (restore edilmemiş veya timestamp aşılmış)
  /// yerel depodan kaldırılır.
  Future<void> syncLocalProducts(LocalRepository localRepo) async {
    final saved = await localRepo.getUnlockedProducts();
    if (saved.isEmpty) return;

    final expired = <String>[];
    for (final id in saved) {
      if (!_kSubscriptionIds.contains(id)) continue;

      // Store tarafından restore edilmişse aktif kabul et
      if (_purchasedIds.contains(id)) continue;

      // Timestamp kontrolü: kayıt yoksa veya süre aşılmışsa expired
      final ts = await localRepo.getSubscriptionTimestamp(id);
      if (ts != null) {
        final purchaseDate = DateTime.fromMillisecondsSinceEpoch(ts);
        final daysSince = DateTime.now().difference(purchaseDate).inDays;
        if (daysSince <= _kSubscriptionGraceDays) continue;
      }

      expired.add(id);
    }

    if (expired.isNotEmpty) {
      final updated = saved.where((id) => !expired.contains(id)).toList();
      await localRepo.addUnlockedProducts(updated);
      for (final id in expired) {
        await localRepo.removeSubscriptionTimestamp(id);
      }
      if (kDebugMode) {
        debugPrint('PurchaseService: expired subscriptions removed: $expired');
      }
      onPurchaseUpdate?.call(_purchasedIds);
    }
  }

  // ── Satın alma stream handler ─────────────────────────────────────────
  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _verifyAndUnlock(purchase);
          break;
        case PurchaseStatus.error:
          if (kDebugMode) {
            debugPrint(
              'PurchaseService: error ${purchase.productID}: ${purchase.error}',
            );
          }
          break;
        case PurchaseStatus.pending:
        case PurchaseStatus.canceled:
          break;
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  /// Receipt'i sunucu tarafinda dogrular, basariliysa urunu acar.
  /// Network hatasinda graceful degradation: yerel olarak ekler, flag'ler.
  Future<void> _verifyAndUnlock(PurchaseDetails purchase) async {
    final repo = RemoteRepository();
    final platform =
        defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
    final receipt = purchase.verificationData.serverVerificationData;

    final result = await repo.verifyPurchase(
      platform: platform,
      receipt: receipt,
      productId: purchase.productID,
    );

    if (result == true) {
      // Sunucu dogruladi
      _addProduct(purchase.productID);
      await _saveSubscriptionTimestampIfNeeded(purchase.productID);
      _pendingVerification.remove(purchase.productID);
      await _persistPending();
      if (kDebugMode) {
        debugPrint('PurchaseService: server verified ${purchase.productID}');
      }
    } else if (result == null) {
      // Network hatasi — graceful degradation: yerel olarak ekle, flag'le
      _addProduct(purchase.productID);
      await _saveSubscriptionTimestampIfNeeded(purchase.productID);
      _pendingVerification[purchase.productID] = receipt;
      await _persistPending();
      if (kDebugMode) {
        debugPrint(
          'PurchaseService: network error, locally added ${purchase.productID}',
        );
      }
    } else {
      // Dogrulama basarisiz — urunu ekleme
      if (kDebugMode) {
        debugPrint(
          'PurchaseService: verification failed for ${purchase.productID}',
        );
      }
    }
  }

  /// Abonelik ürünü ise satın alma zamanını kaydeder.
  Future<void> _saveSubscriptionTimestampIfNeeded(String productId) async {
    if (_kSubscriptionIds.contains(productId) && _localRepo != null) {
      await _localRepo!.saveSubscriptionTimestamp(
        productId,
        DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  /// Urunu ve alt urunlerini _purchasedIds'e ekler.
  /// Consumable ürünler _purchasedIds'e eklenmez, callback ile kredilenir.
  void _addProduct(String productId) {
    final jelAmount = jelOzuAmount(productId);
    if (jelAmount != null) {
      onConsumableFulfilled?.call(jelAmount);
      return;
    }
    _purchasedIds.add(productId);
    if (productId == kStarterPack) {
      _purchasedIds
        ..add(kRemoveAds)
        ..add(kSoundCrystal)
        ..add(kSoundForest)
        ..add(kTexturePack);
    }
    onPurchaseUpdate?.call(_purchasedIds);
  }

  // ── Redeem ile ürün açma ───────────────────────────────────────────────
  /// Redeem sonucu urun ID'lerini _purchasedIds'e ekler.
  void unlockProducts(List<String> productIds) {
    for (final id in productIds) {
      _purchasedIds.add(id);
      if (id == kStarterPack) {
        _purchasedIds
          ..add(kRemoveAds)
          ..add(kSoundCrystal)
          ..add(kSoundForest)
          ..add(kTexturePack);
      }
    }
    onPurchaseUpdate?.call(_purchasedIds);
  }

  // ── Fiyat yardımcıları ─────────────────────────────────────────────────

  /// USD bazında varsayılan fiyatlar (store'dan yüklenemezse locale'e çevrilir).
  static const _kBasePricesUsd = <String, double>{
    kRemoveAds: 2.99,
    kSoundCrystal: 1.99,
    kSoundForest: 1.99,
    kTexturePack: 2.99,
    kStarterPack: 4.99,
    kGlooPlusMonthly: 1.99,
    kGlooPlusQuarter: 4.99,
    kGlooPlusYearly: 9.99,
    kJelOzu100: 0.99,
    kJelOzu500: 3.99,
  };

  /// Yaklaşık USD→yerel para birimi çarpanları.
  /// Store bağlantısı yokken kullanıcıya kendi para biriminde gösterim sağlar.
  static const _kCurrencyRates = <String, (String symbol, double rate)>{
    'TRY': ('₺', 38.0),
    'EUR': ('€', 0.92),
    'GBP': ('£', 0.79),
    'JPY': ('¥', 155.0),
    'KRW': ('₩', 1350.0),
    'CNY': ('¥', 7.25),
    'INR': ('₹', 83.5),
    'BRL': ('R\$', 5.0),
    'RUB': ('₽', 92.0),
    'SAR': ('﷼', 3.75),
    'AED': ('د.إ', 3.67),
  };

  /// Cihaz locale'inden para birimi kodunu tahmin eder.
  static String _localeCurrencyCode() {
    final locale = PlatformDispatcher.instance.locale;
    // Bölge koduna göre para birimi eşleme
    return switch (locale.countryCode?.toUpperCase()) {
      'TR' => 'TRY',
      'DE' || 'FR' || 'ES' || 'IT' || 'NL' || 'PT' || 'AT' || 'BE' ||
      'FI' || 'GR' || 'IE' => 'EUR',
      'GB' => 'GBP',
      'JP' => 'JPY',
      'KR' => 'KRW',
      'CN' => 'CNY',
      'IN' => 'INR',
      'BR' => 'BRL',
      'RU' => 'RUB',
      'SA' => 'SAR',
      'AE' => 'AED',
      _ => 'USD',
    };
  }

  /// Baz fiyatı cihaz locale'ine göre formatlar.
  static String _formatLocalPrice(double usdPrice) {
    final code = _localeCurrencyCode();
    if (code == 'USD') return '\$$usdPrice';

    final entry = _kCurrencyRates[code];
    if (entry == null) return '\$$usdPrice';

    final (symbol, rate) = entry;
    final localPrice = (usdPrice * rate);

    // Tam sayıya yuvarla (JPY, KRW gibi düşük değerli birimler için)
    if (rate >= 100) {
      final rounded = ((localPrice / 10).round() * 10);
      return '$symbol$rounded';
    }

    // 2 ondalık basamak
    return '$symbol${localPrice.toStringAsFixed(2)}';
  }

  /// Mağaza fiyatını döner; store'dan yüklenememişse cihaz locale'ine
  /// göre yaklaşık yerel fiyat gösterir.
  String priceOf(String productId, {String? fallback}) {
    final storePrice = _products[productId]?.price;
    if (storePrice != null) return storePrice;

    if (fallback != null) return fallback;

    final basePrice = _kBasePricesUsd[productId];
    if (basePrice != null) return _formatLocalPrice(basePrice);

    return '—';
  }
}
