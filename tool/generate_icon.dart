// tool/generate_icon.dart
//
// Gloo uygulama ikonu olusturucu.
// Kullanim: dart run tool/generate_icon.dart
//
// Cikti:
//   assets/icon/app_icon.png          (1024x1024 — master ikon)
//   assets/icon/app_icon_foreground.png (1024x1024 — Android adaptive foreground)

// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

// Marka renkleri
const int kBgDarkR = 0x01, kBgDarkG = 0x0C, kBgDarkB = 0x14;
const int kBgLightR = 0x0A, kBgLightG = 0x16, kBgLightB = 0x28;
const int kCyanR = 0x00, kCyanG = 0xE5, kCyanB = 0xFF;

void main() {
  const size = 1024;

  print('Generating Gloo app icon (${size}x$size)...');

  final icon = _generateAppIcon(size);
  final foreground = _generateForeground(size);

  final dir = Directory('assets/icon');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  File('assets/icon/app_icon.png').writeAsBytesSync(img.encodePng(icon));
  print('  -> assets/icon/app_icon.png');

  File('assets/icon/app_icon_foreground.png')
      .writeAsBytesSync(img.encodePng(foreground));
  print('  -> assets/icon/app_icon_foreground.png');

  print('Done.');
}

/// Ana uygulama ikonu: koyu gradient arka plan + cyan jel damlasi + glow
img.Image _generateAppIcon(int size) {
  final image = img.Image(width: size, height: size);
  final center = size / 2;

  // 1) Radyal gradient arka plan (#010C14 merkez -> #0A1628 kenarlar)
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final dx = (x - center) / center;
      final dy = (y - center) / center;
      final dist = sqrt(dx * dx + dy * dy).clamp(0.0, 1.0);

      final r = _lerp(kBgDarkR, kBgLightR, dist);
      final g = _lerp(kBgDarkG, kBgLightG, dist);
      final b = _lerp(kBgDarkB, kBgLightB, dist);

      image.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  // 2) Glow efekti — buyuk, yumusak cyan halo
  _drawGlow(image, center, center, size * 0.38, kCyanR, kCyanG, kCyanB, 0.25);

  // 3) Jel damlasi (blob) sekli — merkeze
  _drawGelBlob(image, center, center, size * 0.28, kCyanR, kCyanG, kCyanB);

  // 4) Ic parlama — daha kucuk, daha parlak glow
  _drawGlow(image, center, center * 0.92, size * 0.18, 255, 255, 255, 0.12);

  // 5) Specular highlight — blob'un ust kisminda beyaz parlama
  _drawHighlight(image, center - size * 0.06, center - size * 0.12, size * 0.08,
      size * 0.04);

  return image;
}

/// Android adaptive icon foreground: seffaf arka plan + cyan jel damlasi + glow
/// Safe zone: merkezdeki %66'lik alan (her yonden %17 margin)
img.Image _generateForeground(int size) {
  final image = img.Image(width: size, height: size);

  // Tamamen seffaf baslat
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      image.setPixelRgba(x, y, 0, 0, 0, 0);
    }
  }

  final center = size / 2;

  // Glow
  _drawGlow(image, center, center, size * 0.32, kCyanR, kCyanG, kCyanB, 0.20);

  // Jel blob — biraz kucuk (safe zone icinde kalsin)
  _drawGelBlob(image, center, center, size * 0.22, kCyanR, kCyanG, kCyanB);

  // Ic parlama
  _drawGlow(image, center, center * 0.94, size * 0.14, 255, 255, 255, 0.10);

  // Specular highlight
  _drawHighlight(image, center - size * 0.04, center - size * 0.09, size * 0.06,
      size * 0.03);

  return image;
}

