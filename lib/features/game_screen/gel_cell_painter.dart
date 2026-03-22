import 'dart:math' as math;

import 'package:flutter/material.dart';

/// [Animation<double>] degerini belirli adimlara kuantize ederek
/// yalnizca gorsel fark esigini asan degisimlerde bildirim gonderen wrapper.
///
/// Ornegin `step = 0.05` ise 0→1 araliginda ~20 farkli deger uretilir.
/// Bu, CustomPainter repaint sayisini ~3x azaltir (60fps → ~20fps nefes).
///
/// Ayni [Animation] icin tekrar tekrar wrapper olusturmak yerine,
/// [getInstance] ile paylasilan tek bir instance kullanilir.
class QuantizedBreathListenable extends ChangeNotifier {
  QuantizedBreathListenable._(this._source, this._step)
      : _lastQuantized = _quantize(_source.value, _step) {
    _source.addListener(_onTick);
  }

  /// Ayni [source] animasyonu icin paylasilan instance dondurur.
  /// Her [AnimationController] basina tek bir wrapper olusturulur.
  static final _cache = Expando<QuantizedBreathListenable>();

  static QuantizedBreathListenable getInstance(
    Animation<double> source, {
    double step = 0.05,
  }) {
    var instance = _cache[source];
    if (instance == null) {
      instance = QuantizedBreathListenable._(source, step);
      _cache[source] = instance;
    }
    return instance;
  }

  final Animation<double> _source;
  final double _step;
  double _lastQuantized;

  double get value => _source.value;

  static double _quantize(double v, double step) =>
      (v / step).roundToDouble() * step;

  void _onTick() {
    final q = _quantize(_source.value, _step);
    if (q != _lastQuantized) {
      _lastQuantized = q;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _source.removeListener(_onTick);
    super.dispose();
  }
}

/// Jel hucresini 3B derinlik hissiyle render eden CustomPainter.
///
/// Render katmanlari (alttan uste):
/// 1. Dis glow — hucre arkasindaki yumusak isik yayilimi
/// 2. Ic degrade govde — sol ust isik kaynagi ile RadialGradient
/// 3. Ince kenar cizgisi — hucre siniri
/// 4. Specular highlight — yuzey gerilimi yansimasi (nefes ile module)
/// 5. Alt kenar golgesi — "yuzeyden yukselme" illuzyonu
/// 6. Ic parlama noktasi — specular merkezinde ekstra beyaz nokta
///
/// [isGlowing] sentez aninda hucreyi daha parlak render eder:
/// dis glow blur/alpha artar, specular ve ic parlama sabit yuksek alpha kullanir.
///
/// [isRecentlyPlaced] yeni yerlestirilmis hucrelerde specular ve glow uzerinde
/// kisaca kisa sureli "jel basinci" modülasyonu uygular (Yaklasim B).
/// Nefes animasyonu uzerinden suruluyor — reduce motion'da otomatik susar.
class GelCellPainter extends CustomPainter {
  GelCellPainter({
    required this.color,
    required this.borderRadius,
    required Animation<double> breathAnimation,
    required this.breathPhase,
    this.isGlowing = false,
    this.isRecentlyPlaced = false,
  })  : _breathAnim = breathAnimation,
        super(
          repaint: QuantizedBreathListenable.getInstance(breathAnimation),
        );

  final Color color;
  final double borderRadius;
  final Animation<double> _breathAnim;

  /// Hucre bazli faz ofseti (radyan). Dalga seklinde nefes icin.
  final double breathPhase;

  /// Sentez aninda hucreyi daha parlak gosterir.
  /// Dis glow blur/alpha artar; specular ve ic parlama sabit yuksek alpha kullanir.
  final bool isGlowing;

  /// Yeni yerlestirilmis hucre: specular highlight Y kayması ve glow alpha'sinda
  /// kisaca ekstra modülasyon ("jel iç ışık basıncı" hissi).
  /// Nefes animasyonunun ilk yarı döngüsündeki pozitif fazı kullanır.
  /// Reduce motion'da nefes duruyorsa bu efekt de otomatik susar.
  final bool isRecentlyPlaced;

  // ── Cached paint objects ────────────────────────────────────────────────
  Shader? _cachedBodyShader;
  Size? _cachedBodyShaderSize;
  Color? _cachedBodyShaderColor;

  Paint? _cachedGlowPaint;
  Color? _cachedGlowColor;
  bool? _cachedGlowState;
  bool? _cachedRecentlyPlaced;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width; // kare hucre
    if (s <= 0) return;

