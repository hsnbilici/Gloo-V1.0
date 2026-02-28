import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/game_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/utils/near_miss_detector.dart';
import '../../game/levels/level_data.dart';
import '../../game/shapes/gel_shape.dart';
import '../../game/systems/combo_detector.dart';
import '../../game/systems/powerup_system.dart';
import '../../game/world/cell_type.dart';
import '../../game/world/game_world.dart';
import '../../providers/audio_provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/user_provider.dart';
import '../../data/remote/pvp_realtime_service.dart';
import '../../game/pvp/matchmaking.dart';
import '../../providers/pvp_provider.dart';
import '../../data/remote/remote_repository.dart';
import '../../services/ad_manager.dart';
import '../../services/analytics_service.dart';
import '../../viral/clip_recorder.dart';
import 'chef_level_overlay.dart';
import 'gel_cell_painter.dart';
import 'game_effects.dart';
import '../pvp/duel_result_overlay.dart';
import 'game_over_overlay.dart';
import 'game_overlay.dart';

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

  // Elde tutulan 3 parça; null = slot kullanıldı
  late List<(GelShape, GelColor)?> _hand;
  bool _firstHandUsed = false;
  int? _selectedSlot;
  Set<(int, int)> _previewCells = {};
  bool _previewValid = false;
  (int, int)? _previewAnchor;

  // Kısa ipucu toast
  String? _toastMsg;
  Timer? _toastTimer;

  // Efekt overlay'leri
  ComboEvent? _activeCombo;
  NearMissEvent? _activeNearMiss;
  int _comboKeyIndex = 0;
  int _nearMissKeyIndex = 0;
  ({double cx, double cy, int count, Color color, int key})? _placeFeedback;
  int _feedbackKeyIndex = 0;
  List<({int row, int col, Color color, int key, Duration delay})> _burstCells = [];
  int _burstKeyBase = 0;

  // Faz 4: Ekran sarsıntısı durumu
  double _shakeIntensity = 0;
  int _shakeKey = 0;

  // Faz 4: Power-up modu
  PowerUpType? _activePowerUpMode;

  // Faz 4: Power-up efekt durumları
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

  // Faz F: Mod bazlı ortam rengi
  Color get _modeColor => switch (widget.mode) {
        GameMode.classic   => kColorClassic,
        GameMode.colorChef => kColorChef,
        GameMode.timeTrial => kColorTimeTrial,
        GameMode.zen       => kColorZen,
        GameMode.daily     => kCyan,
        GameMode.level     => const Color(0xFFFF8C42),
        GameMode.duel      => const Color(0xFFFF4D6D),
      };

  // Faz 4: Loss Aversion badge'leri
  bool _showNearMissRescueBadge = false;
  bool _showHighScoreBadge = false;
  bool _secondChanceUsed = false;

  // PvP Duel: realtime senkronizasyon
  PvpRealtimeService? _pvpService;
  StreamSubscription<int>? _opponentScoreSub;
  StreamSubscription<ObstaclePacket>? _opponentObstacleSub;
  StreamSubscription<int>? _opponentGameOverSub;
  Timer? _scoreBroadcastTimer;
  Timer? _botScoreTimer;

  @override
  void initState() {
    super.initState();
    _game = GlooGame(mode: widget.mode, levelData: widget.levelData);

    // Protokol 1: Jel nefes alma — 2.4sn periyot, surekli tekrar
    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // Kalıcı verileri yükle
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
      // B4: High score yaklasma badge
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
      final bursts = <({int row, int col, Color color, int key, Duration delay})>[];
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
        setState(() => _burstCells = [..._burstCells, ...bursts]);
      }

      // PvP: satir temizleyince rakibe engel gonder
      if (widget.mode == GameMode.duel && clearResult.totalLines > 0) {
        _sendDuelObstacles(clearResult.totalLines, 'small');
      }
    };

    _game.onCombo = (combo) {
      _clipRecorder.onCombo(combo);
      if (mounted) {
        setState(() {
          _activeCombo = combo;
          _comboKeyIndex++;
          // Faz 4: Ekran sarsıntısı
          if (combo.tier == ComboTier.epic) {
            _shakeIntensity = GameConstants.shakeAmplitudeEpic;
            _shakeKey++;
          } else if (combo.tier == ComboTier.large) {
            _shakeIntensity = GameConstants.shakeAmplitudeLarge;
            _shakeKey++;
          }
        });

        // PvP: kombo engel bonusu
        if (widget.mode == GameMode.duel) {
          _sendDuelObstacles(0, combo.tier.name);
        }
      }
    };

    _game.onNearMiss = (event) {
      _clipRecorder.onNearMiss(event);
      if (mounted) {
        setState(() {
          _activeNearMiss = event;
          _nearMissKeyIndex++;
          // B3: Near-miss critical ise kurtarma badge goster
          if (event.isCritical && AdManager().canShowNearMissRescue()) {
            _showNearMissRescueBadge = true;
          }
        });
      }
    };

    _game.onTimerTick = (seconds) {
      if (mounted) {
        ref.read(gameProvider(widget.mode).notifier).updateRemainingSeconds(seconds);
      }
    };

    _game.onChefProgress = (progress, required) {
      if (mounted) {
        ref.read(gameProvider(widget.mode).notifier).updateChef(progress, required);
      }
    };

    _game.onChefLevelComplete = (completedIndex, targetColor, allComplete) {
      if (!mounted) return;
      final nextLevel = _game.currentChefLevel;
      ref.read(gameProvider(widget.mode).notifier).updateChef(
        0,
        nextLevel?.requiredCount ?? 1,
      );
      _showChefLevelCompleteDialog(completedIndex, targetColor, allComplete);
    };

    // Faz 4: Jel Özü güncellemesi
    _game.currencyManager.onBalanceChanged = (balance) {
      if (mounted) {
        setState(() {});
        ref.read(gameProvider(widget.mode).notifier).updateGelOzu(balance);
        // Kalıcı kayıt
        ref.read(localRepositoryProvider.future).then((repo) {
          repo.saveGelOzu(balance);
        });
      }
    };

    // Faz 4: Hamle sayacı
    _game.onMoveCompleted = (moves) {
      if (mounted) {
        ref.read(gameProvider(widget.mode).notifier).updateMovesUsed(moves);
      }
    };

    // Faz 4: Seviye tamamlama
    _game.onLevelComplete = () {
      if (!mounted) return;
      _showLevelCompleteDialog();
    };

    // Faz 4: Jel Enerjisi kazanımı (meta-game kaynak)
    _game.onJelEnergyEarned = (amount) {
      if (!mounted) return;
      ref.read(localRepositoryProvider.future).then((repo) {
        final current = repo.getGelEnergy();
        final updated = current + amount;
        repo.saveGelEnergy(updated);
        repo.saveTotalEarnedEnergy(repo.getTotalEarnedEnergy() + amount);
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
          // Gunluk sonucu backend'e de gonder
          RemoteRepository().submitDailyResult(score: score, completed: true);
        }
        if (widget.mode == GameMode.level && widget.levelData != null) {
          repo.saveLevelHighScore(widget.levelData!.id, score);
        }
      });
      // Backend'e skor gonder (isConfigured degilse sessizce atlar)
      RemoteRepository().submitScore(mode: widget.mode.name, value: score);
      AnalyticsService().logGameOver(mode: widget.mode.name, score: score);

      // Duel: skor broadcast'ini durdur ve oyun bitis sinyali gonder
      if (widget.mode == GameMode.duel) {
        _scoreBroadcastTimer?.cancel();
        _botScoreTimer?.cancel();
        _handleDuelGameOver(score);
        return;
      }

      _showGameOverDialog();
    };

    // PvP Duel: realtime baglantisi kur
    if (widget.mode == GameMode.duel) {
      _initDuelRealtime();
    }
  }

  void _refillHand() {
    if (!_firstHandUsed && widget.mode == GameMode.daily) {
      _firstHandUsed = true;
      _hand = List<(GelShape, GelColor)?>.from(
        ShapeGenerator.generateSeededHand(ShapeGenerator.todaySeed()),
      );
    } else {
      // Faz 4: Smart RNG kullan
      _hand = List<(GelShape, GelColor)?>.from(
        _game.generateNextHand(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDark,
      body: Stack(
        children: [
          _Background(),
          // Faz F: Ortam yüzücü jel damlacıkları
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
          // Faz 4: Power-up aktivasyon pulse (Rotate/Undo)
          if (_activePowerUpEffect != null)
            Positioned.fill(
              child: PowerUpActivateEffect(
                key: ValueKey(_activePowerUpEffect!.key),
                color: _kPowerUpColors[_activePowerUpEffect!.type]!.$1,
                onDismiss: () => setState(() => _activePowerUpEffect = null),
              ),
            ),
          if (_toastMsg != null)
            Positioned(
              bottom: 156,
              left: 40,
              right: 40,
              child: _HintToast(
                key: ValueKey(_toastMsg),
                msg: _toastMsg!,
              ),
            ),
          // B3: Near-miss kurtarma badge
          if (_showNearMissRescueBadge)
            Positioned(
              top: MediaQuery.of(context).padding.top + 52,
              right: 16,
              child: _RewardBadge(
                label: 'Kurtarilabilir!',
                icon: Icons.shield_rounded,
                color: const Color(0xFFFF7B3C),
                onTap: () {
                  AdManager().showNearMissRescue(
                    onRewarded: () {
                      // Bomb power-up hediye
                      _game.powerUpSystem.grantFreePowerUp(PowerUpType.bomb);
                      setState(() => _showNearMissRescueBadge = false);
                      _showToast('Bomb kazandin!');
                    },
                  );
                },
              ),
            ),
          // B4: High score yaklasma badge
          if (_showHighScoreBadge)
            Positioned(
              top: MediaQuery.of(context).padding.top + 52,
              left: 16,
              child: _RewardBadge(
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

  // ─── Izgara + El + Power-up toolbar ─────────────────────────────────────

  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final colorBlindMode =
            ref.watch(audioSettingsProvider).colorBlindMode;
        // Faz 4: Dinamik ızgara boyutu
        final cols = _game.gridManager.cols;
        final rows = _game.gridManager.rows;
        const gap = 2.0;
        const hPad = 12.0;
        const handH = 120.0;
        const handGap = 8.0;
        const bottomPad = 16.0;
        const powerUpH = 56.0; // Faz 4: Power-up toolbar yüksekliği
        const powerUpGap = 6.0;

        final availW = constraints.maxWidth - hPad * 2;
        final availH = constraints.maxHeight - handH - handGap - bottomPad - powerUpH - powerUpGap;

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
                  SizedBox(
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

                          // Faz 4: Hücre tipi bazlı görünüm
                          return _buildCellWidget(
                            row, col, gridCell, cellColor,
                            isPreview, colorBlindMode,
                          );
                        },
                      ),
                    ),
                  ),
                  // Hücre patlaması overlay'leri
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
                          onDismiss: () => setState(() => _placeFeedback = null),
                        ),
                      ),
                    ),
                  // Faz 4: Bomb patlama efekti
                  if (_bombExplosion != null)
                    Positioned(
                      left: _bombExplosion!.col * (cell + gap) + cell / 2 - cell * 3,
                      top: _bombExplosion!.row * (cell + gap) + cell / 2 - cell * 3,
                      child: IgnorePointer(
                        child: BombExplosionEffect(
                          key: ValueKey(_bombExplosion!.key),
                          cellSize: cell,
                          onDismiss: () => setState(() => _bombExplosion = null),
                        ),
                      ),
                    ),
                  // Faz 4: Undo geri sarma efekti
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
            const SizedBox(height: powerUpGap),
            _buildPowerUpToolbar(),
            const SizedBox(height: handGap),
            _buildShapeHand(),
            const SizedBox(height: bottomPad),
          ],
        );

        // Faz 4: Ekran sarsıntısı
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
          // Sarsıntı sonrası sıfırla
          Future.delayed(
            Duration(milliseconds: _shakeIntensity >= GameConstants.shakeAmplitudeEpic
                ? GameConstants.shakeDurationEpic
                : GameConstants.shakeDurationLarge),
            () {
              if (mounted) setState(() => _shakeIntensity = 0);
            },
          );
        }

        return gridContent;
      },
    );
  }

  // ─── Hücre widget'ı (Protokol 1+2: Jel render + Squash/Stretch) ─────────

  Widget _buildCellWidget(
    int row, int col, Cell gridCell, GelColor? cellColor,
    bool isPreview, bool colorBlindMode,
  ) {
    // Stone hücreler: koyu, yerleştirilemez
    if (gridCell.type == CellType.stone) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(UIConstants.radiusXs),
          border: Border.all(
            color: const Color(0xFF2A2A4E),
            width: 1,
          ),
        ),
      );
    }

    // Faz 4: Hücre tipi overlay'leri
    Widget? typeOverlay;
    if (gridCell.type == CellType.ice && gridCell.iceLayer > 0) {
      typeOverlay = Container(
        decoration: BoxDecoration(
          color: const Color(0xFF88CCFF).withValues(
            alpha: gridCell.iceLayer == 2 ? 0.45 : 0.25,
          ),
          borderRadius: BorderRadius.circular(UIConstants.radiusXs),
          border: Border.all(
            color: const Color(0xFFAADDFF).withValues(alpha: 0.5),
            width: gridCell.iceLayer == 2 ? 2 : 1,
          ),
        ),
      );
    } else if (gridCell.type == CellType.locked) {
      final lockColor = gridCell.lockedColor?.displayColor ?? Colors.grey;
      typeOverlay = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UIConstants.radiusXs),
          border: Border.all(color: lockColor, width: 2),
        ),
        child: cellColor == null
            ? Center(
                child: Icon(Icons.lock_outline,
                    size: 10, color: lockColor.withValues(alpha: 0.7)),
              )
            : null,
      );
    } else if (gridCell.type == CellType.gravity) {
      typeOverlay = Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 2,
          margin: const EdgeInsets.only(bottom: 1, left: 2, right: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      );
    } else if (gridCell.type == CellType.rainbow) {
      if (cellColor == null) {
        typeOverlay = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UIConstants.radiusXs),
            border: Border.all(
              color: const Color(0xFFFF69B4).withValues(alpha: 0.5),
              width: 1,
            ),
            gradient: const LinearGradient(
              colors: [
                Color(0x22FF3B3B),
                Color(0x22FFE03C),
                Color(0x223CFF8B),
                Color(0x223C8BFF),
              ],
            ),
          ),
        );
      }
    }

    // ── Hücre içeriği ────────────────────────────────────────────────────
    Widget cellContent;

    if (cellColor != null) {
      // DOLU HÜCRE — Protokol 1: GelCellPainter ile jel render
      final cols = _game.gridManager.cols;
      cellContent = RepaintBoundary(
        child: CustomPaint(
          painter: GelCellPainter(
            color: cellColor.displayColor,
            borderRadius: UIConstants.radiusXs,
            breathAnimation: _breathCtrl,
            breathPhase: (row * cols + col) * 0.12,
          ),
          child: colorBlindMode
              ? Center(
                  child: Text(
                    cellColor.shortLabel,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                )
              : null,
        ),
      );

      // Protokol 2: Squash & Stretch yerlestirme animasyonu
      cellContent = _SquashStretchCell(
        key: ValueKey(('ss', row, col)),
        isPlaced: true,
        child: cellContent,
      );

      // Protokol 2: Dalga yayilimi — komsu hücrelere bounce
      if (_recentlyPlacedCells.isNotEmpty &&
          !_recentlyPlacedCells.contains((row, col))) {
        int minDist = 999;
        for (final placed in _recentlyPlacedCells) {
          final d = (placed.$1 - row).abs() + (placed.$2 - col).abs();
          if (d < minDist) minDist = d;
        }
        if (minDist <= 3) {
          cellContent = _WaveRipple(
            key: ValueKey(('wave', row, col, _waveKey)),
            distance: minDist,
            child: cellContent,
          );
        }
      }
    } else if (isPreview) {
      // PREVIEW HÜCRE
      final slotColor =
          _selectedSlot != null ? _hand[_selectedSlot!]?.$2 : null;
      final base = slotColor?.displayColor ?? Colors.white;
      final bg = _previewValid
          ? base.withValues(alpha: 0.50)
          : const Color(0xFFFF3B3B).withValues(alpha: 0.55);
      cellContent = Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(UIConstants.radiusXs),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 1,
          ),
        ),
      );
    } else {
      // BOŞ HÜCRE — hafif derinlik hissi icin RadialGradient
      cellContent = Container(
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            center: Alignment(-0.3, -0.3),
            radius: 1.4,
            colors: [
              Color(0x26FFFFFF), // alpha ~0.15
              Color(0x14FFFFFF), // alpha ~0.08
            ],
          ),
          borderRadius: BorderRadius.circular(UIConstants.radiusXs),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => _onCellHover(row, col),
      cursor: _selectedSlot != null || _activePowerUpMode == PowerUpType.bomb
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: GestureDetector(
        onTap: () => _onCellTap(row, col),
        child: Stack(
          fit: StackFit.expand,
          children: [
            cellContent,
            if (typeOverlay != null) Positioned.fill(child: typeOverlay),
          ],
        ),
      ),
    );
  }

  // ─── Faz 4: Power-up toolbar ──────────────────────────────────────────────

  // Power-up tema renkleri
  static const _kPowerUpColors = <PowerUpType, (Color, Color)>{
    PowerUpType.rotate: (Color(0xFF00E5FF), Color(0xFF006978)),
    PowerUpType.bomb:   (Color(0xFFFF6B35), Color(0xFF8B2500)),
    PowerUpType.undo:   (Color(0xFFFFD740), Color(0xFF8B6914)),
    PowerUpType.freeze: (Color(0xFF80D8FF), Color(0xFF01579B)),
  };

  Widget _buildPowerUpToolbar() {
    final balance = _game.currencyManager.balance;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          // ── Jel Özü sayacı — damlacık tasarımı ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kCyan.withValues(alpha: 0.12),
                  kCyan.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(UIConstants.radiusMd),
              border: Border.all(color: kCyan.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: kCyan.withValues(alpha: 0.08),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Jel damlacığı
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(-0.3, -0.4),
                      radius: 0.9,
                      colors: [
                        kCyan.withValues(alpha: 0.9),
                        kCyan.withValues(alpha: 0.4),
                        kCyan.withValues(alpha: 0.15),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kCyan.withValues(alpha: 0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 5,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$balance',
                  style: const TextStyle(
                    color: kCyan,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // ── Power-up butonları ──
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _powerUpButton(PowerUpType.rotate, Icons.rotate_right),
                _powerUpButton(PowerUpType.bomb, Icons.flash_on),
                _powerUpButton(PowerUpType.undo, Icons.replay),
                if (widget.mode == GameMode.timeTrial || widget.mode == GameMode.duel)
                  _powerUpButton(PowerUpType.freeze, Icons.ac_unit),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _powerUpButton(PowerUpType type, IconData icon) {
    final canUse = _game.powerUpSystem.canUse(type);
    final def = kPowerUpDefs[type]!;
    final cooldown = _game.powerUpSystem.getCooldown(type);
    final isActive = _activePowerUpMode == type;
    final colors = _kPowerUpColors[type]!;
    final primary = colors.$1;
    final dark = colors.$2;

    return GestureDetector(
      onTap: canUse ? () => _onPowerUpTap(type) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: canUse
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primary.withValues(alpha: isActive ? 0.35 : 0.18),
                    dark.withValues(alpha: isActive ? 0.25 : 0.10),
                  ],
                )
              : null,
          color: canUse ? null : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(UIConstants.radiusMd),
          border: Border.all(
            color: isActive
                ? primary.withValues(alpha: 0.9)
                : canUse
                    ? primary.withValues(alpha: 0.35)
                    : Colors.white.withValues(alpha: 0.06),
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: primary.withValues(alpha: 0.15),
                    blurRadius: 4,
                  ),
                ]
              : canUse
                  ? [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.10),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
        ),
        child: Stack(
          children: [
            // Specular highlight — jel etkisi
            if (canUse)
              Positioned(
                top: 3,
                left: 5,
                right: 12,
                height: 8,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.15),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            // Ana ikon
            Center(
              child: Icon(
                icon,
                size: 22,
                color: canUse
                    ? primary
                    : Colors.white.withValues(alpha: 0.18),
                shadows: canUse
                    ? [
                        Shadow(
                          color: primary.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
            // Maliyet badge — jel kapsül
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: canUse
                      ? primary.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: canUse
                        ? primary.withValues(alpha: 0.25)
                        : Colors.transparent,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  '${def.cost}',
                  style: TextStyle(
                    color: canUse ? primary : kMuted.withValues(alpha: 0.5),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            // Cooldown overlay — karartma + sayaç
            if (cooldown > 0)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                    border: Border.all(
                      color: primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$cooldown',
                      style: TextStyle(
                        color: primary.withValues(alpha: 0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onPowerUpTap(PowerUpType type) {
    switch (type) {
      case PowerUpType.rotate:
        if (_selectedSlot == null || _hand[_selectedSlot!] == null) {
          _showToast('Önce bir şekil seç');
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
            _activePowerUpEffect = (type: PowerUpType.rotate, key: ++_powerUpFxKey);
          });
        }

      case PowerUpType.bomb:
        // Bomb: tekrar basarsa iptal et
        if (_activePowerUpMode == PowerUpType.bomb) {
          setState(() => _activePowerUpMode = null);
          return;
        }
        setState(() => _activePowerUpMode = PowerUpType.bomb);
        _showToast('Bomba merkezi seç');

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
        break; // Henüz UI entegrasyonu yok
    }
  }

  // ─── Şekil eli ──────────────────────────────────────────────────────────

  Widget _buildShapeHand() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.025),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(GameConstants.shapesInHand, (i) {
          final slot = _hand[i];
          final isSelected = _selectedSlot == i;

          if (slot == null) {
            return Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                  width: 1,
                ),
              ),
            );
          }

          final (shape, color) = slot;
          return GestureDetector(
            onTap: () => _onSlotTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.displayColor.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                border: Border.all(
                  color: isSelected
                      ? color.displayColor.withValues(alpha: 0.85)
                      : Colors.white.withValues(alpha: 0.12),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.displayColor.withValues(alpha: 0.35),
                          blurRadius: 14,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: _ShapePreview(shape: shape, color: color),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── Etkileşim ──────────────────────────────────────────────────────────

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
    // Faz 4: Bomb power-up modu
    if (_activePowerUpMode == PowerUpType.bomb) {
      final result = _game.useBomb(row, col);
      if (result != null && result.isNotEmpty) {
        setState(() {
          _activePowerUpMode = null;
          _bombExplosion = (row: row, col: col, key: ++_bombFxKey);
        });
      } else {
        // Başarısız — bomb modunu kapat
        setState(() => _activePowerUpMode = null);
        _showToast('Bomba kullanılamadı');
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
    ref.read(gameProvider(widget.mode).notifier)
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
      // Protokol 2: Dalga yayilimi icin yerlesen hucreleri kaydet
      _recentlyPlacedCells = cells.toSet();
      _waveKey++;
      if (_hand.every((h) => h == null)) _refillHand();
    });

    // Dalga animasyonu bittikten sonra temizle (380ms squash + 100ms buffer)
    Future.delayed(const Duration(milliseconds: 480), () {
      if (mounted) setState(() => _recentlyPlacedCells = {});
    });

    _game.checkGameOver(
      _hand.where((s) => s != null).map((s) => s!.$1).toList(),
    );
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _game.cancelTimer();
    _game.onLineClear        = null;
    _game.onCombo            = null;
    _game.onNearMiss         = null;
    _game.onGameOver         = null;
    _game.onTimerTick        = null;
    _game.onChefProgress     = null;
    _game.onChefLevelComplete = null;
    _game.onMoveCompleted    = null;
    _game.onLevelComplete    = null;
    _game.onIceCracked       = null;
    _game.onGravityApplied   = null;
    _game.currencyManager.onBalanceChanged = null;
    // PvP cleanup
    _scoreBroadcastTimer?.cancel();
    _botScoreTimer?.cancel();
    _opponentScoreSub?.cancel();
    _opponentObstacleSub?.cancel();
    _opponentGameOverSub?.cancel();
    if (widget.mode == GameMode.duel && widget.duelMatchId != null) {
      _pvpService?.leaveDuelRoom(widget.duelMatchId!);
    }
    _breathCtrl.dispose();
    _clipRecorder.dispose();
    super.dispose();
  }

  // ─── Yardımcılar ──────────────────────────────────────────────────────────

  (int, int) _clampAnchor(GelShape shape, int row, int col) {
    final maxRow = _game.gridManager.rows - shape.rowCount;
    final maxCol = _game.gridManager.cols - shape.colCount;
    return (row.clamp(0, maxRow), col.clamp(0, maxCol));
  }

  void _showChefLevelCompleteDialog(
    int completedIndex,
    GelColor targetColor,
    bool allComplete,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showGeneralDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        barrierLabel: '',
        transitionDuration: const Duration(milliseconds: 360),
        transitionBuilder: (ctx, anim, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        ),
        pageBuilder: (ctx, _, __) => ChefLevelOverlay(
          completedLevelIndex: completedIndex,
          targetColor: targetColor,
          isAllComplete: allComplete,
          onContinue: () {
            Navigator.of(ctx).pop();
            setState(() {
              _refillHand();
              _selectedSlot = null;
              _previewCells = {};
              _previewValid = false;
              _previewAnchor = null;
              _burstCells = [];
            });
          },
          onHome: () {
            Navigator.of(ctx).pop();
            context.go('/');
          },
        ),
      );
    });
  }

  // Faz 4: Seviye tamamlama dialog'u
  void _showLevelCompleteDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final levelId = widget.levelData?.id ?? 0;
      final score = _game.score;
      // C4: Seviye tamamlama persist
      ref.read(localRepositoryProvider.future).then((repo) {
        repo.setLevelCompleted(levelId, score);
      });
      showGeneralDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        barrierLabel: '',
        transitionDuration: const Duration(milliseconds: 380),
        transitionBuilder: (ctx, anim, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        ),
        pageBuilder: (ctx, _, __) => _LevelCompleteOverlay(
          score: score,
          levelId: levelId,
          onNextLevel: () {
            Navigator.of(ctx).pop();
            final nextId = levelId + 1;
            context.go('/game/level/$nextId');
          },
          onLevelList: () {
            Navigator.of(ctx).pop();
            context.go('/levels');
          },
          onHome: () {
            Navigator.of(ctx).pop();
            context.go('/');
          },
        ),
      );
    });
  }

  // ── PvP Duel: Realtime entegrasyon ──────────────────────────────────────

  void _sendDuelObstacles(int linesCleared, String comboTier) {
    if (widget.duelIsBot) return; // Bot maclarinda engel gonderme
    final matchId = widget.duelMatchId;
    if (matchId == null || _pvpService == null) return;

    final packets = ObstacleGenerator.fromLineClear(
      linesCleared: linesCleared,
      comboTier: comboTier,
    );
    for (final packet in packets) {
      _pvpService!.sendObstacle(matchId, packet);
    }
  }

  void _initDuelRealtime() {
    final matchId = widget.duelMatchId;
    final isBot = widget.duelIsBot;

    // Duel state'ini provider'a kaydet
    ref.read(duelProvider.notifier).setMatch(
      matchId: matchId ?? 'local',
      seed: widget.duelSeed ?? 0,
      isBot: isBot,
    );

    if (isBot) {
      _initBotSimulation();
      return;
    }

    if (matchId == null) return;

    // Gercek rakip — Supabase Realtime baglantisi
    _pvpService = ref.read(pvpRealtimeServiceProvider);
    _pvpService!.joinDuelRoom(matchId);

    // Rakip skorunu dinle
    _opponentScoreSub = _pvpService!
        .listenOpponentScore(matchId)
        .listen((score) {
      if (mounted) {
        ref.read(duelProvider.notifier).updateOpponentScore(score);
      }
    });

    // Rakip engellerini dinle
    _opponentObstacleSub = _pvpService!
        .listenOpponentObstacles(matchId)
        .listen((packet) {
      if (!mounted) return;
      _applyIncomingObstacle(packet);
    });

    // Rakip oyun bitis sinyali
    _opponentGameOverSub = _pvpService!
        .listenOpponentGameOver(matchId)
        .listen((finalScore) {
      if (mounted) {
        ref.read(duelProvider.notifier).setOpponentDone(finalScore);
      }
    });

    // Skoru her 5sn'de bir broadcast et
    _scoreBroadcastTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        if (_game.status == GameStatus.playing) {
          _pvpService!.broadcastScore(matchId, _game.score);
        }
      },
    );
  }

  void _initBotSimulation() {
    // Bot skoru: zorluk * zaman ilerlemesi * rastgele varyans
    final difficulty = MatchmakingManager.botDifficulty(
      ref.read(eloProvider).valueOrNull ?? 1000,
    );
    var botScore = 0;

    _botScoreTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || _game.status != GameStatus.playing) return;
      // Bot her 3sn'de 30-100 puan arasi kazanir (zorluga gore)
      final gain = (30 + (70 * difficulty)).round();
      botScore += gain;
      ref.read(duelProvider.notifier).updateOpponentScore(botScore);
    });
  }

  void _applyIncomingObstacle(ObstaclePacket packet) {
    // Rakipten gelen engelleri izgaraya uygula
    final grid = _game.gridManager;
    for (var i = 0; i < packet.count; i++) {
      grid.applyRandomObstacle(packet.type);
    }
    setState(() {});
  }

  void _handleDuelGameOver(int playerScore) {
    final duelState = ref.read(duelProvider);
    final matchId = duelState.matchId;
    final isBot = duelState.isBot;

    // Rakibe oyun bitis sinyali gonder
    if (!isBot && matchId != null) {
      _pvpService?.broadcastGameOver(matchId, playerScore);
    }

    // Bot: final skoru hesapla
    if (isBot) {
      _botScoreTimer?.cancel();
    }

    // ELO hesapla
    _finalizeDuelResult(playerScore);
  }

  Future<void> _finalizeDuelResult(int playerScore) async {
    final duelState = ref.read(duelProvider);
    final opponentScore = duelState.opponentScore;
    final isBot = duelState.isBot;

    final repo = await ref.read(localRepositoryProvider.future);
    final playerElo = repo.getElo();

    // Bot ELO'su oyuncu ELO'sunun %80-120'si arasi
    final opponentElo = isBot
        ? (playerElo * MatchmakingManager.botDifficulty(playerElo) * 1.2).round()
        : playerElo; // Gercek eslesmede yakinsak kabul et

    // Sonuc belirle
    final DuelOutcome outcome;
    if (playerScore > opponentScore) {
      outcome = DuelOutcome.win;
    } else if (playerScore < opponentScore) {
      outcome = DuelOutcome.loss;
    } else {
      outcome = DuelOutcome.draw;
    }

    final eloChange = EloSystem.calculateChange(
      playerElo: playerElo,
      opponentElo: opponentElo,
      outcome: outcome,
    );
    final gelReward = EloSystem.calculateGelReward(outcome);
    final newElo = (playerElo + eloChange).clamp(0, 9999);

    // Lokal persist
    repo.saveElo(newElo);
    if (outcome != DuelOutcome.draw) {
      repo.recordPvpResult(isWin: outcome == DuelOutcome.win);
    }
    repo.saveGelOzu(repo.getGelOzu() + gelReward);

    // Backend sync (isConfigured degilse sessizce atlar)
    final remote = RemoteRepository();
    remote.updateElo(newElo: newElo);
    remote.incrementPvpStats(isWin: outcome == DuelOutcome.win);
    if (duelState.matchId != null && duelState.matchId != 'local') {
      remote.submitPvpResult(
        matchId: duelState.matchId!,
        score: playerScore,
      );
    }

    // Analytics
    AnalyticsService().logPvpResult(
      outcome: outcome.name,
      eloChange: eloChange,
      isBot: isBot,
    );

    final result = DuelResult(
      outcome: outcome,
      playerScore: playerScore,
      opponentScore: opponentScore,
      eloChange: eloChange,
      gelReward: gelReward,
    );

    _showDuelResultDialog(result, newElo);
  }

  void _showDuelResultDialog(DuelResult result, int newElo) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showGeneralDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        barrierLabel: '',
        transitionDuration: const Duration(milliseconds: 380),
        transitionBuilder: (ctx, anim, _, child) {
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
        pageBuilder: (ctx, _, __) {
          return DuelResultOverlay(
            result: result,
            playerElo: newElo,
            onHome: () {
              Navigator.of(ctx).pop();
              context.go('/');
            },
            onRematch: () {
              Navigator.of(ctx).pop();
              context.go('/pvp-lobby');
            },
          );
        },
      );
    });
  }

  void _showGameOverDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // B1: Ikinci Sans kosullarini kontrol et
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
                        ref.read(gameProvider(widget.mode).notifier)
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
}

