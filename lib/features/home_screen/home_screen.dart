import 'dart:io' show Platform;

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/widgets/glow_orb.dart';
import '../../data/local/local_repository.dart';
import '../../game/world/game_world.dart';
import '../../providers/audio_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/analytics_service.dart';

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
      ref.read(audioSettingsProvider.notifier).setAnalyticsEnabled(enabled: analyticsEnabled);
      AnalyticsService().setEnabled(analyticsEnabled);
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
      builder: (ctx) => _ConsentDialog(
        title: l.consentTitle,
        message: l.consentMessage,
        acceptLabel: l.consentAccept,
        declineLabel: l.consentDecline,
      ),
    );
    final enabled = accepted == true;
    await repo.setAnalyticsEnabled(enabled);
    await repo.setConsentShown();
    ref.read(audioSettingsProvider.notifier).setAnalyticsEnabled(enabled: enabled);
    AnalyticsService().setEnabled(enabled);
    // ATT izni (iOS) — consent kabul edildiyse
    if (enabled) _requestATTIfNeeded();
    // Sonraki adım: renk körü prompt
    if (mounted && !repo.getColorblindPromptShown()) {
      _showColorblindDialog(repo);
    }
  }

  Future<void> _requestATTIfNeeded() async {
    if (kIsWeb) return;
    if (!Platform.isIOS) return;
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
      builder: (ctx) => _ColorblindPromptDialog(
        title: l.colorblindDialogTitle,
        message: l.colorblindDialogMessage,
        enableLabel: l.colorblindDialogEnable,
        skipLabel: l.colorblindDialogSkip,
        onEnable: () {
          ref.read(audioSettingsProvider.notifier).setColorBlindMode(enabled: true);
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
          const _DeepBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 52),
                  _GelLogo(subtitle: l.homeSubtitle)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(
                        begin: const Offset(0.85, 0.85),
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  if (streak >= 2) ...[
                    const SizedBox(height: 10),
                    _StreakBadge(streak: streak, days: l.streakDays)
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 400.ms)
                        .scale(
                          begin: const Offset(0.7, 0.7),
                          duration: 400.ms,
                          curve: Curves.easeOutBack,
                        ),
                  ],
                  const SizedBox(height: 14),
                  _DailyBanner(label: l.dailyTitle)
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
                          _ModeCard(
                            label: l.modeClassicName,
                            subtitle: l.modeClassicDesc,
                            color: kColorClassic,
                            icon: Icons.grid_view_rounded,
                            isFeatured: true,
                            badgeLabel: l.homeBadgeBeginning,
                            onTap: () => context.go('/game/${GameMode.classic.name}'),
                          ).animate(delay: 80.ms).fadeIn(duration: 350.ms).slideY(
                                begin: 0.15,
                                end: 0,
                                duration: 350.ms,
                                curve: Curves.easeOutCubic,
                              ),
                          const SizedBox(height: 10),
                          _ModeCard(
                            label: l.modeColorChefName,
                            subtitle: l.modeColorChefDesc,
                            color: kColorChef,
                            icon: Icons.colorize_rounded,
                            onTap: () => context.go('/game/${GameMode.colorChef.name}'),
                          ).animate(delay: 160.ms).fadeIn(duration: 350.ms).slideY(
                                begin: 0.15,
                                end: 0,
                                duration: 350.ms,
                                curve: Curves.easeOutCubic,
                              ),
                          const SizedBox(height: 10),
                          _ModeCard(
                            label: l.modeTimeTrialName,
                            subtitle: l.modeTimeTrialDesc,
                            color: kColorTimeTrial,
                            icon: Icons.timer_rounded,
                            onTap: () => context.go('/game/${GameMode.timeTrial.name}'),
                          ).animate(delay: 240.ms).fadeIn(duration: 350.ms).slideY(
                                begin: 0.15,
                                end: 0,
                                duration: 350.ms,
                                curve: Curves.easeOutCubic,
                              ),
                          const SizedBox(height: 10),
                          _ModeCard(
                            label: l.modeZenName,
                            subtitle: l.modeZenDesc,
                            color: kColorZen,
                            icon: Icons.spa_rounded,
                            isLocked: !ref.watch(audioSettingsProvider).glooPlus,
                            lockLabel: 'GLOO+',
                            onTap: () {
                              if (ref.read(audioSettingsProvider).glooPlus) {
                                context.go('/game/${GameMode.zen.name}');
                              } else {
                                context.push('/shop');
                              }
                            },
                          ).animate(delay: 320.ms).fadeIn(duration: 350.ms).slideY(
                                begin: 0.15,
                                end: 0,
                                duration: 350.ms,
                                curve: Curves.easeOutCubic,
                              ),
                          const SizedBox(height: 10),
                          // Faz 4: Seviye modu
                          _ModeCard(
                            label: l.modeLevelName,
                            subtitle: l.modeLevelDesc,
                            color: const Color(0xFFFF8C42),
                            icon: Icons.map_rounded,
                            badgeLabel: 'YENİ',
                            onTap: () => context.go('/levels'),
                          ).animate(delay: 400.ms).fadeIn(duration: 350.ms).slideY(
                                begin: 0.15,
                                end: 0,
                                duration: 350.ms,
                                curve: Curves.easeOutCubic,
                              ),
                          const SizedBox(height: 10),
                          // Faz 4: Düello modu
                          _ModeCard(
                            label: l.modeDuelName,
                            subtitle: l.modeDuelDesc,
                            color: const Color(0xFFFF4D6D),
                            icon: Icons.sports_mma_rounded,
                            badgeLabel: 'YENİ',
                            onTap: () => context.go('/pvp-lobby'),
                          ).animate(delay: 480.ms).fadeIn(duration: 350.ms).slideY(
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
                  _MetaGameBar()
                      .animate(delay: 540.ms)
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: 0.12, end: 0, duration: 350.ms),
                  const SizedBox(height: 8),
                  _BottomBar(
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

// ─── Derin arkaplan ───────────────────────────────────────────────────────────

class _DeepBackground extends StatelessWidget {
  const _DeepBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: kBgDark),
        // Sol-üst cyan orb
        const Positioned(
          top: -130,
          left: -80,
          child: GlowOrb(size: 380, color: kCyan, opacity: 0.09),
        ),
        // Sağ-alt coral orb
        const Positioned(
          bottom: -100,
          right: -60,
          child: GlowOrb(size: 300, color: kColorClassic, opacity: 0.08),
        ),
        // Orta-sağ violet orb
        const Positioned(
          top: 250,
          right: -50,
          child: GlowOrb(size: 220, color: kColorZen, opacity: 0.06),
        ),
      ],
    );
  }
}

