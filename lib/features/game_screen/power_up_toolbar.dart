import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../game/systems/powerup_system.dart';

/// Power-up tema renkleri
const kPowerUpColors = <PowerUpType, (Color, Color)>{
  PowerUpType.rotate: (kCyan, kPowerUpRotateBg),
  PowerUpType.bomb: (kPowerUpBombFg, kPowerUpBombBg),
  PowerUpType.undo: (kAmber, kPowerUpUndoBg),
  PowerUpType.freeze: (kPowerUpFreezeFg, kPowerUpFreezeBg),
};

class PowerUpToolbar extends StatelessWidget {
  const PowerUpToolbar({
    super.key,
    required this.balance,
    required this.powerUpSystem,
    required this.activePowerUpMode,
    required this.showFreeze,
    required this.onPowerUpTap,
    required this.strings,
  });

  final int balance;
  final PowerUpSystem powerUpSystem;
  final PowerUpType? activePowerUpMode;
  final bool showFreeze;
  final void Function(PowerUpType) onPowerUpTap;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          // Jel Ozu sayaci — damlacik tasarimi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kCyan.withValues(alpha: 0.12),
                  kCyan.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(UIConstants.radiusMd),
              border: Border.all(color: kCyan.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: kCyan.withValues(alpha: 0.08),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Jel damlacigi
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(-0.3, -0.4),
                      radius: 0.9,
                      colors: [
                        kCyan.withValues(alpha: 0.9),
                        kCyan.withValues(alpha: 0.4),
                        kCyan.withValues(alpha: 0.15),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kCyan.withValues(alpha: 0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 5,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$balance',
                  style: const TextStyle(
                    color: kCyan,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Power-up butonlari
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PowerUpButton(
                  type: PowerUpType.rotate,
                  icon: Icons.rotate_right,
                  label: strings.semanticsPowerUpRotate,
                  powerUpSystem: powerUpSystem,
                  isActive: activePowerUpMode == PowerUpType.rotate,
                  onTap: onPowerUpTap,
                ),
                _PowerUpButton(
                  type: PowerUpType.bomb,
                  icon: Icons.flash_on,
                  label: strings.semanticsPowerUpBomb,
                  powerUpSystem: powerUpSystem,
                  isActive: activePowerUpMode == PowerUpType.bomb,
                  onTap: onPowerUpTap,
                ),
                _PowerUpButton(
                  type: PowerUpType.undo,
                  icon: Icons.replay,
                  label: strings.semanticsPowerUpUndo,
                  powerUpSystem: powerUpSystem,
                  isActive: activePowerUpMode == PowerUpType.undo,
                  onTap: onPowerUpTap,
                ),
                if (showFreeze)
                  _PowerUpButton(
                    type: PowerUpType.freeze,
                    icon: Icons.ac_unit,
                    label: strings.semanticsPowerUpFreeze,
                    powerUpSystem: powerUpSystem,
                    isActive: activePowerUpMode == PowerUpType.freeze,
                    onTap: onPowerUpTap,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PowerUpButton extends StatefulWidget {
  const _PowerUpButton({
    required this.type,
    required this.icon,
    required this.label,
    required this.powerUpSystem,
    required this.isActive,
    required this.onTap,
  });

  final PowerUpType type;
  final IconData icon;
  final String label;
  final PowerUpSystem powerUpSystem;
  final bool isActive;
  final void Function(PowerUpType) onTap;

  @override
  State<_PowerUpButton> createState() => _PowerUpButtonState();
}

class _PowerUpButtonState extends State<_PowerUpButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final canUse = widget.powerUpSystem.canUse(widget.type);
    final def = kPowerUpDefs[widget.type]!;
    final effectiveCost = widget.powerUpSystem.getEffectiveCost(widget.type);
    final cooldown = widget.powerUpSystem.getCooldown(widget.type);
    final colors = kPowerUpColors[widget.type]!;
    final primary = colors.$1;
    final dark = colors.$2;

    return Semantics(
      label: widget.label,
      button: true,
      enabled: canUse,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: canUse ? () => widget.onTap(widget.type) : null,
          onTapDown: canUse ? (_) => setState(() => _pressed = true) : null,
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 80),
            // AnimatedContainer kept intentionally: animates isActive (selection)
            // and canUse state transitions, not just hover. Hover changes are
            // visually blended within the same 220ms transition.
            child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: canUse
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primary.withValues(
                            alpha: widget.isActive
                                ? 0.35
                                : _hovered
                                    ? 0.24
                                    : 0.18),
                        dark.withValues(
                            alpha: widget.isActive
                                ? 0.25
                                : _hovered
                                    ? 0.15
                                    : 0.10),
                      ],
                    )
                  : null,
              color: canUse ? null : Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(UIConstants.radiusMd),
              border: Border.all(
                color: widget.isActive
                    ? primary.withValues(alpha: 0.9)
                    : canUse
                        ? primary.withValues(
                            alpha: _hovered ? 0.50 : 0.35)
                        : Colors.white.withValues(alpha: 0.06),
                width: widget.isActive ? 1.5 : 1,
              ),
              boxShadow: widget.isActive
                  ? [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.35),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: primary.withValues(alpha: 0.15),
                        blurRadius: 4,
                      ),
                    ]
                  : canUse
                      ? [
                          BoxShadow(
                            color: primary.withValues(
                                alpha: _hovered ? 0.18 : 0.10),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
            ),
            child: Stack(
              children: [
                // Specular highlight — jel etkisi
                if (canUse)
                  Positioned(
                    top: 3,
                    left: 5,
                    right: 12,
                    height: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Ana ikon
                Center(
                  child: Icon(
                    widget.icon,
                    size: 22,
                    color:
                        canUse ? primary : Colors.white.withValues(alpha: 0.18),
                    shadows: canUse
                        ? [
                            Shadow(
                              color: primary.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
                // Maliyet badge — jel kapsul
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: canUse
                          ? primary.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: canUse
                            ? primary.withValues(alpha: 0.25)
                            : Colors.transparent,
                        width: 0.5,
                      ),
                    ),
                    child: effectiveCost > def.cost
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${def.cost}',
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 8,
                                  color: kMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '$effectiveCost',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: kAmber,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            '$effectiveCost',
                            style: TextStyle(
                              color: canUse
                                  ? primary
                                  : kMuted.withValues(alpha: 0.5),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
                // Cooldown overlay
                if (cooldown > 0)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius:
                            BorderRadius.circular(UIConstants.radiusMd),
                        border: Border.all(
                          color: primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$cooldown',
                          style: TextStyle(
                            color: primary.withValues(alpha: 0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
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
