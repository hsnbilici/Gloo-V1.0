import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/layout/responsive.dart';
import '../../core/utils/motion_utils.dart';
import '../shared/glow_orb.dart';
import '../../providers/audio_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/user_provider.dart';

// ─── Onboarding ekranı (ilk açılışta bir kez gösterilir) ─────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;
  bool _analyticsEnabled = true;
  bool _colorBlindEnabled = false;

  static const _kTotalPages = 4;

  static const _kStepMeta = [
    (icon: Icons.grid_4x4_rounded, color: kColorClassic),
    (icon: Icons.bolt_rounded, color: kColorTimeTrial),
    (icon: Icons.palette_rounded, color: kColorChef),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final repo = await ref.read(localRepositoryProvider.future);
    await repo.setOnboardingDone();
    // Only persist consent/colorblind prefs if user reached the prefs page (GDPR)
    if (_page >= 3) {
      await repo.setAnalyticsEnabled(_analyticsEnabled);
      await repo.setConsentShown();
      await repo.setColorblindPromptShown();
      ref
          .read(appSettingsProvider.notifier)
          .setAnalyticsEnabled(enabled: _analyticsEnabled);
      ref.read(analyticsServiceProvider).setEnabled(_analyticsEnabled);
      if (_colorBlindEnabled) {
        ref.read(appSettingsProvider.notifier).setColorBlindMode(enabled: true);
      }
    }
    if (mounted) context.go('/');
  }

  void _next() {
    if (_page < _kTotalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(stringsProvider);

    final stepTitles = [
      l.onboardingStep1Title,
      l.onboardingStep2Title,
      l.onboardingStep3Title
    ];
    final stepDescs = [
      l.onboardingStep1Desc,
      l.onboardingStep2Desc,
      l.onboardingStep3Desc
    ];

    final isLast = _page == _kTotalPages - 1;
    final stepColor =
        _page < _kStepMeta.length ? _kStepMeta[_page].color : kCyan;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hPadding = responsiveHPadding(screenWidth);
    final brightness = Theme.of(context).brightness;
    final bgColor = resolveColor(brightness, dark: kBgDark, light: kBgLight);
    final textColor =
        resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    final surfaceColor = resolveColor(brightness,
        dark: Colors.white.withValues(alpha: 0.06), light: kCardBgLight);
    final borderColor = resolveColor(brightness,
        dark: Colors.white.withValues(alpha: 0.10), light: kCardBorderLight);
    final textSecondary = resolveColor(brightness,
        dark: Colors.white.withValues(alpha: 0.50), light: kTextSecondaryLight);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Dinamik arka plan parıltısı — aktif adım rengiyle değişir
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            top: -120,
            left:
                _page == 0 ? -80 : (_page == 1 ? 60 : (_page == 2 ? 200 : 40)),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: GlowOrb(
                key: ValueKey(_page),
                size: 380,
                color: stepColor,
                opacity: 0.13,
              ),
            ),
          ),
          const Positioned(
            bottom: -80,
            right: -60,
            child: GlowOrb(size: 220, color: kCyan, opacity: 0.06),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: responsiveMaxWidth(screenWidth)),
                child: Column(
                  children: [
                    // Üst bar: Gloo logosu + Geç butonu
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: hPadding, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            kAppName,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 5,
                            ),
                          ),
                          Semantics(
                            button: true,
                            label: l.onboardingSkip,
                            child: GestureDetector(
                              onTap: _finish,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(
                                      UIConstants.radiusXl),
                                  border: Border.all(color: borderColor),
                                ),
                                child: ExcludeSemantics(
                                  child: Text(
                                    l.onboardingSkip,
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Sayfa içeriği
                    Expanded(
                      child: Semantics(
                        label: '${_page + 1}/$_kTotalPages',
                        child: PageView.builder(
                          controller: _controller,
                          itemCount: _kTotalPages,
                          onPageChanged: (i) => setState(() => _page = i),
                          itemBuilder: (context, i) {
                            if (i < 3) {
                              return _StepPage(
                                stepIndex: i,
                                step: _StepData(
                                  icon: _kStepMeta[i].icon,
                                  color: _kStepMeta[i].color,
                                  title: stepTitles[i],
                                  desc: stepDescs[i],
                                ),
                              );
                            }
                            return _PrefsPage(
                              analyticsEnabled: _analyticsEnabled,
                              colorBlindEnabled: _colorBlindEnabled,
                              onAnalyticsChanged: (v) =>
                                  setState(() => _analyticsEnabled = v),
                              onColorBlindChanged: (v) =>
                                  setState(() => _colorBlindEnabled = v),
                              prefsTitle: l.settingsTitle,
                              consentTitle: l.consentTitle,
                              consentMessage: l.consentMessage,
                              colorblindTitle: l.colorblindDialogTitle,
                              colorblindMessage: l.colorblindDialogMessage,
                            );
                          },
                        ),
                      ),
                    ),
                    // Alt: nokta göstergesi + buton
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: hPadding,
                        vertical: 32,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Nokta göstergesi
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_kTotalPages, (i) {
                              final active = i == _page;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 280),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: active ? 22 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: active
                                      ? stepColor
                                      : resolveColor(brightness,
                                          dark: Colors.white
                                              .withValues(alpha: 0.20),
                                          light: kCardBorderLight),
                                  borderRadius: BorderRadius.circular(
                                      UIConstants.radiusXxs),
                                  boxShadow: active
                                      ? [
                                          BoxShadow(
                                            color: stepColor.withValues(
                                                alpha: 0.55),
                                            blurRadius: 8,
                                          )
                                        ]
                                      : null,
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 24),
                          // İlerleme butonu
                          Semantics(
                            button: true,
                            label:
                                isLast ? l.onboardingStart : l.onboardingNext,
                            child: GestureDetector(
                              onTap: _next,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 280),
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: stepColor.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(
                                      UIConstants.radiusTile),
                                  border: Border.all(
                                    color: stepColor.withValues(alpha: 0.55),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: stepColor.withValues(alpha: 0.18),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ExcludeSemantics(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        isLast
                                            ? l.onboardingStart
                                            : l.onboardingNext,
                                        style: TextStyle(
                                          color: stepColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        isLast
                                            ? Icons.play_arrow_rounded
                                            : Icons.arrow_forward_rounded,
                                        color: stepColor,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

// ─── Adım verisi ─────────────────────────────────────────────────────────────

class _StepData {
  const _StepData({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String desc;
}

// ─── Tercihler sayfası (4. adım) ─────────────────────────────────────────────

class _PrefsPage extends StatelessWidget {
  const _PrefsPage({
    required this.analyticsEnabled,
    required this.colorBlindEnabled,
    required this.onAnalyticsChanged,
    required this.onColorBlindChanged,
    required this.prefsTitle,
    required this.consentTitle,
    required this.consentMessage,
    required this.colorblindTitle,
    required this.colorblindMessage,
  });

  final bool analyticsEnabled;
  final bool colorBlindEnabled;
  final ValueChanged<bool> onAnalyticsChanged;
  final ValueChanged<bool> onColorBlindChanged;
  final String prefsTitle;
  final String consentTitle;
  final String consentMessage;
  final String colorblindTitle;
  final String colorblindMessage;

  @override
  Widget build(BuildContext context) {
    final hPadding = responsiveHPadding(MediaQuery.sizeOf(context).width);
    final brightness = Theme.of(context).brightness;
    final textColor =
        resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    final textSecondary = resolveColor(brightness,
        dark: Colors.white.withValues(alpha: 0.60), light: kTextSecondaryLight);
    final surfaceColor = resolveColor(brightness,
        dark: Colors.white.withValues(alpha: 0.06), light: kCardBgLight);
    final borderColor = resolveColor(brightness,
        dark: Colors.white.withValues(alpha: 0.10), light: kCardBorderLight);
    final rm = shouldReduceMotion(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kCyan.withValues(alpha: 0.10),
              border: Border.all(
                color: kCyan.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: kCyan.withValues(alpha: 0.22),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(Icons.tune_rounded, color: kCyan, size: 44),
          ).animateOrSkip(reduceMotion: rm).fadeIn(duration: 320.ms).scale(
                begin: const Offset(0.6, 0.6),
                duration: 380.ms,
                curve: Curves.easeOutBack,
              ),
          const SizedBox(height: 36),
          Text(
            prefsTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: kCyan.withValues(alpha: 0.45),
                  blurRadius: 20,
                ),
              ],
            ),
          )
              .animateOrSkip(reduceMotion: rm, delay: 80.ms)
              .fadeIn(duration: 280.ms),
          const SizedBox(height: 28),
          // Analytics toggle
          _PrefToggle(
            icon: Icons.analytics_outlined,
            color: kCyan,
            label: consentTitle,
            desc: consentMessage,
            value: analyticsEnabled,
            onChanged: onAnalyticsChanged,
            surfaceColor: surfaceColor,
            borderColor: borderColor,
            textColor: textColor,
            textSecondary: textSecondary,
          )
              .animateOrSkip(reduceMotion: rm, delay: 120.ms)
              .fadeIn(duration: 280.ms)
              .slideY(
                  begin: 0.08,
                  end: 0,
                  duration: 280.ms,
                  curve: Curves.easeOutCubic),
          const SizedBox(height: 12),
          // Colorblind toggle
          _PrefToggle(
            icon: Icons.visibility_rounded,
            color: kColorTimeTrial,
            label: colorblindTitle,
            desc: colorblindMessage,
            value: colorBlindEnabled,
            onChanged: onColorBlindChanged,
            surfaceColor: surfaceColor,
            borderColor: borderColor,
            textColor: textColor,
            textSecondary: textSecondary,
          )
              .animateOrSkip(reduceMotion: rm, delay: 200.ms)
              .fadeIn(duration: 280.ms)
              .slideY(
                  begin: 0.08,
                  end: 0,
                  duration: 280.ms,
                  curve: Curves.easeOutCubic),
        ],
      ),
    );
  }
}

class _PrefToggle extends StatelessWidget {
  const _PrefToggle({
    required this.icon,
    required this.color,
    required this.label,
    required this.desc,
    required this.value,
    required this.onChanged,
    required this.surfaceColor,
    required this.borderColor,
    required this.textColor,
    required this.textSecondary,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String desc;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color surfaceColor;
  final Color borderColor;
  final Color textColor;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(UIConstants.radiusMd),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 28,
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeTrackColor: color.withValues(alpha: 0.50),
              activeThumbColor: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tek adım sayfası ─────────────────────────────────────────────────────────

class _StepPage extends StatelessWidget {
  const _StepPage({required this.step, required this.stepIndex});

  final _StepData step;
  final int stepIndex;

  @override
  Widget build(BuildContext context) {
    final hPadding = responsiveHPadding(MediaQuery.sizeOf(context).width);
    final brightness = Theme.of(context).brightness;
    final textColor =
        resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    final textSecondary = resolveColor(brightness,
        dark: Colors.white.withValues(alpha: 0.60), light: kTextSecondaryLight);
    final rm = shouldReduceMotion(context);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          // Mini animated demo
          _MiniGridDemo(stepIndex: stepIndex, color: step.color)
              .animateOrSkip(reduceMotion: rm)
              .fadeIn(duration: 400.ms)
              .scale(
                begin: const Offset(0.85, 0.85),
                duration: 400.ms,
                curve: Curves.easeOutBack,
              ),
          const SizedBox(height: 28),
          // Başlık
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: step.color.withValues(alpha: 0.45),
                  blurRadius: 20,
                ),
              ],
            ),
          )
              .animateOrSkip(reduceMotion: rm, delay: 80.ms)
              .fadeIn(duration: 280.ms)
              .slideY(
                  begin: -0.08,
                  end: 0,
                  duration: 280.ms,
                  curve: Curves.easeOutCubic),
          const SizedBox(height: 16),
          // Açıklama
          Text(
            step.desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.55,
              letterSpacing: 0.1,
            ),
          )
              .animateOrSkip(reduceMotion: rm, delay: 160.ms)
              .fadeIn(duration: 300.ms)
              .slideY(
                  begin: 0.08,
                  end: 0,
                  duration: 300.ms,
                  curve: Curves.easeOutCubic),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Mini grid demo for onboarding steps ─────────────────────────────────────

class _MiniGridDemo extends StatefulWidget {
  const _MiniGridDemo({required this.stepIndex, required this.color});

  final int stepIndex;
  final Color color;

  @override
  State<_MiniGridDemo> createState() => _MiniGridDemoState();
}

class _MiniGridDemoState extends State<_MiniGridDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  static const _rows = 4;
  static const _cols = 4;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Step 0: cells appear one by one filling a row
  // Step 1: two rows flash in sequence (combo)
  // Step 2: two primary colors merge into a new color
  List<List<_DemoCell>> _buildGrid() {
    final grid = List.generate(
      _rows,
      (_) => List.generate(_cols, (_) => const _DemoCell(null, false)),
    );

    switch (widget.stepIndex) {
      case 0:
        // Bottom row fills progressively
        final progress = _ctrl.value;
        final filledCount = (progress * (_cols + 1)).floor().clamp(0, _cols);
        for (int c = 0; c < filledCount; c++) {
          grid[_rows - 1][c] = _DemoCell(widget.color, false);
        }
        // Show row clear flash when full
        if (filledCount >= _cols) {
          for (int c = 0; c < _cols; c++) {
            grid[_rows - 1][c] = _DemoCell(widget.color, true);
          }
        }
        // Some cells in other rows for context
        grid[1][0] = _DemoCell(kColorChef.withValues(alpha: 0.5), false);
        grid[2][1] = _DemoCell(kColorTimeTrial.withValues(alpha: 0.5), false);
        grid[2][3] = _DemoCell(kColorZen.withValues(alpha: 0.5), false);
      case 1:
        // Two rows showing combo flash in sequence
        final progress = _ctrl.value;
        final phase1 = (progress * 2).clamp(0.0, 1.0);
        final phase2 = ((progress - 0.5) * 2).clamp(0.0, 1.0);
        for (int c = 0; c < _cols; c++) {
          grid[_rows - 1][c] = _DemoCell(
            widget.color.withValues(alpha: phase1),
            phase1 > 0.8,
          );
          grid[_rows - 2][c] = _DemoCell(
            widget.color.withValues(alpha: phase2),
            phase2 > 0.8,
          );
        }
        // Static cells above
        grid[0][1] = _DemoCell(kColorClassic.withValues(alpha: 0.4), false);
        grid[1][0] = _DemoCell(kColorChef.withValues(alpha: 0.4), false);
        grid[1][2] = _DemoCell(kColorZen.withValues(alpha: 0.4), false);
      case 2:
        // Color synthesis: red + yellow → orange
        final progress = _ctrl.value;
        const red = Color(0xFFEF5350);
        const yellow = Color(0xFFFFEB3B);
        const orange = Color(0xFFFF9800);
        if (progress < 0.4) {
          // Show two primaries adjacent
          grid[1][1] = const _DemoCell(red, false);
          grid[1][2] = const _DemoCell(yellow, false);
        } else if (progress < 0.7) {
          // Merging — both glow
          grid[1][1] = const _DemoCell(red, true);
          grid[1][2] = const _DemoCell(yellow, true);
        } else {
          // Result — orange
          grid[1][1] = const _DemoCell(orange, false);
          grid[1][2] = const _DemoCell(orange, false);
        }
        // Context cells
        grid[2][0] = _DemoCell(kColorClassic.withValues(alpha: 0.3), false);
        grid[3][3] = _DemoCell(kColorTimeTrial.withValues(alpha: 0.3), false);
    }
    return grid;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final grid = _buildGrid();
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(UIConstants.radiusMd),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.20),
            ),
          ),
          child: SizedBox(
            width: 140,
            height: 140,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _cols,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
              ),
              itemCount: _rows * _cols,
              itemBuilder: (context, index) {
                final r = index ~/ _cols;
                final c = index % _cols;
                final cell = grid[r][c];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: cell.color ?? Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(4),
                    border: cell.isGlowing
                        ? Border.all(
                            color: Colors.white.withValues(alpha: 0.6),
                            width: 1.5,
                          )
                        : Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                            width: 0.5,
                          ),
                    boxShadow: cell.isGlowing
                        ? [
                            BoxShadow(
                              color: (cell.color ?? Colors.white)
                                  .withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _DemoCell {
  const _DemoCell(this.color, this.isGlowing);
  final Color? color;
  final bool isGlowing;
}
