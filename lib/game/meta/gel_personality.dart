import '../../core/constants/color_constants.dart';
import '../../core/l10n/app_strings.dart';

/// Her sentez renginin kişilik arketipi.
enum GelPersonality {
  orange(GelColor.orange),    // Maceracı — ateş + güneş
  green(GelColor.green),      // Bilge — doğa + denge
  purple(GelColor.purple),    // Gizemli — derinlik + sezgi
  pink(GelColor.pink),        // Neşeli — enerji + sevgi
  lightBlue(GelColor.lightBlue), // Sakin — huzur + akış
  lime(GelColor.lime),        // Yaratıcı — taze + yenilikçi
  maroon(GelColor.maroon),    // Güçlü — dayanıklılık + kararlılık
  brown(GelColor.brown);      // Sadık — toprak + güven

  const GelPersonality(this.color);
  final GelColor color;

  /// Lokalize kişilik ismini döner.
  String personalityName(AppStrings l) => switch (this) {
        GelPersonality.orange => l.personalityOrange,
        GelPersonality.green => l.personalityGreen,
        GelPersonality.purple => l.personalityPurple,
        GelPersonality.pink => l.personalityPink,
        GelPersonality.lightBlue => l.personalityLightBlue,
        GelPersonality.lime => l.personalityLime,
        GelPersonality.maroon => l.personalityMaroon,
        GelPersonality.brown => l.personalityBrown,
      };

  /// [GelColor]'dan karşılık gelen [GelPersonality]'yi döner.
  /// Birincil renklerin (red, yellow, blue, white) karşılığı yoktur → null.
  static GelPersonality? fromColor(GelColor color) => switch (color) {
        GelColor.orange => GelPersonality.orange,
        GelColor.green => GelPersonality.green,
        GelColor.purple => GelPersonality.purple,
        GelColor.pink => GelPersonality.pink,
        GelColor.lightBlue => GelPersonality.lightBlue,
        GelColor.lime => GelPersonality.lime,
        GelColor.maroon => GelPersonality.maroon,
        GelColor.brown => GelPersonality.brown,
        _ => null,
      };
}
