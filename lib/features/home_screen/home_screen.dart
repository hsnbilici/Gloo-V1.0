import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../data/local/local_repository.dart';
import '../../game/world/game_world.dart';
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
    ref.read(localRepositoryProvider.future).then((repo) {
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
      // 2) GDPR consent henüz gösterilmemişse dialog aç
      if (!repo.getConsentShown()) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showConsentDialog(repo);
        });
        return;
      }
      // 3) iOS ATT izni iste (consent kabul edildiyse)
      _requestATTIfNeeded();
      // 4) Renk körü prompt henüz gösterilmemişse tek seferlik dialog
      if (!repo.getColorblindPromptShown()) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showColorblindDialog(repo);
        });
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(stringsProvider);
    final streak = ref.watch(streakProvider).valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: kBgDark,
      body: Stack(
        children: [
          const DeepBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 52),
                  GelLogo(subtitle: l.homeSubtitle)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(
                        begin: const Offset(0.85, 0.85),
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  if (streak >= 2) ...[
                    const SizedBox(height: 10),
                    StreakBadge(streak: streak, days: l.streakDays)
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 400.ms)
                        .scale(
                          begin: const Offset(0.7, 0.7),
                          duration: 400.ms,
                          curve: Curves.easeOutBack,
                        ),
                  ],
                  const SizedBox(height: 14),
                  DailyBanner(label: l.dailyTitle)
                      .animate(delay: 60.ms)
                      .fadeIn(duration: 350.ms)
                      .slideY(
                        begin: 0.08,
                        end: 0,
                        duration: 350.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          ModeCard(
                            label: l.modeClassicName,
                            subtitle: l.modeClassicDesc,
                            color: kColorClassic,
                            icon: Icons.grid_view_rounded,
                            isFeatured: true,
                            badgeLabel: l.homeBadgeBeginning,
                            onTap: () =>
                                context.go('/game/${GameMode.classic.name}'),
                          )
                              .animate(delay: 80.ms)
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
                            onTap: () =>
                                context.go('/game/${GameMode.colorChef.name}'),
                          )
                              .animate(delay: 160.ms)
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
                            onTap: () =>
                                context.go('/game/${GameMode.timeTrial.name}'),
                          )
                              .animate(delay: 240.ms)
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
                            lockLabel: 'GLOO+',
                            onTap: () {
                              if (ref.read(appSettingsProvider).glooPlus) {
                                context.go('/game/${GameMode.zen.name}');
                              } else {
                                context.push('/shop');
                              }
                            },
                          )
                              .animate(delay: 320.ms)
                              .fadeIn(duration: 350.ms)
                              .slideY(
                                begin: 0.15,
                                end: 0,
                                duration: 350.ms,
                                curve: Curves.easeOutCubic,
                              ),
                          const SizedBox(height: 10),
                          // Faz 4: Seviye modu
                          ModeCard(
                            label: l.modeLevelName,
                            subtitle: l.modeLevelDesc,
                            color: const Color(0xFFFF8C42),
                            icon: Icons.map_rounded,
                            badgeLabel: 'YENİ',
                            onTap: () => context.go('/levels'),
                          )
                              .animate(delay: 400.ms)
                              .fadeIn(duration: 350.ms)
                              .slideY(
                                begin: 0.15,
                                end: 0,
                                duration: 350.ms,
                                curve: Curves.easeOutCubic,
                              ),
                          const SizedBox(height: 10),
                          // Faz 4: Düello modu
                          ModeCard(
                            label: l.modeDuelName,
                            subtitle: l.modeDuelDesc,
                            color: const Color(0xFFFF4D6D),
                            icon: Icons.sports_mma_rounded,
                            badgeLabel: 'YENİ',
                            onTap: () => context.go('/pvp-lobby'),
                          )
                              .animate(delay: 480.ms)
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
                  const MetaGameBar()
                      .animate(delay: 540.ms)
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: 0.12, end: 0, duration: 350.ms),
                  const SizedBox(height: 8),
                  BottomBar(
                    leaderboardLabel: l.navLeaderboard,
                    shopLabel: l.navShop,
                    settingsLabel: l.navSettings,
                    collectionLabel: l.collectionTitle,
                  )
                      .animate(delay: 420.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0, duration: 400.ms),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
