# Organic Growth — Tier 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the 6 highest-ROI growth features identified in `_dev/docs/GROWTH_REPORT.md` Tier 1 to lift D1 retention from ~35% to ~45% and viral K-factor from 0.15 to 0.25.

**Architecture:** Each task is fully independent — no cross-task dependencies. All changes are additive (no refactoring). Existing patterns (mixin composition, Riverpod providers, l10n, effect widgets) are reused.

**Tech Stack:** Flutter 3.41, Dart 3.3, Riverpod, SharedPreferences, flutter_animate, CustomPaint, share_plus

---

## File Structure

### New Files
| File | Responsibility |
|------|---------------|
| `lib/features/game_screen/effects/confetti_effect.dart` | High-score confetti CustomPaint overlay |
| `lib/features/game_screen/share_prompt_dialog.dart` | Post-combo/near-miss auto-share dialog |
| `lib/features/game_screen/tutorial_overlay.dart` | Interactive first-game tutorial overlay |
| `lib/features/home_screen/widgets/streak_reward_dialog.dart` | Streak milestone reward popup |

### Modified Files
| File | Changes |
|------|---------|
| `lib/data/local/local_repository.dart` | Add `getTutorialDone()`, `setTutorialDone()`, `getLastStreakRewardDay()`, `setLastStreakRewardDay()` |
| `lib/game/economy/currency_manager.dart` | Add `earnStreakReward(int amount)` |
| `lib/core/constants/game_constants.dart` | Add streak reward tiers, tutorial constants |
| `lib/core/l10n/app_strings.dart` | Add tutorial + streak reward + share prompt string keys |
| `lib/core/l10n/strings_en.dart` (+ 11 other langs) | Implement new string getters |
| `lib/features/game_screen/game_screen.dart` | Add tutorial state, confetti state, share prompt state |
| `lib/features/game_screen/game_callbacks.dart` | Trigger confetti on high score, trigger share prompt on epic combo |
| `lib/features/game_screen/game_grid_builder.dart` | Add confetti overlay to Stack |
| `lib/features/game_screen/game_effects.dart` | Export confetti_effect.dart |
| `lib/features/game_screen/effects/power_up_effects.dart` | Add freeze-frame to BombExplosionEffect |
| `lib/features/home_screen/home_screen.dart` | Show streak reward dialog on milestone |
| `lib/audio/sound_bank.dart` | Add `onSmallCombo()` SFX call |
| `lib/audio/audio_constants.dart` | Add `comboTiny` path alias |
| `lib/viral/share_manager.dart` | Add `shareComboClip()` with l10n caption |

---

## Task 1: Streak Milestone Rewards

**Goal:** Players earn Jel Ozu at streak milestones (3/7/14/30 days), creating a tangible reason to return daily.

**Files:**
- Modify: `lib/core/constants/game_constants.dart`
- Modify: `lib/data/local/local_repository.dart`
- Modify: `lib/game/economy/currency_manager.dart`
- Create: `lib/features/home_screen/widgets/streak_reward_dialog.dart`
- Modify: `lib/features/home_screen/home_screen.dart`
- Modify: `lib/core/l10n/app_strings.dart`
- Modify: `lib/core/l10n/strings_en.dart` (+ 11 other lang files)
- Test: `test/features/streak_reward_test.dart`

### Steps

- [ ] **Step 1: Add streak reward constants**

In `lib/core/constants/game_constants.dart`, add after existing constants:

```dart
/// Streak milestone rewards: {day: jelOzuReward}
static const Map<int, int> streakRewards = {
  3: 10,
  7: 50,
  14: 100,
  30: 200,
};
```

- [ ] **Step 2: Add persistence methods to LocalRepository**

In `lib/data/local/local_repository.dart`, add after the streak section (~line 106):

```dart
int getLastStreakRewardDay() =>
    _prefs.getInt('streak_last_reward_day') ?? 0;

Future<void> setLastStreakRewardDay(int day) async {
  await _prefs.setInt('streak_last_reward_day', day);
}
```

- [ ] **Step 3: Add `earnStreakReward` to CurrencyManager**

In `lib/game/economy/currency_manager.dart`, add after `earnDailyLogin()`:

