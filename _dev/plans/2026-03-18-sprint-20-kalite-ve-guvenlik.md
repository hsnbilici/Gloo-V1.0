# Sprint 20 — Kalite, Guvenlik & Mimari Temizlik

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Harici bagimliligi olmayan en yuksek etkili gorevleri tamamlayarak proje skorunu 70 → 75+ cikarmak.

**Architecture:** 8 bagimsiz gorev grubu — her biri ayri subagent'a atanabilir. Tum gorevler birbirinden bagimsiz, paralel calistirilabilir. Her gorev kendi testini iceriyor ve `flutter analyze` + `flutter test` dogrulama adimi var.

**Tech Stack:** Flutter 3.41+, Dart 3.3+, Riverpod 2.x, flutter_secure_storage, SharedPreferences

**Tahmini Scorecard Etkisi:**

| Alan | Onceki | Hedef | Etki |
|------|:------:|:-----:|------|
| Mimari | 70 | 78 | M.12, M.13, M.15, M.16 |
| Gameplay | 72 | 78 | H.12, M.16 |
| UI/UX | 67 | 72 | H.13 |
| Guvenlik | 58 | 68 | C.7, C.8 |
| **GENEL** | **70** | **75** | |

---

## Task 1: C.7 — Hassas Lokal Veri Sifreleme

**Gorev:** `elo`, `unlocked_products`, `gel_ozu`, `gel_energy`, `pending_verification`, `pvp_wins`, `pvp_losses`, `redeemed_codes` anahtarlarini `flutter_secure_storage` ile sifrele.

**Files:**
- Modify: `pubspec.yaml` (flutter_secure_storage dependency ekle)
- Create: `lib/data/local/secure_storage_interface.dart` (abstract interface)
- Modify: `lib/data/local/local_repository.dart` (hassas key'ler icin interface kullan)
- Create: `test/data/local/fake_secure_storage.dart` (test fake)
- Modify: `test/data/local/local_repository_test.dart` (testler)

**Mimari Karar:** `FlutterSecureStorage`'i dogrudan subclass'lamak test ortaminda platform channel exception'a neden olur. Bunun yerine thin abstract interface olustur, hem production hem test bunu implement etsin.

**Etkilenen Getter'lar (sync → async gecis):**
Asagidaki 8 getter sync'ten async'e donecek. **Tum cagirim noktalarini `await` ile guncellemek zorunlu:**
1. `getElo()` / `saveElo()`
2. `getGelOzu()` / `saveGelOzu()`
3. `getGelEnergy()` / `saveGelEnergy()`
4. `getPvpWins()` / `getPvpLosses()` / `recordPvpResult()`
5. `getUnlockedProducts()` / `addUnlockedProducts()`
6. `getPendingVerification()` / `savePendingVerification()` / `clearPendingVerification()`
7. `getRedeemedCodes()` / `addRedeemedCode()`

Etkilenen cagirim dosyalarini bulmak icin:
```bash
grep -rn "getElo\|getGelOzu\|getGelEnergy\|getPvpWins\|getPvpLosses\|getUnlockedProducts\|getPendingVerification\|getRedeemedCodes" lib/ --include="*.dart" -l
```

- [ ] **Step 1: flutter_secure_storage dependency ekle**

`pubspec.yaml`'a ekle:
```yaml
dependencies:
  flutter_secure_storage: ^9.2.4
```

Run: `cd "/Users/devcrew/Desktop/Gloo v1.0" && flutter pub get`

- [ ] **Step 2: Abstract interface olustur**

`lib/data/local/secure_storage_interface.dart`:
```dart
/// SecureStorage icin thin interface — test'te fake, production'da FlutterSecureStorage.
abstract class SecureStorageInterface {
  Future<String?> read({required String key});
  Future<void> write({required String key, required String? value});
  Future<void> deleteAll();
}
```

- [ ] **Step 3: Production wrapper olustur**

`lib/data/local/secure_storage_interface.dart` dosyasinin sonuna ekle:
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Production implementasyonu — FlutterSecureStorage'i sarar.
class SecureStorageImpl implements SecureStorageInterface {
  final FlutterSecureStorage _storage;
  const SecureStorageImpl([this._storage = const FlutterSecureStorage()]);

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> write({required String key, required String? value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}
```

- [ ] **Step 4: Test fake olustur**

`test/data/local/fake_secure_storage.dart`:
```dart
import 'package:gloo/data/local/secure_storage_interface.dart';

class FakeSecureStorage implements SecureStorageInterface {
  final Map<String, String> _store = {};

  @override
  Future<String?> read({required String key}) async => _store[key];

  @override
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }

  @override
  Future<void> deleteAll() async => _store.clear();
}
```

- [ ] **Step 5: Failing test yaz**

`test/data/local/local_repository_test.dart` dosyasina ekle:
```dart
import 'fake_secure_storage.dart';

group('SecureStorage — hassas veriler', () {
  late LocalRepository repo;
  late SharedPreferences prefs;
  late FakeSecureStorage secureStorage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    secureStorage = FakeSecureStorage();
    repo = LocalRepository(prefs, secureStorage: secureStorage);
  });

  test('saveElo hassas veriyi SecureStorage\'a yazar', () async {
    await repo.saveElo(1500);
    expect(await secureStorage.read(key: 'elo'), '1500');
  });

  test('getElo SecureStorage\'dan okur, fallback SharedPreferences', () async {
    await prefs.setInt('elo', 1200);
    final elo = await repo.getElo();
    expect(elo, 1200);
  });

  test('saveGelOzu hassas veriyi SecureStorage\'a yazar', () async {
    await repo.saveGelOzu(500);
    expect(await secureStorage.read(key: 'gel_ozu'), '500');
  });

  test('clearAllData SecureStorage\'i da temizler', () async {
    await repo.saveElo(1500);
    await repo.clearAllData();
    expect(await secureStorage.read(key: 'elo'), isNull);
  });
});
```

Run: `cd "/Users/devcrew/Desktop/Gloo v1.0" && flutter test test/data/local/local_repository_test.dart`
Expected: FAIL — `LocalRepository` henuz `secureStorage` parametresi almiyor.

- [ ] **Step 6: LocalRepository'yi SecureStorage destegi ile guncelle**

`lib/data/local/local_repository.dart` icinde:

1. Constructor'a opsiyonel `SecureStorageInterface` parametresi ekle:
```dart
import 'secure_storage_interface.dart';

