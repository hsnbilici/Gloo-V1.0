import 'package:flutter/material.dart';

import '../models/game_mode.dart';

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
        GelColor.red => 'R',
        GelColor.yellow => 'Y',
        GelColor.blue => 'B',
        GelColor.orange => 'O',
        GelColor.green => 'G',
        GelColor.purple => 'P',
        GelColor.pink => 'Pk',
        GelColor.lightBlue => 'Lb',
        GelColor.lime => 'Li',
        GelColor.maroon => 'Mn',
        GelColor.brown => 'Br',
        GelColor.white => 'W',
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

// ────────────────────────────────────────────────────────────────────────────
// WCAG AA Contrast Ratio Matrix — Dark Theme (last audit: 2026-03-22)
//
// Formula: relative luminance L = 0.2126·R + 0.7152·G + 0.0722·B
//          (channels linearised via sRGB gamma; c <= 0.04045 → c/12.92,
//           else → ((c + 0.055) / 1.055) ^ 2.4)
// Ratio:   (L_lighter + 0.05) / (L_darker + 0.05)
// Thresholds: normal text >= 4.5:1 | large text / graphics >= 3:1
//
// Luminance reference values used below:
//   kBgDark       (0xFF010C14)  L = 0.0032
//   kSurfaceDark  (0xFF0F1420)  L = 0.0070
//   kMuted        (0xFF6B8FA8)  L = 0.2523
//   kCyan         (0xFF00E5FF)  L = 0.6326
//   kGold         (0xFFFFD700)  L = 0.6988
//   kAmber        (0xFFFFD740)  L = 0.7025
//   kGreen        (0xFF3CFF8B)  L = 0.7435
//   kYellow       (0xFFFFE03C)  L = 0.7489
//   kOrange       (0xFFFF8C42)  L = 0.4041
//   kRed          (0xFFFF3B3B)  L = 0.2470
//   kPink         (0xFFFF69B4)  L = 0.3466
//   kLavender     (0xFFB080FF)  L = 0.3189
//   kCoral        (0xFFFF6B6B)  L = 0.3143
//   kColorClassic (0xFFFF4D6D)  L = 0.2766
//   kColorChef    (0xFF00FF9D)  L = 0.7395
//   kColorTimeTrial(0xFFFFD60A) L = 0.6939
//   kColorZen     (0xFF9D5CFF)  L = 0.2201
//   kBronze       (0xFFCD7F32)  L = 0.2839
//   kSilver       (0xFFC0C0C0)  L = 0.5270
//   kDiamondBlue  (0xFF00BFFF)  L = 0.4447
//   kGlooMaster   (0xFFFF3CFF)  L = 0.3171
//   kSuccessGreen (0xFF2E7D32)  L = 0.1554
//   white         (0xFFFFFFFF)  L = 1.0000
//   kPowerUpBombFg(0xFFFFB080)  L = 0.5430
//   kPowerUpBombBg(0xFF8B2500)  L = 0.0681
//   kPowerUpFreezeFg(0xFF80D8FF)L = 0.6091
//   kPowerUpFreezeBg(0xFF01579B)L = 0.0918
//   kPowerUpRotateBg(0xFF006978)L = 0.1147
//   kPowerUpUndoBg(0xFF8B6914)  L = 0.1570
//
// ── Pair ───────────────────────────────────── Ratio   AA(text) AA(large)
// kBgDark     + kMuted                          5.68:1  PASS     PASS
// kBgDark     + kCyan                          12.82:1  PASS     PASS
// kBgDark     + kGold                          14.07:1  PASS     PASS
// kBgDark     + kAmber                         14.13:1  PASS     PASS
// kBgDark     + kGreen                         14.90:1  PASS     PASS
// kBgDark     + kYellow                        15.01:1  PASS     PASS
// kBgDark     + kOrange                         8.53:1  PASS     PASS
// kBgDark     + kRed                            5.58:1  PASS     PASS
// kBgDark     + kPink                           7.45:1  PASS     PASS
// kBgDark     + kLavender                       6.93:1  PASS     PASS
// kBgDark     + kCoral                          6.85:1  PASS     PASS
// kBgDark     + kColorClassic                   6.14:1  PASS     PASS
// kBgDark     + kColorChef                     14.83:1  PASS     PASS
// kBgDark     + kColorTimeTrial                13.98:1  PASS     PASS
// kBgDark     + kColorZen                       5.08:1  PASS     PASS
// kBgDark     + kBronze                         6.28:1  PASS     PASS
// kBgDark     + kSilver                        10.84:1  PASS     PASS
// kBgDark     + kDiamondBlue                    9.29:1  PASS     PASS
// kBgDark     + kGlooMaster                     6.90:1  PASS     PASS
// kSurfaceDark + kMuted                          5.30:1  PASS     PASS
// kSurfaceDark + kCyan                          11.97:1  PASS     PASS
// kSurfaceDark + kGold                          13.13:1  PASS     PASS
// kSurfaceDark + kGreen                         13.91:1  PASS     PASS
// kSurfaceDark + kOrange                         7.96:1  PASS     PASS
// kSurfaceDark + kColorClassic                   5.73:1  PASS     PASS
// kSurfaceDark + kColorZen                       4.74:1  PASS     PASS
// kSurfaceDark + kYellow                        14.00:1  PASS     PASS
// kSurfaceDark + kAmber                         13.06:1  PASS     PASS
// kSurfaceDark + kPink                           6.95:1  PASS     PASS
// kSurfaceDark + kLavender                       6.45:1  PASS     PASS
// kSurfaceDark + kCoral                          6.39:1  PASS     PASS
// kSurfaceDark + kRed                            5.21:1  PASS     PASS
// kSuccessGreen + white                          5.11:1  PASS     PASS
// kPowerUpBombBg + kPowerUpBombFg                5.02:1  PASS     PASS
// kPowerUpFreezeBg + kPowerUpFreezeFg            4.65:1  PASS     PASS
// kPowerUpRotateBg + white                       6.38:1  PASS     PASS
// kPowerUpUndoBg   + kAmber                      3.63:1  FAIL(!)  PASS
//
// WARNINGS:
// ! kPowerUpUndoBg + kAmber — 3.63:1
//     FAILS normal-text AA. Same caveat — icon/large-badge use only.
// NOTE: kAmber.withValues(alpha: 0.08) on kBgDark (~21,28,24 composited)
//     produces an effectively invisible tint; used purely as a decorative
//     hint overlay, NOT for text. No text contrast requirement applies.
// NOTE: kCyanGlow (0x4400E5FF, alpha 27%) is decorative glow only — no text.
// NOTE: kColorZen (5.08:1 on kBgDark, 4.74:1 on kSurfaceDark) passes AA
//     with moderate margin; still avoid pairing with small text below 14px.
// ────────────────────────────────────────────────────────────────────────────

