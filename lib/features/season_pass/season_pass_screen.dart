import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/layout/responsive.dart';
import '../../core/layout/rtl_helpers.dart';
import '../../core/utils/motion_utils.dart';
import '../../game/meta/resource_manager.dart';
import '../../providers/locale_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/user_provider.dart';
import 'season_pass_background.dart';
import 'season_pass_widgets.dart';

// ─── Sezon Pasi Tier Verileri (50 tier, statik) ─────────────────────────────

final List<SeasonTier> _kSeasonTiers = List.generate(50, (i) {
  final tier = i + 1;
  return SeasonTier(
    tier: tier,
    xpRequired: 100 + (i * 20),
    freeReward: SeasonReward(
      type: tier % 5 == 0
          ? SeasonRewardType.costume
          : tier % 3 == 0
              ? SeasonRewardType.energy
              : SeasonRewardType.gelOzu,
      amount: tier % 5 == 0
          ? 1
          : tier % 3 == 0
              ? 5
              : 10 + i,
    ),
    premiumReward: SeasonReward(
      type: tier % 10 == 0 ? SeasonRewardType.costume : SeasonRewardType.gelOzu,
      amount: tier % 10 == 0 ? 1 : 20 + i * 2,
      isPremium: true,
    ),
  );
});

// ─── Sezon Pasi Ekrani ──────────────────────────────────────────────────────

class SeasonPassScreen extends ConsumerStatefulWidget {
  const SeasonPassScreen({super.key});

  @override
  ConsumerState<SeasonPassScreen> createState() => _SeasonPassScreenState();
}

class _SeasonPassScreenState extends ConsumerState<SeasonPassScreen> {
  late final SeasonPassState _passState;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _passState = SeasonPassState();
    _loadState();
  }

  Future<void> _loadState() async {
    final repo = await ref.read(localRepositoryProvider.future);
    _passState.loadFromMap(repo.getSeasonPassState());
    setState(() => _loaded = true);

    // Backend'den sync
    final remote = ref.read(remoteRepositoryProvider);
    final meta = await remote.loadMetaState();
    if (meta != null && mounted) {
      final backendPass = meta.seasonPassState;
      if (backendPass != null && backendPass.isNotEmpty) {
        _passState
            .loadFromMap(backendPass.map((k, v) => MapEntry(k, v as int)));
        await repo.saveSeasonPassState(_passState.toMap());
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dir = Directionality.of(context);
    final rm = shouldReduceMotion(context);
    final currentTier = _passState.getCurrentTier(_kSeasonTiers);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hPadding = responsiveHPadding(screenWidth);
    final brightness = Theme.of(context).brightness;
    final bgColor = resolveColor(brightness, dark: kBgDark, light: kBgLight);
    final surfaceColor = resolveColor(brightness,
        dark: Colors.white.withValues(alpha: 0.06), light: kCardBgLight);
    final borderColor = resolveColor(brightness,
        dark: Colors.white.withValues(alpha: 0.10), light: kCardBorderLight);
    final accentColor =
        resolveColor(brightness, dark: kGold, light: kGoldLight);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          const SeasonBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: responsiveMaxWidth(screenWidth)),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPadding),
                      child: Row(
                        children: [
                          Semantics(
                            label: ref.read(stringsProvider).backLabel,
                            button: true,
                            child: GestureDetector(
                              onTap: () => context.go('/'),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(
                                      UIConstants.radiusMd),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Icon(directionalBackIcon(dir),
                                    color: accentColor, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'SEZON PASI',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                              shadows: [
                                Shadow(
                                  color: accentColor.withValues(alpha: 0.5),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: kGold.withValues(alpha: 0.10),
                              borderRadius:
                                  BorderRadius.circular(UIConstants.radiusMd),
                              border: Border.all(
                                color: kGold.withValues(alpha: 0.30),
                              ),
                            ),
                            child: Text(
                              'Tier $currentTier/50',
                              style: const TextStyle(
                                color: kGold,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animateOrSkip(reduceMotion: rm).fadeIn(duration: 300.ms),
                    const SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPadding),
                      child: XpProgressBar(
                        currentXp: _passState.currentXp,
                        currentTier: currentTier,
                        tiers: _kSeasonTiers,
                      ),
                    )
                        .animateOrSkip(reduceMotion: rm, delay: 100.ms)
                        .fadeIn(duration: 350.ms),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _loaded
                          ? ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding:
                                  EdgeInsets.symmetric(horizontal: hPadding),
                              itemCount: _kSeasonTiers.length,
                              itemBuilder: (context, index) {
                                final tier = _kSeasonTiers[index];
                                final isUnlocked = tier.tier <= currentTier;
                                final isCurrent = tier.tier == currentTier + 1;

                                return TierCard(
                                  tier: tier,
                                  isUnlocked: isUnlocked,
                                  isCurrent: isCurrent,
                                  claimedFree:
                                      _passState.claimedFreeTier >= tier.tier,
                                  claimedPremium:
                                      _passState.claimedPremiumTier >=
                                          tier.tier,
                                );
                              },
                            )
                          : const Center(
                              child: CircularProgressIndicator(color: kGold),
                            ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
