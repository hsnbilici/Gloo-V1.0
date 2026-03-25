import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/layout/responsive.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/locale_provider.dart';
import 'challenge_widgets.dart';

class ChallengeTab extends ConsumerStatefulWidget {
  const ChallengeTab({super.key});

  @override
  ConsumerState<ChallengeTab> createState() => _ChallengeTabState();
}

class _ChallengeTabState extends ConsumerState<ChallengeTab> {
  @override
  void initState() {
    super.initState();
    // Load challenges when tab is first shown
    Future.microtask(
      () => ref.read(challengeProvider.notifier).loadChallenges(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(stringsProvider);
    final state = ref.watch(challengeProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hPadding = responsiveHPadding(screenWidth);
    final brightness = Theme.of(context).brightness;

    final textColor = resolveColor(
      brightness,
      dark: Colors.white,
      light: kTextPrimaryLight,
    );

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: kChallengePrimary,
          strokeWidth: 2,
        ),
      );
    }

    final received = state.received;
    final sent = state.sent;
    final isEmpty = received.isEmpty && sent.isEmpty;

    if (isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sports_kabaddi_rounded,
                color: kMuted.withValues(alpha: 0.4),
                size: 48,
              ),
              const SizedBox(height: Spacing.md),
              Text(
                l.challengeNoActive,
                style: AppTextStyles.body.copyWith(color: kMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: hPadding,
        vertical: Spacing.lg,
      ),
      children: [
        // Received section
        if (received.isNotEmpty) ...[
          _SectionHeader(
            title: l.challengeReceivedSection,
            count: received.length,
            textColor: textColor,
          ),
          ...received.map(
            (c) => ChallengeCard(
              challenge: c,
              isReceived: true,
            ),
          ),
        ],

        // Sent section
        if (sent.isNotEmpty) ...[
          _SectionHeader(
            title: l.challengeSentSection,
            count: sent.length,
            textColor: textColor,
          ),
          ...sent.map(
            (c) => ChallengeCard(
              challenge: c,
              isReceived: false,
            ),
          ),
        ],

        const SizedBox(height: Spacing.xxxl),
      ],
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.textColor,
  });

  final String title;
  final int count;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.md, bottom: Spacing.sm),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Text(
            '($count)',
            style: AppTextStyles.caption.copyWith(color: kMuted),
          ),
        ],
      ),
    );
  }
}
