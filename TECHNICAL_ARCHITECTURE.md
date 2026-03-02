# Gloo: Teknik Mimari Belgesi
## v0.4 — 2026-03-02

---

## Sistem Genel Bakisi

```
+-----------------------------------------------------------------+
|                         FLUTTER APP                             |
|                                                                 |
|  +---------------+  +---------------+  +-------------------+   |
|  |  Presentation |  |  Game Engine  |  |   Platform Layer  |   |
|  |   (Riverpod)  |  |  (Saf Dart)   |  |  (Audio/Haptic)   |   |
|  +------+--------+  +------+--------+  +--------+----------+   |
|         |                  |                     |              |
|  +------v------------------v---------------------v-----------+  |
|  |               Application Core (Dart)                     |  |
|  |    Grid Logic | Physics | Color Synthesis | Scoring       |  |
|  |    Levels | Economy | Meta-Game | PvP | Power-ups         |  |
|  +----------------------------+------------------------------+  |
|                               |                                 |
|  +----------------------------v------------------------------+  |
|  |                    Data Layer                              |  |
|  |      SharedPreferences (Local) | Supabase (Remote)        |  |
|  +------------------------------------------------------------+  |
|                                                                 |
|  +------------------------------------------------------------+  |
|  |              Viral Clip Module                             |  |
|  |    ClipRecorder | VideoProcessor | ShareManager            |  |
|  +------------------------------------------------------------+  |
+-----------------------------------------------------------------+
```

**Onemli:** Oyun motoru saf Dart'tir — Flame kullanilmaz. `GlooGame` sinifi bir `FlameGame` degil, dogrudan `_GameScreenState` icinde tutulan saf Dart orkestratordur.

---

## Klasor Yapisi

