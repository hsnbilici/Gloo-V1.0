import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../game/systems/powerup_system.dart';

/// Power-up tema renkleri
const kPowerUpColors = <PowerUpType, (Color, Color)>{
  PowerUpType.rotate: (Color(0xFF00E5FF), Color(0xFF006978)),
  PowerUpType.bomb:   (Color(0xFFFF6B35), Color(0xFF8B2500)),
  PowerUpType.undo:   (Color(0xFFFFD740), Color(0xFF8B6914)),
  PowerUpType.freeze: (Color(0xFF80D8FF), Color(0xFF01579B)),
};

class PowerUpToolbar extends StatelessWidget {
  const PowerUpToolbar({
    super.key,
    required this.balance,
    required this.powerUpSystem,
    required this.activePowerUpMode,
    required this.showFreeze,
    required this.onPowerUpTap,
  });

  final int balance;
  final PowerUpSystem powerUpSystem;
  final PowerUpType? activePowerUpMode;
  final bool showFreeze;
  final void Function(PowerUpType) onPowerUpTap;

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
                  powerUpSystem: powerUpSystem,
                  isActive: activePowerUpMode == PowerUpType.rotate,
                  onTap: onPowerUpTap,
                ),
                _PowerUpButton(
                  type: PowerUpType.bomb,
                  icon: Icons.flash_on,
                  powerUpSystem: powerUpSystem,
                  isActive: activePowerUpMode == PowerUpType.bomb,
                  onTap: onPowerUpTap,
                ),
                _PowerUpButton(
                  type: PowerUpType.undo,
                  icon: Icons.replay,
                  powerUpSystem: powerUpSystem,
                  isActive: activePowerUpMode == PowerUpType.undo,
                  onTap: onPowerUpTap,
                ),
                if (showFreeze)
                  _PowerUpButton(
                    type: PowerUpType.freeze,
                    icon: Icons.ac_unit,
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

class _PowerUpButton extends StatelessWidget {
  const _PowerUpButton({
    required this.type,
    required this.icon,
    required this.powerUpSystem,
    required this.isActive,
    required this.onTap,
  });

  final PowerUpType type;
  final IconData icon;
  final PowerUpSystem powerUpSystem;
  final bool isActive;
  final void Function(PowerUpType) onTap;

  @override
  Widget build(BuildContext context) {
    final canUse = powerUpSystem.canUse(type);
    final def = kPowerUpDefs[type]!;
    final cooldown = powerUpSystem.getCooldown(type);
    final colors = kPowerUpColors[type]!;
    final primary = colors.$1;
    final dark = colors.$2;

    return GestureDetector(
      onTap: canUse ? () => onTap(type) : null,
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
                    primary.withValues(alpha: isActive ? 0.35 : 0.18),
                    dark.withValues(alpha: isActive ? 0.25 : 0.10),
                  ],
                )
              : null,
          color: canUse ? null : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(UIConstants.radiusMd),
          border: Border.all(
            color: isActive
                ? primary.withValues(alpha: 0.9)
                : canUse
                    ? primary.withValues(alpha: 0.35)
                    : Colors.white.withValues(alpha: 0.06),
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
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
                        color: primary.withValues(alpha: 0.10),
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
                icon,
                size: 22,
                color: canUse
                    ? primary
                    : Colors.white.withValues(alpha: 0.18),
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
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
                child: Text(
                  '${def.cost}',
                  style: TextStyle(
                    color: canUse ? primary : kMuted.withValues(alpha: 0.5),
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
                    borderRadius: BorderRadius.circular(UIConstants.radiusMd),
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
    );
  }
}
