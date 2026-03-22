import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:share_plus/share_plus.dart';

import '../../core/constants/color_constants.dart';
import '../../core/utils/motion_utils.dart';
import '../../data/local/local_repository.dart';
import '../../providers/audio_provider.dart';
import '../../providers/user_provider.dart';
import '../shared/glow_orb.dart';
import '../../core/models/game_mode.dart';
import '../../providers/locale_provider.dart';
import 'game_over_buttons.dart';
import 'game_over_widgets.dart';

// ─── Tam ekran Game Over overlay ─────────────────────────────────────────────

class GameOverOverlay extends ConsumerStatefulWidget {
  const GameOverOverlay({
    super.key,
    required this.score,
    required this.mode,
    required this.filledCells,
    required this.totalCells,
    required this.isNewHighScore,
    required this.onReplay,
    required this.onHome,
    this.showSecondChance = false,
    this.onSecondChance,
    this.secondChanceLabel,
    this.linesCleared = 0,
    this.synthesisCount = 0,
    this.maxCombo = 0,
    this.onWatchAdBomb,
  });

  final int score;
  final GameMode mode;
  final int filledCells;
  final int totalCells;
  final bool isNewHighScore;
  final VoidCallback onReplay;
  final VoidCallback onHome;
  final bool showSecondChance;
  final VoidCallback? onSecondChance;
  final String? secondChanceLabel;
  final int linesCleared;
  final int synthesisCount;
  final int maxCombo;
  final VoidCallback? onWatchAdBomb;

