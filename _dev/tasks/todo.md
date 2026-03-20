# Gloo v1.0 — Yol Haritasi

> Son guncelleme: 2026-03-20
> **Durum:** P0 TAMAMLANDI | P1: 10/12 | P2: 9/9 | P3: 17/17 | Tier 1 Growth TAMAMLANDI
> flutter analyze: 0 error | flutter test: 1965/1965
> **Proje skoru:** 97+ / 100 (100-plan 31/33 kod gorevi tamamlandi) | Tamamlanan sprint: 40+

---

## Manuel Aksiyonlar (Kod disinda yapilmasi gerekenler)

- [ ] **M.1 — Firebase App Check enforce:** Firebase Console > App Check > Enforce etkinlestir
- [ ] **M.2 — GitHub Secrets ekle:** `GOOGLE_SERVICES_JSON_BASE64`, `GOOGLE_SERVICE_INFO_PLIST_BASE64`, `PLAY_SERVICE_ACCOUNT_JSON`, `APPLE_API_KEY`, `APPSTORE_CONNECT_PRIVATE_KEY`
- [ ] **M.3 — Firebase API key rotation:** Firebase Console > Project Settings > API Keys → rotate
- [ ] **M.4 — git rm --cached:** `git rm --cached android/app/google-services.json ios/Runner/GoogleService-Info.plist`
- [ ] **M.5 — updateElo Supabase RPC:** Supabase Dashboard'da `update-elo` Edge Function olustur, rate limiting ekle
- [ ] **M.6 — Privacy policy + store metadata:** Hosting'e privacy policy deploy, App Store + Play Store listing

---

## Kalan Kod Gorevleri

| # | Gorev | Durum | Not |
|---|-------|-------|-----|
| D.2 | Entegrasyon testleri (5+ senaryo) | Beklemede | Cihaz/emulator gerekli |
| D.7 | Golden/snapshot testleri | TAMAMLANDI | 8 golden test |
| F.7 | Android IAP receipt Google Play API | Beklemede | Supabase Dashboard gerekli |

---

## Tamamlanan 100-Plan Gorevleri (31/33)

| Sprint | Tamamlanan | Gorevler |
|--------|:----------:|----------|
| Sprint 1 | 11/13 | B.1, D.1, D.3, E.1, F.1, F.2, F.4, C.2, B.3, F.3, A.2 |
| Sprint 2 | 10/10 | B.2, B.4, C.4, D.4, D.5, E.2, E.3, E.4, E.5, F.5 |
| Sprint 3 | 10/10 | A.1, A.3, A.4, B.5, C.1, C.3, D.6, D.7, E.6, F.6 |

---

## Onceki Tamamlanan Ozet

| Oncelik | Tamamlanan | Toplam | Onemli Tamamlananlar |
|---------|:----------:|:------:|----------------------|
| P0 | 5/5 | 5 | Firebase keys, AdMob, Supabase RLS, iOS signing |
| P1 | 10/12 | 12 | Integration test, a11y, cert pinning, UMP consent, cascade fix, bomb pipeline, onLevelComplete, IAP receipt, iOS native pinning, Play Store CI |
| P2 | 9/9 | 9 | Coverage CI, katman ihlali fix, ShapeGenerator refactor, COPPA a11y, near-miss params |
| P3 | 17/17 | 17 | SoundBank, responsive layout, RTL, theme, smart RNG, shop refactor, PvP reconnect, COPPA, GDPR export, confetti constants, overlay scaling |
| Growth T1 | 6/6 | 6 | Streak, confetti, share prompt, combo SFX, tutorial |
| 100-Plan | 31/33 | 33 | Architecture split, repo interfaces, PvP provider, username validation, build notifications, cert monitor, golden tests |

**Toplam: 68/70+ gorev tamamlandi (%97)**
