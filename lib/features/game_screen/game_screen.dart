import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/game_constants.dart';
import '../../core/layout/responsive.dart';
import '../../data/local/local_repository.dart';
import '../../core/utils/near_miss_detector.dart';
import '../../game/levels/level_data.dart';
import '../../game/shapes/gel_shape.dart';
import '../../game/systems/combo_detector.dart';
import '../../game/systems/powerup_system.dart';
import '../../game/world/game_world.dart';
import '../../providers/audio_provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/user_provider.dart';
import '../../audio/sound_bank.dart';
import '../../core/constants/ui_constants.dart';
import '../../viral/clip_recorder.dart';
import '../../viral/share_manager.dart';
import 'game_background.dart';
import 'share_prompt_dialog.dart';
import 'tutorial_overlay.dart';
import 'game_cell_widget.dart';
import 'game_dialogs.dart';
import 'game_duel_controller.dart';
import 'game_effects.dart';
import 'game_overlay.dart';
import 'hint_toast.dart';
import 'power_up_toolbar.dart';
import 'reward_badge.dart';
import 'shape_hand.dart';

part 'game_callbacks.dart';
part 'game_interactions.dart';
part 'game_grid_builder.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({
    super.key,
    required this.mode,
    this.levelData,
    this.duelMatchId,
    this.duelSeed,
    this.duelIsBot = false,
    this.duelOpponentElo,
  });

  final GameMode mode;
  final LevelData? levelData;

  /// PvP duello parametreleri (lobby'den gelir).
  final String? duelMatchId;
  final int? duelSeed;
  final bool duelIsBot;
  final int? duelOpponentElo;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with
        TickerProviderStateMixin,
        _GameCallbacksMixin,
        _GameInteractionsMixin,
        _GameGridBuilderMixin {
  @override
  late final GlooGame game;
  @override
  final ClipRecorder clipRecorder = ClipRecorder();
  @override
  final SoundBank soundBank = SoundBank();

  @override
  late List<(GelShape, GelColor)?> hand;
  bool _firstHandUsed = false;
  @override
  int? selectedSlot;
  @override
  Set<(int, int)> previewCells = {};
  @override
  bool previewValid = false;
  @override
  (int, int)? previewAnchor;

  String? _toastMsg;
  Timer? _toastTimer;

  @override
  ComboEvent? activeCombo;
  @override
  NearMissEvent? activeNearMiss;
  @override
  int comboKeyIndex = 0;
  @override
  int nearMissKeyIndex = 0;
  @override
  ({double cx, double cy, int count, Color color, int key})? placeFeedback;
  @override
  int feedbackKeyIndex = 0;
  @override
  List<({int row, int col, Color color, int key, Duration delay})> burstCells =
      [];
  @override
  int burstKeyBase = 0;
  @override
  final List<({int row, int col, Color color, int key})> synthesisBlooms = [];
  @override
  int synthesisKeyBase = 0;

  // ─── Ekran sarsıntısı ─────────────────────────────────────────────
  @override
  double shakeIntensity = 0;
  @override
  int shakeKey = 0;
  @override
  Timer? shakeTimer;

  // ─── Power-up durumu ───────────────────────────────────────────────
  @override
  PowerUpType? activePowerUpMode;
  @override
  ({PowerUpType type, int key})? activePowerUpEffect;
  @override
  int powerUpFxKey = 0;
  @override
  ({int row, int col, int key})? bombExplosion;
  @override
  int bombFxKey = 0;
  @override
  ({List<(int, int)> cells, int key})? undoEffect;
  @override
  int undoFxKey = 0;

  // ─── Animasyon & dalga ─────────────────────────────────────────────
  @override
  late final AnimationController breathCtrl;
  @override
  Set<(int, int)> recentlyPlacedCells = {};
  @override
  int waveKey = 0;
  @override
  Timer? waveClearTimer;

  // ─── Mod rengi ─────────────────────────────────────────────────────
  Color get _modeColor => kModeColors[widget.mode]!;

  // ─── Loss Aversion badge'leri ──────────────────────────────────────
  @override
  bool showNearMissRescueBadge = false;
  @override
  bool showHighScoreBadge = false;

  // ─── Konfeti efekti ────────────────────────────────────────────────
  @override
  bool showConfetti = false;
  @override
  int confettiKey = 0;
  bool _secondChanceUsed = false;

  // ─── Epic combo tracking (share prompt) ───────────────────────────
  int _epicComboCount = 0;
  @override
  int get epicComboCount => _epicComboCount;
  @override
  set epicComboCount(int value) => _epicComboCount = value;

  // ─── Tutorial state ──────────────────────────────────────────────
  @override
  bool tutorialActive = false;
  @override
  int tutorialStep = -1; // -1 = no tutorial, 0/1/2 = active steps

  // ─── PvP Duel controller ──────────────────────────────────────────
  @override
  GameDuelController? duelController;

  // ─── Yaşam döngüsü ────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    game = GlooGame(mode: widget.mode, levelData: widget.levelData);

    // Protokol 1: Jel nefes alma — 2.4sn periyot, surekli tekrar
    breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // Kalici verileri yukle
    ref.read(localRepositoryProvider.future).then((repo) async {
      final saved = await repo.getHighScore(widget.mode.name);
      game.setInitialHighScore(saved);
      game.setGamesPlayed(repo.getTotalGamesPlayed());
      game.setCurrencyBalance(await repo.getGelOzu());
      final lifetime = await repo.getLifetimeEarnings();
      game.currencyManager.setLifetimeEarnings(lifetime);
    });

    game.startGame();
    refillHand();
    ref.read(analyticsServiceProvider).logGameStart(mode: widget.mode.name);

    setupCallbacks();

    // Check if tutorial should be shown (first game only, classic mode)
    if (widget.mode == GameMode.classic) {
      ref.read(localRepositoryProvider.future).then((repo) {
        if (!repo.getTutorialDone() && mounted) {
          setState(() {
            tutorialStep = 0;
            tutorialActive = true;
          });
        }
      });
    }
  }

  @override
  void refillHand() {
    if (!_firstHandUsed && widget.mode == GameMode.daily) {
      _firstHandUsed = true;
      hand = List<(GelShape, GelColor)?>.from(
        ShapeGenerator.generateSeededHand(ShapeGenerator.todaySeed()),
      );
    } else {
      hand = List<(GelShape, GelColor)?>.from(
        game.generateNextHand(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bp = Breakpoint.fromWidth(screenWidth);

    final gameContent = SafeArea(
      child: Column(
        children: [
          GameOverlay(game: game, mode: widget.mode),
          const SizedBox(height: 8),
          Expanded(child: buildGrid()),
        ],
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kBgDark,
      body: Stack(
        children: [
          const GameBackground(),
          AmbientGelDroplets(
            count: 10,
            baseColor: _modeColor,
            speedFactor: widget.mode == GameMode.zen ? 0.5 : 1.0,
          ),
          bp == Breakpoint.phone
              ? gameContent
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: gameContent,
                  ),
                ),
          if (activeNearMiss != null)
            Positioned.fill(
              child: NearMissEffect(
                key: ValueKey(nearMissKeyIndex),
                event: activeNearMiss!,
                onDismiss: () => setState(() => activeNearMiss = null),
              ),
            ),
          if (activeCombo != null && activeCombo!.tier != ComboTier.none)
            Positioned.fill(
              child: ComboEffect(
                key: ValueKey(comboKeyIndex),
                combo: activeCombo!,
                onDismiss: () => setState(() => activeCombo = null),
              ),
            ),
          if (activePowerUpEffect != null)
            Positioned.fill(
              child: PowerUpActivateEffect(
                key: ValueKey(activePowerUpEffect!.key),
                color: kPowerUpColors[activePowerUpEffect!.type]!.$1,
                onDismiss: () => setState(() => activePowerUpEffect = null),
              ),
            ),
          if (tutorialActive && tutorialStep >= 0) ...[
            // Semi-transparent overlay
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
            ),
            Builder(builder: (context) {
              final l = ref.read(stringsProvider);
              final messages = [
                l.tutorialStep1,
                l.tutorialStep2,
                l.tutorialStep3,
              ];
              return TutorialOverlay(
                step: tutorialStep,
                message: messages[tutorialStep],
                pointDown: tutorialStep == 0,
                dismissLabel: tutorialStep == 2 ? l.tutorialGotIt : null,
                onDismiss: () {
                  setState(() {
                    tutorialActive = false;
                    tutorialStep = -1;
                  });
                  ref
                      .read(localRepositoryProvider.future)
                      .then((repo) => repo.setTutorialDone());
                },
              );
            }),
          ],
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
          if (showNearMissRescueBadge)
            Positioned(
              top: topPadding + 52,
              right: 16,
              child: RewardBadge(
                label: ref.read(stringsProvider).toastRescueBadge,
                icon: Icons.shield_rounded,
                color: kOrangeVivid,
                onTap: () {
                  ref.read(adManagerProvider).showNearMissRescue(
                    onRewarded: () {
                      game.powerUpSystem.grantFreePowerUp(PowerUpType.bomb);
                      setState(() => showNearMissRescueBadge = false);
                      showToast(ref.read(stringsProvider).toastBombEarned);
                    },
                  );
                },
              ),
            ),
          if (showHighScoreBadge)
            Positioned(
              top: topPadding + 52,
              left: 16,
              child: RewardBadge(
                label: ref.read(stringsProvider).toastHighScoreBadge,
                icon: Icons.star_rounded,
                color: kGold,
                onTap: () {
                  ref.read(adManagerProvider).showHighScoreContinue(
                    onRewarded: () {
                      game.continueWithExtraMoves(5);
                      setState(() => showHighScoreBadge = false);
                      showToast(ref.read(stringsProvider).toastExtraMoves);
                    },
                  );
                },
              ),
            ),
          if (showConfetti)
            Positioned.fill(
              child: ConfettiEffect(
                key: ValueKey(confettiKey),
                onDismiss: () => setState(() => showConfetti = false),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Yardımcılar ──────────────────────────────────────────────────

  @override
  void showToast(String msg) {
    _toastTimer?.cancel();
    setState(() => _toastMsg = msg);
    _toastTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _toastMsg = null);
    });
  }

  @override
  void handleGameOverDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final adManager = ref.read(adManagerProvider);
      final repo = await ref.read(localRepositoryProvider.future);
      final avgScore = repo.getAverageScore();
      final canSecondChance = !_secondChanceUsed &&
          adManager.canShowSecondChance(
            currentScore: game.score,
            averageScore: avgScore,
          );

      if (!mounted) return;
      final l = ref.read(stringsProvider);
      showGameOver(
        context: context,
        score: game.score,
        mode: widget.mode,
        filledCells: game.gridManager.filledCells,
        totalCells: game.gridManager.totalCells,
        isNewHighScore: game.isNewHighScore,
        showSecondChance: canSecondChance,
        secondChanceLabel: l.secondChanceMoves,
        onSecondChance: canSecondChance
            ? () {
                adManager.showSecondChance(
                  onRewarded: () {
                    setState(() {
                      _secondChanceUsed = true;
                      game.continueWithExtraMoves(3);
                      showNearMissRescueBadge = false;
                      showHighScoreBadge = false;
                    });
                    ref
                        .read(gameProvider(widget.mode).notifier)
                        .updateScore(game.score);
                  },
                );
              }
            : null,
        onReplay: () {
          setState(() {
            game.startGame();
            refillHand();
            selectedSlot = null;
            previewCells = {};
            previewValid = false;
            activePowerUpMode = null;
            _secondChanceUsed = false;
            _epicComboCount = 0;
            confettiKey = 0;
            showConfetti = false;
            showNearMissRescueBadge = false;
            showHighScoreBadge = false;
          });
          ref.read(gameProvider(widget.mode).notifier).reset();
        },
        onHome: () => context.go('/'),
      );
    });
  }

  @override
  void dispose() {
    waveClearTimer?.cancel();
    shakeTimer?.cancel();
    _toastTimer?.cancel();
    game.cancelTimer();
    game.onLineClear = null;
    game.onCombo = null;
    game.onNearMiss = null;
    game.onGameOver = null;
    game.onTimerTick = null;
    game.onChefProgress = null;
    game.onChefLevelComplete = null;
    game.onMoveCompleted = null;
    game.onLevelComplete = null;
    game.onIceCracked = null;
    game.onGravityApplied = null;
    game.onColorSynthesis = null;
    game.currencyManager.onBalanceChanged = null;
    duelController?.dispose();
    breathCtrl.dispose();
    clipRecorder.dispose();
    super.dispose();
  }
}
