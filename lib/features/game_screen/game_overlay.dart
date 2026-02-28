import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/game_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../game/world/game_world.dart';
import '../../providers/game_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/pvp_provider.dart';

class GameOverlay extends ConsumerWidget {
  const GameOverlay({super.key, required this.game, required this.mode});

  final GlooGame game;
  final GameMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider(mode));
    final l = ref.watch(stringsProvider);

    final modeLabel = switch (mode) {
      GameMode.classic   => l.modeLabelClassic,
      GameMode.colorChef => l.modeLabelColorChef,
      GameMode.timeTrial => l.modeLabelTimeTrial,
      GameMode.zen       => l.modeLabelZen,
      GameMode.daily     => l.modeLabelDaily,
      GameMode.level     => 'Seviye',
      GameMode.duel      => 'Düello',
    };
    final modeColor = switch (mode) {
      GameMode.classic   => kColorClassic,
      GameMode.colorChef => kColorChef,
      GameMode.timeTrial => kColorTimeTrial,
      GameMode.zen       => kColorZen,
      GameMode.daily     => kCyan,
      GameMode.level     => kColorChef,
      GameMode.duel      => kColorClassic,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Zen modunda sayısal skor yerine ambiyans göstergesi
              if (mode == GameMode.zen)
                _ZenScoreIndicator(color: modeColor, score: gameState.score)
              else
                _ScoreDisplay(score: gameState.score, label: l.scoreLabel),
              _ModeLabel(label: modeLabel, color: modeColor),
              _PauseButton(
                semanticLabel: l.pauseTitle,
                onTap: () {
                  game.pauseGame();
                  _showPauseDialog(context, game, l.pauseTitle, l.pauseResume, l.pauseHome);
                },
              ),
            ],
          ),
        ),
        // Klasik ve Günlük modda ızgara doluluk çubuğu — ne zaman biteceğini gösterir
        if (mode == GameMode.classic || mode == GameMode.daily)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
            child: _FillBar(
              filledCells: gameState.filledCells,
              totalCells: game.gridManager.totalCells,
            ),
          ),
        // Time Trial modunda geri sayım çubuğu
        if (mode == GameMode.timeTrial)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
            child: _CountdownBar(
              remainingSeconds: gameState.remainingSeconds,
              totalSeconds: GameConstants.timeTrialDuration,
            ),
          ),
        // Color Chef modunda hedef ilerleme çubuğu
        if (mode == GameMode.colorChef)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
            child: _ChefTargetBar(
              targetColor: game.currentChefLevel?.targetColor,
              progress: gameState.chefProgress,
              required: gameState.chefRequired,
              levelIndex: game.chefLevelIndex,
            ),
          ),
        // Zen modunda ambiyans çubuğu — baskısız, sakin tasarım
        if (mode == GameMode.zen)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
            child: _ZenAmbienceBar(
              filledCells: gameState.filledCells,
              totalCells: game.gridManager.totalCells,
              color: modeColor,
            ),
          ),
        // Duel modunda geri sayım + rakip skoru
        if (mode == GameMode.duel)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
            child: _DuelHud(
              remainingSeconds: gameState.remainingSeconds,
              ref: ref,
            ),
          ),
      ],
    );
  }

  void _showPauseDialog(
    BuildContext context,
    GlooGame game,
    String title,
    String resumeLabel,
    String homeLabel,
  ) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 260),
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      ),
      pageBuilder: (ctx, _, __) => _PauseDialog(
        title: title,
        resumeLabel: resumeLabel,
        homeLabel: homeLabel,
        onResume: () {
          Navigator.pop(ctx);
          game.resumeGame();
        },
        onHome: () {
          Navigator.pop(ctx);
          context.go('/');
        },
      ),
    );
  }
}

// ─── Color Chef hedef çubuğu ─────────────────────────────────────────────────

class _ChefTargetBar extends StatelessWidget {
  const _ChefTargetBar({
    required this.targetColor,
    required this.progress,
    required this.required,
    required this.levelIndex,
  });

  final GelColor? targetColor;
  final int progress;
  final int required;
  final int levelIndex;