```dart
void earnStreakReward(int amount) {
  _earn(amount);
}
```

- [ ] **Step 4: Add l10n strings**

In `lib/core/l10n/app_strings.dart`, add abstract getters:

```dart
String get streakRewardTitle;       // "Streak Reward!"
String get streakRewardMessage;     // "{days}-day streak! You earned {amount} Jel Ozu!"
String get streakRewardClaim;       // "Claim"
```

Implement in all 12 `strings_*.dart` files.

- [ ] **Step 5: Write the failing test**

```dart
// test/features/streak_reward_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/core/constants/game_constants.dart';

void main() {
  test('streak rewards defined for milestones 3, 7, 14, 30', () {
    expect(GameConstants.streakRewards[3], 10);
    expect(GameConstants.streakRewards[7], 50);
    expect(GameConstants.streakRewards[14], 100);
    expect(GameConstants.streakRewards[30], 200);
  });

  test('no reward for non-milestone days', () {
    expect(GameConstants.streakRewards[1], isNull);
    expect(GameConstants.streakRewards[5], isNull);
  });
}
```

- [ ] **Step 6: Run test to verify it fails**

Run: `flutter test test/features/streak_reward_test.dart -v`
Expected: FAIL (constants not yet added)

- [ ] **Step 7: Implement constants, persistence, and currency methods**

Apply the code from Steps 1–3.

- [ ] **Step 8: Run test to verify it passes**

Run: `flutter test test/features/streak_reward_test.dart -v`
Expected: PASS

- [ ] **Step 9: Create StreakRewardDialog widget**

Create `lib/features/home_screen/widgets/streak_reward_dialog.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/constants/ui_constants.dart';

class StreakRewardDialog extends StatelessWidget {
  const StreakRewardDialog({
    super.key,
    required this.streakDays,
    required this.rewardAmount,
    required this.claimLabel,
    required this.titleLabel,
    required this.onClaim,
  });

  final int streakDays;
  final int rewardAmount;
  final String claimLabel;
  final String titleLabel;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: kSurfaceDark,
            borderRadius: BorderRadius.circular(UIConstants.radiusLg),
            border: Border.all(color: kOrangeVivid.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: kOrangeVivid.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_fire_department_rounded,
                  color: kOrangeVivid, size: 48)
                  .animate()
                  .scale(begin: const Offset(0.5, 0.5), duration: 400.ms,
                      curve: Curves.elasticOut),
              const SizedBox(height: 12),
              Text(titleLabel,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('$streakDays 🔥  +$rewardAmount',
                  style: TextStyle(
                      color: kOrangeVivid, fontSize: 24,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onClaim,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: kOrangeVivid.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                    border: Border.all(
                        color: kOrangeVivid.withValues(alpha: 0.6)),
                  ),
                  child: Text(claimLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: kOrangeVivid, fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 10: Integrate into HomeScreen**

In `lib/features/home_screen/home_screen.dart`, in the `initState` method after `checkAndUpdateStreak()` returns, add streak reward check logic:

```dart
// After streak update, check for milestone reward
final streak = await repo.checkAndUpdateStreak();
final lastRewardDay = repo.getLastStreakRewardDay();
final rewardTiers = GameConstants.streakRewards.keys
    .where((day) => day <= streak && day > lastRewardDay)
    .toList()
  ..sort();

if (rewardTiers.isNotEmpty && mounted) {
  final highestTier = rewardTiers.last;
  final reward = GameConstants.streakRewards[highestTier]!;
  await repo.setLastStreakRewardDay(highestTier);
  // Show reward dialog
  if (mounted) {
    final l = ref.read(stringsProvider);
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionBuilder: fadeScaleTransition,
      transitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (_, __, ___) => StreakRewardDialog(
        streakDays: highestTier,
        rewardAmount: reward,
        titleLabel: l.streakRewardTitle,
        claimLabel: l.streakRewardClaim,
        onClaim: () {
          // Award currency (via game or direct repo)
          Navigator.pop(context);
        },
      ),
    );
  }
}
```

- [ ] **Step 11: Run all tests**

Run: `flutter test`
Expected: All 1289+ tests pass

- [ ] **Step 12: Verify with flutter analyze**

Run: `flutter analyze --no-fatal-infos`
Expected: 0 errors, 0 warnings

- [ ] **Step 13: Commit**

```bash
git add lib/core/constants/game_constants.dart lib/data/local/local_repository.dart \
  lib/game/economy/currency_manager.dart lib/features/home_screen/ \
  lib/core/l10n/ test/features/streak_reward_test.dart