// ─── UI Palette — tüm ekranlar bu sabitleri kullanır ─────────────────────────

/// Ana arka plan rengi — tüm scaffold ve container'lar için.
const Color kBgDark = Color(0xFF010C14);

/// Arka plan degrade başlangıcı — kBgDark'tan biraz daha koyu.
const Color kBgDeepDark = Color(0xFF020D1A);

/// Yüzey rengi — dialog ve bottom sheet arka planı.
const Color kSurfaceDark = Color(0xFF0F1420);

/// En koyu yüzey — MaterialTheme surface, derin siyah.
const Color kSurfaceBlack = Color(0xFF0A0A0F);

/// Koyu lacivert — stone hücre, göz içi nokta.
const Color kSurfaceDeepNavy = Color(0xFF1A1A2E);

/// Lacivert — kilitli seviye, taş hücre kenarı.
const Color kSurfaceNavy = Color(0xFF2A2A4E);

/// Birincil aksan (cyan) — her ekranda `const _kCyan` olarak tekrar tanımlanmaz.
const Color kCyan = Color(0xFF00E5FF);

/// Cyan gölge — skor metni text shadow.
const Color kCyanGlow = Color(0x4400E5FF);

/// Soluk metin / ikincil UI elemanları.
/// #6B8FA8 → arka plan #010C14 üzerinde ~6:1 kontrast (WCAG AA ✓).
const Color kMuted = Color(0xFF6B8FA8);

