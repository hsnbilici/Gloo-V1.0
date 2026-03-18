# P0 — Store Hazirligi Kullanici Kilavuzu

> Bu kilavuz, Gloo'yu App Store ve Play Store'a gondermeden once **senin (gelistirici)** tamamlaman gereken harici adimlari icerir. Claude Code bu adimlari otomatik yapamaz — her biri konsol erisimi veya hesap gerektiriyor.
>
> Her gorevi tamamladiktan sonra bu dokumandaki kutulari isaretle ve Claude Code'a soyle — kod tarafindaki degisiklikleri o yapacak.

---

## Gerekli Hesaplar

| Hesap | Maliyet | URL |
|-------|---------|-----|
| Google Play Console | $25 (tek sefer) | https://play.google.com/console |
| Apple Developer Program | $99/yil | https://developer.apple.com |
| Google AdMob | Ucretsiz | https://admob.google.com |
| Firebase Console | Ucretsiz | https://console.firebase.google.com |
| Supabase Dashboard | Ucretsiz (mevcut) | https://supabase.com/dashboard |

---

## C.1 — Firebase API Key Kisitlamalari

**Neden:** API key'lerin kisitlanmamasi, baskalarinin senin Firebase kotani tuketmesine veya servislerini kotuye kullanmasina izin verir.

**Mevcut Durum:** 3 platform key'i (web, Android, iOS) Firebase Console'da kisitlanmamis.

### Adimlar

- [ ] **1. Firebase Console'a gir**
  - https://console.firebase.google.com → Proje: `gloo-f7905` → Proje Ayarlari

- [ ] **2. Google Cloud Console'da key kisitlama**
  - Firebase proje ayarlarindan "Manage API keys in Google Cloud Console" linkine tikla
  - Alternatif: https://console.cloud.google.com/apis/credentials?project=gloo-f7905

- [ ] **3. Android key'i kisitla**
  - Key: `AIzaSyC-8m-bPO7vv-7M_EHY1AitfMpPNa0HbDo`
  - "Application restrictions" → "Android apps"
  - "Add an item":
    - Package name: `com.gloogame.app`
    - SHA-1 fingerprint (debug): `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android 2>/dev/null | grep SHA1`
    - SHA-1 fingerprint (release): CI'daki release keystore'dan al
  - "API restrictions" → "Restrict key" → Sadece su API'leri sec:
    - Firebase Installations API
    - Firebase Cloud Messaging API
    - Firebase App Check API
    - Google Analytics API

- [ ] **4. iOS key'i kisitla**
  - Key: `AIzaSyBB55ddtzDqtvq4BVPgCW_fWJLB_gSwbJs`
  - "Application restrictions" → "iOS apps"
  - Bundle ID: `com.gloogame.app`
  - Ayni API restrictions

- [ ] **5. Web key'i kisitla**
  - Key: `AIzaSyASVKy7u5DSOZYtZ3ikYVnVqEv3ITYHaLE`
  - "Application restrictions" → "HTTP referrers"
  - Allowed referrers: senin web domain'in (orn. `gloogame.app/*`)
  - Ayni API restrictions

- [ ] **6. Play Console'dan SHA-1 ekle (store kaydi sonrasi)**
  - Play Console → Uygulaman → Setup → App signing
  - "App signing certificate" SHA-1'i kopyala
  - Google Cloud Console'daki Android key'e bu SHA-1'i ekle

> **Tamamladiginda:** Claude Code'a "C.1 tamamlandi" de. Kod degisikligi gerekmiyor — kisitlamalar console tarafinda.

---

## C.2 — AdMob Test ID'lerini Gercek ID'lerle Degistir

**Neden:** Test ID'lerle reklam geliri elde edemezsin. Store'a test ID ile gonderme — reject sebebi.

**Mevcut Durum:** Tum 6 ad unit ID'si ve 2 App ID'si Google'in resmi test ID'leri.

### Adimlar

- [ ] **1. AdMob hesabi olustur**
  - https://admob.google.com → Yeni uygulama ekle
  - Platform: Android → Package: `com.gloogame.app`
  - Platform: iOS → Bundle ID: `com.gloogame.app`

- [ ] **2. Android icin Ad Unit'ler olustur**
  - AdMob → Apps → Gloo (Android) → Ad units
  - Banner: Yeni olustur → ID'yi not al (orn. `ca-app-pub-XXXXX/YYYYY`)
  - Interstitial: Yeni olustur → ID'yi not al
  - Rewarded: Yeni olustur → ID'yi not al

- [ ] **3. iOS icin Ad Unit'ler olustur**
  - Ayni islem — 3 ad unit (banner, interstitial, rewarded)

- [ ] **4. App ID'leri not al**
  - AdMob → Apps → Gloo (Android) → App settings → App ID (orn. `ca-app-pub-XXXXX~ZZZZZ`)
  - Ayni islem iOS icin