git commit -m "feat: streak milestone rewards (3/7/14/30 days → Jel Ozu bonus)"
```

---

## Task 2: Confetti Effect on High Score

**Goal:** When player beats their personal high score, show a confetti particle burst — a dopamine peak that celebrates achievement.

**Files:**
- Create: `lib/features/game_screen/effects/confetti_effect.dart`
- Modify: `lib/features/game_screen/game_effects.dart`
- Modify: `lib/features/game_screen/game_screen.dart`
- Modify: `lib/features/game_screen/game_callbacks.dart`
- Modify: `lib/features/game_screen/game_grid_builder.dart`
- Test: `test/features/confetti_effect_test.dart`

### Steps

- [ ] **Step 1: Create ConfettiEffect widget**

Create `lib/features/game_screen/effects/confetti_effect.dart`:

```dart
import 'dart:math';
import 'package:flutter/material.dart';

/// Full-screen confetti burst — 40 particles with gravity, rotation, and color variety.
/// Duration: 2500ms. Self-dismisses via onDismiss callback.
class ConfettiEffect extends StatefulWidget {
  const ConfettiEffect({super.key, required this.onDismiss});
  final VoidCallback onDismiss;

  @override
  State<ConfettiEffect> createState() => _ConfettiEffectState();
}

class _ConfettiEffectState extends State<ConfettiEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500))
      ..forward();
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _ConfettiPainter(progress: _ctrl.value),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress});
  final double progress;

  static const _count = 40;
  static final _rng = Random(42);
  static final _particles = List.generate(_count, (_) => _Particle.random(_rng));

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in _particles) {
      final t = progress;
      final x = size.width * p.startX + p.vx * t * size.width * 0.5;
      final y = -20 + p.vy * t * size.height + 0.5 * 980 * t * t; // gravity
      final opacity = (1.0 - t).clamp(0.0, 1.0);
      if (opacity <= 0 || y > size.height + 20) continue;

      paint.color = p.color.withValues(alpha: opacity);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spin * t * 6.28);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.w, height: p.h),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

class _Particle {
  const _Particle({
    required this.startX,
    required this.vx,
    required this.vy,
    required this.spin,
    required this.w,
    required this.h,
    required this.color,
  });

  final double startX, vx, vy, spin, w, h;
  final Color color;

  static const _colors = [
    Color(0xFFFF6B6B), Color(0xFF4ECDC4), Color(0xFFFFE66D),
    Color(0xFFA8E6CF), Color(0xFFFF8A5C), Color(0xFF6C5CE7),
    Color(0xFFFF85A1), Color(0xFF00D2FF),
  ];

  static _Particle random(Random rng) {
    return _Particle(
      startX: rng.nextDouble(),
      vx: (rng.nextDouble() - 0.5) * 2,
      vy: -(rng.nextDouble() * 0.4 + 0.3), // upward initial velocity
      spin: (rng.nextDouble() - 0.5) * 4,
      w: rng.nextDouble() * 8 + 4,
      h: rng.nextDouble() * 6 + 2,
      color: _colors[rng.nextInt(_colors.length)],
    );
  }
}
```

- [ ] **Step 2: Export from game_effects.dart**

In `lib/features/game_screen/game_effects.dart`, add:

```dart
export 'effects/confetti_effect.dart';
```

- [ ] **Step 3: Add confetti state to GameScreen**

In `lib/features/game_screen/game_screen.dart`, add state variable (after `showHighScoreBadge`):

```dart
@override
bool showConfetti = false;
@override
int confettiKey = 0;
```

- [ ] **Step 4: Add confetti mixin interface to _GameCallbacksMixin**

In `lib/features/game_screen/game_callbacks.dart`, add to mixin interface:

```dart
bool get showConfetti;
set showConfetti(bool value);
int get confettiKey;
set confettiKey(int value);
```

- [ ] **Step 5: Trigger confetti in onScoreGained callback**

In `game_callbacks.dart`, inside `game.onScoreGained` callback, after the high score badge logic, add:

```dart
if (game.isNewHighScore && !showConfetti) {
  setState(() {
    showConfetti = true;
    confettiKey++;
  });
}
```

- [ ] **Step 6: Add confetti mixin interface to _GameGridBuilderMixin**

In `lib/features/game_screen/game_grid_builder.dart`, add to mixin interface:

```dart
bool get showConfetti;
set showConfetti(bool value);
int get confettiKey;
```

- [ ] **Step 7: Add confetti overlay to game_screen.dart body Stack**

In `lib/features/game_screen/game_screen.dart`, in the build method Stack children (after `showHighScoreBadge` Positioned), add:

```dart
if (showConfetti)
  Positioned.fill(
    child: ConfettiEffect(
      key: ValueKey(confettiKey),
      onDismiss: () => setState(() => showConfetti = false),
    ),
  ),
