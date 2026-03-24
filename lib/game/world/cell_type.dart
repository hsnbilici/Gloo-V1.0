import '../../core/constants/color_constants.dart';

/// Izgara hücresinin türünü belirler.
enum CellType {
  /// Standart boş hücre — her renk yerleştirilebilir.
  normal,

  /// Buz katmanı — temizleme sırasında katman azalır, 0 olunca normal'e döner.
  ice,

  /// Kilitli hücre — yalnızca belirtilen renk yerleştirilebilir.
  locked,

  /// Taş engel — yerleştirilemez, temizlenemez (harita şekillendirici).
  stone,

  /// Yerçekimli hücre — üstündeki bloklar aşağı düşer.
  gravity,

  /// Gökkuşağı — herhangi bir renkle eşleşen joker hücre.
  rainbow,
}

/// Izgaradaki tek bir hücreyi temsil eder.
class Cell {
  Cell({
    this.color,
    this.type = CellType.normal,
    this.iceLayer = 0,
    this.lockedColor,
  });

  /// Hücredeki jel rengi; null ise hücre boş.
  GelColor? color;

  /// Hücre türü.
  CellType type;

  /// Buz katman sayısı (yalnızca [CellType.ice] için anlamlı). 1 veya 2.
  int iceLayer;

  /// Kilitli hücre için gereken renk (yalnızca [CellType.locked] için anlamlı).
  GelColor? lockedColor;

  /// Hücre boş mu (yerleştirmeye müsait)?
  bool get isEmpty {
    if (type == CellType.stone) return false;
    if (type == CellType.ice && iceLayer > 0) return false;
    return color == null;
  }

  /// Hücre yerleştirilebilir mi (renk kontrolü dahil)?
  bool canAccept(GelColor placingColor) {
    if (type == CellType.stone) return false;
    if (type == CellType.ice && iceLayer > 0) return false;
    if (color != null) return false;
    if (type == CellType.locked && lockedColor != null) {
      return placingColor == lockedColor;
    }
    return true;
  }

  /// Buz katmanını bir azaltır. 0 olursa hücre normal'e döner.
  void crackIce() {
    if (type != CellType.ice) return;
    iceLayer--;
    if (iceLayer <= 0) {
      type = CellType.normal;
      iceLayer = 0;
    }
  }

  /// Hücreyi tamamen sıfırlar (renk ve tür korunabilir).
  void clearColor() {
    color = null;
  }

  /// Derin kopya.
  Cell copy() => Cell(
        color: color,
        type: type,
        iceLayer: iceLayer,
        lockedColor: lockedColor,
      );

  @override
  String toString() => 'Cell($type, $color, ice=$iceLayer)';
}
