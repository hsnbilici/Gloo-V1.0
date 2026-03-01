import '../../core/constants/color_constants.dart';
import '../economy/currency_manager.dart';
import '../shapes/gel_shape.dart';
import '../world/grid_manager.dart';

/// Power-up türleri.
enum PowerUpType {
  /// Seçili şekli 90 derece saat yönünde döndürür.
  rotate,

  /// 3×3 alan temizler (seçilen merkez).
  bomb,

  /// Sıradaki 3 şekli öngösterir.
  peek,

  /// Son yerleştirmeyi geri alır.
  undo,

  /// Mevcut şekli gökkuşağı (joker) renge dönüştürür.
  rainbow,

  /// Time Trial'da 10 saniye dondurur.
  freeze,
}

/// Power-up tanımı: maliyet, cooldown, kullanım limiti.
class PowerUpDef {
  const PowerUpDef({
    required this.type,
    required this.cost,
    this.cooldownMoves = 0,
    this.maxPerGame,
  });

  final PowerUpType type;
  final int cost;

  /// Kullanım sonrası bekleme süresi (hamle cinsinden).
  final int cooldownMoves;

  /// Oyun başına maksimum kullanım sayısı (null = sınırsız).
  final int? maxPerGame;
}

/// Tüm power-up tanımları.
const Map<PowerUpType, PowerUpDef> kPowerUpDefs = {
  PowerUpType.rotate: PowerUpDef(
    type: PowerUpType.rotate,
    cost: CurrencyCosts.rotate,
  ),
  PowerUpType.bomb: PowerUpDef(
    type: PowerUpType.bomb,
    cost: CurrencyCosts.bomb,
    cooldownMoves: 1,
  ),
  PowerUpType.peek: PowerUpDef(
    type: PowerUpType.peek,
    cost: CurrencyCosts.peek,
  ),
  PowerUpType.undo: PowerUpDef(
    type: PowerUpType.undo,
    cost: CurrencyCosts.undo,
    maxPerGame: 1,
  ),
  PowerUpType.rainbow: PowerUpDef(
    type: PowerUpType.rainbow,
    cost: CurrencyCosts.rainbow,
    cooldownMoves: 2,
  ),
  PowerUpType.freeze: PowerUpDef(
    type: PowerUpType.freeze,
    cost: CurrencyCosts.freeze,
    maxPerGame: 1,
  ),
};

/// Power-up kullanım sonucu.
sealed class PowerUpResult {}

class RotateResult extends PowerUpResult {
  RotateResult(this.rotatedShape);
  final GelShape rotatedShape;
}

class BombResult extends PowerUpResult {
  BombResult(this.clearedCells);
  final Map<(int, int), GelColor> clearedCells;
}

class PeekResult extends PowerUpResult {
  PeekResult(this.upcomingShapes);
  final List<(GelShape, GelColor)> upcomingShapes;
}

class UndoResult extends PowerUpResult {
  UndoResult(this.restoredCells);
  final List<(int, int)> restoredCells;
}

class RainbowResult extends PowerUpResult {}

class FreezeResult extends PowerUpResult {
  FreezeResult(this.frozenSeconds);
  final int frozenSeconds;
}

class GrantedResult extends PowerUpResult {}

/// Power-up sistemi — kullanım, cooldown, maliyet yönetimi.
class PowerUpSystem {
  PowerUpSystem({required this.currencyManager});

  final CurrencyManager currencyManager;

  /// Her power-up türü için kalan cooldown (hamle cinsinden).
  final Map<PowerUpType, int> _cooldowns = {};

  /// Her power-up türü için bu oyundaki kullanım sayısı.
  final Map<PowerUpType, int> _usageCounts = {};

  /// Son yerleştirme bilgisi (Undo için).
  List<(int, int)>? _lastPlacedCells;
  GelColor? _lastPlacedColor;

  /// Peek ile üretilmiş sıradaki eller.
  List<(GelShape, GelColor)>? _peekedShapes;

  /// Callback: Power-up kullanıldığında UI'ya bildirir.
  void Function(PowerUpType type, PowerUpResult result)? onPowerUpUsed;

  /// Son yerleştirilen renk (Undo görseli için).
  GelColor? get lastPlacedColor => _lastPlacedColor;

  /// Peek ile öngösterilen şekiller.
  List<(GelShape, GelColor)>? get peekedShapes => _peekedShapes;

  // ─── Durum sorgulama ──────────────────────────────────────────────────────

