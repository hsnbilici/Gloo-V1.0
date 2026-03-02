# Firebase API Key Kisitlama Rehberi

**Proje:** `gloo-f7905`
**Tarih:** 2026-03-02
**Durum:** 2/3 tamamlandi — Web ve iOS kisitlamalari uyguland. Android kaldi.

---

## Icindekiler

1. [On Bilgi](#1-on-bilgi)
2. [Web API Key Kisitlamasi](#2-web-api-key-kisitlamasi)
3. [Android API Key Kisitlamasi](#3-android-api-key-kisitlamasi)
4. [iOS API Key Kisitlamasi](#4-ios-api-key-kisitlamasi)
5. [API Kisitlamalari (Tum Platformlar)](#5-api-kisitlamalari-tum-platformlar)
6. [Dogrulama Adimlari](#6-dogrulama-adimlari)
7. [Geri Alma Plani](#7-geri-alma-plani)
8. [Kontrol Listesi](#8-kontrol-listesi)

---

## 1. On Bilgi

### Neden Kisitlama Gerekli?

Firebase API key'leri `firebase_options.dart`, `google-services.json` ve `GoogleService-Info.plist` dosyalarinda acik metin olarak bulunur. Bu key'ler kaynak kodda ve build artifact'lerde gorunur. Kisitlanmamis bir API key ile:

- Kotu niyetli kullanicilar Firebase kotanizi tuketebilir (Analytics, Crashlytics istekleri)
- Key'iniz baska uygulamalarda kullanilabilir
- Google Cloud faturalandirmanizda beklenmedik artislar olusabilir

### Projede Kullanilan Firebase Servisleri

`pubspec.yaml` ve kaynak kod analizine gore:

| Servis | Paket | Kullanim |
|--------|-------|----------|
| Firebase Core | `firebase_core: ^3.12.0` | Zorunlu temel SDK |
| Firebase Analytics | `firebase_analytics: ^11.4.0` | Oyun olaylari, kullanici davranisi |
| Firebase Crashlytics | `firebase_crashlytics: ^4.3.0` | Hata raporlama, fatal crash yakalama |

**Not:** Projede Firestore, Realtime Database, Authentication veya Cloud Messaging kullanilmiyor. Veri katmani Supabase uzerinden calisiyor.

### API Key Ozeti

| Platform | API Key | Dosya |
|----------|---------|-------|
| Web | `AIzaSyASVKy7u5DSOZYtZ3ikYVnVqEv3ITYHaLE` | `lib/firebase_options.dart` |
| Android | `AIzaSyC-8m-bPO7vv-7M_EHY1AitfMpPNa0HbDo` | `android/app/google-services.json` + `lib/firebase_options.dart` |
| iOS | `AIzaSyBB55ddtzDqtvq4BVPgCW_fWJLB_gSwbJs` | `ios/Runner/GoogleService-Info.plist` + `lib/firebase_options.dart` |

### Onemli Uyarilar

- Kisitlamalarin yayilmasi **5-10 dakika** surebilir. Bu sure icinde uygulamayi test etmeyin.
- Kisitlama yapmadan once **mevcut ayarlarin ekran goruntusunu alin** (geri alma icin).
- Islemleri **dusuk trafik saatlerinde** yapin (ornegin gece 02:00-05:00 arasi).
- Her key'i teker teker kisitlayin ve arada test edin. Ucu birden ayni anda kisitlamayin.

---

## 2. Web API Key Kisitlamasi ✅ TAMAMLANDI

**Key:** `AIzaSyASVKy7u5DSOZYtZ3ikYVnVqEv3ITYHaLE`
**Kisitlama Turu:** HTTP Referrer

### Adimlar

1. **Google Cloud Console'u acin:**
   ```
   https://console.cloud.google.com/apis/credentials?project=gloo-f7905
   ```

2. **API Keys** listesinde Web API key'i bulun. Key degerinin son 4 karakteri `HaLE` ile biten satiri tiklayin.

3. **"Application restrictions"** (Uygulama kisitlamalari) bolumune gidin.

4. **"HTTP referrers (web sites)"** secenegini secin.

5. **"ADD AN ITEM"** butonuna tiklayarak asagidaki referrer'lari ekleyin:

   ```
   gloo-f7905.firebaseapp.com/*
   gloo-f7905.web.app/*
   ```

   Eger custom domain kullaniliyorsa (ornegin `www.gloogame.com`):
   ```
   www.gloogame.com/*
   gloogame.com/*
   ```

   **Localhost gelistirme icin** (uretimde kaldirilmali):
   ```
   localhost:*/*
   127.0.0.1:*/*
   ```

6. **"SAVE"** butonuna tiklayin.

### Referrer Pattern Kurallari

| Pattern | Anlamli |
|---------|---------|
| `*.gloogame.com/*` | Tum subdomain'ler dahil |
| `gloogame.com/*` | Yalnizca ana domain |
| `localhost:*/*` | Tum port'larda localhost |

**UYARI:** Referrer kisitlamasi `Referer` HTTP header'ina dayanir. Bazi tarayici eklentileri veya gizlilik ayarlari bu header'i kaldirabilir. Bu nedenle web key'i icin API kisitlamalari da (Bolum 5) mutlaka uygulanmalidir.

---

## 3. Android API Key Kisitlamasi

**Key:** `AIzaSyC-8m-bPO7vv-7M_EHY1AitfMpPNa0HbDo`
**Kisitlama Turu:** Android app (package name + SHA fingerprint)

### 3.1. SHA-1 ve SHA-256 Fingerprint Alma

#### Debug Keystore (Gelistirme)

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Ciktidan `SHA1:` ve `SHA256:` satirlarini kopyalayin:
```
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA256: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

#### Release Keystore (Uretim)

Projede release keystore yolu `android/app/gloo-release.keystore` olarak tanimli (`build.gradle.kts` icinde):

```bash
keytool -list -v -keystore android/app/gloo-release.keystore -alias gloo
```

Parola sorulacaktir (`key.properties` dosyasindaki `storePassword`).

#### Google Play App Signing Kullaniliyorsa

Google Play Console uzerinden imzalama kullaniliyorsa, Google'in urettigi SHA-1 fingerprint'i de eklemeniz gerekir:

1. [Google Play Console](https://play.google.com/console) > **Uygulamaniz** > **Setup** > **App signing**
2. **"App signing key certificate"** bolumunden `SHA-1 certificate fingerprint` degerini kopyalayin.
3. **"Upload key certificate"** bolumunden de SHA-1 degerini kopyalayin (varsa).

### 3.2. Google Cloud Console'da Kisitlama

1. **Google Cloud Console'u acin:**
   ```
   https://console.cloud.google.com/apis/credentials?project=gloo-f7905
   ```

2. **API Keys** listesinde Android API key'i bulun. Key degerinin son 4 karakteri `HbDo` ile biten satiri tiklayin.

3. **"Application restrictions"** bolumune gidin.

4. **"Android apps"** secenegini secin.

5. **"ADD AN ITEM"** butonuna tiklayin ve asagidaki bilgileri girin:

   **Debug sertifikasi icin:**
   | Alan | Deger |
   |------|-------|
   | Package name | `com.gloogame.app` |
   | SHA-1 certificate fingerprint | Debug keystore'dan aldiginiz SHA-1 |

6. **Tekrar "ADD AN ITEM"** tiklayin ve release sertifikasi icin de ekleyin:

   **Release sertifikasi icin:**
   | Alan | Deger |
   |------|-------|
   | Package name | `com.gloogame.app` |
   | SHA-1 certificate fingerprint | Release keystore'dan aldiginiz SHA-1 |

7. **Google Play App Signing** kullaniliyorsa, ucuncu bir giris daha ekleyin:

   | Alan | Deger |
   |------|-------|
   | Package name | `com.gloogame.app` |
   | SHA-1 certificate fingerprint | Google Play Console'dan aldiginiz SHA-1 |

8. **"SAVE"** butonuna tiklayin.

### 3.3. Onemli Notlar

- SHA-1 degerleri iki noktali (`XX:XX:...`) formatta girilmelidir, bosluksuz.
- Farkli makinelerde gelistirme yapiliyorsa, her makinenin debug keystore SHA-1'i farklidir. Tum gelistiricilerin SHA-1'leri eklenmelidir.
- CI/CD pipeline kullaniliyorsa, CI ortaminin keystore SHA-1'i de eklenmelidir.

---

## 4. iOS API Key Kisitlamasi ✅ TAMAMLANDI

**Key:** `AIzaSyBB55ddtzDqtvq4BVPgCW_fWJLB_gSwbJs`
**Kisitlama Turu:** iOS bundle ID

### Adimlar

1. **Google Cloud Console'u acin:**
   ```
   https://console.cloud.google.com/apis/credentials?project=gloo-f7905
   ```

2. **API Keys** listesinde iOS API key'i bulun. Key degerinin son 4 karakteri `wbJs` ile biten satiri tiklayin.

3. **"Application restrictions"** bolumune gidin.

4. **"iOS apps"** secenegini secin.

5. **"ADD AN ITEM"** butonuna tiklayin ve bundle ID'yi girin:

   | Alan | Deger |
   |------|-------|
   | Bundle ID | `com.gloogame.app` |

6. **macOS** icin de ayni key kullanildigi icin (ayni iOS key `firebase_options.dart`'ta macOS config'inde de var), macOS bundle ID'sini de ekleyin:

   | Alan | Deger |
   |------|-------|
   | Bundle ID | `com.gloogame.app` |

   **Not:** macOS bundle ID farkli olabilir. Xcode'da `Runner.xcodeproj` > **Signing & Capabilities** > **Bundle Identifier** degerini kontrol edin.

7. **"SAVE"** butonuna tiklayin.

### Bundle ID Dogrulama

iOS bundle ID'nin dogru oldugunu Xcode'da teyit edin:

1. `ios/Runner.xcworkspace` dosyasini Xcode ile acin.
2. Sol panelde **Runner** projesini secin.
3. **General** sekmesinde **Bundle Identifier** alanini kontrol edin.
4. `com.gloogame.app` olmalidir.

Alternatif olarak terminal'den:

```bash
grep -A1 "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj | head -5
```

---

## 5. API Kisitlamalari (Tum Platformlar)

Uygulama kisitlamalarinin yani sira, her key'in yalnizca ihtiyac duyulan API'lere erisimi olmalidir. Bu, key sizsa bile saldirganin erisebilecegi servisleri sinirlar.

### 5.1. Gerekli API'ler

Projede kullanilan Firebase servislerine gore her platform icin asagidaki API'ler **etkinlestirilmelidir**:

| API | Aciklama | Web | Android | iOS |
|-----|----------|-----|---------|-----|
| **Firebase Installations API** | Firebase SDK'nin cihaz kaydi icin zorunlu | ✅ | ✅ | ✅ |
| **Firebase Analytics API (Google Analytics for Firebase)** | Oyun olaylari ve kullanici analizi | ✅ | ✅ | ✅ |
| **Firebase Crashlytics API (Firebase Management API)** | Hata raporlama | - | ✅ | ✅ |
| **FCM Registration API** | Firebase Cloud Messaging kaydi (Crashlytics bagimlilik) | - | ✅ | ✅ |
| **Token Service API** | Firebase Auth token yenileme (SDK dahili kullanim) | ✅ | ✅ | ✅ |
| **Firebase Remote Config API** | SDK dahili kullanim icin gerekebilir | ✅ | ✅ | ✅ |

**Not:** Crashlytics web platformunda desteklenmez; bu nedenle Web key'inde Crashlytics API'leri gerekmez.

### 5.2. Her Key Icin API Kisitlama Adimlari

Her ucunu de ayni yontemle yapin:

1. **Google Cloud Console > API Keys** sayfasindan ilgili key'i tiklayin.

2. Sayfanin alt kisminda **"API restrictions"** bolumune gidin.

3. **"Don't restrict key"** secili ise **"Restrict key"** secenegine gecin.

4. **"Select APIs"** dropdown'unu acin.

5. Asagidaki API'leri arayin ve secin:

   **Web Key icin:**
   - [x] Firebase Installations API
   - [x] Google Analytics for Firebase API (veya Firebase Analytics Data API)
   - [x] Token Service API
   - [x] Firebase Remote Config API

   **Android Key icin:**
   - [x] Firebase Installations API
   - [x] Google Analytics for Firebase API
   - [x] Firebase Crashlytics API (veya Firebase Management API)
   - [x] FCM Registration API
   - [x] Token Service API
   - [x] Firebase Remote Config API

   **iOS Key icin:**
   - [x] Firebase Installations API
   - [x] Google Analytics for Firebase API
   - [x] Firebase Crashlytics API (veya Firebase Management API)
   - [x] FCM Registration API
   - [x] Token Service API
   - [x] Firebase Remote Config API

6. **"OK"** ve ardindan **"SAVE"** butonuna tiklayin.

### 5.3. API Listesinde Gorunmuyor mu?

Bazi API'ler etkinlestirilmemis olabilir. Etkinlestirmek icin:

1. **APIs & Services > Enabled APIs & services** sayfasina gidin.
2. **"+ ENABLE APIS AND SERVICES"** butonuna tiklayin.
3. Gerekli API'yi arayip etkinlestirin.
4. Ardindan Bolum 5.2'ye donup key kisitlamasina ekleyin.

---

## 6. Dogrulama Adimlari

Her platform icin kisitlama sonrasi asagidaki testleri yapin. **Kisitlama sonrasi 5-10 dakika bekleyin.**

### 6.1. Web Dogrulamasi

```bash
flutter run -d chrome
```

1. Uygulamayi baslatip bir oyun oynayip oyunu bitirin.
2. Chrome DevTools > **Network** sekmesinde Firebase isteklerini kontrol edin:
   - `firebaseinstallations.googleapis.com` → 200 OK olmali
   - `google-analytics.com` / `analyticsdata.googleapis.com` → 200 OK olmali
3. Chrome DevTools > **Console** sekmesinde Firebase hata mesaji olmadigini dogrulayin.
4. Firebase Console > **Analytics** > **Realtime** sayfasinda olay gorunmeli.

### 6.2. Android Dogrulamasi

```bash
flutter run -d emulator-5554
# veya
flutter run -d "Gloo_Pixel8"
```

1. Uygulamayi baslatip bir oyun oynayip oyunu bitirin.
2. `adb logcat | grep -i firebase` ile logcat'te hata olmadigini dogrulayin.
3. Ozellikle su hata mesajlarini arayin:
   - `API key not valid` → Key kisitlamasi cok dar yapilmis
   - `PERMISSION_DENIED` → API kisitlamasi eksik
   - `Requests from this Android client application ... are blocked` → SHA-1 hatali
4. Firebase Console > **Analytics** > **Realtime** sayfasinda Android olaylarini kontrol edin.
5. Firebase Console > **Crashlytics** sayfasinda cihaz kaydi gorunmeli.

### 6.3. iOS Dogrulamasi

```bash
flutter run -d "iPhone 16 Pro"
```

1. Uygulamayi baslatip bir oyun oynayip oyunu bitirin.
2. Xcode Console'da Firebase hata mesaji olmadigini dogrulayin.
3. Ozellikle su hata mesajlarini arayin:
   - `API key not valid` → Key kisitlamasi cok dar yapilmis
   - `Could not reach Cloud Firestore backend` → (Firestore kullanmiyoruz, gorunmemeli)
   - `Firebase Installations error` → Installations API eksik
4. Firebase Console > **Analytics** > **Realtime** sayfasinda iOS olaylarini kontrol edin.
5. Firebase Console > **Crashlytics** sayfasinda cihaz kaydi gorunmeli.

### 6.4. Negatif Test (Opsiyonel ama Tavsiye Edilen)

Key kisitlamasinin gercekten calistigini dogrulamak icin:

```bash
# Web key'ini yetkisiz bir domain'den kullanmayi deneyin
curl -X POST "https://firebaseinstallations.googleapis.com/v1/projects/gloo-f7905/installations" \
  -H "Content-Type: application/json" \
  -H "x-goog-api-key: AIzaSyASVKy7u5DSOZYtZ3ikYVnVqEv3ITYHaLE" \
  -H "Referer: https://evil-site.com" \
  -d '{"fid":"test","appId":"1:473072331709:web:2ac65616ac1bb901aa80d4","authVersion":"FIS_v2","sdkVersion":"w:0.6.4"}'
```

Bu istek **403 Forbidden** donmelidir. Eger 200 donuyorsa, referrer kisitlamasi dogru uygulanmamis demektir.

---

## 7. Geri Alma Plani

Kisitlama sonrasi uygulama dogru calismiyorsa asagidaki adimlari izleyin.

### 7.1. Hizli Geri Alma (1-2 dakika)

1. **Google Cloud Console > API Keys** sayfasina gidin:
   ```
   https://console.cloud.google.com/apis/credentials?project=gloo-f7905
   ```

2. Sorunlu key'i tiklayin.

3. **Uygulama kisitlamasi icin:**
   - **"Application restrictions"** bolumunde **"None"** secenegini secin.
   - **"SAVE"** tiklayin.

4. **API kisitlamasi icin:**
   - **"API restrictions"** bolumunde **"Don't restrict key"** secenegini secin.
   - **"SAVE"** tiklayin.

5. **5-10 dakika bekleyin** ve uygulamayi tekrar test edin.

### 7.2. Kismi Geri Alma

Sorunu tanimlamak icin kisitlamalari tek tek kaldirabilirssiniz:

1. Once **API kisitlamalarini** kaldin (Restrict key → Don't restrict key).
2. Test edin. Calisiyorsa sorun API kisitlamasindaydi — eksik bir API var.
3. Calisiyorsa, API kisitlamalarini geri koyun ve bu sefer **uygulama kisitlamasini** kaldirin.
4. Test edin. Calisiyorsa sorun uygulama kisitlamasindaydi — referrer/SHA-1/bundle ID hatali.

### 7.3. Hangi Hatalar Hangi Kisitlamadan Kaynaklanir?

| Hata Mesaji | Muhtemel Neden | Cozum |
|-------------|----------------|-------|
| `API key not valid. Please pass a valid API key.` | Key kendisi gecersiz veya silinmis | Cloud Console'dan key'in var oldugunu dogrulayin |
| `Requests from this <platform> client application are blocked.` | Uygulama kisitlamasi (referrer/SHA/bundle) hatali | Platform kisitlamasini kontrol edin |
| `This API key is not authorized to use this service.` | API kisitlamasi — gerekli API secilmemis | "Restrict key" listesine eksik API'yi ekleyin |
| `PERMISSION_DENIED: Firebase Installations API has not been used in project...` | API proje duzeyinde etkinlestirilmemis | APIs & Services > Enable API |
| `403 Forbidden` (genel) | Kisitlama cok dar | Once tum kisitlamalari kaldirip adim adim geri ekleyin |

### 7.4. Ekran Goruntusu Yedegi

**Her kisitlama isleminden once** su sayfalarin ekran goruntusunu alin:

1. Key'in "Application restrictions" bolumu
2. Key'in "API restrictions" bolumu
3. Enabled APIs listesi

Bu goruntuleri `tasks/firebase_key_backup_screenshots/` klasorune kaydedin (veya ekip Wiki'sine).

---

## 8. Kontrol Listesi

### Kisitlama Oncesi

- [ ] Mevcut key ayarlarinin ekran goruntusu alindi
- [ ] Tum platformlarda uygulama dogru calisiyor (baseline test)
- [ ] Dusuk trafik saati secildi
- [ ] Android SHA-1 fingerprint'ler alindi (debug + release + Play signing)
- [ ] iOS bundle ID dogrulandi (`com.gloogame.app`)
- [ ] Web domain'leri belirlendi

### Web Key Kisitlamasi ✅

- [x] HTTP referrer kisitlamasi eklendi
- [x] `gloo-f7905.firebaseapp.com/*` eklendi
- [x] `gloo-f7905.web.app/*` eklendi
- [x] Custom domain eklendi (varsa)
- [x] Gelistirme ortami icin `localhost:*/*` eklendi (gecici)
- [x] API kisitlamasi uyguland — yalnizca gerekli API'ler secildi
- [x] 5-10 dakika beklendi
- [x] Web'de uygulama test edildi ve calisiyor

### Android Key Kisitlamasi

- [ ] Android app kisitlamasi eklendi
- [ ] Package name: `com.gloogame.app`
- [ ] Debug SHA-1 eklendi
- [ ] Release SHA-1 eklendi
- [ ] Google Play App Signing SHA-1 eklendi (varsa)
- [ ] API kisitlamasi uyguland — yalnizca gerekli API'ler secildi
- [ ] 5-10 dakika beklendi
- [ ] Android'de uygulama test edildi ve calisiyor

### iOS Key Kisitlamasi ✅

- [x] iOS app kisitlamasi eklendi
- [x] Bundle ID: `com.gloogame.app` eklendi
- [x] macOS bundle ID eklendi (gerekiyorsa)
- [x] API kisitlamasi uyguland — yalnizca gerekli API'ler secildi
- [x] 5-10 dakika beklendi
- [x] iOS'ta uygulama test edildi ve calisiyor

### Kisitlama Sonrasi

- [ ] Firebase Console > Analytics > Realtime'da 3 platformdan da olay geliyor
- [ ] Firebase Console > Crashlytics'te Android ve iOS cihazlar gorunuyor
- [ ] Negatif test yapildi (yetkisiz erisim engelleniyor)
- [ ] Localhost referrer'i uretimde kaldirildi (web deploy oncesi)
- [ ] Tum ekip uyelerine bilgi verildi

---

## Ek: Faydali Linkler

- [Google Cloud Console — API Credentials](https://console.cloud.google.com/apis/credentials?project=gloo-f7905)
- [Google Cloud Console — Enabled APIs](https://console.cloud.google.com/apis/dashboard?project=gloo-f7905)
- [Firebase Console — Proje Ayarlari](https://console.firebase.google.com/project/gloo-f7905/settings/general)
- [Firebase Dokumantasyonu — API Key Kisitlamalari](https://firebase.google.com/docs/projects/api-keys#restrict_an_api_key)
- [Google Play Console — App Signing](https://play.google.com/console)
