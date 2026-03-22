import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/game_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/layout/responsive.dart';
import '../../core/layout/rtl_helpers.dart';
import '../../core/models/game_mode.dart';
import '../../core/utils/motion_utils.dart';
import '../../data/local/local_repository.dart';
import '../../game/economy/currency_manager.dart';
import '../../game/levels/level_progression.dart';
import '../../audio/audio_manager.dart';
import '../../audio/sound_bank.dart';
import '../../core/constants/audio_constants.dart';
import '../../providers/audio_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/service_providers.dart';
import '../../services/notification_service.dart';
import '../../providers/user_provider.dart';
import 'widgets/bottom_bar.dart';
import 'widgets/daily_banner.dart';
import 'widgets/deep_background.dart';
import 'widgets/dialogs.dart';
import 'widgets/gel_logo.dart';
import 'widgets/mode_card.dart';
import 'widgets/quest_bar.dart';
import 'widgets/streak_badge.dart';
import 'widgets/meta_game_bar.dart';
import 'widgets/streak_reward_dialog.dart';

// ─── Ana ekran ────────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  final _soundBank = SoundBank();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    AudioManager().playMusic(AudioPaths.bgMenuLofi);
    // Initialize + schedule notification reminders
    if (!kIsWeb) {
      _initNotifications();
    }
  }

  Future<void> _initNotifications() async {
    try {
      final notif = ref.read(notificationServiceProvider);
      await notif.initialize();
      // Bildirimler devre dışıysa zamanlama yapma
      final repo = await ref.read(localRepositoryProvider.future);
      if (!repo.getNotificationsEnabled()) return;
      final l = ref.read(stringsProvider);
      await notif.scheduleStreakReminder(
          title: l.notifStreakTitle, body: l.notifStreakBody);
      await notif.scheduleDailyPuzzleReminder(
          title: l.notifDailyTitle, body: l.notifDailyBody);
      await notif.scheduleComebackNotification(
          title: l.notifComebackTitle, body: l.notifComebackBody);
    } catch (e) {
      if (kDebugMode) debugPrint('HomeScreen: notification init error: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Uygulama ön plana geldi — comeback bildirimini iptal et
      try {
        ref
            .read(notificationServiceProvider)
            .cancelNotification(NotificationType.comeback);
      } catch (_) {}
    } else if (state == AppLifecycleState.paused) {
      // Uygulama arka plana geçti — comeback bildirimini yeniden planla
      try {
        final notif = ref.read(notificationServiceProvider);
        final l = ref.read(stringsProvider);
        notif.scheduleComebackNotification(
            title: l.notifComebackTitle, body: l.notifComebackBody);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
    // Renk körü prompt'u atla — Settings'ten erişilebilir
    if (!repo.getColorblindPromptShown()) {
      await repo.setColorblindPromptShown();
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
    _soundBank.onLevelComplete();
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
    final repo = ref.watch(localRepositoryProvider).valueOrNull;
    final gamesPlayed = repo?.getTotalGamesPlayed() ?? 0;
    final chefLocked = gamesPlayed < 3;
    final timeTrialLocked = gamesPlayed < 5;
    final glooPlus = ref.watch(appSettingsProvider).glooPlus;

    // Quick Play: son oynanan mod, gamesPlayed >= 3, kilitli değil
    GameMode? quickPlayMode;
    if (gamesPlayed >= 3 && repo != null) {
      final lastModeStr = repo.getLastPlayedMode();
      if (lastModeStr != null) {
        final candidate = GameMode.fromString(lastModeStr);
        final isLocked = switch (candidate) {
          GameMode.colorChef => chefLocked,
          GameMode.timeTrial => timeTrialLocked,
          GameMode.zen => !glooPlus,
          _ => false,
        };
        if (!isLocked) quickPlayMode = candidate;
      }
    }

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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StreakBadge(streak: streak, days: l.streakDays),
                            if (repo != null && !repo.hasStreakFreeze())
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: _StreakFreezeButton(repo: repo, l: l),
                              )
                            else if (repo != null && repo.hasStreakFreeze())
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Icon(
                                  Icons.ac_unit_rounded,
                                  color: kCyan.withValues(alpha: 0.7),
                                  size: 16,
                                ),
                              ),
                          ],
                        )
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
                              QuestBar(brightness: brightness)
                                  .animateOrSkip(reduceMotion: rm, delay: 70.ms)
                                  .fadeIn(duration: 350.ms)
                                  .slideY(
                                    begin: 0.08,
                                    end: 0,
                                    duration: 350.ms,
                                    curve: Curves.easeOutCubic,
                                  ),
                              const SizedBox(height: 8),
                              MetaGameBar(
                                islandLabel: l.islandLabel,
                                characterLabel: l.characterLabel,
                                seasonLabel: l.seasonLabel,
                              )
                                  .animateOrSkip(
                                      reduceMotion: rm, delay: 80.ms)
                                  .fadeIn(duration: 350.ms)
                                  .slideY(
                                    begin: 0.08,
                                    end: 0,
                                    duration: 350.ms,
                                    curve: Curves.easeOutCubic,
                                  ),
                              if (quickPlayMode != null) ...[
                                const SizedBox(height: 8),
                                Builder(builder: (context) {
                                  final qpMode = quickPlayMode!;
                                  return _QuickPlayBanner(
                                    mode: qpMode,
                                    l: l,
                                    brightness: brightness,
                                    onTap: () {
                                      _soundBank.onButtonTap();
                                      switch (qpMode) {
                                        case GameMode.level:
                                          context.go('/levels');
                                        case GameMode.duel:
                                          context.go('/pvp-lobby');
                                        default:
                                          context.go('/game/${qpMode.name}');
                                      }
                                    },
                                  );
                                })
                                    .animateOrSkip(
                                        reduceMotion: rm, delay: 90.ms)
                                    .fadeIn(duration: 350.ms)
                                    .slideY(
                                      begin: 0.08,
                                      end: 0,
                                      duration: 350.ms,
                                      curve: Curves.easeOutCubic,
                                    ),
                              ],
                              const SizedBox(height: 8),
                              _buildModeCardGrid(
                                context: context,
                                l: l,
                                brightness: brightness,
                                rm: rm,
                                screenWidth: screenWidth,
                                chefLocked: chefLocked,
                                timeTrialLocked: timeTrialLocked,
                                gamesPlayed: gamesPlayed,
                                glooPlus: glooPlus,
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      BottomBar(
                        leaderboardLabel: l.navLeaderboard,
                        shopLabel: l.navShop,
                        settingsLabel: l.navSettings,
                        collectionLabel: l.collectionTitle,
                      )
                          .animateOrSkip(reduceMotion: rm, delay: 500.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.2, end: 0, duration: 400.ms),
                      const SizedBox(height: 0),
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

  Widget _buildModeCardGrid({
    required BuildContext context,
    required AppStrings l,
    required Brightness brightness,
    required bool rm,
    required double screenWidth,
    required bool chefLocked,
    required bool timeTrialLocked,
    required int gamesPlayed,
    required bool glooPlus,
  }) {
    final columns = responsiveColumns(
      screenWidth,
      phone: 1,
      tablet: 2,
      desktop: 2,
    );

    // Each entry: the ModeCard widget + optional chip widget below it
    final cardItems = <Widget>[
      _ModeCardWithChip(
        card: ModeCard(
          label: l.modeClassicName,
          subtitle: l.modeClassicDesc,
          color: kColorClassic,
          icon: Icons.grid_view_rounded,
          isFeatured: true,
          badgeLabel: l.homeBadgeBeginning,
          onTap: () {
            _soundBank.onButtonTap();
            context.go('/game/${GameMode.classic.name}');
          },
        )
            .animateOrSkip(reduceMotion: rm, delay: 80.ms)
            .fadeIn(duration: 350.ms)
            .slideY(
              begin: 0.15,
              end: 0,
              duration: 350.ms,
              curve: Curves.easeOutCubic,
            ),
        chip: _ClassicScoreChip(l: l, brightness: brightness)
            .animateOrSkip(reduceMotion: rm, delay: 100.ms)
            .fadeIn(duration: 300.ms),
      ),
      _ModeCardWithChip(
        card: ModeCard(
          label: l.modeColorChefName,
          subtitle: l.modeColorChefDesc,
          color: kColorChef,
          icon: Icons.colorize_rounded,
          isLocked: chefLocked,
          lockLabel:
              chefLocked ? l.modeLockedGames(3 - gamesPlayed) : null,
          onTap: () {
            _soundBank.onButtonTap();
            if (!chefLocked) {
              context.go('/game/${GameMode.colorChef.name}');
            }
          },
        )
            .animateOrSkip(reduceMotion: rm, delay: 160.ms)
            .fadeIn(duration: 350.ms)
            .slideY(
              begin: 0.15,
              end: 0,
              duration: 350.ms,
              curve: Curves.easeOutCubic,
            ),
      ),
      _ModeCardWithChip(
        card: ModeCard(
          label: l.modeTimeTrialName,
          subtitle: l.modeTimeTrialDesc,
          color: kColorTimeTrial,
          icon: Icons.timer_rounded,
          isLocked: timeTrialLocked,
          lockLabel: timeTrialLocked
              ? l.modeLockedGames(5 - gamesPlayed)
              : null,
          onTap: () {
            _soundBank.onButtonTap();
            if (!timeTrialLocked) {
              context.go('/game/${GameMode.timeTrial.name}');
            }
          },
        )
            .animateOrSkip(reduceMotion: rm, delay: 240.ms)
            .fadeIn(duration: 350.ms)
            .slideY(
              begin: 0.15,
              end: 0,
              duration: 350.ms,
              curve: Curves.easeOutCubic,
            ),
      ),
      _ModeCardWithChip(
        card: ModeCard(
          label: l.modeZenName,
          subtitle: l.modeZenDesc,
          color: kColorZen,
          icon: Icons.spa_rounded,
          isLocked: !glooPlus,
          lockLabel: l.glooPlusTitle,
          onTap: () {
            _soundBank.onButtonTap();
            if (ref.read(appSettingsProvider).glooPlus) {
              context.go('/game/${GameMode.zen.name}');
            } else {
              context.push('/shop');
            }
          },
        )
            .animateOrSkip(reduceMotion: rm, delay: 320.ms)
            .fadeIn(duration: 350.ms)
            .slideY(
              begin: 0.15,
              end: 0,
              duration: 350.ms,
              curve: Curves.easeOutCubic,
            ),
      ),
      _ModeCardWithChip(
        card: ModeCard(
          label: l.modeLevelName,
          subtitle: l.modeLevelDesc,
          color: kOrange,
          icon: Icons.map_rounded,
          badgeLabel: l.newBadge,
          onTap: () {
            _soundBank.onButtonTap();
            context.go('/levels');
          },
        )
            .animateOrSkip(reduceMotion: rm, delay: 400.ms)
            .fadeIn(duration: 350.ms)
            .slideY(
              begin: 0.15,
              end: 0,
              duration: 350.ms,
              curve: Curves.easeOutCubic,
            ),
        chip: _LevelProgressChip(l: l, brightness: brightness),
      ),
      _ModeCardWithChip(
        card: ModeCard(
          label: l.modeDuelName,
          subtitle: l.modeDuelDesc,
          color: kColorClassic,
          icon: Icons.sports_mma_rounded,
          badgeLabel: l.newBadge,
          onTap: () {
            _soundBank.onButtonTap();
            context.go('/pvp-lobby');
          },
        )
            .animateOrSkip(reduceMotion: rm, delay: 480.ms)
            .fadeIn(duration: 350.ms)
            .slideY(
              begin: 0.15,
              end: 0,
              duration: 350.ms,
              curve: Curves.easeOutCubic,
            ),
        chip: _DuelEloChip(brightness: brightness),
      ),
    ];

    if (columns == 1) {
      return Column(
        children: [
          for (int i = 0; i < cardItems.length; i++) ...[
            cardItems[i],
            if (i < cardItems.length - 1) const SizedBox(height: 10),
          ],
        ],
      );
    }

    // 2-column layout: pair cards side by side
    final rows = <Widget>[];
    for (int i = 0; i < cardItems.length; i += 2) {
      final hasRight = i + 1 < cardItems.length;
      rows.add(
        // NOTE: IntrinsicHeight causes double layout pass. Monitor for jank on
        // tablet during staggered entry animation. If frame drops occur, replace
        // with ConstrainedBox(constraints: BoxConstraints(minHeight: kModeCardMinHeight)).
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cardItems[i]),
              const SizedBox(width: 12),
              Expanded(
                child: hasRight ? cardItems[i + 1] : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
      if (i + 2 < cardItems.length) rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }
}

// ─── ModeCard + chip wrapper ──────────────────────────────────────────────────

class _ModeCardWithChip extends StatelessWidget {
  const _ModeCardWithChip({required this.card, this.chip});

  final Widget card;
  final Widget? chip;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        card,
        if (chip != null) chip!,
      ],
    );
  }
}

