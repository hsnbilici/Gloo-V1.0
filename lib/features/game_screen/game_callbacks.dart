part of 'game_screen.dart';

/// initState callback wiring'ini GameScreen'den ayiran mixin.
///
/// [_GameScreenState]'in tum callback atamalarini [setupCallbacks] ile yapar.
mixin _GameCallbacksMixin on ConsumerState<GameScreen> {
  GlooGame get game;
  ClipRecorder get clipRecorder;
  List<({int row, int col, Color color, int key, Duration delay})>
      get burstCells;
  int get burstKeyBase;
  set burstKeyBase(int value);
  ComboEvent? get activeCombo;
  set activeCombo(ComboEvent? value);
  int get comboKeyIndex;
  set comboKeyIndex(int value);
  double get shakeIntensity;
  set shakeIntensity(double value);
  int get shakeKey;
  set shakeKey(int value);
  NearMissEvent? get activeNearMiss;
  set activeNearMiss(NearMissEvent? value);
  int get nearMissKeyIndex;
  set nearMissKeyIndex(int value);
  bool get showNearMissRescueBadge;
  set showNearMissRescueBadge(bool value);
  bool get showHighScoreBadge;
  set showHighScoreBadge(bool value);
  int? get selectedSlot;
  set selectedSlot(int? value);
  Set<(int, int)> get previewCells;
  set previewCells(Set<(int, int)> value);
  bool get previewValid;
  set previewValid(bool value);
  (int, int)? get previewAnchor;
  set previewAnchor((int, int)? value);
  List<({int row, int col, Color color, int key})> get synthesisBlooms;
  int get synthesisKeyBase;
  set synthesisKeyBase(int value);
  GameDuelController? get duelController;
  set duelController(GameDuelController? value);
  void refillHand();
  void handleGameOverDialog();

  void setupCallbacks() {
    game.onScoreGained = (points) {
      ref.read(gameProvider(widget.mode).notifier).updateScore(game.score);
      if (!showHighScoreBadge &&
          game.highScore > 0 &&
          ref.read(adManagerProvider).canShowHighScoreContinue(
            currentScore: game.score,
            highScore: game.highScore,
          )) {
        setState(() => showHighScoreBadge = true);
      }
    };

    game.onLineClear = (clearResult) {
      if (!mounted) return;
      final gridCols = game.gridManager.cols;
      final gridRows = game.gridManager.rows;
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
          key: ++burstKeyBase,
          delay: Duration(milliseconds: (distFromCenter * 35).round()),
        ));
      }
      if (bursts.isNotEmpty) {
        setState(() {
          burstCells.addAll(bursts);
          if (burstCells.length > 200) {
            burstCells.removeRange(0, burstCells.length - 200);
          }
        });
      }

      // PvP: satir temizleyince rakibe engel gonder
      if (widget.mode == GameMode.duel && clearResult.totalLines > 0) {
        duelController?.sendObstacles(clearResult.totalLines, 'small');
      }
    };

    game.onCombo = (combo) {
      clipRecorder.onCombo(combo);
      if (mounted) {
        setState(() {
          activeCombo = combo;
          comboKeyIndex++;
          if (combo.tier == ComboTier.epic) {
            shakeIntensity = GameConstants.shakeAmplitudeEpic;
            shakeKey++;
          } else if (combo.tier == ComboTier.large) {
            shakeIntensity = GameConstants.shakeAmplitudeLarge;
            shakeKey++;
          }
        });

        if (widget.mode == GameMode.duel) {
          duelController?.sendObstacles(0, combo.tier.name);
        }
      }
    };

    game.onNearMiss = (event) {
      clipRecorder.onNearMiss(event);
      if (mounted) {
        setState(() {
          activeNearMiss = event;
          nearMissKeyIndex++;
          if (event.isCritical && ref.read(adManagerProvider).canShowNearMissRescue()) {
            showNearMissRescueBadge = true;
          }
        });
      }
    };

    game.onTimerTick = (seconds) {
      if (mounted) {
        ref
            .read(gameProvider(widget.mode).notifier)
            .updateRemainingSeconds(seconds);
      }
    };

    game.onChefProgress = (progress, required) {
      if (mounted) {
        ref
            .read(gameProvider(widget.mode).notifier)
            .updateChef(progress, required);
      }
    };

    game.onChefLevelComplete = (completedIndex, targetColor, allComplete) {
      if (!mounted) return;
      final nextLevel = game.currentChefLevel;
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
            refillHand();
            selectedSlot = null;
            previewCells = {};
            previewValid = false;
            previewAnchor = null;
            burstCells.clear();
          });
        },
      );
    };

    // Jel Ozu guncellemesi — setState yok, sadece provider + persist
    game.currencyManager.onBalanceChanged = (balance) {
      if (mounted) {
        ref.read(gameProvider(widget.mode).notifier).updateGelOzu(balance);
        ref.read(localRepositoryProvider.future).then((repo) {
          repo.saveGelOzu(balance);
        });
      }
    };

    // Hamle sayaci
    game.onMoveCompleted = (moves) {
      if (mounted) {
        ref.read(gameProvider(widget.mode).notifier).updateMovesUsed(moves);
      }
    };

    // Seviye tamamlama
    game.onLevelComplete = () {
      if (!mounted) return;
      final levelId = widget.levelData?.id ?? 0;
      final score = game.score;
      ref.read(localRepositoryProvider.future).then((repo) {
        repo.setLevelCompleted(levelId, score);
      });
      showLevelComplete(context: context, score: score, levelId: levelId);
    };

    // Jel Enerjisi kazanimi (meta-game kaynak)
    game.onJelEnergyEarned = (amount) {
      if (!mounted) return;
      ref.read(localRepositoryProvider.future).then((repo) {
        final current = repo.getGelEnergy();
        final updated = current + amount;
        repo.saveGelEnergy(updated);
        final totalEarned = repo.getTotalEarnedEnergy() + amount;
        repo.saveTotalEarnedEnergy(totalEarned);

        ref.read(remoteRepositoryProvider).saveMetaState(
          gelEnergy: updated,
          totalEarnedEnergy: totalEarned,
        );
      });
    };

    game.onColorSynthesis = (resultColor, position) {
      if (!mounted) return;
      setState(() {
        synthesisBlooms.add((
          row: position.$1,
          col: position.$2,
          color: resultColor.displayColor,
          key: ++synthesisKeyBase,
        ));
        if (synthesisBlooms.length > 20) {
          synthesisBlooms.removeRange(0, synthesisBlooms.length - 20);
        }
      });
    };

    game.onGameOver = () {
      if (!mounted) return;
      final score = game.score;
      ref.read(localRepositoryProvider.future).then((repo) {
        repo.saveScore(mode: widget.mode.name, value: score);
        repo.incrementGamesPlayed();
        repo.updateAverageScore(score);
        if (widget.mode == GameMode.daily) {
          repo.saveDailyResult(score);
          ref.read(remoteRepositoryProvider).submitDailyResult(score: score, completed: true);
        }
        if (widget.mode == GameMode.level && widget.levelData != null) {
          repo.saveLevelHighScore(widget.levelData!.id, score);
        }
      });
      ref.read(remoteRepositoryProvider).submitScore(mode: widget.mode.name, value: score);
      ref.read(analyticsServiceProvider).logGameOver(mode: widget.mode.name, score: score);

      // Duel: skor broadcast'ini durdur ve oyun bitis sinyali gonder
      if (widget.mode == GameMode.duel) {
        duelController?.scoreBroadcastTimer?.cancel();
        duelController?.botScoreTimer?.cancel();
        duelController?.handleGameOver(score, context);
        return;
      }

      handleGameOverDialog();
    };

    // PvP Duel: realtime baglantisi kur
    if (widget.mode == GameMode.duel) {
      duelController = GameDuelController(
        ref: ref,
        game: game,
        matchId: widget.duelMatchId,
        isBot: widget.duelIsBot,
        seed: widget.duelSeed ?? 0,
        onStateChanged: () {
          // Grid was mutated in-place by incoming PvP obstacles;
          // trigger rebuild so GridView reflects new cell states.
          if (mounted) setState(() {});
        },
      );
      duelController!.init();
    }
  }
}
