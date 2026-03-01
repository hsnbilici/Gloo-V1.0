import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../shared/glow_orb.dart';
import '../../data/local/local_repository.dart';
import '../../game/world/game_world.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_provider.dart';
import '../../viral/share_manager.dart';

class DailyPuzzleScreen extends ConsumerWidget {
  const DailyPuzzleScreen({super.key});

  static const _kAccent = Color(0xFF00E5FF); // kCyan
  static const _kBg = kBgDark;

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

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // Arka plan orbs
          const Positioned(
            top: -100,
            right: -60,
            child: GlowOrb(size: 320, color: _kAccent, opacity: 0.08),
          ),
          const Positioned(
            bottom: -80,
            left: -40,
            child: GlowOrb(size: 260, color: kColorZen, opacity: 0.06),
          ),
          SafeArea(
            child: repoAsync.when(
              data: (repo) => _DailyContent(
                l: l,
                repo: repo,
                accent: _kAccent,
                dateLabel: _dateLabel(DateTime.now()),
                puzzleNumber: _puzzleNumber(DateTime.now()),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(color: _kAccent),
              ),
              error: (_, __) => Center(
                child: Text(
                  '...',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── İçerik ───────────────────────────────────────────────────────────────────

class _DailyContent extends StatelessWidget {
  const _DailyContent({
    required this.l,
    required this.repo,
    required this.accent,
    required this.dateLabel,
    required this.puzzleNumber,
  });

  final dynamic l;
  final LocalRepository repo;
  final Color accent;
  final String dateLabel;
  final int puzzleNumber;

  @override
  Widget build(BuildContext context) {
    final completed = repo.isDailyCompleted();
    final score = repo.getDailyScore();

    return Column(
      children: [
        // Üst bar — geri butonu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white70, size: 20),
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Başlık
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
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 6),
                Text(
                  '#$puzzleNumber',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.25),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ).animate(delay: 100.ms).fadeIn(),
                const SizedBox(height: 40),
                // Takvim kartı
                _CalendarCard(
                  accent: accent,
                  dateLabel: dateLabel,
                ).animate(delay: 150.ms).fadeIn(duration: 500.ms).scale(
                      begin: const Offset(0.88, 0.88),
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: 36),
                // Tamamlanma durumu
                if (completed)
                  _CompletedState(
                    l: l,
                    score: score,
                    accent: accent,
                    dateLabel: dateLabel,
                  ).animate(delay: 250.ms).fadeIn(duration: 400.ms).slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 400.ms,
                        curve: Curves.easeOutCubic,
                      )
                else
                  _PlayState(l: l, accent: accent)
                      .animate(delay: 250.ms)
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

// ─── Takvim kartı ─────────────────────────────────────────────────────────────

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({required this.accent, required this.dateLabel});

  final Color accent;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final day = now.day.toString();

    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UIConstants.radiusXl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.14),
            accent.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.30), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            color: accent.withValues(alpha: 0.50),
            size: 22,
          ),
          const SizedBox(height: 8),
          Text(
            day,
            style: TextStyle(
              color: accent,
              fontSize: 56,
              fontWeight: FontWeight.w900,
              height: 1,
              shadows: [
                Shadow(color: accent.withValues(alpha: 0.5), blurRadius: 20),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateLabel,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tamamlanmamış durum ──────────────────────────────────────────────────────

class _PlayState extends StatelessWidget {
  const _PlayState({required this.l, required this.accent});

  final dynamic l;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          dateLabel(DateTime.now()),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.50),
            fontSize: 13,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        _ActionBtn(
          label: l.dailyPlayButton.toString(),
          color: accent,
          filled: true,
          onTap: () => context.go('/game/${GameMode.daily.name}'),
        ),
      ],
    );
  }

  String dateLabel(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d.$m.${date.year}';
  }
}

// ─── Tamamlanmış durum ────────────────────────────────────────────────────────

class _CompletedState extends StatelessWidget {
  const _CompletedState({
    required this.l,
    required this.score,
    required this.accent,
    required this.dateLabel,
  });

  final dynamic l;
  final int score;
  final Color accent;
  final String dateLabel;

  String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tamamlandı rozeti
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: kColorChef.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kColorChef.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: kColorChef.withValues(alpha: 0.10),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: kColorChef,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                l.dailyCompleted.toString().toUpperCase(),
                style: const TextStyle(
                  color: kColorChef,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Puan
        Text(
          l.dailyScore.toString().toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.40),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _fmt(score),
          style: TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.w900,
            height: 1,
            shadows: [
              Shadow(
                color: accent.withValues(alpha: 0.3),
                blurRadius: 16,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        // Paylaş butonu
        _ActionBtn(
          label: l.dailyShareResult.toString(),
          color: accent,
          filled: false,
          icon: Icons.share_rounded,
          onTap: () {
            ShareManager().shareDailyResult(
              score: score,
              dateLabel: dateLabel,
            );
          },
        ),
      ],
    );
  }
}

// ─── Aksiyon butonu ───────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.color,
    required this.filled,
    required this.onTap,
    this.icon,
  });

  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: filled ? color.withValues(alpha: 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(UIConstants.radiusTile),
          border: Border.all(
            color: filled
                ? color.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.12),
            width: filled ? 1.5 : 1,
          ),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