// ─── Şekil önizleme widget'ı ────────────────────────────────────────────────

class _ShapePreview extends StatelessWidget {
  const _ShapePreview({required this.shape, required this.color});

  final GelShape shape;
  final GelColor color;

  static const double _cellSize = 13.0;
  static const double _gap = 2.0;

  @override
  Widget build(BuildContext context) {
    final displayColor = color.displayColor;
    return SizedBox(
      width: shape.colCount * (_cellSize + _gap) - _gap,
      height: shape.rowCount * (_cellSize + _gap) - _gap,
      child: Stack(
        children: shape.cells.map((cell) {
          return Positioned(
            left: cell.$2 * (_cellSize + _gap),
            top: cell.$1 * (_cellSize + _gap),
            child: Container(
              width: _cellSize,
              height: _cellSize,
              decoration: BoxDecoration(
                color: displayColor,
                borderRadius: BorderRadius.circular(UIConstants.radiusXs),
                boxShadow: [
                  BoxShadow(
                    color: displayColor.withValues(alpha: 0.6),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Arkaplan ───────────────────────────────────────────────────────────────

class _Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF020D1A), kBgDark],
            ),
          ),
        ),
        Positioned(
          top: -100,
          left: -60,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00E5FF).withValues(alpha: 0.07),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          right: -40,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF9D5CFF).withValues(alpha: 0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Kısa ipucu toast ────────────────────────────────────────────────────────

class _HintToast extends StatelessWidget {
  const _HintToast({super.key, required this.msg});

  final String msg;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(UIConstants.radiusXl),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.40),
              blurRadius: 12,
            ),
          ],
        ),
        child: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 120.ms)
        .slideY(begin: 0.3, end: 0, duration: 200.ms, curve: Curves.easeOutCubic);
  }
}