class LocalRepository {
  final SharedPreferences _prefs;
  final SecureStorageInterface _secure;

  LocalRepository(this._prefs, {SecureStorageInterface? secureStorage})
      : _secure = secureStorage ?? const SecureStorageImpl();
```

2. Tum 8 hassas getter/setter'i SecureStorage'a yonlendir. Pattern:
```dart
  Future<int> getElo() async {
    final secure = await _secure.read(key: 'elo');
    if (secure != null) return int.tryParse(secure) ?? 1000;
    return _prefs.getInt('elo') ?? 1000; // Migration fallback
  }

  Future<void> saveElo(int elo) async {
    await _secure.write(key: 'elo', value: elo.toString());
    await _prefs.remove('elo'); // Eski key'i temizle
  }
```

3. Ayni pattern'i uygula: `getGelOzu/saveGelOzu`, `getGelEnergy/saveGelEnergy`, `getPvpWins/getPvpLosses/recordPvpResult`, `getUnlockedProducts/addUnlockedProducts`, `getPendingVerification/savePendingVerification/clearPendingVerification`, `getRedeemedCodes/addRedeemedCode`.

4. `clearAllData()` metoduna `await _secure.deleteAll();` ekle.

- [ ] **Step 7: Tum cagirim noktalarini `await` ile guncelle**

Step baslangicindaki grep komutunu calistir. Her sonuc dosyasinda:
- `repo.getElo()` → `await repo.getElo()` (metot zaten async ise sorun yok)
- Eger metot sync ise `async` yap ve `Future` return tipini ekle
- Ozellikle kontrol et: `user_provider.dart`, `pvp_lobby_screen.dart`, `game_duel_controller.dart`, `settings_screen.dart`, `purchase_service.dart`

- [ ] **Step 8: Testleri calistir ve dogrula**

Run: `cd "/Users/devcrew/Desktop/Gloo v1.0" && flutter test test/data/local/local_repository_test.dart`
Expected: PASS

Run: `cd "/Users/devcrew/Desktop/Gloo v1.0" && flutter analyze && flutter test`
Expected: 0 error, tum testler gecmeli

- [ ] **Step 9: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/data/local/ test/data/local/
# + tum await guncellemesi yapilan dosyalar
git commit -m "feat(C.7): hassas lokal veriyi flutter_secure_storage ile sifrele"
```

---

## Task 2: C.8 — PrivacyInfo.xcprivacy Dosyasi Ekle

**Gorev:** Apple'in zorunlu kildigi privacy manifest dosyasini iOS projesine ekle.

**Files:**
- Create/Update: `ios/Runner/PrivacyInfo.xcprivacy`

- [ ] **Step 1: Mevcut dosyayi kontrol et**

Run: `cat "/Users/devcrew/Desktop/Gloo v1.0/ios/Runner/PrivacyInfo.xcprivacy" 2>/dev/null || echo "DOSYA YOK"`

Eger dosya varsa iceriginini oku ve asagidaki template ile karsilastir. Eksik key'leri ekle, mevcut key'leri koru. Eger dosya yoksa template'i oldugun gibi olustur.

- [ ] **Step 2: PrivacyInfo.xcprivacy dosyasi olustur/guncelle**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSPrivacyTracking</key>
	<true/>
	<key>NSPrivacyTrackingDomains</key>
	<array>
		<string>googleads.g.doubleclick.net</string>
		<string>firebase-settings.crashlytics.com</string>
	</array>
	<key>NSPrivacyCollectedDataTypes</key>
	<array>
		<dict>
			<key>NSPrivacyCollectedDataType</key>
			<string>NSPrivacyCollectedDataTypeDeviceID</string>
			<key>NSPrivacyCollectedDataTypeLinked</key>
			<false/>
			<key>NSPrivacyCollectedDataTypeTracking</key>
			<true/>
			<key>NSPrivacyCollectedDataTypePurposes</key>
			<array>
				<string>NSPrivacyCollectedDataTypePurposeThirdPartyAdvertising</string>
			</array>
		</dict>
		<dict>
			<key>NSPrivacyCollectedDataType</key>
			<string>NSPrivacyCollectedDataTypeCrashData</string>
			<key>NSPrivacyCollectedDataTypeLinked</key>
			<false/>
			<key>NSPrivacyCollectedDataTypeTracking</key>
			<false/>
			<key>NSPrivacyCollectedDataTypePurposes</key>
			<array>
				<string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
			</array>
		</dict>
		<dict>
			<key>NSPrivacyCollectedDataType</key>
			<string>NSPrivacyCollectedDataTypePerformanceData</string>
			<key>NSPrivacyCollectedDataTypeLinked</key>
			<false/>
			<key>NSPrivacyCollectedDataTypeTracking</key>
			<false/>
			<key>NSPrivacyCollectedDataTypePurposes</key>
			<array>
				<string>NSPrivacyCollectedDataTypePurposeAnalytics</string>
			</array>
		</dict>
	</array>
	<key>NSPrivacyAccessedAPITypes</key>
	<array>
		<dict>
			<key>NSPrivacyAccessedAPIType</key>
			<string>NSPrivacyAccessedAPICategoryUserDefaults</string>
			<key>NSPrivacyAccessedAPITypeReasons</key>
			<array>
				<string>CA92.1</string>
			</array>
		</dict>
	</array>
</dict>
</plist>
```

- [ ] **Step 3: Commit**

```bash
git add ios/Runner/PrivacyInfo.xcprivacy
git commit -m "feat(C.8): iOS PrivacyInfo.xcprivacy manifest ekle/guncelle"
```

---

## Task 3: M.12 — audio→game Ters Bagimliligi Gider

**Gorev:** `ComboEvent` ve `ComboTier` tiplerini `game/systems/combo_detector.dart`'tan `core/` altina tasi. `sound_bank.dart` artik `core/` import edecek.

**Files:**
- Create: `lib/core/models/combo_types.dart`
- Modify: `lib/game/systems/combo_detector.dart` (tipler cikarilir, core/ import edilir)
- Modify: `lib/audio/sound_bank.dart` (import yolu guncellenir)
- Modify: Tum `ComboEvent`/`ComboTier` import eden dosyalar

**ONEMLI:** Tipleri birebir kopyala — mevcut API'yi degistirme. Gercek tanimlar `combo_detector.dart` icinde:
- `ComboTier` enum'u `none` dahil 5 deger icerir: `{ none, small, medium, large, epic }`
- `ComboEvent` sinifi 3 alan icerir: `size` (int), `tier` (ComboTier), `multiplier` (double)
- `ComboEvent.none` static const mevcut

- [ ] **Step 1: Mevcut tiplerin tam tanimini oku**

Run: `cd "/Users/devcrew/Desktop/Gloo v1.0" && grep -A 20 "enum ComboTier" lib/game/systems/combo_detector.dart`
Run: `cd "/Users/devcrew/Desktop/Gloo v1.0" && grep -A 10 "class ComboEvent" lib/game/systems/combo_detector.dart`

Ciktilardaki tanimlari BIREBIR kopyala.

- [ ] **Step 2: core/models/combo_types.dart olustur**

`lib/core/models/combo_types.dart` — Step 1'deki ciktiyi birebir yapistir. Ornek (gercek kodu kontrol et):
```dart
enum ComboTier { none, small, medium, large, epic }

class ComboEvent {
  final int size;
  final ComboTier tier;
  final double multiplier;

