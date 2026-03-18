import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/layout/responsive.dart';
import '../../core/layout/rtl_helpers.dart';
import '../shared/section_header.dart';
import '../../data/remote/dto/redeem_result.dart';
import '../../providers/audio_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/user_provider.dart';
import '../../services/purchase_service.dart';
import 'shop_redeem.dart';
import 'shop_widgets.dart';

part 'shop_logic.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen>
    with _ShopLogicMixin {
  @override
  final redeemController = TextEditingController();
  @override
  bool purchasing = false;
  @override
  bool redeeming = false;
  @override
  String? toastMsg;
  @override
  Timer? toastTimer;

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
    loadRedeemState();
  }

  @override
  void dispose() {
    toastTimer?.cancel();
    redeemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(stringsProvider);
    final settings = ref.watch(appSettingsProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hPadding = responsiveHPadding(screenWidth);
    final dir = Directionality.of(context);

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
                margin: const EdgeInsetsDirectional.only(start: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Icon(directionalBackIcon(dir),
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
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: responsiveMaxWidth(screenWidth)),
          child: Stack(
            children: [
              const ShopBackground(),
              ListView(
                padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 8),
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
                onMonthly: () => buy(PurchaseService.kGlooPlusMonthly),
                onYearly: () => buy(PurchaseService.kGlooPlusYearly),
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
                onBuy: () => buy(PurchaseService.kRemoveAds),
              )
                  .animate(delay: 120.ms)
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.08, end: 0, duration: 350.ms),

              // ── Ses Paketleri + Doku Paketleri + Starter Pack
              SectionHeader(title: l.shopSectionSoundPacks, color: kCyan),
              ...buildProductTiles(l),

              const SizedBox(height: 20),

              // ── Redeem Code
              SectionHeader(title: l.redeemCodeTitle, color: kCyan),
              RedeemCodeField(
                controller: redeemController,
                buttonLabel: l.redeemCodeButton,
                hintText: l.redeemCodeHint,
                enabled: !redeeming,
                onRedeem: () => redeemCode(redeemController.text),
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
          if (toastMsg != null)
            Positioned(
              bottom: 80,
              left: 40,
              right: 40,
              child: ShopToast(message: toastMsg!),
            ),
        ],
      ),
        ),
      ),
    );
  }
}
