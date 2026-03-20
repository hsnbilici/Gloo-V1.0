import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../game/meta/resource_manager.dart';

class GlooMascot extends StatelessWidget {
  const GlooMascot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.2, -0.2),
          colors: [kMascotGreenLight, kMascotGreenMid, kMascotGreenDark],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: kGreen.withValues(alpha: 0.30),
            blurRadius: 28,
            spreadRadius: 6,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 30,
            left: 28,
            child: Container(
              width: 14,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Align(
                alignment: const Alignment(0.3, 0.3),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: kSurfaceDeepNavy,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 28,
            child: Container(
              width: 14,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Align(
                alignment: const Alignment(0.3, 0.3),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: kSurfaceDeepNavy,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 36,
            child: Container(
              width: 28,
              height: 10,
              decoration: const BoxDecoration(
                color: kMascotMouth,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 20,
            child: Container(
              width: 22,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.40),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TalentCard extends StatelessWidget {
  const TalentCard({
    super.key,
    required this.def,
    required this.level,
    required this.cost,
    required this.isMax,
    required this.canAfford,
    required this.onUpgrade,
    required this.delay,
  });

  final TalentDef def;
  final int level;
  final int cost;
  final bool isMax;
  final bool canAfford;
  final VoidCallback onUpgrade;
  final Duration delay;

  Color get _talentColor => switch (def.type) {
        TalentType.betterHand => kGreen,
        TalentType.colorMaster => kOrange,
        TalentType.fastHands => kColorClassic,
        TalentType.zenGuru => kLavender,
      };

  IconData get _talentIcon => switch (def.type) {
        TalentType.betterHand => Icons.back_hand_rounded,
        TalentType.colorMaster => Icons.palette_rounded,
        TalentType.fastHands => Icons.speed_rounded,
        TalentType.zenGuru => Icons.self_improvement_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final color = _talentColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(UIConstants.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Icon(_talentIcon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          def.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Lv.$level/${def.maxLevel}',
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    def.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.40),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (!isMax)
              Semantics(
                label: '${def.name} upgrade $cost',
                button: true,
                enabled: canAfford,
                child: GestureDetector(
                onTap: canAfford ? onUpgrade : null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: canAfford
                        ? color.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                    border: Border.all(
                      color: canAfford
                          ? color.withValues(alpha: 0.45)
                          : Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Text(
                    '$cost',
                    style: TextStyle(
                      color: canAfford ? color : kMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              )
            else
              Text(
                'MAKS',
                style: TextStyle(
                  color: color.withValues(alpha: 0.50),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
          ],
        ),
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 250.ms)
        .slideX(begin: 0.06, end: 0, duration: 250.ms);
  }
}