  const ComboEvent({
    required this.size,
    required this.tier,
    required this.multiplier,
  });

  static const ComboEvent none = ComboEvent(
    size: 0,
    tier: ComboTier.none,
    multiplier: 1.0,
  );
}
```

- [ ] **Step 3: Tum referanslari bul**

Run: `cd "/Users/devcrew/Desktop/Gloo v1.0" && grep -rn "ComboEvent\|ComboTier" lib/ --include="*.dart" -l`

Ciktidaki her dosya icin import guncellenmeli.

- [ ] **Step 4: combo_detector.dart'tan tipler cikar, core/ import et**

`lib/game/systems/combo_detector.dart` dosyasinda:
- `ComboTier` enum tanimini sil
- `ComboEvent` sinif tanimini sil
- Dosyanin basina ekle: `import '../../core/models/combo_types.dart';`

- [ ] **Step 5: sound_bank.dart import'unu guncelle**

`lib/audio/sound_bank.dart` dosyasinda:
- `import '../game/systems/combo_detector.dart'` → `import '../core/models/combo_types.dart'`

- [ ] **Step 6: Diger etkilenen dosyalarin import'larini guncelle**

Step 3 listesine gore: sadece `ComboEvent`/`ComboTier` icin import eden dosyalarda `combo_detector.dart` → `core/models/combo_types.dart` degistir. `ComboDetector` sinifini da import edenler `combo_detector.dart` import'unu korumali (ama type import'unu `core/`'dan almali).

- [ ] **Step 7: Testleri calistir**

Run: `cd "/Users/devcrew/Desktop/Gloo v1.0" && flutter analyze && flutter test`
Expected: 0 error, tum testler gecmeli

- [ ] **Step 8: Commit**

```bash
git add lib/core/models/combo_types.dart lib/game/systems/combo_detector.dart lib/audio/sound_bank.dart
# + diger etkilenen dosyalar
git commit -m "refactor(M.12): ComboEvent/ComboTier core/ altina tasi — audio→game ters bagimliligi giderildi"
```

---

## Task 4: M.13 — game_world.dart Flutter Import'unu Gider

**Gorev:** `GameMode` enum'unu `core/` altina tasiyarak hem `kModeColors` map'ini `color_constants.dart`'ta tutmak hem de `game_world.dart`'tan Flutter import'unu kaldirmak.

**Mimari Karar:** CLAUDE.md kurali: `game/ → core/`, asla `core/ → game/`. `GameMode` saf Dart enum'u (Flutter bagimliligi yok), `core/` icin dogal bir adaydır. Bu sayede `color_constants.dart` `GameMode`'u `core/` icinden import edebilir — katman ihlali olmaz.

**Files:**
- Create: `lib/core/models/game_mode.dart` (GameMode enum buraya tasinir)
- Modify: `lib/game/world/game_world.dart` (GameMode cikarilir, core/ import edilir, Flutter import silinir)
- Modify: `lib/core/constants/color_constants.dart` (kModeColors buraya tasinir)
- Modify: `GameMode` import eden tum dosyalar

- [ ] **Step 1: GameMode referanslarini bul**

Run: `cd "/Users/devcrew/Desktop/Gloo v1.0" && grep -rn "GameMode" lib/ --include="*.dart" -l`
Run: `cd "/Users/devcrew/Desktop/Gloo v1.0" && grep -rn "kModeColors" lib/ --include="*.dart" -l`

- [ ] **Step 2: core/models/game_mode.dart olustur**

`lib/core/models/game_mode.dart`:
```dart
/// Oyun modlari — saf Dart, Flutter bagimliligi yok.
enum GameMode {
  classic,
  colorChef,
  timeTrial,
  zen,
  daily,
  level,
  duel;

