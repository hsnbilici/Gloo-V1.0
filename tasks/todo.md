# Gloo v1.0 — Yol Haritasi

> Son guncelleme: 2026-03-01
> **Durum:** Sprint 7 TAMAMLANDI | flutter analyze: 0 issue | flutter test: 1013/1013
> **Kalan:** 12 madde (0 yurutulebilir, 12 harici bagimlilk) | Tamamlanan fazlar: 18 (A-R)
> **Oncelik:** Store hazirligi → Harici bagimlilklar

---

## Sprint 7 — Kod Kalitesi & Guvenlik (TAMAMLANDI)

> 8 yurutulebilir gorev tamamlandi, 12 harici bagimlilk (atlanacak)

### Batch 1 (Paralel — bagimsiz gorevler)
- [x] M.1 — GameScreen parcalama (UI/UX) — 999→398 satir, 3 mixin + dialog refactor
- [x] H.1 — Redeem code per-user (Backend) — RedeemResult sealed class + Edge Function auth
- [x] M.4 — PvP seed server-side (Backend) — createPvpMatch seed kaldirildi, generateBotMatchSeed eklendi
- [x] M.6 — Android AD_ID privacy metadata (DevOps) — AndroidManifest AD_ID + iOS PrivacyInfo.xcprivacy

### Batch 2 (Paralel — Batch 1 sonrasi)
- [x] M.2 — Features→Provider gecisi (Developer) — 12 feature dosyasi provider'a gecti, remoteRepositoryProvider eklendi
- [x] M.5 — GDPR silme dogrulama (Backend) — deleteUserData→bool, 12 dil x 5 string
- [x] L.1 — Viral pipeline testleri (QA) — 3 dosya, 61 test
- [x] L.2 — Quest/Dialog testleri (QA) — 2 dosya, 48 test

### Final
- [x] QA entegrasyon: flutter analyze (0 issue) + flutter test (1013/1013 PASS)
- [x] Security Audit: 0 CRITICAL, 1 HIGH, 4 MEDIUM bulgu (detay: `tasks/qa-report.md`)

---

## Kalan Gorevler — Oncelik Sirasina Gore

### CRITICAL — Uretime Gecis Oncesi Zorunlu

- [ ] C.1 — **Firebase API key kisitlamalari** — Google Cloud Console'dan HTTP referrer + bundle ID kisitlamasi ekle. `firebase_options.dart`'taki key'ler her platformda restrict edilmeli.
  - Ajan: Security | Harici: Google Cloud Console
  - Kabul: API key'ler yalnizca `com.gloogame.app` bundle ID'den erisilebilir

- [ ] C.2 — **AdMob test ID → gercek ID degisimi** — Android (`AndroidManifest.xml`) ve iOS (`Info.plist`) icindeki `ca-app-pub-3940256099942544~3347511713` test ID'sini gercek AdMob App ID ile degistir. `ad_manager.dart`'taki ad unit ID'leri de guncelle.
  - Ajan: DevOps | Harici: AdMob Console
  - Kabul: Tum platformlarda gercek AdMob ID'leri aktif

- [ ] C.3 — **Android release signing** — Release keystore olustur, `key.properties` yapilandir, CI workflow'a signing secret'lari ekle.
  - Ajan: DevOps | Harici: Keystore + CI secrets
  - Kabul: `flutter build appbundle --release` basarili

### HIGH — Store Submission Icin Gerekli

- [x] S7-SEC-1 — **PvP seed INTEGER overflow** — ~~Migration'a `ALTER COLUMN seed TYPE BIGINT` eklendi. Microsecond epoch 64-bit olarak guvenle saklanir.~~
  - Ajan: Backend | Kaynak: Security Audit S7-SEC-1
  - Kabul: PvP mac olusturma INSERT basarili, seed BIGINT tipinde

- [x] H.1 — **Redeem code per-user limitasyonu** — ~~Sprint 7'de tamamlandi~~ (RedeemResult sealed class + Edge Function per-user guard)

- [ ] H.2 — **Android payment verification** — `verify-purchase/index.ts` Edge Function'da Android icin Google Play Developer API entegrasyonu eksik. Simdilik sadece temel JSON format kontrol var.
  - Ajan: Backend | Harici: Google Play Developer API key
  - Kabul: Android receipt'leri Google API ile dogrulanir

