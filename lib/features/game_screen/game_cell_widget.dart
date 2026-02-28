import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../game/systems/powerup_system.dart';
import '../../game/world/cell_type.dart';
import 'gel_cell_painter.dart';

/// Tek bir izgara hucresini render eden widget.
class GameCellWidget extends StatelessWidget {
  const GameCellWidget({
    super.key,
    required this.row,
    required this.col,
    required this.gridCell,
    required this.cellColor,
    required this.isPreview,
    required this.colorBlindMode,
    required this.cols,
    required this.breathCtrl,
    required this.recentlyPlacedCells,
    required this.waveKey,
    required this.previewValid,
    required this.previewSlotColor,
    required this.selectedSlot,
    required this.activePowerUpMode,
    required this.onTap,
    required this.onHover,
  });

  final int row;
  final int col;
  final Cell gridCell;
  final GelColor? cellColor;
  final bool isPreview;
  final bool colorBlindMode;
  final int cols;
  final AnimationController breathCtrl;
  final Set<(int, int)> recentlyPlacedCells;
  final int waveKey;
  final bool previewValid;
  final GelColor? previewSlotColor;
  final int? selectedSlot;
  final PowerUpType? activePowerUpMode;
  final VoidCallback onTap;
  final VoidCallback onHover;

  @override
  Widget build(BuildContext context) {
    // Stone hucreler: koyu, yerlestirilemez
    if (gridCell.type == CellType.stone) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(UIConstants.radiusXs),
          border: Border.all(
            color: const Color(0xFF2A2A4E),
            width: 1,
          ),
        ),
      );
    }

    // Hucre tipi overlay'leri
    Widget? typeOverlay;
    if (gridCell.type == CellType.ice && gridCell.iceLayer > 0) {
      typeOverlay = Container(
        decoration: BoxDecoration(
          color: const Color(0xFF88CCFF).withValues(
            alpha: gridCell.iceLayer == 2 ? 0.45 : 0.25,
          ),
          borderRadius: BorderRadius.circular(UIConstants.radiusXs),
          border: Border.all(
            color: const Color(0xFFAADDFF).withValues(alpha: 0.5),
            width: gridCell.iceLayer == 2 ? 2 : 1,
          ),
        ),
      );
    } else if (gridCell.type == CellType.locked) {
      final lockColor = gridCell.lockedColor?.displayColor ?? Colors.grey;
      typeOverlay = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UIConstants.radiusXs),
          border: Border.all(color: lockColor, width: 2),
        ),
        child: cellColor == null
            ? Center(
                child: Icon(Icons.lock_outline,
                    size: 10, color: lockColor.withValues(alpha: 0.7)),
              )
            : null,
      );
    } else if (gridCell.type == CellType.gravity) {
      typeOverlay = Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 2,
          margin: const EdgeInsets.only(bottom: 1, left: 2, right: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      );
    } else if (gridCell.type == CellType.rainbow) {
      if (cellColor == null) {
        typeOverlay = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UIConstants.radiusXs),
            border: Border.all(
              color: const Color(0xFFFF69B4).withValues(alpha: 0.5),
              width: 1,
            ),
            gradient: const LinearGradient(
              colors: [
                Color(0x22FF3B3B),
                Color(0x22FFE03C),
                Color(0x223CFF8B),
                Color(0x223C8BFF),
              ],
            ),
          ),
        );
      }
    }

    // Hucre icerigi
    Widget cellContent;

    if (cellColor != null) {
      // DOLU HUCRE — Protokol 1: GelCellPainter ile jel render
      cellContent = RepaintBoundary(
        child: CustomPaint(
          painter: GelCellPainter(
            color: cellColor!.displayColor,
            borderRadius: UIConstants.radiusXs,
            breathAnimation: breathCtrl,
            breathPhase: (row * cols + col) * 0.12,
          ),
          child: colorBlindMode
              ? Center(
                  child: Text(
                    cellColor!.shortLabel,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                )
              : null,
        ),
      );

      // Protokol 2: Squash & Stretch yerlestirme animasyonu
      cellContent = SquashStretchCell(
        key: ValueKey(('ss', row, col)),
        isPlaced: true,
        child: cellContent,
      );

      // Protokol 2: Dalga yayilimi — komsu hucrelere bounce
      if (recentlyPlacedCells.isNotEmpty &&
          !recentlyPlacedCells.contains((row, col))) {
        int minDist = 999;
        for (final placed in recentlyPlacedCells) {
          final d = (placed.$1 - row).abs() + (placed.$2 - col).abs();
          if (d < minDist) minDist = d;
        }
        if (minDist <= 3) {
          cellContent = WaveRipple(
            key: ValueKey(('wave', row, col, waveKey)),
            distance: minDist,
            child: cellContent,
          );
        }
      }
    } else if (isPreview) {
      // PREVIEW HUCRE
      final base = previewSlotColor?.displayColor ?? Colors.white;
      final bg = previewValid
          ? base.withValues(alpha: 0.50)
          : const Color(0xFFFF3B3B).withValues(alpha: 0.55);
      cellContent = Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(UIConstants.radiusXs),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 1,
          ),
        ),
      );
    } else {
      // BOS HUCRE — hafif derinlik hissi icin RadialGradient
      cellContent = Container(
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            center: Alignment(-0.3, -0.3),
            radius: 1.4,
            colors: [
              Color(0x26FFFFFF), // alpha ~0.15
              Color(0x14FFFFFF), // alpha ~0.08
            ],
          ),
          borderRadius: BorderRadius.circular(UIConstants.radiusXs),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => onHover(),
      cursor: selectedSlot != null || activePowerUpMode == PowerUpType.bomb
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            cellContent,
            if (typeOverlay != null) Positioned.fill(child: typeOverlay),
          ],
        ),
      ),
    );
  }
}

