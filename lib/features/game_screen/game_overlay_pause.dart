import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';

// ─── Pause dialog ────────────────────────────────────────────────────────────

class PauseDialog extends StatelessWidget {
  const PauseDialog({
    super.key,
    required this.title,
    required this.resumeLabel,
    required this.homeLabel,
    required this.onResume,
    required this.onHome,
  });

  final String title;
  final String resumeLabel;
  final String homeLabel;
  final VoidCallback onResume;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onResume();
      },
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: kBgDark,
              borderRadius: BorderRadius.circular(UIConstants.radiusXxl),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 48,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: kCyan.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                    border: Border.all(color: kCyan.withValues(alpha: 0.28)),
                  ),
                  child:
                      const Icon(Icons.pause_rounded, color: kCyan, size: 24),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 28),
                PauseBtn(
                  label: resumeLabel,
                  icon: Icons.play_arrow_rounded,
                  color: kCyan,
                  filled: true,
                  onTap: onResume,
                ),
                const SizedBox(height: 10),
                PauseBtn(
                  label: homeLabel,
                  icon: Icons.home_rounded,
                  color: kMuted,
                  filled: false,
                  onTap: onHome,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Pause dialog butonu ─────────────────────────────────────────────────────

class PauseBtn extends StatefulWidget {
  const PauseBtn({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  @override
  State<PauseBtn> createState() => _PauseBtnState();
}

class _PauseBtnState extends State<PauseBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: widget.filled
              ? widget.color.withValues(alpha: _pressed ? 0.20 : 0.13)
              : Colors.white.withValues(alpha: _pressed ? 0.07 : 0.03),
          borderRadius: BorderRadius.circular(UIConstants.radiusTile),
          border: Border.all(
            color: widget.filled
                ? widget.color.withValues(alpha: _pressed ? 0.70 : 0.50)
                : Colors.white.withValues(alpha: _pressed ? 0.16 : 0.09),
            width: widget.filled ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: widget.color, size: 18),
            const SizedBox(width: 10),
            Text(
              widget.label,
              style: TextStyle(
                color: widget.color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