```
lib/
+-- main.dart                          # Entry point (123 satir)
+-- app/
|   +-- app.dart                       # MaterialApp, tema, locale
|   +-- router.dart                    # GoRouter route tanimlari
|
+-- core/
|   +-- constants/
|   |   +-- game_constants.dart        # Grid boyutlari (8x10), FPS, fizik
|   |   +-- color_constants.dart       # GelColor enum (12), sentez tablosu, UI paleti
|   |   +-- audio_constants.dart       # 30+ ses dosya yolu (sfx/music)
|   |   +-- ui_constants.dart          # Font boyutlari, spacing
|   +-- utils/
|   |   +-- near_miss_detector.dart    # Shannon entropy + yerlestirme analizi
|   |   +-- color_mixer.dart           # Sentez tablosu arama (sira bagimsiz)
|   +-- extensions/
|   |   +-- color_extensions.dart      # Color yardimcilari
|   +-- l10n/
|   |   +-- app_strings.dart           # Abstract l10n base
|   |   +-- strings_{tr,en,de,zh,ja,ko,ru,es,ar,fr,hi,pt}.dart  # 12 dil
|   +-- widgets/
|       +-- glow_orb.dart              # Animasyonlu isik efekti widget
|
+-- game/
|   +-- shapes/
|   |   +-- gel_shape.dart             # GelShape (19 sekil), ShapeGenerator (Smart RNG)
|   +-- systems/
|   |   +-- color_synthesis.dart       # Bitisik renk cifti tespiti ve sentez
|   |   +-- combo_detector.dart        # ComboEvent tier'leri (1500ms pencere)
|   |   +-- score_system.dart          # Puan hesaplama
|   |   +-- powerup_system.dart        # 6 power-up tipi, cooldown, limit
|   |   +-- color_chef_levels.dart     # 50 ColorChefLevel hedef tanimi
|   +-- world/
|   |   +-- game_world.dart            # GlooGame orkestrator, 7 mod (~454 satir)
|   |   +-- grid_manager.dart          # Cell matris, satir/sutun algilama, yercekimi
|   |   +-- cell_type.dart             # CellType enum + Cell sinifi
|   +-- levels/
|   |   +-- level_data.dart            # LevelData (rows, cols, targetScore, specialCells)
|   |   +-- level_progression.dart     # 50 seviye + prosedurel uretim
|   +-- economy/
|   |   +-- currency_manager.dart      # Jel Ozu (kazanim, harcama, bakiye)
|   +-- meta/
|   |   +-- resource_manager.dart      # Barrel export (~42 satir)
|   |   |   +-- island_state.dart          # Ada yonetimi (BuildingType, Building, IslandState)
|   |   |   +-- character_state.dart       # Karakter/kostum (CostumeSlot, TalentDef, CharacterState)
|   |   |   +-- season_pass.dart           # Sezon pasi (SeasonRewardType, SeasonTier, SeasonPassState)
|   |   |   +-- quests.dart                # Gorev sistemi (QuestType, Quest, kDailyQuestPool)
|   +-- pvp/
|   |   +-- matchmaking.dart           # ELO, eslestirme, engel uretici
|   +-- physics/
|       +-- spring_physics.dart        # Spring animasyon (stiffness/damping)
|       +-- gel_deformer.dart          # Jel deformasyon (Bezier)
|
+-- audio/
|   +-- audio_manager.dart             # just_audio, 8 kanal SFX havuzu, pitch varyasyonu
|   +-- haptic_manager.dart            # 13 haptic profil
|   +-- sound_bank.dart                # Ses onbellek
|
+-- viral/
|   +-- clip_recorder.dart             # Frame buffer (stub)
|   +-- video_processor.dart           # FFmpeg pipeline (stub)
|   +-- share_manager.dart             # share_plus entegrasyonu
|
+-- services/
|   +-- analytics_service.dart         # Firebase Analytics (gloo-f7905)
|   +-- ad_manager.dart                # google_mobile_ads (test ID)
|   +-- purchase_service.dart          # in_app_purchase (7 urun)
|
+-- data/
|   +-- local/
|   |   +-- local_repository.dart      # SharedPreferences wrapper
|   |   +-- data_models.dart           # Score, UserProfile veri siniflari
|   +-- remote/
|       +-- supabase_client.dart       # Supabase config (gercek credentials)
|       +-- remote_repository.dart     # Leaderboard, daily puzzles, PvP, IAP, GDPR, meta-game
|       +-- pvp_realtime_service.dart  # Supabase Realtime (Presence + Broadcast)
|       +-- dto/                       # Veri transfer nesneleri
|           +-- daily_puzzle.dart
|           +-- leaderboard_entry.dart
|           +-- meta_state.dart
|           +-- pvp_match.dart
|           +-- redeem_result.dart
|           +-- broadcast_score.dart
|           +-- broadcast_obstacle.dart
|           +-- broadcast_game_over.dart
|
+-- providers/
|   +-- game_provider.dart             # GameState, GameNotifier
|   +-- audio_provider.dart            # Ses/haptik ayarlari
|   +-- locale_provider.dart           # Dil secimi
|   +-- pvp_provider.dart             # PvP state (duel, matchmaking)
|   +-- service_providers.dart        # Singleton service provider'lari
|   +-- user_provider.dart             # Kullanici profili, ELO
|
+-- features/
|   +-- game_screen/
|   |   +-- game_screen.dart           # Ana oyun ekrani (~398 satir, 3 mixin ile modular)
|   |   +-- game_callbacks.dart        # Oyun callback mixin'leri
|   |   +-- game_interactions.dart     # Kullanici etkilesim mixin'leri
|   |   +-- game_grid_builder.dart     # Grid widget builder mixin'i
|   |   +-- game_dialogs.dart          # Oyun icin dialog fonksiyonlari
|   |   +-- game_overlay.dart          # HUD (skor, timer, Chef progress)
|   |   +-- game_over_overlay.dart     # Oyun bitti + ikinci sans dialog
|   |   +-- game_effects.dart          # VFX efektleri (~1185 satir)
|   |   +-- gel_cell_painter.dart      # 6 katman CustomPainter (141 satir)
|   |   +-- chef_level_overlay.dart    # Color Chef seviye tamamlama
|   +-- home_screen/
|   |   +-- home_screen.dart           # 7 mod karti + meta-game bar (~329 satir, 8 module)
|   +-- onboarding/
|   |   +-- onboarding_screen.dart     # 3 adimli tutorial
|   +-- daily_puzzle/
|   |   +-- daily_puzzle_screen.dart   # Gunluk bulmaca
|   +-- settings/
|   |   +-- settings_screen.dart       # Ayarlar
|   +-- leaderboard/
|   |   +-- leaderboard_screen.dart    # Skor tablosu
|   +-- shop/
|   |   +-- shop_screen.dart           # IAP + Gloo+ abonelik
|   +-- collection/
|   |   +-- collection_screen.dart     # Nadir renk koleksiyonu
|   +-- level_select/
|   |   +-- level_select_screen.dart   # Seviye secim (5 sutun grid, 381 satir)
|   +-- pvp/
|   |   +-- pvp_lobby_screen.dart      # PvP lobi (ELO, lig, eslestirme, 537 satir)
|   |   +-- duel_result_overlay.dart   # Duello sonuc (skor karsilastirma, 274 satir)
|   +-- island/
|   |   +-- island_screen.dart         # Ada yonetimi (5 bina, 433 satir)
|   +-- character/
|   |   +-- character_screen.dart      # Karakter/kostum (yetenek agaci, 459 satir)
|   +-- season_pass/
|   |   +-- season_pass_screen.dart    # Sezon pasi (50 tier, 467 satir)
|   +-- quests/
|   |   +-- quest_overlay.dart         # Gorev sistemi (gunluk+haftalik, 475 satir)
|   +-- shared/
|       +-- section_header.dart       # Ortak SectionHeader widget

assets/
+-- audio/
|   +-- sfx/                           # 32 ASMR ses efektleri (.ogg + .m4a)
|   +-- music/                         # 4 arka plan muzigi (.mp3)
+-- images/
    +-- gel_textures/                  # Jel doku atlaslari
    +-- ui/                            # UI ikonlar
```

