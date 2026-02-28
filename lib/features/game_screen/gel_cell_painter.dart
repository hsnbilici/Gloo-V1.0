import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Jel hucresini 3B derinlik hissiyle render eden CustomPainter.
///
/// Render katmanlari (alttan uste):
/// 1. Dis glow — hucre arkasindaki yumusak isik yayilimi
/// 2. Ic degrade govde — sol ust isik kaynagi ile RadialGradient
/// 3. Ince kenar cizgisi — hucre siniri
/// 4. Specular highlight — yuzey gerilimi yansimasi (nefes ile module)
/// 5. Alt kenar golgesi — "yuzeyden yukselme" illuzyonu
class GelCellPainter extends CustomPainter {
  GelCellPainter({
    required this.color,
    required this.borderRadius,
    required Animation<double> breathAnimation,
    required this.breathPhase,
  })  : _breathAnim = breathAnimation,
        super(repaint: breathAnimation);

  final Color color;
  final double borderRadius;
  final Animation<double> _breathAnim;

  /// Hucre bazli faz ofseti (radyan). Dalga seklinde nefes icin.
  final double breathPhase;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width; // kare hucre
    if (s <= 0) return;

    final breathMod =
        math.sin(_breathAnim.value * 2 * math.pi + breathPhase);

    final rect = Offset.zero & size;
    final rrect =
        RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // ── 1. Dis glow — hucrenin altinda renkli isik halkasi ───────────────
    canvas.drawRRect(
      rrect.inflate(2.0),
      Paint()
        ..color = color.withValues(alpha: 0.40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // ── 2. Ic degrade govde — sol ust isik kaynagi → sag alt golge ──────
    //    Yuksek kontrast: acik ust-sol, koyu alt-sag → 3B derinlik
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 1.1,
        colors: [
          _lighten(color, 0.42), // parlak ust-sol
          color,                  // orta ton
          _darken(color, 0.25),   // koyu alt-sag
        ],
        stops: const [0.0, 0.40, 1.0],
      ).createShader(rect);
    canvas.drawRRect(rrect, bodyPaint);

    // ── 3. Ince ust kenar parlama — "isik vuruyor" hissi ────────────────
    //    Ust kenar boyunca beyaz cizgi (hucre balonunun ust siniri)
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // ── 4. Specular highlight — genis, belirgin beyaz elips ─────────────
    //    Buyuk boyut + yuksek alpha → "plastik/jel" parlaklik
    final specAlpha = (0.62 + 0.18 * breathMod).clamp(0.0, 1.0);
    final hlW = s * 0.55;
    final hlH = s * 0.30;
    final hlX = s * 0.10 + s * 0.012 * breathMod;
    final hlY = s * 0.06 + s * 0.008 * breathMod;
    final hlRect = Rect.fromLTWH(hlX, hlY, hlW, hlH);

    canvas.drawOval(
      hlRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.1, 0.1),
          radius: 0.80,
          colors: [
            Colors.white.withValues(alpha: specAlpha),
            Colors.white.withValues(alpha: specAlpha * 0.35),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.50, 1.0],
        ).createShader(hlRect),
    );

    // ── 5. Alt kenar golge — hucrenin "yukseldigini" gosteren koyu egri ──
    final shadowPath = Path()
      ..moveTo(s * 0.18, s * 0.84)
      ..quadraticBezierTo(s * 0.5, s * 0.95, s * 0.82, s * 0.84);
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = _darken(color, 0.40).withValues(alpha: 0.40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );

    // ── 6. Ek: ic parlama noktasi (kucuk, keskin) ──────────────────────
    //    Speculer highlight'in merkezinde ekstra beyaz nokta
    final dotAlpha = (0.35 + 0.12 * breathMod).clamp(0.0, 1.0);
    canvas.drawCircle(
      Offset(s * 0.28 + s * 0.01 * breathMod, s * 0.18),
      s * 0.06,
      Paint()..color = Colors.white.withValues(alpha: dotAlpha),
    );
  }

  // ── Renk yardimcilari ──────────────────────────────────────────────────

  static Color _lighten(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  static Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  bool shouldRepaint(GelCellPainter old) =>
      old.color != color || old.borderRadius != borderRadius;
}
