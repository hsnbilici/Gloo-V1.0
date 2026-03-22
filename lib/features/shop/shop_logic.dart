part of 'shop_screen.dart';

/// Shop iş mantığı: satın alma, redeem, toast ve ürün listesi.
mixin _ShopLogicMixin on ConsumerState<ShopScreen> {
  SoundBank get _soundBank;
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
    _soundBank.onButtonTap();
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

}
