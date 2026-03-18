# Gloo v1.0 — Yol Haritasi

> Son guncelleme: 2026-03-18
> **Durum:** P0+P2+P3(6/17) TAMAMLANDI | flutter analyze: 0 error | flutter test: 1289/1289
> **Proje skoru:** 87 / 100
> Tamamlanan sprint: 33 (A-Z + AA-AG)

---

## Scorecard (2026-03-18)

| # | Alan | Puan | En Dusuk Alt Alan |
|---|------|:----:|-------------------|
| 1 | Mimari | **85** | features→data bypass duzeltildi |
| 2 | Gameplay | **82** | PvP/Duel (72), availableColors + inflasyon eklendi |
| 3 | UI/UX | **76** | Erisilebilirlik (55) |
| 4 | QA | **89** | 1289 test, coverage threshold %70, pipeline testleri |
| 5 | DevOps | **78** | CI versioning + Dependabot eklendi |
| 6 | Backend | **77** | GDPR uyumlulugu (68) |
| 7 | Guvenlik | **80** | iOS native pinning eksik |
| **GENEL** | | **87** | |

---

## Yapilacaklar

### P0 — TAMAMLANDI

- [x] C.1: Firebase API key kisitlamalari — Release keystore, SHA-1, Google Cloud Console kisitlama
- [x] C.2: AdMob altyapi hazir (dart-define + fallback). Gercek ID'ler AdMob Console'dan eklenecek
- [x] C.4: API key'leri `--dart-define` ile CI secret'a tasindi. `.env` guncellendi (gloo-d3dd8)
- [x] C.5: Supabase RLS dogrulandi — tum CRUD `auth.uid() = id` ile korunuyor
- [x] C.6: iOS code signing (manual Release/Profile) + TestFlight CI pipeline

### P1 — HIGH (Store Submission + Kalite)

**Tamamlanan P1 gorevleri:**
- [x] H.6: Integration test altyapisi — `integration_test/` + classic mod E2E + test helper
- [x] H.7: Erisilebilirlik — Semantics 8 ekran, textScaler 5 ekran, 44x44dp tap targets
- [x] H.9: Certificate pinning — Android `network_security_config.xml` + Dart `HttpOverrides` + 7 test
- [x] H.11: AdMob UMP SDK — `ConsentService` + `user_messaging_platform` + consent gate'ler

**Kalan P1 gorevleri (harici bagimlilik):**

| # | Gorev | Harici Bag. |
|---|-------|-------------|
| H.2 | Android payment verification (Google Play Developer API) | Google Play API |
| H.3 | iOS App Store hazirligi (signing + IAP + TestFlight + submit) | Apple Developer |
| H.4 | Android Play Store hazirligi (listing + test + submit) | Play Console |
| H.10 | Privacy policy URL + store metadata | Hosting |

### P2 — MEDIUM (Kalite & Mimari)

**Tamamlanan P2 gorevleri:**
- [x] M.5: `StateNotifierProvider` → `NotifierProvider` — zaten tamamlanmis (projede kullanim yok)
- [x] M.6: Coverage threshold — CI'ya lcov + min %70 esik
- [x] M.8: `features→data/remote` bypass'larini provider'a yonlendir (pvp_lobby + game_duel_controller)
- [x] M.14: 60+ hardcoded `Color(0x...)` → `color_constants.dart` (39 yeni sabit, 21 dosya)
- [x] M.17: `ShapeGenerator` static → instance-based (constructor injection, izole test state)
- [x] M.18: Mock/fake siniflar — `mocktail` entegrasyonu (3 mock sinif)
- [x] M.19: `_evaluateBoard()` pipeline testi (12 test: chef/timeTrial/level)

**Kalan P2 gorevleri (harici bagimlilik):**

| # | Gorev | Harici Bag. |
|---|-------|-------------|
| M.3 | Firebase App Check enforce | Firebase Console |
| M.20 | Sunucu tarafinda ELO hesaplama (RPC) | Supabase |

### P3 — LOW (Opsiyonel)

**Tamamlanan P3 gorevleri:**
- [x] L.9: SoundBank ses pipeline — tum SFX event'leri + 7 yeni event (onSynthesis, onIceBreak vb.)
- [x] L.11: Dependabot — pub + github-actions haftalik kontrol
- [x] L.15: `availableColors` level ozelligi — ShapeGenerator + GlooGame entegrasyonu, Level 15/25
- [x] L.16: Ekonomi inflasyon kontrolu — `inflatedCost()` (1x-3x, 500 birim basina +1x)
- [x] L.18: ELO lig isimleri l10n — 5 lig, 12 dil
- [x] L.21: CI versioning otomasyonu — git commit count bazli build number

