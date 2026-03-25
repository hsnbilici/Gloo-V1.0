import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/models/game_mode.dart';
import '../../providers/audio_provider.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/locale_provider.dart';

/// Bottom sheet for creating and sending a challenge to a friend.
class SendChallengeSheet extends ConsumerStatefulWidget {
  const SendChallengeSheet({
    super.key,
    required this.recipientId,
    required this.recipientUsername,
    required this.onPlayAndSend,
  });

  final String recipientId;
  final String recipientUsername;
  final void Function(GameMode mode, int wager) onPlayAndSend;

  /// Convenience method to show the sheet.
  static Future<void> show(
    BuildContext context, {
    required String recipientId,
    required String recipientUsername,
    required void Function(GameMode mode, int wager) onPlayAndSend,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SendChallengeSheet(
        recipientId: recipientId,
        recipientUsername: recipientUsername,
        onPlayAndSend: onPlayAndSend,
      ),
    );
  }

  @override
  ConsumerState<SendChallengeSheet> createState() =>
      _SendChallengeSheetState();
}

class _SendChallengeSheetState extends ConsumerState<SendChallengeSheet> {
  static const _challengeModes = [
    GameMode.classic,
    GameMode.timeTrial,
    GameMode.colorChef,
  ];
  static const _wagerOptions = [0, 10, 25, 50];
  static const _dailyLimitNormal = 5;
  static const _dailyLimitPlus = 20;

  GameMode _selectedMode = GameMode.classic;
  int _selectedWager = 0;

  IconData _iconForMode(GameMode mode) {
    return switch (mode) {
      GameMode.classic => Icons.grid_on_rounded,
      GameMode.timeTrial => Icons.timer_rounded,
      GameMode.colorChef => Icons.palette_rounded,
      _ => Icons.grid_on_rounded,
    };
  }

