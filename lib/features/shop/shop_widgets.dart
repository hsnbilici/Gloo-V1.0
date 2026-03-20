import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/layout/rtl_helpers.dart';
import '../shared/glow_orb.dart';

// ─── Arkaplan ─────────────────────────────────────────────────────────────────

class ShopBackground extends StatelessWidget {
  const ShopBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: kBgDark),
        const Positioned(
          top: -80,
          left: -60,
          child: GlowOrb(size: 300, color: kGold, opacity: 0.06),
        ),
        const Positioned(
          bottom: -100,
          right: -50,
          child: GlowOrb(size: 260, color: kColorZen, opacity: 0.07),
        ),
      ],
    );
  }
}

// ─── Ürün kartı ───────────────────────────────────────────────────────────────

class ProductTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final dir = Directionality.of(context);
    final (gradBegin, gradEnd) = directionalGradientAlignment(dir);
    return Semantics(
      label: label,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: gradBegin,
            end: gradEnd,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.textScalerOf(context).scale(14),
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
                : Semantics(
                    label: '$label $price',
                    button: true,
                    child: GestureDetector(
                      onTap: onBuy,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(UIConstants.radiusSm),
                          border:
                              Border.all(color: color.withValues(alpha: 0.50)),
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
                  child: Semantics(
                    label: '$monthlyLabel $monthlyPrice',
                    button: true,
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
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Semantics(
                    label: '$yearlyLabel $yearlyPrice',
                    button: true,
                    child: GestureDetector(
                      onTap: onYearly,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: kGold.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(UIConstants.radiusMd),
                          border: Border.all(
                              color: kGold.withValues(alpha: 0.50), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                                color: kGold.withValues(alpha: 0.14),
                                blurRadius: 10),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: kGold.withValues(alpha: 0.20),
                                borderRadius:
                                    BorderRadius.circular(UIConstants.radiusXs),
                              ),
                              child: Text(
                                badgeLabel,
                                style: const TextStyle(
                                  color: kGold,
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
                                color: kGold.withValues(alpha: 0.80),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              yearlyPrice,
                              style: const TextStyle(
                                color: kGold,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
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
