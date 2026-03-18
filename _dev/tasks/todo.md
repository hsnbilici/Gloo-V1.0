# Gloo v1.0 — Yol Haritasi

> Son guncelleme: 2026-03-18
> **Durum:** Sprint 20 TAMAMLANDI | flutter analyze: 0 error | flutter test: 1218/1218
> **Proje skoru:** 76 / 100
> Tamamlanan sprint: 31 (A-Z + AA-AE)

---

## Scorecard (2026-03-18)

| # | Alan | Puan | En Dusuk Alt Alan |
|---|------|:----:|-------------------|
| 1 | Mimari | **78** | State management (65) |
| 2 | Gameplay | **78** | PvP/Duel (72) |
| 3 | UI/UX | **72** | Erisilebilirlik (38) |
| 4 | QA | **79** | CI/CD entegrasyonu (65) |
| 5 | DevOps | **73** | Release hazirligi (45) |
| 6 | Backend | **77** | GDPR uyumlulugu (68) |
| 7 | Guvenlik | **68** | Hardcoded secrets (35) |
| **GENEL** | | **76** | |

---

## Yapilacaklar

### P0 — CRITICAL (Store Oncesi Zorunlu)

| # | Gorev | Harici Bag. |
|---|-------|-------------|
| C.1 | Firebase API key kisitlamalari — Release SHA-1 + Play Console kaydi | Play Store |
| C.2 | AdMob test ID → gercek ID (Android + iOS + ad_manager.dart) | AdMob Console |
| C.4 | API key'leri `--dart-define` ile CI secret'a tasi — Firebase + Supabase acik | CI/CD secret |
| C.5 | Supabase RLS dogrula — `updateElo()` baska kullanicinin ELO'sunu degistirebilir mi? | Supabase Dashboard |
| C.6 | iOS code signing + TestFlight pipeline kur | Apple Developer |

### P1 — HIGH (Store Submission + Kalite)

| # | Gorev | Harici Bag. |
|---|-------|-------------|
| H.2 | Android payment verification (Google Play Developer API) | Google Play API |
| H.3 | iOS App Store hazirligi (signing + IAP + TestFlight + submit) | Apple Developer |
| H.4 | Android Play Store hazirligi (listing + test + submit) | Play Console |
| H.6 | Integration test altyapisi — `integration_test/` sifir; classic mod E2E testi | — |
| H.7 | Erisilebilirlik — Semantics %15→%60, oyun izgarasi semantik, textScaler, 44x44dp | — |
| H.9 | Certificate pinning — Supabase + Firebase; IAP receipt ve PvP skor MITM'e acik | — |
| H.10 | Privacy policy URL + store metadata | Hosting |
| H.11 | AdMob UMP SDK — EU reklam consent zorunlu (TCF 2.0) | — |

### P2 — MEDIUM (Kalite & Mimari)

| # | Gorev | Harici Bag. |
|---|-------|-------------|
| M.3 | Firebase App Check enforce — Console kayit + 7 gun monitoring | Firebase Console |
| M.5 | `StateNotifierProvider` → `NotifierProvider` gecisi (4 provider) | — |
| M.6 | Coverage threshold enforcement — CI'ya lcov + min %70 esik | — |
| M.8 | `features→data/remote` bypass'larini provider'a yonlendir (4 dosya) | — |
| M.14 | 60+ hardcoded `Color(0x...)` sabiti `color_constants.dart`'a tasi | — |
| M.17 | `ShapeGenerator` static → instance-based (PvP paralel state riski) | — |
| M.18 | Mock/fake siniflar — `mocktail` + RemoteRepository/Analytics/Purchase mock | — |
| M.19 | `_evaluateBoard()` pipeline testi yaz (place→synth→clear→gravity→combo) | — |
| M.20 | Sunucu tarafinda ELO hesaplama — RPC ile (client-side cheat onlemi) | Supabase |

### P3 — LOW (Opsiyonel)

| # | Gorev | Harici Bag. |
|---|-------|-------------|
| L.3 | Fastlane veya Shorebird entegrasyonu | Kurulum |
| L.4 | Performans profili (60fps dogrulama) | Fiziksel cihaz |
| L.5 | TikTok/Instagram direct share | Platform API |
| L.6 | Tablet/web genis ekran layout — responsive yok | — |
| L.9 | SoundBank ses pipeline tamamla — `onLineClear`/`onGameOver` bos | Ses uretimi |
| L.10 | COPPA yas kapisi (App Store 4+ siniflandirma) | — |
| L.11 | Dependabot/Renovate — otomatik dependency guncelleme | — |
| L.12 | RTL layout destegi — Arapca var ama Directionality yok | — |
| L.13 | ThemeData olustur — karanlik/aydinlik gecisi imkansiz | — |
| L.14 | Seeded modlarda smart RNG etkinlestir (Daily/Duel merhamet yok) | — |
| L.15 | `availableColors` level ozelligini aktif et | — |
| L.16 | Ekonomi inflasyon kontrolu — bakiye siniri/gunluk cap yok | — |
| L.17 | shop_screen.dart parcala (878 satir) | — |
| L.18 | ELO lig isimlerini l10n'a tasi (`'Bronz'`, `'Gumus'` vb.) | — |
| L.19 | PvP reconnection stratejisi — ag kopmasinda bildirim yok | — |
| L.20 | Veri export (GDPR Article 20) | — |
| L.21 | CI versioning otomasyonu — version code sabit `1` | — |

---

## Tamamlanan Sprintler

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
