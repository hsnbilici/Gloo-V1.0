import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/game_constants.dart';
import '../../core/utils/near_miss_detector.dart';
import '../../game/levels/level_data.dart';
import '../../game/shapes/gel_shape.dart';
import '../../game/systems/combo_detector.dart';
import '../../game/systems/powerup_system.dart';
import '../../game/world/game_world.dart';
import '../../providers/audio_provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_provider.dart';
import '../../data/remote/remote_repository.dart';
import '../../services/ad_manager.dart';
import '../../services/analytics_service.dart';
import '../../viral/clip_recorder.dart';
import 'game_background.dart';
import 'game_cell_widget.dart';
import 'game_dialogs.dart';
import 'game_duel_controller.dart';
import 'game_effects.dart';
import 'game_over_overlay.dart';
import 'game_overlay.dart';
import 'hint_toast.dart';
import 'power_up_toolbar.dart';
import 'reward_badge.dart';
import 'shape_hand.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({
    super.key,
    required this.mode,
    this.levelData,
    this.duelMatchId,
    this.duelSeed,
    this.duelIsBot = false,
  });

  final GameMode mode;
  final LevelData? levelData;

  /// PvP duello parametreleri (lobby'den gelir).
  final String? duelMatchId;
  final int? duelSeed;
  final bool duelIsBot;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  late final GlooGame _game;
  final ClipRecorder _clipRecorder = ClipRecorder();

  // Elde tutulan 3 parca; null = slot kullanildi
  late List<(GelShape, GelColor)?> _hand;
  bool _firstHandUsed = false;
  int? _selectedSlot;
  Set<(int, int)> _previewCells = {};
  bool _previewValid = false;
  (int, int)? _previewAnchor;

  // Kisa ipucu toast
  String? _toastMsg;
  Timer? _toastTimer;

  // Efekt overlay'leri
  ComboEvent? _activeCombo;
  NearMissEvent? _activeNearMiss;
  int _comboKeyIndex = 0;
  int _nearMissKeyIndex = 0;
  ({double cx, double cy, int count, Color color, int key})? _placeFeedback;
  int _feedbackKeyIndex = 0;
  List<({int row, int col, Color color, int key, Duration delay})> _burstCells =
      [];
  int _burstKeyBase = 0;
  final List<({int row, int col, Color color, int key})> _synthesisBlooms = [];
  int _synthesisKeyBase = 0;

  // Ekran sarsintisi durumu
  double _shakeIntensity = 0;
  int _shakeKey = 0;
  Timer? _shakeTimer;

  // Power-up modu
  PowerUpType? _activePowerUpMode;

  // Power-up efekt durumlari
  ({PowerUpType type, int key})? _activePowerUpEffect;
  int _powerUpFxKey = 0;
  ({int row, int col, int key})? _bombExplosion;
  int _bombFxKey = 0;
  ({List<(int, int)> cells, int key})? _undoEffect;
  int _undoFxKey = 0;

  // Protokol 1: Jel nefes alma animasyonu
  late final AnimationController _breathCtrl;

  // Protokol 2: Yerlestirme dalga yayilimi
  Set<(int, int)> _recentlyPlacedCells = {};
  int _waveKey = 0;
  Timer? _waveClearTimer;

  // Mod bazli ortam rengi
  Color get _modeColor => switch (widget.mode) {
        GameMode.classic => kColorClassic,
        GameMode.colorChef => kColorChef,
        GameMode.timeTrial => kColorTimeTrial,
        GameMode.zen => kColorZen,
        GameMode.daily => kCyan,
        GameMode.level => const Color(0xFFFF8C42),
        GameMode.duel => const Color(0xFFFF4D6D),
      };

  // Loss Aversion badge'leri
  bool _showNearMissRescueBadge = false;
  bool _showHighScoreBadge = false;
  bool _secondChanceUsed = false;

  // PvP Duel controller
  GameDuelController? _duelController;

  @override
  void initState() {
    super.initState();
    _game = GlooGame(mode: widget.mode, levelData: widget.levelData);

    // Protokol 1: Jel nefes alma — 2.4sn periyot, surekli tekrar
    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // Kalici verileri yukle
    ref.read(localRepositoryProvider.future).then((repo) async {
      final saved = await repo.getHighScore(widget.mode.name);
      _game.setInitialHighScore(saved);
      _game.setGamesPlayed(repo.getTotalGamesPlayed());
      _game.setCurrencyBalance(repo.getGelOzu());
    });

    _game.startGame();
    _refillHand();
    AnalyticsService().logGameStart(mode: widget.mode.name);

    _game.onScoreGained = (points) {
      ref.read(gameProvider(widget.mode).notifier).updateScore(_game.score);
      if (!_showHighScoreBadge &&
          _game.highScore > 0 &&
          AdManager().canShowHighScoreContinue(
            currentScore: _game.score,
            highScore: _game.highScore,
          )) {
        setState(() => _showHighScoreBadge = true);
      }
    };

    _game.onLineClear = (clearResult) {
      if (!mounted) return;
      final gridCols = _game.gridManager.cols;
      final gridRows = _game.gridManager.rows;
      final bursts =
          <({int row, int col, Color color, int key, Duration delay})>[];
      for (final entry in clearResult.clearedCellColors.entries) {
        final (row, col) = entry.key;
        final double distFromCenter = clearResult.clearedRows.contains(row)
            ? (col - (gridCols - 1) / 2.0).abs()
            : (row - (gridRows - 1) / 2.0).abs();
        bursts.add((
          row: row,
          col: col,
          color: entry.value.displayColor,
          key: ++_burstKeyBase,
          delay: Duration(milliseconds: (distFromCenter * 35).round()),
        ));
      }
      if (bursts.isNotEmpty) {
        setState(() {
          _burstCells.addAll(bursts);
          if (_burstCells.length > 200) {
            _burstCells.removeRange(0, _burstCells.length - 200);
          }
        });
      }

      // PvP: satir temizleyince rakibe engel gonder
      if (widget.mode == GameMode.duel && clearResult.totalLines > 0) {
        _duelController?.sendObstacles(clearResult.totalLines, 'small');
      }
    };

    _game.onCombo = (combo) {
      _clipRecorder.onCombo(combo);
      if (mounted) {
        setState(() {
          _activeCombo = combo;
          _comboKeyIndex++;
          if (combo.tier == ComboTier.epic) {
            _shakeIntensity = GameConstants.shakeAmplitudeEpic;
            _shakeKey++;
          } else if (combo.tier == ComboTier.large) {
            _shakeIntensity = GameConstants.shakeAmplitudeLarge;
            _shakeKey++;
          }
        });

        if (widget.mode == GameMode.duel) {
          _duelController?.sendObstacles(0, combo.tier.name);
        }
      }
    };

    _game.onNearMiss = (event) {
      _clipRecorder.onNearMiss(event);
      if (mounted) {
        setState(() {
          _activeNearMiss = event;
          _nearMissKeyIndex++;
          if (event.isCritical && AdManager().canShowNearMissRescue()) {
            _showNearMissRescueBadge = true;
          }
        });
      }
    };

    _game.onTimerTick = (seconds) {
      if (mounted) {
        ref
            .read(gameProvider(widget.mode).notifier)
            .updateRemainingSeconds(seconds);
      }
    };

    _game.onChefProgress = (progress, required) {
      if (mounted) {
        ref
            .read(gameProvider(widget.mode).notifier)
            .updateChef(progress, required);
      }
    };

    _game.onChefLevelComplete = (completedIndex, targetColor, allComplete) {
      if (!mounted) return;
      final nextLevel = _game.currentChefLevel;
      ref.read(gameProvider(widget.mode).notifier).updateChef(
            0,
            nextLevel?.requiredCount ?? 1,
          );
      showChefLevelComplete(
        context: context,
        completedIndex: completedIndex,
        targetColor: targetColor,
        allComplete: allComplete,
        onContinue: () {
          setState(() {
            _refillHand();
            _selectedSlot = null;
            _previewCells = {};
            _previewValid = false;
            _previewAnchor = null;
            _burstCells = [];
          });
        },
      );
    };

    // Jel Ozu guncellemesi — setState yok, sadece provider + persist
    _game.currencyManager.onBalanceChanged = (balance) {
      if (mounted) {
        ref.read(gameProvider(widget.mode).notifier).updateGelOzu(balance);
        ref.read(localRepositoryProvider.future).then((repo) {
          repo.saveGelOzu(balance);
        });
      }
    };

    // Hamle sayaci
    _game.onMoveCompleted = (moves) {
      if (mounted) {
        ref.read(gameProvider(widget.mode).notifier).updateMovesUsed(moves);
      }
    };

    // Seviye tamamlama
    _game.onLevelComplete = () {
      if (!mounted) return;
      final levelId = widget.levelData?.id ?? 0;
      final score = _game.score;
      ref.read(localRepositoryProvider.future).then((repo) {
        repo.setLevelCompleted(levelId, score);
      });
      showLevelComplete(context: context, score: score, levelId: levelId);
    };

    // Jel Enerjisi kazanimi (meta-game kaynak)
    _game.onJelEnergyEarned = (amount) {
      if (!mounted) return;
      ref.read(localRepositoryProvider.future).then((repo) {
        final current = repo.getGelEnergy();
        final updated = current + amount;
        repo.saveGelEnergy(updated);
        final totalEarned = repo.getTotalEarnedEnergy() + amount;
        repo.saveTotalEarnedEnergy(totalEarned);

        RemoteRepository().saveMetaState(
          gelEnergy: updated,
          totalEarnedEnergy: totalEarned,
        );
      });
    };

    _game.onColorSynthesis = (resultColor, position) {
      if (!mounted) return;
      setState(() {
        _synthesisBlooms.add((
          row: position.$1,
          col: position.$2,
          color: resultColor.displayColor,
          key: ++_synthesisKeyBase,
        ));
        if (_synthesisBlooms.length > 20) {
          _synthesisBlooms.removeRange(0, _synthesisBlooms.length - 20);
        }
      });
    };

    _game.onGameOver = () {
      if (!mounted) return;
      final score = _game.score;
      ref.read(localRepositoryProvider.future).then((repo) {
        repo.saveScore(mode: widget.mode.name, value: score);
        repo.incrementGamesPlayed();
        repo.updateAverageScore(score);
        if (widget.mode == GameMode.daily) {
          repo.saveDailyResult(score);
          RemoteRepository().submitDailyResult(score: score, completed: true);
        }
        if (widget.mode == GameMode.level && widget.levelData != null) {
          repo.saveLevelHighScore(widget.levelData!.id, score);
        }
      });
      RemoteRepository().submitScore(mode: widget.mode.name, value: score);
      AnalyticsService().logGameOver(mode: widget.mode.name, score: score);

      // Duel: skor broadcast'ini durdur ve oyun bitis sinyali gonder
      if (widget.mode == GameMode.duel) {
        _duelController?.scoreBroadcastTimer?.cancel();
        _duelController?.botScoreTimer?.cancel();
        _duelController?.handleGameOver(score, context);
        return;
      }

      _showGameOverDialog();
    };

    // PvP Duel: realtime baglantisi kur
    if (widget.mode == GameMode.duel) {
      _duelController = GameDuelController(
        ref: ref,
        game: _game,
        matchId: widget.duelMatchId,
        isBot: widget.duelIsBot,
        seed: widget.duelSeed ?? 0,
        onStateChanged: () {
          // Grid was mutated in-place by incoming PvP obstacles;
          // trigger rebuild so GridView reflects new cell states.
          if (mounted) setState(() {});
        },
      );
      _duelController!.init();
    }
  }

  void _refillHand() {
    if (!_firstHandUsed && widget.mode == GameMode.daily) {
      _firstHandUsed = true;
      _hand = List<(GelShape, GelColor)?>.from(
        ShapeGenerator.generateSeededHand(ShapeGenerator.todaySeed()),
      );
    } else {
      _hand = List<(GelShape, GelColor)?>.from(
        _game.generateNextHand(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: kBgDark,
      body: Stack(
        children: [
          const GameBackground(),
          AmbientGelDroplets(
            count: 10,
            baseColor: _modeColor,
            speedFactor: widget.mode == GameMode.zen ? 0.5 : 1.0,
          ),
          SafeArea(
            child: Column(
              children: [
                GameOverlay(game: _game, mode: widget.mode),
                const SizedBox(height: 8),
                Expanded(child: _buildGrid()),
              ],
            ),
          ),
          if (_activeNearMiss != null)
            Positioned.fill(
              child: NearMissEffect(
                key: ValueKey(_nearMissKeyIndex),
                event: _activeNearMiss!,
                onDismiss: () => setState(() => _activeNearMiss = null),
              ),
            ),
          if (_activeCombo != null && _activeCombo!.tier != ComboTier.none)
            Positioned.fill(
              child: ComboEffect(
                key: ValueKey(_comboKeyIndex),
                combo: _activeCombo!,
                onDismiss: () => setState(() => _activeCombo = null),
              ),
            ),
          if (_activePowerUpEffect != null)
            Positioned.fill(
              child: PowerUpActivateEffect(
                key: ValueKey(_activePowerUpEffect!.key),
                color: kPowerUpColors[_activePowerUpEffect!.type]!.$1,
                onDismiss: () => setState(() => _activePowerUpEffect = null),
              ),
            ),
          if (_toastMsg != null)
            Positioned(
              bottom: 156,
              left: 40,
              right: 40,
              child: HintToast(
                key: ValueKey(_toastMsg),
                msg: _toastMsg!,
              ),
            ),
          if (_showNearMissRescueBadge)
            Positioned(
              top: topPadding + 52,
              right: 16,
              child: RewardBadge(
                label: 'Kurtarilabilir!',
                icon: Icons.shield_rounded,
                color: const Color(0xFFFF7B3C),
                onTap: () {
                  AdManager().showNearMissRescue(
                    onRewarded: () {
                      _game.powerUpSystem.grantFreePowerUp(PowerUpType.bomb);
                      setState(() => _showNearMissRescueBadge = false);
                      _showToast('Bomb kazandin!');
                    },
                  );
                },
              ),
            ),
          if (_showHighScoreBadge)
            Positioned(
              top: topPadding + 52,
              left: 16,
              child: RewardBadge(
                label: 'Rekoruna yakinsin!',
                icon: Icons.star_rounded,
                color: const Color(0xFFFFD700),
                onTap: () {
                  AdManager().showHighScoreContinue(
                    onRewarded: () {
                      _game.continueWithExtraMoves(5);
                      setState(() => _showHighScoreBadge = false);
                      _showToast('+5 Hamle!');
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ─── Izgara ───────────────────────────────────────────────────────────

  Widget _buildGrid() {
    final colorBlindMode = ref.watch(appSettingsProvider).colorBlindMode;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = _game.gridManager.cols;
        final rows = _game.gridManager.rows;
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
                        _previewCells = {};
                        _previewValid = false;
                        _previewAnchor = null;
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
                          final gridCell = _game.gridManager.getCell(row, col);
                          final cellColor = gridCell.color;
                          final isPreview = _previewCells.contains((row, col));

                          return GameCellWidget(
                            row: row,
                            col: col,
                            gridCell: gridCell,
                            cellColor: cellColor,
                            isPreview: isPreview,
                            colorBlindMode: colorBlindMode,
                            cols: cols,
                            breathCtrl: _breathCtrl,
                            recentlyPlacedCells: _recentlyPlacedCells,
                            waveKey: _waveKey,
                            previewValid: _previewValid,
                            previewSlotColor: _selectedSlot != null
                                ? _hand[_selectedSlot!]?.$2
                                : null,
                            selectedSlot: _selectedSlot,
                            activePowerUpMode: _activePowerUpMode,
                            onTap: () => _onCellTap(row, col),
                            onHover: () => _onCellHover(row, col),
                          );
                        },
                      ),
                    ),
                  )),
                  // Hucre patlamasi overlay'leri
                  ..._burstCells.map((burst) {
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
                              setState(() => _burstCells
                                  .removeWhere((b) => b.key == burst.key));
                            }
                          },
                        ),
                      ),
                    );
                  }),
                  // Renk sentezi bloom overlay'leri
                  ..._synthesisBlooms.map((bloom) {
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
                              setState(() => _synthesisBlooms
                                  .removeWhere((b) => b.key == bloom.key));
                            }
                          },
                        ),
                      ),
                    );
                  }),
                  if (_placeFeedback != null)
                    Positioned(
                      left: _placeFeedback!.cx * (cell + gap) + cell / 2,
                      top: _placeFeedback!.cy * (cell + gap) + cell / 2,
                      child: FractionalTranslation(
                        translation: const Offset(-0.5, -0.5),
                        child: PlaceFeedbackEffect(
                          key: ValueKey(_placeFeedback!.key),
                          count: _placeFeedback!.count,
                          color: _placeFeedback!.color,
                          onDismiss: () =>
                              setState(() => _placeFeedback = null),
                        ),
                      ),
                    ),
                  if (_bombExplosion != null)
                    Positioned(
                      left: _bombExplosion!.col * (cell + gap) +
                          cell / 2 -
                          cell * 3,
                      top: _bombExplosion!.row * (cell + gap) +
                          cell / 2 -
                          cell * 3,
                      child: IgnorePointer(
                        child: BombExplosionEffect(
                          key: ValueKey(_bombExplosion!.key),
                          cellSize: cell,
                          onDismiss: () =>
                              setState(() => _bombExplosion = null),
                        ),
                      ),
                    ),
                  if (_undoEffect != null)
                    Positioned.fill(
                      child: UndoRewindEffect(
                        key: ValueKey(_undoEffect!.key),
                        cells: _undoEffect!.cells,
                        cellSize: cell,
                        gridGap: gap,
                        onDismiss: () => setState(() => _undoEffect = null),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            PowerUpToolbar(
              balance: _game.currencyManager.balance,
              powerUpSystem: _game.powerUpSystem,
              activePowerUpMode: _activePowerUpMode,
              showFreeze: widget.mode == GameMode.timeTrial ||
                  widget.mode == GameMode.duel,
              onPowerUpTap: _onPowerUpTap,
            ),
            const SizedBox(height: 8),
            ShapeHand(
              hand: _hand,
              selectedSlot: _selectedSlot,
              onSlotTap: _onSlotTap,
            ),
            const SizedBox(height: 16),
          ],
        );

        // Ekran sarsintisi
        if (_shakeIntensity > 0) {
          gridContent = ScreenShake(
            key: ValueKey(_shakeKey),
            intensity: _shakeIntensity,
            duration: Duration(
              milliseconds: _shakeIntensity >= GameConstants.shakeAmplitudeEpic
                  ? GameConstants.shakeDurationEpic
                  : GameConstants.shakeDurationLarge,
            ),
            child: gridContent,
          );
          _shakeTimer?.cancel();
          _shakeTimer = Timer(
            Duration(
                milliseconds:
                    _shakeIntensity >= GameConstants.shakeAmplitudeEpic
                        ? GameConstants.shakeDurationEpic
                        : GameConstants.shakeDurationLarge),
            () {
              if (mounted) setState(() => _shakeIntensity = 0.0);
            },
          );
        }

        return gridContent;
      },
    );
  }

  // ─── Etkilesim ──────────────────────────────────────────────────────────

  void _showToast(String msg) {
    _toastTimer?.cancel();
    setState(() => _toastMsg = msg);
    _toastTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _toastMsg = null);
    });
  }

  void _onSlotTap(int index) {
    if (_activePowerUpMode != null) {
      setState(() => _activePowerUpMode = null);
    }
    if (_hand[index] == null) {
      _showToast(ref.read(stringsProvider).toastSlotUsed);
      return;
    }
    setState(() {
      if (_selectedSlot == index) {
        _selectedSlot = null;
      } else {
        _selectedSlot = index;
      }
      _previewCells = {};
      _previewValid = false;
      _previewAnchor = null;
    });
  }

  void _onCellHover(int row, int col) {
    if (_activePowerUpMode == PowerUpType.bomb) return;
    if (_selectedSlot == null) return;
    final slot = _hand[_selectedSlot!];
    if (slot == null) return;

    final (shape, color) = slot;
    final (ar, ac) = _clampAnchor(shape, row, col);
    final cells = shape.at(ar, ac);

    setState(() {
      _previewCells = cells.toSet();
      _previewValid = _game.gridManager.canPlace(cells, color);
      _previewAnchor = (ar, ac);
    });
  }

  void _onCellTap(int row, int col) {
    // Bomb power-up modu
    if (_activePowerUpMode == PowerUpType.bomb) {
      final result = _game.useBomb(row, col);
      if (result != null && result.isNotEmpty) {
        setState(() {
          _activePowerUpMode = null;
          _bombExplosion = (row: row, col: col, key: ++_bombFxKey);
        });
      } else {
        setState(() => _activePowerUpMode = null);
        _showToast('Bomba kullanilamadi');
      }
      return;
    }

    if (_selectedSlot == null) {
      _showToast(ref.read(stringsProvider).toastSelectShape);
      return;
    }
    final slot = _hand[_selectedSlot!];
    if (slot == null) return;

    final (shape, color) = slot;
    final (ar, ac) = _clampAnchor(shape, row, col);
    final cells = shape.at(ar, ac);
    final canPlace = _game.gridManager.canPlace(cells, color);

    if (_previewAnchor != (ar, ac)) {
      setState(() {
        _previewCells = cells.toSet();
        _previewValid = canPlace;
        _previewAnchor = (ar, ac);
      });
      return;
    }

    if (!canPlace) {
      _showToast(ref.read(stringsProvider).toastCannotPlace);
      return;
    }

    _game.placePiece(cells, color);
    ref
        .read(gameProvider(widget.mode).notifier)
        .updateFill(_game.gridManager.filledCells);

    final feedbackCx = ac + (shape.colCount - 1) / 2.0;
    final feedbackCy = ar + (shape.rowCount - 1) / 2.0;

    setState(() {
      _hand[_selectedSlot!] = null;
      _selectedSlot = null;
      _previewCells = {};
      _previewValid = false;
      _previewAnchor = null;
      _placeFeedback = (
        cx: feedbackCx,
        cy: feedbackCy,
        count: cells.length,
        color: color.displayColor,
        key: ++_feedbackKeyIndex,
      );
      _recentlyPlacedCells = cells.toSet();
      _waveKey++;
      if (_hand.every((h) => h == null)) _refillHand();
    });

    _waveClearTimer?.cancel();
    _waveClearTimer = Timer(const Duration(milliseconds: 480), () {
      if (mounted) setState(() => _recentlyPlacedCells = {});
    });

    _game.checkGameOver(
      _hand.where((s) => s != null).map((s) => s!.$1).toList(),
    );
  }

  void _onPowerUpTap(PowerUpType type) {
    switch (type) {
      case PowerUpType.rotate:
        if (_selectedSlot == null || _hand[_selectedSlot!] == null) {
          _showToast('Once bir sekil sec');
          return;
        }
        final (shape, color) = _hand[_selectedSlot!]!;
        final rotated = _game.rotateShape(shape);
        if (rotated != null) {
          setState(() {
            _hand[_selectedSlot!] = (rotated, color);
            _previewCells = {};
            _previewValid = false;
            _previewAnchor = null;
            _activePowerUpEffect =
                (type: PowerUpType.rotate, key: ++_powerUpFxKey);
          });
        }

      case PowerUpType.bomb:
        if (_activePowerUpMode == PowerUpType.bomb) {
          setState(() => _activePowerUpMode = null);
          return;
        }
        setState(() => _activePowerUpMode = PowerUpType.bomb);
        _showToast('Bomba merkezi sec');

      case PowerUpType.undo:
        final result = _game.useUndo();
        if (result != null) {
          setState(() {
            _undoEffect = (cells: result, key: ++_undoFxKey);
          });
        }

      case PowerUpType.freeze:
        final success = _game.useFreeze();
        if (success) {
          _showToast('10sn donduruldu!');
        }

      case PowerUpType.peek:
      case PowerUpType.rainbow:
        break;
    }
  }

  (int, int) _clampAnchor(GelShape shape, int row, int col) {
    final maxRow = _game.gridManager.rows - shape.rowCount;
    final maxCol = _game.gridManager.cols - shape.colCount;
    return (row.clamp(0, maxRow), col.clamp(0, maxCol));
  }

  void _showGameOverDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final adManager = AdManager();
      final repo = await ref.read(localRepositoryProvider.future);
      final avgScore = repo.getAverageScore();
      final canSecondChance = !_secondChanceUsed &&
          adManager.canShowSecondChance(
            currentScore: _game.score,
            averageScore: avgScore,
          );

      if (!mounted) return;
      showGeneralDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        barrierLabel: '',
        transitionDuration: const Duration(milliseconds: 380),
        transitionBuilder: (ctx, anim, secondaryAnim, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        pageBuilder: (ctx, anim, secondaryAnim) {
          return GameOverOverlay(
            score: _game.score,
            mode: widget.mode,
            filledCells: _game.gridManager.filledCells,
            totalCells: _game.gridManager.totalCells,
            isNewHighScore: _game.isNewHighScore,
            showSecondChance: canSecondChance,
            onSecondChance: canSecondChance
                ? () {
                    Navigator.of(ctx).pop();
                    adManager.showSecondChance(
                      onRewarded: () {
                        setState(() {
                          _secondChanceUsed = true;
                          _game.continueWithExtraMoves(3);
                          _showNearMissRescueBadge = false;
                          _showHighScoreBadge = false;
                        });
                        ref
                            .read(gameProvider(widget.mode).notifier)
                            .updateScore(_game.score);
                      },
                    );
                  }
                : null,
            onReplay: () {
              Navigator.of(ctx).pop();
              setState(() {
                _game.startGame();
                _refillHand();
                _selectedSlot = null;
                _previewCells = {};
                _previewValid = false;
                _activePowerUpMode = null;
                _secondChanceUsed = false;
                _showNearMissRescueBadge = false;
                _showHighScoreBadge = false;
              });
              ref.read(gameProvider(widget.mode).notifier).reset();
            },
            onHome: () {
              Navigator.of(ctx).pop();
              context.go('/');
            },
          );
        },
      );
    });
  }

  @override
  void dispose() {
    _waveClearTimer?.cancel();
    _shakeTimer?.cancel();
    _toastTimer?.cancel();
    _game.cancelTimer();
    _game.onLineClear = null;
    _game.onCombo = null;
    _game.onNearMiss = null;
    _game.onGameOver = null;
    _game.onTimerTick = null;
    _game.onChefProgress = null;
    _game.onChefLevelComplete = null;
    _game.onMoveCompleted = null;
    _game.onLevelComplete = null;
    _game.onIceCracked = null;
    _game.onGravityApplied = null;
    _game.currencyManager.onBalanceChanged = null;
    _duelController?.dispose();
    _breathCtrl.dispose();
    _clipRecorder.dispose();
    super.dispose();
  }
}