// ─── Faz 4: Seviye tamamlama overlay ─────────────────────────────────────────

class _LevelCompleteOverlay extends StatelessWidget {
  const _LevelCompleteOverlay({
    required this.score,
    required this.levelId,
    required this.onNextLevel,
    required this.onLevelList,
    required this.onHome,
  });

  final int score;
  final int levelId;
  final VoidCallback onNextLevel;
  final VoidCallback onLevelList;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kBgDark.withValues(alpha: 0.92),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Seviye $levelId',
              style: const TextStyle(
                color: kMuted,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'TAMAMLANDI!',
              style: TextStyle(
                color: kColorChef,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.6, 0.6),
                  end: const Offset(1.0, 1.0),
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 200.ms),
            const SizedBox(height: 16),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: score),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (_, val, __) => Text(
                '$val',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  shadows: [
                    Shadow(
                      color: kColorChef.withValues(alpha: 0.5),
                      blurRadius: 24,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: onNextLevel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kColorChef,
                  foregroundColor: kBgDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                  ),
                ),
                child: const Text(
                  'Sonraki Seviye',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 220,
              child: OutlinedButton(
                onPressed: onLevelList,
                style: OutlinedButton.styleFrom(
                  foregroundColor: kMuted,
                  side: BorderSide(color: kMuted.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                  ),
                ),
                child: const Text(
                  'Seviye Listesi',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onHome,
              child: const Text(
                'Ana Menu',
                style: TextStyle(
                  color: kMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Protokol 2: Squash & Stretch yerlestirme animasyonu ────────────────────

/// Hucre doldugunda 4 fazli squash & stretch animasyonu oynatir.
///
/// Fazlar (toplam 380ms):
/// 1. Anticipation (0-60ms): hafif buyume 1.0 → 1.08
/// 2. Impact/Squash (60-120ms): yatay genisleme 1.15, dikey sikisma 0.82
/// 3. Overshoot/Stretch (120-200ms): dikey uzama 1.06
/// 4. Settle (200-380ms): yumusak stabilizasyon → 1.0
class _SquashStretchCell extends StatefulWidget {
  const _SquashStretchCell({
    super.key,
    required this.isPlaced,
    required this.child,
  });

  final bool isPlaced;
  final Widget child;

  @override
  State<_SquashStretchCell> createState() => _SquashStretchCellState();
}

class _SquashStretchCellState extends State<_SquashStretchCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _prevPlaced = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    if (widget.isPlaced) {
      // İlk oluşturmada animasyon oynat (hücre yeni doldu)
      _ctrl.forward(from: 0);
      _prevPlaced = true;
    }
  }

  @override
  void didUpdateWidget(_SquashStretchCell old) {
    super.didUpdateWidget(old);
    // Sadece false → true gecisinde animasyon oynat
    if (widget.isPlaced && !_prevPlaced) {
      _ctrl.forward(from: 0);
    } else if (!widget.isPlaced && _prevPlaced) {
      // Hücre bosaldi — aninda sifirla, animasyon yok
      _ctrl.value = 0;
    }
    _prevPlaced = widget.isPlaced;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaced) return widget.child;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final p = _ctrl.value;
        // Animasyon bitti — transform gereksiz
        if (p >= 0.99) return widget.child;

        double scaleX, scaleY;

        if (p < 0.16) {
          // Faz 1: Anticipation — hafif buyume
          final t = Curves.easeOutQuad.transform(p / 0.16);
          scaleX = scaleY = 1.0 + 0.08 * t;
        } else if (p < 0.32) {
          // Faz 2: Impact — SQUASH (yatay genisler, dikey sikisir)
          final t = Curves.easeInQuad.transform((p - 0.16) / 0.16);
          scaleX = 1.08 + (1.15 - 1.08) * t; // 1.08 → 1.15
          scaleY = 1.08 + (0.82 - 1.08) * t; // 1.08 → 0.82
        } else if (p < 0.53) {
          // Faz 3: Overshoot — STRETCH (geri toplanma + dikey uzama)
          final t = Curves.easeOutQuad.transform((p - 0.32) / 0.21);
          scaleX = 1.15 + (1.0 - 1.15) * t;  // 1.15 → 1.0
          scaleY = 0.82 + (1.06 - 0.82) * t;  // 0.82 → 1.06
        } else {
          // Faz 4: Settle — yumusak stabilizasyon
          final t = Curves.easeInOutSine.transform((p - 0.53) / 0.47);
          scaleX = 1.0;
          scaleY = 1.06 + (1.0 - 1.06) * t; // 1.06 → 1.0
        }

        // GPU-composited transform — repaint gerektirmez
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(scaleX, scaleY, 1.0),
          child: widget.child,
        );
      },
    );
  }
}