**Kalan P3 gorevleri:**

| # | Gorev |
|---|-------|
| L.3 | Fastlane veya Shorebird entegrasyonu |
| L.4 | Performans profili (60fps dogrulama) |
| L.5 | TikTok/Instagram direct share |
| L.6 | Tablet/web responsive layout |
| L.10 | COPPA yas kapisi |
| L.12 | RTL layout destegi |
| L.13 | ThemeData (karanlik/aydinlik) |
| L.14 | Seeded modlarda smart RNG |
| L.17 | shop_screen.dart parcala |
| L.19 | PvP reconnection stratejisi |
| L.20 | Veri export (GDPR Article 20) |

---

## Tamamlanan Sprintler

<details>
<summary>Sprint 22 (AG) — P3 Bagimsiz Gorevler — 6/6</summary>

- [x] L.9: SoundBank ses pipeline — tum SFX + 7 yeni event
- [x] L.11: Dependabot yapilandirmasi (pub + github-actions)
- [x] L.15: availableColors level ozelligi (ShapeGenerator entegrasyonu)
- [x] L.16: Ekonomi inflasyon kontrolu (inflatedCost 1x-3x)
- [x] L.18: ELO lig isimleri l10n (5 lig, 12 dil)
- [x] L.21: CI versioning otomasyonu (git commit count)
</details>

<details>
<summary>Sprint 21 (AF) — P2 Kalite & Mimari Iyilestirme — 7/7</summary>

- [x] M.5: StateNotifierProvider kontrol — zaten tamamlanmis
- [x] M.6: CI coverage threshold (min %70 lcov esik)
- [x] M.8: features→data/remote bypass fix (re-export uzerinden)
- [x] M.14: 60+ hardcoded Color(0x...) → color_constants.dart (39 sabit)
- [x] M.17: ShapeGenerator static → instance-based (constructor injection)
- [x] M.18: mocktail entegrasyonu (3 mock sinif)
- [x] M.19: _evaluateBoard() pipeline testleri (12 test)
</details>

<details>
<summary>Sprint 20 (AE) — Kalite, Guvenlik & Mimari Temizlik — 8/8</summary>

- [x] C.7: Hassas veri sifreleme (flutter_secure_storage, 8 key, migration fallback)
- [x] C.8: PrivacyInfo.xcprivacy guncellendi
- [x] M.12: ComboEvent/ComboTier → core/ (audio→game fix)
- [x] M.13: GameMode → core/, kModeColors → color_constants (game/ Flutter import fix)
- [x] M.15: Kullanilmayan sharedPreferencesProvider silindi
- [x] M.16: PvP obstacle large fix (ice:3+stone:2) + 3 test
- [x] H.12: _evaluateBoard() → 7 alt metot (SRP)
- [x] H.13: 15 hardcoded TR string → l10n (12 dil)
</details>

<details>
<summary>Sprint 19 (AD) — Kalite & Mimari Iyilestirme — 5/5</summary>

- [x] H.8: IAP _pendingVerification persist
- [x] M.7: core→game ters bagimlilik fix
- [x] M.4: 20 hardcoded TR string → l10n
- [x] M.9: submitScore/submitPvpResult retry (exponential backoff)
- [x] M.11: Gloo+ abonelik expiry kontrolu
</details>

<details>
<summary>Onceki Sprintler (A-AC) — 28 faz</summary>

| Faz | Aciklama |
|-----|----------|
| A | Birim testler (723 test) |
| B | Supabase entegrasyon (8 tablo + 22 RLS + 3 RPC) |
| C | PvP Realtime (Presence + Broadcast + bot + ELO) |
| D | Meta-game backend |
| E | Firebase Analytics + Crashlytics |
| F | 36 ses dosyasi + 32 iOS .m4a |
| G | Viral pipeline (screen_recorder + FFmpeg + share) |
| J | CI/CD (4 workflow) |
| K | Kod kalitesi |
| L | Bundle ID, GDPR/ATT, memory leak fix |
| M | Performans optimizasyonu 33/33 |
| N-Z | Sprint 1-15: Guvenlik, backend, gorsel, CI |
| AA-AC | Sprint 16-18: Bug fix, signing, CI duzeltmeleri |
</details>
