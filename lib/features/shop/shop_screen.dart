import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../shared/glow_orb.dart';
import '../shared/section_header.dart';
import '../../data/remote/dto/redeem_result.dart';
import '../../providers/audio_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/user_provider.dart';
import '../../services/purchase_service.dart';

// Aksan renkleri
const _kGold = Color(0xFFFFD700);
const _kViolet = Color(0xFF9D5CFF);
const _kCoral = Color(0xFFFF6B6B);

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
      // Gloo+ veya ads removed durumunu provider'a yansıt
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
    final unlocked = repo.getUnlockedProducts();
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

      // Lokal kontrol: daha once kullanilmis mi
      final redeemed = repo.getRedeemedCodes();
      if (redeemed.contains(code.toUpperCase())) {
        _showToast(l.redeemCodeAlreadyUsed);
        if (mounted) setState(() => _redeeming = false);
        return;
      }

      // Supabase dogrulama
      final result = await ref.read(remoteRepositoryProvider).redeemCode(code);
      switch (result) {
        case RedeemSuccess(:final productIds):
          if (productIds.isEmpty) {
            _showToast(l.redeemCodeInvalid);
            if (mounted) setState(() => _redeeming = false);
            return;
          }
          // Basarili: urunleri ac
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Arkaplan
          const _ShopBackground(),
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            children: [
              // ── Gloo+ Abonelik ────────────────────────────────────────
              SectionHeader(title: l.shopSectionSubscription, color: _kGold),
              _GlooPlusCard(
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

              // ── Reklamsız ─────────────────────────────────────────────
              SectionHeader(title: l.shopSectionRemoveAds, color: _kCoral),
              _ProductTile(
                icon: Icons.block_rounded,
                label: l.shopRemoveAds,
                desc: l.shopRemoveAdsDesc,
                price: ref
                    .read(purchaseServiceProvider)
                    .priceOf(PurchaseService.kRemoveAds, fallback: '\$2.99'),
                color: _kCoral,
                purchased: settings.adsRemoved,
                onBuy: () => _buy(PurchaseService.kRemoveAds),
              )
                  .animate(delay: 120.ms)
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.08, end: 0, duration: 350.ms),

              // ── Ses Paketleri ─────────────────────────────────────────
              SectionHeader(title: l.shopSectionSoundPacks, color: kCyan),
              _ProductTile(
                icon: Icons.graphic_eq_rounded,
                label: l.shopSoundCrystal,
                desc: l.shopSoundCrystalDesc,
                price: ref
                    .read(purchaseServiceProvider)
                    .priceOf(PurchaseService.kSoundCrystal, fallback: '\$1.99'),
                color: kCyan,
                purchased: ref
                    .read(purchaseServiceProvider)
                    .isPurchased(PurchaseService.kSoundCrystal),
                onBuy: () => _buy(PurchaseService.kSoundCrystal),
              )
                  .animate(delay: 180.ms)
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.08, end: 0, duration: 350.ms),
              _ProductTile(
                icon: Icons.forest_rounded,
                label: l.shopSoundForest,
                desc: l.shopSoundForestDesc,
                price: ref
                    .read(purchaseServiceProvider)
                    .priceOf(PurchaseService.kSoundForest, fallback: '\$1.99'),
                color: kCyan,
                purchased: ref
                    .read(purchaseServiceProvider)
                    .isPurchased(PurchaseService.kSoundForest),
                onBuy: () => _buy(PurchaseService.kSoundForest),
              )
                  .animate(delay: 220.ms)
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.08, end: 0, duration: 350.ms),

              // ── Doku Paketleri ────────────────────────────────────────
              SectionHeader(title: l.shopSectionTexturePacks, color: _kViolet),
              _ProductTile(
                icon: Icons.texture_rounded,
                label: l.shopTexturePack,
                desc: l.shopTexturePackDesc,
                price: ref
                    .read(purchaseServiceProvider)
                    .priceOf(PurchaseService.kTexturePack, fallback: '\$2.99'),
                color: _kViolet,
                purchased: ref
                    .read(purchaseServiceProvider)
                    .isPurchased(PurchaseService.kTexturePack),
                onBuy: () => _buy(PurchaseService.kTexturePack),
              )
                  .animate(delay: 280.ms)
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.08, end: 0, duration: 350.ms),

              // ── Starter Pack ──────────────────────────────────────────
              _ProductTile(
                icon: Icons.star_rounded,
                label: l.shopStarterPack,
                desc: l.shopStarterPackDesc,
                price: ref
                    .read(purchaseServiceProvider)
                    .priceOf(PurchaseService.kStarterPack, fallback: '\$4.99'),
                color: _kGold,
                purchased: ref
                    .read(purchaseServiceProvider)
                    .isPurchased(PurchaseService.kStarterPack),
                onBuy: () => _buy(PurchaseService.kStarterPack),
                isFeatured: true,
              )
                  .animate(delay: 340.ms)
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.08, end: 0, duration: 350.ms),

              const SizedBox(height: 20),

              // ── Redeem Code ─────────────────────────────────────────
              SectionHeader(title: l.redeemCodeTitle, color: kCyan),
              _RedeemCodeField(
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

              // ── Geri Yükle ────────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () =>
                      ref.read(purchaseServiceProvider).restorePurchases(),
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
              const SizedBox(height: 40),
            ],
          ),
          // Toast
          if (_toastMsg != null)
            Positioned(
              bottom: 80,
              left: 40,
              right: 40,
              child: _Toast(message: _toastMsg!),
            ),
        ],
      ),
    );
  }
}

// ─── Arkaplan ─────────────────────────────────────────────────────────────────

