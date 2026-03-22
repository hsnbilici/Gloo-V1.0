import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/utils/motion_utils.dart';
import '../../game/world/cell_type.dart';
import '../../providers/grid_state_provider.dart';
import '../../providers/locale_provider.dart';
import 'effects/cell_effects.dart';
import 'gel_cell_painter.dart';

/// Tek bir izgara hucresini render eden widget.
class GameCellWidget extends ConsumerWidget {
  const GameCellWidget({
    super.key,
    required this.row,
    required this.col,
    required this.colorBlindMode,
    required this.cols,
    required this.breathCtrl,
    required this.waveKey,
    required this.onTap,
    required this.onHover,
  });

  final int row;
  final int col;
  final bool colorBlindMode;
  final int cols;
  final AnimationController breathCtrl;
  final int waveKey;
  final VoidCallback onTap;
  final VoidCallback onHover;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(
      gridStateProvider.select((state) => state[(row, col)]),
    );

    if (data == null) {
      return const SizedBox.shrink();
    }

    // Stone hucreler: koyu, yerlestirilemez
    if (data.type == CellType.stone) {
      return Container(
        decoration: BoxDecoration(
          color: kSurfaceDeepNavy,
          borderRadius: BorderRadius.circular(UIConstants.radiusXs),
          border: Border.all(
            color: kSurfaceNavy,
            width: 1,
          ),
        ),
      );
    }

