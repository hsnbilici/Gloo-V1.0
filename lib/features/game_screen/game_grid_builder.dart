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
  Set<(int, int)> get synthesisGlowCells;
  Timer? get synthesisGlowTimer;
  set synthesisGlowTimer(Timer? value);
  int get waveKey;
  PowerUpType? get activePowerUpMode;
  List<({int row, int col, Color color, int key, Duration delay, double intensity})>
      get burstCells;
  List<({int row, int key})> get sweepRows;
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
  void onDragStarted(int index);
  void onDragOver(int row, int col);
  void onDragDrop(int row, int col);
  void onDragCancelled(int index);

  final GlobalKey _gridKey = GlobalKey();

  void syncGridState() {
    final rows = game.gridManager.rows;
    final cols = game.gridManager.cols;
    final isInteractive =
        selectedSlot != null || activePowerUpMode == PowerUpType.bomb;
    final slotColor = selectedSlot != null ? hand[selectedSlot!]?.$2 : null;

    final cells = <(int, int), CellRenderData>{};
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final gridCell = game.gridManager.getCell(r, c);
        final isPreview = previewCells.contains((r, c));
        final isPlaced = recentlyPlacedCells.contains((r, c));

        int waveDist = -1;
        if (gridCell.color != null &&
            recentlyPlacedCells.isNotEmpty &&
            !isPlaced) {
          int minDist = 999;
          for (final placed in recentlyPlacedCells) {
            final d = (placed.$1 - r).abs() + (placed.$2 - c).abs();
            if (d < minDist) minDist = d;
          }
          if (minDist <= 3) waveDist = minDist;
        }

        cells[(r, c)] = CellRenderData(
          color: gridCell.color,
          type: gridCell.type,
          iceLayer: gridCell.iceLayer,
          lockedColor: gridCell.lockedColor,
          isPreview: isPreview,
          previewValid: previewValid,
          previewSlotColor: isPreview ? slotColor : null,
          isRecentlyPlaced: isPlaced,
          waveDistance: waveDist,
          isInteractive: isInteractive,
          isSynthesisResult: synthesisGlowCells.contains((r, c)),
        );
      }
    }

    // Preview-time line completion hint: highlight rows that would be
    // completed if the current preview piece is placed.
    if (previewCells.isNotEmpty && previewValid) {
      for (int r = 0; r < rows; r++) {
        bool rowComplete = true;
        for (int c = 0; c < cols; c++) {
          final gridCell = game.gridManager.getCell(r, c);
          if (gridCell.type == CellType.stone) continue;
          final filled = !gridCell.isEmpty || previewCells.contains((r, c));
          if (!filled) {
            rowComplete = false;
            break;
          }
        }
        if (rowComplete) {
          for (int c = 0; c < cols; c++) {
            final key = (r, c);
            final existing = cells[key];
            if (existing != null) {
              cells[key] = existing.copyWith(isCompletionPreview: true);
            }
          }
        }
      }
    }

    // Nearly-full row detection: ≤2 empty playable cells (not fully filled)
    for (int r = 0; r < rows; r++) {
      int filled = 0;
      int playable = 0;
      for (int c = 0; c < cols; c++) {
        final cell = game.gridManager.getCell(r, c);
        if (cell.type != CellType.stone) {
          playable++;
          if (!cell.isEmpty) filled++;
        }
      }
      if (playable > 0 && filled < playable && (playable - filled) == 1) {
        for (int c = 0; c < cols; c++) {
          final key = (r, c);
          final existing = cells[key];
          if (existing != null) {
            cells[key] = existing.copyWith(isNearlyFullRow: true);
          }
        }
      }
    }

    ref.read(gridStateProvider.notifier).updateCells(cells);
  }

  Widget buildGrid() {
    final colorBlindMode = ref.watch(appSettingsProvider).colorBlindMode;

    // Push current cell state to provider before building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) syncGridState();
    });

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
                      child: DragTarget<int>(
                    onWillAcceptWithDetails: (_) => selectedSlot != null,
                    onMove: (details) {
                      final box = _gridKey.currentContext?.findRenderObject()
                          as RenderBox?;
                      if (box == null) return;
                      final local = box.globalToLocal(details.offset);
                      final c =
                          (local.dx / (cell + gap)).floor().clamp(0, cols - 1);
                      final r =
                          (local.dy / (cell + gap)).floor().clamp(0, rows - 1);
                      onDragOver(r, c);
                    },
                    onAcceptWithDetails: (details) {
                      final box = _gridKey.currentContext?.findRenderObject()
                          as RenderBox?;
                      if (box == null) return;
                      final local = box.globalToLocal(details.offset);
                      final c =
                          (local.dx / (cell + gap)).floor().clamp(0, cols - 1);
                      final r =
                          (local.dy / (cell + gap)).floor().clamp(0, rows - 1);
                      onDragDrop(r, c);
                    },
                    onLeave: (_) => setState(() {
                      previewCells = {};
                      previewValid = false;
                      previewAnchor = null;
                    }),
                    builder: (context, candidateData, rejectedData) {
                      return SizedBox(
                        key: _gridKey,
                        width: gridW,
                        height: gridH,
                        child: MouseRegion(
                          onExit: (_) => setState(() {
                            previewCells = {};
                            previewValid = false;
                            previewAnchor = null;
                          }),
                          child: GridView.builder(
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cols,
                              crossAxisSpacing: 2.0,
                              mainAxisSpacing: 2.0,
                            ),
                            itemCount: cols * rows,
                            itemBuilder: (context, index) {
                              final row = index ~/ cols;
                              final col = index % cols;

                              return GameCellWidget(
                                row: row,
                                col: col,
                                colorBlindMode: colorBlindMode,
                                cols: cols,
                                breathCtrl: breathCtrl,
                                waveKey: waveKey,
                                onTap: () => onCellTap(row, col),
                                onHover: () => onCellHover(row, col),
                              );
                            },
                          ),
                        ),
                      );
                    },
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
                          intensity: burst.intensity,
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
                  // Satır sweep overlay'leri (çoklu satır temizleme, lines >= 2)
                  ...sweepRows.map((sweep) {
                    final isRtl = Directionality.of(context) == TextDirection.rtl;
                    return Positioned(
                      key: ValueKey('sweep_${sweep.key}'),
                      left: 0,
                      top: sweep.row * (cell + gap),
                      child: IgnorePointer(
                        child: LineSweepEffect(
                          cols: cols,
                          cellSize: cell,
                          gap: gap,
                          isRtl: isRtl,
                          onDismiss: () {
                            if (mounted) {
                              setState(() => sweepRows
                                  .removeWhere((s) => s.key == sweep.key));
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
                          onDismiss: () => setState(() => placeFeedback = null),
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
                          onDismiss: () => setState(() => bombExplosion = null),
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
              strings: ref.watch(stringsProvider),
            ),
            const SizedBox(height: 8),
            ShapeHand(
              hand: hand,
              selectedSlot: selectedSlot,
              onSlotTap: onSlotTap,
              onDragStarted: onDragStarted,
              onDragEnd: (index, wasAccepted) {
                if (!wasAccepted) onDragCancelled(index);
              },
              nextShapeSilhouette: game.powerUpSystem.peekedShapes == null
                  ? game.nextShapeSilhouette
                  : null,
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
                milliseconds: shakeIntensity >= GameConstants.shakeAmplitudeEpic
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
