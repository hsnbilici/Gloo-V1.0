import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../audio/sound_bank.dart';
import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/layout/responsive.dart';
import '../../core/layout/rtl_helpers.dart';
import '../../core/utils/motion_utils.dart';
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
    with _ShopLogicMixin, SingleTickerProviderStateMixin {
  @override
  final _soundBank = SoundBank();

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

  late final TabController _tabController;

  static const _kTabCount = 4;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _kTabCount, vsync: this);
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
    _tabController.dispose();
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
    final brightness = Theme.of(context).brightness;
    final bgColor = resolveColor(brightness, dark: kBgDark, light: kBgLight);
    final textColor =
        resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    final surfaceColor = resolveColor(brightness,
        dark: Colors.white.withValues(alpha: 0.06), light: kCardBgLight);
    final borderColor = resolveColor(brightness,
        dark: Colors.white.withValues(alpha: 0.1), light: kCardBorderLight);
    final rm = shouldReduceMotion(context);

    return ResponsiveScaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _BackButton(
          label: l.backLabel,
          icon: directionalBackIcon(dir),
          iconColor: textColor,
          surfaceColor: surfaceColor,
          borderColor: borderColor,
          onTap: () => context.pop(),
        ),
        title: Text(
          l.shopTitle,
          style: TextStyle(
            color: textColor,
            fontSize: MediaQuery.textScalerOf(context).scale(18),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        bottom: _ShopTabBar(
          controller: _tabController,
          labels: ['Gloo+', l.shopTabCurrency, 'Premium', l.shopTabPromo],
          icons: const [
            Icons.star_rounded,
            Icons.water_drop_rounded,
            Icons.workspace_premium_rounded,
            Icons.confirmation_number_rounded,
          ],
          colors: const [kGold, kCyan, kColorZen, kGreen],
        ),
      ),
      body: Stack(
        children: [
          const ShopBackground(),
          Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // ── Tab 0: Gloo+ Abonelik
                    _buildSubscriptionTab(l, settings, hPadding, rm),
                    // ── Tab 1: Jel Özü
                    _buildCurrencyTab(l, hPadding, rm),
                    // ── Tab 2: Premium
                    _buildPremiumTab(l, settings, hPadding, rm),
                    // ── Tab 3: Promosyon Kodu
                    _buildPromoTab(l, hPadding, rm),
                  ],
                ),
              ),
              _buildRestoreButton(l),
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
    );
  }

  Widget _buildSubscriptionTab(
      dynamic l, dynamic settings, double hPadding, bool rm) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 8),
      children: [
        SectionHeader(title: l.shopSectionSubscription as String, color: kGold),
        GlooPlusCard(
          title: l.glooPlusTitle,
          desc: l.glooPlusDesc,
          monthlyLabel: l.glooPlusMonthly,
          quarterLabel: l.glooPlusQuarter,
          yearlyLabel: l.glooPlusYearly,
          badgeLabel: l.glooPlusBadge,
          monthlyPrice: ref.read(purchaseServiceProvider).priceOf(
              PurchaseService.kGlooPlusMonthly,
              fallback: '\$1.99'),
          quarterPrice: ref.read(purchaseServiceProvider).priceOf(
              PurchaseService.kGlooPlusQuarter,
              fallback: '\$4.99'),
          yearlyPrice: ref.read(purchaseServiceProvider).priceOf(
              PurchaseService.kGlooPlusYearly,
              fallback: '\$9.99'),
          isSubscribed: settings.glooPlus,
          onMonthly: () => buy(PurchaseService.kGlooPlusMonthly),
          onQuarter: () => buy(PurchaseService.kGlooPlusQuarter),
          onYearly: () => buy(PurchaseService.kGlooPlusYearly),
        )
            .animateOrSkip(reduceMotion: rm, delay: 60.ms)
            .fadeIn(duration: 350.ms)
            .slideY(begin: 0.08, end: 0, duration: 350.ms),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildCurrencyTab(dynamic l, double hPadding, bool rm) {
    final purchase = ref.read(purchaseServiceProvider);
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 8),
      children: [
        SectionHeader(
            title: l.shopSectionCurrency as String, color: kCyan),
        ProductTile(
          icon: Icons.water_drop_rounded,
          label: l.shopJelOzu100 as String,
          desc: '100 Jel Ozu',
          price: purchase.priceOf(PurchaseService.kJelOzu100,
              fallback: '\$0.99'),
          color: kCyan,
          purchased: purchase.isPurchased(PurchaseService.kJelOzu100),
          onBuy: () => buy(PurchaseService.kJelOzu100),
        )
            .animateOrSkip(reduceMotion: rm, delay: 60.ms)
            .fadeIn(duration: 350.ms)
            .slideY(begin: 0.08, end: 0, duration: 350.ms),
        ProductTile(
          icon: Icons.water_drop_rounded,
          label: l.shopJelOzu500 as String,
          desc: '500 Jel Ozu',
          price: purchase.priceOf(PurchaseService.kJelOzu500,
              fallback: '\$3.99'),
          color: kCyan,
          purchased: purchase.isPurchased(PurchaseService.kJelOzu500),
          onBuy: () => buy(PurchaseService.kJelOzu500),
          isFeatured: true,
        )
            .animateOrSkip(reduceMotion: rm, delay: 120.ms)
            .fadeIn(duration: 350.ms)
            .slideY(begin: 0.08, end: 0, duration: 350.ms),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildPremiumTab(
      dynamic l, dynamic settings, double hPadding, bool rm) {
    final purchase = ref.read(purchaseServiceProvider);
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 8),
      children: [
        // ── Reklamsız
        SectionHeader(
            title: l.shopSectionRemoveAds as String, color: kCoral),
        ProductTile(
          icon: Icons.block_rounded,
          label: l.shopRemoveAds as String,
          desc: l.shopRemoveAdsDesc as String,
          price: purchase.priceOf(PurchaseService.kRemoveAds,
              fallback: '\$2.99'),
          color: kCoral,
          purchased: settings.adsRemoved,
          onBuy: () => buy(PurchaseService.kRemoveAds),
        )
            .animateOrSkip(reduceMotion: rm, delay: 60.ms)
            .fadeIn(duration: 350.ms)
            .slideY(begin: 0.08, end: 0, duration: 350.ms),
        // ── Ses Paketleri
        SectionHeader(
            title: l.shopSectionSoundPacks as String, color: kCyan),
        ProductTile(
          icon: Icons.graphic_eq_rounded,
          label: l.shopSoundCrystal as String,
          desc: l.shopSoundCrystalDesc as String,
          price: purchase.priceOf(PurchaseService.kSoundCrystal,
              fallback: '\$1.99'),
          color: kCyan,
          purchased: purchase.isPurchased(PurchaseService.kSoundCrystal),
          onBuy: () => buy(PurchaseService.kSoundCrystal),
        )
            .animateOrSkip(reduceMotion: rm, delay: 120.ms)
            .fadeIn(duration: 350.ms)
            .slideY(begin: 0.08, end: 0, duration: 350.ms),
        ProductTile(
          icon: Icons.forest_rounded,
          label: l.shopSoundForest as String,
          desc: l.shopSoundForestDesc as String,
          price: purchase.priceOf(PurchaseService.kSoundForest,
              fallback: '\$1.99'),
          color: kCyan,
          purchased: purchase.isPurchased(PurchaseService.kSoundForest),
          onBuy: () => buy(PurchaseService.kSoundForest),
        )
            .animateOrSkip(reduceMotion: rm, delay: 160.ms)
            .fadeIn(duration: 350.ms)
            .slideY(begin: 0.08, end: 0, duration: 350.ms),
        // ── Doku Paketleri & Starter Pack
        SectionHeader(
            title: l.shopSectionTexturePacks as String,
            color: kColorZen),
        ProductTile(
          icon: Icons.texture_rounded,
          label: l.shopTexturePack as String,
          desc: l.shopTexturePackDesc as String,
          price: purchase.priceOf(PurchaseService.kTexturePack,
              fallback: '\$2.99'),
          color: kColorZen,
          purchased: purchase.isPurchased(PurchaseService.kTexturePack),
          onBuy: () => buy(PurchaseService.kTexturePack),
        )
            .animateOrSkip(reduceMotion: rm, delay: 220.ms)
            .fadeIn(duration: 350.ms)
            .slideY(begin: 0.08, end: 0, duration: 350.ms),
        ProductTile(
          icon: Icons.star_rounded,
          label: l.shopStarterPack as String,
          desc: l.shopStarterPackDesc as String,
          price: purchase.priceOf(PurchaseService.kStarterPack,
              fallback: '\$4.99'),
          color: kGold,
          purchased: purchase.isPurchased(PurchaseService.kStarterPack),
          onBuy: () => buy(PurchaseService.kStarterPack),
          isFeatured: true,
        )
            .animateOrSkip(reduceMotion: rm, delay: 280.ms)
            .fadeIn(duration: 350.ms)
            .slideY(begin: 0.08, end: 0, duration: 350.ms),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildPromoTab(dynamic l, double hPadding, bool rm) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 8),
      children: [
        SectionHeader(
            title: l.redeemCodeTitle as String, color: kGreen),
        RedeemCodeField(
          controller: redeemController,
          buttonLabel: l.redeemCodeButton as String,
          hintText: l.redeemCodeHint as String,
          enabled: !redeeming,
          onRedeem: () => redeemCode(redeemController.text),
        )
            .animateOrSkip(reduceMotion: rm, delay: 60.ms)
            .fadeIn(duration: 350.ms)
            .slideY(begin: 0.08, end: 0, duration: 350.ms),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildRestoreButton(dynamic l) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Center(
        child: Semantics(
          label: l.shopRestorePurchases as String,
          button: true,
          child: GestureDetector(
            onTap: () =>
                ref.read(purchaseServiceProvider).restorePurchases(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Center(
                child: Text(
                  l.shopRestorePurchases as String,
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
    );
  }
}

/// Tab bar widget for the shop screen.
class _ShopTabBar extends StatelessWidget implements PreferredSizeWidget {
  const _ShopTabBar({
    required this.controller,
    required this.labels,
    required this.icons,
    required this.colors,
  });

  final TabController controller;
  final List<String> labels;
  final List<IconData> icons;
  final List<Color> colors;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      labelPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      tabs: List.generate(labels.length, (i) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final selected = controller.index == i;
            final color = selected
                ? colors[i]
                : Colors.white.withValues(alpha: 0.40);
            return Tab(
              height: 48,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icons[i], size: 14, color: color),
                  const SizedBox(width: 5),
                  Text(
                    labels[i],
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
      indicator: _ColoredUnderlineIndicator(colors: colors, controller: controller),
    );
  }
}

/// Per-tab colored underline indicator.
class _ColoredUnderlineIndicator extends Decoration {
  const _ColoredUnderlineIndicator({
    required this.colors,
    required this.controller,
  });

  final List<Color> colors;
  final TabController controller;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _ColoredUnderlinePainter(colors: colors, controller: controller);
}

class _ColoredUnderlinePainter extends BoxPainter {
  _ColoredUnderlinePainter({
    required this.colors,
    required this.controller,
  });

  final List<Color> colors;
  final TabController controller;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final double animValue =
        (controller.animation?.value ?? controller.index.toDouble())
            .clamp(0.0, colors.length - 1.0);
    final int fromIndex = animValue.floor();
    final int toIndex = animValue.ceil().clamp(0, colors.length - 1);
    final double t = animValue - fromIndex;
    final color = Color.lerp(colors[fromIndex], colors[toIndex], t)!;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;
    final rect = Rect.fromLTWH(
      offset.dx,
      offset.dy + (configuration.size?.height ?? 48) - 2,
      configuration.size?.width ?? 60,
      2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      paint,
    );
  }
}

// ─── AppBar geri butonu (hover destekli) ─────────────────────────────────────

class _BackButton extends StatefulWidget {
  const _BackButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.surfaceColor,
    required this.borderColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final Color surfaceColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Center(
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsetsDirectional.only(start: 12),
              decoration: BoxDecoration(
                color: _hovered
                    ? widget.surfaceColor
                        .withValues(alpha: widget.surfaceColor.a + 0.05)
                    : widget.surfaceColor,
                borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                border: Border.all(
                  color: _hovered
                      ? widget.borderColor
                          .withValues(alpha: widget.borderColor.a + 0.08)
                      : widget.borderColor,
                ),
              ),
              child: Icon(widget.icon, color: widget.iconColor, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}
