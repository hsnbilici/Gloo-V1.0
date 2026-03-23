# Stereo Ses Revizyonu Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tum ses dosyalarini studio kalitesinde stereo olarak revize etmek + 6 yeni muzik parcasi eklemek + mod-bazli muzik secim mantigi + sessizlik stratejisi.

**Architecture:** Faz 1 (asset uretimi — kullanici tarafindan AI araclarla) sifir kod degisikligi gerektirir, drop-in dosya degisimi. Faz 2 (6 yeni muzik + kod) `audio_constants.dart`'a path'ler, `game_screen.dart`'a mod-muzik eslesmesi, `game_callbacks.dart`'a sessizlik gap'leri ekler.

**Tech Stack:** Flutter/Dart, just_audio, Suno/Udio (muzik), ElevenLabs SFX (SFX)

**Spec:** `docs/superpowers/specs/2026-03-23-stereo-audio-revision-design.md`

---

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Replace | `assets/audio/sfx/*.ogg` + `*.m4a` (32 cift) | Stereo/kalite yukseltilmis SFX dosyalari |
| Replace | `assets/audio/music/*.mp3` (4 dosya) | Stereo revize muzik |
| Create | `assets/audio/music/colorchef_groove.mp3` | Yeni muzik |
| Create | `assets/audio/music/level_quest.mp3` | Yeni muzik |
| Create | `assets/audio/music/daily_ritual.mp3` | Yeni muzik |
| Create | `assets/audio/music/duel_arena.mp3` | Yeni muzik |
| Create | `assets/audio/music/menu_chill.mp3` | Yeni muzik |
| Create | `assets/audio/music/tension_escalation.mp3` | Yeni muzik |
| Modify | `lib/core/constants/audio_constants.dart` | 6 yeni muzik path + musicForMode map |
| Modify | `lib/features/game_screen/game_screen.dart:262-268` | Mod-muzik eslesmesi |
| Modify | `lib/features/game_screen/game_callbacks.dart` | Sessizlik gap'leri (3 an) |
| Modify | `lib/features/home_screen/home_screen.dart:71` | menu_chill alternasyon |
| Modify | `pubspec.yaml` | Yeni music asset'leri (flutter assets listesi) |

---

## Task 1: Faz 1A — 11 Stereo SFX Uretimi (Kullanici)

**Bu task kullanici tarafindan AI araclarla yapilir — kod degisikligi yok.**

- [ ] **Step 1: ElevenLabs SFX ile 11 stereo SFX uret**

