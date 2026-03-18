import 'package:flutter/material.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/constants/ui_constants.dart';

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
  State<ModeCard> createState() => ModeCardState();
}

class ModeCardState extends State<ModeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      button: true,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          transformAlignment: Alignment.center,
          transform: Matrix4.diagonal3Values(
              _pressed ? 0.97 : 1.0, _pressed ? 0.97 : 1.0, 1.0),
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: widget.isFeatured ? 18 : 13,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UIConstants.radiusLg),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: widget.isFeatured
                  ? [
                      widget.color.withValues(alpha: _pressed ? 0.28 : 0.20),
                      widget.color.withValues(alpha: 0.08),
                      Colors.transparent,
                    ]
                  : [
                      widget.color.withValues(alpha: _pressed ? 0.17 : 0.11),
                      widget.color.withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
              stops: const [0.0, 0.35, 1.0],
            ),
            border: Border.all(
              color: widget.color.withValues(
                alpha: widget.isFeatured
                    ? (_pressed ? 0.70 : 0.50)
                    : (_pressed ? 0.38 : 0.22),
              ),
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
                        Text(
                          widget.label,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: widget.isFeatured ? 17 : 16,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                color: widget.color.withValues(alpha: 0.35),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        if (widget.isFeatured && widget.badgeLabel != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: widget.color.withValues(alpha: 0.18),
                              borderRadius:
                                  BorderRadius.circular(UIConstants.radiusSm),
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
                      style: TextStyle(
                        color: widget.isFeatured
                            ? Colors.white.withValues(alpha: 0.55)
                            : kMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isLocked && widget.lockLabel != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: kGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                    border: Border.all(
                        color: kGold.withValues(alpha: 0.40)),
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
                  Icons.chevron_right_rounded,
                  color: widget.color
                      .withValues(alpha: widget.isFeatured ? 0.80 : 0.55),
                  size: widget.isFeatured ? 24 : 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