  @override
  ConsumerState<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends ConsumerState<GameOverOverlay> {
  bool _promptDismissed = false;
  bool _promptShownMarked = false;
  String? _selectedTipKey;

  // Stat records (loaded once, before saving new values)
  int _prevLinesRecord = 0;
  int _prevSynthRecord = 0;
  int _prevComboRecord = 0;
  bool _recordsLoaded = false;

  void _loadAndSaveRecords(LocalRepository repo) {
    if (_recordsLoaded) return;
    _recordsLoaded = true;
    _prevLinesRecord = repo.getStatRecord('lines_cleared');
    _prevSynthRecord = repo.getStatRecord('synthesis_count');
    _prevComboRecord = repo.getStatRecord('max_combo');
    repo.updateStatRecord('lines_cleared', widget.linesCleared);
    repo.updateStatRecord('synthesis_count', widget.synthesisCount);
    repo.updateStatRecord('max_combo', widget.maxCombo);
  }

  void _markPromptShown() {
    if (_promptShownMarked) return;
    _promptShownMarked = true;
    ref.read(localRepositoryProvider.future).then((repo) {
      repo.setColorblindPromptShown();
    });
  }

  /// Selects which tip to show and increments its counter. Returns the tip
  /// key ('synthesis' or 'combo'), or null if both tips have been shown 2+
  /// times and the player doesn't need either.
  String? _selectTipKey(LocalRepository repo) {
    final synthCount = repo.getTipShownCount('synthesis');
    final comboCount = repo.getTipShownCount('combo');

    // Primary: show what the player needs (max 2 times per tip)
    if (widget.synthesisCount == 0 && synthCount < 2) {
      repo.incrementTipShown('synthesis');
      return 'synthesis';
    }
    if (widget.maxCombo == 0 && comboCount < 2) {
      repo.incrementTipShown('combo');
      return 'combo';
    }

    // If the player needs neither tip, don't show anything
    if (widget.synthesisCount > 0 && widget.maxCombo > 0) return null;

    // Total cap: stop showing tips after 6 total displays
    if (synthCount + comboCount >= 6) return null;

    // Rotation: show the less-seen tip
    if (synthCount <= comboCount) {
      repo.incrementTipShown('synthesis');
      return 'synthesis';
    }
    repo.incrementTipShown('combo');
    return 'combo';
  }

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(stringsProvider);
    final rm = shouldReduceMotion(context);
    final color = kModeColors[widget.mode]!;

    final modeLabel = switch (widget.mode) {
      GameMode.classic => l.gameOverModeClassic,
      GameMode.colorChef => l.gameOverModeColorChef,
      GameMode.timeTrial => l.gameOverModeTimeTrial,
      GameMode.zen => l.gameOverModeZen,
      GameMode.daily => l.gameOverModeDaily,
      GameMode.level => l.levelLabel,
      GameMode.duel => l.duelLabel,
    };

    final fillPct = widget.totalCells > 0
        ? (widget.filledCells / widget.totalCells * 100).round()
        : 0;

    // Colorblind prompt: show if not already shown and colorblind mode is off
    final repo = ref.watch(localRepositoryProvider).valueOrNull;

    // Load previous records before saving new ones
    if (repo != null) _loadAndSaveRecords(repo);

    final isNewLines =
        widget.linesCleared > _prevLinesRecord && widget.linesCleared > 0;
    final isNewSynth =
        widget.synthesisCount > _prevSynthRecord && widget.synthesisCount > 0;
    final isNewCombo =
        widget.maxCombo > _prevComboRecord && widget.maxCombo > 0;

    final gamesPlayed = repo?.getTotalGamesPlayed() ?? 0;
    final showColorblindPrompt = !_promptDismissed &&
        repo != null &&
        gamesPlayed >= 2 &&
        gamesPlayed <= 5 &&
        !repo.getColorblindPromptShown() &&
        !ref.watch(appSettingsProvider).colorBlindMode;
    if (showColorblindPrompt) {
      _markPromptShown();
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Arkaplan
          const ColoredBox(color: kBgDark, child: SizedBox.expand()),
          // Mod rengiyle üst ışıma
          Positioned(
            top: -140,
            left: -100,
            child: GlowOrb(size: 420, color: color, opacity: 0.10),
          ),
          // Alt karşıt ışıma
          Positioned(
            bottom: -100,
            right: -80,
            child: GlowOrb(size: 300, color: color, opacity: 0.06),
          ),
          // İçerik
          SafeArea(
            child: Column(
              children: [
                // ── Üst boşluk
                const SizedBox(height: 8),
                // ── Mod rozeti
                GameOverModeBadge(label: modeLabel, color: color)
                    .animateOrSkip(reduceMotion: rm, delay: 80.ms)
                    .fadeIn(duration: 280.ms)
                    .scale(
                      begin: const Offset(0.75, 0.75),
                      duration: 280.ms,
                      curve: Curves.easeOutBack,
                    ),
                // ── Merkez içerik
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Başlık
                          Text(
                            l.gameOverTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 6,
                              shadows: [
                                Shadow(
                                  color: color.withValues(alpha: 0.55),
                                  blurRadius: 22,
                                ),
                              ],
                            ),
                          )
                              .animateOrSkip(reduceMotion: rm, delay: 140.ms)
                              .fadeIn(duration: 300.ms)
                              .slideY(
                                begin: -0.12,
                                end: 0,
                                duration: 300.ms,
                                curve: Curves.easeOutCubic,
                              ),
                          const SizedBox(height: 14),
                          // Parıldayan ayraç
                          GlowDivider(color: color)
                              .animateOrSkip(reduceMotion: rm, delay: 240.ms)
                              .scaleX(
                                begin: 0,
                                end: 1,
                                duration: 380.ms,
                                curve: Curves.easeOutCubic,
                              ),
                          const SizedBox(height: 48),
                          // Skor sayacı
                          ScoreCountUp(score: widget.score, color: color),
                          const SizedBox(height: 6),
                          Text(
                            l.gameOverScoreLabel,
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 4,
                            ),
                          )
                              .animateOrSkip(reduceMotion: rm, delay: 360.ms)
                              .fadeIn(duration: 280.ms),
                          if (widget.isNewHighScore) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                NewRecordBadge(
                                    label: l.gameOverNewRecord, color: color),
                                const SizedBox(width: 10),
                                Semantics(
                                  label: l.gameOverShareScore,
                                  button: true,
                                  child: GestureDetector(
                                    onTap: () {
                                      Share.share(
                                        l.shareScoreCaption(
                                          modeLabel,
                                          '${widget.score}',
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: color.withValues(alpha: 0.30),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.share_rounded,
                                        color: color,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                                .animateOrSkip(reduceMotion: rm, delay: 420.ms)
                                .fadeIn(duration: 300.ms)
                                .scale(
                                  begin: const Offset(0.7, 0.7),
                                  duration: 300.ms,
                                  curve: Curves.easeOutBack,
                                ),
                          ],
                          const SizedBox(height: 40),
                          // İstatistikler
                          GameOverStatRow(
                            label: l.gameOverGridFill,
                            value: fillPct < 20
                                ? l.gridFillClean
                                : fillPct < 55
                                    ? l.gridFillGood
                                    : fillPct < 80
                                        ? l.gridFillCrowded
                                        : l.gridFillFull,
                            color: color,
                          )
                              .animateOrSkip(reduceMotion: rm, delay: 460.ms)
                              .fadeIn(duration: 280.ms)
                              .slideX(
                                begin: 0.12,
                                end: 0,
                                duration: 280.ms,
                                curve: Curves.easeOutCubic,
                              ),
                          const SizedBox(height: 6),
                          GameOverStatRow(
                            label: l.gameOverLinesCleared,
                            value: '${widget.linesCleared}',
                            color: color,
                            isNewRecord: isNewLines,
                            subtitle: _recordsLoaded &&
                                    widget.linesCleared > 0 &&
                                    isNewLines
                                ? l.gameOverNewStatRecord
                                : null,
                          )
                              .animateOrSkip(reduceMotion: rm, delay: 500.ms)
                              .fadeIn(duration: 280.ms)
                              .slideX(
                                begin: 0.12,
                                end: 0,
                                duration: 280.ms,
                                curve: Curves.easeOutCubic,
                              ),
                          const SizedBox(height: 6),
                          GameOverStatRow(
                            label: l.gameOverSyntheses,
                            value: '${widget.synthesisCount}',
                            color: color,
                            isNewRecord: isNewSynth,
                            subtitle: _recordsLoaded &&
                                    widget.synthesisCount > 0 &&
                                    isNewSynth
                                ? l.gameOverNewStatRecord
                                : null,
                          )
                              .animateOrSkip(reduceMotion: rm, delay: 540.ms)
                              .fadeIn(duration: 280.ms)
                              .slideX(
                                begin: 0.12,
                                end: 0,
                                duration: 280.ms,
                                curve: Curves.easeOutCubic,
                              ),
                          const SizedBox(height: 6),
                          GameOverStatRow(
                            label: l.gameOverMaxCombo,
                            value: '${widget.maxCombo}x',
                            color: color,
                            isNewRecord: isNewCombo,
                            subtitle: _recordsLoaded &&
                                    widget.maxCombo > 0 &&
                                    isNewCombo
                                ? l.gameOverNewStatRecord
                                : null,
                          )
                              .animateOrSkip(reduceMotion: rm, delay: 580.ms)
                              .fadeIn(duration: 280.ms)
                              .slideX(
                                begin: 0.12,
                                end: 0,
                                duration: 280.ms,
                                curve: Curves.easeOutCubic,
                              ),
                          // İpucu
                          if (repo != null)
                            ...() {
                              _selectedTipKey ??= _selectTipKey(repo);
                              if (_selectedTipKey == null) return <Widget>[];
                              final tipText = _selectedTipKey == 'synthesis'
                                  ? l.gameOverTipSynthesis
                                  : l.gameOverTipCombo;
                              return <Widget>[
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: 260,
                                  child: Text(
                                    tipText,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: kMuted.withValues(alpha: 0.7),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.italic,
                                      height: 1.4,
                                    ),
                                  ),
                                )
                                    .animateOrSkip(
                                        reduceMotion: rm, delay: 650.ms)
                                    .fadeIn(duration: 300.ms),
                              ];
                            }(),
                          // Colorblind inline prompt
                          if (showColorblindPrompt) ...[
                            const SizedBox(height: 14),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.visibility_outlined,
                                  size: 14,
                                  color: kMuted.withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    l.colorblindPromptText,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: kMuted.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref
                                        .read(appSettingsProvider.notifier)
                                        .setColorBlindMode(enabled: true);
                                    setState(() => _promptDismissed = true);
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.padded,
                                  ),
                                  child: Text(
                                    l.colorblindPromptAction,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                              ],
                            )
                                .animateOrSkip(reduceMotion: rm, delay: 700.ms)
                                .fadeIn(duration: 300.ms),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                // ── Butonlar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ikinci Sans butonu — Rewarded Ad
                      if (widget.showSecondChance &&
                          widget.onSecondChance != null)
                        SecondChanceButton(
                          color: color,
                          onTap: widget.onSecondChance!,
                          watchAdLabel: l.watchAdLabel,
                          secondChanceLabel:
                              widget.secondChanceLabel ?? l.secondChanceMoves,
                        )
                            .animateOrSkip(reduceMotion: rm, delay: 500.ms)
                            .fadeIn(duration: 320.ms)
                            .slideY(
                              begin: 0.18,
                              end: 0,
                              duration: 320.ms,
                              curve: Curves.easeOutCubic,
                            ),
                      if (widget.showSecondChance &&
                          widget.onSecondChance != null)
                        const SizedBox(height: 12),
                      if (widget.onWatchAdBomb != null)
                        ActionButton(
                          label: l.gameOverWatchAdBomb,
                          icon: Icons.local_fire_department_rounded,
                          accentColor: kOrange,
                          filled: false,
                          onTap: widget.onWatchAdBomb!,
                        )
                            .animateOrSkip(reduceMotion: rm, delay: 520.ms)
                            .fadeIn(duration: 320.ms)
                            .slideY(
                              begin: 0.18,
                              end: 0,
                              duration: 320.ms,
                              curve: Curves.easeOutCubic,
                            ),
                      if (widget.onWatchAdBomb != null)
                        const SizedBox(height: 12),
                      ActionButton(
                        label: l.gameOverReplay,
                        icon: Icons.replay_rounded,
                        accentColor: color,
                        filled: true,
                        onTap: widget.onReplay,
                      )
                          .animateOrSkip(reduceMotion: rm, delay: 540.ms)
                          .fadeIn(duration: 320.ms)
                          .slideY(
                            begin: 0.18,
                            end: 0,
                            duration: 320.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: 12),
                      ActionButton(
                        label: l.gameOverHome,
                        icon: Icons.home_rounded,
                        accentColor: kMuted,
                        filled: false,
                        onTap: widget.onHome,
                      )
                          .animateOrSkip(reduceMotion: rm, delay: 610.ms)
                          .fadeIn(duration: 320.ms)
                          .slideY(
                            begin: 0.18,
                            end: 0,
                            duration: 320.ms,
                            curve: Curves.easeOutCubic,
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