// ─── Faz 4: Loss Aversion Reward Badge ────────────────────────────────────

class _RewardBadge extends StatelessWidget {
  const _RewardBadge({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(UIConstants.radiusLg),
          border: Border.all(color: color.withValues(alpha: 0.55), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.play_circle_outline, color: color, size: 14),
          ],
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.05, 1.05),
            duration: 800.ms,
          ),
    );
  }
}

// ─── Protokol 2: Dalga yayilimi (Wave Ripple) ──────────────────────────────

/// Yerlestirme noktasina yakin dolu hücrelere geciktirilmis bounce efekti.
/// [distance]: Manhattan mesafesi (1-3 arasi).
class _WaveRipple extends StatefulWidget {
  const _WaveRipple({
    super.key,
    required this.distance,
    required this.child,
  });

  final int distance;
  final Widget child;

  @override
  State<_WaveRipple> createState() => _WaveRippleState();
}

class _WaveRippleState extends State<_WaveRipple>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    // Mesafeye göre gecikme
    Future.delayed(Duration(milliseconds: widget.distance * 25), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        if (!_ctrl.isAnimating && _ctrl.value <= 0) return widget.child;
        if (_ctrl.isCompleted) return widget.child;

        // Genlik: mesafe arttikca azalir
        final magnitude = 0.03 / (1.0 + widget.distance * 0.6);
        final t = Curves.easeOutSine.transform(_ctrl.value);
        // Sinus dalgasi: 0 → magnitude → 0 (tek bounce)
        final bounce = magnitude * math.sin(t * math.pi);
        final scale = 1.0 + bounce;

        return Transform.scale(
          scale: scale,
          child: widget.child,
        );
      },
    );
  }
}
