import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../game/pvp/matchmaking.dart';

// ─── Eslestirme Ara butonu ───────────────────────────────────────────────────

class MatchButton extends StatefulWidget {
  const MatchButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<MatchButton> createState() => _MatchButtonState();
}

class _MatchButtonState extends State<MatchButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Eslestirme Ara',
      button: true,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          transform: Matrix4.diagonal3Values(
              _pressed ? 0.96 : 1.0, _pressed ? 0.96 : 1.0, 1.0),
          transformAlignment: Alignment.center,
          width: 240,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kColorClassic.withValues(alpha: 0.20),
                kColorClassic.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(UIConstants.radiusXl),
            border: Border.all(
                color: kColorClassic.withValues(alpha: 0.55), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: kColorClassic.withValues(alpha: 0.20),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_mma_rounded, color: kColorClassic, size: 22),
              SizedBox(width: 10),
              Text(
                'Eslestirme Ara',
                style: TextStyle(
                  color: kColorClassic,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Eslestirme bekleme gostergesi ───────────────────────────────────────────

class SearchingIndicator extends StatelessWidget {
  const SearchingIndicator({
    super.key,
    required this.waitSeconds,
    required this.pulseCtrl,
    required this.onCancel,
    required this.cancelLabel,
  });

  final int waitSeconds;
  final AnimationController pulseCtrl;
  final VoidCallback onCancel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Donen halka / pulse
        AnimatedBuilder(
          animation: pulseCtrl,
          builder: (_, __) {
            final scale = 1.0 + pulseCtrl.value * 0.15;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: kColorClassic.withValues(
                        alpha: 0.5 + pulseCtrl.value * 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kColorClassic.withValues(
                          alpha: 0.15 + pulseCtrl.value * 0.15),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: kColorClassic,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Rakip araniyor...',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.70),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${waitSeconds}sn / ${MatchmakingManager.maxWaitSeconds}sn',
          style: const TextStyle(
            color: kMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        Semantics(
          label: cancelLabel,
          button: true,
          child: GestureDetector(
            onTap: onCancel,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
              child: Center(
                child: Text(
                  cancelLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
