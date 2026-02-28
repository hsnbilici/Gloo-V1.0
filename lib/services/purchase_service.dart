import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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
    _available = await _iap.isAvailable();
    if (!_available) {
      debugPrint('PurchaseService: IAP not available');
      return;
    }

    // Satın alma akışını dinle
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('PurchaseService: stream error $error'),
    );

    // Ürünleri yükle
    final response = await _iap.queryProductDetails(allProductIds);
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('PurchaseService: not found: ${response.notFoundIDs}');
    }
    for (final product in response.productDetails) {
      _products[product.id] = product;
    }

    debugPrint('PurchaseService: ${_products.length} ürün yüklendi');
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

  // ── Satın alma stream handler ─────────────────────────────────────────
  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _purchasedIds.add(purchase.productID);
          debugPrint('PurchaseService: ✓ ${purchase.productID}');
          // Starter Pack: alt ürünleri de aç
          if (purchase.productID == kStarterPack) {
            _purchasedIds
              ..add(kRemoveAds)
              ..add(kSoundCrystal)
              ..add(kSoundForest)
              ..add(kTexturePack);
          }
          break;
        case PurchaseStatus.error:
          debugPrint(
              'PurchaseService: error ${purchase.productID}: ${purchase.error}');
          break;
        case PurchaseStatus.pending:
        case PurchaseStatus.canceled:
          break;
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
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
