import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../audio/audio_manager.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/utils/motion_utils.dart';
import '../../data/local/local_repository.dart';
import '../../data/remote/supabase_client.dart';
import '../../providers/theme_provider.dart';
import '../../services/ad_manager.dart';
import '../../services/consent_service.dart';
import '../../services/purchase_service.dart';
import '../shared/glow_orb.dart';
import 'breathing_letter.dart';
import 'loading_progress_bar.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen>
    with TickerProviderStateMixin {
  // ─── Breathing ───────────────────────────────────────────────────────────
  late final AnimationController _breathCtrl;

  // ─── Drop-in stagger ─────────────────────────────────────────────────────
  late final AnimationController _dropCtrl;
  static const _letterCount = 4;
  static const _staggerMs = 80;
  static const _dropDurationMs = 500;
  static const _totalDropMs =
      _dropDurationMs + (_letterCount - 1) * _staggerMs; // 740ms

  // ─── GlowOrb fade-in ────────────────────────────────────────────────────
  late final AnimationController _orbFadeCtrl;

  // ─── Line + progress bar fade-in ─────────────────────────────────────────
  late final AnimationController _lineFadeCtrl;

  // ─── Fake progress ───────────────────────────────────────────────────────
  late final AnimationController _progressCtrl;
  late final Animation<double> _progressAnim;
  late final AnimationController _finishCtrl;
  late final Animation<double> _finishAnim;

  bool _initDone = false;
  bool _navigated = false;
  LocalRepository? _repo;
  final Stopwatch _displayTimer = Stopwatch();

  static const _minDisplayMs = 2000;

  // ─── Letter config ───────────────────────────────────────────────────────
  static const _letters = [
    ('G', kCyan, 0.0),
    ('L', kGold, pi / 3),
    ('O', kPink, 2 * pi / 3),
    ('O', kCyan, pi),
  ];

  @override
  void initState() {
    super.initState();

    _breathCtrl = AnimationController(
      vsync: this,
      duration: AnimationDurations.breathCycle,
    )..repeat();

    _dropCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalDropMs),
    )..forward();

    _orbFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    _lineFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // 0 → 0.8 over 2 seconds
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _progressAnim = Tween<double>(begin: 0.0, end: 0.8).animate(
      CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut),
    );
    _progressCtrl.forward();

    // 0.8 → 1.0 in 300ms (triggered after init completes)
    _finishCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _finishAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _finishCtrl, curve: Curves.easeInOut),
    );
    _finishCtrl.addStatusListener(_onFinishComplete);

    _displayTimer.start();
    _runInit();
  }

  @override
  void dispose() {
    _finishCtrl.removeStatusListener(_onFinishComplete);
    _breathCtrl.dispose();
    _dropCtrl.dispose();
    _orbFadeCtrl.dispose();
    _lineFadeCtrl.dispose();
    _progressCtrl.dispose();
    _finishCtrl.dispose();
    super.dispose();
  }

  // ─── Init orchestration ──────────────────────────────────────────────────

  Future<void> _runInit() async {
    // UMP consent
    if (!kIsWeb) {
      try {
        await ConsentService().initialize();
      } catch (_) {}
    }

    // Parallel service init
    try {
      await Future.wait([
        SupabaseConfig.initialize(),
        AudioManager().initialize(),
        if (!kIsWeb) AdManager().initialize(),
        if (!kIsWeb) PurchaseService().initialize(),
      ]);
    } catch (_) {}

    // SharedPreferences + LocalRepository (tek instance)
    try {
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalRepository(prefs);
      _repo = repo;

      // IAP pending verifications + ad caps
      if (!kIsWeb) {
        await PurchaseService().loadPendingVerifications(repo);
        await PurchaseService().syncLocalProducts(repo);
        await AdManager().restoreDailyCaps(prefs);
      }

      // Theme + audio package
      final savedThemeMode = repo.getThemeMode();
      ref.read(themeModeProvider.notifier).setThemeMode(savedThemeMode);
      AudioManager().setAudioPackage(repo.getAudioPackage());
    } catch (_) {}

    _initDone = true;
    _tryFinish();
  }

  void _tryFinish() {
    if (!_initDone) return;

    // Wait for fake progress to reach 0.8
    if (_progressCtrl.isAnimating) {
      _progressCtrl.addStatusListener(_onProgressReady);
      return;
    }
    _startFinishAnimation();
  }

  void _onProgressReady(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _progressCtrl.removeStatusListener(_onProgressReady);
      _startFinishAnimation();
    }
  }

  void _startFinishAnimation() {
    // Ensure minimum display time
    final elapsed = _displayTimer.elapsedMilliseconds;
    if (elapsed < _minDisplayMs) {
      Future.delayed(
        Duration(milliseconds: _minDisplayMs - elapsed),
        () {
          if (mounted) _finishCtrl.forward();
        },
      );
    } else {
      _finishCtrl.forward();
    }
  }

  void _onFinishComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_navigated && mounted) {
      _navigated = true;
      final onboardingDone = _repo?.getOnboardingDone() ?? false;
      if (onboardingDone) {
        context.go('/');
      } else {
        context.go('/onboarding');
      }
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  double get _currentProgress {
    if (_finishCtrl.isAnimating || _finishCtrl.isCompleted) {
      return _finishAnim.value;
    }
    return _progressAnim.value;
  }

  @override
  Widget build(BuildContext context) {
    final rm = shouldReduceMotion(context);

    return Semantics(
      label: '$kAppName loading',
      child: Scaffold(
        backgroundColor: kBgDark,
        body: IgnorePointer(
          child: Stack(
            children: [
              // GlowOrb — top-left
              Positioned(
                top: -130,
                left: -80,
                child: rm
                    ? const GlowOrb(size: 280, color: kCyan, opacity: 0.07)
                    : FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _orbFadeCtrl,
                          curve: Curves.easeOut,
                        ),
                        child: const GlowOrb(
                          size: 280,
                          color: kCyan,
                          opacity: 0.07,
                        ),
                      ),
              ),
              // GlowOrb — bottom-right
              Positioned(
                bottom: -80,
                right: -60,
                child: rm
                    ? const GlowOrb(size: 280, color: kPink, opacity: 0.05)
                    : FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _orbFadeCtrl,
                          curve: Curves.easeOut,
                        ),
                        child: const GlowOrb(
                          size: 280,
                          color: kPink,
                          opacity: 0.05,
                        ),
                      ),
              ),
              // Center content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // GLOO letters
                    if (rm)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int i = 0; i < _letters.length; i++) ...[
                            if (i > 0) const SizedBox(width: 12),
                            BreathingLetter(
                              letter: _letters[i].$1,
                              color: _letters[i].$2,
                              phase: _letters[i].$3,
                              animate: false,
                            ),
                          ],
                        ],
                      )
                    else
                      AnimatedBuilder(
                        animation: Listenable.merge([_dropCtrl, _breathCtrl]),
                        builder: (_, __) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (int i = 0; i < _letters.length; i++) ...[
                                if (i > 0) const SizedBox(width: 12),
                                _buildDropLetter(i),
                              ],
                            ],
                          );
                        },
                      ),
                    // Decorative line — 20dp below letters
                    const SizedBox(height: 20),
                    if (rm)
                      Container(
                        width: 80,
                        height: 1.5,
                        decoration: BoxDecoration(
                          color: kGold.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      )
                    else
                      FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _lineFadeCtrl,
                          curve: Curves.easeOut,
                        ),
                        child: Container(
                          width: 80,
                          height: 1.5,
                          decoration: BoxDecoration(
                            color: kGold.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    // Progress bar — 28dp below line
                    const SizedBox(height: 28),
                    if (rm)
                      const LoadingProgressBar(progress: 1.0)
                    else
                      FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _lineFadeCtrl,
                          curve: Curves.easeOut,
                        ),
                        child: AnimatedBuilder(
                          animation:
                              Listenable.merge([_progressCtrl, _finishCtrl]),
                          builder: (_, __) {
                            return LoadingProgressBar(
                              progress: _currentProgress,
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropLetter(int index) {
    final (letter, color, phase) = _letters[index];

    // Calculate staggered progress for this letter
    final startFraction = (index * _staggerMs) / _totalDropMs;
    final endFraction =
        (index * _staggerMs + _dropDurationMs) / _totalDropMs;
    final t = ((_dropCtrl.value - startFraction) / (endFraction - startFraction))
        .clamp(0.0, 1.0);

    // easeOutBack curve
    final curved = Curves.easeOutBack.transform(t);

    final offsetY = -20.0 * (1.0 - curved);
    final alpha = curved.clamp(0.0, 1.0);

    return Opacity(
      opacity: alpha,
      child: Transform.translate(
        offset: Offset(0, offsetY),
        child: BreathingLetter(
          letter: letter,
          color: color,
          phase: phase,
          animate: t >= 1.0,
          breathController: _breathCtrl,
        ),
      ),
    );
  }
}
