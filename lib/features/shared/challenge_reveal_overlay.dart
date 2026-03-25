import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/models/challenge.dart';
import '../../core/utils/motion_utils.dart';

/// Dramatic score reveal overlay shown when a challenge is completed.
class ChallengeRevealOverlay extends StatefulWidget {
  const ChallengeRevealOverlay({
    super.key,
    required this.result,
    required this.opponentUsername,
    required this.onRematch,
    required this.onClose,
  });

  final ChallengeResult result;
  final String opponentUsername;
  final VoidCallback onRematch;
  final VoidCallback onClose;

  /// Shows the overlay as a modal dialog.
  static Future<void> show(
    BuildContext context, {
    required ChallengeResult result,
    required String opponentUsername,
    required VoidCallback onRematch,
    required VoidCallback onClose,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionBuilder: fadeScaleTransition,
      transitionDuration: AnimationDurations.dialog,
      pageBuilder: (_, __, ___) => ChallengeRevealOverlay(
        result: result,
        opponentUsername: opponentUsername,
        onRematch: onRematch,
        onClose: onClose,
      ),
    );
  }

  @override
  State<ChallengeRevealOverlay> createState() =>
      _ChallengeRevealOverlayState();
}

class _ChallengeRevealOverlayState extends State<ChallengeRevealOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _recipientCtrl;
  late final AnimationController _senderCtrl;

  late final Animation<int> _recipientScore;
  late final Animation<int> _senderScore;

  bool _showOutcome = false;
  bool _announced = false;

  bool get _reduceMotion => shouldReduceMotion(context);

  Color get _outcomeColor => switch (widget.result.outcome) {
        ChallengeOutcome.win => kChallengeWin,
        ChallengeOutcome.loss => kChallengeLose,
        ChallengeOutcome.draw => kGold,
      };

  String get _outcomeLabel => switch (widget.result.outcome) {
        ChallengeOutcome.win => 'You Won!',
        ChallengeOutcome.loss => 'You Lost',
        ChallengeOutcome.draw => 'Draw!',
      };

  @override
  void initState() {
    super.initState();

    _recipientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _senderCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _recipientScore = IntTween(
      begin: 0,
      end: widget.result.recipientScore,
    ).animate(CurvedAnimation(
      parent: _recipientCtrl,
      curve: Curves.easeOutCubic,
    ));

    _senderScore = IntTween(
      begin: 0,
      end: widget.result.senderScore,
    ).animate(CurvedAnimation(
      parent: _senderCtrl,
      curve: Curves.easeOutCubic,
    ));

    _startSequence();
  }

  Future<void> _startSequence() async {
    // In reduce motion mode, skip to final state immediately.
    if (_reduceMotion) {
      _recipientCtrl.value = 1.0;
      _senderCtrl.value = 1.0;
      if (mounted) setState(() => _showOutcome = true);
      _announce();
      return;
    }

    // Recipient score counter starts immediately.
    _recipientCtrl.forward();

    // Sender score counter starts after 500ms delay.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _senderCtrl.forward();

    // Outcome appears after both counters finish (~1500ms from start).
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _showOutcome = true);
    _announce();
  }

  void _announce() {
    if (_announced) return;
    _announced = true;
    final msg =
        '$_outcomeLabel ${widget.result.recipientScore} - ${widget.result.senderScore}';
    SemanticsService.sendAnnouncement(
      View.of(context),
      msg,
      Directionality.of(context),
    );
  }

  @override
  void dispose() {
    _recipientCtrl.dispose();
    _senderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rm = _reduceMotion;
    final isWinnerRecipient =
        widget.result.recipientScore > widget.result.senderScore;
    final isWinnerSender =
        widget.result.senderScore > widget.result.recipientScore;
    final reward = widget.result.gelReward;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.hPaddingCard,
            vertical: Spacing.xxl,
          ),
          decoration: BoxDecoration(
            color: kSurfaceDark,
            borderRadius: BorderRadius.circular(UIConstants.radiusXxl),
            border: Border.all(
              color: _outcomeColor.withValues(alpha: 0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: _outcomeColor.withValues(alpha: 0.12),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Revealing Score... label
              Text(
                'Revealing Score...',
                style: AppTextStyles.label.copyWith(
                  color: kMuted,
                  letterSpacing: 3,
                ),
              )
                  .animateOrSkip(reduceMotion: rm)
                  .fadeIn(duration: 280.ms),
              const SizedBox(height: Spacing.xl),

              // ── Score rows
              _ScoreRow(
                label: 'You',
                animation: _recipientScore,
                controller: _recipientCtrl,
                finalScore: widget.result.recipientScore,
                isWinner: isWinnerRecipient,
                reduceMotion: rm,
                delay: Duration.zero,
              ),
              const SizedBox(height: Spacing.md),
              _ScoreRow(
                label: widget.opponentUsername,
                animation: _senderScore,
                controller: _senderCtrl,
                finalScore: widget.result.senderScore,
                isWinner: isWinnerSender,
                reduceMotion: rm,
                delay: const Duration(milliseconds: 500),
              ),
              const SizedBox(height: Spacing.xxl),

              // ── Outcome header
              if (_showOutcome) ...[
                Text(
                  _outcomeLabel,
                  style: AppTextStyles.displayLarge.copyWith(
                    color: _outcomeColor,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: _outcomeColor.withValues(alpha: 0.55),
                        blurRadius: 22,
                      ),
                    ],
                  ),
                )
                    .animateOrSkip(reduceMotion: rm)
                    .fadeIn(duration: 300.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      duration: 300.ms,
                      curve: Curves.easeOutBack,
                    ),
                const SizedBox(height: Spacing.lg),

                // ── Reward display
                if (reward != 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.water_drop_rounded,
                        size: 18,
                        color: reward > 0 ? kGold : kChallengeLose,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Text(
                        '${reward > 0 ? '+' : ''}$reward Jel Ozu',
                        style: AppTextStyles.heading.copyWith(
                          color: reward > 0 ? kGold : kChallengeLose,
                        ),
                      ),
                    ],
                  )
                      .animateOrSkip(reduceMotion: rm, delay: 120.ms)
                      .fadeIn(duration: 280.ms),
                const SizedBox(height: Spacing.xxl),
              ],

              // ── Action buttons
              if (_showOutcome) ...[
                _ChallengeActionButton(
                  label: 'Rematch',
                  icon: Icons.replay_rounded,
                  accentColor: kChallengePrimary,
                  filled: true,
                  onTap: widget.onRematch,
                )
                    .animateOrSkip(reduceMotion: rm, delay: 200.ms)
                    .fadeIn(duration: 320.ms)
                    .slideY(
                      begin: 0.18,
                      end: 0,
                      duration: 320.ms,
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: Spacing.md),
                _ChallengeActionButton(
                  label: 'Close',
                  icon: Icons.close_rounded,
                  accentColor: kMuted,
                  filled: false,
                  onTap: widget.onClose,
                )
                    .animateOrSkip(reduceMotion: rm, delay: 280.ms)
                    .fadeIn(duration: 320.ms)
                    .slideY(
                      begin: 0.18,
                      end: 0,
                      duration: 320.ms,
                      curve: Curves.easeOutCubic,
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Score row with animated counter ─────────────────────────────────────────

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.label,
    required this.animation,
    required this.controller,
    required this.finalScore,
    required this.isWinner,
    required this.reduceMotion,
    required this.delay,
  });

  final String label;
  final Animation<int> animation;
  final AnimationController controller;
  final int finalScore;
  final bool isWinner;
  final bool reduceMotion;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final accentColor = isWinner ? kChallengeWin : kMuted;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.md,
      ),
      decoration: BoxDecoration(
        color: isWinner
            ? accentColor.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(UIConstants.radiusMd),
        border: isWinner
            ? Border.all(color: accentColor.withValues(alpha: 0.30))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                color: isWinner ? Colors.white : kMuted,
                fontWeight: isWinner ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: controller,
            builder: (_, __) {
              final val = reduceMotion ? finalScore : animation.value;
              return Text(
                '$val',
                style: AppTextStyles.heading.copyWith(
                  color: isWinner ? accentColor : Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              );
            },
          ),
        ],
      ),
    )
        .animateOrSkip(reduceMotion: reduceMotion, delay: delay)
        .fadeIn(duration: 280.ms)
        .slideX(
          begin: 0.08,
          end: 0,
          duration: 280.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

// ─── Action button (mirrors game_over_buttons.dart pattern) ──────────────────

class _ChallengeActionButton extends StatefulWidget {
  const _ChallengeActionButton({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color accentColor;
  final bool filled;
  final VoidCallback onTap;

  @override
  State<_ChallengeActionButton> createState() => _ChallengeActionButtonState();
}

class _ChallengeActionButtonState extends State<_ChallengeActionButton> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final dir = Directionality.of(context);

    return Semantics(
      label: widget.label,
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.96 : 1.0,
            duration: AnimationDurations.micro,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: widget.filled
                    ? widget.accentColor.withValues(
                        alpha: _pressed ? 0.20 : _hovered ? 0.17 : 0.13)
                    : Colors.white.withValues(
                        alpha: _pressed ? 0.08 : _hovered ? 0.06 : 0.03),
                borderRadius: BorderRadius.circular(UIConstants.radiusTile),
                border: Border.all(
                  color: widget.filled
                      ? widget.accentColor.withValues(
                          alpha: _hovered ? 0.50 : 0.30)
                      : Colors.white.withValues(
                          alpha: _hovered ? 0.18 : 0.08),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.filled ? widget.accentColor : kMuted,
                    size: 18,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Text(
                    widget.label,
                    style: AppTextStyles.body.copyWith(
                      color: widget.filled ? widget.accentColor : kMuted,
                      fontWeight: FontWeight.w700,
                      letterSpacing: dir == TextDirection.rtl ? 0 : 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
