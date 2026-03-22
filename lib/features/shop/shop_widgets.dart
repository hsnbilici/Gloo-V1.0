import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/layout/rtl_helpers.dart';
import '../shared/glow_orb.dart';

// ─── Arkaplan ─────────────────────────────────────────────────────────────────

class ShopBackground extends StatelessWidget {
  const ShopBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = resolveColor(brightness, dark: kBgDark, light: kBgLight);
    final isDark = brightness == Brightness.dark;
    final orbAlpha = isDark ? 1.0 : 0.45;

    return Stack(
      children: [
        Container(color: bgColor),
        Positioned(
          top: -80,
          left: -60,
          child: GlowOrb(size: 300, color: kGold, opacity: 0.06 * orbAlpha),
        ),
        Positioned(
          bottom: -100,
          right: -50,
          child: GlowOrb(size: 260, color: kColorZen, opacity: 0.07 * orbAlpha),
        ),
      ],
    );
  }
}

// ─── Ürün kartı ───────────────────────────────────────────────────────────────

class ProductTile extends StatefulWidget {
  const ProductTile({
    super.key,
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
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  bool _buyHovered = false;

  @override
  Widget build(BuildContext context) {
    final dir = Directionality.of(context);
    final (gradBegin, gradEnd) = directionalGradientAlignment(dir);
    return Semantics(
      label: widget.label,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: gradBegin,
            end: gradEnd,
            colors: [
              widget.color
                  .withValues(alpha: widget.isFeatured ? 0.14 : 0.08),
              widget.color.withValues(alpha: 0.02),
              Colors.transparent,
            ],
            stops: const [0.0, 0.35, 1.0],
          ),
          borderRadius: BorderRadius.circular(UIConstants.radiusTile),
          border: Border.all(
            color: widget.color
                .withValues(alpha: widget.isFeatured ? 0.45 : 0.22),
            width: widget.isFeatured ? 1.5 : 1,
          ),
          boxShadow: widget.isFeatured
              ? [
                  BoxShadow(
                      color: widget.color.withValues(alpha: 0.12),
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
                color: widget.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                border:
                    Border.all(color: widget.color.withValues(alpha: 0.30)),
              ),
              child: Icon(widget.icon, color: widget.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.textScalerOf(context).scale(14),
                      fontWeight: FontWeight.w700,
                      shadows: widget.isFeatured
                          ? [
                              Shadow(
                                  color:
                                      widget.color.withValues(alpha: 0.35),
                                  blurRadius: 8)
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: MediaQuery.textScalerOf(context).scale(11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            widget.purchased
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(UIConstants.radiusSm),
                      border: Border.all(
                          color: widget.color.withValues(alpha: 0.35)),
                    ),
                    child:
                        Icon(Icons.check_rounded, color: widget.color, size: 16),
                  )
                : Semantics(
                    label: '${widget.label} ${widget.price}',
                    button: true,
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _buyHovered = true),
                      onExit: (_) => setState(() => _buyHovered = false),
                      child: GestureDetector(
                        onTap: widget.onBuy,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: widget.color.withValues(
                                alpha: _buyHovered ? 0.22 : 0.15),
                            borderRadius:
                                BorderRadius.circular(UIConstants.radiusSm),
                            border: Border.all(
                                color: widget.color.withValues(
                                    alpha: _buyHovered ? 0.70 : 0.50)),
                          ),
                          child: Text(
                            widget.price,
                            style: TextStyle(
                              color: widget.color,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// ─── Gloo+ abonelik kartı ────────────────────────────────────────────────────

class GlooPlusCard extends StatelessWidget {
  const GlooPlusCard({
    super.key,
    required this.title,
    required this.desc,
    required this.monthlyLabel,
    required this.quarterLabel,
    required this.yearlyLabel,
    required this.badgeLabel,
    required this.monthlyPrice,
    required this.quarterPrice,
    required this.yearlyPrice,
    required this.isSubscribed,
    required this.onMonthly,
    required this.onQuarter,
    required this.onYearly,
  });

  final String title;
  final String desc;
  final String monthlyLabel;
  final String quarterLabel;
  final String yearlyLabel;
  final String badgeLabel;
  final String monthlyPrice;
  final String quarterPrice;
  final String yearlyPrice;
  final bool isSubscribed;
  final VoidCallback onMonthly;
  final VoidCallback onQuarter;
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
            kGold.withValues(alpha: 0.12),
            kColorZen.withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(UIConstants.radiusLg),
        border: Border.all(color: kGold.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: kGold.withValues(alpha: 0.10),
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
                      kGold.withValues(alpha: 0.20),
                      kColorZen.withValues(alpha: 0.15)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                  border: Border.all(color: kGold.withValues(alpha: 0.45)),
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    color: kGold, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: kGold,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                              color: kGold.withValues(alpha: 0.50),
                              blurRadius: 12)
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                color: kGold.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                border: Border.all(color: kGold.withValues(alpha: 0.40)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: kGold, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: kGold,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                            color: kGold.withValues(alpha: 0.40), blurRadius: 8)
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _SubscriptionOption(
                    label: monthlyLabel,
                    price: monthlyPrice,
                    onTap: onMonthly,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SubscriptionOption(
                    label: quarterLabel,
                    price: quarterPrice,
                    onTap: onQuarter,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SubscriptionOption(
                    label: yearlyLabel,
                    price: yearlyPrice,
                    badgeLabel: badgeLabel,
                    isHighlighted: true,
                    onTap: onYearly,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SubscriptionOption extends StatefulWidget {
  const _SubscriptionOption({
    required this.label,
    required this.price,
    required this.onTap,
    this.badgeLabel,
    this.isHighlighted = false,
  });

  final String label;
  final String price;
  final VoidCallback onTap;
  final String? badgeLabel;
  final bool isHighlighted;

  @override
  State<_SubscriptionOption> createState() => _SubscriptionOptionState();
}

class _SubscriptionOptionState extends State<_SubscriptionOption> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${widget.label} ${widget.price}',
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: widget.isHighlighted
                  ? kGold.withValues(alpha: _hovered ? 0.18 : 0.12)
                  : Colors.white.withValues(alpha: _hovered ? 0.08 : 0.04),
              borderRadius: BorderRadius.circular(UIConstants.radiusMd),
              border: Border.all(
                color: widget.isHighlighted
                    ? kGold.withValues(alpha: _hovered ? 0.65 : 0.50)
                    : Colors.white.withValues(alpha: _hovered ? 0.20 : 0.12),
                width: widget.isHighlighted ? 1.5 : 1,
              ),
              boxShadow: widget.isHighlighted
                  ? [
                      BoxShadow(
                          color: kGold.withValues(
                              alpha: _hovered ? 0.22 : 0.14),
                          blurRadius: 10),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                if (widget.badgeLabel != null) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: kGold.withValues(alpha: 0.20),
                      borderRadius:
                          BorderRadius.circular(UIConstants.radiusXs),
                    ),
                    child: Text(
                      widget.badgeLabel!,
                      style: const TextStyle(
                        color: kGold,
                        fontSize: 7,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.isHighlighted
                        ? kGold.withValues(alpha: 0.80)
                        : Colors.white.withValues(alpha: 0.60),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.price,
                  style: TextStyle(
                    color: widget.isHighlighted ? kGold : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
