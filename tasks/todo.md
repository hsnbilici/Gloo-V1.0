# Gloo v1.0 — Yol Haritasi

> Son guncelleme: 2026-03-17
> **Durum:** Sprint 18 TAMAMLANDI + Simplify fix'ler uygulandı | flutter analyze: 0 error | flutter test: 1204/1204
> **Proje skoru:** 77 / 100 (7 ajan kapsamli denetimi)
> Tamamlanan fazlar: 29 (A-Z + AA + AB + AC)
> **Kalan:** Store dogrulama + guvenlik hardening + erisilebilirlik

---

## Proje Scorecard (7 Ajan Denetimi — 2026-03-17)

| # | Alan | Puan | En Dusuk Alt Alan |
|---|------|:----:|-------------------|
| 1 | Mimari | 79 | Bagimlilik yonu (72) |
| 2 | Gameplay | 83 | PvP/Duel (80) |
| 3 | UI/UX | 79 | Erisilebilirlik (55) |
| 4 | QA | 81 | Edge case coverage (72) |
| 5 | DevOps | 71 | Release hazirligi (55) |
| 6 | Backend | 79 | Lokal veri yonetimi (72) |
| 7 | Guvenlik | 64 | Hardcoded secrets (45) |
| **GENEL** | | **77** | |

---

## Kalan Gorevler — Oncelik Sirasina Gore

### P0 — CRITICAL (Uretime Gecis Oncesi Zorunlu)

| # | Gorev | Ajan | Harici Bagimlilk | Scorecard Ref |
|---|-------|------|------------------|---------------|
| C.1 | Firebase API key kisitlamalari — Debug SHA-1 eklendi. Release + Play Console SHA-1 eksik | Security | Release keystore + Play Store kaydi | Guvenlik: 45 |
| C.2 | AdMob test ID → gercek ID degisimi (Android + iOS + ad_manager.dart) | DevOps | AdMob Console | DevOps: 55 |
| ~~C.3~~ | ~~Android release signing~~ — TAMAMLANDI | DevOps | — | — |
| C.4 | **API key'leri `--dart-define` ile CI secret'a tasi** — Firebase + Supabase key'leri kaynak koddan cikarilmali | Security | CI/CD secret yapilandirmasi | Guvenlik: 45 |
| C.5 | **Supabase RLS politikalarini dogrula** — ozellikle `updateElo()` client'tan dogrudan deger yaziyor; sunucu tarafinda sinir konulmali | Security | Supabase Dashboard | Guvenlik: 50 |
| C.6 | **iOS code signing + TestFlight pipeline kur** — CI'da tamamen eksik, store submit engelliyor | DevOps | Apple Developer ($99/yil) | DevOps: 55, 70 |

### P1 — HIGH (Store Submission + Kalite)