  /// Power-up kullanılabilir mi?
  bool canUse(PowerUpType type) {
    final def = kPowerUpDefs[type]!;

    // Bakiye kontrolü
    if (!currencyManager.canAfford(def.cost)) return false;

    // Cooldown kontrolü
    if ((_cooldowns[type] ?? 0) > 0) return false;

    // Kullanım limiti kontrolü
    if (def.maxPerGame != null) {
      if ((_usageCounts[type] ?? 0) >= def.maxPerGame!) return false;
    }

    return true;
  }

  /// Power-up'ın kalan cooldown'u.
  int getCooldown(PowerUpType type) => _cooldowns[type] ?? 0;

  /// Power-up'ın bu oyundaki kullanım sayısı.
  int getUsageCount(PowerUpType type) => _usageCounts[type] ?? 0;

  // ─── Kullanım ─────────────────────────────────────────────────────────────

  /// Rotate: Şekli döndürür.
  RotateResult? useRotate(GelShape currentShape) {
    if (!_activate(PowerUpType.rotate)) return null;
    final rotated = currentShape.rotated();
    final result = RotateResult(rotated);
    onPowerUpUsed?.call(PowerUpType.rotate, result);
    return result;
  }

  /// Bomb: 3×3 alan temizler.
  BombResult? useBomb(GridManager gridManager, int centerRow, int centerCol) {
    if (!_activate(PowerUpType.bomb)) return null;
    final cleared = gridManager.clearArea(centerRow, centerCol, 1);
    final result = BombResult(cleared);
    onPowerUpUsed?.call(PowerUpType.bomb, result);
    return result;
  }

  /// Peek: Sıradaki şekilleri öngösterir.
  PeekResult? usePeek(List<(GelShape, GelColor)> upcoming) {
    if (!_activate(PowerUpType.peek)) return null;
    _peekedShapes = upcoming;
    final result = PeekResult(upcoming);
    onPowerUpUsed?.call(PowerUpType.peek, result);
    return result;
  }

  /// Undo: Son yerleştirmeyi geri alır.
  UndoResult? useUndo(GridManager gridManager) {
    if (_lastPlacedCells == null) return null;
    if (!_activate(PowerUpType.undo)) return null;
    gridManager.undoPlace(_lastPlacedCells!);
    final result = UndoResult(_lastPlacedCells!);
    _lastPlacedCells = null;
    _lastPlacedColor = null;
    onPowerUpUsed?.call(PowerUpType.undo, result);
    return result;
  }

  /// Rainbow: Mevcut şekli joker renge dönüştürür.
  RainbowResult? useRainbow() {
    if (!_activate(PowerUpType.rainbow)) return null;
    final result = RainbowResult();
    onPowerUpUsed?.call(PowerUpType.rainbow, result);
    return result;
  }

  /// Freeze: Time Trial'da 10 saniye dondurur.
  FreezeResult? useFreeze() {
    if (!_activate(PowerUpType.freeze)) return null;
    const frozenSeconds = 10;
    final result = FreezeResult(frozenSeconds);
    onPowerUpUsed?.call(PowerUpType.freeze, result);
    return result;
  }

  // ─── Oyun akışı entegrasyonu ──────────────────────────────────────────────

  /// Her hamle sonrası çağrılır — cooldown'ları azaltır.
  void onMoveCompleted() {
    for (final type in _cooldowns.keys.toList()) {
      final current = _cooldowns[type] ?? 0;
      if (current > 0) _cooldowns[type] = current - 1;
    }
  }

  /// Yerleştirme kaydı (Undo için).
  void recordPlacement(List<(int, int)> cells, GelColor color) {
    _lastPlacedCells = List.from(cells);
    _lastPlacedColor = color;
  }

  /// Oyun başı sıfırlama.
  void reset() {
    _cooldowns.clear();
    _usageCounts.clear();
    _lastPlacedCells = null;
    _lastPlacedColor = null;
    _peekedShapes = null;
  }

  // ─── Dahili ───────────────────────────────────────────────────────────────

  bool _activate(PowerUpType type) {
    if (!canUse(type)) return false;
    final def = kPowerUpDefs[type]!;
    currencyManager.spend(def.cost);
    _cooldowns[type] = def.cooldownMoves;
    _usageCounts[type] = (_usageCounts[type] ?? 0) + 1;
    return true;
  }

  /// Rewarded Ad odul olarak ucretsiz power-up verir.
  /// Cooldown sifirlanir, maliyet alinmaz.
  void grantFreePowerUp(PowerUpType type) {
    _cooldowns[type] = 0;
    onPowerUpUsed?.call(type, GrantedResult());
  }
}