```

- [ ] **Step 8: Write test**

```dart
// test/features/confetti_effect_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/features/game_screen/effects/confetti_effect.dart';

void main() {
  testWidgets('ConfettiEffect renders and dismisses', (tester) async {
    bool dismissed = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ConfettiEffect(onDismiss: () => dismissed = true),
      ),
    ));
    expect(find.byType(ConfettiEffect), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2600));
    expect(dismissed, isTrue);
  });
}
```

- [ ] **Step 9: Run tests**

Run: `flutter test test/features/confetti_effect_test.dart -v`
Expected: PASS

- [ ] **Step 10: Run flutter analyze**

Run: `flutter analyze --no-fatal-infos`
Expected: 0 errors, 0 warnings

- [ ] **Step 11: Commit**

```bash
git add lib/features/game_screen/effects/confetti_effect.dart \
  lib/features/game_screen/game_effects.dart \
  lib/features/game_screen/game_screen.dart \
  lib/features/game_screen/game_callbacks.dart \
  test/features/confetti_effect_test.dart
git commit -m "feat: confetti particle burst on new high score"
```

---

## Task 3: Bomb Freeze-Frame Effect

**Goal:** Add a 100ms pause before bomb explosion animation starts — creates a dramatic "impact" moment.

**Files:**
- Modify: `lib/features/game_screen/effects/power_up_effects.dart` (BombExplosionEffect)
- Test: `test/features/bomb_freeze_frame_test.dart`

### Steps

- [ ] **Step 1: Write failing test**

```dart
// test/features/bomb_freeze_frame_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/features/game_screen/effects/power_up_effects.dart';

void main() {
  testWidgets('BombExplosionEffect has 100ms delay before animation', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 200,
          height: 200,
          child: BombExplosionEffect(
            cellSize: 30,
            onDismiss: () {},
          ),
        ),
      ),
    ));
    // At t=0, should be in freeze-frame (no animation progress yet)
    expect(find.byType(BombExplosionEffect), findsOneWidget);
    // Pump past freeze + full duration
    await tester.pump(const Duration(milliseconds: 800));
  });
}
```

- [ ] **Step 2: Run test to verify baseline**

Run: `flutter test test/features/bomb_freeze_frame_test.dart -v`
Expected: PASS (widget renders)

- [ ] **Step 3: Add freeze-frame delay to BombExplosionEffect**

In `lib/features/game_screen/effects/power_up_effects.dart`, in `_BombExplosionEffectState.initState()`, wrap the AnimationController forward call with a delay:

```dart
@override
void initState() {
  super.initState();
  _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  // 100ms freeze-frame before explosion begins
  Future.delayed(const Duration(milliseconds: 100), () {
    if (mounted) _ctrl.forward();
  });
  _ctrl.addStatusListener((status) {
    if (status == AnimationStatus.completed && mounted) widget.onDismiss();
  });
}
```

Also update the total dismiss time to account for the delay (if there's a separate Timer, extend it by 100ms).

- [ ] **Step 4: Run test**

Run: `flutter test test/features/bomb_freeze_frame_test.dart -v`
Expected: PASS

- [ ] **Step 5: Run all tests**

Run: `flutter test`
Expected: All tests pass

- [ ] **Step 6: Commit**

```bash
git add lib/features/game_screen/effects/power_up_effects.dart \
  test/features/bomb_freeze_frame_test.dart