- [ ] **5. ID'leri Claude Code'a ver**

  Claude Code'a su bilgileri paylas:
  ```
  Android App ID: ca-app-pub-XXXXX~ZZZZZ
  iOS App ID: ca-app-pub-XXXXX~ZZZZZ

  Android Banner: ca-app-pub-XXXXX/YYYYY
  Android Interstitial: ca-app-pub-XXXXX/YYYYY
  Android Rewarded: ca-app-pub-XXXXX/YYYYY

  iOS Banner: ca-app-pub-XXXXX/YYYYY
  iOS Interstitial: ca-app-pub-XXXXX/YYYYY
  iOS Rewarded: ca-app-pub-XXXXX/YYYYY
  ```

> **Tamamladiginda:** Claude Code su 3 dosyayi guncelleyecek:
> - `lib/services/ad_manager.dart` (6 ad unit ID)
> - `android/app/src/main/AndroidManifest.xml` (App ID)
> - `ios/Runner/Info.plist` (App ID)

---

## C.4 — API Key'leri `--dart-define` ile CI Secret'a Tasi

**Neden:** Firebase ve Supabase key'leri kaynak kodda acik. Repo public olursa (veya fork edilirse) key'lerin sizar.

**Mevcut Hardcoded Key'ler:**
- `lib/firebase_options.dart` — 3 Firebase API key + project config
- `lib/data/remote/supabase_client.dart` — Supabase URL + anon key

### Adimlar

- [ ] **1. GitHub Repository Secrets ekle**
  - GitHub → Gloo repo → Settings → Secrets and variables → Actions
  - Su secret'lari ekle:

  | Secret Adi | Deger | Nereden |
  |------------|-------|---------|
  | `FIREBASE_API_KEY_WEB` | `AIzaSyASV...` | firebase_options.dart |
  | `FIREBASE_API_KEY_ANDROID` | `AIzaSyC-8...` | firebase_options.dart |
  | `FIREBASE_API_KEY_IOS` | `AIzaSyBB5...` | firebase_options.dart |
  | `FIREBASE_APP_ID_WEB` | `1:473072...` | firebase_options.dart |
  | `FIREBASE_APP_ID_ANDROID` | `1:473072...` | firebase_options.dart |
  | `FIREBASE_APP_ID_IOS` | `1:473072...` | firebase_options.dart |
  | `FIREBASE_MESSAGING_SENDER_ID` | `473072331709` | firebase_options.dart |
  | `FIREBASE_PROJECT_ID` | `gloo-f7905` | firebase_options.dart |
  | `FIREBASE_STORAGE_BUCKET` | `gloo-f7905.firebasestorage.app` | firebase_options.dart |
  | `SUPABASE_URL` | `https://lcumia...` | supabase_client.dart |
  | `SUPABASE_ANON_KEY` | `sb_publishable_p1_...` | supabase_client.dart |