// ─── Classic skor chip'i ──────────────────────────────────────────────────────

class _ClassicScoreChip extends ConsumerWidget {
  const _ClassicScoreChip({
    required this.l,
    required this.brightness,
  });

  final AppStrings l;
  final Brightness brightness;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastScore = ref.watch(lastScoreProvider('classic'));
    final highScore = ref.watch(highScoreProvider('classic')).valueOrNull ?? 0;

    if (lastScore == 0 && highScore == 0) return const SizedBox.shrink();

    final isNewBest = lastScore > 0 && highScore > 0 && lastScore >= highScore;
    final isSoClose = !isNewBest &&
        lastScore > 0 &&
        highScore > 0 &&
        lastScore >= highScore * 0.8;

    final textColor = resolveColor(
      brightness,
      dark: kMuted,
      light: kTextSecondaryLight,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (lastScore > 0) ...[
            Text(
              '${l.homeScoreLast}: ${_fmt(lastScore)}',
              style: AppTextStyles.caption.copyWith(
                color: isNewBest
                    ? kGold
                    : isSoClose
                        ? kAmber
                        : textColor,
              ),
            ),
          ],
          if (lastScore > 0 && highScore > 0)
            Text(
              '  ·  ',
              style: AppTextStyles.caption.copyWith(color: textColor),
            ),
          if (highScore > 0) ...[
            Text(
              '${l.homeScoreBest}: ${_fmt(highScore)}',
              style: AppTextStyles.caption.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (isNewBest) ...[
            const SizedBox(width: 6),
            Text(
              l.homeScoreNewBest,
              style: AppTextStyles.caption.copyWith(
                color: kGold,
                fontWeight: FontWeight.w700,
              ),
            ),
          ] else if (isSoClose) ...[
            const SizedBox(width: 6),
            Text(
              l.homeScoreBeatIt,
              style: AppTextStyles.caption.copyWith(
                color: kGold,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(int value) {
    if (value >= 1000) {
      return '${(value ~/ 1000)},${(value % 1000).toString().padLeft(3, '0')}';
    }
    return value.toString();
  }
}

// ─── Level progress chip ─────────────────────────────────────────────────────

class _LevelProgressChip extends ConsumerWidget {
  const _LevelProgressChip({
    required this.l,
    required this.brightness,
  });

  final AppStrings l;
  final Brightness brightness;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxLevel = ref.watch(maxCompletedLevelProvider).valueOrNull ?? 0;
    if (maxLevel == 0) return const SizedBox.shrink();

    final textColor = resolveColor(
      brightness,
      dark: kMuted,
      light: kTextSecondaryLight,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Text(
        '${l.levelLabel} $maxLevel/${LevelProgression.totalPredefinedLevels}',
        style: AppTextStyles.caption.copyWith(color: textColor),
      ),
    );
  }
}

// ─── Duel ELO chip ───────────────────────────────────────────────────────────

class _DuelEloChip extends ConsumerWidget {
  const _DuelEloChip({required this.brightness});

  final Brightness brightness;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elo = ref.watch(eloProvider).valueOrNull ?? 0;
    if (elo == 0) return const SizedBox.shrink();

    final textColor = resolveColor(
      brightness,
      dark: kMuted,
      light: kTextSecondaryLight,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Text(
        '$elo ELO',
        style: AppTextStyles.caption.copyWith(color: textColor),
      ),
    );
  }
}

// ─── Quick Play banner ────────────────────────────────────────────────────────

class _QuickPlayBanner extends StatelessWidget {
  const _QuickPlayBanner({
    required this.mode,
    required this.l,
    required this.brightness,
    required this.onTap,
  });

  final GameMode mode;
  final AppStrings l;
  final Brightness brightness;
  final VoidCallback onTap;

  String _modeName() => switch (mode) {
        GameMode.classic => l.modeClassicName,
        GameMode.colorChef => l.modeColorChefName,
        GameMode.timeTrial => l.modeTimeTrialName,
        GameMode.zen => l.modeZenName,
        GameMode.daily => l.dailyTitle,
        GameMode.level => l.modeLevelName,
        GameMode.duel => l.modeDuelName,
      };

  @override
  Widget build(BuildContext context) {
    final accentColor = kModeColors[mode] ?? kColorClassic;
    final bgColor = resolveColor(
      brightness,
      dark: kSurfaceDark,
      light: kCardBgLight,
    );
    final borderColor = resolveColor(
      brightness,
      dark: kCardBorderLight.withValues(alpha: 0.10),
      light: kCardBorderLight,
    );

    return Semantics(
      label: '${l.quickPlayLabel}: ${_modeName()}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.play_arrow_rounded, color: accentColor, size: 20),
              const SizedBox(width: 8),
              Text(
                l.quickPlayLabel,
                style: AppTextStyles.caption.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                ': ${_modeName()}',
                style: AppTextStyles.caption.copyWith(
                  color: resolveColor(
                    brightness,
                    dark: kMuted,
                    light: kTextSecondaryLight,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                directionalChevronIcon(Directionality.of(context)),
                color: accentColor.withValues(alpha: 0.7),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Streak Freeze buy button ─────────────────────────────────────────────────

class _StreakFreezeButton extends StatefulWidget {
  const _StreakFreezeButton({required this.repo, required this.l});

  final LocalRepository repo;
  final AppStrings l;

  @override
  State<_StreakFreezeButton> createState() => _StreakFreezeButtonState();
}

class _StreakFreezeButtonState extends State<_StreakFreezeButton> {
  bool _purchased = false;

  Future<void> _buy() async {
    final balance = await widget.repo.getGelOzu();
    if (balance < CurrencyCosts.streakFreeze) return;
    await widget.repo.saveGelOzu(balance - CurrencyCosts.streakFreeze);
    await widget.repo.setStreakFreeze(true);
    if (!mounted) return;
    setState(() => _purchased = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.l.streakFreezeLabel),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_purchased) {
      return Icon(
        Icons.ac_unit_rounded,
        color: kCyan.withValues(alpha: 0.7),
        size: 16,
      );
    }
    return Semantics(
      label: widget.l.streakFreezeBuy,
      button: true,
      child: GestureDetector(
        onTap: _buy,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: kCyan.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kCyan.withValues(alpha: 0.30)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.ac_unit_rounded, color: kCyan, size: 12),
              SizedBox(width: 4),
              Text(
                '100',
                style: TextStyle(
                  color: kCyan,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
