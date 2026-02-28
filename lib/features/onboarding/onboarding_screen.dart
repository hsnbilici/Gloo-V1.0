import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/widgets/glow_orb.dart';
import '../../providers/locale_provider.dart';
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

  static const _kTotalPages = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final repo = await ref.read(localRepositoryProvider.future);
    await repo.setOnboardingDone();
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

    final steps = [
      _StepData(
        icon: Icons.grid_4x4_rounded,
        color: kColorClassic,
        title: l.onboardingStep1Title,
        desc: l.onboardingStep1Desc,
      ),
      _StepData(
        icon: Icons.bolt_rounded,
        color: kColorTimeTrial,
        title: l.onboardingStep2Title,
        desc: l.onboardingStep2Desc,
      ),
      _StepData(
        icon: Icons.palette_rounded,
        color: kColorChef,
        title: l.onboardingStep3Title,
        desc: l.onboardingStep3Desc,
      ),
    ];

    final isLast = _page == _kTotalPages - 1;
    final stepColor = steps[_page].color;

    return Scaffold(
      backgroundColor: kBgDark,
      body: Stack(
        children: [
          // Dinamik arka plan parıltısı — aktif adım rengiyle değişir
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            top: -120,
            left: _page == 0 ? -80 : (_page == 1 ? 60 : 200),
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
            child: Column(
              children: [
                // Üst bar: Gloo logosu + Geç butonu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'GLOO',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.90),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 5,
                        ),
                      ),
                      GestureDetector(
                        onTap: _finish,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius:
                                BorderRadius.circular(UIConstants.radiusXl),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                            ),
                          ),
                          child: Text(
                            l.onboardingSkip,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.50),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Sayfa içeriği
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _kTotalPages,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (context, i) => _StepPage(step: steps[i]),
                  ),
                ),
                // Alt: nokta göstergesi + buton
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
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
                                  : Colors.white.withValues(alpha: 0.20),
                              borderRadius:
                                  BorderRadius.circular(UIConstants.radiusXxs),
                              boxShadow: active
                                  ? [
                                      BoxShadow(
                                        color:
                                            stepColor.withValues(alpha: 0.55),
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
                      GestureDetector(
                        onTap: _next,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: stepColor.withValues(alpha: 0.14),
                            borderRadius:
                                BorderRadius.circular(UIConstants.radiusTile),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLast ? l.onboardingStart : l.onboardingNext,
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
                    ],
                  ),
                ),
              ],
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

// ─── Tek adım sayfası ─────────────────────────────────────────────────────────

class _StepPage extends StatelessWidget {
  const _StepPage({required this.step});

  final _StepData step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Büyük ikon dairesi
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: step.color.withValues(alpha: 0.10),
              border: Border.all(
                color: step.color.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: step.color.withValues(alpha: 0.22),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(step.icon, color: step.color, size: 44),
          )
              .animate()
              .fadeIn(duration: 320.ms)
              .scale(
                begin: const Offset(0.6, 0.6),
                duration: 380.ms,
                curve: Curves.easeOutBack,
              ),
          const SizedBox(height: 36),
          // Başlık
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
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
              .animate(delay: 80.ms)
              .fadeIn(duration: 280.ms)
              .slideY(begin: -0.08, end: 0, duration: 280.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 16),
          // Açıklama
          Text(
            step.desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.60),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.55,
              letterSpacing: 0.1,
            ),
          )
              .animate(delay: 160.ms)
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.08, end: 0, duration: 300.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }
}