// ─── Logo ─────────────────────────────────────────────────────────────────────

class _GelLogo extends StatelessWidget {
  const _GelLogo({required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
              height: 1,
            ),
            children: [
              TextSpan(
                text: 'Gl',
                style: TextStyle(
                  color: kCyan,
                  shadows: [
                    Shadow(color: kCyan.withValues(alpha: 0.8), blurRadius: 18),
                    Shadow(color: kCyan.withValues(alpha: 0.3), blurRadius: 45),
                  ],
                ),
              ),
              TextSpan(
                text: 'oo',
                style: TextStyle(
                  color: kColorClassic,
                  shadows: [
                    Shadow(color: kColorClassic.withValues(alpha: 0.8), blurRadius: 18),
                    Shadow(color: kColorClassic.withValues(alpha: 0.3), blurRadius: 45),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 28, height: 1, color: kMuted.withValues(alpha: 0.4)),
            const SizedBox(width: 10),
            Text(
              subtitle,
              style: const TextStyle(
                color: kMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 3.5,
              ),
            ),
            const SizedBox(width: 10),
            Container(width: 28, height: 1, color: kMuted.withValues(alpha: 0.4)),
          ],
        ),
      ],
    );
  }
}

// ─── Mod kartı ────────────────────────────────────────────────────────────────

class _ModeCard extends StatefulWidget {
  const _ModeCard({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
    this.isFeatured = false,
    this.badgeLabel,
    this.isLocked = false,
    this.lockLabel,
  });