---

## Oyun Motoru Pipeline

`GlooGame` saf Dart orkestratordur. Her hamle asagidaki pipeline'i tetikler:

```
GameScreen._onCellTap()
  -> GlooGame.placePiece(cells, color)
      -> GridManager.place()
      -> _evaluateBoard():
          -> ColorSynthesisSystem.findSyntheses()
          -> GridManager.setCell() (sentez sonucu)
          -> Color Chef: hedef renk sayimi -> seviye tamamlaninca izgara sifirlanir
          -> GridManager.detectAndClear() (tam satir/sutun temizleme + buz kirma)
          -> GridManager.applyGravity() (gravity hucreler icin)
          -> ComboDetector.registerClear() (1500ms pencerede zincir)
          -> ScoreSystem.addLineClear()
          -> CurrencyManager.earnFromLineClear() (Jel Ozu kazanimi)
          -> PowerUpSystem.onMoveCompleted() (cooldown azalt)
          -> NearMissDetector.evaluate() (Classic/Chef/Zen)
          -> onJelEnergyEarned?.call(clearResult.totalLines) (meta-game kaynak)
      -> Level modu: hedef skor veya hamle siniri kontrolu -> onLevelComplete
  -> GlooGame.checkGameOver(handShapes)
```

### GlooGame Callback'leri

```dart
void Function(int points)? onScoreGained;
void Function(LineClearResult)? onLineClear;
void Function(ComboEvent)? onCombo;
void Function()? onGameOver;
void Function(int gelOzu)? onCurrencyEarned;
void Function(PowerUpType, PowerUpResult)? onPowerUpUsed;
void Function()? onLevelComplete;
void Function(List<(int, int)>)? onIceCracked;
void Function(List<(int, int, int, int)>)? onGravityApplied;
void Function(int amount)? onJelEnergyEarned;
```

---

## Renk Sentezi Tablosu

```dart
// core/constants/color_constants.dart

const Map<(GelColor, GelColor), GelColor> kColorMixingTable = {
  (GelColor.red,    GelColor.yellow): GelColor.orange,
  (GelColor.yellow, GelColor.blue):   GelColor.green,
  (GelColor.red,    GelColor.blue):   GelColor.purple,
  (GelColor.orange, GelColor.blue):   GelColor.brown,
  (GelColor.red,    GelColor.white):  GelColor.pink,
  (GelColor.blue,   GelColor.white):  GelColor.lightBlue,
  (GelColor.green,  GelColor.yellow): GelColor.lime,
  (GelColor.purple, GelColor.orange): GelColor.maroon,
};
```

