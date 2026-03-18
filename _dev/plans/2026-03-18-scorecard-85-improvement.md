# Scorecard 74.5 → 85+ İyileştirme Planı

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Code review'da tespit edilen kritik ve önemli sorunları düzelterek composite score'u 74.5'ten 85+'a çıkarmak.

**Architecture:** Güvenlik (defaultValue temizliği, isConfigured fix), CI/CD (test/analyze ekleme), ve Ad ID'lerin dart-define'a taşınması olmak üzere 3 ana eksende iyileştirme.

**Tech Stack:** Flutter 3.41, Dart, GitHub Actions, Supabase, Firebase, AdMob

---

### Task 1: Firebase defaultValue'lardan gerçek key'leri kaldır (Security +10)

**Files:**
- Modify: `lib/firebase_options.dart:27-62`

- [ ] **Step 1: defaultValue'ları boş string yap**

`firebase_options.dart`'taki tüm `defaultValue:` parametrelerini boş string ile değiştir:

```dart
static const _apiKeyWeb = String.fromEnvironment(
  'FIREBASE_API_KEY_WEB',
  defaultValue: '',
);
static const _apiKeyAndroid = String.fromEnvironment(
  'FIREBASE_API_KEY_ANDROID',
  defaultValue: '',
);
static const _apiKeyIos = String.fromEnvironment(
  'FIREBASE_API_KEY_IOS',
  defaultValue: '',
);
static const _appIdWeb = String.fromEnvironment(
  'FIREBASE_APP_ID_WEB',
  defaultValue: '',
);
static const _appIdAndroid = String.fromEnvironment(
  'FIREBASE_APP_ID_ANDROID',
  defaultValue: '',
);
static const _appIdIos = String.fromEnvironment(
  'FIREBASE_APP_ID_IOS',
  defaultValue: '',
);
static const _messagingSenderId = String.fromEnvironment(
  'FIREBASE_MESSAGING_SENDER_ID',
  defaultValue: '',
);
static const _projectId = String.fromEnvironment(
  'FIREBASE_PROJECT_ID',
  defaultValue: '',
);
static const _storageBucket = String.fromEnvironment(
  'FIREBASE_STORAGE_BUCKET',
  defaultValue: '',
);
```

- [ ] **Step 2: isConfigured guard ekle**

`DefaultFirebaseOptions` sınıfına static guard ekle:

```dart
/// Firebase key'leri --dart-define ile verilmis mi?
static bool get isConfigured =>
    _apiKeyWeb.isNotEmpty && _projectId.isNotEmpty;
```

- [ ] **Step 3: .env dosyasını güncelle**

`.env` dosyasındaki key'ler lokal geliştirme için hala çalışacak. `.env`'den `--dart-define` parametrelerine çeviren helper script'i kontrol et. Lokal çalıştırmada `--dart-define-from-file=.env` kullanılacak.

- [ ] **Step 4: Testlerin geçtiğini doğrula**

Run: `flutter test`
Expected: 1220 test PASS

- [ ] **Step 5: Commit**

```bash
git add lib/firebase_options.dart
git commit -m "security: remove real API keys from defaultValue in firebase_options"
```

---

### Task 2: Supabase isConfigured guard'ını düzelt (Security +5)

**Files:**
- Modify: `lib/data/remote/supabase_client.dart:14-26`

- [ ] **Step 1: defaultValue'ları boş string yap**

```dart
static const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: '',
);
static const supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: '',
);
```

- [ ] **Step 2: isConfigured guard'ını güncelle**

```dart
static bool get isConfigured =>
    supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
```

- [ ] **Step 3: Testlerin geçtiğini doğrula**

Run: `flutter test`
Expected: 1220 test PASS

- [ ] **Step 4: Commit**

```bash
git add lib/data/remote/supabase_client.dart
git commit -m "security: fix isConfigured guard — use empty defaults instead of real keys"
```

---

### Task 3: CI workflow'larına test ve analyze adımı ekle (CI/CD +8)

**Files:**
- Modify: `.github/workflows/web_build.yml`
- Modify: `.github/workflows/android_build.yml`
- Modify: `.github/workflows/ios_build.yml`

- [ ] **Step 1: web_build.yml'a test/analyze ekle**

`Install dependencies` adımından sonra, `Build web release` adımından önce ekle:

```yaml
      - name: Analyze
        run: flutter analyze --no-fatal-infos

      - name: Run tests
        run: flutter test
```

- [ ] **Step 2: android_build.yml'a test/analyze ekle**

`build-apk` job'unda `Install dependencies` sonrasına ekle:

```yaml
      - name: Analyze
        run: flutter analyze --no-fatal-infos

      - name: Run tests
        run: flutter test
```

- [ ] **Step 3: android_build.yml'da continue-on-error kaldır**

`build-aab` job'undaki `Build release AAB` step'inden `continue-on-error: true` satırını sil.

- [ ] **Step 4: ios_build.yml'a test/analyze ekle**

`build-simulator` job'unda `Install dependencies` sonrasına ekle:

```yaml
      - name: Analyze
        run: flutter analyze --no-fatal-infos

      - name: Run tests
        run: flutter test
```

- [ ] **Step 5: Commit**

```bash
git add .github/workflows/web_build.yml .github/workflows/android_build.yml .github/workflows/ios_build.yml
git commit -m "ci: add test and analyze steps to all build workflows"
```

---

### Task 4: Ad ID'leri --dart-define'a taşı (Monetization +5, Security +3)