  final String label;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final bool isFeatured;
  final String? badgeLabel;
  final bool isLocked;
  final String? lockLabel;

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      button: true,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(_pressed ? 0.97 : 1.0, _pressed ? 0.97 : 1.0, 1.0),
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: widget.isFeatured ? 18 : 13,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UIConstants.radiusLg),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: widget.isFeatured
                ? [
                    widget.color.withValues(alpha: _pressed ? 0.28 : 0.20),
                    widget.color.withValues(alpha: 0.08),
                    Colors.transparent,
                  ]
                : [
                    widget.color.withValues(alpha: _pressed ? 0.17 : 0.11),
                    widget.color.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
            stops: const [0.0, 0.35, 1.0],
          ),
          border: Border.all(
            color: widget.color.withValues(
              alpha: widget.isFeatured ? (_pressed ? 0.70 : 0.50) : (_pressed ? 0.38 : 0.22),
            ),
            width: widget.isFeatured ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: widget.isFeatured ? 0.18 : 0.07),
              blurRadius: widget.isFeatured ? 24 : 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: widget.isFeatured ? 50 : 44,
              height: widget.isFeatured ? 50 : 44,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: widget.isFeatured ? 0.20 : 0.12),
                borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                border: Border.all(
                  color: widget.color.withValues(alpha: widget.isFeatured ? 0.50 : 0.28),
                ),
              ),
              child: Icon(widget.icon, color: widget.color, size: widget.isFeatured ? 24 : 21),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widget.isFeatured ? 17 : 16,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(
                              color: widget.color.withValues(alpha: 0.35),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      if (widget.isFeatured && widget.badgeLabel != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                            border: Border.all(
                              color: widget.color.withValues(alpha: 0.45),
                            ),
                          ),
                          child: Text(
                            widget.badgeLabel!,
                            style: TextStyle(
                              color: widget.color,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      color: widget.isFeatured
                          ? Colors.white.withValues(alpha: 0.55)
                          : kMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.isLocked && widget.lockLabel != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                  border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.40)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_rounded, color: Color(0xFFFFD700), size: 10),
                    const SizedBox(width: 3),
                    Text(
                      widget.lockLabel!,
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Icon(
                Icons.chevron_right_rounded,
                color: widget.color.withValues(alpha: widget.isFeatured ? 0.80 : 0.55),
                size: widget.isFeatured ? 24 : 22,
              ),
          ],
        ),
      ),
      ),
    );
  }
}

// ─── Alt navigasyon çubuğu ────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.leaderboardLabel,
    required this.shopLabel,
    required this.settingsLabel,
    required this.collectionLabel,
  });

  final String leaderboardLabel;
  final String shopLabel;
  final String settingsLabel;
  final String collectionLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(UIConstants.radiusXl),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _BottomItem(
            icon: Icons.leaderboard_rounded,
            label: leaderboardLabel,
            onTap: () => context.push('/leaderboard'),
          ),
          Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.08)),
          _BottomItem(
            icon: Icons.collections_bookmark_rounded,
            label: collectionLabel,
            onTap: () => context.push('/collection'),
          ),
          Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.08)),
          _BottomItem(
            icon: Icons.storefront_rounded,
            label: shopLabel,
            onTap: () => context.push('/shop'),
          ),
          Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.08)),
          _BottomItem(
            icon: Icons.settings_rounded,
            label: settingsLabel,
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.60), size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.70),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

// ─── Günlük bulmaca banner'ı ──────────────────────────────────────────────────

class _DailyBanner extends ConsumerWidget {
  const _DailyBanner({required this.label});

  final String label;

  static const _kAccent = Color(0xFF00E5FF); // kCyan

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repoAsync = ref.watch(localRepositoryProvider);
    final completed = repoAsync.valueOrNull?.isDailyCompleted() ?? false;
    final score = repoAsync.valueOrNull?.getDailyScore() ?? 0;