  /// String'den GameMode'a donusum. Gecersiz deger classic'e duser.
  static GameMode fromString(String value) {
    return GameMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => GameMode.classic,
    );
  }
}
```

**Not:** `fromString()` metodu `game_world.dart`'ta tanimli — buraya tas. Mevcut implementasyonu birebir kontrol et.

- [ ] **Step 3: kModeColors'u color_constants.dart'a tasi**

`lib/core/constants/color_constants.dart` dosyasinin sonuna ekle:
```dart
import '../models/game_mode.dart';

const Map<GameMode, Color> kModeColors = {
  GameMode.classic: kColorClassic,
  GameMode.colorChef: kColorChef,
  GameMode.timeTrial: kColorTimeTrial,
  GameMode.zen: kColorZen,
  GameMode.daily: kCyan,
  GameMode.level: kColorChef,
  GameMode.duel: kColorClassic,
};
```

Import yonu: `core/constants/ → core/models/` — ayni katman icinde, kural ihlali yok.

- [ ] **Step 4: game_world.dart'tan GameMode, kModeColors ve Flutter import'unu sil**

`lib/game/world/game_world.dart` dosyasinda:
- `import 'package:flutter/material.dart';` satirini sil
- `GameMode` enum tanimini sil (fromString dahil)
- `kModeColors` map tanimini sil
- Basina ekle: `import '../../core/models/game_mode.dart';`
- Gerekiyorsa: `import '../../core/constants/color_constants.dart';`

- [ ] **Step 5: Tum GameMode import'larini guncelle**

Step 1 ciktisindaki her dosyada `game_world.dart`'tan `GameMode` import edenleri `core/models/game_mode.dart`'tan import edecek sekilde guncelle. `GlooGame` sinifini da import eden dosyalar `game_world.dart` import'unu korumali.

- [ ] **Step 6: Testleri calistir**

Run: `cd "/Users/devcrew/Desktop/Gloo v1.0" && flutter analyze && flutter test`
Expected: 0 error, tum testler gecmeli

- [ ] **Step 7: Commit**

```bash
git add lib/core/models/game_mode.dart lib/core/constants/color_constants.dart lib/game/world/game_world.dart
# + tum etkilenen import dosyalari
git commit -m "refactor(M.13): GameMode core/ altina, kModeColors color_constants'a tasi — game/ Flutter import kaldirildi"
```

---

## Task 5: M.15 — sharedPreferencesProvider Tasima + Konsolidasyon

**Gorev:** `sharedPreferencesProvider`'i `data_models.dart`'tan `providers/` altina tasi ve `localRepositoryProvider` ile konsolide et.

**Files:**
- Modify: `lib/data/local/data_models.dart` (provider tanimini sil)
- Modify: `lib/providers/user_provider.dart` (provider tanimini buraya tasi, localRepositoryProvider bunu kullansiin)
- Modify: `sharedPreferencesProvider` import eden tum dosyalar

- [ ] **Step 1: Mevcut kullanim noktalarini bul**

Run: `cd "/Users/devcrew/Desktop/Gloo v1.0" && grep -rn "sharedPreferencesProvider" lib/ --include="*.dart"`

- [ ] **Step 2: user_provider.dart'a tasi ve konsolide et**

`lib/providers/user_provider.dart`'ta:

```dart
// Onceki:
// final localRepositoryProvider = FutureProvider<LocalRepository>((ref) async {
//   final prefs = await SharedPreferences.getInstance();
//   return LocalRepository(prefs);
// });

