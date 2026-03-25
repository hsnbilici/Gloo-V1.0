part of 'game_screen.dart';

/// initState callback wiring'ini GameScreen'den ayiran mixin.
///
/// [_GameScreenState]'in tum callback atamalarini [setupCallbacks] ile yapar.
mixin _GameCallbacksMixin on ConsumerState<GameScreen> {
  GlooGame get game;
  ClipRecorder get clipRecorder;
  SoundBank get soundBank;
  List<({int row, int col, Color color, int key, Duration delay, double intensity})>
      get burstCells;
  int get burstKeyBase;
  set burstKeyBase(int value);
  List<({int row, int key})> get sweepRows;
  int get sweepKeyBase;
  set sweepKeyBase(int value);
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
  bool get showConfetti;
  set showConfetti(bool value);
  int get confettiKey;
  set confettiKey(int value);
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
  Set<(int, int)> get synthesisGlowCells;
  Timer? get synthesisGlowTimer;
  set synthesisGlowTimer(Timer? value);
  GameDuelController? get duelController;
  set duelController(GameDuelController? value);
  int get epicComboCount;
  set epicComboCount(int value);
  void refillHand();
  void handleGameOverDialog();
  void showToast(String msg, {String? a11yAnnouncement});
  void syncGridState();

  /// initState'te resolve edilen LocalRepository cache'i.
  /// Callback'lerde tekrarlanan `localRepositoryProvider.future.then()` yerine kullanilir.
  LocalRepository? _cachedRepo;

  /// Adaptif zorluk beceri profili — game_screen.dart'tan set edilir.
  SkillProfile? skillProfileForCallbacks;

  /// GelOzu ses debounce — onBalanceChanged her deger degisiminde tetiklenir,
  /// tek hamlede 2-3 kez ust uste calmayi onler.
  Timer? _gelOzuSfxDebounce;

  /// Duel/TimeTrial'da son saniye müzik tempo artışı uygulandı mı
  bool _timerSpedUp = false;

  /// Kombo müzik volume swell — iptal edilebilir Timer
  Timer? _comboSwellTimer;

  /// Gravity/Ice ses debounce — aynı 50ms içinde tekrar tetiklemeyi önler
  DateTime _lastIceSfx = DateTime(0);
  DateTime _lastGravitySfx = DateTime(0);
  static const _sfxDebounce = Duration(milliseconds: 50);

  /// Track quest progress and grant reward if a quest was just completed.
  void _trackQuest(QuestType type, {int amount = 1}) {
    final repo = _cachedRepo;
    if (repo == null) return;
    final questState = ref.read(questProvider).valueOrNull;
    if (questState == null) return;
    incrementQuestProgress(repo, questState, type, amount: amount).then(
      (reward) {
        if (reward > 0) {
          game.currencyManager.earnFromLineClear(reward);
          soundBank.onGelOzuEarn();
        }
        // Refresh quest provider
        ref.invalidate(questProvider);
      },
    );
  }

  /// Submit challenge score and show reveal overlay on success.
  /// On failure, persist to SharedPreferences for retry on next launch.
  void _submitChallengeScore(String challengeId, int score) {
    final challengeRepo = ref.read(challengeRepositoryProvider);
    challengeRepo
        .submitRecipientScore(challengeId: challengeId, score: score)
        .then((result) {
      if (!mounted) return;
      if (result != null) {
        // Show the reveal overlay after a short delay for game over to settle
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          ChallengeRevealOverlay.show(
            context,
            result: result,
            opponentUsername: '', // sender username not available here
            l: ref.read(stringsProvider),
            onRematch: () {
              Navigator.of(context).pop();
              context.go('/friends');
            },
            onClose: () => Navigator.of(context).pop(),
          );
        });
      } else {
        // Network failure — persist for retry on next launch
        _persistPendingChallengeScore(challengeId, score);
      }
    }).catchError((Object e) {
      _persistPendingChallengeScore(challengeId, score);
      if (kDebugMode) {
        debugPrint('GameCallbacks: challenge score submit error: $e');
      }
    });
  }

  void _persistPendingChallengeScore(String challengeId, int score) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('pending_challenge_score_$challengeId', '$score');
      if (kDebugMode) {
        debugPrint(
          'GameCallbacks: challenge score saved for retry: $challengeId',
        );
      }
    });
  }

  void setupCallbacks() {
    // Repo'yu bir kez resolve et — callback'lerde tekrar future.then() gerekmez
    ref.read(localRepositoryProvider.future).then((repo) {
      _cachedRepo = repo;
    });

    game.onScoreGained = (points) {
      ref.read(gameProvider(widget.mode).notifier).updateScore(game.score);
      if (!showHighScoreBadge &&
          game.highScore > 0 &&
          ref.read(adManagerProvider).canShowHighScoreContinue(
                currentScore: game.score,
                highScore: game.highScore,
              )) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => showHighScoreBadge = true);
        });
      }
      if (game.isNewHighScore && !showConfetti && confettiKey == 0) {
        setState(() {
          showConfetti = true;
          confettiKey++;
        });
      }
    };

    game.onLineClear = (clearResult) {
      if (!mounted) return;
      final gridCols = game.gridManager.cols;
      final gridRows = game.gridManager.rows;
      // Çoklu satır temizlemede daha yoğun parçacık efekti
      final lines = clearResult.totalLines;
      final double burstIntensity =
          lines >= 4 ? 2.0 : (lines >= 2 ? 1.5 : 1.0);
      final bursts =
          <({int row, int col, Color color, int key, Duration delay, double intensity})>[];
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
          intensity: burstIntensity,
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

      // Çoklu satır sweep efekti: lines >= 2 ise temizlenen her satır için
      if (lines >= 2 && clearResult.clearedRows.isNotEmpty) {
        final rm = mounted ? MediaQuery.disableAnimationsOf(context) : false;
        if (!rm) {
          setState(() {
            for (final row in clearResult.clearedRows) {
              sweepRows.add((row: row, key: ++sweepKeyBase));
            }
            if (sweepRows.length > 40) {
              sweepRows.removeRange(0, sweepRows.length - 40);
            }
          });
        }
      }

      // PvP: satir temizleyince rakibe engel gonder
      if (widget.mode == GameMode.duel && clearResult.totalLines > 0) {
        soundBank.onPvpObstacleSent();
        duelController?.sendObstacles(clearResult.totalLines, 'small');
      }

      // Quest tracking: clear lines
      if (clearResult.totalLines > 0) {
        _trackQuest(QuestType.clearLines, amount: clearResult.totalLines);
      }
    };

    game.onCombo = (combo) {
      clipRecorder.onCombo(combo);
      // Ödül seviyesi: epic komboda 80ms sessizlik — dramatik etki
      if (combo.tier == ComboTier.epic) {
        Future.delayed(const Duration(milliseconds: 80), () {
          if (mounted) soundBank.onCombo(combo);
        });
      } else {
        soundBank.onCombo(combo);
      }
      // Quest tracking: combo (medium+ counts)
      if (combo.tier.index >= ComboTier.medium.index) {
        _trackQuest(QuestType.reachCombo);
      }
      // Müzik volume swell: epic/large komboda geçici artış (iptal edilebilir)
      if (combo.tier == ComboTier.epic || combo.tier == ComboTier.large) {
        _comboSwellTimer?.cancel();
        AudioManager().setMusicVolume(0.6);
        _comboSwellTimer = Timer(
          const Duration(milliseconds: 800),
          () => AudioManager().setMusicVolume(AudioConfig.musicVolume),
        );
      }

      // Epic yaklaşım motivasyon toast'ı — large tier + 6+ kombo, 3 kez sınırlı, Duel'de gösterme
      if (combo.tier == ComboTier.large && combo.size >= 6 && widget.mode != GameMode.duel) {
        final repo = _cachedRepo;
        if (repo != null) {
          final tipShown = repo.getTipShownCount('epic_approach');
          if (tipShown < 3) {
            repo.incrementTipShown('epic_approach');
            showToast(ref.read(stringsProvider).tipEpicApproach);
          }
        }
      }

      if (mounted) {
        // A11y: announce combo tier to screen readers (medium+ only)
        if (combo.tier.index >= ComboTier.medium.index) {
          final l = ref.read(stringsProvider);
          final comboLabel = switch (combo.tier) {
            ComboTier.medium => l.comboMedium,
            ComboTier.large => l.comboLarge,
            ComboTier.epic => l.comboEpic,
            _ => null,
          };
          if (comboLabel != null) {
            SemanticsService.sendAnnouncement(
              View.of(context),
              '$comboLabel x${combo.multiplier.toStringAsFixed(1)}',
              Directionality.of(context),
            );
          }
        }
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

        // Show share prompt on first epic combo per game session
        if (combo.tier == ComboTier.epic && epicComboCount == 0) {
          epicComboCount++;
          // Delay to let the combo effect play first (1500ms combo + 100ms buffer)
          Future.delayed(const Duration(milliseconds: 1600), () {
            if (!mounted) return;
            final l = ref.read(stringsProvider);
            showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierColor: Colors.black.withValues(alpha: 0.5),
              transitionBuilder: fadeScaleTransition,
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (_, __, ___) => SharePromptDialog(
                title: l.sharePromptTitle,
                message: l.sharePromptMessage,
                shareLabel: l.sharePromptShare,
                skipLabel: l.sharePromptSkip,
                onShare: () {
                  Navigator.pop(context);
                  ShareManager().shareComboResult(
                    score: game.score,
                    mode: widget.mode.name,
                    comboLabel: 'EPIC COMBO',
                    l: l,
                  );
                },
                onSkip: () => Navigator.pop(context),
              ),
            );
          });
        }
      }
    };

    game.onNearMiss = (event) {
      clipRecorder.onNearMiss(event);
      soundBank.onNearMiss(survived: !event.isCritical);
      if (mounted) {
        // A11y: announce near-miss to screen readers
        final l = ref.read(stringsProvider);
        final baseLabel =
            event.isCritical ? l.nearMissCritical : l.nearMissStandard;
        // survived mirrors the SFX logic: critical = did not survive
        final survivedSuffix =
            event.isCritical ? ' Game Over!' : ' Survived!';
        SemanticsService.sendAnnouncement(
          View.of(context),
          '$baseLabel$survivedSuffix',
          Directionality.of(context),
        );
        setState(() {
          activeNearMiss = event;
          nearMissKeyIndex++;
          if (event.isCritical &&
              ref.read(adManagerProvider).canShowNearMissRescue()) {
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

        // TimeTrial: son 15 saniyede tick SFX (haptik-siz, sabit pitch)
        if (widget.mode == GameMode.timeTrial && seconds <= 15 && seconds > 0) {
          AudioManager().playSfx(AudioPaths.buttonTap, pitchVariation: false);
        }

        // Duel/TimeTrial: son 30/15 saniyede müzik tempo artışı
        final threshold =
            widget.mode == GameMode.duel ? 30 : (widget.mode == GameMode.timeTrial ? 15 : 0);
        if (threshold > 0 && seconds <= threshold && !_timerSpedUp) {
          _timerSpedUp = true;
          AudioManager().setMusicSpeed(1.15);
        }
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
        _cachedRepo?.saveGelOzu(balance);
        _cachedRepo
            ?.saveLifetimeEarnings(game.currencyManager.lifetimeEarnings);
        // Debounce: tek hamlede birden fazla balance degisimi olabilir
        _gelOzuSfxDebounce?.cancel();
        _gelOzuSfxDebounce = Timer(
          const Duration(milliseconds: 300),
          () => soundBank.onGelOzuEarn(),
        );
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
      // Ödül seviyesi: 100ms sessizlik — dramatik etki
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) soundBank.onLevelComplete();
      });
      final levelId = widget.levelData?.id ?? 0;
      final score = game.score;
      _cachedRepo?.setLevelCompleted(levelId, score);
      final l = ref.read(stringsProvider);
      // A11y: announce level complete to screen readers
      SemanticsService.sendAnnouncement(
        View.of(context),
        '${l.levelCompleteAnnounce}. ${l.levelLabel} $levelId. ${l.gameOverScoreLabel}: $score',
        Directionality.of(context),
      );
      // Level completion reward: levelId * 2 Jel Özü
      final rewardAmount = min(levelId * 2, 30);
      if (rewardAmount > 0) {
        game.currencyManager.earnFromLineClear(rewardAmount);
      }

      showLevelComplete(
        context: context,
        score: score,
        levelId: levelId,
        targetScore: widget.levelData?.targetScore,
        nextLevelLabel: l.nextLevelLabel,
        levelListLabel: l.levelListLabel,
        mainMenuLabel: l.mainMenuLabel,
        levelLabel: l.levelLabel,
        completedLabel: l.completedLabel,
      );
    };

    // Jel Enerjisi kazanimi (meta-game kaynak)
    game.onJelEnergyEarned = (amount) async {
      if (!mounted) return;
      final repo = _cachedRepo;
      if (repo == null) return;
      final current = await repo.getGelEnergy();
      final updated = current + amount;
      repo.saveGelEnergy(updated);
      final totalEarned = repo.getTotalEarnedEnergy() + amount;
      repo.saveTotalEarnedEnergy(totalEarned);

      ref.read(remoteRepositoryProvider).saveMetaState(
            gelEnergy: updated,
            totalEarnedEnergy: totalEarned,
          );
    };

    game.onColorSynthesis = (resultColor, position) {
      soundBank.onSynthesis();
      // Quest tracking: synthesis
      _trackQuest(QuestType.makeSyntheses);
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
        // Sentez hücresine geçici glow efekti — 600ms sonra temizlenir
        // Batch clear: tüm sentez hücreleri son sentezden 600ms sonra birlikte temizlenir.
        // Per-cell timer yaklaşımı karmaşıklık ekler, mevcut UX yeterli.
        synthesisGlowCells.add(position);
        synthesisGlowTimer?.cancel();
        synthesisGlowTimer = Timer(const Duration(milliseconds: 600), () {
          if (mounted) {
            setState(() {
              synthesisGlowCells.clear();
              syncGridState();
            });
          }
        });
      });
      syncGridState();
      // Show synthesis hint toast for new players (first 3 times)
      final repo = _cachedRepo;
      if (repo != null) {
        final shown = repo.getTipShownCount('synthesis_hint');
        if (shown < 3) {
          repo.incrementTipShown('synthesis_hint');
          showToast(ref.read(stringsProvider).toastSynthesis);
        } else {
          // Sentez-temizleme trade-off ipucu: oyun 3-8 arasında, 2 kez göster
          final gamesPlayed = repo.getTotalGamesPlayed();
          final tradeoffShown = repo.getTipShownCount('synthesis_tradeoff');
          if (tradeoffShown < 2 && gamesPlayed >= 3 && gamesPlayed <= 8) {
            repo.incrementTipShown('synthesis_tradeoff');
            showToast(ref.read(stringsProvider).tipSynthesisTradeoff);
          }
        }
      }
    };

    game.onGelMerge = (mergeCount) {
      soundBank.onGelMerge(mergeCount: mergeCount);
    };

    game.onCascadeStep = (step, linesCleared) {
      final rm = mounted ? MediaQuery.disableAnimationsOf(context) : false;
      final delay = rm ? 0 : step * 180;
      final pitch = min(1.0 + (step - 1) * 0.08, 1.3);
      Future.delayed(Duration(milliseconds: delay), () {
        if (!mounted) return;
        soundBank.onLineClear(lines: linesCleared, pitch: pitch);
      });
    };

    game.onIceCracked = (_) {
      final now = DateTime.now();
      if (now.difference(_lastIceSfx) < _sfxDebounce) return;
      _lastIceSfx = now;
      soundBank.onIceBreak();
    };

    game.onGravityApplied = (_) {
      final now = DateTime.now();
      if (now.difference(_lastGravitySfx) < _sfxDebounce) return;
      _lastGravitySfx = now;
      soundBank.onGravityDrop();
    };

    game.onStoneBroken = (_) {
      soundBank.onStoneBroken();
    };

    game.onGameOver = () {
      if (!mounted) return;
      // Ödül seviyesi: 150ms sessizlik — dramatik etki
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) soundBank.onGameOver();
      });
      AudioManager().fadeOutMusic(const Duration(milliseconds: 800));
      // A11y: announce game over with final score to screen readers
      final goL = ref.read(stringsProvider);
      SemanticsService.sendAnnouncement(
        View.of(context),
        '${goL.gameOverTitle}. ${goL.gameOverScoreLabel}: ${game.score}',
        Directionality.of(context),
      );
      final score = game.score;
      // Quest tracking: play games + reach score
      _trackQuest(QuestType.playGames);
      if (score >= 500) {
        _trackQuest(QuestType.reachScore);
      }
      // Daily puzzle quest
      if (widget.mode == GameMode.daily) {
        _trackQuest(QuestType.completeDailyPuzzle);
      }
      final repo = _cachedRepo;
      if (repo != null) {
        repo.saveScore(mode: widget.mode.name, value: score);
        repo.saveLastScore(mode: widget.mode.name, value: score);
        repo.saveLastPlayedMode(widget.mode.name);
        repo.incrementGamesPlayed();
        repo.updateAverageScore(score);
        if (widget.mode == GameMode.daily) {
          repo.saveDailyResult(score);
          ref
              .read(remoteRepositoryProvider)
              .submitDailyResult(score: score, completed: true);
        }
        if (widget.mode == GameMode.level && widget.levelData != null) {
          repo.saveLevelHighScore(widget.levelData!.id, score);
        }
      }
      ref
          .read(remoteRepositoryProvider)
          .submitScore(mode: widget.mode.name, value: score);
      ref
          .read(analyticsServiceProvider)
          .logGameOver(mode: widget.mode.name, score: score);

      // Adaptif zorluk: beceri profili güncelle (tüm modlardan beslenir)
      if (skillProfileForCallbacks != null && repo != null) {
        final stats = game.buildGameStats();
        skillProfileForCallbacks = skillProfileForCallbacks!.addGame(stats);
        repo.saveSkillProfile(skillProfileForCallbacks!);
        // Remote sync skill profile for other players' profile view
        ref.read(friendRepositoryProvider).syncSkillProfile(
          skillProfileForCallbacks!.toMap(),
        );
      }

      // Season Pass XP: score / 100, Gloo+ subscribers get 2x
      var xp = max(10, score ~/ 100);
      if (game.currencyManager.isGlooPlus) xp *= 2;
      if (xp > 0 && repo != null) {
        final passState = SeasonPassState();
        passState.loadFromMap(repo.getSeasonPassState());
        passState.addXp(xp);
        repo.saveSeasonPassState(passState.toMap());
      }

      // Duel: skor broadcast'ini durdur ve oyun bitis sinyali gonder
      if (widget.mode == GameMode.duel) {
        duelController?.scoreBroadcastTimer?.cancel();
        duelController?.botScoreTimer?.cancel();
        duelController?.handleGameOver(score, context);
        return;
      }

      // Schedule comeback notification
      if (!kIsWeb) {
        try {
          final notif = ref.read(notificationServiceProvider);
          final l = ref.read(stringsProvider);
          notif.scheduleComebackNotification(title: l.notifComebackTitle, body: l.notifComebackBody);
        } catch (e) {
          if (kDebugMode) debugPrint('GameCallbacks: comeback notification error: $e');
        }
      }

      // Island: oyun sonu güncellemesi — pasif üretim tick
      if (!kIsWeb) {
        final islandRepo = _cachedRepo;
        if (islandRepo != null) {
          final island = IslandState()..loadFromMap(islandRepo.getIslandState());
          final produced = island.tickPassiveProduction();
          if (produced > 0) {
            islandRepo.getGelEnergy().then((current) {
              islandRepo.saveGelEnergy(current + produced);
            }).catchError((Object e) {
              if (kDebugMode) debugPrint('GameCallbacks: island update error: $e');
            });
          }
        }
      }

      // Challenge: skor gönder ve sonucu göster
      if (widget.challengeId != null) {
        _submitChallengeScore(widget.challengeId!, score);
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
        opponentElo: widget.duelOpponentElo,
        soundBank: soundBank,
        onStateChanged: () {
          // Grid was mutated in-place by incoming PvP obstacles;
          // trigger rebuild so GridView reflects new cell states.
          if (mounted) setState(() {});
        },
        onObstacleReceived: () {
          soundBank.onPvpObstacleReceived();
          if (mounted) {
            setState(() {
              shakeIntensity = GameConstants.shakeAmplitudeLarge;
              shakeKey++;
            });
          }
        },
      );
      duelController!.init();
    }
  }
}
