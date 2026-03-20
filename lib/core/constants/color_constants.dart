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
const Color kPowerUpBombFg = Color(0xFFFF6B35);

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

// ─── Oyun modu → aksan renk eşlemesi ────────────────────────────────────────
const Map<GameMode, Color> kModeColors = {
  GameMode.classic: kColorClassic,
  GameMode.colorChef: kColorChef,
  GameMode.timeTrial: kColorTimeTrial,
  GameMode.zen: kColorZen,
  GameMode.daily: kCyan,
  GameMode.level: kColorChef,
  GameMode.duel: kColorClassic,
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
