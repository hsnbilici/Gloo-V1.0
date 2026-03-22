import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/constants/color_constants_light.dart';
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

    final brightness = Theme.of(context).brightness;
    final titleColor = resolveColor(
      brightness,
      dark: Colors.white,
      light: kTextPrimaryLight,
    );
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: () => context.push('/daily'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UIConstants.radiusMd),
            gradient: LinearGradient(
              begin: gradBegin,
              end: gradEnd,
              colors: [
                _kAccent.withValues(alpha: 0.10),
                _kAccent.withValues(alpha: 0.02),
                Colors.transparent,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
            border: Border.all(color: _kAccent.withValues(alpha: 0.20)),
          ),
          child: Row(
            children: [
              Icon(
                completed
                    ? Icons.check_circle_rounded
                    : Icons.calendar_today_rounded,
                color: completed ? kColorChef : _kAccent,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  completed ? '$label — ${fmt(score)}' : '$label — ${todayLabel()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                directionalChevronIcon(Directionality.of(context)),
                color: _kAccent.withValues(alpha: 0.50),
                size: 18,
              ),
            ],
          ),
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