- [ ] **2. Lokal gelistirme icin `.env` dosyasi olustur**
  - Proje kokune `.env` dosyasi olustur (yukaridaki key'lerle)
  - `.gitignore`'a `.env` ekle

- [ ] **3. Claude Code'a soyle**

> **Tamamladiginda:** Claude Code su degisiklikleri yapacak:
> - `firebase_options.dart` → `String.fromEnvironment()` ile okuma
> - `supabase_client.dart` → `String.fromEnvironment()` ile okuma
> - 4 CI workflow → `--dart-define` parametreleri ekleme
> - `.gitignore` → `.env` ekleme

---

## C.5 — Supabase RLS Politikalarini Dogrula

**Neden:** `updateElo()` client'tan degeri dogrudan yaziyor. RLS dogru ayarlanmamissa baska kullanicinin ELO'sunu degistirebilirsin.

**Mevcut Durum:** RLS aktif, RPC fonksiyonlari mevcut. Ama dogrulanmasi gerekiyor.

### Adimlar

- [ ] **1. Supabase Dashboard'a gir**
  - https://supabase.com/dashboard → Proje: `lcumiadyvwharxhrbtkm`
  - SQL Editor'a gir

- [ ] **2. RLS politikalarini kontrol et**
  ```sql
  SELECT schemaname, tablename, policyname, cmd, qual
  FROM pg_policies
  WHERE schemaname = 'public'
  ORDER BY tablename, cmd;
  ```

  Her tablo icin kontrol et:
  - `profiles` UPDATE → `auth.uid() = id` olmali (sadece kendi profilini)
  - `scores` INSERT → Dogrudan INSERT kapali, sadece `submit_score()` RPC ile
  - `pvp_matches` UPDATE → Dogrudan UPDATE kapali, sadece `submit_pvp_score()` RPC ile

- [ ] **3. RPC fonksiyonlarini kontrol et**
  ```sql
  SELECT proname, prosrc FROM pg_proc
  WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
  AND proname IN ('submit_score', 'submit_pvp_score');
  ```

  Kontrol et:
  - `submit_score()` → Skor limiti dogrulamasi var mi? (mod bazli max skor)
  - `submit_pvp_score()` → auth.uid() ile oyuncu dogrulamasi var mi?

- [ ] **4. ELO manipulasyonu testi**
  ```sql
  -- Bu sorgu basarili OLMAMALI (RLS engellemeli):
  UPDATE profiles SET elo = 9999 WHERE id != auth.uid();
  ```

- [ ] **5. Eksik migration'lari deploy et**
  - `supabase/schema.sql` dosyasindaki RPC'leri Supabase SQL Editor'da calistir
  - Edge Function: `supabase/functions/redeem-code/` deploy et (varsa)

> **Tamamladiginda:** Claude Code'a RLS sonuclarini paylas. Eksiklik varsa sunucu tarafinda ELO hesaplama (M.20) onceliklendirilecek.

---

## C.6 — iOS Code Signing + TestFlight Pipeline

**Neden:** iOS'ta imzasiz uygulama dagitilamaz. TestFlight olmadan beta test yapamazsin, App Store'a gonderemezsin.

**Mevcut Durum:** CI sadece simulator build'i yapiyor. Release signing tamamen eksik.

### Adimlar

#### A. Apple Developer Hesabi

- [ ] **1. Apple Developer Program'a katil**
  - https://developer.apple.com/programs/ → Enroll ($99/yil)
  - Team ID'ni not al (orn. `ABCDE12345`)

- [ ] **2. App ID olustur**
  - Apple Developer → Certificates, Identifiers & Profiles → Identifiers
  - "+" → App IDs → Platform: iOS
  - Bundle ID: `com.gloogame.app` (Explicit)
  - Capabilities: In-App Purchase, Push Notifications (gerekirse)

#### B. Sertifikalar

- [ ] **3. Distribution Certificate olustur**
  - Mac'te: Keychain Access → Certificate Assistant → Request a Certificate From a Certificate Authority
  - Apple Developer → Certificates → "+" → iOS Distribution (App Store)
  - CSR dosyasini yukle → Certificate'i indir (.cer)
  - Keychain'e cift tikla ile ekle
  - Keychain'den .p12 olarak export et (sifre belirle)

- [ ] **4. Provisioning Profile olustur**
  - Apple Developer → Profiles → "+" → App Store Distribution
  - App ID: `com.gloogame.app` sec
  - Certificate: Az once olusturdugunu sec
  - Indir (.mobileprovision)

#### C. Xcode Yapilandirmasi

- [ ] **5. Xcode'da signing ayarla**
  - `ios/Runner.xcworkspace`'i Xcode ile ac
  - Runner target → Signing & Capabilities
  - Team: Apple Developer hesabini sec
  - Bundle Identifier: `com.gloogame.app`
  - "Automatically manage signing" → Debug icin ON
  - Release icin: Manual signing, provisioning profile sec

#### D. GitHub CI Secrets

- [ ] **6. Sertifikalari base64'e cevir**
  ```bash
  base64 -i distribution.p12 -o cert_base64.txt
  base64 -i profile.mobileprovision -o profile_base64.txt
  ```

- [ ] **7. GitHub Secrets ekle**
  | Secret | Deger |
  |--------|-------|
  | `IOS_CERT_BASE64` | cert_base64.txt icerigi |
  | `IOS_CERT_PASSWORD` | .p12 export sifresi |
  | `IOS_PROFILE_BASE64` | profile_base64.txt icerigi |
  | `IOS_TEAM_ID` | Apple Developer Team ID |
  | `APPSTORE_CONNECT_KEY_ID` | App Store Connect API Key ID |
  | `APPSTORE_CONNECT_ISSUER_ID` | Issuer ID |
  | `APPSTORE_CONNECT_KEY_BASE64` | .p8 private key (base64) |

- [ ] **8. App Store Connect API Key olustur** (TestFlight upload icin)
  - https://appstoreconnect.apple.com → Users and Access → Keys
  - "+" → Name: "CI Upload" → Access: App Manager
  - Key ID, Issuer ID ve .p8 dosyasini indir

> **Tamamladiginda:** Claude Code su degisiklikleri yapacak:
> - `ios/Runner.xcodeproj/project.pbxproj` → Signing config
> - `.github/workflows/ios_build.yml` → Release build + TestFlight upload

---

## Oncelik Sirasi (Onerilen)

```
1. C.4 (API key'leri secret'a tasi)     ← En kritik guvenlik riski
2. C.1 (Firebase key kisitlamalari)      ← Console'da 5 dk islem
3. C.5 (Supabase RLS dogrula)            ← SQL sorgulari calistir
4. C.6 (iOS signing)                     ← Apple Developer hesabi gerekli
5. C.2 (AdMob gercek ID)                 ← Store submit oncesi son adim
```

C.4 ve C.1 hemen yapilabiir. C.6 Apple Developer hesabi gerektirir. C.2 en sona birakilabilir (store submit gunu).