  String _nameForMode(GameMode mode, AppStrings l) {
    return switch (mode) {
      GameMode.classic => l.modeClassicName,
      GameMode.timeTrial => l.modeTimeTrialName,
      GameMode.colorChef => l.modeColorChefName,
      _ => l.modeClassicName,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(stringsProvider);
    final brightness = Theme.of(context).brightness;
    final challengeState = ref.watch(challengeProvider);
    final isGlooPlus = ref.watch(appSettingsProvider).glooPlus;

    final dailyLimit = isGlooPlus ? _dailyLimitPlus : _dailyLimitNormal;
    final limitReached = challengeState.dailySentCount >= dailyLimit;

    final sheetBg =
        resolveColor(brightness, dark: kSurfaceDark, light: kSurfaceLight);
    final handleColor = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.18),
      light: kCardBorderLight,
    );
    final borderColor = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.08),
      light: kCardBorderLight,
    );
    final textColor = resolveColor(
      brightness,
      dark: Colors.white,
      light: kTextPrimaryLight,
    );
    final secondaryText = resolveColor(
      brightness,
      dark: kMuted,
      light: kTextSecondaryLight,
    );
    final challengeAccent = resolveColor(
      brightness,
      dark: kChallengePrimary,
      light: kChallengePrimaryLight,
    );

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(UIConstants.radiusXxl),
        ),
        border: Border.all(color: borderColor),
      ),
      padding: EdgeInsets.fromLTRB(
        UIConstants.hPaddingScreen,
        Spacing.lg,
        UIConstants.hPaddingScreen,
        MediaQuery.of(context).viewInsets.bottom + Spacing.xxxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle ──
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(UIConstants.radiusXxs),
              ),
            ),
          ),
          const SizedBox(height: Spacing.xl),

          // ── Header ──
          Text(
            l.challengeSend,
            style: AppTextStyles.heading.copyWith(color: textColor),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            widget.recipientUsername,
            style: AppTextStyles.bodySecondary.copyWith(
              color: challengeAccent,
            ),
          ),
          const SizedBox(height: Spacing.xxl),

          // ── Mode Selection ──
          Text(
            l.challengeModePick,
            style: AppTextStyles.label.copyWith(color: secondaryText),
          ),
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: Spacing.sm,
            children: _challengeModes.map((mode) {
              final selected = _selectedMode == mode;
              final modeColor = kModeColors[mode] ?? kCyan;
              return Semantics(
                label: _nameForMode(mode, l),
                button: true,
                selected: selected,
                child: ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _iconForMode(mode),
                        size: 16,
                        color: selected ? Colors.white : secondaryText,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Text(_nameForMode(mode, l)),
                    ],
                  ),
                  selected: selected,
                  selectedColor: modeColor,
                  backgroundColor: resolveColor(
                    brightness,
                    dark: Colors.white.withValues(alpha: 0.06),
                    light: kCardBgLight,
                  ),
                  labelStyle: AppTextStyles.body.copyWith(
                    color: selected ? Colors.white : textColor,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: selected
                        ? modeColor
                        : resolveColor(
                            brightness,
                            dark: Colors.white.withValues(alpha: 0.1),
                            light: kCardBorderLight,
                          ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(UIConstants.radiusSm),
                  ),
                  onSelected: (_) => setState(() => _selectedMode = mode),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: Spacing.xl),

          // ── Type Toggle ──
          Row(
            children: [
              Semantics(
                label: l.challengeScoreBattle,
                button: true,
                selected: true,
                child: ChoiceChip(
                  label: Text(l.challengeScoreBattle),
                  selected: true,
                  selectedColor: challengeAccent,
                  labelStyle: AppTextStyles.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(UIConstants.radiusSm),
                  ),
                  side: BorderSide(color: challengeAccent),
                  onSelected: (_) {},
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Semantics(
                label: '${l.challengeLiveDuel} — ${l.challengeComingSoon}',
                button: true,
                enabled: false,
                child: ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l.challengeLiveDuel),
                      const SizedBox(width: Spacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: secondaryText.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(
                            UIConstants.radiusXs,
                          ),
                        ),
                        child: Text(
                          l.challengeComingSoon,
                          style: AppTextStyles.micro.copyWith(
                            color: secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  selected: false,
                  backgroundColor: resolveColor(
                    brightness,
                    dark: Colors.white.withValues(alpha: 0.03),
                    light: kCardBgLight,
                  ),
                  labelStyle: AppTextStyles.body.copyWith(
                    color: secondaryText,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(UIConstants.radiusSm),
                  ),
                  side: BorderSide(
                    color: resolveColor(
                      brightness,
                      dark: Colors.white.withValues(alpha: 0.06),
                      light: kCardBorderLight,
                    ),
                  ),
                  onSelected: null,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xl),

          // ── Wager Selection ──
          Text(
            l.challengeWagerPick,
            style: AppTextStyles.label.copyWith(color: secondaryText),
          ),
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: Spacing.sm,
            children: _wagerOptions.map((amount) {
              final selected = _selectedWager == amount;
              final isNone = amount == 0;
              return Semantics(
                label: isNone ? l.challengeNoWager : '$amount Jel Ozu',
                button: true,
                selected: selected,
                child: ChoiceChip(
                  label: isNone
                      ? const Text('—')
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.water_drop_rounded,
                              size: 14,
                              color: selected ? Colors.white : kAmber,
                            ),
                            const SizedBox(width: Spacing.xxs),
                            Text('$amount'),
                          ],
                        ),
                  selected: selected,
                  selectedColor: challengeAccent,
                  backgroundColor: resolveColor(
                    brightness,
                    dark: Colors.white.withValues(alpha: 0.06),
                    light: kCardBgLight,
                  ),
                  labelStyle: AppTextStyles.body.copyWith(
                    color: selected ? Colors.white : textColor,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: selected
                        ? challengeAccent
                        : resolveColor(
                            brightness,
                            dark: Colors.white.withValues(alpha: 0.1),
                            light: kCardBorderLight,
                          ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(UIConstants.radiusSm),
                  ),
                  // Disable if wager exceeds balance — for now always enabled
                  // since balance check will be handled at the server side.
                  onSelected: (_) => setState(() => _selectedWager = amount),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: Spacing.lg),

          // ── Daily Limit Display ──
          Text(
            '${challengeState.dailySentCount}/$dailyLimit '
            '${isGlooPlus ? "(Gloo+)" : ""}',
            style: AppTextStyles.caption.copyWith(
              color: limitReached ? kAmber : secondaryText,
            ),
          ),
          if (limitReached) ...[
            const SizedBox(height: Spacing.xs),
            Text(
              l.challengeDailyLimitReached,
              style: AppTextStyles.caption.copyWith(color: kAmber),
            ),
            if (!isGlooPlus) ...[
              const SizedBox(height: Spacing.xxs),
              Text(
                l.challengeDailyLimitGlooPlus,
                style: AppTextStyles.caption.copyWith(color: secondaryText),
              ),
            ],
          ],
          const SizedBox(height: Spacing.xxl),

          // ── Play & Send Button ──
          SizedBox(
            width: double.infinity,
            child: Semantics(
              label: l.challengePlayAndSend,
              button: true,
              enabled: !limitReached,
              child: FilledButton(
                onPressed: limitReached
                    ? null
                    : () {
                        Navigator.pop(context);
                        widget.onPlayAndSend(
                          _selectedMode,
                          _selectedWager,
                        );
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: challengeAccent,
                  disabledBackgroundColor:
                      challengeAccent.withValues(alpha: 0.3),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: Spacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(UIConstants.radiusMd),
                  ),
                ),
                child: Text(
                  l.challengePlayAndSend,
                  style: AppTextStyles.subheading.copyWith(
                    color: Colors.white,
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