    return GestureDetector(
      onTap: () => context.push('/daily'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UIConstants.radiusLg),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              _kAccent.withValues(alpha: 0.12),
              _kAccent.withValues(alpha: 0.03),
              Colors.transparent,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
          border: Border.all(color: _kAccent.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _kAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                border: Border.all(color: _kAccent.withValues(alpha: 0.30)),
              ),
              child: Icon(
                completed
                    ? Icons.check_circle_rounded
                    : Icons.calendar_today_rounded,
                color: completed ? kColorChef : _kAccent,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    completed
                        ? _fmt(score)
                        : _todayLabel(),
                    style: TextStyle(
                      color: completed
                          ? kColorChef
                          : Colors.white.withValues(alpha: 0.40),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: _kAccent.withValues(alpha: 0.60),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    final d = now.day.toString().padLeft(2, '0');
    final m = now.month.toString().padLeft(2, '0');
    return '$d.$m.${now.year}';
  }

  String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toString();
  }
}

// ─── Streak rozeti ────────────────────────────────────────────────────────────

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak, required this.days});

  final int streak;
  final String days;

  static const _kFire = Color(0xFFFF8C42);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _kFire.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kFire.withValues(alpha: 0.30)),
        boxShadow: [
          BoxShadow(color: _kFire.withValues(alpha: 0.14), blurRadius: 14),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: _kFire,
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            '$streak $days',
            style: const TextStyle(
              color: _kFire,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Meta-Game Hızlı Erişim Çubuğu ──────────────────────────────────────────

class _MetaGameBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(UIConstants.radiusLg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _MetaItem(
            icon: Icons.terrain_rounded,
            label: 'Ada',
            color: const Color(0xFF3CFF8B),
            onTap: () => context.push('/island'),
          ),
          Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.06)),
          _MetaItem(
            icon: Icons.person_rounded,
            label: 'Karakter',
            color: const Color(0xFFB080FF),
            onTap: () => context.push('/character'),
          ),
          Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.06)),
          _MetaItem(
            icon: Icons.military_tech_rounded,
            label: 'Sezon',
            color: const Color(0xFFFFD700),
            onTap: () => context.push('/season-pass'),
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.80),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Renk körü modu ilk açılış dialog'u ───────────────────────────────────────

class _ColorblindPromptDialog extends StatelessWidget {
  const _ColorblindPromptDialog({
    required this.title,
    required this.message,
    required this.enableLabel,
    required this.skipLabel,
    required this.onEnable,
    required this.onSkip,
  });

  final String title;
  final String message;
  final String enableLabel;
  final String skipLabel;
  final VoidCallback onEnable;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: kBgDark,
          borderRadius: BorderRadius.circular(UIConstants.radiusXxl),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.60),
              blurRadius: 48,
              spreadRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: kColorTimeTrial.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(color: kColorTimeTrial.withValues(alpha: 0.30)),
              ),
              child: const Icon(
                Icons.visibility_rounded,
                color: kColorTimeTrial,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.60),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _DialogBtn(
              label: enableLabel,
              color: kColorTimeTrial,
              filled: true,
              onTap: onEnable,
            ),
            const SizedBox(height: 10),
            _DialogBtn(
              label: skipLabel,
              color: kMuted,
              filled: false,
              onTap: onSkip,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsentDialog extends StatelessWidget {
  const _ConsentDialog({
    required this.title,
    required this.message,
    required this.acceptLabel,
    required this.declineLabel,
  });

  final String title;
  final String message;
  final String acceptLabel;
  final String declineLabel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: kBgDark,
          borderRadius: BorderRadius.circular(UIConstants.radiusXxl),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.60),
              blurRadius: 48,
              spreadRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: kCyan.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(color: kCyan.withValues(alpha: 0.30)),
              ),
              child: const Icon(
                Icons.analytics_outlined,
                color: kCyan,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.60),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _DialogBtn(
              label: acceptLabel,
              color: kCyan,
              filled: true,
              onTap: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 10),
            _DialogBtn(
              label: declineLabel,
              color: kMuted,
              filled: false,
              onTap: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogBtn extends StatelessWidget {
  const _DialogBtn({
    required this.label,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: filled ? color.withValues(alpha: 0.13) : Colors.transparent,
          borderRadius: BorderRadius.circular(UIConstants.radiusTile),
          border: Border.all(
            color: filled
                ? color.withValues(alpha: 0.50)
                : Colors.white.withValues(alpha: 0.08),
            width: filled ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: filled ? color : color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
