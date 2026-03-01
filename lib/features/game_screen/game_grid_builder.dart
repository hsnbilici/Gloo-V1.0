part of 'game_screen.dart';

/// _buildGrid() metodunu GameScreen'den ayiran mixin.
///
/// ~220 satirlik izgara build/layout mantigi.
mixin _GameGridBuilderMixin on ConsumerState<GameScreen> {
  GlooGame get game;
  List<(GelShape, GelColor)?> get hand;
  int? get selectedSlot;
  Set<(int, int)> get previewCells;
  set previewCells(Set<(int, int)> value);
  bool get previewValid;
  set previewValid(bool value);
  (int, int)? get previewAnchor;
  set previewAnchor((int, int)? value);
  AnimationController get breathCtrl;
  Set<(int, int)> get recentlyPlacedCells;
  int get waveKey;
  PowerUpType? get activePowerUpMode;
  List<({int row, int col, Color color, int key, Duration delay})>
      get burstCells;
  List<({int row, int col, Color color, int key})> get synthesisBlooms;
  ({double cx, double cy, int count, Color color, int key})? get placeFeedback;
  set placeFeedback(
      ({double cx, double cy, int count, Color color, int key})? value);
  ({int row, int col, int key})? get bombExplosion;
  set bombExplosion(({int row, int col, int key})? value);
  ({List<(int, int)> cells, int key})? get undoEffect;
  set undoEffect(({List<(int, int)> cells, int key})? value);
  double get shakeIntensity;
  set shakeIntensity(double value);
  int get shakeKey;
  Timer? get shakeTimer;
  set shakeTimer(Timer? value);
  void onCellTap(int row, int col);
  void onCellHover(int row, int col);
  void onPowerUpTap(PowerUpType type);
  void onSlotTap(int index);

  Widget buildGrid() {
    final colorBlindMode = ref.watch(appSettingsProvider).colorBlindMode;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = game.gridManager.cols;
        final rows = game.gridManager.rows;
        const gap = 2.0;
        const hPad = 12.0;
        const handH = 120.0;
        const handGap = 8.0;
        const bottomPad = 16.0;
        const powerUpH = 56.0;
        const powerUpGap = 6.0;

        final availW = constraints.maxWidth - hPad * 2;
        final availH = constraints.maxHeight -
            handH -
            handGap -
            bottomPad -
            powerUpH -
            powerUpGap;

        final cellByW = (availW - gap * (cols - 1)) / cols;
        final cellByH = (availH - gap * (rows - 1)) / rows;
        final cell = cellByW < cellByH ? cellByW : cellByH;

        final gridW = cell * cols + gap * (cols - 1);
        final gridH = cell * rows + gap * (rows - 1);

        Widget gridContent = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  RepaintBoundary(
                      child: SizedBox(
                    width: gridW,
                    height: gridH,
                    child: MouseRegion(
                      onExit: (_) => setState(() {
                        previewCells = {};
                        previewValid = false;
                        previewAnchor = null;
                      }),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 2.0,
                          mainAxisSpacing: 2.0,
                        ),
                        itemCount: cols * rows,
                        itemBuilder: (context, index) {
                          final row = index ~/ cols;
                          final col = index % cols;
                          final gridCell = game.gridManager.getCell(row, col);
                          final cellColor = gridCell.color;
                          final isPreview = previewCells.contains((row, col));

                          return GameCellWidget(
                            row: row,
                            col: col,
                            gridCell: gridCell,
                            cellColor: cellColor,
                            isPreview: isPreview,
                            colorBlindMode: colorBlindMode,
                            cols: cols,
                            breathCtrl: breathCtrl,
                            recentlyPlacedCells: recentlyPlacedCells,
                            waveKey: waveKey,
                            previewValid: previewValid,
                            previewSlotColor: selectedSlot != null
                                ? hand[selectedSlot!]?.$2
                                : null,
                            selectedSlot: selectedSlot,
                            activePowerUpMode: activePowerUpMode,
                            onTap: () => onCellTap(row, col),
                            onHover: () => onCellHover(row, col),
                          );
                        },
                      ),
                    ),
                  )),
                  // Hucre patlamasi overlay'leri
                  ...burstCells.map((burst) {
                    return Positioned(
                      key: ValueKey(burst.key),
                      left: burst.col * (cell + gap) - cell * 1.5,
                      top: burst.row * (cell + gap) - cell * 1.5,
                      child: IgnorePointer(
                        child: CellBurstEffect(
                          color: burst.color,
                          cellSize: cell,
                          delay: burst.delay,
                          onDismiss: () {
                            if (mounted) {
                              setState(() => burstCells
                                  .removeWhere((b) => b.key == burst.key));
                            }
                          },
                        ),
                      ),
                    );
                  }),
                  // Renk sentezi bloom overlay'leri
                  ...synthesisBlooms.map((bloom) {
                    return Positioned(
                      key: ValueKey(bloom.key),
                      left: bloom.col * (cell + gap) - cell * 2.0,
                      top: bloom.row * (cell + gap) - cell * 2.0,
                      child: IgnorePointer(
                        child: ColorSynthesisBloomEffect(
                          color: bloom.color,
                          cellSize: cell,
                          onDismiss: () {
                            if (mounted) {
                              setState(() => synthesisBlooms
                                  .removeWhere((b) => b.key == bloom.key));
                            }
                          },
                        ),
                      ),
                    );
                  }),
                  if (placeFeedback != null)
                    Positioned(
                      left: placeFeedback!.cx * (cell + gap) + cell / 2,
                      top: placeFeedback!.cy * (cell + gap) + cell / 2,
                      child: FractionalTranslation(
                        translation: const Offset(-0.5, -0.5),
                        child: PlaceFeedbackEffect(
                          key: ValueKey(placeFeedback!.key),
                          count: placeFeedback!.count,
                          color: placeFeedback!.color,
                          onDismiss: () =>
                              setState(() => placeFeedback = null),
                        ),
                      ),
                    ),
                  if (bombExplosion != null)
                    Positioned(
                      left: bombExplosion!.col * (cell + gap) +
                          cell / 2 -
                          cell * 3,
                      top: bombExplosion!.row * (cell + gap) +
                          cell / 2 -
                          cell * 3,
                      child: IgnorePointer(
                        child: BombExplosionEffect(
                          key: ValueKey(bombExplosion!.key),
                          cellSize: cell,
                          onDismiss: () =>
                              setState(() => bombExplosion = null),
                        ),
                      ),
                    ),
                  if (undoEffect != null)
                    Positioned.fill(
                      child: UndoRewindEffect(
                        key: ValueKey(undoEffect!.key),
                        cells: undoEffect!.cells,
                        cellSize: cell,
                        gridGap: gap,
                        onDismiss: () => setState(() => undoEffect = null),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            PowerUpToolbar(
              balance: game.currencyManager.balance,
              powerUpSystem: game.powerUpSystem,
              activePowerUpMode: activePowerUpMode,
              showFreeze: widget.mode == GameMode.timeTrial ||
                  widget.mode == GameMode.duel,
              onPowerUpTap: onPowerUpTap,
            ),
            const SizedBox(height: 8),
            ShapeHand(
              hand: hand,
              selectedSlot: selectedSlot,
              onSlotTap: onSlotTap,
            ),
            const SizedBox(height: 16),
          ],
        );

        // Ekran sarsintisi
        if (shakeIntensity > 0) {
          gridContent = ScreenShake(
            key: ValueKey(shakeKey),
            intensity: shakeIntensity,
            duration: Duration(
              milliseconds: shakeIntensity >= GameConstants.shakeAmplitudeEpic
                  ? GameConstants.shakeDurationEpic
                  : GameConstants.shakeDurationLarge,
            ),
            child: gridContent,
          );
          shakeTimer?.cancel();
          shakeTimer = Timer(
            Duration(
                milliseconds:
                    shakeIntensity >= GameConstants.shakeAmplitudeEpic
                        ? GameConstants.shakeDurationEpic
                        : GameConstants.shakeDurationLarge),
            () {
              if (mounted) setState(() => shakeIntensity = 0.0);
            },
          );
        }

        return gridContent;
      },
    );
  }
}
