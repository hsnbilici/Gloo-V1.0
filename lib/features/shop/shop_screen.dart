import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../shared/section_header.dart';
import '../../data/remote/dto/redeem_result.dart';
import '../../providers/audio_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/user_provider.dart';
import '../../services/purchase_service.dart';
import 'shop_redeem.dart';
import 'shop_widgets.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final _redeemController = TextEditingController();
  bool _purchasing = false;
  bool _redeeming = false;
  String? _toastMsg;
  Timer? _toastTimer;

  @override
  void initState() {
    super.initState();
    final purchase = ref.read(purchaseServiceProvider);
    purchase.onPurchaseUpdate = (_) {
      if (!mounted) return;
      final notifier = ref.read(appSettingsProvider.notifier);
      notifier.setGlooPlus(enabled: purchase.isGlooPlus);
      notifier.setAdsRemoved(removed: purchase.adsRemoved);
      ref.read(adManagerProvider).setAdsRemoved(purchase.adsRemoved);
      setState(() {});
    };
    _loadRedeemState();
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _redeemController.dispose();
    super.dispose();
  }

  Future<void> _loadRedeemState() async {
    final repo = await ref.read(localRepositoryProvider.future);
    final unlocked = await repo.getUnlockedProducts();
    if (unlocked.isNotEmpty) {
      ref.read(purchaseServiceProvider).unlockProducts(unlocked);
    }
  }

  Future<void> _redeemCode(String code) async {
    if (_redeeming || code.trim().isEmpty) return;
    setState(() => _redeeming = true);
    final l = ref.read(stringsProvider);

    try {
      final repo = await ref.read(localRepositoryProvider.future);

      final redeemed = await repo.getRedeemedCodes();
      if (redeemed.contains(code.toUpperCase())) {
        _showToast(l.redeemCodeAlreadyUsed);
        if (mounted) setState(() => _redeeming = false);
        return;
      }

      final result = await ref.read(remoteRepositoryProvider).redeemCode(code);
      switch (result) {
        case RedeemSuccess(:final productIds):
          if (productIds.isEmpty) {
            _showToast(l.redeemCodeInvalid);
            if (mounted) setState(() => _redeeming = false);
            return;
          }
          ref.read(purchaseServiceProvider).unlockProducts(productIds);
          await repo.addRedeemedCode(code.toUpperCase());
          await repo.addUnlockedProducts(productIds);
          _redeemController.clear();
          _showToast(l.redeemCodeSuccess);
        case RedeemAlreadyRedeemed():
          _showToast(l.redeemCodeAlreadyUsed);
        case RedeemError():
          _showToast(l.redeemCodeInvalid);
      }
    } catch (_) {
      _showToast(l.redeemCodeInvalid);
    }

    if (mounted) setState(() => _redeeming = false);
  }

  Future<void> _buy(String productId) async {
    if (_purchasing) return;
    setState(() => _purchasing = true);
    final l = ref.read(stringsProvider);
    try {
      await ref.read(purchaseServiceProvider).buyProduct(productId);
    } catch (_) {
      _showToast(l.shopPurchaseError);
    }
    if (mounted) setState(() => _purchasing = false);
  }

  void _showToast(String msg) {
    _toastTimer?.cancel();
    setState(() => _toastMsg = msg);
    _toastTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _toastMsg = null);
    });
  }

  List<Widget> _buildProductTiles(dynamic l) {
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
          onBuy: () => _buy(p.id),
          isFeatured: p.isFeatured,
        )
            .animate(delay: Duration(milliseconds: p.delay))
            .fadeIn(duration: 350.ms)
            .slideY(begin: 0.08, end: 0, duration: 350.ms),
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(stringsProvider);
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      backgroundColor: kBgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Semantics(
          label: 'Geri',
          button: true,
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Center(
              child: Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
        ),
        title: Text(
          l.shopTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.textScalerOf(context).scale(18),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: Stack(
        children: [
          const ShopBackground(),
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            children: [
              // ── Gloo+ Abonelik
              SectionHeader(title: l.shopSectionSubscription, color: kGold),
              GlooPlusCard(
                title: l.glooPlusTitle,
                desc: l.glooPlusDesc,
                monthlyLabel: l.glooPlusMonthly,
                yearlyLabel: l.glooPlusYearly,
                badgeLabel: l.glooPlusBadge,
                monthlyPrice: ref.read(purchaseServiceProvider).priceOf(
                    PurchaseService.kGlooPlusMonthly,
                    fallback: '\$1.99'),
                yearlyPrice: ref.read(purchaseServiceProvider).priceOf(
                    PurchaseService.kGlooPlusYearly,
                    fallback: '\$9.99'),
                isSubscribed: settings.glooPlus,
                onMonthly: () => _buy(PurchaseService.kGlooPlusMonthly),
                onYearly: () => _buy(PurchaseService.kGlooPlusYearly),
              )
                  .animate(delay: 60.ms)
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.08, end: 0, duration: 350.ms),

              // ── Reklamsız
              SectionHeader(title: l.shopSectionRemoveAds, color: kCoral),
              ProductTile(
                icon: Icons.block_rounded,
                label: l.shopRemoveAds,
                desc: l.shopRemoveAdsDesc,
                price: ref
                    .read(purchaseServiceProvider)
                    .priceOf(PurchaseService.kRemoveAds, fallback: '\$2.99'),
                color: kCoral,
                purchased: settings.adsRemoved,
                onBuy: () => _buy(PurchaseService.kRemoveAds),
              )
                  .animate(delay: 120.ms)
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.08, end: 0, duration: 350.ms),

              // ── Ses Paketleri + Doku Paketleri + Starter Pack
              SectionHeader(title: l.shopSectionSoundPacks, color: kCyan),
              ..._buildProductTiles(l),

              const SizedBox(height: 20),

              // ── Redeem Code
              SectionHeader(title: l.redeemCodeTitle, color: kCyan),
              RedeemCodeField(
                controller: _redeemController,
                buttonLabel: l.redeemCodeButton,
                hintText: l.redeemCodeHint,
                enabled: !_redeeming,
                onRedeem: () => _redeemCode(_redeemController.text),
              )
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.08, end: 0, duration: 350.ms),

              const SizedBox(height: 20),

              // ── Geri Yükle
              Center(
                child: Semantics(
                  label: l.shopRestorePurchases,
                  button: true,
                  child: GestureDetector(
                    onTap: () =>
                        ref.read(purchaseServiceProvider).restorePurchases(),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: Center(
                        child: Text(
                          l.shopRestorePurchases,
                          style: TextStyle(
                            color: kMuted.withValues(alpha: 0.70),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: kMuted.withValues(alpha: 0.40),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
          if (_toastMsg != null)
            Positioned(
              bottom: 80,
              left: 40,
              right: 40,
              child: ShopToast(message: _toastMsg!),
            ),
        ],
      ),
    );
  }
}
