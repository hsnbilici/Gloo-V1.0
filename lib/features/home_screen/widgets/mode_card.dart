import 'package:flutter/material.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/constants/color_constants_light.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/layout/rtl_helpers.dart';

class ModeCard extends StatefulWidget {
  const ModeCard({
    super.key,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
    this.isFeatured = false,
    this.badgeLabel,
    this.isLocked = false,
    this.lockLabel,
  });

  final String label;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final bool isFeatured;
  final String? badgeLabel;
  final bool isLocked;
  final String? lockLabel;

  @override
  State<ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<ModeCard> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final dir = Directionality.of(context);
    final (gradBegin, gradEnd) = directionalGradientAlignment(dir);
    final brightness = Theme.of(context).brightness;

    // Pre-compute hover/press-dependent alpha values
    final double gradAlpha1, gradAlpha2, borderAlpha;
    if (widget.isFeatured) {
      gradAlpha1 = _pressed
          ? 0.28
          : _hovered
              ? 0.24
              : 0.20;
      gradAlpha2 = _hovered ? 0.12 : 0.08;
      borderAlpha = _pressed
          ? 0.70
          : _hovered
              ? 0.60
              : 0.50;
    } else {
      gradAlpha1 = _pressed
          ? 0.17
          : _hovered
              ? 0.15
              : 0.11;
      gradAlpha2 = _hovered ? 0.07 : 0.04;
      borderAlpha = _pressed
          ? 0.38
          : _hovered
              ? 0.30
              : 0.22;
    }

    return Semantics(
      label: widget.label,
      button: true,
      child: MouseRegion(
        onEnter: (_) {
          if (!_hovered) setState(() => _hovered = true);
        },
        onExit: (_) {
          if (_hovered) setState(() => _hovered = false);
        },
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 80),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: widget.isFeatured ? 18 : 13,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(UIConstants.radiusLg),
                gradient: LinearGradient(
                  begin: gradBegin,
                  end: gradEnd,
                  colors: [
                    widget.color.withValues(alpha: gradAlpha1),
                    widget.color.withValues(alpha: gradAlpha2),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.35, 1.0],
                ),
                border: Border.all(
                  color: widget.color.withValues(alpha: borderAlpha),
                  width: widget.isFeatured ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color
                        .withValues(alpha: widget.isFeatured ? 0.18 : 0.07),
                    blurRadius: widget.isFeatured ? 24 : 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: widget.isFeatured ? 50 : 44,
                    height: widget.isFeatured ? 50 : 44,
                    decoration: BoxDecoration(
                      color: widget.color
                          .withValues(alpha: widget.isFeatured ? 0.20 : 0.12),
                      borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                      border: Border.all(
                        color: widget.color
                            .withValues(alpha: widget.isFeatured ? 0.50 : 0.28),
                      ),
                    ),
                    child: Icon(widget.icon,
                        color: widget.color, size: widget.isFeatured ? 24 : 21),
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
                                widget.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: resolveColor(brightness,
                                      dark: Colors.white,
                                      light: kTextPrimaryLight),
                                  fontSize: MediaQuery.textScalerOf(context)
                                      .scale(widget.isFeatured ? 17 : 16),
                                  fontWeight: FontWeight.w700,
                                  shadows: [
                                    Shadow(
                                      color:
                                          widget.color.withValues(alpha: 0.35),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (widget.badgeLabel != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.color.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(
                                      UIConstants.radiusSm),
                                  border: Border.all(
                                    color: widget.color.withValues(alpha: 0.45),
                                  ),
                                ),
                                child: Text(
                                  widget.badgeLabel!,
                                  style: TextStyle(
                                    color: widget.color,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: widget.isFeatured
                                ? resolveColor(brightness,
                                    dark: Colors.white.withValues(alpha: 0.55),
                                    light: kTextSecondaryLight)
                                : resolveColor(brightness,
                                    dark: kMuted, light: kTextSecondaryLight),
                            fontSize:
                                MediaQuery.textScalerOf(context).scale(11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.isLocked && widget.lockLabel != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: kGold.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(UIConstants.radiusSm),
                        border:
                            Border.all(color: kGold.withValues(alpha: 0.40)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_rounded,
                              color: kGold, size: 10),
                          const SizedBox(width: 3),
                          Text(
                            widget.lockLabel!,
                            style: const TextStyle(
                              color: kGold,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else
                    Icon(
                      directionalChevronIcon(Directionality.of(context)),
                      color: widget.color
                          .withValues(alpha: widget.isFeatured ? 0.80 : 0.55),
                      size: widget.isFeatured ? 24 : 22,
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
