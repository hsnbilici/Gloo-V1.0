# Gloo v1.0 — Yol Haritasi

> Son guncelleme: 2026-03-01
> **Durum:** Sprint 10 TAMAMLANDI | flutter analyze: 0 issue | flutter test: 1205/1205
> **Proje skoru:** 9.2 / 10 | Tamamlanan fazlar: 21 (A-U)
> **Kalan:** 7 madde — tumu harici bagimlilk gerektiriyor

---

## Kalan Gorevler — Oncelik Sirasina Gore

### CRITICAL — Uretime Gecis Oncesi Zorunlu

| # | Gorev | Ajan | Harici Bagimlilk |
|---|-------|------|------------------|
| C.1 | Firebase API key kisitlamalari (HTTP referrer + bundle ID) | Security | Google Cloud Console |
| C.2 | AdMob test ID → gercek ID degisimi (Android + iOS + ad_manager.dart) | DevOps | AdMob Console |
| C.3 | Android release signing (keystore + key.properties + CI secrets) | DevOps | Keystore olusturma |

### HIGH — Store Submission Icin Gerekli

| # | Gorev | Ajan | Harici Bagimlilk |
|---|-------|------|------------------|
| H.2 | Android payment verification (Google Play Developer API) | Backend | Google Play API key |
| H.3 | iOS App Store hazirligi (signing + IAP + TestFlight + submit) | DevOps | Apple Developer ($99/yil) |
| H.4 | Android Play Store hazirligi (listing + test + submit) | DevOps | Google Play Console ($25) |
| H.5 | GitHub CI workflow push (4 workflow, OAuth token scope eksik) | DevOps | GitHub token guncelleme |

### MEDIUM — Guvenlik Iyilestirme

| # | Gorev | Ajan | Harici Bagimlilk |
|---|-------|------|------------------|
| M.3 | Firebase App Check (Play Integrity + App Attest) | Security | Firebase Console |

### LOW — Opsiyonel

| # | Gorev | Ajan | Harici Bagimlilk |
|---|-------|------|------------------|
| L.3 | Fastlane veya Shorebird entegrasyonu | DevOps | Kurulum |
| L.4 | Performans profili (60fps dogrulama) | QA | Fiziksel cihaz |
| L.5 | TikTok/Instagram direct share | Developer | Platform API key |

---

## Guncel Skor Ozeti

| Ajan | Skor | Tavan (harici ile) |
|------|------|--------------------|
| QA | **9.5** / 10 | 9.5 |
| Security | **9.0** / 10 | 10.0 (C.1, M.3) |
| Architect | **9.5** / 10 | 9.5 |
| Backend | **10.0** / 10 | 10.0 |
| DevOps | **8.0** / 10 | 10.0 (C.2, C.3, H.3-5) |
| **ORTALAMA** | **9.2** / 10 | 9.8 |

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
| J | CI/CD (4 GitHub Actions workflow — yerel, push bekliyor) |
| K | Kod kalitesi (refactoring, rename, README, GDD) |
| L | Bundle ID, GDPR/ATT, memory leak fix, dosya refactoring |
| M | Performans optimizasyonu: 33/33 |
| N | Sprint 1: Guvenlik hardening 7/7 |
| O | Sprint 2: Backend kalite 4/4 |
| P | Sprint 3: Gorsel & branding 2/2 |
| Q | Sprint 6: Post-launch 9/9 (home_screen parcalama, singleton→provider, DTO, 181 test) |
| R | Sprint 7: Kod kalitesi & guvenlik 10/10 (GameScreen refactor, per-user redeem, GDPR, 109 test) |
| S | Sprint 8: Guvenlik iyilestirmeleri 3/3 (atomik redeem, GDPR transaction RPC, PvP seed random) |
| T | Sprint 9: Mimari + guvenlik polish 6/6 (resource_manager split, dedup, DTOs, GDPR auth.users, RLS) |
| U | Sprint 10: Test kapsami genisletme 5/5 (audio, router, effects, DTOs, providers — 191 yeni test) |