    final breathMod = math.sin(_breathAnim.value * 2 * math.pi + breathPhase);

    // isRecentlyPlaced modülasyonu: nefes animasyonunun pozitif fazından
    // türetilen tek bir skaler (0.0–1.0). Subtle "jel basıncı" hissi için.
    // breathMod aralığı -1..1; pozitif fazı sıkıştırma anına karşılık gelir.
    final placedMod = isRecentlyPlaced ? breathMod.clamp(0.0, 1.0) : 0.0;

    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // ── 1. Dis glow — hucrenin altinda renkli isik halkasi ───────────────
    // isRecentlyPlaced: glow alpha'sı +0.10 * placedMod ekstra parlaklık.
    // Cache: statik durum icin tekrar kullan; isRecentlyPlaced aktifken
    // placedMod her nefes tickinde degisir, o yuzden cache atlaniyor.
    if (!isRecentlyPlaced) {
      if (_cachedGlowPaint == null ||
          _cachedGlowColor != color ||
          _cachedGlowState != isGlowing ||
          _cachedRecentlyPlaced != false) {
        _cachedGlowColor = color;
        _cachedGlowState = isGlowing;
        _cachedRecentlyPlaced = false;
        _cachedGlowPaint = Paint()
          ..color = color.withValues(alpha: isGlowing ? 0.60 : 0.40)
          ..maskFilter =
              MaskFilter.blur(BlurStyle.normal, isGlowing ? 12 : 6);
      }
      canvas.drawRRect(rrect.inflate(2.0), _cachedGlowPaint!);
    } else {
      // isRecentlyPlaced: cache yok — her tick taze alpha ile ciz.
      _cachedGlowPaint = null; // bir sonraki normal state icin temizle
      _cachedRecentlyPlaced = true;
      final baseAlpha = isGlowing ? 0.60 : 0.40;
      canvas.drawRRect(
        rrect.inflate(2.0),
        Paint()
          ..color = color.withValues(
              alpha: (baseAlpha + placedMod * 0.10).clamp(0.0, 1.0))
          ..maskFilter =
              MaskFilter.blur(BlurStyle.normal, isGlowing ? 12 : 6),
      );
    }

    // ── 2. Ic degrade govde — sol ust isik kaynagi → sag alt golge ──────
    //    Yuksek kontrast: acik ust-sol, koyu alt-sag → 3B derinlik
    if (_cachedBodyShader == null ||
        _cachedBodyShaderSize != size ||
        _cachedBodyShaderColor != color) {
      _cachedBodyShaderSize = size;
      _cachedBodyShaderColor = color;
      _cachedBodyShader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 1.1,
        colors: [
          _lighten(color, 0.42), // parlak ust-sol
          color, // orta ton
          _darken(color, 0.25), // koyu alt-sag
        ],
        stops: const [0.0, 0.40, 1.0],
      ).createShader(rect);
    }
    final bodyPaint = Paint()..shader = _cachedBodyShader;
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
    //    isRecentlyPlaced: Y pozisyonu hafif kayar (max ±5% cellHeight),
    //    alpha biraz artar — "jel içi ışık yayılır" hissi.
    final specAlpha =
        isGlowing ? 0.90 : (0.62 + 0.18 * breathMod).clamp(0.0, 1.0);
    final hlW = s * 0.55;
    final hlH = s * 0.30;
    final hlX = s * 0.10 + s * 0.012 * breathMod;
    // isRecentlyPlaced: specular Y aşağı kayar (sıkışma hissi, max %5)
    final hlY = s * 0.06 + s * 0.008 * breathMod + s * 0.05 * placedMod;
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
    //    Speculer highlight'in merkezinde ekstra beyaz nokta.
    //    isRecentlyPlaced: yarıçap basınçla büyür (max +%30), subtle pulse.
    final dotAlpha =
        isGlowing ? 0.60 : (0.35 + 0.12 * breathMod).clamp(0.0, 1.0);
    final dotRadius = s * 0.06 * (1.0 + placedMod * 0.30);
    canvas.drawCircle(
      Offset(s * 0.28 + s * 0.01 * breathMod, s * 0.18),
      dotRadius,
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
      old.color != color ||
      old.borderRadius != borderRadius ||
      old.breathPhase != breathPhase ||
      old.isGlowing != isGlowing ||
      old.isRecentlyPlaced != isRecentlyPlaced;
}