class _ShopBackground extends StatelessWidget {
  const _ShopBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: kBgDark),
        const Positioned(
          top: -80,
          left: -60,
          child: GlowOrb(size: 300, color: _kGold, opacity: 0.06),
        ),
        const Positioned(
          bottom: -100,
          right: -50,
          child: GlowOrb(size: 260, color: _kViolet, opacity: 0.07),
        ),
      ],
    );
  }
}

// ─── Ürün kartı ───────────────────────────────────────────────────────────────

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.icon,
    required this.label,
    required this.desc,
    required this.price,
    required this.color,
    required this.purchased,
    required this.onBuy,
    this.isFeatured = false,
  });

  final IconData icon;
  final String label;
  final String desc;
  final String price;
  final Color color;
  final bool purchased;
  final VoidCallback onBuy;
  final bool isFeatured;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            color.withValues(alpha: isFeatured ? 0.14 : 0.08),
            color.withValues(alpha: 0.02),
            Colors.transparent,
          ],
          stops: const [0.0, 0.35, 1.0],
        ),
        borderRadius: BorderRadius.circular(UIConstants.radiusTile),
        border: Border.all(
          color: color.withValues(alpha: isFeatured ? 0.45 : 0.22),
          width: isFeatured ? 1.5 : 1,
        ),
        boxShadow: isFeatured
            ? [
                BoxShadow(
                    color: color.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4))
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(UIConstants.radiusMd),
              border: Border.all(color: color.withValues(alpha: 0.30)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    shadows: isFeatured
                        ? [
                            Shadow(
                                color: color.withValues(alpha: 0.35),
                                blurRadius: 8)
                          ]
                        : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          purchased
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                    border: Border.all(color: color.withValues(alpha: 0.35)),
                  ),
                  child: Icon(Icons.check_rounded, color: color, size: 16),
                )
              : GestureDetector(
                  onTap: onBuy,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                      border: Border.all(color: color.withValues(alpha: 0.50)),
                    ),
                    child: Text(
                      price,
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

// ─── Gloo+ abonelik kartı ────────────────────────────────────────────────────

class _GlooPlusCard extends StatelessWidget {
  const _GlooPlusCard({
    required this.title,
    required this.desc,
    required this.monthlyLabel,
    required this.yearlyLabel,
    required this.badgeLabel,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.isSubscribed,
    required this.onMonthly,
    required this.onYearly,
  });

  final String title;
  final String desc;
  final String monthlyLabel;
  final String yearlyLabel;
  final String badgeLabel;
  final String monthlyPrice;
  final String yearlyPrice;
  final bool isSubscribed;
  final VoidCallback onMonthly;
  final VoidCallback onYearly;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _kGold.withValues(alpha: 0.12),
            _kViolet.withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(UIConstants.radiusLg),
        border: Border.all(color: _kGold.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: _kGold.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _kGold.withValues(alpha: 0.20),
                      _kViolet.withValues(alpha: 0.15)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                  border: Border.all(color: _kGold.withValues(alpha: 0.45)),
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    color: _kGold, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: _kGold,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                              color: _kGold.withValues(alpha: 0.50),
                              blurRadius: 12)
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.50),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isSubscribed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _kGold.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                border: Border.all(color: _kGold.withValues(alpha: 0.40)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: _kGold, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: _kGold,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                            color: _kGold.withValues(alpha: 0.40),
                            blurRadius: 8)
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                // Aylık
                Expanded(
                  child: GestureDetector(
                    onTap: onMonthly,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius:
                            BorderRadius.circular(UIConstants.radiusMd),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            monthlyLabel,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.60),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            monthlyPrice,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Yıllık (vurgulu)
                Expanded(
                  child: GestureDetector(
                    onTap: onYearly,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _kGold.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(UIConstants.radiusMd),
                        border: Border.all(
                            color: _kGold.withValues(alpha: 0.50), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: _kGold.withValues(alpha: 0.14),
                              blurRadius: 10),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _kGold.withValues(alpha: 0.20),
                              borderRadius:
                                  BorderRadius.circular(UIConstants.radiusXs),
                            ),
                            child: Text(
                              badgeLabel,
                              style: const TextStyle(
                                color: _kGold,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            yearlyLabel,
                            style: TextStyle(
                              color: _kGold.withValues(alpha: 0.80),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            yearlyPrice,
                            style: const TextStyle(
                              color: _kGold,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Redeem Code Alanı ───────────────────────────────────────────────────────

class _RedeemCodeField extends StatelessWidget {
  const _RedeemCodeField({
    required this.controller,
    required this.buttonLabel,
    required this.hintText,
    required this.enabled,
    required this.onRedeem,
  });

  final TextEditingController controller;
  final String buttonLabel;
  final String hintText;
  final bool enabled;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: kCyan.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(UIConstants.radiusTile),
        border: Border.all(color: kCyan.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              textCapitalization: TextCapitalization.characters,
              maxLength: 20,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25),
                  fontSize: 13,
                  fontFamily: 'monospace',
                  letterSpacing: 1,
                ),
                counterText: '',
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: enabled ? onRedeem : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: enabled
                    ? kCyan.withValues(alpha: 0.15)
                    : kCyan.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                border: Border.all(
                  color: enabled
                      ? kCyan.withValues(alpha: 0.50)
                      : kCyan.withValues(alpha: 0.15),
                ),
              ),
              child: Text(
                buttonLabel,
                style: TextStyle(
                  color: enabled ? kCyan : kCyan.withValues(alpha: 0.35),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Toast ────────────────────────────────────────────────────────────────────

class _Toast extends StatelessWidget {
  const _Toast({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: kBgDark,
        borderRadius: BorderRadius.circular(UIConstants.radiusMd),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.50), blurRadius: 20),
        ],
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(begin: 0.3, end: 0, duration: 200.ms);
  }
}