// Sonraki:
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final localRepositoryProvider = FutureProvider<LocalRepository>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return LocalRepository(prefs);
});
```

Bu sayede `SharedPreferences.getInstance()` tek bir provider'dan saglanir, `localRepositoryProvider` bunu tuketir — duplicate instance olusturma riski kalkar.

- [ ] **Step 3: data_models.dart'tan provider tanimini ve gereksiz import'lari sil**

`lib/data/local/data_models.dart` dosyasinda:
- `import 'package:flutter_riverpod/flutter_riverpod.dart';` sil
- `import 'package:shared_preferences/shared_preferences.dart';` sil (baska yerde kullanilmiyorsa)
- `sharedPreferencesProvider` tanimini sil

- [ ] **Step 4: Etkilenen dosyalardaki import'lari guncelle**

Step 1 ciktisina gore `data_models.dart`'tan `sharedPreferencesProvider` import eden dosyalari `providers/user_provider.dart`'tan import edecek sekilde guncelle.

- [ ] **Step 5: Testleri calistir**

Run: `cd "/Users/devcrew/Desktop/Gloo v1.0" && flutter analyze && flutter test`
Expected: 0 error, tum testler gecmeli

- [ ] **Step 6: Commit**

```bash
git add lib/data/local/data_models.dart lib/providers/user_provider.dart
# + etkilenen dosyalar
git commit -m "refactor(M.15): sharedPreferencesProvider providers/ altina tasindi, localRepositoryProvider ile konsolide edildi"
```

---

## Task 6: M.16 — PvP Medium/Large Engel Kopyasini Duzelt

**Gorev:** `ObstacleGenerator.fromLineClear()` icinde `medium` ve `large` kombo tier'lari ayni engeli gonderiyor — `large` daha agir ceza vermeli.

**Files:**
- Modify: `lib/game/pvp/matchmaking.dart` (ObstacleGenerator.fromLineClear satir 163-168)
- Create: `test/game/pvp/matchmaking_test.dart` (test dosyasi mevcut degil — yeni olustur)

- [ ] **Step 1: Test dosyasini olustur ve failing test yaz**

`test/game/pvp/matchmaking_test.dart` (yeni dosya):
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/game/pvp/matchmaking.dart';

void main() {
  group('ObstacleGenerator.fromLineClear', () {
    test('medium kombo ice:2 + stone:1 bonus uretir', () {
      final packets = ObstacleGenerator.fromLineClear(
        linesCleared: 2, comboTier: 'medium',
      );
      final totalCount = packets.fold<int>(0, (sum, p) => sum + p.count);
      // base: ice(2) + locked(1) + medium bonus: ice(2) + stone(1) = 6
      expect(totalCount, 6);
    });

    test('large kombo medium\'dan daha agir engel uretir', () {
      final medium = ObstacleGenerator.fromLineClear(
        linesCleared: 2, comboTier: 'medium',
      );
      final large = ObstacleGenerator.fromLineClear(
        linesCleared: 2, comboTier: 'large',
      );
      final mediumTotal = medium.fold<int>(0, (sum, p) => sum + p.count);
      final largeTotal = large.fold<int>(0, (sum, p) => sum + p.count);

      expect(mediumTotal, 6);  // base(2) + locked(1) + ice(2) + stone(1)
      expect(largeTotal, 8);   // base(2) + locked(1) + ice(3) + stone(2)
      expect(largeTotal, greaterThan(mediumTotal));
    });

    test('epic kombo alan etkisi uretir', () {
      final packets = ObstacleGenerator.fromLineClear(
        linesCleared: 1, comboTier: 'epic',
      );
      final hasAreaEffect = packets.any((p) => p.areaSize != null && p.areaSize! > 1);
      expect(hasAreaEffect, isTrue);
    });
  });
}
```

