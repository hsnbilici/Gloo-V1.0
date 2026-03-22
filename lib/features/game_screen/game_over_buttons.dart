import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/layout/rtl_helpers.dart';

// ─── Aksiyon butonu ──────────────────────────────────────────────────────────

class ActionButton extends StatefulWidget {
  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color accentColor;
  final bool filled;
  final VoidCallback onTap;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _pressed = false;
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      button: true,
      child: FocusableActionDetector(
        onShowFocusHighlight: (focused) {
          if (_focused != focused) setState(() => _focused = focused);
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: AnimatedScale(
              scale: _pressed ? 0.96 : 1.0,
              duration: const Duration(milliseconds: 80),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: widget.filled
                      ? widget.accentColor.withValues(
                          alpha: _pressed ? 0.20 : _hovered ? 0.17 : 0.13)
                      : Colors.white.withValues(
                          alpha: _pressed ? 0.07 : _hovered ? 0.05 : 0.03),
                  borderRadius:
                      BorderRadius.circular(UIConstants.radiusTile),
                  border: Border.all(
                    color: _focused
                        ? kCyan.withValues(alpha: 0.6)
                        : widget.filled
                            ? widget.accentColor.withValues(
                                alpha:
                                    _pressed ? 0.70 : _hovered ? 0.60 : 0.50)
                            : Colors.white.withValues(
                                alpha:
                                    _pressed ? 0.16 : _hovered ? 0.13 : 0.09),
                    width: _focused ? 2 : widget.filled ? 1.5 : 1,
                  ),
                  boxShadow: widget.filled
                      ? [
                          BoxShadow(
                            color: widget.accentColor.withValues(alpha: 0.14),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, color: widget.accentColor, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.accentColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Ikinci Sans butonu — Rewarded Ad ile 3 ekstra hamle ─────────────────────

class SecondChanceButton extends StatefulWidget {
  const SecondChanceButton({
    super.key,
    required this.color,
    required this.onTap,
    required this.watchAdLabel,
    required this.secondChanceLabel,
  });

  final Color color;
  final VoidCallback onTap;
  final String watchAdLabel;
  final String secondChanceLabel;

  @override
  State<SecondChanceButton> createState() => _SecondChanceButtonState();
}

class _SecondChanceButtonState extends State<SecondChanceButton> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final dir = Directionality.of(context);
    final (gradBegin, gradEnd) = directionalGradientAlignment(dir);
    return Semantics(
      label: widget.secondChanceLabel,
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 80),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: gradBegin,
                  end: gradEnd,
                  colors: [
                    kGold.withValues(
                        alpha: _pressed ? 0.22 : _hovered ? 0.19 : 0.15),
                    widget.color.withValues(
                        alpha: _pressed ? 0.18 : _hovered ? 0.14 : 0.10),
                  ],
                ),
                borderRadius: BorderRadius.circular(UIConstants.radiusTile),
                border: Border.all(
                  color: kGold.withValues(
                      alpha: _pressed ? 0.80 : _hovered ? 0.68 : 0.55),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kGold.withValues(alpha: 0.20),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_circle_outline_rounded,
                      color: kGold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.watchAdLabel,
                    style: const TextStyle(
                      color: kGold,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: kGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kGold.withValues(alpha: 0.40)),
                    ),
                    child: Text(
                      widget.secondChanceLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
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
