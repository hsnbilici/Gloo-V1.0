part of 'game_screen.dart';

/// Kullanici etkilesim handler'larini GameScreen'den ayiran mixin.
///
/// _onCellTap, _onSlotTap, _onCellHover, _onPowerUpTap, _clampAnchor
mixin _GameInteractionsMixin on ConsumerState<GameScreen> {
  GlooGame get game;
  List<(GelShape, GelColor)?> get hand;
  int? get selectedSlot;
  set selectedSlot(int? value);
  Set<(int, int)> get previewCells;
  set previewCells(Set<(int, int)> value);
  bool get previewValid;
  set previewValid(bool value);
  (int, int)? get previewAnchor;
  set previewAnchor((int, int)? value);
  PowerUpType? get activePowerUpMode;
  set activePowerUpMode(PowerUpType? value);
  ({int row, int col, int key})? get bombExplosion;
  set bombExplosion(({int row, int col, int key})? value);
  int get bombFxKey;
  set bombFxKey(int value);
  ({double cx, double cy, int count, Color color, int key})? get placeFeedback;
  set placeFeedback(
      ({double cx, double cy, int count, Color color, int key})? value);
  int get feedbackKeyIndex;
  set feedbackKeyIndex(int value);
  Set<(int, int)> get recentlyPlacedCells;
  set recentlyPlacedCells(Set<(int, int)> value);
  int get waveKey;
  set waveKey(int value);
  Timer? get waveClearTimer;
  set waveClearTimer(Timer? value);
  ({PowerUpType type, int key})? get activePowerUpEffect;
  set activePowerUpEffect(({PowerUpType type, int key})? value);
  int get powerUpFxKey;
  set powerUpFxKey(int value);
  ({List<(int, int)> cells, int key})? get undoEffect;
  set undoEffect(({List<(int, int)> cells, int key})? value);
  int get undoFxKey;
  set undoFxKey(int value);
  void refillHand();
  void showToast(String msg);

  void onSlotTap(int index) {
    if (activePowerUpMode != null) {
      setState(() => activePowerUpMode = null);
    }
    if (hand[index] == null) {
      showToast(ref.read(stringsProvider).toastSlotUsed);
      return;
    }
    setState(() {
      if (selectedSlot == index) {
        selectedSlot = null;
      } else {
        selectedSlot = index;
      }
      previewCells = {};
      previewValid = false;
      previewAnchor = null;
    });
  }

  void onCellHover(int row, int col) {
    if (activePowerUpMode == PowerUpType.bomb) return;
    if (selectedSlot == null) return;
    final slot = hand[selectedSlot!];
    if (slot == null) return;

    final (shape, color) = slot;
    final (ar, ac) = clampAnchor(shape, row, col);
    final cells = shape.at(ar, ac);

    setState(() {
      previewCells = cells.toSet();
      previewValid = game.gridManager.canPlace(cells, color);
      previewAnchor = (ar, ac);
    });
  }

  void onCellTap(int row, int col) {
    // Bomb power-up modu
    if (activePowerUpMode == PowerUpType.bomb) {
      final result = game.useBomb(row, col);
      if (result != null && result.isNotEmpty) {
        setState(() {
          activePowerUpMode = null;
          bombExplosion = (row: row, col: col, key: ++bombFxKey);
        });
      } else {
        setState(() => activePowerUpMode = null);
        showToast(ref.read(stringsProvider).toastBombFailed);
      }
      return;
    }

    if (selectedSlot == null) {
      showToast(ref.read(stringsProvider).toastSelectShape);
      return;
    }
    final slot = hand[selectedSlot!];
    if (slot == null) return;

    final (shape, color) = slot;
    final (ar, ac) = clampAnchor(shape, row, col);
    final cells = shape.at(ar, ac);
    final canPlace = game.gridManager.canPlace(cells, color);

    if (previewAnchor != (ar, ac)) {
      setState(() {
        previewCells = cells.toSet();
        previewValid = canPlace;
        previewAnchor = (ar, ac);
      });
      return;
    }

    if (!canPlace) {
      showToast(ref.read(stringsProvider).toastCannotPlace);
      return;
    }

    game.placePiece(cells, color);
    ref
        .read(gameProvider(widget.mode).notifier)
        .updateFill(game.gridManager.filledCells);

    final feedbackCx = ac + (shape.colCount - 1) / 2.0;
    final feedbackCy = ar + (shape.rowCount - 1) / 2.0;

    setState(() {
      hand[selectedSlot!] = null;
      selectedSlot = null;
      previewCells = {};
      previewValid = false;
      previewAnchor = null;
      placeFeedback = (
        cx: feedbackCx,
        cy: feedbackCy,
        count: cells.length,
        color: color.displayColor,
        key: ++feedbackKeyIndex,
      );
      recentlyPlacedCells = cells.toSet();
      waveKey++;
      if (hand.every((h) => h == null)) refillHand();
    });

    waveClearTimer?.cancel();
    waveClearTimer = Timer(const Duration(milliseconds: 480), () {
      if (mounted) setState(() => recentlyPlacedCells = {});
    });

    game.checkGameOver(
      hand.where((s) => s != null).map((s) => s!.$1).toList(),
    );
  }

  void onPowerUpTap(PowerUpType type) {
    switch (type) {
      case PowerUpType.rotate:
        if (selectedSlot == null || hand[selectedSlot!] == null) {
          showToast(ref.read(stringsProvider).toastSelectShapeFirst);
          return;
        }
        final (shape, color) = hand[selectedSlot!]!;
        final rotated = game.rotateShape(shape);
        if (rotated != null) {
          setState(() {
            hand[selectedSlot!] = (rotated, color);
            previewCells = {};
            previewValid = false;
            previewAnchor = null;
            activePowerUpEffect =
                (type: PowerUpType.rotate, key: ++powerUpFxKey);
          });
        }

      case PowerUpType.bomb:
        if (activePowerUpMode == PowerUpType.bomb) {
          setState(() => activePowerUpMode = null);
          return;
        }
        setState(() => activePowerUpMode = PowerUpType.bomb);
        showToast(ref.read(stringsProvider).toastBombSelectCenter);

      case PowerUpType.undo:
        final result = game.useUndo();
        if (result != null) {
          setState(() {
            undoEffect = (cells: result, key: ++undoFxKey);
          });
        }

      case PowerUpType.freeze:
        final success = game.useFreeze();
        if (success) {
          showToast(ref.read(stringsProvider).toastFrozen);
        }

      case PowerUpType.peek:
      case PowerUpType.rainbow:
        break;
    }
  }

  (int, int) clampAnchor(GelShape shape, int row, int col) {
    final maxRow = game.gridManager.rows - shape.rowCount;
    final maxCol = game.gridManager.cols - shape.colCount;
    return (row.clamp(0, maxRow), col.clamp(0, maxCol));
  }
}
