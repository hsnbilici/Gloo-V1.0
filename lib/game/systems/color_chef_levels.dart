import '../../core/constants/color_constants.dart';

class ColorChefLevel {
  const ColorChefLevel({
    required this.targetColor,
    required this.requiredCount,
  });

  final GelColor targetColor;
  final int requiredCount;
}

/// 40 bölüm sabit seviye listesi.
/// Birincil renklerden (red/yellow/blue/white) üretilebilir sentez renkleri
/// kullanılır; zorluk kademeli artar.
const List<ColorChefLevel> kColorChefLevels = [
  // Bölüm 1–5: Temel sentezler (kolay)
  ColorChefLevel(targetColor: GelColor.orange, requiredCount: 3),
  ColorChefLevel(targetColor: GelColor.green, requiredCount: 3),
  ColorChefLevel(targetColor: GelColor.purple, requiredCount: 3),
  ColorChefLevel(targetColor: GelColor.pink, requiredCount: 3),
  ColorChefLevel(targetColor: GelColor.lightBlue, requiredCount: 3),
  // Bölüm 6–10: Artan miktar
  ColorChefLevel(targetColor: GelColor.orange, requiredCount: 4),
  ColorChefLevel(targetColor: GelColor.green, requiredCount: 4),
  ColorChefLevel(targetColor: GelColor.purple, requiredCount: 4),
  ColorChefLevel(targetColor: GelColor.lime, requiredCount: 3),
  ColorChefLevel(targetColor: GelColor.brown, requiredCount: 3),
  // Bölüm 11–15: Nadir sentezler devreye giriyor
  ColorChefLevel(targetColor: GelColor.orange, requiredCount: 5),
  ColorChefLevel(targetColor: GelColor.pink, requiredCount: 4),
  ColorChefLevel(targetColor: GelColor.lime, requiredCount: 4),
  ColorChefLevel(targetColor: GelColor.lightBlue, requiredCount: 4),
  ColorChefLevel(targetColor: GelColor.maroon, requiredCount: 3),
  // Bölüm 16–20: Zor kombinasyonlar, yüksek miktar
  ColorChefLevel(targetColor: GelColor.brown, requiredCount: 4),
  ColorChefLevel(targetColor: GelColor.purple, requiredCount: 5),
  ColorChefLevel(targetColor: GelColor.maroon, requiredCount: 4),
  ColorChefLevel(targetColor: GelColor.lime, requiredCount: 5),
  ColorChefLevel(targetColor: GelColor.maroon, requiredCount: 5),
  // Bölüm 21–25: Tüm sentez renklerinin yüksek hedeflerle turu
  ColorChefLevel(targetColor: GelColor.orange, requiredCount: 6),
  ColorChefLevel(targetColor: GelColor.green, requiredCount: 6),
  ColorChefLevel(targetColor: GelColor.purple, requiredCount: 6),
  ColorChefLevel(targetColor: GelColor.pink, requiredCount: 5),
  ColorChefLevel(targetColor: GelColor.lightBlue, requiredCount: 5),
  // Bölüm 26–30: Nadir renkler yüksek baskı altında
  ColorChefLevel(targetColor: GelColor.lime, requiredCount: 6),
  ColorChefLevel(targetColor: GelColor.brown, requiredCount: 5),
  ColorChefLevel(targetColor: GelColor.maroon, requiredCount: 6),
  ColorChefLevel(targetColor: GelColor.brown, requiredCount: 6),
  ColorChefLevel(targetColor: GelColor.pink, requiredCount: 6),
  // Bölüm 31–35: Çoklu hedef turu — arka arkaya zor sentezler
  ColorChefLevel(targetColor: GelColor.orange, requiredCount: 7),
  ColorChefLevel(targetColor: GelColor.purple, requiredCount: 7),
  ColorChefLevel(targetColor: GelColor.lime, requiredCount: 7),
  ColorChefLevel(targetColor: GelColor.maroon, requiredCount: 7),
  ColorChefLevel(targetColor: GelColor.lightBlue, requiredCount: 6),
  // Bölüm 36–40: Usta seviyesi — en yüksek miktar, en nadir renkler
  ColorChefLevel(targetColor: GelColor.brown, requiredCount: 7),
  ColorChefLevel(targetColor: GelColor.green, requiredCount: 7),
  ColorChefLevel(targetColor: GelColor.maroon, requiredCount: 8),
  ColorChefLevel(targetColor: GelColor.lime, requiredCount: 8),
  ColorChefLevel(targetColor: GelColor.purple, requiredCount: 8),
];