/// Yumusak radyal glow cizer (additive blending)
void _drawGlow(img.Image image, double cx, double cy, double radius, int cr,
    int cg, int cb, double maxAlpha) {
  final size = image.width;
  final r2 = radius * radius;

  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final dx = x - cx;
      final dy = y - cy;
      final d2 = dx * dx + dy * dy;

      if (d2 < r2) {
        final t = 1.0 - (d2 / r2);
        // Gaussian-benzeri falloff
        final intensity = t * t * maxAlpha;

        final pixel = image.getPixel(x, y);
        final pr = pixel.r.toInt();
        final pg = pixel.g.toInt();
        final pb = pixel.b.toInt();
        final pa = pixel.a.toInt();

        final nr = (pr + (cr * intensity)).round().clamp(0, 255);
        final ng = (pg + (cg * intensity)).round().clamp(0, 255);
        final nb = (pb + (cb * intensity)).round().clamp(0, 255);
        final na = (pa + (255 * intensity)).round().clamp(0, 255);

        image.setPixelRgba(x, y, nr, ng, nb, na);
      }
    }
  }
}

/// Jel damlasi / blob sekli cizer
/// Superellipse (squircle) tabanlı organik sekil
void _drawGelBlob(img.Image image, double cx, double cy, double radius, int cr,
    int cg, int cb) {
  final size = image.width;

  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final dx = (x - cx) / radius;
      final dy = (y - cy) / radius;

      // Superellipse formulü: |x|^n + |y|^n = 1, n=3 ile blob benzeri sekil
      // Alt kisim biraz tombul (damla efekti)
      final adx = dx.abs();
      final adjustedDy = dy < 0 ? dy * 0.85 : dy * 1.05; // Alt kisim uzun
      final ady = adjustedDy.abs();

      // Hafif dalga efekti icin sinusoidal perturbasyon
      final angle = atan2(dy, dx);
      final wobble = 1.0 + 0.04 * sin(angle * 3) + 0.02 * sin(angle * 5 + 1);

      final superDist = pow(adx, 3) + pow(ady, 3);
      final threshold = pow(wobble, 3);

      if (superDist < threshold) {
        // Kenar yumusatma (anti-aliasing)
        final edgeDist = (threshold - superDist) / threshold;
        final alpha = (edgeDist * 8.0).clamp(0.0, 1.0);

        // Gradient: merkezden kenara dogru koyulasan cyan
        final grad = (1.0 - (superDist / threshold)).clamp(0.0, 1.0);
        final brightR = _lerp(cr, (cr * 0.6).round(), 1.0 - grad);
        final brightG = _lerp(cg, (cg * 0.7).round(), 1.0 - grad);
        final brightB = _lerp(cb, (cb * 0.7).round(), 1.0 - grad);

        // Mevcut pixel ile blend
        final pixel = image.getPixel(x, y);
        final pr = pixel.r.toInt();
        final pg = pixel.g.toInt();
        final pb = pixel.b.toInt();
        final pa = pixel.a.toInt();

        final nr = _lerp(pr, brightR, alpha);
        final ng = _lerp(pg, brightG, alpha);
        final nb = _lerp(pb, brightB, alpha);
        final na = (pa + (255 * alpha)).round().clamp(0, 255);

        image.setPixelRgba(x, y, nr, ng, nb, na);
      }
    }
  }
}

/// Specular highlight — kucuk beyaz elips
void _drawHighlight(
    img.Image image, double cx, double cy, double rx, double ry) {
  final size = image.width;

  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final dx = (x - cx) / rx;
      final dy = (y - cy) / ry;
      final d2 = dx * dx + dy * dy;

      if (d2 < 1.0) {
        final t = 1.0 - d2;
        final intensity = t * t * t * 0.7; // Cubic falloff

        final pixel = image.getPixel(x, y);
        final pr = pixel.r.toInt();
        final pg = pixel.g.toInt();
        final pb = pixel.b.toInt();

        final nr = (pr + (255 * intensity)).round().clamp(0, 255);
        final ng = (pg + (255 * intensity)).round().clamp(0, 255);
        final nb = (pb + (255 * intensity)).round().clamp(0, 255);

        image.setPixelRgba(x, y, nr, ng, nb, 255);
      }
    }
  }
}

/// Lineer interpolasyon (int)
int _lerp(int a, int b, double t) {
  return (a + (b - a) * t).round().clamp(0, 255);
}