/// Altın vurgu — mağaza, ödül, premium UI elemanları.
const Color kGold = Color(0xFFFFD700);

/// Turuncu vurgu — streak badge, quest overlay, ada bina, seviye, karakter.
const Color kOrange = Color(0xFFFF8C42);

/// Canlı turuncu — combo large, near-miss, rescue badge (= GelColor.orange).
const Color kOrangeVivid = Color(0xFFFF7B3C);

/// Yeşil vurgu — başarı, tamamlanma, kazanma göstergeleri.
const Color kGreen = Color(0xFF3CFF8B);

/// Koyu yeşil başarı — snackbar arka planı.
const Color kSuccessGreen = Color(0xFF2E7D32);

/// Lavanta vurgu — karakter, zen modu, premium UI elemanları.
const Color kLavender = Color(0xFFB080FF);

/// Mercan vurgu — uyarı ve reklamsız aksanı.
const Color kCoral = Color(0xFFFF6B6B);

/// Kırmızı vurgu — hata, kayıp, combo epic (= GelColor.red).
const Color kRed = Color(0xFFFF3B3B);

/// Sarı vurgu — combo medium, beraberlik (= GelColor.yellow).
const Color kYellow = Color(0xFFFFE03C);

/// Pembe vurgu — season pass, rainbow hücre (= GelColor.pink).
const Color kPink = Color(0xFFFF69B4);

// ─── Liga renkleri ────────────────────────────────────────────────────────────

/// Bronz — PvP bronze liga, liderlik tablosu 3. sıra.
const Color kBronze = Color(0xFFCD7F32);

/// Gümüş — PvP silver liga, liderlik tablosu 2. sıra.
const Color kSilver = Color(0xFFC0C0C0);

/// Elmas mavisi — PvP diamond liga, ada limanı.
const Color kDiamondBlue = Color(0xFF00BFFF);

/// Gloo Master eforu — PvP glooMaster liga.
const Color kGlooMaster = Color(0xFFFF3CFF);

// ─── MaterialTheme renkleri ───────────────────────────────────────────────────

/// Uygulama birincil rengi — MaterialTheme primary.
const Color kThemePrimary = Color(0xFFFF3CAC);

/// Uygulama ikincil rengi — MaterialTheme secondary, neon yeşil.
const Color kThemeSecondary = Color(0xFF39FF14);

/// Uygulama üçüncül rengi — MaterialTheme tertiary, mor.
const Color kThemeTertiary = Color(0xFF8B5CF6);

// ─── Buz efekti renkleri ─────────────────────────────────────────────────────

/// Buz mavi — ice hücre overlay.
const Color kIceBlue = Color(0xFF88CCFF);

/// Parlak buz mavi — ice hücre kenarı.
const Color kIceBlueBright = Color(0xFFAADDFF);

/// Buz rengi — IceBreakPainter kırık parça rengi.
const Color kIceColor = Color(0xFFB0E0FF);

/// Buz parlaması — IceBreakPainter highlight.
const Color kIceHighlight = Color(0xFFE8F6FF);

// ─── Amber / power-up renkleri ────────────────────────────────────────────────

/// Amber — power-up undo, freeze efekti arka planı.
const Color kAmber = Color(0xFFFFD740);

/// Koyu amber — bomb shock dalgası.
const Color kAmberDark = Color(0xFFFF8C00);

/// Amber parıltısı — bomb efekti iç glow.
const Color kAmberGlow = Color(0xFFFFA000);

// ─── Power-up tema renk çiftleri (ön plan / arka plan) ───────────────────────

/// Rotate power-up arka plan tonu.
const Color kPowerUpRotateBg = Color(0xFF006978);

/// Bomb power-up ön rengi.
const Color kPowerUpBombFg = Color(0xFFFFB080);

/// Bomb power-up arka plan tonu.
const Color kPowerUpBombBg = Color(0xFF8B2500);

/// Undo power-up arka plan tonu.
const Color kPowerUpUndoBg = Color(0xFF8B6914);

