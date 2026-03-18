import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';

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
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: widget.filled
                ? widget.accentColor.withValues(alpha: _pressed ? 0.20 : 0.13)
                : Colors.white.withValues(alpha: _pressed ? 0.07 : 0.03),
            borderRadius: BorderRadius.circular(UIConstants.radiusTile),
            border: Border.all(
              color: widget.filled
                  ? widget.accentColor.withValues(alpha: _pressed ? 0.70 : 0.50)
                  : Colors.white.withValues(alpha: _pressed ? 0.16 : 0.09),
              width: widget.filled ? 1.5 : 1,
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

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.secondChanceLabel,
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                kGold.withValues(alpha: _pressed ? 0.22 : 0.15),
                widget.color.withValues(alpha: _pressed ? 0.18 : 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(UIConstants.radiusTile),
            border: Border.all(
              color: kGold.withValues(alpha: _pressed ? 0.80 : 0.55),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
    );
  }
}
