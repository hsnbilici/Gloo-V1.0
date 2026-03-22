import 'package:flutter/material.dart';

/// Ortak FadeTransition + ScaleTransition builder — dialog geçişlerinde kullanılır.
Widget fadeScaleTransition(
  BuildContext context,
  Animation<double> anim,
  Animation<double> _,
  Widget? child,
) {
  return FadeTransition(
    opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
    child: ScaleTransition(
      scale: Tween<double>(begin: 0.96, end: 1.0).animate(
        CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
      ),
      child: child,
    ),
  );
}

abstract final class UIConstants {
  // ─── Border radius skalası ────────────────────────────────────────────────
  /// Dekoratif mini elementler: bölüm aksan çubuğu, bottom sheet tutamağı.
  static const double radiusXxs = 2.0;

  /// Izgara hücreleri, küçük etiketler, track/bar köşeleri.
  static const double radiusXs = 6.0;

  /// Rozetler, küçük butonlar, mod etiketleri.
  static const double radiusSm = 8.0;

  /// Kartlar, el slotları, orta butonlar.
  static const double radiusMd = 12.0;

  /// Liste karoları ve aksiyon butonları.
  static const double radiusTile = 14.0;

  /// Büyük mod kartları, ana CTA butonları.
  static const double radiusLg = 16.0;

  /// Bottom bar, mod rozetleri.
  static const double radiusXl = 20.0;

  /// Dialog container ve bottom sheet üst köşeleri.
  static const double radiusXxl = 24.0;

  // ─── Yatay kenar boşlukları ───────────────────────────────────────────────
  /// Ana ekranlar: HomeScreen, SettingsScreen.
  static const double hPaddingScreen = 24.0;

  /// Kart ve panel içi: GameOverlay, GameOverOverlay butonları.
  static const double hPaddingCard = 16.0;

  /// Izgara kenar boşluğu: GameScreen.
  static const double hPaddingGrid = 12.0;
}

/// Centralized vertical spacing — eliminates ad-hoc SizedBox(height:) magic numbers.
abstract final class Spacing {
  /// Micro: metin satirlari arasi, ikon-metin ayrimi.
  static const double xxs = 2.0;

  /// Tiny: eleman ici bosluk, divider margin.
  static const double xs = 4.0;

  /// Small: kompakt liste ogeleri, kart ici minimum.
  static const double sm = 8.0;

  /// Base: standart kart ici, toggle satiri, badge arasi.
  static const double md = 12.0;

  /// Medium: bolum ici paragraf arasi, buton gruplari.
  static const double lg = 16.0;

  /// Large: bolumler arasi, ekran ici ana kesimler.
  static const double xl = 20.0;

  /// XL: buyuk bolum kesmeleri, overlay ici.
  static const double xxl = 24.0;

  /// XXL: ekran ust/alt padding, ayirici alanlar.
  static const double xxxl = 32.0;
}

/// Centralized text styles — reduces inline TextStyle boilerplate.
///
/// Kullanim: `style: AppTextStyles.heading` veya
/// `style: AppTextStyles.body.copyWith(color: kCyan)`
abstract final class AppTextStyles {
  // ─── Headings — Syne (kimlik fontu) ────────────────────────────────────
  /// Ekran basligi (32px): overlay title, game over.
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    fontFamily: 'Syne',
    height: 1.1,
  );

  /// Orta baslik (18px): ekran title, section header.
  static const TextStyle heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    fontFamily: 'Syne',
    height: 1.2,
  );

  /// Kucuk baslik (16px): kart basligi, mod adi.
  static const TextStyle subheading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    fontFamily: 'Syne',
    height: 1.2,
  );

  // ─── Body — Platform default (okunabilirlik) ────────────────────────────
  /// Ana govde metni (14px): aciklamalar, liste ogeleri.
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: null,
    height: 1.4,
  );

  /// Ikincil govde (13px): alt aciklamalar, yardimci metin.
  static const TextStyle bodySecondary = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    fontFamily: null,
    height: 1.4,
  );

  // ─── Labels & Captions — Platform default (okunabilirlik) ──────────────
  /// Etiket (11px): badge, meta bilgi, kucuk label.
  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    fontFamily: null,
    height: 1.2,
  );

  /// Kucuk etiket (10px): bottom bar, minimal text.
  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    fontFamily: null,
    height: 1.2,
  );

  /// Mikro etiket (8-9px): badge ici, grid label.
  static const TextStyle micro = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w800,
    fontFamily: null,
    height: 1.0,
  );
}

/// Centralized animation durations — reduces magic numbers across features.
abstract final class AnimationDurations {
  // ─── Micro feedback ──────────────────────────────────────────────────────
  /// Button taps, overlay entrance animations.
  static const Duration micro = Duration(milliseconds: 80);

  /// Standard haptic/visual feedback delay.
  static const Duration feedback = Duration(milliseconds: 100);

  // ─── UI transitions ──────────────────────────────────────────────────────
  /// Settings toggles, widget fade transitions.
  static const Duration quick = Duration(milliseconds: 180);

  /// Shape hand refill, standard UI duration.
  static const Duration standard = Duration(milliseconds: 200);

  /// Screen shake, ambient effect default.
  static const Duration medium = Duration(milliseconds: 300);

  /// Dialog show/hide transitions.
  static const Duration dialog = Duration(milliseconds: 380);

  // ─── Game effects ────────────────────────────────────────────────────────
  /// Wave clear timer, near-miss pulse.
  static const Duration waveClear = Duration(milliseconds: 480);

  /// Cell burst particle explosion.
  static const Duration cellBurst = Duration(milliseconds: 580);

  /// Bomb explosion + place feedback.
  static const Duration explosion = Duration(milliseconds: 650);

  /// Color synthesis bloom effect.
  static const Duration synthBloom = Duration(milliseconds: 700);

  /// Power-up activate, duel progress bar.
  static const Duration powerUp = Duration(milliseconds: 800);

  // ─── Sequences ───────────────────────────────────────────────────────────
  /// Level complete overlay.
  static const Duration levelComplete = Duration(milliseconds: 1200);

  /// Game toast message display.
  static const Duration toast = Duration(milliseconds: 1400);

  /// Combo window, feedback dismiss.
  static const Duration comboWindow = Duration(milliseconds: 1500);

  /// Near-miss dismiss, long toast.
  static const Duration longToast = Duration(milliseconds: 2000);

  /// Gel respiration / breathing cycle.
  static const Duration breathCycle = Duration(milliseconds: 2400);

  /// Confetti particle explosion.
  static const Duration confetti = Duration(milliseconds: 2500);
}