- [ ] H.3 — **iOS App Store hazirligi** — Apple Developer Account + signing + IAP + TestFlight
  - Ajan: DevOps | Harici: Apple Developer Account ($99/yil) + Xcode + cihaz
  - Alt gorevler:
    - [ ] App ID kaydet (`com.gloogame.app`)
    - [ ] Signing & Capabilities (Development + Distribution)
    - [ ] In-App Purchase capability + 7 IAP urunu tanimla
    - [ ] StoreKit Sandbox test (fiziksel cihaz)
    - [ ] Ekran goruntuleri (6.7", 6.1", 5.5" — 12 dil)
    - [ ] TestFlight dahili + harici test
    - [ ] Submit for Review

- [ ] H.4 — **Android Play Store hazirligi** — Google Play Console + store listing + test
  - Ajan: DevOps | Harici: Google Play Console ($25) + Android cihaz
  - Alt gorevler:
    - [ ] Google Play Console'da uygulama olustur
    - [ ] Store listesi: baslik, aciklama, ekran goruntuleri (12 dil)
    - [ ] Icerik derecelendirme anketi
    - [ ] IAP urunlerini Play Console'da tanimla
    - [ ] Dahili test → Kapali test → Acik test → Uretim

- [ ] H.5 — **GitHub CI workflow push** — `.github/workflows/` dosyalari (4 workflow) yerel olarak mevcut ama push edilemedi (OAuth token `workflow` scope eksik). Token guncellendikten sonra push et.
  - Ajan: DevOps | Harici: GitHub token guncelleme
  - Kabul: 4 workflow GitHub'da aktif

### MEDIUM — Kod Kalitesi & Guvenlik

- [x] M.1 — **GameScreen parcalama** — ~~Sprint 7'de tamamlandi~~ (3 mixin + dialog refactor)

- [x] M.2 — **Features → Provider katmani gecisi** — ~~Sprint 7'de tamamlandi~~ (12 feature dosyasi + remoteRepositoryProvider)

- [ ] M.3 — **Firebase App Check** — Android: Play Integrity, iOS: App Attest etkinlestir.
  - Ajan: Security | Harici: Firebase Console
  - Kabul: App Check token olmadan API istekleri reddedilir

- [x] M.4 — **PvP seed server-side uretim** — ~~Sprint 7'de tamamlandi~~ (DB DEFAULT + client seed kaldirildi)

- [x] M.5 — **GDPR silme dogrulama** — ~~Sprint 7'de tamamlandi~~ (deleteUserData→bool, 12 dil x 5 string)

- [x] M.6 — **Android AD_ID + iOS PrivacyInfo** — ~~Sprint 7'de tamamlandi~~ (AD_ID permission + PrivacyInfo.xcprivacy)

- [ ] S7-SEC-2 — **Redeem current_uses atomik artirma** — `redeem-code/index.ts` satir 148: read-then-write pattern, paralel farkli-kullanici kullanimi race condition. `current_uses + 1` SQL veya RPC ile atomik artirma gerekli.
  - Ajan: Backend | Kaynak: Security Audit S7-SEC-2
  - Kabul: `current_uses` atomik olarak artiriliyor, max_uses siniri dogru uygulanir

- [x] S7-SEC-3 — **GDPR eksik tablo silme** — ~~`deleteUserData()`'a `redeem_usages` + `pvp_matches` (player1_id + player2_id) eklendi. 7/7 tablo siliniyor.~~
  - Ajan: Backend | Kaynak: Security Audit S7-SEC-3
  - Kabul: 7/7 tablo siliniyor (mevcut 5 + pvp_matches + redeem_usages)

- [ ] S7-SEC-4 — **GDPR silme transaction wrapping** — Ardisik DELETE'ler transaction icinde degil. Kismi basarisizlik kurtarilamaz.
  - Ajan: Backend | Kaynak: Security Audit S7-SEC-4
  - Kabul: Silme islemleri sunucu-tarafli RPC icinde, transaction garantili

- [ ] S7-SEC-5 — **PvP seed spoofing korumasi** — Client INSERT'te `seed` degeri gonderebilir, DEFAULT bypass edilir. Match olusturmayi RPC'ye tasimak veya BEFORE INSERT trigger gerekli.
  - Ajan: Backend | Kaynak: Security Audit S7-SEC-5
  - Kabul: Client seed override edemez, sunucu seed garanti edilir

### LOW — Opsiyonel Iyilestirmeler

- [x] L.1 — **Viral pipeline testleri** — `ClipRecorder`, `VideoProcessor`, `ShareManager` icin 61 test yazildi.
  - Ajan: QA
  - Kabul: 3 test dosyasi, 61 test, flutter analyze 0 issue, flutter test 61/61 gecti

- [x] L.2 — **Quest/Dialog testleri** — `quest_overlay.dart` ve game dialogs icin 0 test var.
  - Ajan: QA
  - Kabul: 2 test dosyasi, 48 test, flutter analyze 0 issue, flutter test 48/48 gecti

- [ ] L.3 — **Fastlane veya Shorebird entegrasyonu** — OTA guncelleme veya otomatik store dagitimi.
  - Ajan: DevOps | Harici: Kurulum gerekli
  - Kabul: Build + deploy pipeline otomasyon

- [ ] L.4 — **Performans profili** — Flutter DevTools ile 60fps hedefi dogrulama.
  - Ajan: QA | Harici: Fiziksel cihaz
  - Kabul: Jank-free 60fps

- [ ] L.5 — **TikTok/Instagram direct share** — Viral pipeline'a sosyal medya entegrasyonu.
  - Ajan: Developer | Harici: Platform API key'leri
  - Kabul: Paylas butonu TikTok/Instagram'a yonlendiriyor

---

## Tamamlanan Fazlar (Referans)

| Faz | Aciklama |
|-----|----------|
| A | 904 birim test (48 dosya, 0 hata) |
| B | Supabase entegrasyon (8 tablo + 22 RLS + 3 indeks + 3 RPC) |
| C | PvP Realtime (Presence + Broadcast + bot fallback + ELO) |
| D | Meta-game backend (meta_states + cross-device sync) |
| E | Firebase Analytics + Crashlytics (gloo-f7905) |
| F | 36 ses dosyasi (32 SFX .ogg + 4 muzik .mp3) + 32 iOS .m4a |
| G | Viral pipeline (screen_recorder + FFmpeg + share) |
| J | CI/CD (4 GitHub Actions workflow — yerel, push bekliyor) |
| K | Kod kalitesi (refactoring, rename, README, GDD) |
| L | Bundle ID, GDPR/ATT, memory leak fix, dosya refactoring |
| M | Performans optimizasyonu: 33/33 |
| N | Sprint 1: Guvenlik hardening 7/7 (IAP receipt, redeem RLS, PvP RPC, skor RPC, GDPR DELETE, ELO auth, debugPrint) |
| O | Sprint 2: Backend kalite 4/4 (race condition RPC, matchmaking simetri, streak key, createdAt fix) |
| P | Sprint 3: Gorsel & branding 2/2 (programatik jel damlasi ikon + native splash) |
| Q | Sprint 6: Post-launch 9/9 (home_screen parcalama, AppSettings rename, glow_orb tasima, 181 test, web CI, singleton→provider, DTO) |

---

## 5-Ajan Analiz Ozeti (2026-03-01, Guncellenmis)

| Ajan | Sonuc |
|------|-------|
| **QA** | 904/904 test gecti, 0 analyze issue. Oyun motoru + data layer + services iyi kapsam. Feature UI testleri seyrek (1-5/ekran). Viral/effects/quests 0 test. |
| **Architect** | Mimari olgunluk 7.5/10. Katman ayrimi iyi, ~8-10 minor ihlal (features→data direkt). 0 TODO/FIXME/HACK. GameScreen 900+ satir (en buyuk monolith). Provider yapisi tutarli. |
| **Backend** | %95 hazirlik. RemoteRepository %100 isConfigured guard. 4 DTO sinifi tam. 3 Edge Function + 3 RPC aktif. Eksik: Android payment API, redeem per-user guard. |
| **Security** | Risk ORTA. Hardcoded key'ler beklenen (mobil app). Firebase API restrict edilmeli. profiles SELECT cok genis. Redeem per-user yok. PvP seed client-side. debugPrint temiz, HTTP yok, ATT mevcut. |
| **DevOps** | Web build hazir. Android debug hazir, release keystore eksik. iOS debug hazir, signing gerekli. AdMob test ID aktif (uretim oncesi degistirilmeli). 4 CI workflow yerel (push bekliyor). |
