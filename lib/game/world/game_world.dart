import 'dart:async';

import '../../core/constants/color_constants.dart';
import '../../core/constants/game_constants.dart';
import '../../core/utils/near_miss_detector.dart';
import '../economy/currency_manager.dart';
import '../levels/level_data.dart';
import '../shapes/gel_shape.dart';
import '../systems/color_chef_levels.dart';
import '../systems/color_synthesis.dart';
import '../systems/combo_detector.dart';
import '../systems/powerup_system.dart';
import '../systems/score_system.dart';
import 'grid_manager.dart';

enum GameMode {
  classic,
  colorChef,
  timeTrial,
  zen,
  daily,
  level,  // Faz 4: Seviye modu
  duel;   // Faz 4: PvP düello modu

  static GameMode fromString(String value) {
    return GameMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => GameMode.classic,
    );
  }
}

enum GameStatus { idle, playing, paused, gameOver, frozen }

class GlooGame {
  GlooGame({required this.mode, this.levelData});

  final GameMode mode;
  final LevelData? levelData;

  late final GridManager _gridManager;
  final ScoreSystem _scoreSystem = ScoreSystem();
  final ComboDetector _comboDetector = ComboDetector();
  final ColorSynthesisSystem _synthesisSystem = ColorSynthesisSystem();
  final NearMissDetector _nearMissDetector = NearMissDetector();

  /// Faz 4: Ekonomi sistemi.
  final CurrencyManager currencyManager = CurrencyManager();

  /// Faz 4: Power-up sistemi.
  late final PowerUpSystem powerUpSystem;

  GameStatus status = GameStatus.idle;
  Timer? _countdownTimer;
  int _remainingSeconds = GameConstants.timeTrialDuration;

  // Color Chef durumu
  int _chefLevelIndex = 0;
  int _chefProgress = 0;

  // Faz 4: Seviye modu durumu
  int _movesUsed = 0;
  int _handIndex = 0;

  // Faz 4: Smart RNG durumu
  int _totalGamesPlayed = 0;

  // Faz 4: Freeze durumu
  Timer? _freezeTimer;

  void Function(int points)? onScoreGained;
  void Function(LineClearResult result)? onLineClear;
  void Function(NearMissEvent event)? onNearMiss;
  void Function(ComboEvent combo)? onCombo;
  void Function()? onGameOver;
  void Function(int seconds)? onTimerTick;
  void Function(int progress, int required)? onChefProgress;
  void Function(int completedIndex, GelColor targetColor, bool allComplete)?
      onChefLevelComplete;

  // Faz 4: Yeni callback'ler
  void Function(int gelOzu)? onCurrencyEarned;
  void Function(PowerUpType type, PowerUpResult result)? onPowerUpUsed;
  void Function(int movesUsed)? onMoveCompleted;
  void Function()? onLevelComplete;
  void Function(List<(int, int)> crackedCells)? onIceCracked;
  void Function(List<(int, int, int, int)> moves)? onGravityApplied;
  void Function(int amount)? onJelEnergyEarned;
  void Function(GelColor resultColor, (int, int) position)? onColorSynthesis;

  int get score => _scoreSystem.score;
  int get highScore => _scoreSystem.highScore;
  bool get isNewHighScore => _scoreSystem.isNewHighScore;
  int get remainingSeconds => _remainingSeconds;
  int get chefProgress => _chefProgress;
  int get chefLevelIndex => _chefLevelIndex;
  int get movesUsed => _movesUsed;
  int get handIndex => _handIndex;
  ColorChefLevel? get currentChefLevel =>
      mode == GameMode.colorChef && _chefLevelIndex < kColorChefLevels.length
          ? kColorChefLevels[_chefLevelIndex]
          : null;
  GridManager get gridManager => _gridManager;

  void setInitialHighScore(int value) => _scoreSystem.setInitialHighScore(value);
  void setGamesPlayed(int value) => _totalGamesPlayed = value;
  void setCurrencyBalance(int value) => currencyManager.setBalance(value);

  void _initGridManager() {
    if (levelData != null) {
      _gridManager = GridManager(rows: levelData!.rows, cols: levelData!.cols);
      _gridManager.initFromSpecialCells(levelData!.allSpecialCells());
    } else {
      _gridManager = GridManager();
    }
  }

