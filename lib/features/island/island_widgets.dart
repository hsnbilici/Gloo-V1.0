import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/layout/rtl_helpers.dart';
import '../../core/utils/motion_utils.dart';
import '../shared/glow_orb.dart';
import '../../game/meta/resource_manager.dart';

class BuildingCard extends StatefulWidget {
  const BuildingCard({
    super.key,
    required this.type,
    required this.building,
    required this.level,
    required this.canBuild,
    required this.cost,
    required this.canAfford,
    required this.onUpgrade,
    required this.delay,
  });

  final BuildingType type;
  final Building building;
  final int level;
  final bool canBuild;
  final int cost;
  final bool canAfford;
  final VoidCallback onUpgrade;
  final Duration delay;

  @override
  State<BuildingCard> createState() => _BuildingCardState();
}

class _BuildingCardState extends State<BuildingCard> {
  bool _pressed = false;

  IconData get _buildingIcon => switch (widget.type) {
        BuildingType.gelFactory => Icons.factory_rounded,
        BuildingType.asmrTower => Icons.music_note_rounded,
        BuildingType.colorLab => Icons.science_rounded,
        BuildingType.arena => Icons.sports_mma_rounded,
        BuildingType.harbor => Icons.sailing_rounded,
      };

  Color get _buildingColor => switch (widget.type) {
        BuildingType.gelFactory => kGreen,
        BuildingType.asmrTower => kLavender,
        BuildingType.colorLab => kOrange,
        BuildingType.arena => kColorClassic,
        BuildingType.harbor => kDiamondBlue,
      };

  @override
  Widget build(BuildContext context) {
    final dir = Directionality.of(context);
    final (gradBegin, gradEnd) = directionalGradientAlignment(dir);
    final color = _buildingColor;
    final isMaxLevel = !widget.canBuild;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: gradBegin,
            end: gradEnd,
            colors: [
              color.withValues(alpha: 0.10),
              color.withValues(alpha: 0.03),
              Colors.transparent,
            ],
            stops: const [0.0, 0.35, 1.0],
          ),
          borderRadius: BorderRadius.circular(UIConstants.radiusLg),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                border: Border.all(color: color.withValues(alpha: 0.35)),
              ),
              child: Icon(_buildingIcon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.building.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      LevelDots(
                        level: widget.level,
                        maxLevel: widget.building.maxLevel,
                        color: color,
                      ),
                    ],
                  ),
                  if (widget.building.description != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      widget.building.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isMaxLevel)
              Semantics(
                label: '${widget.building.name} upgrade ${widget.cost}',
                button: true,
                enabled: widget.canAfford,
                child: GestureDetector(
                  onTap: widget.canAfford ? widget.onUpgrade : null,
                  onTapDown: widget.canAfford
                      ? (_) => setState(() => _pressed = true)
                      : null,
                  onTapUp: widget.canAfford
                      ? (_) => setState(() => _pressed = false)
                      : null,
                  onTapCancel: widget.canAfford
                      ? () => setState(() => _pressed = false)
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 80),
                    transform: Matrix4.diagonal3Values(
                        _pressed ? 0.93 : 1.0, _pressed ? 0.93 : 1.0, 1.0),
                    transformAlignment: Alignment.center,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.canAfford
                          ? color.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                      border: Border.all(
                        color: widget.canAfford
                            ? color.withValues(alpha: 0.50)
                            : Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded,
                            color: widget.canAfford ? color : kMuted, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          '${widget.cost}',
                          style: TextStyle(
                            color: widget.canAfford ? color : kMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                  border: Border.all(color: color.withValues(alpha: 0.20)),
                ),
                child: Text(
                  'MAKS',
                  style: TextStyle(
                    color: color.withValues(alpha: 0.60),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    )
        .animateOrSkip(
            reduceMotion: shouldReduceMotion(context), delay: widget.delay)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.08, end: 0, duration: 300.ms);
  }
}

class LevelDots extends StatelessWidget {
  const LevelDots({
    super.key,
    required this.level,
    required this.maxLevel,
    required this.color,
  });

  final int level;
  final int maxLevel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxLevel, (i) {
        final filled = i < level;
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsetsDirectional.only(end: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? color : color.withValues(alpha: 0.15),
            border: Border.all(
              color: filled ? color : color.withValues(alpha: 0.30),
              width: 1,
            ),
          ),
        );
      }),
    );
  }
}

class IslandBackground extends StatelessWidget {
  const IslandBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = resolveColor(brightness, dark: kBgDark, light: kBgLight);
    final isDark = brightness == Brightness.dark;
    final orbAlpha = isDark ? 1.0 : 0.45;

    return Stack(
      children: [
        Container(color: bgColor),
        Positioned(
          top: -100,
          left: -60,
          child: GlowOrb(size: 340, color: kGreen, opacity: 0.07 * orbAlpha),
        ),
        Positioned(
          bottom: -80,
          right: -40,
          child:
              GlowOrb(size: 260, color: kDiamondBlue, opacity: 0.06 * orbAlpha),
        ),
      ],
    );
  }
}
