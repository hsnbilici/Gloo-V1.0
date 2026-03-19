import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/layout/rtl_helpers.dart';
import '../../../providers/user_provider.dart';

class DailyBanner extends ConsumerWidget {
  const DailyBanner({super.key, required this.label});

  final String label;

  static const _kAccent = kCyan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dir = Directionality.of(context);
    final (gradBegin, gradEnd) = directionalGradientAlignment(dir);
    final repoAsync = ref.watch(localRepositoryProvider);
    final completed = repoAsync.valueOrNull?.isDailyCompleted() ?? false;
    final score = repoAsync.valueOrNull?.getDailyScore() ?? 0;

    return GestureDetector(
      onTap: () => context.push('/daily'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UIConstants.radiusLg),
          gradient: LinearGradient(
            begin: gradBegin,
            end: gradEnd,
            colors: [
              _kAccent.withValues(alpha: 0.12),
              _kAccent.withValues(alpha: 0.03),
              Colors.transparent,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
          border: Border.all(color: _kAccent.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _kAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                border: Border.all(color: _kAccent.withValues(alpha: 0.30)),
              ),
              child: Icon(
                completed
                    ? Icons.check_circle_rounded
                    : Icons.calendar_today_rounded,
                color: completed ? kColorChef : _kAccent,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    completed ? fmt(score) : todayLabel(),
                    style: TextStyle(
                      color: completed
                          ? kColorChef
                          : Colors.white.withValues(alpha: 0.40),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              directionalChevronIcon(Directionality.of(context)),
              color: _kAccent.withValues(alpha: 0.60),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

String todayLabel() {
  final now = DateTime.now();
  final d = now.day.toString().padLeft(2, '0');
  final m = now.month.toString().padLeft(2, '0');
  return '$d.$m.${now.year}';
}

String fmt(int v) {
  if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return v.toString();
}
