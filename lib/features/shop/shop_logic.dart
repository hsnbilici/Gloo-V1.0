part of 'shop_screen.dart';

/// Shop iş mantığı: satın alma, redeem, toast ve ürün listesi.
mixin _ShopLogicMixin on ConsumerState<ShopScreen> {
  TextEditingController get redeemController;
  bool get purchasing;
  set purchasing(bool value);
  bool get redeeming;
  set redeeming(bool value);
  String? get toastMsg;
  set toastMsg(String? value);
  Timer? get toastTimer;
  set toastTimer(Timer? value);

  Future<void> loadRedeemState() async {
    final repo = await ref.read(localRepositoryProvider.future);
    final unlocked = await repo.getUnlockedProducts();
    if (unlocked.isNotEmpty) {
      ref.read(purchaseServiceProvider).unlockProducts(unlocked);
    }
  }

  /// Yerel test kodlari — Supabase baglantisi olmadan calisir.
  static const _kLocalRedeemCodes = <String, List<String>>{
    'UNLOCKALL': [
      PurchaseService.kGlooPlusYearly,
      PurchaseService.kRemoveAds,
      PurchaseService.kSoundCrystal,
      PurchaseService.kSoundForest,
      PurchaseService.kTexturePack,
      PurchaseService.kStarterPack,
    ],
    'GLOOPREMIUM': [PurchaseService.kGlooPlusYearly],
    'ZENMODE': [PurchaseService.kGlooPlusQuarter],
  };

  Future<void> redeemCode(String code) async {
    if (redeeming || code.trim().isEmpty) return;
    setState(() => redeeming = true);
    final l = ref.read(stringsProvider);

    try {
      final repo = await ref.read(localRepositoryProvider.future);
      final upperCode = code.toUpperCase();

      final redeemed = await repo.getRedeemedCodes();
      if (redeemed.contains(upperCode)) {
        showToast(l.redeemCodeAlreadyUsed);
        if (mounted) setState(() => redeeming = false);
        return;
      }

      // Oncelik: Supabase uzerinden dogrulama
      final remote = ref.read(remoteRepositoryProvider);
      final result = await remote.redeemCode(code);
      switch (result) {
        case RedeemSuccess(:final productIds):
          if (productIds.isEmpty) {
            showToast(l.redeemCodeInvalid);
            if (mounted) setState(() => redeeming = false);
            return;
          }
          ref.read(purchaseServiceProvider).unlockProducts(productIds);
          await repo.addRedeemedCode(upperCode);
          await repo.addUnlockedProducts(productIds);
          redeemController.clear();
          showToast(l.redeemCodeSuccess);
          if (mounted) setState(() => redeeming = false);
          return;
        case RedeemAlreadyRedeemed():
          showToast(l.redeemCodeAlreadyUsed);
          if (mounted) setState(() => redeeming = false);
          return;
        case RedeemError():
          // Supabase hatasi veya yapilandirilmamis — yerel kodlari dene
          break;
      }

      // Fallback: yerel test kodlari (Supabase offline ise)
      final localProducts = _kLocalRedeemCodes[upperCode];
      if (localProducts != null) {
        ref.read(purchaseServiceProvider).unlockProducts(localProducts);
        await repo.addRedeemedCode(upperCode);
        await repo.addUnlockedProducts(localProducts);
        redeemController.clear();
        showToast(l.redeemCodeSuccess);
      } else {
        showToast(l.redeemCodeInvalid);
      }
    } catch (_) {
      showToast(l.redeemCodeInvalid);
    }

    if (mounted) setState(() => redeeming = false);
  }

  Future<void> buy(String productId) async {
    if (purchasing) return;
    setState(() => purchasing = true);
    final l = ref.read(stringsProvider);
    try {
      final success =
          await ref.read(purchaseServiceProvider).buyProduct(productId);
      if (!success && mounted) {
        showToast(l.shopPurchaseError);
      }
    } catch (_) {
      showToast(l.shopPurchaseError);
    }
    if (mounted) setState(() => purchasing = false);
  }

  void showToast(String msg) {
    toastTimer?.cancel();
    setState(() => toastMsg = msg);
    toastTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => toastMsg = null);
    });
  }

  List<Widget> buildProductTiles(dynamic l) {
    final purchase = ref.read(purchaseServiceProvider);
    final products = [
      (
        id: PurchaseService.kSoundCrystal,
        icon: Icons.graphic_eq_rounded,
        label: l.shopSoundCrystal as String,
        desc: l.shopSoundCrystalDesc as String,
        fallback: '\$1.99',
        color: kCyan,
        delay: 180,
        isFeatured: false,
        section: null as ({String title, Color color})?,
      ),
      (
        id: PurchaseService.kSoundForest,
        icon: Icons.forest_rounded,
        label: l.shopSoundForest as String,
        desc: l.shopSoundForestDesc as String,
        fallback: '\$1.99',
        color: kCyan,
        delay: 220,
        isFeatured: false,
        section: null,
      ),
      (
        id: PurchaseService.kTexturePack,
        icon: Icons.texture_rounded,
        label: l.shopTexturePack as String,
        desc: l.shopTexturePackDesc as String,
        fallback: '\$2.99',
        color: kColorZen,
        delay: 280,
        isFeatured: false,
        section: (title: l.shopSectionTexturePacks as String, color: kColorZen),
      ),
      (
        id: PurchaseService.kStarterPack,
        icon: Icons.star_rounded,
        label: l.shopStarterPack as String,
        desc: l.shopStarterPackDesc as String,
        fallback: '\$4.99',
        color: kGold,
        delay: 340,
        isFeatured: true,
        section: null,
      ),
    ];

    final widgets = <Widget>[];
    for (final p in products) {
      if (p.section != null) {
        widgets.add(
            SectionHeader(title: p.section!.title, color: p.section!.color));
      }
      widgets.add(
        ProductTile(
          icon: p.icon,
          label: p.label,
          desc: p.desc,
          price: purchase.priceOf(p.id, fallback: p.fallback),
          color: p.color,
          purchased: purchase.isPurchased(p.id),
          onBuy: () => buy(p.id),
          isFeatured: p.isFeatured,
        )
            .animateOrSkip(reduceMotion: shouldReduceMotion(context), delay: Duration(milliseconds: p.delay))
            .fadeIn(duration: 350.ms)
            .slideY(begin: 0.08, end: 0, duration: 350.ms),
      );
    }
    return widgets;
  }
}
