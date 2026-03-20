import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/layout/responsive.dart';
import '../../core/layout/rtl_helpers.dart';
import '../shared/glow_orb.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_provider.dart';

/// Nadir renk kombinasyonları koleksiyon/albüm ekranı.
///
/// `LocalRepository` üzerinden `discovered_colors` set'i okunur.
/// Sentez tablosundaki 8 birleşim rengi koleksiyona alınabilir:
/// orange, green, purple, brown, pink, lightBlue, lime, maroon.
class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  /// Koleksiyona alınabilir renkler — sentezlenmiş renkler.
  static const _kCollectibleColors = [
    GelColor.orange,
    GelColor.green,
    GelColor.purple,
    GelColor.brown,
    GelColor.pink,
    GelColor.lightBlue,
    GelColor.lime,
    GelColor.maroon,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(stringsProvider);
    final repoAsync = ref.watch(localRepositoryProvider);
    final discovered =
        repoAsync.valueOrNull?.getDiscoveredColors() ?? <String>{};
    final total = _kCollectibleColors.length;
    final found =
        _kCollectibleColors.where((c) => discovered.contains(c.name)).length;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hPadding = responsiveHPadding(screenWidth);
    final dir = Directionality.of(context);
    final brightness = Theme.of(context).brightness;
    final bgColor = resolveColor(brightness, dark: kBgDark, light: kBgLight);
    final textColor = resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    final surfaceColor = resolveColor(brightness, dark: Colors.white.withValues(alpha: 0.06), light: kCardBgLight);
    final borderColor = resolveColor(brightness, dark: Colors.white.withValues(alpha: 0.1), light: kCardBorderLight);

    return ResponsiveScaffold(
      backgroundColor: bgColor,
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
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                  border: Border.all(color: borderColor),
                ),
                child: Icon(directionalBackIcon(dir),
                    color: textColor, size: 18),
              ),
            ),
          ),
        ),
        title: Text(
          l.collectionTitle,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kCyan.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                  border: Border.all(color: kCyan.withValues(alpha: 0.30)),
                ),
                child: Text(
                  '$found / $total',
                  style: const TextStyle(
                    color: kCyan,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
            children: [
              const _CollectionBackground(),
              found == 0
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPadding),
                        child: Text(
                          l.collectionEmpty,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: kMuted, fontSize: 14, height: 1.5),
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.fromLTRB(
                          hPadding, 16, hPadding, 40),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: responsiveColumns(screenWidth,
                            phone: 2, tablet: 3, desktop: 4),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: _kCollectibleColors.length,
                      itemBuilder: (context, index) {
                        final gelColor = _kCollectibleColors[index];
                        final isDiscovered =
                            discovered.contains(gelColor.name);

                        // Sentez girdisini bul
                        final recipe = _findRecipe(gelColor);

                        return _ColorCard(
                          gelColor: gelColor,
                          isDiscovered: isDiscovered,
                          colorName: l.colorName(gelColor),
                          discoveredLabel: l.collectionDiscovered,
                          lockedLabel: l.collectionLocked,
                          recipe: recipe,
                        )
                            .animate(delay: (60 * index).ms)
                            .fadeIn(duration: 350.ms)
                            .scale(
                              begin: const Offset(0.92, 0.92),
                              duration: 350.ms,
                              curve: Curves.easeOutCubic,
                            );
                      },
                    ),
            ],
          ),
    );
  }

  static (GelColor, GelColor)? _findRecipe(GelColor target) {
    for (final entry in kColorMixingTable.entries) {
      if (entry.value == target) return entry.key;
    }
    return null;
  }
}

// ─── Arkaplan ─────────────────────────────────────────────────────────────────

class _CollectionBackground extends StatelessWidget {
  const _CollectionBackground();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = resolveColor(brightness, dark: kBgDark, light: kBgLight);
    return Stack(
      children: [
        Container(color: bgColor),
        const Positioned(
          top: -80,
          right: -60,
          child: GlowOrb(size: 260, color: kColorChef, opacity: 0.06),
        ),
        const Positioned(
          bottom: -100,
          left: -50,
          child: GlowOrb(size: 300, color: kColorClassic, opacity: 0.05),
        ),
      ],
    );
  }
}

// ─── Renk kartı ───────────────────────────────────────────────────────────────

class _ColorCard extends StatelessWidget {
  const _ColorCard({
    required this.gelColor,
    required this.isDiscovered,
    required this.colorName,
    required this.discoveredLabel,
    required this.lockedLabel,
    required this.recipe,
  });

  final GelColor gelColor;
  final bool isDiscovered;
  final String colorName;
  final String discoveredLabel;
  final String lockedLabel;
  final (GelColor, GelColor)? recipe;

  @override
  Widget build(BuildContext context) {
    final color = gelColor.displayColor;
    final brightness = Theme.of(context).brightness;
    final textColor = resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: isDiscovered
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.14),
                  color.withValues(alpha: 0.04),
                  Colors.transparent,
                ],
              )
            : null,
        color: isDiscovered ? null : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(UIConstants.radiusLg),
        border: Border.all(
          color: isDiscovered
              ? color.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.06),
          width: isDiscovered ? 1.5 : 1,
        ),
        boxShadow: isDiscovered
            ? [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 14)]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Renk dairesi
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  isDiscovered ? color : Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDiscovered
                    ? color.withValues(alpha: 0.70)
                    : Colors.white.withValues(alpha: 0.10),
                width: 2.5,
              ),
              boxShadow: isDiscovered
                  ? [
                      BoxShadow(
                          color: color.withValues(alpha: 0.40), blurRadius: 16),
                      BoxShadow(
                          color: color.withValues(alpha: 0.15),
                          blurRadius: 30,
                          spreadRadius: 4),
                    ]
                  : null,
            ),
            child: isDiscovered
                ? null
                : const Icon(Icons.lock_rounded, color: kMuted, size: 18),
          ),
          const SizedBox(height: 10),
          // Renk adı
          Text(
            isDiscovered ? colorName : '???',
            style: TextStyle(
              color: isDiscovered ? textColor : kMuted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          // Sentez formülü veya durum etiketi
          if (isDiscovered && recipe != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MiniColorDot(color: recipe!.$1.displayColor),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child:
                      Text('+', style: TextStyle(color: kMuted, fontSize: 10)),
                ),
                _MiniColorDot(color: recipe!.$2.displayColor),
              ],
            )
          else
            Text(
              isDiscovered ? discoveredLabel : lockedLabel,
              style: TextStyle(
                color: isDiscovered
                    ? color.withValues(alpha: 0.70)
                    : kMuted.withValues(alpha: 0.50),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniColorDot extends StatelessWidget {
  const _MiniColorDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.70)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 4),
        ],
      ),
    );
  }
}