// ─── Protokol 2: Squash & Stretch yerlestirme animasyonu ────────────────────

/// Hucre doldugunda 4 fazli squash & stretch animasyonu oynatir.
class SquashStretchCell extends StatefulWidget {
  const SquashStretchCell({
    super.key,
    required this.isPlaced,
    required this.child,
  });

  final bool isPlaced;
  final Widget child;

  @override
  State<SquashStretchCell> createState() => _SquashStretchCellState();
}

class _SquashStretchCellState extends State<SquashStretchCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _prevPlaced = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    if (widget.isPlaced) {
      _ctrl.forward(from: 0);
      _prevPlaced = true;
    }
  }

  @override
  void didUpdateWidget(SquashStretchCell old) {
    super.didUpdateWidget(old);
    if (widget.isPlaced && !_prevPlaced) {
      _ctrl.forward(from: 0);
    } else if (!widget.isPlaced && _prevPlaced) {
      _ctrl.value = 0;
    }
    _prevPlaced = widget.isPlaced;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaced) return widget.child;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final p = _ctrl.value;
        if (p >= 0.99) return widget.child;

        double scaleX, scaleY;

        if (p < 0.16) {
          // Faz 1: Anticipation — hafif buyume
          final t = Curves.easeOutQuad.transform(p / 0.16);
          scaleX = scaleY = 1.0 + 0.08 * t;
        } else if (p < 0.32) {
          // Faz 2: Impact — SQUASH
          final t = Curves.easeInQuad.transform((p - 0.16) / 0.16);
          scaleX = 1.08 + (1.15 - 1.08) * t;
          scaleY = 1.08 + (0.82 - 1.08) * t;
        } else if (p < 0.53) {
          // Faz 3: Overshoot — STRETCH
          final t = Curves.easeOutQuad.transform((p - 0.32) / 0.21);
          scaleX = 1.15 + (1.0 - 1.15) * t;
          scaleY = 0.82 + (1.06 - 0.82) * t;
        } else {
          // Faz 4: Settle
          final t = Curves.easeInOutSine.transform((p - 0.53) / 0.47);
          scaleX = 1.0;
          scaleY = 1.06 + (1.0 - 1.06) * t;
        }

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(scaleX, scaleY, 1.0),
          child: widget.child,
        );
      },
    );
  }
}

// ─── Protokol 2: Dalga yayilimi (Wave Ripple) ──────────────────────────────

/// Yerlestirme noktasina yakin dolu hucrelere geciktirilmis bounce efekti.
class WaveRipple extends StatefulWidget {
  const WaveRipple({
    super.key,
    required this.distance,
    required this.child,
  });

  final int distance;
  final Widget child;

  @override
  State<WaveRipple> createState() => _WaveRippleState();
}

class _WaveRippleState extends State<WaveRipple>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    Future.delayed(Duration(milliseconds: widget.distance * 25), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        if (!_ctrl.isAnimating && _ctrl.value <= 0) return widget.child;
        if (_ctrl.isCompleted) return widget.child;

        final magnitude = 0.03 / (1.0 + widget.distance * 0.6);
        final t = Curves.easeOutSine.transform(_ctrl.value);
        final bounce = magnitude * math.sin(t * math.pi);
        final scale = 1.0 + bounce;

        return Transform.scale(
          scale: scale,
          child: widget.child,
        );
      },
    );
  }
}
