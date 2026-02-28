# Gloo — Kalan Isler ve Yol Haritasi

> Son guncelleme: 2026-02-28
> Durum: Faz 1 (MVP) tamamlandi. Faz A++ tamamlandi (634 test). Faz B tamamlandi. Faz C tamamlandi. Faz D tamamlandi. Faz E kismi. Faz G tamamlandi (kod). Faz J tamamlandi. Faz K tamamlandi (kod).

---

## A. Birim Testler (Oncelik: Yuksek)

634 test yazildi (27 test dosyasi). 427 yeni test (15 dosya) eklendi. Tamamlandi.

**Onceki (222 test, 12 dosya):**
- [x] A.1 — `test/game/grid_manager_test.dart`: 54 test (yerlestirme, satir/sutun temizleme, gravity, buz kirma, clearArea, undo, Cell sinifi)
- [x] A.2 — `test/game/color_synthesis_test.dart`: 12 test (yatay/dikey sentez, 8 tablo girisi, sira bagimsizlik, applySynthesis)
- [x] A.3 — `test/core/near_miss_detector_test.dart`: 9 test (esik degerleri, critical/standard siniflar, faktor agirliklari)
- [x] A.4 — `test/core/color_mixer_test.dart`: 19 test (8 cift + ters sira, mixChain, isSecondaryColor, findRecipes)
- [x] A.5 — `test/game/score_system_test.dart`: 22 test (skor formulu, kombo carpanlari, ComboDetector tier'leri)
- [x] A.6 — `test/game/shape_generator_test.dart`: 26 test (GelShape, seeded deterministik, getDifficulty, merhamet)
- [x] A.7 — `test/game/level_progression_test.dart`: 32 test (50 seviye, prosedurel 51+, breathing room, LevelData, MapShape)
- [x] A.8 — `test/game/currency_manager_test.dart`: 26 test (kazanim, harcama, callback, CurrencyCosts)
- [x] A.9 — `test/features/`: 22 widget test (HomeScreen 9, OnboardingScreen 6, GameOverlay 8 — mod kartlari, HUD, streak, lock)

**2. dalga (305 test, 11 dosya):**
- [x] A.10 — `test/game/game_world_test.dart`: 53 test (GlooGame — startGame, placePiece, checkGameOver, pause/resume, continueWithExtraMoves, generateNextHand, power-up entegrasyonu, callback'ler, freeze, currentChefLevel)
- [x] A.11 — `test/game/powerup_system_test.dart`: 33 test (PowerUpSystem — canUse, rotate, bomb, peek, undo, rainbow, freeze, cooldown decay, recordPlacement, reset, grantFreePowerUp)
- [x] A.12 — `test/game/matchmaking_test.dart`: 44 test (EloLeague, EloSystem, ObstacleGenerator, MatchmakingManager, AsyncDuelState, MatchResult, DuelResult)
- [x] A.13 — `test/game/resource_manager_test.dart`: 38 test (ResourceManager, IslandState, Building, CharacterState, SeasonPassState, Quest tanimlari)
- [x] A.14 — `test/game/level_system_test.dart`: 26 test (LevelData, MapShape, LevelProgression — 50 oncetanimli, prosedurel, breathing room, CellConfig)
- [x] A.15 — `test/core/constants_test.dart`: 33 test (GameConstants, GelColor, kColorMixingTable, kPrimaryColors, UI palette, CurrencyCosts)
- [x] A.16 — `test/game/cell_type_test.dart`: 17 test (CellType enum, Cell — isEmpty, canAccept, crackIce, clearColor, copy, toString)
- [x] A.17 — `test/game/combo_detector_test.dart`: 8 test (ComboTier, ComboEvent, ComboDetector — tier eskalasyonu, zincir birikimi, reset)
- [x] A.18 — `test/data/data_models_test.dart`: 5 test (Score, UserProfile — constructor, varsayilan degerler, mutability)
- [x] A.19 — `test/core/l10n_test.dart`: 25 test (AppStrings.forLocale — 12 dil, fallback, string completeness)
- [x] A.20 — `test/game/gel_shape_test.dart`: 23 test (GelShape — boyutlar, at(), rotated(), kAllShapes, shape kategorileri, ShapeGenerator — seeded, difficulty, mercy)

**3. dalga (122 test, 4 yeni dosya + 1 guncelleme):**
- [x] A.21 — `test/core/constants_test.dart` guncellendi: +10 test (AudioPaths SFX/Music yol dogrulama, AudioConfig volume/pitch, UIConstants radius skalasi ve padding) → toplam 43 test
- [x] A.22 — `test/data/local_repository_test.dart`: 70 test (HighScore, Profile, Onboarding, Colorblind, Analytics, GDPR clearAllData, Streak, DiscoveredColors, DailyPuzzle, GelOzu, GelEnergy, Level ilerleme, GameStats, PvP/ELO, IslandState, CharacterState, SeasonPassState, DailyQuestProgress, RedeemCodes, UnlockedProducts)
- [x] A.23 — `test/providers/game_provider_test.dart`: 18 test (GameState defaults/copyWith, GameNotifier tum update metodlari, reset, bagimsiz mod state)
- [x] A.24 — `test/providers/audio_provider_test.dart`: 15 test (AudioSettings defaults/copyWith, AudioSettingsNotifier toggle/set metodlari — colorBlind, analytics, glooPlus, adsRemoved)
- [x] A.25 — `test/providers/locale_provider_test.dart`: 9 test (kLanguageOptions 12 dil/benzersiz kodlar, LocaleNotifier setLocale)

---

## B. Backend — Supabase Gercek Entegrasyon (Oncelik: Yuksek)

Tamamlandi. Supabase projesi olusturuldu, gercek anahtarlar girildi, 6 tablo + 15 RLS + indeksler deploy edildi. Tum akislar end-to-end test edildi.

- [x] B.1 — Supabase projesi olusturuldu (`lcumiadyvwharxhrbtkm`)
- [x] B.2 — Veritabani semasini deploy et: `supabase/schema.sql` (6 tablo + RLS + indeksler)
- [x] B.3 — RLS politikalarini uygula (`supabase/schema.sql` icinde)
- [x] B.4 — `supabase_client.dart`'ta gercek URL ve anonKey dolduruldu
- [x] B.5 — Anonim auth akisi test edildi (signInAnonymously → profile olusturma)
- [x] B.6 — Leaderboard gercek veriyle test edildi (scores JOIN profiles → username)
- [x] B.7 — Daily puzzle backend entegrasyonu test edildi (upsert + sorgulama)
- [x] B.8 — Redeem code akisi test edildi (kod dogrulama + current_uses artirimi)
- [x] B.9 — `pvp_matches` ve `pvp_obstacles` tablolarini olustur (`supabase/schema.sql`)
- [x] B.10 — PvP tablolari icin RLS politikalarini uygula
- [x] B.11 — `supabase_client.dart` isConfigured guard + otomatik profil olusturma
- [x] B.12 — `remote_repository.dart` tum metodlara isConfigured guard eklendi
- [x] B.13 — GameScreen onGameOver'da backend skor submit + daily submit eklendi
- [x] B.14 — Duel sonucunda backend ELO + PvP istatistik + mac sonucu gonderimi eklendi

---

## C. PvP Realtime Entegrasyonu (Oncelik: Orta) ✓

Tamamlandi. Realtime eslestirme, duello senkronizasyonu, engel gondermesi, bot fallback, ELO hesaplama.

- [x] C.1 — Supabase Realtime channel yapisi tasarla → `pvp_realtime_service.dart`
- [x] C.2 — `Matchmaking` sinifini Realtime ile entegre et → `pvp_lobby_screen.dart`
- [x] C.3 — Asenkron duello state senkronizasyonu → `broadcastScore`, `listenOpponentScore`
- [x] C.4 — `ObstacleGenerator` engel gondermesini Realtime uzerinden ilet → `sendObstacle`, `listenOpponentObstacles`
- [x] C.5 — ELO guncelleme mantigi backend'e tasi → `supabase/functions/calculate-elo/index.ts`
- [x] C.6 — Bot fallback → `_initBotSimulation()` (skor simülasyonu, 30sn timeout)
- [x] C.7 — `pvp_realtime_service.dart` olustur (Presence + Broadcast)
- [x] C.8 — `remote_repository.dart`'a PvP metodlarini ekle
- [x] C.9 — Supabase Edge Function yazildi: `calculate-elo/index.ts`
- [x] C.10 — Bot fallback realtime servis ile entegre edildi
- [x] C.11 — GameScreen duel modu realtime entegrasyonu (skor broadcast, engel gonder/al, DuelResultOverlay)
- [x] C.12 — GameOverlay'e duel HUD eklendi (geri sayim cubugu + rakip skoru)
- [x] C.13 — Router duel parametreleri (matchId, seed, isBot query params)
- [x] C.14 — PvP Riverpod provider'lari (duelProvider, pvpRealtimeServiceProvider)
- [x] C.15 — GridManager.applyRandomObstacle (rakipten gelen engelleri uygula)

---

## D. Meta-Game Backend Entegrasyonu (Oncelik: Orta) ✓

Tamamlandi. `meta_states` tablosu (7 JSONB/int kolon + RLS) deploy edildi. Tum ekranlar local-first + async backend sync ile entegre edildi.

- [x] D.1 — `ResourceManager` state'ini Supabase'e persist et → `meta_states` tablosu (gel_energy, total_earned_energy, island_state JSONB)
- [x] D.2 — Karakter/kostum kilitleri backend'de → `meta_states.character_state` JSONB (kostumler, yetenekler, equipment)
- [x] D.3 — Sezon pasi ilerlemesini backend ile senkronize et → `meta_states.season_pass_state` JSONB (xp, free_tier, premium_tier)
- [x] D.4 — Gorev ilerlemesini backend'e sync et → `meta_states.quest_progress` JSONB + `quest_date` (gorev tanimlari lokal sabit, ilerleme backend sync)
- [x] D.5 — Cross-device senkronizasyon → local-first + backend override pattern, end-to-end test basarili
- [x] D.6 — `remote_repository.dart`'a `saveMetaState()` ve `loadMetaState()` eklendi
- [x] D.7 — `supabase/schema.sql` guncellendi (meta_states tablo + RLS)
- [x] D.8 — GameScreen `onJelEnergyEarned` callback'ine backend enerji sync eklendi

---

## E. Firebase Analytics ve Crashlytics (Oncelik: Orta)

Firebase paketleri eklendi, kod yazildi. `flutterfire configure` ve Firebase Console kurulumu gerekli.

- [ ] E.0 — Firebase CLI kur (`curl -sL https://firebase.tools | bash`) + `firebase login`
- [ ] E.1 — Firebase projesi olustur (Firebase Console) → `gloo-d3dd8`
- [x] E.2 — `firebase_core`, `firebase_analytics`, `firebase_crashlytics` pubspec'e ekle
- [ ] E.3 — `flutterfire configure --project=gloo-d3dd8` calistir → `firebase_options.dart` olusturulur
- [x] E.4 — `main.dart`'taki Firebase init yorum satirlarini ac + Crashlytics error handler
- [x] E.5 — `analytics_service.dart` gercek Firebase cagrilari ile guncellendi
- [ ] E.6 — Crashlytics'i test et (kasti crash → dashboard'da gorunurluk)
- [x] E.7 — Custom event'ler eklendi: power-up, seviye tamamlama, PvP sonuc, renk sentezi, IAP

---

## F. Ses Dosyalari Uretimi (Oncelik: Orta)

`audio_constants.dart`'ta 30+ ses yolu tanimli. Hicbir OGG/M4A dosyasi uretilmedi.

- [ ] F.1 — Jel yerlestirme sesleri: `gel_place_1/2/3.ogg` (squelch varyantlari)
- [ ] F.2 — Birlesim sesleri: `merge_1/2/3.ogg` (slime merge, reverb)
- [ ] F.3 — Patlama sesleri: `burst_1/2/3.ogg` (kristal pop kaskati)
- [ ] F.4 — Kombo sesleri: `combo_small/medium/large/epic.ogg` (4 tier)
- [ ] F.5 — Renk sentezi: `color_synthesis.ogg` (derin harmonik)
- [ ] F.6 — Power-up sesleri: `powerup_activate.ogg`, `powerup_bomb.ogg`, `powerup_rainbow.ogg`, `powerup_freeze.ogg`
- [ ] F.7 — Buz kirma: `ice_crack_1/2.ogg`
- [ ] F.8 — Near-miss: `near_miss_warning.ogg`, `near_miss_resolve.ogg`
- [ ] F.9 — Seviye/oyun: `level_complete.ogg`, `game_over.ogg`
- [ ] F.10 — PvP sesleri: `pvp_match_found.ogg`, `pvp_obstacle_sent/received.ogg`, `pvp_win/lose.ogg`
- [ ] F.11 — UI sesleri: `button_tap.ogg`, `menu_transition.ogg`
- [ ] F.12 — Muzik: `music_classic.ogg`, `music_zen.ogg`, `music_timetrial.ogg` (loop)
- [ ] F.13 — iOS icin `.m4a` ikili format uret (`.ogg` iOS'ta native desteklenmez)

---

## G. Viral Pipeline (Oncelik: Dusuk) ✓

Tamamlandi. `screen_recorder` + `ffmpeg_kit_flutter_full_gpl` paketleri eklendi. Frame capture, FFmpeg video isleme ve XFile paylasim aktif.

- [x] G.1 — `screen_recorder: ^0.3.0` pubspec'e eklendi
- [x] G.2 — `clip_recorder.dart`: RepaintBoundary frame capture + PNG dizisi + FFmpeg pipeline aktif
- [x] G.3 — `ffmpeg_kit_flutter_full_gpl: ^6.0.3` pubspec'e eklendi (web'de kIsWeb guard)
- [x] G.4 — `video_processor.dart`: FFmpeg komut pipeline aktif (slow-mo 0.5x, saturation 1.3, contrast 1.1, filigran opsiyonel)
- [x] G.5 — `share_manager.dart`: `shareVideo()` XFile + Share.shareXFiles aktif
- [ ] G.6 — End-to-end test: near-miss → kayit → isleme → paylasim akisini dogrula *(cihaz testi gerekli)*
- [ ] G.7 — TikTok/Instagram direct share arastir *(gelecek iterasyon)*

---

## H. iOS App Store Hazirligi (Oncelik: Orta)

iOS build simulator'de calisiyor. Gercek cihaz ve store icin eksikler var.

- [x] H.1 — Xcode.app kurulumu
- [x] H.2 — iOS Simulator'de basarili calisma
- [ ] H.3 — Bundle ID belirle ve Xcode project'te guncelle (com.example.gloo → gercek ID)
- [ ] H.4 — Apple Developer Account'ta App ID kaydet
- [ ] H.5 — Signing & Capabilities ayarla (Xcode'da)
- [ ] H.6 — In-App Purchase capability ekle
- [ ] H.7 — App Store Connect'te 7 IAP urunu tanimla
- [ ] H.8 — StoreKit Sandbox test
- [ ] H.9 — LaunchScreen.storyboard arka planini #0A0A0F yap (Xcode'da)
- [ ] H.10 — Privacy policy hazirla (URL gerekli)
- [ ] H.11 — Ekran goruntuleri (6.7", 6.1", 5.5" — 12 dil)
- [ ] H.12 — App Store metadata (baslik, aciklama, anahtar kelimeler — 12 dil)
- [ ] H.13 — App Store onizleme videosu
- [ ] H.14 — TestFlight dahili + harici test
- [ ] H.15 — Submit for Review

---

## I. Android Play Store Hazirligi (Oncelik: Orta)

APK build calisiyor. Store listesi ve release build eksik.

- [ ] I.1 — Release signing key olustur (keystore)
- [ ] I.2 — `flutter build appbundle --release` basarili build
- [ ] I.3 — Google Play Console'da uygulama olustur
- [ ] I.4 — Store listesi: baslik, aciklama, ekran goruntuleri (12 dil)
- [ ] I.5 — Icerik derecelendirme anketi
- [ ] I.6 — IAP urunlerini Play Console'da tanimla
- [ ] I.7 — Dahili test → Kapali test → Acik test → Uretim
- [ ] I.8 — AdMob gercek App ID ve ad unit ID'leri ile degistir

---

## J. CI/CD Pipeline (Oncelik: Dusuk) ✓

Tamamlandi. 3 GitHub Actions workflow olusturuldu.

- [x] J.1 — `flutter_ci.yml`: `flutter analyze` + `flutter test --coverage` + `dart format` (PR + push to main)
- [x] J.2 — `android_build.yml`: Debug APK + Release AAB build (push to main, Java 17)
- [x] J.3 — `ios_build.yml`: iOS build `--no-codesign` (push to main, macos-latest)
- [ ] J.4 — Fastlane veya Shorebird entegrasyonu *(opsiyonel — ihtiyac duyulunca)*

---

## K. Kod Kalitesi ve Polish (Oncelik: Dusuk)

- [x] K.1 — Renk sentezi gorsel animasyonu: `onColorSynthesis` callback + `ColorSynthesisBloomEffect` overlay entegre edildi
- [x] K.2 — `isar_schema.dart` → `data_models.dart` olarak yeniden adlandirildi (import'lar guncellendi)
- [x] K.3 — README.md platform durumu guncellendi (iOS + Flutter 3.41.2 + faz durumlari)
- [x] K.4 — GDD.md Faz Durumu checklisti guncellendi (Faz 1-3 tamamlandi, Faz 4 kaldi)
- [ ] K.5 — Uygulama ikonu tasarla *(tasarim gorevi)*
- [ ] K.6 — Splash screen / logo animasyonu *(tasarim gorevi)*

---

## Oncelik Ozeti

| Oncelik | Bolum | Aciklama |
|---------|-------|----------|
| **Yuksek** | A | Birim testler — refactoring ve yeni ozellikler icin guvenlik agi |
| **Yuksek** | B | Supabase gercek entegrasyon — leaderboard, daily, redeem code |
| **Orta** | C | PvP Realtime — ana diferansiyator |
| **Orta** | D | Meta-game backend — retention mekanizmasi |
| **Orta** | E | Firebase Analytics/Crashlytics — metrik takibi |
| **Orta** | F | Ses dosyalari — ASMR deneyiminin cekirdegi |
| **Orta** | H, I | Store hazirligi — yayina cikis yolu |
| **Dusuk** | G | Viral pipeline — TikTok paylasim altyapisi |
| **Dusuk** | J | CI/CD — otomasyon |
| **Dusuk** | K | Kod kalitesi ve polish |

---

## Tamamlanan Buyuk Maddeler (Referans)

- [x] Faz 1 MVP: 7 oyun modu, izgara mekanigi, renk sentezi, skor, kombo, power-up, l10n (12 dil)
- [x] 14 feature ekrani UI (game, home, onboarding, daily, settings, leaderboard, shop, collection, levels, pvp, island, character, season_pass, quests)
- [x] 7 VFX protokolu kodlandi (breathing gel, squash & stretch, cascade, chain lightning, danger pulse, color bloom, ambient atmosphere)
- [x] Smart RNG + merhamet mekanizmasi
- [x] 50 seviye + prosedurel uretim
- [x] 6 ozel hucre tipi (ice, locked, stone, gravity, rainbow)
- [x] AdMob entegrasyonu (test ID'leri — interstitial, rewarded, banner + loss aversion tetikleyicileri)
- [x] IAP urun tanimlari (7 urun) + redeem code sistemi (lokal)
- [x] HapticManager (13 profil, tam implementasyon)
- [x] Spring physics + gel deformer (tam implementasyon)
- [x] iOS build + simulator calisiyor (Xcode 26.3, iOS 26.2)
- [x] Near-miss algilama (Shannon entropy)
- [x] AudioManager + iOS audio session (ambient)
- [x] ShareManager metin paylasimi (share_plus)
- [x] `flutter analyze` — 0 issue