/// Freeze power-up ön rengi.
const Color kPowerUpFreezeFg = Color(0xFF80D8FF);

/// Freeze power-up arka plan tonu.
const Color kPowerUpFreezeBg = Color(0xFF01579B);

// ─── Boş hücre derinlik gradyanı ─────────────────────────────────────────────

/// Boş hücre radyal gradyan — açık ton (~%15 opaklık).
const Color kCellEmptyLight = Color(0x26FFFFFF);

/// Boş hücre radyal gradyan — koyu ton (~%8 opaklık).
const Color kCellEmptyDark = Color(0x14FFFFFF);

// ─── Rainbow hücre gradyan tonları (düşük alfa) ───────────────────────────────

/// Rainbow hücre kırmızı tonu (~%13 opaklık).
const Color kRainbowRed = Color(0x22FF3B3B);

/// Rainbow hücre sarı tonu (~%13 opaklık).
const Color kRainbowYellow = Color(0x22FFE03C);

/// Rainbow hücre yeşil tonu (~%13 opaklık).
const Color kRainbowGreen = Color(0x223CFF8B);

/// Rainbow hücre mavi tonu (~%13 opaklık).
const Color kRainbowBlue = Color(0x223C8BFF);

// ─── Maskot renkleri (GlooMascot) ────────────────────────────────────────────

/// Maskot gradyan — açık yeşil merkez.
const Color kMascotGreenLight = Color(0xFF5CFFA8);

/// Maskot gradyan — orta yeşil.
const Color kMascotGreenMid = Color(0xFF00CC66);

/// Maskot gradyan — koyu yeşil kenar.
const Color kMascotGreenDark = Color(0xFF008844);

/// Maskot ağız rengi — koyu yeşil.
const Color kMascotMouth = Color(0xFF006633);

// ─── Mod aksan renkleri — merkezi tanım ──────────────────────────────────────
// game_over_overlay, game_overlay, game_effects, home_screen bu sabitleri
// import eder; her dosyada ayrıca tanımlamaz.

const Color kColorClassic = Color(0xFFFF4D6D);
const Color kColorChef = Color(0xFF00FF9D);
const Color kColorTimeTrial = Color(0xFFFFD60A);
const Color kColorZen = Color(0xFF9D5CFF);
const Color kColorDuel = kCoral;

// ─── Oyun modu → aksan renk eşlemesi ────────────────────────────────────────
const Map<GameMode, Color> kModeColors = {
  GameMode.classic: kColorClassic,
  GameMode.colorChef: kColorChef,
  GameMode.timeTrial: kColorTimeTrial,
  GameMode.zen: kColorZen,
  GameMode.daily: kCyan,
  GameMode.level: kColorChef,
  GameMode.duel: kColorDuel,
};

// ─── Konfeti efekti renkleri ─────────────────────────────────────────────────

/// Konfeti parçacığı kırmızı — yüksek skor patlaması.
const Color kConfettiRed = Color(0xFFFF6B6B);

/// Konfeti parçacığı camgöbeği — yüksek skor patlaması.
const Color kConfettiTeal = Color(0xFF4ECDC4);

/// Konfeti parçacığı sarı — yüksek skor patlaması.
const Color kConfettiYellow = Color(0xFFFFE66D);

/// Konfeti parçacığı açık yeşil — yüksek skor patlaması.
const Color kConfettiLightGreen = Color(0xFFA8E6CF);

/// Konfeti parçacığı turuncu — yüksek skor patlaması.
const Color kConfettiOrange = Color(0xFFFF8A5C);

/// Konfeti parçacığı mor — yüksek skor patlaması.
const Color kConfettiPurple = Color(0xFF6C5CE7);

/// Konfeti parçacığı pembe — yüksek skor patlaması.
const Color kConfettiPink = Color(0xFFFF85A1);

/// Konfeti parçacığı açık mavi — yüksek skor patlaması.
const Color kConfettiLightBlue = Color(0xFF00D2FF);

/// Returns the appropriate color based on brightness.
Color resolveColor(
  Brightness brightness, {
  required Color dark,
  required Color light,
}) {
  return brightness == Brightness.dark ? dark : light;
}