12 renk: 4 birincil (red, yellow, blue, white) + 8 sentez. Elden yalnizca birincil renkler cikar. Sentez sonuclari sadece bitisik hucre birlesimi ile olusur. Tablo sira bagimsiz aranir.

---

## Near-Miss Algilama Algoritmasi

```dart
class NearMissDetector {
  static const double threshold = 0.85;

  NearMissEvent? evaluate(GameState state) {
    final fillRatio = state.filledCells / state.totalCells;
    final recentComboSize = state.lastComboSize;
    final colorDiversity = _calculateColorDiversity(state.grid);
    final availableMoves = _countAvailablePlacements(state);

    final score = (fillRatio * 0.4) +
        (_normalizeCombo(recentComboSize) * 0.3) +
        ((1.0 - colorDiversity) * 0.2) +
        (_normalizeMoves(availableMoves) * 0.1);

    if (score > threshold) {
      return NearMissEvent(
        score: score,
        type: score > 0.95 ? NearMissType.critical : NearMissType.standard,
      );
    }
    return null;
  }
}
```

Shannon entropy ile renk homojenlik olcumu. 0.85 esik = standard, 0.95 = critical.

---

## VFX Sistemi

7 protokol tanimli, hepsi kodlandi (emulator testi bekliyor):

### Protocol 1: Breathing Gel (GelCellPainter)
6 katmanli CustomPainter — asagidan yukari:
1. Outer Glow (alpha:0.40, blur:6)
2. Body Gradient (RadialGradient, lighten +0.42 / darken -0.25)
3. Border Stroke (white alpha:0.14)
4. Specular Highlight (%55x%30, breathing ile titresim)
5. Bottom Shadow (Bezier, darken:0.40)
6. Inner Highlight Dot

`repaint: breathAnimation` ile surekli yeniden cizim (widget rebuild yok).

### Protocol 2: Squash & Stretch + Wave Ripple
4 fazli animasyon (380ms): Anticipation -> Impact -> Overshoot -> Settle
Wave: Manhattan distance bazli gecikme, `0.03 / (1 + d*0.6)` buyukluk.

### Protocol 3: The Cascade (CellBurstEffect)
16 parcacik, Bezier trajectory (quadratic), 580ms, tier bazli renkler.

### Protocol 4: Chain Lightning (ComboEffect + ScreenShake)
Tier bazli: small=yellow spark, medium=orange glow, large=red burst, epic=purple explosion.
ScreenShake: epic=4px, large=2px.

### Protocol 5: Danger Pulse (NearMissEffect + VignettePainter)
Radyal vignette overlay (CustomPainter), "OH NO!" text, gerilim muzigi.

### Protocol 6: Color Bloom (ColorSynthesisBloomEffect)
3 katman: beyaz flas + 2 genisleyen halka + 10 parcacik.

### Protocol 7: Ambient Atmosphere (AmbientGelDroplets)
10 yuzucu damlacik, sinusoidal hareket, nefes alma boyut animasyonu, specular highlight.
Mod bazli renk: classic=cyan, zen=yesil, duel=kirmizi.

---

## Smart RNG (ShapeGenerator)

### Zorluk Egrisi
```
difficulty = min(score/5000, 0.8) + min(gamesPlayed/50, 0.2)
Maksimum: 0.95 (asla 1.0 olmaz)
```

### Sekil Agirliklari
| Zorluk | Kucuk | Orta | Buyuk |
|---|---|---|---|
| 0.0-0.3 | %60 | %30 | %10 |
| 0.3-0.7 | %30 | %40 | %30 |
| 0.7-1.0 | %10 | %30 | %60 |

### Merhamet Mekanizmasi
- 3 ardisik kayip -> zorluk x0.7
- 5 hamle temizleme yok -> kurtarici el
- Seeded modlar (Daily/Duel): deterministik el dagitimi

---

## State Management

`GameScreen` bir `GlooGame` ornegini `State` icinde dogrudan tutar. Riverpod yalnizca UI icin kullanilir:

| Provider | Icerik |
|---|---|
| `gameProvider(GameMode)` | score, status, filledCells, remainingSeconds, chefProgress |
| `audioSettingsProvider` | sfxEnabled, musicEnabled, hapticsEnabled, colorBlindMode, glooPlus |
| `sharedPreferencesProvider` | FutureProvider<SharedPreferences> |
| `localRepositoryProvider` | FutureProvider<LocalRepository> |
| `stringsProvider` | Aktif dil l10n string'leri |
| `streakProvider` | Gunluk giris serisi |
| `userProvider` | Auth, profil |
| `eloProvider` | PvP ELO puani |
| `duelProvider` | DuelState (matchId, seed, opponentScore, isBot) |

---

## Routing (GoRouter)

Sira onemli — spesifik rotalar genel `/game/:mode` rotasindan ONCE tanimlanir:

```
/                     HomeScreen (7 mod karti + meta-game bar)
/onboarding           OnboardingScreen (3 adim)
/game/level/:levelId  GameScreen (Level modu)
/game/duel            GameScreen (Duel modu)
/game/:mode           GameScreen (diger modlar)
/daily                DailyPuzzleScreen
/settings             SettingsScreen
/shop                 ShopScreen
/leaderboard          LeaderboardScreen
/collection           CollectionScreen
/levels               LevelSelectScreen
/pvp-lobby            PvpLobbyScreen
/island               IslandScreen
/character            CharacterScreen
/season-pass          SeasonPassScreen
```

---

## Performans Kurallari

1. `RepaintBoundary` ile oyun canvas ve HUD ayri layer'larda izole edilir
2. `GelCellPainter` `shouldRepaint()` yalnizca color ve borderRadius kontrol eder
3. Ses ve haptik tetiklemeleri `unawaited()` — fire-and-forget
4. Animasyon kontrolleri: `breathCtrl` surekli (2400ms), placement one-shot (380ms)
5. VFX parcacik sayisi cihaz profiline gore ayarlanabilir (high-end=16, low-end=6)
6. `Matrix4.diagonal3Values` ile transform — layout rebuild yok

---

## Veri Katmani

### Yerel (SharedPreferences)
`LocalRepository` sarmalayicisi ile:
- Skor, streak, gunluk bulmaca, discovered_colors
- Onboarding/colorblind flags
- Jel Ozu bakiyesi
- Seviye tamamlama (completedLevels, levelScores)
- Jel Enerjisi (gelEnergy, totalEarnedEnergy)
- Redeem code verileri: `redeemed_codes` (kullanilmis kodlar), `unlocked_products` (acilmis urun ID'leri)

### Uzak (Supabase)
- Leaderboard
- Daily puzzle seed'leri
- PvP eslestirme (Supabase Realtime — Presence + Broadcast)
- `redeem_codes` tablosu: Promosyon kodlari dogrulama. `RemoteRepository.redeemCode(code)` → Supabase'de kod gecerliligi, `max_uses`/`current_uses` ve `expires_at` kontrolu → basarili ise `product_ids` listesi doner

---

## Monetizasyon

- **Zen modu:** Gloo+ abonelik ile kilitli
- **AdManager:** Interstitial (4 oyunda 1), rewarded (ikinci sans), banner (home). Anti-frustration: 5dk'da 2 kayip -> reklam yok
- **PurchaseService:** 7 IAP urunu (store'da tanimlanmali)
- **Redeem Code:** ShopScreen'de kod girisi -> `RemoteRepository.redeemCode()` Supabase dogrulama -> `PurchaseService.unlockProducts()` aktivasyon -> `LocalRepository` ile lokal persist (`redeemed_codes` + `unlocked_products`)
- **Ikinci Sans:** Game over'da "Reklam Izle -> 3 Ekstra Hamle" butonu

---

## Bilinen Kisitlamalar

- `withOpacity()` yerine `withValues(alpha:)` kullanilmali (Flutter 3.41+ deprecation)
- `SwitchListTile.activeColor` yerine `activeThumbColor` (Flutter 3.31+)
- Proje yolunda non-ASCII karakter varsa `impellerc` hatasi — ASCII-safe yola kopyalanarak build edilmeli (detay: CLAUDE.md)
- Ses dosyalari: 32 SFX (.ogg + .m4a) + 4 muzik (.mp3) uretildi

---

*Bu belge CLAUDE.md ve GDD.md ile birlikte okunmalidir.*
