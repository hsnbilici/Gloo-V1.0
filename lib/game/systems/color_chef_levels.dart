import '../../core/constants/color_constants.dart';

class ColorChefLevel {
  const ColorChefLevel({
    required this.targetColor,
    required this.requiredCount,
  });

  final GelColor targetColor;
  final int requiredCount;
}

/// İlk 20 bölüm sabit seviye listesi.
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
];