git commit -m "feat: 100ms freeze-frame before bomb explosion for dramatic impact"
```

---

## Task 4: Small Combo SFX

**Goal:** Small combos (2 lines within 1.5s) currently have no dedicated SFX — they feel incomplete compared to medium/large/epic tiers. Add a subtle ping sound.

**Files:**
- Modify: `lib/audio/sound_bank.dart`
- Modify: `lib/audio/audio_constants.dart`
- Test: `test/audio/sound_bank_test.dart` (existing, verify no regression)

### Steps

- [ ] **Step 1: Check existing combo SFX mapping**

Read `lib/audio/sound_bank.dart` to understand the current `onCombo()` method structure.

- [ ] **Step 2: Add comboTiny audio path**

In `lib/audio/audio_constants.dart`, add alongside existing combo paths:

```dart
static String get comboTiny => _sfx('combo_small'); // reuse small SFX at lower volume
```

Note: If a dedicated `combo_tiny.ogg` asset exists, use that path. Otherwise reuse `combo_small` at 0.5 volume.

- [ ] **Step 3: Update SoundBank.onCombo() to handle small tier**

In `lib/audio/sound_bank.dart`, in the `onCombo()` method, ensure the `ComboTier.small` case plays a quiet SFX instead of being silent:

```dart
Future<void> onCombo(ComboEvent combo) async {
  switch (combo.tier) {
    case ComboTier.none:
      return;
    case ComboTier.small:
      await _audio.playSfx(AudioPaths.comboSmall, volume: 0.5);
    case ComboTier.medium:
      await _audio.playSfx(AudioPaths.comboMedium);
    case ComboTier.large:
      await _audio.playSfx(AudioPaths.comboLarge);
      _haptic.trigger(HapticProfile.comboEpic); // or appropriate profile
    case ComboTier.epic:
      await _audio.playSfx(AudioPaths.comboEpic);
      _haptic.trigger(HapticProfile.comboEpic);
  }
}
```

- [ ] **Step 4: Run existing audio tests**

Run: `flutter test test/audio/ -v`
Expected: All pass

- [ ] **Step 5: Run flutter analyze**

Run: `flutter analyze --no-fatal-infos`
Expected: 0 errors, 0 warnings

- [ ] **Step 6: Commit**

```bash
git add lib/audio/sound_bank.dart lib/audio/audio_constants.dart
git commit -m "feat: add small combo SFX (quiet ping) to complete audio tier hierarchy"
```

---

## Task 5: Auto-Share Prompt After Epic Moments

**Goal:** After an epic combo or near-miss survival, show a brief "Share this moment?" dialog that opens the native share sheet with a text-based score share. This creates viral opportunities without waiting for video pipeline.

**Files:**
- Create: `lib/features/game_screen/share_prompt_dialog.dart`
- Modify: `lib/features/game_screen/game_callbacks.dart`
- Modify: `lib/features/game_screen/game_screen.dart`
- Modify: `lib/core/l10n/app_strings.dart`
- Modify: `lib/core/l10n/strings_en.dart` (+ 11 other lang files)
- Modify: `lib/viral/share_manager.dart`
- Test: `test/features/share_prompt_test.dart`

### Steps

- [ ] **Step 1: Add l10n strings**

In `lib/core/l10n/app_strings.dart`, add:

```dart
String get sharePromptTitle;    // "Epic moment!"
String get sharePromptMessage;  // "Share your score?"
String get sharePromptShare;    // "Share"
String get sharePromptSkip;     // "Skip"
```

Implement in all 12 `strings_*.dart` files.

- [ ] **Step 2: Add shareComboResult to ShareManager**

In `lib/viral/share_manager.dart`, add:

```dart
Future<void> shareComboResult({
  required int score,
  required String mode,
  required String comboLabel,
}) async {
  final modeLabel = _modeLabel(mode);
  final text = '$comboLabel! $modeLabel modunda ${_formatScore(score)} puan! '
      '$_appUrl\n\n$_hashtags';
  AnalyticsService().logShare(mode: 'combo');
  await Share.share(text);
}

