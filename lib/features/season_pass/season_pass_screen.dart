import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/widgets/glow_orb.dart';
import '../../data/remote/remote_repository.dart';
import '../../game/meta/resource_manager.dart';
import '../../providers/user_provider.dart';

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
      amount: tier % 5 == 0 ? 1 : tier % 3 == 0 ? 5 : 10 + i,
    ),
    premiumReward: SeasonReward(
      type: tier % 10 == 0
          ? SeasonRewardType.costume
          : SeasonRewardType.gelOzu,
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
  static const _kAccent = Color(0xFFFFD700);

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
    final remote = RemoteRepository();
    final meta = await remote.loadMetaState();
    if (meta != null && mounted) {
      final backendPass = meta['season_pass_state'] as Map<String, dynamic>?;
      if (backendPass != null && backendPass.isNotEmpty) {
        _passState.loadFromMap(
            backendPass.map((k, v) => MapEntry(k, v as int)));
        await repo.saveSeasonPassState(_passState.toMap());
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTier = _passState.getCurrentTier(_kSeasonTiers);

    return Scaffold(
      backgroundColor: kBgDark,
      body: Stack(
        children: [
          _SeasonBackground(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Ust bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius:
                                BorderRadius.circular(UIConstants.radiusMd),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                            ),
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white70, size: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'SEZON PASI',
                        style: TextStyle(
                          color: _kAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(
                              color: _kAccent.withValues(alpha: 0.5),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Mevcut tier
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _kAccent.withValues(alpha: 0.10),
                          borderRadius:
                              BorderRadius.circular(UIConstants.radiusMd),
                          border: Border.all(
                            color: _kAccent.withValues(alpha: 0.30),
                          ),
                        ),
                        child: Text(
                          'Tier $currentTier/50',
                          style: const TextStyle(
                            color: _kAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: 16),
                // XP ilerleme cubugu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _XpProgressBar(
                    currentXp: _passState.currentXp,
                    currentTier: currentTier,
                    tiers: _kSeasonTiers,
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 350.ms),
                const SizedBox(height: 16),
                // Yatay tier listesi
                Expanded(
                  child: _loaded
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _kSeasonTiers.length,
                          itemBuilder: (context, index) {
                            final tier = _kSeasonTiers[index];
                            final isUnlocked = tier.tier <= currentTier;
                            final isCurrent = tier.tier == currentTier + 1;

                            return _TierCard(
                              tier: tier,
                              isUnlocked: isUnlocked,
                              isCurrent: isCurrent,
                              claimedFree:
                                  _passState.claimedFreeTier >= tier.tier,
                              claimedPremium:
                                  _passState.claimedPremiumTier >= tier.tier,
                              delay: Duration(milliseconds: 30 * index),
                            );
                          },
                        )
                      : const Center(
                          child: CircularProgressIndicator(color: _kAccent),
                        ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── XP Ilerleme Cubugu ──────────────────────────────────────────────────────

class _XpProgressBar extends StatelessWidget {
  const _XpProgressBar({
    required this.currentXp,
    required this.currentTier,
    required this.tiers,
  });

  final int currentXp;
  final int currentTier;
  final List<SeasonTier> tiers;

  @override
  Widget build(BuildContext context) {
    int accumulated = 0;
    int nextXp = 0;
    int prevAccumulated = 0;
    for (final tier in tiers) {
      accumulated += tier.xpRequired;
      if (tier.tier == currentTier + 1) {
        nextXp = accumulated;
        prevAccumulated = accumulated - tier.xpRequired;
        break;
      }
    }
    if (nextXp == 0) nextXp = accumulated;

    final progress = nextXp > prevAccumulated
        ? ((currentXp - prevAccumulated) / (nextXp - prevAccumulated))
            .clamp(0.0, 1.0)
        : 1.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$currentXp XP',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.60),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Sonraki: $nextXp XP',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                Container(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFF8C42)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Tier Karti ─────────────────────────────────────────────────────────────

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.tier,
    required this.isUnlocked,
    required this.isCurrent,
    required this.claimedFree,
    required this.claimedPremium,
    required this.delay,
  });

  final SeasonTier tier;
  final bool isUnlocked;
  final bool isCurrent;
  final bool claimedFree;
  final bool claimedPremium;

  final Duration delay;

  IconData _rewardIcon(SeasonRewardType type) => switch (type) {
        SeasonRewardType.gelOzu     => Icons.water_drop_rounded,
        SeasonRewardType.costume    => Icons.checkroom_rounded,
        SeasonRewardType.decoration => Icons.auto_awesome_rounded,
        SeasonRewardType.energy     => Icons.bolt_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final borderColor = isCurrent
        ? const Color(0xFFFFD700)
        : isUnlocked
            ? const Color(0xFF3CFF8B).withValues(alpha: 0.40)
            : Colors.white.withValues(alpha: 0.08);

    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: isCurrent
            ? const Color(0xFFFFD700).withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(UIConstants.radiusMd),
        border: Border.all(color: borderColor, width: isCurrent ? 2 : 1),
      ),
      child: Column(
        children: [
          // Tier numarasi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isCurrent
                  ? const Color(0xFFFFD700).withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Center(
              child: Text(
                '${tier.tier}',
                style: TextStyle(
                  color: isCurrent
                      ? const Color(0xFFFFD700)
                      : isUnlocked
                          ? Colors.white
                          : kMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          // Ucretsiz odul (ust)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'UCRETSIZ',
                    style: TextStyle(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.50),
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    _rewardIcon(tier.freeReward.type),
                    color: isUnlocked
                        ? const Color(0xFF00E5FF)
                        : kMuted,
                    size: 20,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${tier.freeReward.amount}',
                    style: TextStyle(
                      color: isUnlocked
                          ? Colors.white.withValues(alpha: 0.80)
                          : kMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Ayrac
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.06),
          ),
          // Premium odul (alt)
          Expanded(
            child: Center(
              child: tier.premiumReward != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'PREMIUM',
                          style: TextStyle(
                            color: const Color(0xFFFF69B4).withValues(alpha: 0.50),
                            fontSize: 7,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          _rewardIcon(tier.premiumReward!.type),
                          color: isUnlocked
                              ? const Color(0xFFFF69B4)
                              : kMuted.withValues(alpha: 0.40),
                          size: 20,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${tier.premiumReward!.amount}',
                          style: TextStyle(
                            color: isUnlocked
                                ? Colors.white.withValues(alpha: 0.60)
                                : kMuted.withValues(alpha: 0.30),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
          ),
        ],
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 200.ms)
        .slideX(begin: 0.1, end: 0, duration: 200.ms);
  }
}

// ─── Arkaplan ───────────────────────────────────────────────────────────────

class _SeasonBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: kBgDark),
        const Positioned(
          top: -100,
          left: -50,
          child: GlowOrb(size: 320, color: Color(0xFFFFD700), opacity: 0.06),
        ),
        const Positioned(
          bottom: -80,
          right: -40,
          child: GlowOrb(size: 260, color: Color(0xFFFF69B4), opacity: 0.05),
        ),
      ],
    );
  }
}
