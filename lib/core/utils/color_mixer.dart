import '../constants/color_constants.dart';

class ColorMixer {
  /// İki jel rengini sentezler. Tablo dışı kombinasyon null döner.
  static GelColor? mix(GelColor a, GelColor b) {
    // Sıra bağımsız arama — (a,b) ve (b,a) aynı sonucu verir
    return kColorMixingTable[(a, b)] ?? kColorMixingTable[(b, a)];
  }

  /// Birden fazla jelin ardışık sentezini hesaplar.
  /// Örn: red + yellow = orange, orange + blue = brown
  static GelColor? mixChain(List<GelColor> colors) {
    if (colors.isEmpty) return null;
    if (colors.length == 1) return colors.first;

    GelColor? result = colors.first;
    for (int i = 1; i < colors.length; i++) {
      result = mix(result!, colors[i]);
      if (result == null) return null; // Geçersiz zincir
    }
    return result;
  }

  /// Bir rengin sentezlenebilir (secondary) renk olup olmadığını döner.
  static bool isSecondaryColor(GelColor color) {
    return kColorMixingTable.values.contains(color);
  }

  /// Hedef rengi üretmek için gereken hammadde kombinasyonunu bulur.
  static List<(GelColor, GelColor)> findRecipes(GelColor target) {
    return kColorMixingTable.entries
        .where((e) => e.value == target)
        .map((e) => e.key)
        .toList();
  }
}