  void startGame() {
    _countdownTimer?.cancel();
    _freezeTimer?.cancel();
    status = GameStatus.playing;

    _initGridManager();
    _scoreSystem.reset();
    _comboDetector.reset();
    _movesUsed = 0;
    _handIndex = 0;
    currencyManager.resetGameStats();

    powerUpSystem = PowerUpSystem(currencyManager: currencyManager);
    powerUpSystem.onPowerUpUsed = onPowerUpUsed;

    _remainingSeconds = GameConstants.timeTrialDuration;
    if (mode == GameMode.colorChef) {
      _chefLevelIndex = 0;
      _chefProgress = 0;
    }
    if (mode == GameMode.timeTrial || mode == GameMode.duel) _startCountdown();
    if (mode == GameMode.duel) _remainingSeconds = 120; // 2 dakika
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (status == GameStatus.frozen) return; // Freeze aktifken sayma
      if (status != GameStatus.playing) return;
      _remainingSeconds--;
      onTimerTick?.call(_remainingSeconds);
      if (_remainingSeconds <= 0) {
        _countdownTimer?.cancel();
        status = GameStatus.gameOver;
        onGameOver?.call();
      }
    });
  }

  void pauseGame() {
    status = GameStatus.paused;
    _countdownTimer?.cancel();
    _freezeTimer?.cancel();
  }

  void resumeGame() {
    status = GameStatus.playing;
    if (mode == GameMode.timeTrial || mode == GameMode.duel) _startCountdown();
  }

  void cancelTimer() {
    _countdownTimer?.cancel();
    _freezeTimer?.cancel();
  }

  /// Eldeki şekillerin herhangi biri ızgaraya yerleştirilebiliyorsa oyun devam
  /// eder. Hiçbiri sığmıyorsa status → gameOver ve onGameOver callback'i tetiklenir.
  void checkGameOver(List<GelShape> handShapes) {
    if (status != GameStatus.playing) return;
    if (mode == GameMode.timeTrial) return;
    if (mode == GameMode.zen) return;
    if (mode == GameMode.duel) return;
    if (handShapes.isEmpty) return;

    // Seviye modu: hamle sınırı kontrolü
    if (mode == GameMode.level && levelData?.maxMoves != null) {
      if (_movesUsed >= levelData!.maxMoves!) {
        // Hedef skora ulaşıldıysa seviye tamamlandı
        if (_scoreSystem.score >= levelData!.targetScore) {
          onLevelComplete?.call();
          return;
        }
        status = GameStatus.gameOver;
        onGameOver?.call();
        return;
      }
    }

    for (final shape in handShapes) {
      final maxR = _gridManager.rows - shape.rowCount;
      final maxC = _gridManager.cols - shape.colCount;
      for (int r = 0; r <= maxR; r++) {
        for (int c = 0; c <= maxC; c++) {
          if (_gridManager.canPlace(shape.at(r, c))) return;
        }
      }
    }

    status = GameStatus.gameOver;
    ShapeGenerator.recordLoss();
    onGameOver?.call();
  }

  void placePiece(List<(int, int)> cells, GelColor color) {
    if (status != GameStatus.playing) return;
    if (!_gridManager.canPlace(cells, color)) return;

    _gridManager.place(cells, color);
    _movesUsed++;
    _handIndex++;

    // Power-up: Undo için yerleştirme kaydı
    powerUpSystem.recordPlacement(cells, color);
    powerUpSystem.onMoveCompleted();

    _evaluateBoard();
    onMoveCompleted?.call(_movesUsed);
  }

  /// Smart RNG ile yeni el oluştur.
  List<(GelShape, GelColor)> generateNextHand() {
    if (mode == GameMode.daily) {
      return ShapeGenerator.generateNextSeededHand(
        baseSeed: ShapeGenerator.todaySeed(),
        handIndex: _handIndex,
        moveCount: _movesUsed,
      );
    }

    if (mode == GameMode.duel) {
      // Düello: deterministik (seed bazlı)
      return ShapeGenerator.generateSeededHand(
          _handIndex * 31 + _movesUsed * 7);
    }

    // Smart RNG
    final difficulty = ShapeGenerator.getDifficulty(
      score: _scoreSystem.score,
      gamesPlayed: _totalGamesPlayed,
    );
    return ShapeGenerator.generateSmartHand(
      gridManager: _gridManager,
      difficulty: difficulty,
      gamesPlayed: _totalGamesPlayed,
    );
  }

  void _evaluateBoard() {
    final syntheses = _synthesisSystem.findSyntheses(_gridManager.grid);

    // Sentezleri ızgaraya uygula — çakışan hücreleri atla
    int appliedSynthesisCount = 0;
    int chefTargetCount = 0;
    final chefLevel = currentChefLevel;
    final modifiedCells = <(int, int)>{};

    for (final synthesis in syntheses) {
      if (synthesis.positions.any((p) => modifiedCells.contains(p))) continue;
      final first = synthesis.positions.first;
      _gridManager.setCell(first.$1, first.$2, synthesis.resultColor);
      for (int i = 1; i < synthesis.positions.length; i++) {
        final pos = synthesis.positions[i];
        _gridManager.setCell(pos.$1, pos.$2, null);
      }
      modifiedCells.addAll(synthesis.positions);
      appliedSynthesisCount++;
      onColorSynthesis?.call(synthesis.resultColor, first);

      if (chefLevel != null && synthesis.resultColor == chefLevel.targetColor) {
        chefTargetCount++;
      }
    }

    // Faz 4: Sentez → Jel Özü kazanımı
    if (appliedSynthesisCount > 0) {
      currencyManager.earnFromSynthesis(appliedSynthesisCount);
    }

    // Color Chef ilerleme ve seviye tamamlanma kontrolü
    if (chefLevel != null && chefTargetCount > 0) {
      _chefProgress += chefTargetCount;
      onChefProgress?.call(_chefProgress, chefLevel.requiredCount);

      if (_chefProgress >= chefLevel.requiredCount) {
        final completedIndex = _chefLevelIndex;
        _chefLevelIndex++;
        _chefProgress = 0;
        _gridManager.reset();
        onChefLevelComplete?.call(
          completedIndex,
          chefLevel.targetColor,
          _chefLevelIndex >= kColorChefLevels.length,
        );
        return;
      }
    }

    final clearResult = _gridManager.detectAndClear();

    if (clearResult.totalLines > 0) {
      onLineClear?.call(clearResult);
      final combo = _comboDetector.registerClear(clearResult.totalLines);
      final points = _scoreSystem.addLineClear(
        linesCleared: clearResult.totalLines,
        combo: combo,
        colorSynthesisCount: appliedSynthesisCount,
      );
      onScoreGained?.call(points);
      if (combo.tier != ComboTier.none) onCombo?.call(combo);

      // Faz 4: Satır temizleme → Jel Özü + Merhamet RNG güncelleme
      currencyManager.earnFromLineClear(clearResult.totalLines);
      ShapeGenerator.recordClear();

      // Faz 4: Jel Enerjisi kazanımı (meta-game kaynak)
      onJelEnergyEarned?.call(clearResult.totalLines);

      // Faz 4: Kombo bonus
      if (combo.tier != ComboTier.none) {
        currencyManager.earnFromCombo(combo.tier.name);
      }

      // Faz 4: Buz kırılma callback'i
      if (clearResult.crackedIceCells.isNotEmpty) {
        onIceCracked?.call(clearResult.crackedIceCells);
      }

      // Faz 4: Yerçekimi uygula
      final gravityMoves = _gridManager.applyGravity();
      if (gravityMoves.isNotEmpty) {
        onGravityApplied?.call(gravityMoves);
        // Yerçekimi sonrası tekrar temizleme kontrolü
        final secondClear = _gridManager.detectAndClear();
        if (secondClear.totalLines > 0) {
          onLineClear?.call(secondClear);
          final combo2 = _comboDetector.registerClear(secondClear.totalLines);
          final points2 = _scoreSystem.addLineClear(
            linesCleared: secondClear.totalLines,
            combo: combo2,
          );
          onScoreGained?.call(points2);
          if (combo2.tier != ComboTier.none) onCombo?.call(combo2);
          currencyManager.earnFromLineClear(secondClear.totalLines);
        }
      }

      // Time Trial: her temizlenen satır +2 saniye bonus
      if (mode == GameMode.timeTrial) {
        _remainingSeconds += clearResult.totalLines * GameConstants.timeTrialLineClearBonus;
        onTimerTick?.call(_remainingSeconds);
      }

      // Seviye modu: hedef skor kontrolü
      if (mode == GameMode.level && levelData != null) {
        if (_scoreSystem.score >= levelData!.targetScore) {
          onLevelComplete?.call();
          return;
        }
      }
    } else {
      // Satır temizlenmedi → Merhamet RNG güncelleme
      ShapeGenerator.recordMoveWithoutClear();
    }

    // Time Trial: near-miss gürültü yapar, atla
    if (mode == GameMode.timeTrial) return;
    if (mode == GameMode.duel) return;

    final nearMiss = _nearMissDetector.evaluate(
      filledCells: _gridManager.filledCells,
      totalCells: _gridManager.totalCells,
      lastComboSize: 0,
      availableMoves: 3,
      grid: _gridManager.grid,
    );
    if (nearMiss != null) onNearMiss?.call(nearMiss);
  }

  // ─── Faz 4: Power-up Entegrasyonu ──────────────────────────────────────────

  /// Rotate: Mevcut şekli döndür.
  GelShape? rotateShape(GelShape shape) {
    final result = powerUpSystem.useRotate(shape);
    return result?.rotatedShape;
  }

  /// Bomb: 3×3 alan temizle.
  Map<(int, int), GelColor>? useBomb(int centerRow, int centerCol) {
    final result = powerUpSystem.useBomb(_gridManager, centerRow, centerCol);
    if (result != null) {
      // Temizleme sonrası yerçekimi ve zincirleme kontrol
      _gridManager.applyGravity();
      final clearResult = _gridManager.detectAndClear();
      if (clearResult.totalLines > 0) {
        onLineClear?.call(clearResult);
        final combo = _comboDetector.registerClear(clearResult.totalLines);
        final points = _scoreSystem.addLineClear(
          linesCleared: clearResult.totalLines,
          combo: combo,
        );
        onScoreGained?.call(points);
      }
    }
    return result?.clearedCells;
  }

  /// Undo: Son yerleştirmeyi geri al.
  List<(int, int)>? useUndo() {
    final result = powerUpSystem.useUndo(_gridManager);
    if (result != null) {
      _movesUsed--;
    }
    return result?.restoredCells;
  }

  /// Freeze: Time Trial'da 10sn dondur.
  bool useFreeze() {
    final result = powerUpSystem.useFreeze();
    if (result == null) return false;
    status = GameStatus.frozen;
    _freezeTimer = Timer(Duration(seconds: result.frozenSeconds), () {
      if (status == GameStatus.frozen) {
        status = GameStatus.playing;
      }
    });
    return true;
  }

  /// Rainbow: Mevcut şekil joker renk olarak döner (UI rengi beyaz yapılır).
  bool useRainbow() {
    return powerUpSystem.useRainbow() != null;
  }

  // ─── Faz 4: Ikinci Sans — Rewarded Ad sonrasi devam ─────────────────────

  /// Game Over sonrasi ekstra hamle ekleyerek oyunu devam ettirir.
  /// Rewarded ad izlendikten sonra cagirilir.
  void continueWithExtraMoves(int moves) {
    if (status != GameStatus.gameOver) return;
    status = GameStatus.playing;
    // Seviye modunda hamle sinirini genislet
    if (mode == GameMode.level && levelData?.maxMoves != null) {
      // maxMoves readonly oldugundan, _movesUsed'i geri cekyoruz
      _movesUsed = (_movesUsed - moves).clamp(0, _movesUsed);
    }
    // TimeTrial/Duel: ekstra sure ekle
    if (mode == GameMode.timeTrial || mode == GameMode.duel) {
      _remainingSeconds += moves * 10; // Her hamle = 10sn
      _startCountdown();
      onTimerTick?.call(_remainingSeconds);
    }
  }
}
