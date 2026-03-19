import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../data/local/local_repository.dart';
import '../data/remote/remote_repository.dart';

/// Uygulama içi satın alma (IAP) ve Gloo+ abonelik yöneticisi.
///
/// Ürün tanımları GDD 3.2'ye uygundur:
/// - Reklamsız deneyim: $2.99 tek seferlik
/// - Ses paketi "Crystal ASMR": $1.99
/// - Ses paketi "Deep Forest": $1.99
/// - Jel Doku Paketi: $2.99
/// - Starter Pack: $4.99
/// - Gloo+ Aylık: $1.99/ay
/// - Gloo+ Yıllık: $9.99/yıl
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
  static const kGlooPlusYearly = 'gloo_plus_yearly';

  static const _kConsumableIds = <String>{};
  static const _kNonConsumableIds = <String>{
    kRemoveAds,
    kSoundCrystal,
    kSoundForest,
    kTexturePack,
    kStarterPack,
  };
  static const _kSubscriptionIds = <String>{
    kGlooPlusMonthly,
    kGlooPlusYearly,
  };

  static Set<String> get allProductIds => {
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
      _purchasedIds.contains(kGlooPlusYearly);

  /// Reklamlar kaldırılmış mı? (doğrudan IAP veya Gloo+ ile)
  bool get adsRemoved =>
      _purchasedIds.contains(kRemoveAds) ||
      _purchasedIds.contains(kStarterPack) ||
      isGlooPlus;

  // Dışarıdan dinlemek için callback
  void Function(Set<String> purchasedIds)? onPurchaseUpdate;

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
        if (kDebugMode)
          debugPrint('PurchaseService: not found: ${response.notFoundIDs}');
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

  /// Yerel depodan yüklenen ürünleri mevcut durum ile senkronize eder.
  /// Süresi dolmuş abonelikler (restore edilmemiş) yerel depodan kaldırılır.
  Future<void> syncLocalProducts(LocalRepository localRepo) async {
    final saved = await localRepo.getUnlockedProducts();
    if (saved.isEmpty) return;
    // Kayıtlı ama artık aktif olmayan abonelikleri kaldır
    final expired = saved
        .where(
          (id) => _kSubscriptionIds.contains(id) && !_purchasedIds.contains(id),
        )
        .toList();
    if (expired.isNotEmpty) {
      final updated = saved.where((id) => !expired.contains(id)).toList();
      await localRepo.addUnlockedProducts(updated);
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
      _pendingVerification.remove(purchase.productID);
      await _persistPending();
      if (kDebugMode) {
        debugPrint('PurchaseService: server verified ${purchase.productID}');
      }
    } else if (result == null) {
      // Network hatasi — graceful degradation: yerel olarak ekle, flag'le
      _addProduct(purchase.productID);
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

  /// Urunu ve alt urunlerini _purchasedIds'e ekler.
  void _addProduct(String productId) {
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
  /// Mağaza fiyatını döner veya varsayılan gösterir.
  String priceOf(String productId, {String fallback = '—'}) {
    return _products[productId]?.price ?? fallback;
  }
}
