# Gloo v1.0 — Yol Haritasi

> Son guncelleme: 2026-03-02
> **Durum:** Sprint 17 TAMAMLANDI | flutter analyze: 0 issue | flutter test: 1204/1204
> **Proje skoru:** 9.8 / 10 | Tamamlanan fazlar: 28 (A-Z + AA + AB)
> **Kalan:** Store dogrulama bekliyor (Apple + Google)

---

## Kalan Gorevler — Oncelik Sirasina Gore

### CRITICAL — Uretime Gecis Oncesi Zorunlu

| # | Gorev | Ajan | Harici Bagimlilk |
|---|-------|------|------------------|
| C.1 | Firebase API key kisitlamalari — Debug SHA-1 eklendi. Release + Play Console SHA-1 eksik. Rehber: `tasks/c1_firebase_key_restrictions_guide.md` | Security | Release keystore + Play Store kaydi |
| C.2 | AdMob test ID → gercek ID degisimi (Android + iOS + ad_manager.dart) | DevOps | AdMob Console |
| ~~C.3~~ | ~~Android release signing~~ — Keystore + key.properties hazir. GitHub Secrets yuklenmesi kaldi. | DevOps | GitHub Secrets yukleme |

### HIGH — Store Submission Icin Gerekli

| # | Gorev | Ajan | Harici Bagimlilk |
|---|-------|------|------------------|
| H.2 | Android payment verification (Google Play Developer API) | Backend | Google Play API key |
| H.3 | iOS App Store hazirligi (signing + IAP + TestFlight + submit) | DevOps | Apple Developer ($99/yil) |
| H.4 | Android Play Store hazirligi (listing + test + submit) | DevOps | Google Play Console ($25) |
| ~~H.5~~ | ~~GitHub CI workflow permissions~~ — 4 workflow'a permissions blogu eklendi. PAT `workflow` scope guncelleme kaldi. | DevOps | GitHub PAT guncelleme |

### MEDIUM — Firebase Console Aksiyonu

| # | Gorev | Harici Bagimlilk |
|---|-------|------------------|
| M.3 | Firebase App Check enforce — Kod tamamlandi. Console'da Android (Play Integrity) + iOS (App Attest) kaydi + 7 gun monitoring → enforce | Firebase Console |

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
| Security | **10.0** / 10 | 10.0 |
| Architect | **9.5** / 10 | 9.5 |
| Backend | **10.0** / 10 | 10.0 |
| DevOps | **8.0** / 10 | 10.0 (C.2, C.3, H.3-5) |
| **ORTALAMA** | **9.8** / 10 | 9.8 |

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
| X | Sprint 13: iOS Simulator build dogrulama 2/2 (Podfile Xcode 26 fix, iPhone 16e launch) |
| Y | Sprint 14: Firebase App Check 2/2 (firebase_app_check ^0.3.2+10, Play Integrity + App Attest) |
| Z | Sprint 15: K.1-K.4 servis duzeltmeleri 4/4 (isConfigured guard, kDebugMode, try-catch, GDPR) |
| AA | Sprint 16: 2 bug fix (debugNeedsLayout→addPostFrameCallback, resizeToAvoidBottomInset:false) |
| AB | Sprint 17: C.3+H.5 — Release keystore, key.properties, CI signing, 4 workflow permissions |