  @override
  Widget build(BuildContext context) {
    if (targetColor == null) return const SizedBox.shrink();

    final color = targetColor!.displayColor;
    final ratio = required > 0 ? (progress / required).clamp(0.0, 1.0) : 0.0;
    final levelNumber = levelIndex + 1;

    return Row(
      children: [
        // Hedef renk damlası
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 6),
            ],
          ),
        ),
        const SizedBox(width: 6),
        // İlerleme çubuğu
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(UIConstants.radiusXs),
            child: Stack(
              children: [
                Container(height: 4, color: Colors.white.withValues(alpha: 0.07)),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  widthFactor: ratio,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.65),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // İlerleme sayısı + seviye
        RichText(
          text: TextSpan(
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
            children: [
              TextSpan(
                text: '$progress/$required',
                style: TextStyle(color: color, letterSpacing: 0.5),
              ),
              TextSpan(
                text: '  S.$levelNumber',
                style: TextStyle(
                  color: color.withValues(alpha: 0.55),
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Doluluk çubuğu ─────────────────────────────────────────────────────────

class _FillBar extends StatelessWidget {
  const _FillBar({required this.filledCells, required this.totalCells});

  final int filledCells;
  final int totalCells;

  @override
  Widget build(BuildContext context) {
    final ratio = totalCells > 0 ? (filledCells / totalCells).clamp(0.0, 1.0) : 0.0;

    final Color barColor;
    if (ratio > 0.80) {
      barColor = kColorClassic; // kırmızı — kritik
    } else if (ratio > 0.58) {
      barColor = kColorTimeTrial; // sarı — uyarı
    } else {
      barColor = kCyan; // cyan — güvenli
    }

    final pct = (ratio * 100).round();

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(UIConstants.radiusXs),
            child: Stack(
              children: [
                // Track
                Container(
                  height: 4,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
                // Fill
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: barColor,
                      boxShadow: ratio > 0.58
                          ? [
                              BoxShadow(
                                color: barColor.withValues(alpha: 0.7),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$pct%',
          style: TextStyle(
            color: barColor,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ─── Geri sayım çubuğu (Time Trial) ──────────────────────────────────────────

class _CountdownBar extends StatelessWidget {
  const _CountdownBar({
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  final int remainingSeconds;
  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    final ratio = totalSeconds > 0
        ? (remainingSeconds / totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    final Color barColor;
    final bool isPulsing;
    if (remainingSeconds <= 10) {
      barColor = kColorClassic; // kırmızı — kritik
      isPulsing = true;
    } else if (remainingSeconds <= 30) {
      barColor = kColorTimeTrial; // sarı — uyarı
      isPulsing = false;
    } else {
      barColor = kCyan; // cyan — güvenli
      isPulsing = false;
    }

    final mins = remainingSeconds ~/ 60;
    final secs = remainingSeconds % 60;
    final timeLabel = mins > 0
        ? '$mins:${secs.toString().padLeft(2, '0')}'
        : '$remainingSeconds';

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(UIConstants.radiusXs),
            child: Stack(
              children: [
                Container(
                  height: 4,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.linear,
                    height: 4,
                    decoration: BoxDecoration(
                      color: barColor,
                      boxShadow: [
                        BoxShadow(
                          color: barColor.withValues(alpha: isPulsing ? 0.90 : 0.60),
                          blurRadius: isPulsing ? 10 : 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: barColor,
            fontSize: isPulsing ? 13 : 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
          child: Text(timeLabel),
        ),
      ],
    );
  }
}

// ─── Skor ────────────────────────────────────────────────────────────────────

class _ScoreDisplay extends StatelessWidget {
  const _ScoreDisplay({required this.score, required this.label});

  final int score;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: kMuted,
            fontSize: 11,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          _format(score),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1,
            shadows: [
              Shadow(color: Color(0x4400E5FF), blurRadius: 12),
            ],
          ),
        ),
      ],
    );
  }

  String _format(int s) {
    if (s >= 1000000) return '${(s / 1000000).toStringAsFixed(1)}M';
    if (s >= 1000) return '${(s / 1000).toStringAsFixed(1)}K';
    return s.toString();
  }
}

// ─── Mod etiketi ─────────────────────────────────────────────────────────────

class _ModeLabel extends StatelessWidget {
  const _ModeLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(UIConstants.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          letterSpacing: 2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Duraklat butonu ─────────────────────────────────────────────────────────

class _PauseButton extends StatelessWidget {
  const _PauseButton({required this.onTap, required this.semanticLabel});
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(UIConstants.radiusSm),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
          ),
          child: Icon(
            Icons.pause_rounded,
            color: Colors.white.withValues(alpha: 0.90),
            size: 20,
          ),
        ),
      ),
    );
  }
}

// ─── Zen ambiyans göstergesi (skor yerine) ───────────────────────────────────

class _ZenScoreIndicator extends StatelessWidget {
  const _ZenScoreIndicator({required this.color, required this.score});

  final Color color;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HUZUR',
          style: TextStyle(
            color: color.withValues(alpha: 0.60),
            fontSize: 11,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 1),
        Row(
          children: [
            Icon(Icons.self_improvement_rounded, color: color, size: 22),
            const SizedBox(width: 4),
            Text(
              _format(score),
              style: TextStyle(
                color: color.withValues(alpha: 0.75),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _format(int s) {
    if (s >= 1000) return '${(s / 1000).toStringAsFixed(1)}K';
    return s.toString();
  }
}

// ─── Zen ambiyans çubuğu ─────────────────────────────────────────────────────

class _ZenAmbienceBar extends StatelessWidget {
  const _ZenAmbienceBar({
    required this.filledCells,
    required this.totalCells,
    required this.color,
  });

  final int filledCells;
  final int totalCells;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = totalCells > 0 ? (filledCells / totalCells).clamp(0.0, 1.0) : 0.0;

    return Row(
      children: [
        Icon(Icons.water_drop_outlined, color: color.withValues(alpha: 0.55), size: 12),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(UIConstants.radiusXs),
            child: Stack(
              children: [
                Container(height: 3, color: Colors.white.withValues(alpha: 0.05)),
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.55),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 4,
                        ),
                      ],
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

// ─── Pause dialog ─────────────────────────────────────────────────────────────

class _PauseDialog extends StatelessWidget {
  const _PauseDialog({
    required this.title,
    required this.resumeLabel,
    required this.homeLabel,
    required this.onResume,
    required this.onHome,
  });

  final String title;
  final String resumeLabel;
  final String homeLabel;
  final VoidCallback onResume;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onResume();
      },
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: kBgDark,
              borderRadius: BorderRadius.circular(UIConstants.radiusXxl),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
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
                    border: Border.all(color: kCyan.withValues(alpha: 0.28)),
                  ),
                  child: const Icon(Icons.pause_rounded, color: kCyan, size: 24),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 28),
                _PauseBtn(
                  label: resumeLabel,
                  icon: Icons.play_arrow_rounded,
                  color: kCyan,
                  filled: true,
                  onTap: onResume,
                ),
                const SizedBox(height: 10),
                _PauseBtn(
                  label: homeLabel,
                  icon: Icons.home_rounded,
                  color: kMuted,
                  filled: false,
                  onTap: onHome,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PauseBtn extends StatefulWidget {
  const _PauseBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  @override
  State<_PauseBtn> createState() => _PauseBtnState();
}

class _PauseBtnState extends State<_PauseBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(_pressed ? 0.97 : 1.0, _pressed ? 0.97 : 1.0, 1.0),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: widget.filled
              ? widget.color.withValues(alpha: _pressed ? 0.20 : 0.13)
              : Colors.white.withValues(alpha: _pressed ? 0.07 : 0.03),
          borderRadius: BorderRadius.circular(UIConstants.radiusTile),
          border: Border.all(
            color: widget.filled
                ? widget.color.withValues(alpha: _pressed ? 0.70 : 0.50)
                : Colors.white.withValues(alpha: _pressed ? 0.16 : 0.09),
            width: widget.filled ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: widget.color, size: 18),
            const SizedBox(width: 10),
            Text(
              widget.label,
              style: TextStyle(
                color: widget.color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Duel HUD: geri sayım + rakip skoru ─────────────────────────────────────

class _DuelHud extends StatelessWidget {
  const _DuelHud({
    required this.remainingSeconds,
    required this.ref,
  });

  final int remainingSeconds;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final duelState = ref.watch(duelProvider);
    const duelColor = Color(0xFFFF4D6D);
    const duelDuration = 120;

    final ratio = (remainingSeconds / duelDuration).clamp(0.0, 1.0);

    final Color barColor;
    final bool isPulsing;
    if (remainingSeconds <= 10) {
      barColor = kColorClassic;
      isPulsing = true;
    } else if (remainingSeconds <= 30) {
      barColor = kColorTimeTrial;
      isPulsing = false;
    } else {
      barColor = duelColor;
      isPulsing = false;
    }

    final mins = remainingSeconds ~/ 60;
    final secs = remainingSeconds % 60;
    final timeLabel = '$mins:${secs.toString().padLeft(2, '0')}';

    return Column(
      children: [
        // Geri sayım çubuğu
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(UIConstants.radiusXs),
                child: Stack(
                  children: [
                    Container(
                      height: 4,
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                    FractionallySizedBox(
                      widthFactor: ratio,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.linear,
                        height: 4,
                        decoration: BoxDecoration(
                          color: barColor,
                          boxShadow: [
                            BoxShadow(
                              color: barColor.withValues(
                                  alpha: isPulsing ? 0.90 : 0.60),
                              blurRadius: isPulsing ? 10 : 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: barColor,
                fontSize: isPulsing ? 13 : 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
              child: Text(timeLabel),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Rakip skoru
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              duelState.isBot
                  ? Icons.smart_toy_rounded
                  : Icons.person_rounded,
              color: Colors.white.withValues(alpha: 0.40),
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              'Rakip: ${duelState.opponentScore}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