**Files:**
- Modify: `lib/services/ad_manager.dart:43-59`
- Modify: `.github/workflows/android_build.yml`
- Modify: `.github/workflows/ios_build.yml`
- Modify: `.env`

- [ ] **Step 1: Ad ID'leri String.fromEnvironment'a çevir**

`ad_manager.dart`'ta mevcut getter'ları değiştir:

```dart
// ── Reklam ID'leri ───────────────────────────────────────────────────────
// --dart-define ile inject edilir. Boş ise test ID kullanılır.
static const _bannerIdIos = String.fromEnvironment('AD_BANNER_IOS');
static const _bannerIdAndroid = String.fromEnvironment('AD_BANNER_ANDROID');
static const _interstitialIdIos = String.fromEnvironment('AD_INTERSTITIAL_IOS');
static const _interstitialIdAndroid = String.fromEnvironment('AD_INTERSTITIAL_ANDROID');
static const _rewardedIdIos = String.fromEnvironment('AD_REWARDED_IOS');
static const _rewardedIdAndroid = String.fromEnvironment('AD_REWARDED_ANDROID');

static const _kTestBannerIos = 'ca-app-pub-3940256099942544/2435281174';
static const _kTestBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
static const _kTestInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';
static const _kTestInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
static const _kTestRewardedIos = 'ca-app-pub-3940256099942544/1712485313';
static const _kTestRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';

static String get _kBanner => _isIOS
    ? (_bannerIdIos.isNotEmpty ? _bannerIdIos : _kTestBannerIos)
    : (_bannerIdAndroid.isNotEmpty ? _bannerIdAndroid : _kTestBannerAndroid);
static String get _kInterstitial => _isIOS
    ? (_interstitialIdIos.isNotEmpty ? _interstitialIdIos : _kTestInterstitialIos)
    : (_interstitialIdAndroid.isNotEmpty ? _interstitialIdAndroid : _kTestInterstitialAndroid);
static String get _kRewarded => _isIOS
    ? (_rewardedIdIos.isNotEmpty ? _rewardedIdIos : _kTestRewardedIos)
    : (_rewardedIdAndroid.isNotEmpty ? _rewardedIdAndroid : _kTestRewardedAndroid);
```

- [ ] **Step 2: .env'ye test ad ID'leri ekle**

`.env` dosyasına ekle (boş bırak — test ID fallback kullanılacak):

```
AD_BANNER_IOS=
AD_BANNER_ANDROID=
AD_INTERSTITIAL_IOS=
AD_INTERSTITIAL_ANDROID=
AD_REWARDED_IOS=
AD_REWARDED_ANDROID=
```

- [ ] **Step 3: Testlerin geçtiğini doğrula**

Run: `flutter test`
Expected: 1220 test PASS

- [ ] **Step 4: Commit**

```bash
git add lib/services/ad_manager.dart .env
git commit -m "feat: make ad unit IDs configurable via --dart-define with test ID fallback"
```

---

### Task 5: Lokal geliştirme için --dart-define-from-file desteği (DevOps +3)

**Files:**
- Create: `scripts/run_local.sh`
- Modify: `CLAUDE.md` (komutlar bölümü)

- [ ] **Step 1: Helper script oluştur**

```bash
#!/bin/bash
# Lokal gelistirme — .env'den dart-define inject eder
flutter run --dart-define-from-file=.env "$@"
```

- [ ] **Step 2: Çalıştırılabilir yap**

Run: `chmod +x scripts/run_local.sh`

- [ ] **Step 3: CLAUDE.md'ye komutu ekle**

Komutlar bölümüne ekle:
```
./scripts/run_local.sh -d chrome          # .env ile web'de calistir
./scripts/run_local.sh -d "iPhone 17 Pro" # .env ile iOS'ta calistir
```

- [ ] **Step 4: Commit**

```bash
git add scripts/run_local.sh CLAUDE.md
git commit -m "devops: add run_local.sh for --dart-define-from-file convenience"
```

---

### Task 6: Doğrulama ve final build (Store Readiness +5)

**Files:** Tüm proje

- [ ] **Step 1: Analyze**

Run: `flutter analyze --no-fatal-infos`
Expected: 14 info (değişmemiş)

- [ ] **Step 2: Testler**

Run: `flutter test`
Expected: 1220 test PASS

- [ ] **Step 3: Web build (--dart-define-from-file ile)**

Run: `flutter build web --release --dart-define-from-file=.env`
Expected: ✓ Built build/web

- [ ] **Step 4: Android build**

Run: `flutter build apk --debug --dart-define-from-file=.env`
Expected: ✓ Built build/app/outputs/flutter-apk/app-debug.apk

- [ ] **Step 5: iOS build**

Run: `flutter build ios --debug --simulator --dart-define-from-file=.env`
Expected: ✓ Built build/ios/iphonesimulator/Runner.app

- [ ] **Step 6: Push**

```bash
git push origin main
```

---

## Beklenen Skor İyileştirmesi

| Dimension | Önce | Sonra | Delta | Neden |
|---|:---:|:---:|:---:|---|
| Security | 62 | 80 | +18 | defaultValue temizliği, isConfigured fix |
| CI/CD & DevOps | 76 | 87 | +11 | test/analyze tüm pipeline'larda |
| Monetization | 77 | 82 | +5 | Ad ID'ler dart-define'da |
| Store Readiness | 68 | 78 | +10 | Key'ler temiz, CI güvenilir |
| **Composite** | **74.5** | **~82** | **+7.5** | |

> Not: 85+ hedefi için ek olarak integration test, responsive design ve accessibility iyileştirmesi gerekir — bunlar ayrı sprint'te planlanmalı.