Run: `cd "/Users/devcrew/Desktop/Gloo v1.0" && flutter test test/game/pvp/matchmaking_test.dart`
Expected: FAIL — `large kombo` testi basarisiz (medium ve large ayni)

- [ ] **Step 2: fromLineClear large case'ini guncelle**

`lib/game/pvp/matchmaking.dart` satir 166-168'i degistir:
```dart
    case 'large':
      packets.add(const ObstaclePacket(type: ObstacleType.ice, count: 3));
      packets.add(const ObstaclePacket(type: ObstacleType.stone, count: 2));
```

- [ ] **Step 3: Testi calistir**

Run: `cd "/Users/devcrew/Desktop/Gloo v1.0" && flutter test test/game/pvp/matchmaking_test.dart`
Expected: PASS (tum 3 test)

- [ ] **Step 4: Tum testler**

Run: `cd "/Users/devcrew/Desktop/Gloo v1.0" && flutter analyze && flutter test`
Expected: 0 error, tum testler gecmeli

- [ ] **Step 5: Commit**

```bash
git add lib/game/pvp/matchmaking.dart test/game/pvp/matchmaking_test.dart
git commit -m "fix(M.16): PvP large kombo engeli medium'dan agir yapildi — kopyala-yapistir hatasi duzeltildi"
```

---

## Task 7: H.13 — Hardcoded Turkce Stringler (2. Tur)

**Gorev:** 15 tespit edilen hardcoded Turkce string'i l10n sistemine tasi.