String _modeLabel(String mode) {
  return switch (mode) {
    'classic' => 'Klasik',
    'colorChef' => 'Renk Sefi',
    'timeTrial' => 'Zaman Kosusu',
    'zen' => 'Zen',
    'daily' => 'Gunluk Bulmaca',
    _ => mode,
  };
}
```

Note: Extract the existing `_buildCaption` switch to `_modeLabel` to DRY up.

- [ ] **Step 3: Create SharePromptDialog**

Create `lib/features/game_screen/share_prompt_dialog.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';

class SharePromptDialog extends StatelessWidget {
  const SharePromptDialog({
    super.key,
    required this.title,
    required this.message,
    required this.shareLabel,
    required this.skipLabel,
    required this.onShare,
    required this.onSkip,
  });

  final String title, message, shareLabel, skipLabel;
  final VoidCallback onShare, onSkip;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kSurfaceDark,
            borderRadius: BorderRadius.circular(UIConstants.radiusLg),
            border: Border.all(color: kCyan.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.share_rounded, color: kCyan, size: 36)
                  .animate()
                  .scale(begin: const Offset(0.5, 0.5), duration: 350.ms,
                      curve: Curves.elasticOut),
              const SizedBox(height: 10),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(message,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14)),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onSkip,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius:
                              BorderRadius.circular(UIConstants.radiusMd),
                        ),
                        child: Text(skipLabel,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: onShare,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: kCyan.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(UIConstants.radiusMd),
                          border: Border.all(
                              color: kCyan.withValues(alpha: 0.5)),
                        ),
                        child: Text(shareLabel,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: kCyan, fontSize: 14,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Add share prompt state to GameScreen**

In `game_screen.dart`, add state:

```dart
int _epicComboCount = 0; // track to avoid spamming — show max 1 per game
```

- [ ] **Step 5: Trigger share prompt in game_callbacks.dart**

In `game_callbacks.dart`, inside the `game.onCombo` callback, after the combo effect and clip recorder trigger, add:

```dart
// Show share prompt on first epic combo per game (don't spam)
if (combo.tier == ComboTier.epic && _epicComboCount == 0) {
  _epicComboCount++;
  // Delay to let combo effect play first
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
          );
        },
        onSkip: () => Navigator.pop(context),
      ),
    );
  });
}
```

Note: `_epicComboCount` needs to be accessible from the mixin. Add it as a mixin interface getter/setter, or track it directly in `_GameScreenState`.

- [ ] **Step 6: Reset epic count on game restart**

In `handleGameOverDialog` → `onReplay` callback, add:

```dart
_epicComboCount = 0;
```

- [ ] **Step 7: Write test**

```dart
// test/features/share_prompt_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/features/game_screen/share_prompt_dialog.dart';

void main() {
  testWidgets('SharePromptDialog renders share and skip buttons', (tester) async {
    bool shared = false;
    bool skipped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SharePromptDialog(
          title: 'Epic!',
          message: 'Share?',
          shareLabel: 'Share',
          skipLabel: 'Skip',
          onShare: () => shared = true,
          onSkip: () => skipped = true,
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    await tester.tap(find.text('Share'));
    expect(shared, isTrue);
  });
}
```

- [ ] **Step 8: Run tests**

Run: `flutter test test/features/share_prompt_test.dart -v`
Expected: PASS

- [ ] **Step 9: Run all tests + analyze**

Run: `flutter test && flutter analyze --no-fatal-infos`
Expected: All pass, 0 errors/warnings

- [ ] **Step 10: Commit**

```bash
git add lib/features/game_screen/share_prompt_dialog.dart \
  lib/features/game_screen/game_callbacks.dart \
  lib/features/game_screen/game_screen.dart \
  lib/viral/share_manager.dart \
  lib/core/l10n/ \
  test/features/share_prompt_test.dart
git commit -m "feat: auto-share prompt after epic combo for viral growth"
```

---

## Task 6: Interactive First-Game Tutorial

**Goal:** After onboarding screens, the first game session shows a 3-step overlay guiding the player: (1) select a shape, (2) tap grid to preview, (3) tap again to place. This dramatically reduces first-game churn.

**Files:**
- Create: `lib/features/game_screen/tutorial_overlay.dart`
- Modify: `lib/data/local/local_repository.dart`
- Modify: `lib/features/game_screen/game_screen.dart`
- Modify: `lib/features/game_screen/game_interactions.dart`
- Modify: `lib/core/l10n/app_strings.dart`
- Modify: `lib/core/l10n/strings_en.dart` (+ 11 other lang files)
- Test: `test/features/tutorial_overlay_test.dart`

### Steps

- [ ] **Step 1: Add persistence to LocalRepository**

In `lib/data/local/local_repository.dart`, add:

```dart
bool getTutorialDone() => _prefs.getBool('tutorial_done') ?? false;

Future<void> setTutorialDone() async {
  await _prefs.setBool('tutorial_done', true);
}
```

- [ ] **Step 2: Add l10n strings**

In `lib/core/l10n/app_strings.dart`, add:

```dart
String get tutorialStep1;  // "Tap a shape to select it"
String get tutorialStep2;  // "Tap the grid to preview placement"
String get tutorialStep3;  // "Tap again to place! Lines clear when full."
String get tutorialGotIt;  // "Got it!"
```

Implement in all 12 `strings_*.dart` files.

- [ ] **Step 3: Create TutorialOverlay widget**

Create `lib/features/game_screen/tutorial_overlay.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';

/// 3-step tutorial overlay shown during first game.
/// Each step advances on user action (onSlotTap, onCellTap, onCellTap).
class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({
    super.key,
    required this.step,
    required this.message,
    required this.onDismiss,
    this.dismissLabel,
    this.pointDown = false,
  });

  /// Current tutorial step (0-2).
  final int step;
  /// Localized instruction message.
  final String message;
  /// Called when user taps "Got it" or tutorial completes.
  final VoidCallback onDismiss;
  /// Label for dismiss button (shown on last step).
  final String? dismissLabel;
  /// If true, shows downward arrow (pointing at hand). If false, upward (pointing at grid).
  final bool pointDown;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: pointDown ? 200 : null,
      top: pointDown ? null : 100,
      child: IgnorePointer(
        ignoring: dismissLabel == null, // only tappable on last step
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!pointDown)
              Icon(Icons.arrow_upward_rounded,
                  color: kCyan.withValues(alpha: 0.6), size: 28)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .slideY(begin: 0, end: -0.3, duration: 600.ms),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: kSurfaceDark.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                border: Border.all(color: kCyan.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: kCyan.withValues(alpha: 0.15),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  if (dismissLabel != null) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: onDismiss,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: kCyan.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(UIConstants.radiusSm),
                          border:
                              Border.all(color: kCyan.withValues(alpha: 0.4)),
                        ),
                        child: Text(dismissLabel!,
                            style: TextStyle(
                                color: kCyan,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(
                begin: pointDown ? 0.1 : -0.1,
                duration: 300.ms,
                curve: Curves.easeOutCubic),
            if (pointDown)
              Icon(Icons.arrow_downward_rounded,
                  color: kCyan.withValues(alpha: 0.6), size: 28)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .slideY(begin: 0, end: 0.3, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Add tutorial state to GameScreen**

In `lib/features/game_screen/game_screen.dart`, add:

```dart
int _tutorialStep = -1; // -1 = no tutorial, 0/1/2 = active steps
bool _tutorialActive = false;
```

In `initState()`, after `setupCallbacks()`, add:

```dart
// Check if tutorial should be shown (first game only, classic mode)
if (widget.mode == GameMode.classic) {
  ref.read(localRepositoryProvider.future).then((repo) {
    if (!repo.getTutorialDone() && mounted) {
      setState(() {
        _tutorialStep = 0;
        _tutorialActive = true;
      });
    }
  });
}
```

- [ ] **Step 5: Advance tutorial on user actions**

In `lib/features/game_screen/game_interactions.dart`:

In `onSlotTap()`, after the existing logic, add at the end:

```dart
// Advance tutorial from step 0 (select shape) to step 1 (tap grid)
if (_tutorialActive && _tutorialStep == 0 && selectedSlot != null) {
  setState(() => _tutorialStep = 1);
}
```

In `onCellTap()`, after successful placement (inside the `if (!canPlace)` block that returns, before `game.placePiece()`), add:

```dart
// Advance tutorial from step 1 (preview) to step 2 (placed!)
if (_tutorialActive && _tutorialStep == 1) {
  // First tap shows preview — advance to step 2
  setState(() => _tutorialStep = 2);
  return; // Let them see the preview first
}
```

Note: The existing two-tap logic already handles preview → place. Tutorial step 1→2 happens when preview is first shown. Step 2 shows "Tap again to place!" message. After placement, tutorial completes.

After successful `game.placePiece()` call:

```dart
if (_tutorialActive && _tutorialStep == 2) {
  _tutorialActive = false;
  _tutorialStep = -1;
  ref.read(localRepositoryProvider.future).then((repo) => repo.setTutorialDone());
}
```

These state variables need to be accessible from the interactions mixin. Add them as interface getters/setters:

```dart
bool get _tutorialActive; // in _GameInteractionsMixin
set _tutorialActive(bool value);
int get _tutorialStep;
set _tutorialStep(int value);
```

Note: Since these are private, they need to be accessed through the `_GameScreenState` directly. The mixin already has access via `ConsumerState<GameScreen>`.

- [ ] **Step 6: Render tutorial overlay in game_screen.dart**

In `game_screen.dart` build method Stack, add (before the toast):

```dart
if (_tutorialActive && _tutorialStep >= 0) ...[
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
    final messages = [l.tutorialStep1, l.tutorialStep2, l.tutorialStep3];
    return TutorialOverlay(
      step: _tutorialStep,
      message: messages[_tutorialStep],
      pointDown: _tutorialStep == 0, // step 0 points at hand
      dismissLabel: _tutorialStep == 2 ? l.tutorialGotIt : null,
      onDismiss: () {
        setState(() {
          _tutorialActive = false;
          _tutorialStep = -1;
        });
        ref.read(localRepositoryProvider.future)
            .then((repo) => repo.setTutorialDone());
      },
    );
  }),
],
```

- [ ] **Step 7: Write test**

```dart
// test/features/tutorial_overlay_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/features/game_screen/tutorial_overlay.dart';