Spec Bolum 2.1'deki AI prompt'lari kullan. Her SFX icin:
1. AI aracta prompt'u gir
2. Sonucu DAW'da ac (Audacity, Logic, GarageBand vb.)
3. Post-processing zincirini uygula (spec'teki per-SFX post notlari)
4. 48kHz stereo WAV olarak kaydet
5. `.ogg` (Ogg Vorbis stereo 128kbps) + `.m4a` (AAC-LC stereo 128kbps) export et
6. Phase cancellation testi: mono'ya sumla, ses kaybolmuyorsa OK

Dosyalar: `combo_large`, `combo_epic`, `line_clear_crystal`, `level_complete`, `level_complete_new`, `pvp_victory`, `pvp_defeat`, `game_over`, `bomb_explosion`, `near_miss_tension`, `freeze_chime`

- [ ] **Step 2: Dosyalari `assets/audio/sfx/` klasorune kopyala** (mevcut dosyalarin UZERINE yaz)

- [ ] **Step 3: Dogrulama** — simülatörde uygulama ac, her SFX'i tetikle, stereo duy

---

## Task 2: Faz 1B — 21 Mono SFX Kalite Yukseltmesi (Kullanici)

**Bu task kullanici tarafindan AI araclarla yapilir — kod degisikligi yok.**

- [ ] **Step 1: ElevenLabs SFX ile 21 mono SFX uret**

Spec Bolum 2.2'deki AI prompt'lari + Jel DNA katman agirliklarini kullan. Post-processing:
1. Trim
2. EQ: HP 40Hz, LP 12kHz
3. Compression: 3:1, -18dB threshold
4. Normalize -6 dBFS
5. Plate reverb: 5-15ms pre-delay, 200-400ms decay, %15-25 wet
6. Export: `.ogg` Vorbis mono 96kbps + `.m4a` AAC-LC mono 96kbps

- [ ] **Step 2: combo_epic.m4a sample rate duzelt** — 96kHz → 48kHz (ffmpeg veya DAW)

- [ ] **Step 3: Dosyalari `assets/audio/sfx/` klasorune kopyala**

- [ ] **Step 4: Dogrulama** — simülatörde test

---

## Task 3: Faz 1C — 4 Muzik Revize (Kullanici)

**Bu task kullanici tarafindan Suno/Udio ile yapilir — kod degisikligi yok.**

- [ ] **Step 1: Suno/Udio ile 4 muzik parcasi uret**

Spec Bolum 3.1'deki prompt'lari kullan:
- `menu_lofi.mp3` — 78 BPM, Bb Maj, 150sn
- `game_relax.mp3` — 98 BPM, C Maj, 180sn
- `game_tension.mp3` — 124 BPM, C min, 150sn
- `zen_ambient.mp3` — 65 BPM, Eb Maj, 240sn

Post-processing:
1. Loudness normalize: -14 LUFS integrated, -1 dBTP
2. SFX Boslugu: 800Hz-2kHz notch (EQ'da -4 ile -8 dB)
3. Seamless loop: son 100ms xfade
4. Export: MP3 stereo 44.1kHz 192kbps CBR

- [ ] **Step 2: 1.15x speed testi** — game_tension'i 1.15x'te dinle, bozulma yok mu

- [ ] **Step 3: Dosyalari `assets/audio/music/` klasorune kopyala** (mevcut dosyalarin UZERINE yaz)

- [ ] **Step 4: Dogrulama** — simülatörde her mod'da müzik dinle

- [ ] **Step 5: Commit**
```bash
git add assets/audio/
git commit -m "feat(audio): Faz 1 — studio quality stereo SFX + music revision"
```

---

## Task 4: Faz 2A — 6 Yeni Muzik Uretimi (Kullanici)

**Bu task kullanici tarafindan Suno/Udio ile yapilir.**

- [ ] **Step 1: 6 muzik parcasi uret**

Spec Bolum 3.2'deki prompt'lari kullan:
- `colorchef_groove.mp3` — 100 BPM, Eb Maj, 150sn
- `level_quest.mp3` — 112 BPM, G Maj, 150sn
- `daily_ritual.mp3` — 92 BPM, D Maj, 120sn
- `duel_arena.mp3` — 130 BPM, A min, 120sn
- `menu_chill.mp3` — 78 BPM, Bb Maj, 150sn
- `tension_escalation.mp3` — 124 BPM, C min, 120sn

Post-processing: ayni (loudness, SFX boslugu, loop, export)

- [ ] **Step 2: 1.15x speed testi** — duel_arena ve tension_escalation

- [ ] **Step 3: Dosyalari `assets/audio/music/` klasorune kopyala**

---

## Task 5: Faz 2B — AudioPaths + musicForMode

**Files:**
- Modify: `lib/core/constants/audio_constants.dart`
- Modify: `pubspec.yaml`

- [ ] **Step 1: pubspec.yaml'a yeni music asset'leri ekle**

`pubspec.yaml`'daki `flutter.assets` listesinde `assets/audio/music/` zaten toplu listeleniyorsa ek islem gerekmez. Kontrol et — dosya bazli listeleme varsa 6 yeni dosyayi ekle.

- [ ] **Step 2: 6 yeni muzik path'i ekle**

`lib/core/constants/audio_constants.dart`'ta mevcut 4 muzik path'in altina:

```dart
static const String bgColorChef = '$_music/colorchef_groove.mp3';
static const String bgLevelQuest = '$_music/level_quest.mp3';
static const String bgDailyRitual = '$_music/daily_ritual.mp3';
static const String bgDuelArena = '$_music/duel_arena.mp3';
static const String bgMenuChill = '$_music/menu_chill.mp3';
static const String bgTensionEscalation = '$_music/tension_escalation.mp3';
```

- [ ] **Step 3: musicForMode helper ekle**

Ayni dosyada veya `AudioPaths` class'ina:

```dart
/// Oyun moduna gore muzik path'ini doner.
static String musicForMode(GameMode mode) => switch (mode) {
  GameMode.zen => bgZenMode,
  GameMode.timeTrial => bgGameTension,
  GameMode.duel => bgDuelArena,
  GameMode.colorChef => bgColorChef,
  GameMode.level => bgLevelQuest,
  GameMode.daily => bgDailyRitual,
  _ => bgGameRelax,
};
```

`GameMode` import'u: `import '../../core/models/game_mode.dart';` (audio_constants.dart'a — veya ayri helper dosyasi)

**Not:** `audio_constants.dart` saf Dart, `GameMode` da saf Dart (`core/models/game_mode.dart`) — import uyumlu.

- [ ] **Step 4: Analyze**
```
flutter analyze lib/core/constants/audio_constants.dart
```

- [ ] **Step 5: Commit**
```bash
git add lib/core/constants/audio_constants.dart pubspec.yaml
git commit -m "feat(audio): 6 new music paths + musicForMode helper"
```

---

## Task 6: Faz 2C — Mod-Bazli Muzik Secim Entegrasyonu

**Files:**
- Modify: `lib/features/game_screen/game_screen.dart:262-268`
- Modify: `lib/features/home_screen/home_screen.dart:71`

- [ ] **Step 1: game_screen.dart mod-muzik eslesmesini guncelle**

`lib/features/game_screen/game_screen.dart` satir 262-268 civarinda mevcut:

```dart
final musicPath = switch (widget.mode) {
  GameMode.zen => AudioPaths.bgZenMode,
  GameMode.timeTrial || GameMode.duel => AudioPaths.bgGameTension,
  _ => AudioPaths.bgGameRelax,
};
AudioManager().playMusic(musicPath);
```

Degistir:

```dart
AudioManager().playMusic(AudioPaths.musicForMode(widget.mode));
```

- [ ] **Step 2: home_screen.dart menu_chill alternasyon**

`lib/features/home_screen/home_screen.dart` satir 71 civarinda:

```dart
AudioManager().playMusic(AudioPaths.bgMenuLofi);
```

Degistir:

```dart
// Gece saatlerinde (21:00-06:00) menu_chill, diger saatlerde menu_lofi
final hour = DateTime.now().hour;
final menuMusic = (hour >= 21 || hour < 6)
    ? AudioPaths.bgMenuChill
    : AudioPaths.bgMenuLofi;
AudioManager().playMusic(menuMusic);
```

- [ ] **Step 3: dispose'dan donen muzik de dogru olmali**

`game_screen.dart` dispose'da HomeScreen'e donerken muzik degisimi var mi kontrol et (satir 566):

```dart
AudioManager().playMusic(AudioPaths.bgMenuLofi);
```

Bunu da guncelle:
```dart
final hour = DateTime.now().hour;
AudioManager().playMusic(
  (hour >= 21 || hour < 6) ? AudioPaths.bgMenuChill : AudioPaths.bgMenuLofi,
);
```

- [ ] **Step 4: Analyze + test**
```
flutter analyze lib/features/game_screen/game_screen.dart lib/features/home_screen/home_screen.dart
flutter test test/features/game_screen_test.dart test/features/home_screen_test.dart -v
```

- [ ] **Step 5: Commit**
```bash
git add lib/features/game_screen/game_screen.dart lib/features/home_screen/home_screen.dart
git commit -m "feat(audio): mode-based music selection + night menu_chill"
```

---

## Task 7: Faz 2D — Grid Doluluk Crossfade Guncelleme

**Files:**
- Modify: `lib/features/game_screen/game_callbacks.dart`

- [ ] **Step 1: Mevcut crossfade mantgini oku**

`game_callbacks.dart`'ta `crossfadeMusic` cagrisini bul — grid %70+ doluyken `game_relax` → `game_tension` crossfade.

- [ ] **Step 2: tension_escalation'a guncelle**

Mevcut:
```dart
AudioManager().crossfadeMusic(AudioPaths.bgGameTension);
```

Degistir:
```dart
AudioManager().crossfadeMusic(AudioPaths.bgTensionEscalation);
```

Geri donusu de kontrol et (hysteresis %60):
```dart
AudioManager().crossfadeMusic(AudioPaths.musicForMode(widget.mode));
```

- [ ] **Step 3: Analyze**
```
flutter analyze lib/features/game_screen/game_callbacks.dart
```

- [ ] **Step 4: Commit**
```bash
git add lib/features/game_screen/game_callbacks.dart
git commit -m "feat(audio): grid fullness crossfade → tension_escalation"
```

---

## Task 8: Faz 2E — Sessizlik Gap'leri (Odul Seviyesi)

**Files:**
- Modify: `lib/features/game_screen/game_callbacks.dart`

- [ ] **Step 1: game_over sessizlik gap'i**

`game.onGameOver` callback'inde, `soundBank.onGameOver()` cagrisindan ONCE:

```dart
// Odul seviyesi: 150ms sessizlik — "bir sey bitti" hissini kurar
await Future.delayed(const Duration(milliseconds: 150));
if (!mounted) return;
soundBank.onGameOver();
```

**Dikkat:** Mevcut callback `void Function()` signature — async yapilamayabilir. Bu durumda `Future.delayed` + `.then()` pattern kullan:

```dart
Future.delayed(const Duration(milliseconds: 150), () {
  if (mounted) soundBank.onGameOver();
});
```

- [ ] **Step 2: combo_epic sessizlik gap'i**

`game.onCombo` callback'inde, `combo.tier == ComboTier.epic` ise:

```dart
if (combo.tier == ComboTier.epic) {
  Future.delayed(const Duration(milliseconds: 80), () {
    if (mounted) soundBank.onCombo(combo);
  });
} else {
  soundBank.onCombo(combo);
}
```

- [ ] **Step 3: level_complete sessizlik gap'i**

`game.onLevelComplete` callback'inde:

```dart
Future.delayed(const Duration(milliseconds: 100), () {
  if (mounted) soundBank.onLevelComplete();
});
```

- [ ] **Step 4: Analyze + test**
```
flutter analyze lib/features/game_screen/game_callbacks.dart
flutter test test/features/game_screen_test.dart -v
```

- [ ] **Step 5: Commit**
```bash
git add lib/features/game_screen/game_callbacks.dart
git commit -m "feat(audio): silence gaps before epic moments (150/80/100ms)"
```

---

## Task 9: Son Dogrulama

- [ ] **Step 1: Tum testleri calistir**
```
flutter test test/ --exclude-tags=golden
```
Expected: 2155+ tests PASS

- [ ] **Step 2: Simülatörde tam oyun testi**
- Classic mod → game_relax muzik duyulmali
- ColorChef mod → colorchef_groove duyulmali
- Level mod → level_quest duyulmali
- Duel mod → duel_arena duyulmali
- Grid %70+ → tension_escalation crossfade
- Game over → 150ms sessizlik + game_over SFX
- Epic combo → 80ms sessizlik + combo_epic SFX
- Gece saatlerinde HomeScreen → menu_chill

- [ ] **Step 3: Boyut kontrolu**
```bash
du -sh assets/audio/
```
Expected: < 35MB

- [ ] **Step 4: Final commit**
```bash
git add -A
git commit -m "feat(audio): stereo revision complete — award-level sound design"
```
