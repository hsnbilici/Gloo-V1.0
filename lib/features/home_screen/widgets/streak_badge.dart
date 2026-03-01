import 'package:flutter/material.dart';

class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.streak, required this.days});

  final int streak;
  final String days;

  static const _kFire = Color(0xFFFF8C42);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _kFire.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kFire.withValues(alpha: 0.30)),
        boxShadow: [
          BoxShadow(color: _kFire.withValues(alpha: 0.14), blurRadius: 14),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: _kFire,
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            '$streak $days',
            style: const TextStyle(
              color: _kFire,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