| # | Gorev | Ajan | Harici Bagimlilk | Scorecard Ref |
|---|-------|------|------------------|---------------|
| H.2 | Android payment verification (Google Play Developer API) | Backend | Google Play API key | Backend: 83 |
| H.3 | iOS App Store hazirligi (signing + IAP + TestFlight + submit) | DevOps | Apple Developer | DevOps: 70 |
| H.4 | Android Play Store hazirligi (listing + test + submit) | DevOps | Google Play Console ($25) | DevOps: 55 |
| ~~H.5~~ | ~~GitHub CI workflow permissions~~ — TAMAMLANDI | DevOps | — | — |
| H.6 | **Integration test altyapisi kur** — `integration_test/` sifir; temel oyun akisi E2E test edilmeli | QA | — | QA: 82 |
| H.7 | **Erisilebilirlik iyilestirmesi** — Semantics genislet (47 dosyanin 7'sinde var), font scaling yonet, ekran okuyucu destegi | UI/UX | — | UI/UX: 55 |
| ~~H.8~~ | ~~IAP `_pendingVerification` persist et~~ — TAMAMLANDI (Sprint 19) | Backend | — | — |
| H.9 | **Certificate pinning ekle** — en azindan Supabase endpoint'i icin | Security | — | Guvenlik: 55 |
| H.10 | **Privacy policy URL'si + store metadata olustur** — her iki store icin zorunlu | DevOps | Hosting | DevOps: 55 |

### P2 — MEDIUM (Kalite & Mimari Iyilestirme)

| # | Gorev | Ajan | Harici Bagimlilk | Scorecard Ref |
|---|-------|------|------------------|---------------|
| M.3 | Firebase App Check enforce — Console'da kayit + 7 gun monitoring → enforce | — | Firebase Console | Backend: 80 |
| ~~M.4~~ | ~~Hardcoded Turkce string'leri l10n'a tasi~~ — TAMAMLANDI (Sprint 19) | UI/UX | — | — |
| M.5 | **`StateNotifierProvider` → `NotifierProvider` gecisi** — Riverpod 2.x deprecated | Architect | — | Mimari: 82 |
| M.6 | **Coverage threshold enforcement** — CI'ya `very_good_coverage` veya lcov ile min %80 ekle | QA | — | QA: 80 |
| ~~M.7~~ | ~~`core→game` ters bagimliligi gider~~ — TAMAMLANDI (Sprint 19) | Architect | — | — |
| M.8 | **`features→data/remote` dogrudan erisimlerini provider'a yonlendir** — 3 dosyada bypass var | Architect | — | Mimari: 72 |
| ~~M.9~~ | ~~Retry mekanizmasi ekle~~ — TAMAMLANDI (Sprint 19) | Backend | — | — |
| M.10 | **AdMob UMP SDK entegrasyonu** — GDPR tam uyumluluk icin zorunlu | Backend | — | Backend: 76 |
| ~~M.11~~ | ~~Subscription expiry kontrolu~~ — TAMAMLANDI (Sprint 19) | Backend | — | — |

### P3 — LOW (Opsiyonel & Gelecek)

| # | Gorev | Ajan | Harici Bagimlilk | Scorecard Ref |
|---|-------|------|------------------|---------------|
| L.3 | Fastlane veya Shorebird entegrasyonu | DevOps | Kurulum | DevOps: 71 |
| L.4 | Performans profili (60fps dogrulama) | QA | Fiziksel cihaz | QA: 81 |
| L.5 | TikTok/Instagram direct share | Developer | Platform API key | — |
| L.6 | **Tablet/web genis ekran layout'u** — tum ekranlar telefon dikeyi icin; 10" tablette optimize degil | UI/UX | — | UI/UX: 78 |
| L.7 | **`_evaluateBoard()` parcalanmasi** — 130+ satir, 6+ sorumluluk; pipeline/strategy pattern | Developer | — | Gameplay: 82 |
| L.8 | **Harici servis mock'lari** — Firebase/Supabase icin mock/fake siniflar olustur | QA | — | QA: 78 |
| L.9 | **SoundBank ses pipeline'i tamamla** — `onLineClear` ve `onGameOver` bos; ses dosyalari eksik | UI/UX | Ses uretimi | UI/UX: 80 |
| L.10 | **COPPA yas kapisi** — oyun gorselleri cocuklara hitap ediyorsa 13 yas alti kontrol zorunlu | Security | — | Guvenlik: 82 |
| L.11 | **Dependabot/Renovate kur** — otomatik dependency guncelleme | DevOps | — | Guvenlik: 68 |
| L.12 | **RTL layout destegi** — Arapca dil dosyasi var ama layout ayarlamasi yok | UI/UX | — | UI/UX: 75 |

---

## Scorecard Alt Alan Detaylari

<details>
<summary>Mimari (79/100)</summary>

| Alt Alan | Puan |
|----------|:----:|
| Katman ayrimi | 78 |
| Bagimlilik yonu | 72 |
| State management | 82 |
| Routing | 88 |
| Genisletilebilirlik | 80 |
| Teknik borc | 75 |
| Pattern tutarliligi | 81 |

</details>

<details>
<summary>Gameplay (83/100)</summary>

| Alt Alan | Puan |
|----------|:----:|
| GlooGame pipeline | 82 |
| GridManager | 85 |
| Oyun mekanikleri | 86 |
| Shape sistemi | 84 |
| Level sistemi | 83 |
| PvP/Duel | 80 |
| Ekonomi | 81 |
| Fizik | 87 |

</details>

<details>
<summary>UI/UX (79/100)</summary>

| Alt Alan | Puan |
|----------|:----:|
| Ekran yapisi & navigasyon | 88 |
| Animasyon kalitesi | 92 |
| Renk & tema tutarliligi | 82 |
| Responsive tasarim | 78 |
| **Erisilebilirlik** | **55** |
| l10n/i18n | 75 |
| Widget ayristirma | 85 |
| Haptik & ses | 80 |

</details>

<details>
<summary>QA (81/100)</summary>

| Alt Alan | Puan |
|----------|:----:|
| Test kapsami | 82 |
| Test kalitesi | 78 |
| Lint uyumu | 90 |
| Edge case coverage | 72 |
| Test organizasyonu | 85 |
| CI/CD entegrasyonu | 80 |

</details>

<details>
<summary>DevOps (71/100)</summary>

| Alt Alan | Puan |
|----------|:----:|
| CI/CD pipeline | 72 |
| Android build | 82 |
| iOS build | 70 |
| Web build | 75 |
| **Release hazirligi** | **55** |
| Asset yonetimi | 68 |
| Dependency yonetimi | 78 |

</details>

<details>
<summary>Backend (79/100)</summary>

| Alt Alan | Puan |
|----------|:----:|
| Supabase entegrasyonu | 78 |
| Lokal veri yonetimi | 72 |
| PvP Realtime | 82 |
| Veri modelleri/DTO | 75 |
| Firebase entegrasyonu | 80 |
| IAP/Purchase | 83 |
| Reklam sistemi | 85 |
| GDPR uyumlulugu | 76 |

</details>

<details>
<summary>Guvenlik (64/100)</summary>

| Alt Alan | Puan |
|----------|:----:|
| **Hardcoded secrets** | **45** |
| Network guvenligi | 55 |
| Veri guvenligi | 60 |
| Kimlik dogrulama | 65 |
| IAP guvenligi | 78 |
| **Anti-cheat** | **50** |
| GDPR/COPPA/ATT | 82 |
| Print/debug leak | 92 |
| Store gereksinimleri | 75 |
| Dependency guvenligi | 68 |

</details>

---

## Tamamlanan Fazlar (Referans)

| Faz | Aciklama |
|-----|----------|
| A | Birim testler (baslangic: 723 test) |
| B | Supabase entegrasyon (8 tablo + 22 RLS + 3 indeks + 3 RPC) |
| C | PvP Realtime (Presence + Broadcast + bot fallback + ELO) |
| D | Meta-game backend (meta_states + cross-device sync) |
| E | Firebase Analytics + Crashlytics (gloo-f7905) |
| F | 36 ses dosyasi (32 SFX .ogg + 4 muzik .mp3) + 32 iOS .m4a |
| G | Viral pipeline (screen_recorder + FFmpeg + share) |
| J | CI/CD (4 GitHub Actions workflow) |
| K | Kod kalitesi (refactoring, rename, README, GDD) |
| L | Bundle ID, GDPR/ATT, memory leak fix, dosya refactoring |
| M | Performans optimizasyonu: 33/33 |
| N | Sprint 1: Guvenlik hardening 7/7 |
| O | Sprint 2: Backend kalite 4/4 |
| P | Sprint 3: Gorsel & branding 2/2 |
| Q | Sprint 6: Post-launch 9/9 |
| R | Sprint 7: Kod kalitesi & guvenlik 10/10 |
| S | Sprint 8: Guvenlik iyilestirmeleri 3/3 |
| T | Sprint 9: Mimari + guvenlik polish 6/6 |
| U | Sprint 10: Test kapsami genisletme 5/5 (1204 test) |
| V | Sprint 11: Firebase API key kisitlamalari 3/3 |
| W | Sprint 12: QA bulgu duzeltmeleri 8/8 |
| X | Sprint 13: iOS Simulator build dogrulama 2/2 |
| Y | Sprint 14: Firebase App Check 2/2 |
| Z | Sprint 15: K.1-K.4 servis duzeltmeleri 4/4 |
| AA | Sprint 16: 2 bug fix |
| AB | Sprint 17: C.3+H.5 — Release keystore, CI signing |
| AC | Sprint 18: CI duzeltmeleri 6/6 |
| AD | Sprint 19: Kalite & mimari iyilestirme (bagimsiz gorevler) |

---

## Sprint 19 — Kalite & Mimari Iyilestirme (Harici Bagimlilik Yok)

- [x] AD.1 — H.8: IAP `_pendingVerification` SharedPreferences'a persist et
- [x] AD.2 — M.7: `core→game` ters bagimliligi gider (`kModeColors` → `game_world.dart`'a tasindi)
- [x] AD.3 — M.4: Hardcoded Turkce string'leri l10n'a tasi (20 string, 12 dil + GelColor.displayName → l10n)
- [x] AD.4 — M.9: `submitScore` ve `submitPvpResult` icin retry mekanizmasi ekle (exponential backoff, 3 deneme)
- [x] AD.5 — M.11: Gloo+ abonelik expiry kontrolu ekle (restorePurchases + syncLocalProducts)
- [x] AD.6 — Dogrulama: `flutter analyze` 0 error | `flutter test` 1204/1204 passed