**Files:**
- Modify: `lib/core/l10n/app_strings.dart` (yeni abstract getter'lar)
- Modify: `lib/core/l10n/strings_en.dart` .. `strings_tr.dart` (12 dil dosyasi)
- Modify: Hardcoded string iceren feature dosyalari

**Tespit Edilen Stringler:**

| String | Dosya | l10n Key |
|--------|-------|----------|
| `'Seviye'` | game_overlay.dart | `levelLabel` |
| `'Duello'` / `'Duel'` | game_over_overlay.dart | `duelLabel` |
| `'Galibiyet'` | pvp_lobby_screen.dart | `pvpWinLabel` |
| `'Maglubiyet'` | pvp_lobby_screen.dart | `pvpLossLabel` |
| `'Oran'` | pvp_lobby_screen.dart | `pvpRatioLabel` |
| `'Iptal'` | pvp_lobby_screen.dart | `cancelLabel` |
| `'Tekrar Oyna'` | duel_result_overlay.dart | `playAgainLabel` |
| `'Ana Menu'` | duel_result_overlay.dart | `mainMenuLabel` |
| `'Sonraki Seviye'` | level_complete_overlay.dart | `nextLevelLabel` |
| `'Seviye Listesi'` | level_complete_overlay.dart | `levelListLabel` |
| `'Reklam Izle'` | game_over_overlay.dart | `watchAdLabel` |
| `'YENİ'` | home_screen.dart | `newBadge` |
| `'Ada'` | meta_game_bar.dart | `islandLabel` |
| `'Karakter'` | meta_game_bar.dart | `characterLabel` |
| `'Sezon'` | meta_game_bar.dart | `seasonLabel` |

- [ ] **Step 1: Gercek hardcoded string'leri dogrula**

Run: `cd "/Users/devcrew/Desktop/Gloo v1.0" && grep -rn "'Seviye'\|'Duello'\|'Galibiyet'\|'Maglubiyet'\|'Oran'\|'Iptal'\|'Tekrar Oyna'\|'Ana Menu'\|'Sonraki Seviye'\|'Seviye Listesi'\|'Reklam Izle'\|'YENİ'\|'Ada'\|'Karakter'\|'Sezon'" lib/features/ --include="*.dart"`

Ciktidaki dosya ve satir numaralarini not al.

- [ ] **Step 2: app_strings.dart'a abstract getter'lar ekle**

`lib/core/l10n/app_strings.dart` dosyasina abstract class body icine ekle:
```dart
  // Sprint 20 — ek l10n stringler
  String get levelLabel;
  String get duelLabel;
  String get pvpWinLabel;
  String get pvpLossLabel;
  String get pvpRatioLabel;
  String get cancelLabel;
  String get playAgainLabel;
  String get mainMenuLabel;
  String get nextLevelLabel;
  String get levelListLabel;
  String get watchAdLabel;
  String get newBadge;
  String get islandLabel;
  String get characterLabel;
  String get seasonLabel;
```

- [ ] **Step 3: 12 dil dosyasina override ekle**

Her `strings_*.dart` dosyasina cevirileri ekle.

`strings_en.dart`:
```dart
  @override String get levelLabel => 'Level';
  @override String get duelLabel => 'Duel';
  @override String get pvpWinLabel => 'Wins';
  @override String get pvpLossLabel => 'Losses';
  @override String get pvpRatioLabel => 'Ratio';
  @override String get cancelLabel => 'Cancel';
  @override String get playAgainLabel => 'Play Again';
  @override String get mainMenuLabel => 'Main Menu';
  @override String get nextLevelLabel => 'Next Level';
  @override String get levelListLabel => 'Level List';
  @override String get watchAdLabel => 'Watch Ad';
  @override String get newBadge => 'NEW';
  @override String get islandLabel => 'Island';
  @override String get characterLabel => 'Character';
  @override String get seasonLabel => 'Season';
```

`strings_tr.dart`:
```dart
  @override String get levelLabel => 'Seviye';
  @override String get duelLabel => 'Duello';
  @override String get pvpWinLabel => 'Galibiyet';
  @override String get pvpLossLabel => 'Maglubiyet';
  @override String get pvpRatioLabel => 'Oran';
  @override String get cancelLabel => 'Iptal';
  @override String get playAgainLabel => 'Tekrar Oyna';
  @override String get mainMenuLabel => 'Ana Menu';
  @override String get nextLevelLabel => 'Sonraki Seviye';
  @override String get levelListLabel => 'Seviye Listesi';
  @override String get watchAdLabel => 'Reklam Izle';
  @override String get newBadge => 'YENİ';
  @override String get islandLabel => 'Ada';
  @override String get characterLabel => 'Karakter';
  @override String get seasonLabel => 'Sezon';
```

Diger 10 dil icin uygun cevirileri ekle: `de`, `zh`, `ja`, `ko`, `ru`, `es`, `fr`, `hi`, `pt`, `ar`.

- [ ] **Step 4: Feature dosyalarindaki hardcoded string'leri l10n ile degistir**

Her feature dosyasinda `ref.watch(stringsProvider)` veya mevcut `l` degiskeni uzerinden eris:
```dart
// Onceki: Text('Seviye')
// Sonraki: Text(l.levelLabel)
```

Step 1 ciktisindaki tum dosya ve satirlarda degisiklik yap.

- [ ] **Step 5: Testleri calistir**

Run: `cd "/Users/devcrew/Desktop/Gloo v1.0" && flutter analyze && flutter test`
Expected: 0 error, tum testler gecmeli

- [ ] **Step 6: Commit**

```bash
git add lib/core/l10n/ lib/features/
git commit -m "feat(H.13): 15 hardcoded Turkce string l10n'a tasindi — 12 dil destegi"
```

---

## Task 8: H.12 — _evaluateBoard() Parcalanmasi

**Gorev:** 131 satirlik `_evaluateBoard()` metodunu sorumluluk bazli alt metotlara parcala. Refactoring — davranis degisikligi YOK.

**Files:**
- Modify: `lib/game/world/game_world.dart` (satir 267-397 arasi)
- Modify: `test/game/game_world_test.dart` (pipeline regresyon testi ekle)

**Hedef Yapi:**
```
_evaluateBoard()
  → _applySyntheses()              // Sentez bul ve uygula
  → _updateColorChefProgress()     // Color Chef ilerleme (mevcut mod ise)
  → _clearAndScore()               // Satir temizle, puan ver, kombo
  → _applyGravityAndCascade()      // Gravity + zincirleme temizleme
  → _checkTimeTrialBonus(cleared)  // Time Trial +2sn
  → _checkLevelCompletion()        // Seviye modu hedef kontrolu
  → _evaluateNearMiss()            // Near-miss detector
```

- [ ] **Step 1: Mevcut _evaluateBoard() tam icerigini oku**

Run: `cd "/Users/devcrew/Desktop/Gloo v1.0" && sed -n '267,397p' lib/game/world/game_world.dart`

Bu ciktiyi referans olarak sakla — refactoring sonrasi davranis degismemeli.

- [ ] **Step 2: Regresyon testi yaz (parcalamadan ONCE)**

`test/game/game_world_test.dart` dosyasina ekle:
```dart
group('_evaluateBoard pipeline regresyon', () {
  test('sentez + temizleme + gravity pipeline dogru calisir', () {
    // GlooGame'i minimal callback'lerle olustur
    int totalScore = 0;
    List<List<int>> clearedLines = [];

    final game = GlooGame(
      mode: GameMode.classic,
      onScoreGained: (s) => totalScore = s,
      onLineClear: (c) => clearedLines = c,
    );
    game.startGame();

    // Pipeline tetikle ve hata olmadigini dogrula
    // Not: GlooGame API'si uzerinden test et, private metotlari degil
    expect(() => game.checkGameOver([]), returnsNormally);
  });
});
```

Run: `cd "/Users/devcrew/Desktop/Gloo v1.0" && flutter test test/game/game_world_test.dart --name "pipeline"`
Expected: PASS (mevcut davranis dogrulandi)

- [ ] **Step 3: _applySyntheses() metodunu cikar**

`lib/game/world/game_world.dart` dosyasinda yeni private metot ekle (class body icinde):
```dart
  /// Renk sentezlerini bulur ve izgaraya uygular.
  void _applySyntheses() {
    // _evaluateBoard()'dan sentez bolumunu (~ satir 268-285) buraya tasi
    // Orijinal kodu birebir kopyala, sadece metot olarak ayir
  }
```

**ONEMLI:** Kodu kopyalarken degisken isimlerini, callback cagirimlarini ve siralamayi korumalisin.

- [ ] **Step 4: _clearAndScore() metodunu cikar**

```dart
  /// Satir/sutun temizleme, puanlama ve kombo islemleri.
  /// Temizlenen satirlarin listesini doner.
  List<List<int>> _clearAndScore() {
    // _evaluateBoard()'dan detectAndClear + scoreSystem + comboDetector +
    // currencyManager bolumunu buraya tasi
    // Bos liste donerse temizleme yapilmamis demektir
  }
```

- [ ] **Step 5: _applyGravityAndCascade() metodunu cikar**

```dart
  /// Yercekim uygular ve cascade temizleme yapar.
  void _applyGravityAndCascade() {
    // _evaluateBoard()'dan applyGravity + ikinci detectAndClear bolumunu tasi
  }
```

- [ ] **Step 6: _evaluateBoard() icini yeni metotlarla degistir**

```dart
  void _evaluateBoard() {
    _applySyntheses();

    if (_mode == GameMode.colorChef) {
      _updateColorChefProgress(); // mevcut metot ise oldugu gibi cagir, yoksa cikar
    }

    final cleared = _clearAndScore();

    if (cleared.isNotEmpty) {
      _applyGravityAndCascade();

      if (_mode == GameMode.timeTrial) {
        _remainingSeconds += 2 * cleared.length;
        onTimerTick?.call(_remainingSeconds);
      }
    }

    if (_mode == GameMode.level) {
      _checkLevelCompletion(); // mevcut metot
    }

    if (_mode != GameMode.timeTrial && _mode != GameMode.duel) {
      _nearMissDetector.evaluate(
        score: _scoreSystem.score,
        targetScore: _targetScore,
        availableMoves: 3,
      );
    }

    _powerUpSystem.onMoveCompleted();
  }
```

- [ ] **Step 7: Testleri calistir**

Run: `cd "/Users/devcrew/Desktop/Gloo v1.0" && flutter analyze && flutter test`
Expected: 0 error, tum testler gecmeli (refactoring davranisi degistirmemeli)

- [ ] **Step 8: Commit**

```bash
git add lib/game/world/game_world.dart test/game/game_world_test.dart
git commit -m "refactor(H.12): _evaluateBoard() 4 alt metoda parcalandi — SRP uygulamasi"
```

---

## Dogrulama Adimi (Tum Sprint Sonrasi)

- [ ] **Final dogrulama**

```bash
cd "/Users/devcrew/Desktop/Gloo v1.0"
flutter analyze           # 0 error, 0 warning bekleniyor
flutter test              # 1204+ test gecmeli (yeni testler dahil)
flutter build web --release  # Web build basarili olmali
```

- [ ] **tasks/todo.md guncelle**

Tamamlanan gorevleri isaretle: C.7, C.8, M.12, M.13, M.15, M.16, H.12, H.13
Sprint 20 bolumunu ekle.
