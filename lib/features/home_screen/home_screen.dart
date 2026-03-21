import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/game_constants.dart';
import '../../core/layout/responsive.dart';
import '../../core/utils/motion_utils.dart';
import '../../data/local/local_repository.dart';
import '../../core/models/game_mode.dart';
import '../../providers/audio_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/user_provider.dart';
import 'widgets/bottom_bar.dart';
import 'widgets/daily_banner.dart';
import 'widgets/deep_background.dart';
import 'widgets/dialogs.dart';
import 'widgets/gel_logo.dart';
import 'widgets/meta_game_bar.dart';
import 'widgets/mode_card.dart';
import 'widgets/streak_badge.dart';
import 'widgets/streak_reward_dialog.dart';

// ─── Ana ekran ────────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // İlk açılışta sıralı kontroller — SharedPreferences yüklendikten sonra
    ref.read(localRepositoryProvider.future).then((repo) async {
      if (!mounted) return;
      // 0) Analytics tercihini provider'a ve servise yükle
      final analyticsEnabled = repo.getAnalyticsEnabled();
      ref
          .read(appSettingsProvider.notifier)
          .setAnalyticsEnabled(enabled: analyticsEnabled);
      ref.read(analyticsServiceProvider).setEnabled(analyticsEnabled);
      // 1) Onboarding tamamlanmamışsa yönlendir
      if (!repo.getOnboardingDone()) {
        context.go('/onboarding');
        return;
      }
      await _continueStartupFlow(repo);
    });
  }

  Future<void> _continueStartupFlow(LocalRepository repo) async {
    if (!mounted) return;
    // 2) Streak seri ödülü kontrolü
    final streak = await repo.checkAndUpdateStreak();
    final lastRewardDay = repo.getLastStreakRewardDay();
    final eligibleTier = GameConstants.streakRewards.keys
        .where((day) => streak >= day && day > lastRewardDay)
        .fold<int>(0, (best, day) => day > best ? day : best);
    if (eligibleTier > 0 && mounted) {
      final reward = GameConstants.streakRewards[eligibleTier]!;
      await _showStreakRewardDialog(streak: eligibleTier, reward: reward);
      await repo.setLastStreakRewardDay(eligibleTier);
      final currentGelOzu = await repo.getGelOzu();
      await repo.saveGelOzu(currentGelOzu + reward);
    }
    if (!mounted) return;
    // 3) GDPR consent henüz gösterilmemişse dialog aç
    if (!repo.getConsentShown()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showConsentDialog(repo);
      });
      return;
    }
    // 4) iOS ATT izni iste (consent kabul edildiyse)
    _requestATTIfNeeded();
    // 5) Renk körü prompt henüz gösterilmemişse tek seferlik dialog
    if (!repo.getColorblindPromptShown()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showColorblindDialog(repo);
      });
    }
  }

  Future<void> _showConsentDialog(LocalRepository repo) async {
    final l = ref.read(stringsProvider);
    if (!mounted) return;
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => ConsentDialog(
        title: l.consentTitle,
        message: l.consentMessage,
        acceptLabel: l.consentAccept,
        declineLabel: l.consentDecline,
      ),
    );
    final enabled = accepted == true;
    await repo.setAnalyticsEnabled(enabled);
    await repo.setConsentShown();
    ref
        .read(appSettingsProvider.notifier)
        .setAnalyticsEnabled(enabled: enabled);
    ref.read(analyticsServiceProvider).setEnabled(enabled);
    // ATT izni (iOS) — consent kabul edildiyse
    if (enabled) _requestATTIfNeeded();
    // Sonraki adım: renk körü prompt
    if (mounted && !repo.getColorblindPromptShown()) {
      _showColorblindDialog(repo);
    }
  }

  Future<void> _requestATTIfNeeded() async {
    if (kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    try {
      await AppTrackingTransparency.requestTrackingAuthorization();
    } catch (_) {
      // ATT kullanılamıyor — sessizce atla
    }
  }

  Future<void> _showColorblindDialog(dynamic repo) async {
    final l = ref.read(stringsProvider);
    await repo.setColorblindPromptShown();

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => ColorblindPromptDialog(
        title: l.colorblindDialogTitle,
        message: l.colorblindDialogMessage,
        enableLabel: l.colorblindDialogEnable,
        skipLabel: l.colorblindDialogSkip,
        onEnable: () {
          ref
              .read(appSettingsProvider.notifier)
              .setColorBlindMode(enabled: true);
          Navigator.of(ctx).pop();
        },
        onSkip: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  Future<void> _showStreakRewardDialog({
    required int streak,
    required int reward,
  }) async {
    final l = ref.read(stringsProvider);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => StreakRewardDialog(
        streakDay: streak,
        reward: reward,
        title: l.streakRewardTitle,
        claimLabel: l.streakRewardClaim,
        onClaim: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(stringsProvider);
    final streak = ref.watch(streakProvider).valueOrNull ?? 0;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final hPadding = responsiveHPadding(screenWidth);
    final brightness = Theme.of(context).brightness;
    final bgColor = resolveColor(brightness, dark: kBgDark, light: kBgLight);
    final rm = shouldReduceMotion(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          const DeepBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: responsiveMaxWidth(screenWidth)),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPadding),
                  child: Column(
                    children: [
                      const SizedBox(height: 52),
                      GelLogo(subtitle: l.homeSubtitle)
                          .animateOrSkip(reduceMotion: rm)
                          .fadeIn(duration: 500.ms)
                          .scale(
                            begin: const Offset(0.85, 0.85),
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      if (streak >= 2) ...[
                        const SizedBox(height: 10),
                        StreakBadge(streak: streak, days: l.streakDays)
                            .animateOrSkip(reduceMotion: rm, delay: 200.ms)
                            .fadeIn(duration: 400.ms)
                            .scale(
                              begin: const Offset(0.7, 0.7),
                              duration: 400.ms,
                              curve: Curves.easeOutBack,
                            ),
                      ],
                      const SizedBox(height: 14),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DailyBanner(label: l.dailyTitle)
                                  .animateOrSkip(reduceMotion: rm, delay: 60.ms)
                                  .fadeIn(duration: 350.ms)
                                  .slideY(
                                    begin: 0.08,
                                    end: 0,
                                    duration: 350.ms,
                                    curve: Curves.easeOutCubic,
                                  ),
                              const SizedBox(height: 8),
                              ModeCard(
                                label: l.modeClassicName,
                                subtitle: l.modeClassicDesc,
                                color: kColorClassic,
                                icon: Icons.grid_view_rounded,
                                isFeatured: true,
                                badgeLabel: l.homeBadgeBeginning,
                                onTap: () => context
                                    .go('/game/${GameMode.classic.name}'),
                              )
                                  .animateOrSkip(reduceMotion: rm, delay: 80.ms)
                                  .fadeIn(duration: 350.ms)
                                  .slideY(
                                    begin: 0.15,
                                    end: 0,
                                    duration: 350.ms,
                                    curve: Curves.easeOutCubic,
                                  ),
                              const SizedBox(height: 10),
                              ModeCard(
                                label: l.modeColorChefName,
                                subtitle: l.modeColorChefDesc,
                                color: kColorChef,
                                icon: Icons.colorize_rounded,
                                onTap: () => context
                                    .go('/game/${GameMode.colorChef.name}'),
                              )
                                  .animateOrSkip(
                                      reduceMotion: rm, delay: 160.ms)
                                  .fadeIn(duration: 350.ms)
                                  .slideY(
                                    begin: 0.15,
                                    end: 0,
                                    duration: 350.ms,
                                    curve: Curves.easeOutCubic,
                                  ),
                              const SizedBox(height: 10),
                              ModeCard(
                                label: l.modeTimeTrialName,
                                subtitle: l.modeTimeTrialDesc,
                                color: kColorTimeTrial,
                                icon: Icons.timer_rounded,
                                onTap: () => context
                                    .go('/game/${GameMode.timeTrial.name}'),
                              )
                                  .animateOrSkip(
                                      reduceMotion: rm, delay: 240.ms)
                                  .fadeIn(duration: 350.ms)
                                  .slideY(
                                    begin: 0.15,
                                    end: 0,
                                    duration: 350.ms,
                                    curve: Curves.easeOutCubic,
                                  ),
                              const SizedBox(height: 10),
                              ModeCard(
                                label: l.modeZenName,
                                subtitle: l.modeZenDesc,
                                color: kColorZen,
                                icon: Icons.spa_rounded,
                                isLocked:
                                    !ref.watch(appSettingsProvider).glooPlus,
                                lockLabel: l.glooPlusTitle,
                                onTap: () {
                                  if (ref.read(appSettingsProvider).glooPlus) {
                                    context.go('/game/${GameMode.zen.name}');
                                  } else {
                                    context.push('/shop');
                                  }
                                },
                              )
                                  .animateOrSkip(
                                      reduceMotion: rm, delay: 320.ms)
                                  .fadeIn(duration: 350.ms)
                                  .slideY(
                                    begin: 0.15,
                                    end: 0,
                                    duration: 350.ms,
                                    curve: Curves.easeOutCubic,
                                  ),
                              const SizedBox(height: 10),
                              ModeCard(
                                label: l.modeLevelName,
                                subtitle: l.modeLevelDesc,
                                color: kOrange,
                                icon: Icons.map_rounded,
                                badgeLabel: l.newBadge,
                                onTap: () => context.go('/levels'),
                              )
                                  .animateOrSkip(
                                      reduceMotion: rm, delay: 400.ms)
                                  .fadeIn(duration: 350.ms)
                                  .slideY(
                                    begin: 0.15,
                                    end: 0,
                                    duration: 350.ms,
                                    curve: Curves.easeOutCubic,
                                  ),
                              const SizedBox(height: 10),
                              ModeCard(
                                label: l.modeDuelName,
                                subtitle: l.modeDuelDesc,
                                color: kColorClassic,
                                icon: Icons.sports_mma_rounded,
                                badgeLabel: l.newBadge,
                                onTap: () => context.go('/pvp-lobby'),
                              )
                                  .animateOrSkip(
                                      reduceMotion: rm, delay: 480.ms)
                                  .fadeIn(duration: 350.ms)
                                  .slideY(
                                    begin: 0.15,
                                    end: 0,
                                    duration: 350.ms,
                                    curve: Curves.easeOutCubic,
                                  ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      // Faz 4: Meta-game hizli erisim cubugu
                      MetaGameBar(
                        islandLabel: l.islandLabel,
                        characterLabel: l.characterLabel,
                        seasonLabel: l.seasonLabel,
                      )
                          .animateOrSkip(reduceMotion: rm, delay: 600.ms)
                          .fadeIn(duration: 350.ms)
                          .slideY(begin: 0.12, end: 0, duration: 350.ms),
                      const SizedBox(height: 8),
                      BottomBar(
                        leaderboardLabel: l.navLeaderboard,
                        shopLabel: l.navShop,
                        settingsLabel: l.navSettings,
                        collectionLabel: l.collectionTitle,
                      )
                          .animateOrSkip(reduceMotion: rm, delay: 500.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.2, end: 0, duration: 400.ms),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
