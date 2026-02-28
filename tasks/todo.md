# Gloo — Kalan Isler ve Yol Haritasi

> Son guncelleme: 2026-02-27
> Durum: Faz 1 (MVP) tamamlandi. Faz B kod entegrasyonu tamamlandi (gercek Supabase projesi bekliyor). Faz C tamamlandi. Faz E kismi.

---

## A. Birim Testler (Oncelik: Yuksek)

222 test yazildi (9 birim + 3 widget test dosyasi). Tamamlandi.

- [x] A.1 — `test/game/grid_manager_test.dart`: 54 test (yerlestirme, satir/sutun temizleme, gravity, buz kirma, clearArea, undo, Cell sinifi)
- [x] A.2 — `test/game/color_synthesis_test.dart`: 12 test (yatay/dikey sentez, 8 tablo girisi, sira bagimsizlik, applySynthesis)
- [x] A.3 — `test/core/near_miss_detector_test.dart`: 9 test (esik degerleri, critical/standard siniflar, faktor agirliklari)
- [x] A.4 — `test/core/color_mixer_test.dart`: 19 test (8 cift + ters sira, mixChain, isSecondaryColor, findRecipes)
- [x] A.5 — `test/game/score_system_test.dart`: 22 test (skor formulu, kombo carpanlari, ComboDetector tier'leri)
- [x] A.6 — `test/game/shape_generator_test.dart`: 26 test (GelShape, seeded deterministik, getDifficulty, merhamet)
- [x] A.7 — `test/game/level_progression_test.dart`: 32 test (50 seviye, prosedurel 51+, breathing room, LevelData, MapShape)
- [x] A.8 — `test/game/currency_manager_test.dart`: 26 test (kazanim, harcama, callback, CurrencyCosts)
- [x] A.9 — `test/features/`: 22 widget test (HomeScreen 9, OnboardingScreen 6, GameOverlay 8 — mod kartlari, HUD, streak, lock)

---

## B. Backend — Supabase Gercek Entegrasyon (Oncelik: Yuksek)

Kod tarafı tamamlandı. `supabase_client.dart` isConfigured guard'ı eklendi, tüm remote metodlar placeholder'da sessizce atlar. SQL şeması ve RLS hazır. Supabase projesi oluşturulup gerçek anahtarlar girildiğinde test edilebilir.

- [x] B.2 — Veritabani semasini deploy et: `supabase/schema.sql` (6 tablo + RLS + indeksler)
- [x] B.3 — RLS politikalarini uygula (`supabase/schema.sql` icinde)
- [x] B.9 — `pvp_matches` ve `pvp_obstacles` tablolarini olustur (`supabase/schema.sql`)
- [x] B.10 — PvP tablolari icin RLS politikalarini uygula
- [x] B.11 — `supabase_client.dart` isConfigured guard + otomatik profil olusturma
- [x] B.12 — `remote_repository.dart` tum metodlara isConfigured guard eklendi
- [x] B.13 — GameScreen onGameOver'da backend skor submit + daily submit eklendi
- [x] B.14 — Duel sonucunda backend ELO + PvP istatistik + mac sonucu gonderimi eklendi
- [ ] B.1 — Supabase projesi olustur (supabase.com dashboard) *(manuel)*
- [ ] B.4 — `supabase_client.dart`'ta gercek URL ve anonKey'i doldur *(manuel)*
- [ ] B.5 — Anonim auth akisini test et (signInAnonymously → profile olusturma) *(gercek proje gerekli)*
- [ ] B.6 — Leaderboard'u gercek veriyle test et *(gercek proje gerekli)*
- [ ] B.7 — Daily puzzle backend entegrasyonu test et *(gercek proje gerekli)*
- [ ] B.8 — Redeem code akisini test et *(gercek proje gerekli)*

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

## D. Meta-Game Backend Entegrasyonu (Oncelik: Orta)

UI ekranlari yazildi (island, character, season_pass, quests). `ResourceManager` lokal. Backend persist yok.

- [ ] D.1 — `ResourceManager` state'ini Supabase'e persist et (jel enerjisi, bina seviyeleri)
- [ ] D.2 — Karakter/kostum kilitleri backend'de tutulsin
- [ ] D.3 — Sezon pasi ilerlemesini backend ile senkronize et
- [ ] D.4 — Gunluk/haftalik gorev tanimlarini backend'den cek (su an sabit)
- [ ] D.5 — Cross-device senkronizasyon testi (ayni hesap, farkli cihaz)

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

## G. Viral Pipeline (Oncelik: Dusuk)

ClipRecorder state machine'i var ama gercek frame capture yok. VideoProcessor tamamen stub.

- [ ] G.1 — `screen_recorder` paketini pubspec'e ekle + platform uyumluluk kontrolu
- [ ] G.2 — `clip_recorder.dart`: yorum satirlarini ac (_beginCapture, _finalizeClip, dispose)
- [ ] G.3 — `ffmpeg_kit_flutter_full_gpl` paketini pubspec'e ekle (web uyumsuz — platform guard)
- [ ] G.4 — `video_processor.dart`: FFmpeg komut pipeline'ini aktiflestir (slow-mo, filigran, LUT)
- [ ] G.5 — `share_manager.dart`: `shareVideo()` XFile dalini ac
- [ ] G.6 — End-to-end test: near-miss → kayit → isleme → paylasim akisini dogrula
- [ ] G.7 — TikTok/Instagram direct share arastir (`social_share` paketi?)

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

## J. CI/CD Pipeline (Oncelik: Dusuk)

Hicbir otomasyon yok.

- [ ] J.1 — GitHub Actions: `flutter analyze` + `flutter test` PR check
- [ ] J.2 — GitHub Actions: Android APK/AAB build (push to main)
- [ ] J.3 — GitHub Actions: iOS build (Xcode Cloud veya self-hosted runner)
- [ ] J.4 — Fastlane veya Shorebird entegrasyonu (opsiyonel)

---

## K. Kod Kalitesi ve Polish (Oncelik: Dusuk)

- [ ] K.1 — Renk sentezi gorsel animasyonu: `applySynthesis()` `_evaluateBoard()`'dan cagrilmiyor (GDD 1.2 notu)
- [ ] K.2 — `isar_schema.dart` adi yaniltici — dosyayi `data_models.dart` olarak yeniden adlandir
- [ ] K.3 — README.md platform durumunu guncelle (iOS eklendi, Flutter 3.41.2)
- [ ] K.4 — GDD.md Faz Durumu checklistini guncelle (mevcut ilerlemeyi yansitsin)
- [ ] K.5 — Uygulama ikonu tasarla (GDD 2.2 konseptine gore)
- [ ] K.6 — Splash screen / logo animasyonu (GDD 1.5 — jel kapsul birlesmesi)

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
