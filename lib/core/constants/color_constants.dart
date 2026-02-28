import 'package:flutter/material.dart';

enum GelColor {
  red,
  yellow,
  blue,
  orange,
  green,
  purple,
  pink,
  lightBlue,
  lime,
  maroon,
  brown,
  white;

  /// Renk körü modu için kısa etiket — dil bağımsız evrensel kısaltma.
  String get shortLabel => switch (this) {
        GelColor.red       => 'R',
        GelColor.yellow    => 'Y',
        GelColor.blue      => 'B',
        GelColor.orange    => 'O',
        GelColor.green     => 'G',
        GelColor.purple    => 'P',
        GelColor.pink      => 'Pk',
        GelColor.lightBlue => 'Lb',
        GelColor.lime      => 'Li',
        GelColor.maroon    => 'Mn',
        GelColor.brown     => 'Br',
        GelColor.white     => 'W',
      };

  Color get displayColor => switch (this) {
        GelColor.red => const Color(0xFFFF3B3B),
        GelColor.yellow => const Color(0xFFFFE03C),
        GelColor.blue => const Color(0xFF3C8BFF),
        GelColor.orange => const Color(0xFFFF7B3C),
        GelColor.green => const Color(0xFF3CFF8B),
        GelColor.purple => const Color(0xFF8B3CFF),
        GelColor.pink => const Color(0xFFFF3CAC),
        GelColor.lightBlue => const Color(0xFF3CF0FF),
        GelColor.lime => const Color(0xFF9DFF3C),
        GelColor.maroon => const Color(0xFF8B1A1A),
        GelColor.brown => const Color(0xFF8B6914),
        GelColor.white => const Color(0xFFF0F0F0),
      };

  String get displayName => switch (this) {
        GelColor.red => 'Kırmızı',
        GelColor.yellow => 'Sarı',
        GelColor.blue => 'Mavi',
        GelColor.orange => 'Turuncu',
        GelColor.green => 'Yeşil',
        GelColor.purple => 'Mor',
        GelColor.pink => 'Pembe',
        GelColor.lightBlue => 'Açık Mavi',
        GelColor.lime => 'Lime',
        GelColor.maroon => 'Bordo',
        GelColor.brown => 'Kahverengi',
        GelColor.white => 'Beyaz',
      };
}

/// Renk sentezi tablosu — iki jel birleştiğinde hangi rengi üretir
const Map<(GelColor, GelColor), GelColor> kColorMixingTable = {
  (GelColor.red, GelColor.yellow): GelColor.orange,
  (GelColor.yellow, GelColor.blue): GelColor.green,
  (GelColor.red, GelColor.blue): GelColor.purple,
  (GelColor.orange, GelColor.blue): GelColor.brown,
  (GelColor.red, GelColor.white): GelColor.pink,
  (GelColor.blue, GelColor.white): GelColor.lightBlue,
  (GelColor.green, GelColor.yellow): GelColor.lime,
  (GelColor.purple, GelColor.orange): GelColor.maroon,
};

/// Oyun başında sunulan temel renkler (sentezlenenler hariç)
const List<GelColor> kPrimaryColors = [
  GelColor.red,
  GelColor.yellow,
  GelColor.blue,
  GelColor.white,
];

// ─── UI Palette — tüm ekranlar bu sabitleri kullanır ─────────────────────────

/// Ana arka plan rengi — tüm scaffold ve container'lar için.
const Color kBgDark = Color(0xFF010C14);

/// Birincil aksan (cyan) — her ekranda `const _kCyan` olarak tekrar tanımlanmaz.
const Color kCyan = Color(0xFF00E5FF);

/// Soluk metin / ikincil UI elemanları.
/// #6B8FA8 → arka plan #010C14 üzerinde ~6:1 kontrast (WCAG AA ✓).
const Color kMuted = Color(0xFF6B8FA8);

// ─── Mod aksan renkleri — merkezi tanım ──────────────────────────────────────
// game_over_overlay, game_overlay, game_effects, home_screen bu sabitleri
// import eder; her dosyada ayrıca tanımlamaz.

const Color kColorClassic   = Color(0xFFFF4D6D);
const Color kColorChef      = Color(0xFF00FF9D);
const Color kColorTimeTrial = Color(0xFFFFD60A);
const Color kColorZen       = Color(0xFF9D5CFF);
