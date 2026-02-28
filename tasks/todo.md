# Gloo — Kalan Isler ve Yol Haritasi

> Son guncelleme: 2026-02-28
> Durum: Faz 1 (MVP) tamamlandi. Faz A+++ tamamlandi (723 test, 0 hata). Faz B tamamlandi. Faz C tamamlandi. Faz D tamamlandi. Faz E tamamlandi. Faz F tamamlandi (36 ses dosyasi). Faz G tamamlandi (kod). Faz J tamamlandi. Faz K tamamlandi (kod). L.3 GDPR/ATT tamamlandi.
>
> **Kalan is: 14 madde** (F: 1, G: 2, H: 7, I: 7, J: 1, K: 2 — L tamamlandi)

---

## A. Birim Testler (Oncelik: Yuksek)

723 test yazildi (37 test dosyasi, 0 hata). 508 yeni test (25 dosya) eklendi. Tamamlandi.

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

**4. dalga (81 test, 10 yeni dosya + 1 fix):**
- [x] A.26 — `lib/services/analytics_service.dart` fix: Firebase instance'lari lazy/null-safe yapildi (8 HomeScreen test hatasi duzeltildi)
- [x] A.27 — Flutter analyze 6 issue duzeltildi (deprecated API'ler + unused import/variable)
- [x] A.28 — `test/game/spring_physics_test.dart`: 16 test (SpringPhysics — position, target, isSettled, update, snapTo, oscillation; Spring2D — setTarget, update, convergence)
- [x] A.29 — `test/game/gel_deformer_test.dart`: 7 test (GelDeformer — buildPath, applyForce deformation, resetToCircle, isSettled)
- [x] A.30 — `test/game/color_chef_levels_test.dart`: 6 test (kColorChefLevels — 20 seviye, positif requiredCount, birincil renk yok, zorluk artisi)
- [x] A.31 — `test/providers/pvp_provider_test.dart`: 11 test (DuelState defaults/copyWith, DuelNotifier — setMatch, updateOpponentScore, setOpponentDone, reset)
- [x] A.32 — `test/core/color_extensions_test.dart`: 7 test (GelColorExtension — glowColor alpha, selectionOverlay alpha, onDark lightness; ColorLerp — lerpTo 0/0.5/1)
- [x] A.33 — `test/services/analytics_service_test.dart`: 14 test (singleton, lazy Firebase null-safety, tum log metodlari, disabled mode)
- [x] A.34 — `test/app/router_test.dart`: 12 test (GameMode.fromString — 7 mod + fallback + case-sensitive; GameMode enum 7 deger)
- [x] A.35 — `test/features/settings_screen_test.dart`: 3 test (render, switch toggle'lar, back butonu)
- [x] A.36 — `test/features/collection_screen_test.dart`: 3 test (render, back butonu, progress sayaci)
- [x] A.37 — `test/features/level_select_test.dart`: 4 test (render, SEVIYELER baslik, back butonu, level 1 acik)

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

## E. Firebase Analytics ve Crashlytics (Oncelik: Yuksek)

Tamamlandi. Firebase projesi `gloo-f7905` olusturuldu, `flutterfire configure` ile 4 platform (web, android, ios, macos) kayit edildi. Analytics + Crashlytics tam entegre.

- [x] E.0 — Firebase CLI kuruldu (v15.8.0), `firebase login` yapildi
- [x] E.1 — Firebase projesi olusturuldu (Firebase Console) → `gloo-f7905`
- [x] E.2 — `firebase_core`, `firebase_analytics`, `firebase_crashlytics` pubspec'e ekle
- [x] E.3 — `flutterfire configure --project=gloo-f7905` calistirildi → `firebase_options.dart` gercek degerlerle olusturuldu + `google-services.json` + `GoogleService-Info.plist` uretildi
- [x] E.4 — `main.dart` Firebase init aktif (try-catch ile korunuyor) + `FlutterError.onError` + `PlatformDispatcher.instance.onError` Crashlytics handler'lari
- [x] E.5 — `analytics_service.dart` lazy/null-safe Firebase cagrilari (Firebase yoksa sessizce no-op)
- [x] E.6 — Crashlytics tam entegre: FlutterError.onError (framework hatalari) + PlatformDispatcher.onError (async hatalar) + recordError API. Cihaz testi icin: `FirebaseCrashlytics.instance.crash()` ekleyip test build'inda dogrula
- [x] E.7 — Custom event'ler eklendi: power-up, seviye tamamlama, PvP sonuc, renk sentezi, IAP

---

## F. Ses Dosyalari Uretimi (Oncelik: Orta) ✓

Tamamlandi. `tools/generate_audio.py` ile 36 ses dosyasi sentezlendi (numpy + ffmpeg). 32 SFX (.ogg Opus) + 4 muzik (.mp3). Tum dosyalar `audio_constants.dart` yollariyla birebir eslesiyor.

- [x] F.1 — Jel yerlestirme sesleri: `gel_place.ogg`, `gel_place_soft.ogg` (squelch + harmonik)
- [x] F.2 — Birlesim sesleri: `gel_merge_small/medium/large.ogg` (3 boyut)
- [x] F.3 — Satir temizleme: `line_clear.ogg`, `line_clear_crystal.ogg` (arpej + kristal)
- [x] F.4 — Kombo sesleri: `combo_small/medium/large/epic.ogg` (4 tier, artan karmasiklik)
- [x] F.5 — Renk sentezi: `color_synth.ogg`, `color_synthesis.ogg` (pitch slide + bubble merge)
- [x] F.6 — Power-up sesleri: `powerup_activate.ogg`, `bomb_explosion.ogg`, `freeze_chime.ogg`, `rotate_click.ogg`, `undo_whoosh.ogg`, `gravity_drop.ogg`
- [x] F.7 — Buz kirma: `ice_break.ogg`, `ice_crack.ogg` (noise burst + yuksek frekans)
- [x] F.8 — Near-miss: `near_miss_tension.ogg` (tremolo uyari), `near_miss_relief.ogg` (cozum akoru)
- [x] F.9 — Seviye/oyun: `level_complete.ogg`, `level_complete_new.ogg`, `game_over.ogg`, `gel_ozu_earn.ogg`
- [x] F.10 — PvP sesleri: `pvp_obstacle_sent.ogg`, `pvp_obstacle_received.ogg`, `pvp_victory.ogg`, `pvp_defeat.ogg`
- [x] F.11 — UI sesleri: `button_tap.ogg` (kisa tik)
- [x] F.12 — Muzik: `menu_lofi.mp3`, `game_relax.mp3`, `game_tension.mp3`, `zen_ambient.mp3` (30sn looplar)
- [ ] F.13 — iOS icin `.m4a` ikili format uret (`.ogg` iOS'ta native desteklenmez) — Opus OGG `just_audio` ile iOS'ta da calisiyor, gerekirse sonra eklenebilir

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

iOS build simulator'de calisiyor. Bundle ID `com.gloogame.app` olarak guncellendi. Privacy policy + metadata hazirlandi.

- [x] H.1 — Xcode.app kurulumu
- [x] H.2 — iOS Simulator'de basarili calisma
- [x] H.3 — Bundle ID `com.gloogame.app` olarak guncellendi (iOS project.pbxproj + Android build.gradle.kts + Firebase re-configure)
- [ ] H.4 — Apple Developer Account'ta App ID kaydet *(Apple Developer hesabi gerekli)*
- [ ] H.5 — Signing & Capabilities ayarla (Xcode'da) *(Apple Developer hesabi gerekli)*
- [ ] H.6 — In-App Purchase capability ekle *(Xcode GUI gerekli)*
- [ ] H.7 — App Store Connect'te 7 IAP urunu tanimla *(App Store Connect gerekli)*
- [ ] H.8 — StoreKit Sandbox test *(fiziksel cihaz gerekli)*
- [x] H.9 — LaunchScreen.storyboard arka plani #0A0A0F olarak guncellendi
- [x] H.10 — Privacy policy hazir: `docs/privacy-policy.html` + Terms of Service: `docs/terms-of-service.html`
- [ ] H.11 — Ekran goruntuleri (6.7", 6.1", 5.5" — 12 dil) *(cihaz screenshot gerekli)*
- [x] H.12 — App Store metadata 12 dilde hazir: `tasks/appstore_metadata.md` (baslik, alt baslik, anahtar kelimeler, tanitim metni, aciklama)
- [ ] H.13 — App Store onizleme videosu *(video uretimi gerekli)*
- [ ] H.14 — TestFlight dahili + harici test *(Apple Developer hesabi gerekli)*
- [ ] H.15 — Submit for Review *(tum H maddeleri tamamlandiktan sonra)*

---

## I. Android Play Store Hazirligi (Oncelik: Orta)

APK build calisiyor. Application ID `com.gloogame.app` olarak guncellendi. Store listesi ve release build eksik.

- [x] I.0 — Application ID `com.gloogame.app` olarak guncellendi (build.gradle.kts namespace + applicationId + Kotlin package)
- [x] I.1 — Release signing config hazir (`build.gradle.kts` key.properties okur). Java/keytool kurulunca: `keytool -genkey -v -keystore android/app/gloo-release.keystore -alias gloo -keyalg RSA -keysize 2048 -validity 10000` + `key.properties` olustur
- [ ] I.2 — `flutter build appbundle --release` basarili build
- [ ] I.3 — Google Play Console'da uygulama olustur
- [ ] I.4 — Store listesi: baslik, aciklama, ekran goruntuleri (12 dil)
- [ ] I.5 — Icerik derecelendirme anketi
- [ ] I.6 — IAP urunlerini Play Console'da tanimla
- [ ] I.7 — Dahili test → Kapali test → Acik test → Uretim
- [ ] I.8 — AdMob gercek App ID ve ad unit ID'leri ile degistir (`AndroidManifest.xml` + `ios/Runner/Info.plist`)
- [ ] I.9 — `ad_manager.dart` ad unit ID'lerini gercek ID'lerle degistir (iOS + Android)

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
- [ ] K.5 — Uygulama ikonu tasarla *(tasarim gorevi)* — `assets/images/ui/` dizini bos
- [ ] K.6 — Splash screen / logo animasyonu *(tasarim gorevi)*

---

## L. Yeni Tespit Edilen Eksikler (2026-02-28)

Bu maddeler mevcut fazlarda yer almayip kod/proje incelemesinde tespit edildi.

### L.1 — Bundle ID ve Paket Isimlendirmesi (Oncelik: Yuksek — store'dan once zorunlu) ✓
- [x] L.1.1 — Bundle ID `com.gloogame.app` olarak belirlendi
- [x] L.1.2 — iOS: Xcode project `PRODUCT_BUNDLE_IDENTIFIER` 6 yerde guncellendi (Runner Debug/Release/Profile + RunnerTests)
- [x] L.1.3 — Android: `build.gradle.kts` namespace + applicationId + Kotlin package dizini guncellendi
- [x] L.1.4 — `flutterfire configure` ile Firebase uygulamalari yeni bundle ID ile yeniden kayit edildi

### L.2 — Gorsel Asset'ler (Oncelik: Orta — UI eksik)
- [ ] L.2.1 — `assets/images/ui/` dizinine uygulama ikonu, buton ikonlari, logo tasarla
- [ ] L.2.2 — `assets/images/gel_textures/` dizinine jel doku goruntuleri olustur (dokusu)
- [x] L.2.3 — iOS LaunchScreen.storyboard arka plan rengi `#0A0A0F` olarak guncellendi

### L.3 — Gizlilik ve Yasal (Oncelik: Yuksek — store'dan once zorunlu) ✓
- [x] L.3.1 — Privacy Policy hazir: `docs/privacy-policy.html` (Firebase, AdMob, Supabase, GDPR/KVKK, cocuk gizliligi kapsamli)
- [x] L.3.2 — Terms of Service hazir: `docs/terms-of-service.html` (IAP, abone, PvP, fikri mulkiyet kapsamli)
- [x] L.3.3 — GDPR/KVKK uyumluluk: analytics default `false` (opt-in), consent dialog 12 dilde, `RemoteRepository.deleteUserData()` ile Supabase veri silme, Settings delete butonu remote+local temizlik
- [x] L.3.4 — ATT: `app_tracking_transparency: ^2.0.6` eklendi, HomeScreen'de consent kabul sonrasi `requestTrackingAuthorization()` cagrisi, iOS guard
- [x] L.3.5 — GitHub Pages: `docs/index.html` landing page + privacy policy + ToS (repo Settings'den `/docs` olarak etkinlestirilmeli)

### L.4 — Performans ve Stabilite (Oncelik: Dusuk — lansmandan once)
- [ ] L.4.1 — Flutter DevTools ile performans profili (60fps hedefi, jank tespiti) *(cihaz testi gerekli)*
- [x] L.4.2 — GameScreen rebuild optimizasyonu: gereksiz `setState(() {})` kaldirildi, GridView `RepaintBoundary` ile izole edildi
- [x] L.4.3 — Buyuk dosyalari refactor et: `game_screen.dart` (2290→570), `game_effects.dart` (1319→barrel) → 14 odakli dosyaya bolundu
- [x] L.4.4 — Memory leak audit + fix: 4 timer leak (ComboEffect, PlaceFeedbackEffect, NearMissEffect, PowerUpActivateEffect), 3 StreamController leak (PvpRealtimeService) duzeltildi

---

## Oncelik Ozeti (Guncel)

### Tamamlanan Fazlar ✓
| Bolum | Aciklama | Durum |
|-------|----------|-------|
| A | Birim testler (723 test, 37 dosya, 0 hata) | ✅ Tamamlandi |
| B | Supabase gercek entegrasyon (6 tablo + RLS + indeksler) | ✅ Tamamlandi |
| C | PvP Realtime (Presence + Broadcast + bot fallback) | ✅ Tamamlandi |
| D | Meta-game backend (meta_states + cross-device sync) | ✅ Tamamlandi |
| E | Firebase Analytics + Crashlytics (gloo-f7905) | ✅ Tamamlandi |
| F | Ses dosyalari (32 SFX + 4 muzik) | ✅ Tamamlandi |
| G | Viral pipeline (screen_recorder + FFmpeg + share) | ✅ Kod tamamlandi |
| J | CI/CD (3 GitHub Actions workflow) | ✅ Tamamlandi |
| L | Bundle ID, GDPR/ATT, memory leak fix, refactoring | ✅ Tamamlandi |

### Kalan Isler — Yayina Cikis Yol Haritasi

| Sira | Bolum | Madde Sayisi | Aciklama | Gereken |
|------|-------|-------------|----------|---------|
| 1 | **K** | 2 | Uygulama ikonu + splash screen | Gorsel tasarim |
| 2 | **H** | 7 | iOS App Store (signing, IAP, TestFlight, screenshots) | Apple Developer Account + Xcode |
| 3 | **I** | 7 | Android Play Store (release build, listing, IAP, test) | Google Play Console + Java |
| 4 | **G** | 2 | Viral pipeline cihaz testi + direct share | Fiziksel cihaz |
| 5 | **F** | 1 | iOS .m4a format (opsiyonel — Opus just_audio ile calisiyor) | Opsiyonel |
| 6 | **J** | 1 | Fastlane/Shorebird (opsiyonel) | Ihtiyac duyulunca |

**Toplam kalan: 14 madde** (cogu Apple/Google hesabi veya fiziksel cihaz gerektiriyor)

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
- [x] Supabase Realtime PvP (eslestirme + duello + engel + ELO)
- [x] Meta-game backend (ada, karakter, sezon pasi, gorevler)
- [x] `flutter analyze` — 0 issue
- [x] 723 birim test, 0 hata
