import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/layout/responsive.dart';
import '../../core/layout/rtl_helpers.dart';
import '../../core/utils/motion_utils.dart';
import '../../data/local/local_repository.dart';
import '../shared/glow_orb.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_provider.dart';
import 'daily_puzzle_widgets.dart';

class DailyPuzzleScreen extends ConsumerWidget {
  const DailyPuzzleScreen({super.key});

  String _dateLabel(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d.$m.${date.year}';
  }

  int _puzzleNumber(DateTime date) {
    final start = DateTime(date.year, 1, 1);
    return date.difference(start).inDays + 1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = ref.watch(stringsProvider);
    final repoAsync = ref.watch(localRepositoryProvider);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final brightness = Theme.of(context).brightness;
    final bgColor = resolveColor(brightness, dark: kBgDark, light: kBgLight);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          const Positioned(
            top: -100,
            right: -60,
            child: GlowOrb(size: 320, color: kCyan, opacity: 0.08),
          ),
          const Positioned(
            bottom: -80,
            left: -40,
            child: GlowOrb(size: 260, color: kColorZen, opacity: 0.06),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: responsiveMaxWidth(screenWidth)),
                child: repoAsync.when(
              data: (repo) => _DailyContent(
                l: l,
                repo: repo,
                accent: kCyan,
                dateLabel: _dateLabel(DateTime.now()),
                puzzleNumber: _puzzleNumber(DateTime.now()),
                hPadding: responsiveHPadding(screenWidth),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(color: kCyan),
              ),
              error: (_, __) => Center(
                child: Text(
                  '...',
                  style: TextStyle(
                    color: resolveColor(
                      brightness,
                      dark: Colors.white.withValues(alpha: 0.4),
                      light: kTextSecondaryLight,
                    ),
                  ),
                ),
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

class _DailyContent extends StatelessWidget {
  const _DailyContent({
    required this.l,
    required this.repo,
    required this.accent,
    required this.dateLabel,
    required this.puzzleNumber,
    required this.hPadding,
  });

  final AppStrings l;
  final LocalRepository repo;
  final Color accent;
  final String dateLabel;
  final int puzzleNumber;
  final double hPadding;

  @override
  Widget build(BuildContext context) {
    final dir = Directionality.of(context);
    final completed = repo.isDailyCompleted();
    final score = repo.getDailyScore();
    final brightness = Theme.of(context).brightness;
    final rm = shouldReduceMotion(context);
    final textSecondary = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.25),
      light: kTextSecondaryLight,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: Icon(directionalBackIcon(dir),
                    color: Colors.white70, size: 20),
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: hPadding),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Text(
                  l.dailyTitle.toString().toUpperCase(),
                  style: TextStyle(
                    color: accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    shadows: [
                      Shadow(
                        color: accent.withValues(alpha: 0.6),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                ).animateOrSkip(reduceMotion: rm).fadeIn(duration: 400.ms),
                const SizedBox(height: 6),
                Text(
                  '#$puzzleNumber',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ).animateOrSkip(reduceMotion: rm, delay: 100.ms).fadeIn(),
                const SizedBox(height: 40),
                CalendarCard(
                  accent: accent,
                  dateLabel: dateLabel,
                ).animateOrSkip(reduceMotion: rm, delay: 150.ms).fadeIn(duration: 500.ms).scale(
                      begin: const Offset(0.88, 0.88),
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: 36),
                if (completed)
                  CompletedState(
                    l: l,
                    score: score,
                    accent: accent,
                    dateLabel: dateLabel,
                  ).animateOrSkip(reduceMotion: rm, delay: 250.ms).fadeIn(duration: 400.ms).slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 400.ms,
                        curve: Curves.easeOutCubic,
                      )
                else
                  PlayState(l: l, accent: accent)
                      .animateOrSkip(reduceMotion: rm, delay: 250.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 400.ms,
                        curve: Curves.easeOutCubic,
                      ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