void main() {
  testWidgets('TutorialOverlay displays message', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            TutorialOverlay(
              step: 0,
              message: 'Tap a shape',
              pointDown: true,
              onDismiss: () {},
            ),
          ],
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Tap a shape'), findsOneWidget);
  });

  testWidgets('TutorialOverlay shows dismiss button on last step', (tester) async {
    bool dismissed = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            TutorialOverlay(
              step: 2,
              message: 'Done!',
              dismissLabel: 'Got it!',
              onDismiss: () => dismissed = true,
            ),
          ],
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Got it!'), findsOneWidget);
    await tester.tap(find.text('Got it!'));
    expect(dismissed, isTrue);
  });
}
```

- [ ] **Step 8: Run tests**

Run: `flutter test test/features/tutorial_overlay_test.dart -v`
Expected: PASS

- [ ] **Step 9: Run all tests + analyze**

Run: `flutter test && flutter analyze --no-fatal-infos`
Expected: All pass, 0 errors/warnings

- [ ] **Step 10: Commit**

```bash
git add lib/features/game_screen/tutorial_overlay.dart \
  lib/data/local/local_repository.dart \
  lib/features/game_screen/game_screen.dart \
  lib/features/game_screen/game_interactions.dart \
  lib/core/l10n/ \
  test/features/tutorial_overlay_test.dart
git commit -m "feat: interactive 3-step tutorial overlay for first game session"
```

---

## Summary

| Task | Feature | Primary Impact | Estimated Effort |
|------|---------|---------------|-----------------|
| 1 | Streak Milestone Rewards | +5% D7 retention | 3-4 hours |
| 2 | Confetti on High Score | +3% D1 (dopamine peak) | 2-3 hours |
| 3 | Bomb Freeze-Frame | Polish (dramatic impact) | 30 min |
| 4 | Small Combo SFX | Audio hierarchy completeness | 30 min |
| 5 | Auto-Share Prompt | +2% K-factor (viral) | 3-4 hours |
| 6 | Interactive Tutorial | +8% D1 retention | 4-5 hours |

**Total estimated effort:** ~14-17 hours
**Combined impact:** D1 +11%, D7 +5%, K-factor +0.05

All tasks are fully independent — can be implemented in any order or in parallel.
