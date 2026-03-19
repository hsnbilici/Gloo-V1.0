# Gloo v1.0 — Yol Haritasi

> Son guncelleme: 2026-03-19
> **Durum:** P0 TAMAMLANDI | P1: 8/12 | P2: 7/9 | P3: 14/17 | Tier 1 Growth TAMAMLANDI
> flutter analyze: 0 error | flutter test: 1352/1352
> **Proje skoru:** 78 / 100 (derinlemesine inceleme sonrasi) | Tamamlanan sprint: 34+

---

## Manuel Aksiyonlar

### P0 sonrasi
- [ ] **GitHub Secrets ekle:** `GOOGLE_SERVICES_JSON_BASE64` — `cat android/app/google-services.json | base64` ciktisini GitHub repo Settings > Secrets'a ekle
- [ ] **GitHub Secrets ekle:** `GOOGLE_SERVICE_INFO_PLIST_BASE64` — `cat ios/Runner/GoogleService-Info.plist | base64` ciktisini ekle
- [ ] **Firebase API key'lerini rotate et** — git history'de eski key'ler mevcut. Firebase Console > Project Settings > API Keys'ten key'leri yenile
- [ ] **git rm --cached calistir:** `git rm --cached android/app/google-services.json ios/Runner/GoogleService-Info.plist` ile dosyalari git tracking'den cikar (lokal kopyalar kalir)

### P1 sonrasi
- [ ] **iOS certificate pinning:** TrustKit Swift Package veya manual URLSessionDelegate ekle. Fiziksel cihazda MITM proxy ile dogrula. Adimlar: (1) `ios/Runner/` altina `CertificatePinningPlugin.swift` ekle, (2) Supabase + Google domain pin'lerini `kCertificatePins`'ten al, (3) AppDelegate'te register et, (4) cihazda Charles/Burp ile test et

---

## Kalan Gorevler

### P1 — HIGH (Store Submission)

| # | Gorev | Harici Bag. | Not |
|---|-------|-------------|-----|
| H.2 | Android payment verification (Google Play Developer API) | Google Play API | Sunucu tarafli receipt dogrulama |
| H.3 | iOS App Store hazirligi (signing + IAP + TestFlight + submit) | Apple Developer | CI signing hazir, TestFlight aktif |
| H.4 | Android Play Store hazirligi (listing + test + submit) | Play Console | APK build CI'da hazir |
| H.10 | Privacy policy URL + store metadata | Hosting | GDPR/COPPA icin zorunlu |

### P2 — MEDIUM (Kalite)

| # | Gorev | Harici Bag. |
|---|-------|-------------|
| M.3 | Firebase App Check enforce | Firebase Console |
| M.20 | Sunucu tarafinda ELO hesaplama (RPC) | Supabase |

### P3 — LOW (Opsiyonel)

| # | Gorev | Kategori |
|---|-------|----------|
| L.3 | Fastlane veya Shorebird entegrasyonu | DevOps |
| L.4 | Performans profili (60fps dogrulama) | QA |
| L.5 | TikTok/Instagram direct share | Growth |

---

## Tamamlanan Ozet

| Oncelik | Tamamlanan | Toplam | Onemli Tamamlananlar |
|---------|:----------:|:------:|----------------------|
| P0 | 5/5 | 5 | Firebase keys, AdMob, Supabase RLS, iOS signing |
| P1 | 8/12 | 12 | Integration test, a11y, cert pinning, UMP consent, cascade fix, bomb pipeline, onLevelComplete, IAP receipt |
| P2 | 7/9 | 9 | Coverage CI, katman ihlali fix, ShapeGenerator refactor |
| P3 | 14/17 | 17 | SoundBank, responsive layout, RTL, theme, smart RNG, shop refactor, PvP reconnect, COPPA, GDPR export |
| Growth T1 | 6/6 | 6 | Streak, confetti, share prompt, combo SFX, tutorial |

**Toplam: 40/49 gorev tamamlandi (%82)**
