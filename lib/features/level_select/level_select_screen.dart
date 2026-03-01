import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../shared/glow_orb.dart';
import '../../game/levels/level_progression.dart';
import '../../providers/user_provider.dart';

// ─── Seviye Secim Ekrani ─────────────────────────────────────────────────────

class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

  static const _kAccent = Color(0xFFFF8C42);
  static const _kCompleted = Color(0xFF3CFF8B);
  static const _kLocked = Color(0xFF2A2A4E);

  static const _kSectionNames = [
    'Jel Vadisi',
    'Buzlu Alanlar',
    'Tas Labirent',
    'Renk Bahcesi',
    'Karanlik Mahzen',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repoAsync = ref.watch(localRepositoryProvider);
    final completedLevels =
        repoAsync.valueOrNull?.getCompletedLevels() ?? <int>{};
    final maxCompleted = repoAsync.valueOrNull?.getMaxCompletedLevel() ?? 0;
    final totalLevels = LevelProgression.totalPredefinedLevels;

    return Scaffold(
      backgroundColor: kBgDark,
      body: Stack(
        children: [
          // Arkaplan
          const _LevelSelectBackground(),
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
                      Expanded(
                        child: Text(
                          'SEVIYELER',
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
                      ),
                      // Ilerleme
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
                          '${completedLevels.length}/$totalLevels',
                          style: const TextStyle(
                            color: _kAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: -0.1, end: 0, duration: 300.ms),
                const SizedBox(height: 16),
                // Seviye gridi
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: (totalLevels / 10).ceil(),
                    itemBuilder: (context, sectionIndex) {
                      final startLevel = sectionIndex * 10 + 1;
                      final endLevel = (startLevel + 9).clamp(1, totalLevels);
                      final sectionName = sectionIndex < _kSectionNames.length
                          ? _kSectionNames[sectionIndex]
                          : 'Bolum ${sectionIndex + 1}';

                      return _LevelSection(
                        sectionName: sectionName,
                        startLevel: startLevel,
                        endLevel: endLevel,
                        completedLevels: completedLevels,
                        maxCompleted: maxCompleted,
                        repo: repoAsync.valueOrNull,
                        delay: Duration(milliseconds: 100 * sectionIndex),
                      );
                    },
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

// ─── Bolum widget'i ─────────────────────────────────────────────────────────

class _LevelSection extends StatelessWidget {
  const _LevelSection({
    required this.sectionName,
    required this.startLevel,
    required this.endLevel,
    required this.completedLevels,
    required this.maxCompleted,
    required this.repo,
    required this.delay,
  });

  final String sectionName;
  final int startLevel;
  final int endLevel;
  final Set<int> completedLevels;
  final int maxCompleted;
  final dynamic repo;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bolum baslik
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 8),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: LevelSelectScreen._kAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                sectionName,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        )
            .animate(delay: delay)
            .fadeIn(duration: 300.ms)
            .slideX(begin: -0.1, end: 0, duration: 300.ms),
        // 5 sutun grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: endLevel - startLevel + 1,
          itemBuilder: (context, index) {
            final levelId = startLevel + index;
            final isCompleted = completedLevels.contains(levelId);
            final isUnlocked = levelId <= maxCompleted + 1;
            final score = repo?.getLevelScore(levelId);

            return _LevelCell(
              levelId: levelId,
              isCompleted: isCompleted,
              isUnlocked: isUnlocked,
              score: score,
              delay: delay + Duration(milliseconds: 30 * index),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─── Tek seviye hucresi ─────────────────────────────────────────────────────

class _LevelCell extends StatefulWidget {
  const _LevelCell({
    required this.levelId,
    required this.isCompleted,
    required this.isUnlocked,
    required this.score,
    required this.delay,
  });

  final int levelId;
  final bool isCompleted;
  final bool isUnlocked;
  final int? score;
  final Duration delay;

  @override
  State<_LevelCell> createState() => _LevelCellState();
}

class _LevelCellState extends State<_LevelCell> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.isCompleted;
    final isUnlocked = widget.isUnlocked;

    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isCompleted) {
      bgColor = LevelSelectScreen._kCompleted.withValues(alpha: 0.15);
      borderColor = LevelSelectScreen._kCompleted.withValues(alpha: 0.55);
      textColor = LevelSelectScreen._kCompleted;
    } else if (isUnlocked) {
      bgColor = LevelSelectScreen._kAccent.withValues(alpha: 0.12);
      borderColor = LevelSelectScreen._kAccent.withValues(alpha: 0.50);
      textColor = Colors.white;
    } else {
      bgColor = LevelSelectScreen._kLocked.withValues(alpha: 0.30);
      borderColor = Colors.white.withValues(alpha: 0.06);
      textColor = Colors.white.withValues(alpha: 0.25);
    }

    return GestureDetector(
      onTap:
          isUnlocked ? () => context.go('/game/level/${widget.levelId}') : null,
      onTapDown: isUnlocked ? (_) => setState(() => _pressed = true) : null,
      onTapUp: isUnlocked ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: isUnlocked ? () => setState(() => _pressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.diagonal3Values(
            _pressed ? 0.92 : 1.0, _pressed ? 0.92 : 1.0, 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(UIConstants.radiusMd),
          border: Border.all(color: borderColor, width: isCompleted ? 1.5 : 1),
          boxShadow: isCompleted
              ? [
                  BoxShadow(
                    color:
                        LevelSelectScreen._kCompleted.withValues(alpha: 0.15),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              Icon(Icons.lock_rounded,
                  color: Colors.white.withValues(alpha: 0.20), size: 16)
            else ...[
              Text(
                '${widget.levelId}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (isCompleted && widget.score != null) ...[
                const SizedBox(height: 2),
                Text(
                  _fmtScore(widget.score!),
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.65),
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    ).animate(delay: widget.delay).fadeIn(duration: 200.ms).scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 200.ms,
          curve: Curves.easeOutBack,
        );
  }

  String _fmtScore(int v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }
}

// ─── Arkaplan ───────────────────────────────────────────────────────────────

class _LevelSelectBackground extends StatelessWidget {
  const _LevelSelectBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: kBgDark),
        const Positioned(
          top: -100,
          right: -60,
          child: GlowOrb(
              size: 340, color: LevelSelectScreen._kAccent, opacity: 0.08),
        ),
        const Positioned(
          bottom: -80,
          left: -40,
          child: GlowOrb(
              size: 260, color: LevelSelectScreen._kCompleted, opacity: 0.06),
        ),
      ],
    );
  }
}