    // Hucre tipi overlay'leri
    Widget? typeOverlay;
    if (data.type == CellType.ice && data.iceLayer > 0) {
      typeOverlay = Container(
        decoration: BoxDecoration(
          color: kIceBlue.withValues(
            alpha: data.iceLayer == 2 ? 0.45 : 0.25,
          ),
          borderRadius: BorderRadius.circular(UIConstants.radiusXs),
          border: Border.all(
            color: kIceBlueBright.withValues(alpha: 0.5),
            width: data.iceLayer == 2 ? 2 : 1,
          ),
        ),
      );
    } else if (data.type == CellType.locked) {
      final lockColor = data.lockedColor?.displayColor ?? Colors.grey;
      typeOverlay = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UIConstants.radiusXs),
          border: Border.all(color: lockColor, width: 2),
        ),
        child: data.color == null
            ? Center(
                child: Icon(Icons.lock_outline,
                    size: 10, color: lockColor.withValues(alpha: 0.7)),
              )
            : null,
      );
    } else if (data.type == CellType.gravity) {
      typeOverlay = Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 2,
          margin: const EdgeInsets.only(bottom: 1, left: 2, right: 2),
          decoration: BoxDecoration(
            color: kGold.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      );
    } else if (data.type == CellType.rainbow) {
      if (data.color == null) {
        typeOverlay = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UIConstants.radiusXs),
            border: Border.all(
              color: kPink.withValues(alpha: 0.5),
              width: 1,
            ),
            gradient: const LinearGradient(
              colors: [
                kRainbowRed,
                kRainbowYellow,
                kRainbowGreen,
                kRainbowBlue,
              ],
            ),
          ),
        );
      }
    }

    // Hucre icerigi
    Widget cellContent;

    if (data.color != null) {
      // DOLU HUCRE — Protokol 1: GelCellPainter ile jel render
      cellContent = RepaintBoundary(
        child: CustomPaint(
          painter: GelCellPainter(
            color: data.color!.displayColor,
            borderRadius: UIConstants.radiusXs,
            breathAnimation: breathCtrl,
            breathPhase: (row * cols + col) * 0.12,
            isGlowing: data.isSynthesisResult,
          ),
          child: colorBlindMode
              ? CustomPaint(
                  painter: _ColorBlindPatternPainter(
                    data.color!,
                    data.color!.displayColor.computeLuminance() > 0.4,
                  ),
                  child: Center(
                    child: Text(
                      data.color!.shortLabel,
                      style: TextStyle(
                        color: data.color!.displayColor.computeLuminance() > 0.4
                            ? Colors.black87
                            : Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
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
      if (data.waveDistance >= 0 && data.waveDistance <= 3) {
        cellContent = WaveRipple(
          key: ValueKey(('wave', row, col, waveKey)),
          distance: data.waveDistance,
          child: cellContent,
        );
      }

      // Protokol: Sentez pulse efekti
      cellContent = SynthesisPulseCell(
        key: ValueKey(('synth_pulse', row, col)),
        isActive: data.isSynthesisResult,
        child: cellContent,
      );
    } else if (data.isPreview) {
      // PREVIEW HUCRE
      final base = data.previewSlotColor?.displayColor ?? Colors.white;
      final bg = data.previewValid
          ? base.withValues(alpha: 0.50)
          : kRed.withValues(alpha: 0.55);
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
    } else if (data.isNearlyFullRow && data.type != CellType.stone) {
      // BOS HUCRE — neredeyse dolu satir ipucu
      cellContent = Container(
        decoration: BoxDecoration(
          color: kAmber.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(UIConstants.radiusXs),
          border: Border.all(
            color: kAmber.withValues(alpha: 0.25),
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
              kCellEmptyLight, // alpha ~0.15
              kCellEmptyDark, // alpha ~0.08
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

    // Semantics label: hücre durumunu ekran okuyuculara bildirir
    final l = ref.watch(stringsProvider);
    final String semanticLabel;
    if (data.color != null) {
      semanticLabel = '${l.colorName(data.color!)} ${row + 1}, ${col + 1}';
    } else if (data.isPreview) {
      semanticLabel = '${l.semanticsCellPreview} ${row + 1}, ${col + 1}';
    } else if (data.type == CellType.stone) {
      semanticLabel = '${l.semanticsCellStone} ${row + 1}, ${col + 1}';
    } else if (data.type == CellType.ice) {
      semanticLabel = '${l.semanticsCellIce} ${data.iceLayer} ${row + 1}, ${col + 1}';
    } else if (data.type == CellType.locked) {
      semanticLabel = '${l.semanticsCellLocked} ${row + 1}, ${col + 1}';
    } else if (data.type == CellType.gravity) {
      semanticLabel = '${l.semanticsCellGravity} ${row + 1}, ${col + 1}';
    } else if (data.type == CellType.rainbow) {
      semanticLabel = '${l.semanticsCellRainbow} ${row + 1}, ${col + 1}';
    } else {
      semanticLabel = '${l.semanticsCellEmpty} ${row + 1}, ${col + 1}';
    }

    return Semantics(
      label: semanticLabel,
      button: data.isInteractive,
      child: MouseRegion(
        onEnter: (_) => onHover(),
        cursor:
            data.isInteractive ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              cellContent,
              if (typeOverlay != null) Positioned.fill(child: typeOverlay),
              if (data.isSynthesisResult)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(UIConstants.radiusXs),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.70),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (data.color?.displayColor ?? Colors.white)
                                .withValues(alpha: 0.50),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (data.isCompletionPreview)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(UIConstants.radiusXs),
                      border: Border.all(
                        color: kGreen.withValues(alpha: 0.40),
                        width: 1,
                      ),
                      color: kGreen.withValues(alpha: 0.06),
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
  AnimationController? _ctrl;
  bool _prevPlaced = false;

  AnimationController _ensureController() {
    return _ctrl ??= AnimationController(
      vsync: this,
      duration: AnimationDurations.dialog,
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.isPlaced) {
      _ensureController().forward(from: 0);
      _prevPlaced = true;
    }
  }

  @override
  void didUpdateWidget(SquashStretchCell old) {
    super.didUpdateWidget(old);
    if (widget.isPlaced && !_prevPlaced) {
      _ensureController().forward(from: 0);
    } else if (!widget.isPlaced && _prevPlaced) {
      _ctrl?.value = 0;
    }
    _prevPlaced = widget.isPlaced;
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaced || _ctrl == null) return widget.child;
    if (shouldReduceMotion(context)) return widget.child;

    return AnimatedBuilder(
      animation: _ctrl!,
      builder: (_, __) {
        final p = _ctrl!.value;
        if (p >= 0.99) return widget.child;

        double scaleX, scaleY;

        if (p < 0.16) {
          final t = Curves.easeOutQuad.transform(p / 0.16);
          scaleX = scaleY = 1.0 + 0.08 * t;
        } else if (p < 0.32) {
          final t = Curves.easeInQuad.transform((p - 0.16) / 0.16);
          scaleX = 1.08 + (1.15 - 1.08) * t;
          scaleY = 1.08 + (0.82 - 1.08) * t;
        } else if (p < 0.53) {
          final t = Curves.easeOutQuad.transform((p - 0.32) / 0.21);
          scaleX = 1.15 + (1.0 - 1.15) * t;
          scaleY = 0.82 + (1.06 - 0.82) * t;
        } else {
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
  AnimationController? _ctrl;
  Timer? _delayTimer;

  AnimationController _ensureController() {
    return _ctrl ??= AnimationController(
      vsync: this,
      duration: AnimationDurations.quick,
    );
  }

  @override
  void initState() {
    super.initState();
    _delayTimer = Timer(Duration(milliseconds: widget.distance * 25), () {
      if (mounted) _ensureController().forward();
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ctrl == null) return widget.child;
    if (shouldReduceMotion(context)) return widget.child;

    return AnimatedBuilder(
      animation: _ctrl!,
      builder: (_, __) {
        if (!_ctrl!.isAnimating && _ctrl!.value <= 0) return widget.child;
        if (_ctrl!.isCompleted) return widget.child;

        final magnitude = 0.03 / (1.0 + widget.distance * 0.6);
        final t = Curves.easeOutSine.transform(_ctrl!.value);
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

// ─── Renk Koru Modu: Sekil Deseni ──────────────────────────────────────────

/// Her GelColor icin farkli geometrik desen cizen CustomPainter.
/// Birincil renkler: basit sekiller (daire, kare, ucgen, elmas).
/// Sentez renkleri: cizgi desenleri (capraz, yatay, dikey, nokta vb.).
class _ColorBlindPatternPainter extends CustomPainter {
  _ColorBlindPatternPainter(this.gelColor, this.isDarkOnLight);

  final GelColor gelColor;
  final bool isDarkOnLight;

  Paint get _paint => Paint()
    ..color = isDarkOnLight ? Colors.black38 : Colors.white54
    ..strokeWidth = 1.2
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.shortestSide * 0.28;

    switch (gelColor) {
      // Birincil renkler — belirgin sekiller
      case GelColor.red:
        // Ucgen (yukari)
        final path = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r, cy + r * 0.7)
          ..lineTo(cx - r, cy + r * 0.7)
          ..close();
        canvas.drawPath(path, _paint);
      case GelColor.yellow:
        // Daire
        canvas.drawCircle(Offset(cx, cy), r, _paint);
      case GelColor.blue:
        // Kare
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset(cx, cy), width: r * 1.6, height: r * 1.6),
          _paint,
        );
      case GelColor.white:
        // Elmas (45 derece kare)
        final path = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r, cy)
          ..lineTo(cx, cy + r)
          ..lineTo(cx - r, cy)
          ..close();
        canvas.drawPath(path, _paint);

      // Sentez renkleri — cizgi desenleri
      case GelColor.orange:
        // Yatay cizgiler
        for (var y = cy - r; y <= cy + r; y += r * 0.7) {
          canvas.drawLine(Offset(cx - r, y), Offset(cx + r, y), _paint);
        }
      case GelColor.green:
        // Dikey cizgiler
        for (var x = cx - r; x <= cx + r; x += r * 0.7) {
          canvas.drawLine(Offset(x, cy - r), Offset(x, cy + r), _paint);
        }
      case GelColor.purple:
        // Capraz cizgiler (\)
        canvas.drawLine(Offset(cx - r, cy - r), Offset(cx + r, cy + r), _paint);
        canvas.drawLine(Offset(cx, cy - r), Offset(cx + r, cy), _paint);
        canvas.drawLine(Offset(cx - r, cy), Offset(cx, cy + r), _paint);
      case GelColor.pink:
        // X deseni
        canvas.drawLine(Offset(cx - r, cy - r), Offset(cx + r, cy + r), _paint);
        canvas.drawLine(Offset(cx + r, cy - r), Offset(cx - r, cy + r), _paint);
      case GelColor.lightBlue:
        // Arti (+) deseni
        canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), _paint);
        canvas.drawLine(Offset(cx - r, cy), Offset(cx + r, cy), _paint);
      case GelColor.lime:
        // Nokta deseni
        final dotPaint = Paint()
          ..color = isDarkOnLight ? Colors.black38 : Colors.white54
          ..style = PaintingStyle.fill;
        final dotR = r * 0.18;
        canvas.drawCircle(Offset(cx - r * 0.5, cy - r * 0.5), dotR, dotPaint);
        canvas.drawCircle(Offset(cx + r * 0.5, cy - r * 0.5), dotR, dotPaint);
        canvas.drawCircle(Offset(cx, cy), dotR, dotPaint);
        canvas.drawCircle(Offset(cx - r * 0.5, cy + r * 0.5), dotR, dotPaint);
        canvas.drawCircle(Offset(cx + r * 0.5, cy + r * 0.5), dotR, dotPaint);
      case GelColor.maroon:
        // Ucgen (asagi)
        final path = Path()
          ..moveTo(cx, cy + r)
          ..lineTo(cx + r, cy - r * 0.7)
          ..lineTo(cx - r, cy - r * 0.7)
          ..close();
        canvas.drawPath(path, _paint);
      case GelColor.brown:
        // Izgara deseni
        canvas.drawLine(Offset(cx - r, cy), Offset(cx + r, cy), _paint);
        canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), _paint);
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset(cx, cy), width: r * 1.4, height: r * 1.4),
          _paint,
        );
    }
  }

  @override
  bool shouldRepaint(_ColorBlindPatternPainter oldDelegate) =>
      gelColor != oldDelegate.gelColor ||
      isDarkOnLight != oldDelegate.isDarkOnLight;
}
