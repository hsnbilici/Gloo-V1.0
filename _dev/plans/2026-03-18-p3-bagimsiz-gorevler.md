# P3 Bağımsız Görevler — Uygulama Planı

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** P3 listesindeki harici bağımlılığı olmayan 6 görevi tamamlayarak proje kalitesini artırmak.

**Architecture:** Mevcut altyapıya ekleme yapılır — yeni katman veya yapısal değişiklik yok. Her görev birbirinden bağımsız, paralel çalıştırılabilir.

**Tech Stack:** Flutter 3.41+, Dart, Riverpod, GitHub Actions

---

## Task 1: L.18 — ELO Lig İsimleri l10n

**Files:**
- Modify: `lib/game/pvp/matchmaking.dart:16-23`
- Modify: `lib/core/l10n/app_strings.dart`
- Modify: `lib/core/l10n/strings_en.dart` + 11 diğer dil dosyası (`strings_tr.dart`, `strings_de.dart`, `strings_zh.dart`, `strings_ja.dart`, `strings_ko.dart`, `strings_ru.dart`, `strings_es.dart`, `strings_ar.dart`, `strings_fr.dart`, `strings_hi.dart`, `strings_pt.dart`)
- Create: `test/game/pvp/elo_league_l10n_test.dart`

**Context:**
- `EloLeagueInfo.displayName` (matchmaking.dart:17-23) hardcoded Türkçe string'ler döndürüyor: 'Bronz', 'Gümüş', 'Altın', 'Elmas', 'Gloo Master'
- l10n sistemi: `AppStrings` abstract class + 12 `strings_*.dart` implementasyonu
- `displayName` getter'ı parametre almıyor → l10n context yok
- Çözüm: `AppStrings`'e 5 league getter ekle, `displayName`'i kaldır, kullanım noktalarında `AppStrings` üzerinden çağır

**Kullanım noktalarını bul:** `displayName` grep ile tüm referansları bul ve güncellenecek dosyaları belirle.

- [ ] **Step 1: AppStrings'e 5 abstract getter ekle**

`lib/core/l10n/app_strings.dart`'a ekle:

```dart
String get leagueBronze;
String get leagueSilver;
String get leagueGold;
String get leagueDiamond;
String get leagueGlooMaster;
```

- [ ] **Step 2: 12 dil dosyasına override ekle**

Her `strings_*.dart` dosyasına 5 getter override ekle. Çeviriler:

| Key | en | tr | de | zh | ja | ko | ru | es | ar | fr | hi | pt |
|-----|----|----|----|----|----|----|----|----|----|----|----|----|
| leagueBronze | Bronze | Bronz | Bronze | 青铜 | ブロンズ | 브론즈 | Бронза | Bronce | برونز | Bronze | कांस्य | Bronze |
| leagueSilver | Silver | Gümüş | Silber | 白银 | シルバー | 실버 | Серебро | Plata | فضة | Argent | रजत | Prata |
| leagueGold | Gold | Altın | Gold | 黄金 | ゴールド | 골드 | Золото | Oro | ذهب | Or | स्वर्ण | Ouro |
| leagueDiamond | Diamond | Elmas | Diamant | 钻石 | ダイヤモンド | 다이아몬드 | Алмаз | Diamante | ألماس | Diamant | हीरा | Diamante |
| leagueGlooMaster | Gloo Master | Gloo Master | Gloo Master | Gloo 大师 | グルーマスター | 글루 마스터 | Глу Мастер | Gloo Maestro | غلو ماستر | Gloo Maître | ग्लू मास्टर | Gloo Mestre |

- [ ] **Step 3: matchmaking.dart — displayName getter'ını güncelle**

`EloLeagueInfo` extension'ındaki `displayName` getter'ı şu anki string literal'leri kullanıyor. Bunu `String leagueName(AppStrings l)` metoduna dönüştür:

```dart
extension EloLeagueInfo on EloLeague {
  String leagueName(AppStrings l) => switch (this) {
        EloLeague.bronze => l.leagueBronze,
        EloLeague.silver => l.leagueSilver,
        EloLeague.gold => l.leagueGold,
        EloLeague.diamond => l.leagueDiamond,
        EloLeague.glooMaster => l.leagueGlooMaster,
      };

  int get minElo => switch (this) {
    // ... değişmez
  };
  // ...
}
```

- [ ] **Step 4: Tüm `displayName` kullanım noktalarını güncelle**

Bilinen kullanım noktası: `lib/features/pvp/pvp_lobby_widgets.dart:55` — `league.displayName` → `league.leagueName(l)`. Bu widget `ConsumerWidget` olduğu için `ref.watch(stringsProvider)` ile `AppStrings` erişimi mevcut.

Ek referans olup olmadığını `grep -r displayName lib/` ile doğrula.

- [ ] **Step 5: Test yaz**

```dart
// test/game/pvp/elo_league_l10n_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/game/pvp/matchmaking.dart';
import 'package:gloo/core/l10n/strings_en.dart';
import 'package:gloo/core/l10n/strings_tr.dart';

void main() {
  group('EloLeague l10n', () {
    test('English league names', () {
      final l = StringsEn();
      expect(EloLeague.bronze.leagueName(l), 'Bronze');
      expect(EloLeague.glooMaster.leagueName(l), 'Gloo Master');
    });

    test('Turkish league names', () {
      final l = StringsTr();
      expect(EloLeague.bronze.leagueName(l), 'Bronz');
      expect(EloLeague.diamond.leagueName(l), 'Elmas');
    });

    test('all leagues have names for all languages', () {
      for (final league in EloLeague.values) {
        expect(league.leagueName(StringsEn()), isNotEmpty);
        expect(league.leagueName(StringsTr()), isNotEmpty);
      }
    });
  });
}
```

- [ ] **Step 6: Doğrula ve commit**

Run: `flutter analyze && flutter test`
Expected: 0 error, tüm testler geçer

```bash
git add lib/core/l10n/ lib/game/pvp/matchmaking.dart test/game/pvp/elo_league_l10n_test.dart
git commit -m "feat(l10n): ELO league names localized to 12 languages (L.18)"
```

---

## Task 2: L.9 — SoundBank Ses Pipeline Tamamlama

**Files:**
- Modify: `lib/audio/sound_bank.dart`
- Create: `test/audio/sound_bank_test.dart`

**Context:**
- `SoundBank` (45 satır) AudioManager (SFX) + HapticManager wrapper.
- `AudioPaths` 30+ SFX path tanımlıyor ama SoundBank bunların çoğunu kullanmıyor.
- Eksik SFX çağrıları: `onGelPlaced` (haptic-only), `onGelMerge` (haptic-only), `onCombo` (haptic-only epic), `onLevelComplete` (haptic-only).
- Yeni pipeline event'leri eksik: `onSynthesis`, `onIceBreak`, `onPowerUpActivate`, `onNearMiss`, `onGravityDrop`, `onButtonTap`, `onGelOzuEarn`.
- `AudioManager.playSfx()` dosya bulamazsa sessizce atlar — güvenli.

- [ ] **Step 1: Test yaz**

```dart
// test/audio/sound_bank_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/audio/sound_bank.dart';
import 'package:gloo/audio/audio_manager.dart';
import 'package:gloo/audio/haptic_manager.dart';
import 'package:gloo/core/models/combo_types.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioManager extends Mock implements AudioManager {}
class MockHapticManager extends Mock implements HapticManager {}

void main() {
  late MockAudioManager audio;
  late MockHapticManager haptic;
  late SoundBank bank;

  setUp(() {
    audio = MockAudioManager();
    haptic = MockHapticManager();
    bank = SoundBank(audio: audio, haptic: haptic);

    when(() => audio.playSfx(any())).thenAnswer((_) async {});
    when(() => haptic.trigger(any())).thenAnswer((_) async {});
  });

  test('onGelPlaced plays SFX and haptic', () async {
    await bank.onGelPlaced();
    verify(() => audio.playSfx(any())).called(1);
    verify(() => haptic.trigger(HapticProfile.gelPlace)).called(1);
  });

  test('onGelPlaced soft variant uses soft SFX', () async {
    await bank.onGelPlaced(soft: true);
    verify(() => audio.playSfx(any())).called(1);
  });

  test('onGelMerge plays SFX based on merge count', () async {
    await bank.onGelMerge(mergeCount: 2);
    verify(() => audio.playSfx(any())).called(1);

    await bank.onGelMerge(mergeCount: 5);
    verify(() => audio.playSfx(any())).called(2);
  });

  test('onCombo plays SFX for all tiers', () async {
    await bank.onCombo(const ComboEvent(size: 2, tier: ComboTier.small, multiplier: 1.2));
    verify(() => audio.playSfx(any())).called(1);

    await bank.onCombo(const ComboEvent(size: 8, tier: ComboTier.epic, multiplier: 3.0));
    verify(() => audio.playSfx(any())).called(2);
    verify(() => haptic.trigger(HapticProfile.comboEpic)).called(1);
  });

  test('onLevelComplete plays SFX and haptic', () async {
    await bank.onLevelComplete();
    verify(() => audio.playSfx(any())).called(1);
    verify(() => haptic.trigger(HapticProfile.levelComplete)).called(1);
  });

  test('onSynthesis plays SFX', () async {
    await bank.onSynthesis();
    verify(() => audio.playSfx(any())).called(1);
  });

  test('onIceBreak plays SFX and haptic', () async {
    await bank.onIceBreak();
    verify(() => audio.playSfx(any())).called(1);
    verify(() => haptic.trigger(any())).called(1);
  });

  test('onPowerUpActivate plays SFX and haptic', () async {
    await bank.onPowerUpActivate();
    verify(() => audio.playSfx(any())).called(1);
    verify(() => haptic.trigger(any())).called(1);
  });

  test('onGravityDrop plays SFX', () async {
    await bank.onGravityDrop();
    verify(() => audio.playSfx(any())).called(1);
  });
}
```

- [ ] **Step 2: Testleri çalıştır, başarısız olduğunu doğrula**

Run: `flutter test test/audio/sound_bank_test.dart`
Expected: Derleme hataları (onSynthesis, onIceBreak vb. yok)

- [ ] **Step 3: SoundBank'i genişlet**

`lib/audio/sound_bank.dart`'ı şu şekilde güncelle — mevcut event'lere SFX ekle, yeni event'ler ekle:

```dart
import '../core/constants/audio_constants.dart';
import '../core/models/combo_types.dart';
import 'audio_manager.dart';
import 'haptic_manager.dart';

class SoundBank {
  SoundBank({AudioManager? audio, HapticManager? haptic})
      : _audio = audio ?? AudioManager(),
        _haptic = haptic ?? HapticManager();

  final AudioManager _audio;
  final HapticManager _haptic;

  Future<void> onGelPlaced({bool soft = false}) async {
    await _audio.playSfx(soft ? AudioPaths.gelPlaceSoft : AudioPaths.gelPlace);
    await _haptic.trigger(HapticProfile.gelPlace);
  }

  Future<void> onGelMerge({required int mergeCount}) async {
    final sfx = switch (mergeCount) {
      >= 4 => AudioPaths.gelMergeLarge,
      >= 3 => AudioPaths.gelMergeMedium,
      _ => AudioPaths.gelMergeSmall,
    };
    await _audio.playSfx(sfx);
    final haptic = mergeCount >= 3
        ? HapticProfile.gelMergeLarge
        : HapticProfile.gelMergeSmall;
    await _haptic.trigger(haptic);
  }

  Future<void> onLineClear({required int lines}) async {
    await _audio.playSfx(
      lines >= 2 ? AudioPaths.lineClearCrystal : AudioPaths.lineClear,
    );
    await _haptic.trigger(HapticProfile.gelMergeLarge);
  }

  Future<void> onCombo(ComboEvent combo) async {
    final sfx = switch (combo.tier) {
      ComboTier.small => AudioPaths.comboSmall,
      ComboTier.medium => AudioPaths.comboMedium,
      ComboTier.large => AudioPaths.comboLarge,
      ComboTier.epic => AudioPaths.comboEpic,
      ComboTier.none => null,
    };
    if (sfx != null) await _audio.playSfx(sfx);
    if (combo.tier == ComboTier.epic) {
      await _haptic.trigger(HapticProfile.comboEpic);
    }
  }

  Future<void> onGameOver() async {
    await _audio.playSfx(AudioPaths.gameOver);
  }

  Future<void> onLevelComplete() async {
    await _audio.playSfx(AudioPaths.levelComplete);
    await _haptic.trigger(HapticProfile.levelComplete);
  }

  Future<void> onSynthesis() async {
    await _audio.playSfx(AudioPaths.colorSynthesis);
  }

  Future<void> onIceBreak() async {
    await _audio.playSfx(AudioPaths.iceBreak);
    await _haptic.trigger(HapticProfile.gelMergeSmall);
  }

  Future<void> onPowerUpActivate() async {
    await _audio.playSfx(AudioPaths.powerupActivate);
    await _haptic.trigger(HapticProfile.gelPlace);
  }

  Future<void> onGravityDrop() async {
    await _audio.playSfx(AudioPaths.gravityDrop);
  }

  Future<void> onButtonTap() async {
    await _audio.playSfx(AudioPaths.buttonTap);
  }

  Future<void> onGelOzuEarn() async {
    await _audio.playSfx(AudioPaths.gelOzuEarn);
  }

  Future<void> onNearMiss({required bool survived}) async {
    await _audio.playSfx(
      survived ? AudioPaths.nearMissRelief : AudioPaths.nearMissTension,
    );
  }
}
```

- [ ] **Step 4: Testleri çalıştır, geçtiğini doğrula**

Run: `flutter test test/audio/sound_bank_test.dart`
Expected: Tüm testler geçer

- [ ] **Step 5: Doğrula ve commit**

Run: `flutter analyze && flutter test`

```bash
git add lib/audio/sound_bank.dart test/audio/sound_bank_test.dart
git commit -m "feat(audio): complete SoundBank pipeline with all SFX events (L.9)"
```

---

## Task 3: L.15 — availableColors Level Özelliği

**Files:**
- Modify: `lib/game/shapes/gel_shape.dart:113-117, 186-228, 283-293`
- Modify: `lib/game/world/game_world.dart` (generateSmartHand çağrısı)
- Modify: `lib/game/levels/level_progression.dart` (birkaç seviyeye availableColors ekle)
- Create: `test/game/shapes/available_colors_test.dart`

**Context:**
- `LevelData.availableColors` alanı mevcut ama hiçbir yerde kullanılmıyor.
- `ShapeGenerator._randomPiece()` (satır 113-117) ve `_weightedRandomColor()` (satır 186-228) daima `kPrimaryColors` kullanıyor.
- `generateSeededHand()` (satır 283-293) static, `kPrimaryColors` kullanıyor.
- `GlooGame._generateHand()` `generateSmartHand()` çağırırken `availableColors` geçmiyor.
- Çözüm: `generateSmartHand()` ve `generateSeededHand()` metodlarına opsiyonel `List<GelColor>? availableColors` parametresi ekle. `null` ise `kPrimaryColors` fallback.

- [ ] **Step 1: Test yaz**

```dart
// test/game/shapes/available_colors_test.dart
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/core/constants/color_constants.dart';
import 'package:gloo/game/shapes/gel_shape.dart';
import 'package:gloo/game/world/grid_manager.dart';

void main() {
  group('availableColors filtering', () {
    test('generateSmartHand respects availableColors', () {
      final sg = ShapeGenerator(rng: Random(42));
      final gm = GridManager(rows: 8, cols: 8);
      final colors = [GelColor.red, GelColor.blue];

      final hand = sg.generateSmartHand(
        gridManager: gm,
        difficulty: 0.5,
        availableColors: colors,
      );

      for (final (_, color) in hand) {
        expect(colors.contains(color), isTrue,
            reason: 'Color $color not in availableColors');
      }
    });

    test('generateSmartHand uses kPrimaryColors when availableColors is null', () {
      final sg = ShapeGenerator(rng: Random(42));
      final gm = GridManager(rows: 8, cols: 8);

      final hand = sg.generateSmartHand(
        gridManager: gm,
        difficulty: 0.5,
      );

      for (final (_, color) in hand) {
        expect(kPrimaryColors.contains(color), isTrue);
      }
    });

    test('generateSeededHand respects availableColors', () {
      final colors = [GelColor.yellow, GelColor.white];
      final hand = ShapeGenerator.generateSeededHand(
        42,
        availableColors: colors,
      );

      for (final (_, color) in hand) {
        expect(colors.contains(color), isTrue,
            reason: 'Seeded hand color $color not in availableColors');
      }
    });

    test('single available color produces uniform hand', () {
      final sg = ShapeGenerator(rng: Random(99));
      final gm = GridManager(rows: 8, cols: 8);
      final colors = [GelColor.red];

      final hand = sg.generateSmartHand(
        gridManager: gm,
        difficulty: 0.5,
        availableColors: colors,
      );

      for (final (_, color) in hand) {
        expect(color, GelColor.red);
      }
    });
  });
}
```

- [ ] **Step 2: Testleri çalıştır, derleme hatası doğrula**

Run: `flutter test test/game/shapes/available_colors_test.dart`
Expected: FAIL — `availableColors` parametresi yok

- [ ] **Step 3: ShapeGenerator'a availableColors desteği ekle**

`lib/game/shapes/gel_shape.dart` değişiklikleri:

**_randomPiece (satır 113-117):** `kPrimaryColors` yerine `_activeColors` kullan:

```dart
(GelShape, GelColor) _randomPiece([List<GelColor>? availableColors]) {
  final colors = availableColors ?? kPrimaryColors;
  final shape = kAllShapes[_rng.nextInt(kAllShapes.length)];
  final color = colors[_rng.nextInt(colors.length)];
  return (shape, color);
}
```

**generateHand (satır 122-123):**

```dart
List<(GelShape, GelColor)> generateHand({List<GelColor>? availableColors}) =>
    List.generate(GameConstants.shapesInHand, (_) => _randomPiece(availableColors));
```

**generateSmartHand (satır 126-162):** `availableColors` parametresi ekle:

```dart
List<(GelShape, GelColor)> generateSmartHand({
  required GridManager gridManager,
  required double difficulty,
  int gamesPlayed = 0,
  List<GelColor>? availableColors,
}) {
  // ... mevcut kod
  // _weightedRandomColor çağrılarına availableColors geç
}
```

**_weightedRandomColor (satır 186-228):** `availableColors` parametresi ekle:

```dart
GelColor _weightedRandomColor(List<List<GelColor?>> grid, [List<GelColor>? availableColors]) {
  final colors = availableColors ?? kPrimaryColors;
  // colorCounts döngüsünde kPrimaryColors yerine colors kullan
  // Boş ızgara fallback'inde colors kullan
}
```

**_findPlaceableShape (satır 250-271):** `availableColors` ekle:

```dart
(GelShape, GelColor) _findPlaceableShape(GridManager gridManager, [List<GelColor>? availableColors]) {
  final colors = availableColors ?? kPrimaryColors;
  // kPrimaryColors yerine colors kullan
}
```

**generateSeededHand (static, satır 283-293):**

```dart
static List<(GelShape, GelColor)> generateSeededHand(int seed, {List<GelColor>? availableColors}) {
  final rng = Random(seed);
  final colors = availableColors ?? kPrimaryColors;
  return List.generate(
    GameConstants.shapesInHand,
    (_) {
      final shape = kAllShapes[rng.nextInt(kAllShapes.length)];
      final color = colors[rng.nextInt(colors.length)];
      return (shape, color);
    },
  );
}
```

**generateNextSeededHand (static, satır 296-303):**

```dart
static List<(GelShape, GelColor)> generateNextSeededHand({
  required int baseSeed,
  required int handIndex,
  required int moveCount,
  List<GelColor>? availableColors,
}) {
  final seed = baseSeed * 31 + handIndex * 7 + moveCount;
  return generateSeededHand(seed, availableColors: availableColors);
}
```

- [ ] **Step 4: GlooGame'de availableColors'ı ilet**

`lib/game/world/game_world.dart`'ta `generateNextHand()` metodunu güncelle (satır ~214). `levelData?.availableColors` değerini `generateSmartHand`'e ve `generateSeededHand`'e geç.

`generateSmartHand(...)` çağrısına `availableColors: levelData?.availableColors` ekle. `ShapeGenerator.generateSeededHand(...)` çağrısına da `availableColors: levelData?.availableColors` ekle.

- [ ] **Step 5: Birkaç seviyeye availableColors ekle**

`lib/game/levels/level_progression.dart`'ta öğretici değer olarak 2-3 seviyeye ekle:

```dart
// Seviye 15: Üç renk — renk kısıtlaması tanıtımı (sentez mümkün: red+blue=purple, red+yellow=orange)
const LevelData(
  id: 15, rows: 9, cols: 8, targetScore: 850,
  availableColors: [GelColor.red, GelColor.yellow, GelColor.blue],
),
// Seviye 25: İki renk — zorluk artışı (sadece red+blue=purple sentezi)
const LevelData(
  id: 25, rows: 9, cols: 8, targetScore: 1000,
  availableColors: [GelColor.red, GelColor.blue],
),
```

- [ ] **Step 6: Testleri çalıştır, geçtiğini doğrula**

Run: `flutter test test/game/shapes/available_colors_test.dart && flutter test`
Expected: Tüm testler geçer

- [ ] **Step 7: Doğrula ve commit**

Run: `flutter analyze`

```bash
git add lib/game/shapes/gel_shape.dart lib/game/world/game_world.dart lib/game/levels/level_progression.dart test/game/shapes/available_colors_test.dart
git commit -m "feat(levels): wire availableColors to ShapeGenerator for per-level color restriction (L.15)"
```

---

## Task 4: L.16 — Ekonomi İnflasyon Kontrolü

**Files:**
- Modify: `lib/game/economy/currency_manager.dart`
- Create: `test/game/economy/inflation_test.dart`

**Context:**
- `CurrencyCosts` sabit maliyetler tanımlıyor (rotate=3, bomb=8 vb.). Oyuncu ilerledikçe Jel Özü birikir ve power-up'lar ucuz kalır.
- Çözüm: `CurrencyManager`'a `inflatedCost(int baseCost)` metodu ekle. Kumulatif harcama veya toplam kazanıma dayalı basit çarpan.
- Formül: `baseCost * (1 + totalLifetimeEarnings / 500).clamp(1.0, 3.0)` — 500 birim kazanımda %100 artış, max 3x.
- `totalLifetimeEarnings` yeni bir alan: persist edilmeli (`LocalRepository` üzerinden).

**Önemli:** Mevcut `spend(amount)` API'sini bozmamak için `inflatedCost` ayrı hesaplama metodu olarak eklenecek. UI tarafı `CurrencyCosts.rotate` yerine `currencyManager.inflatedCost(CurrencyCosts.rotate)` çağıracak.

**Kapsam notu:** Bu görev sadece `CurrencyManager`'a inflasyon mekanizmasını ekler. `lifetimeEarnings` persist edilmesi (`LocalRepository` entegrasyonu) ve UI wiring (power-up butonlarında `inflatedCost` kullanımı) ayrı görevler olarak planlanmalıdır.

- [ ] **Step 1: Test yaz**

```dart
// test/game/economy/inflation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gloo/game/economy/currency_manager.dart';

void main() {
  group('Inflation control', () {
    test('inflatedCost returns baseCost at 0 lifetime earnings', () {
      final cm = CurrencyManager(initialBalance: 100);
      expect(cm.inflatedCost(CurrencyCosts.rotate), CurrencyCosts.rotate);
    });

    test('inflatedCost increases with lifetime earnings', () {
      final cm = CurrencyManager(initialBalance: 100);
      cm.addLifetimeEarnings(500);
      // 1 + 500/500 = 2.0 → rotate 3 * 2 = 6
      expect(cm.inflatedCost(CurrencyCosts.rotate), 6);
    });

    test('inflatedCost caps at 3x', () {
      final cm = CurrencyManager(initialBalance: 100);
      cm.addLifetimeEarnings(5000);
      // 1 + 5000/500 = 11 → clamp 3.0 → rotate 3 * 3 = 9
      expect(cm.inflatedCost(CurrencyCosts.rotate), 9);
    });

    test('inflatedCost rounds up', () {
      final cm = CurrencyManager(initialBalance: 100);
      cm.addLifetimeEarnings(250);
      // 1 + 250/500 = 1.5 → peek 2 * 1.5 = 3
      expect(cm.inflatedCost(CurrencyCosts.peek), 3);
    });

    test('lifetime earnings accumulate through _earn', () {
      final cm = CurrencyManager(initialBalance: 0);
      cm.earnFromLineClear(3);
      cm.earnFromCombo('epic');
      // 3 + 5 = 8 total
      expect(cm.lifetimeEarnings, 8);
    });

    test('setLifetimeEarnings restores persisted value', () {
      final cm = CurrencyManager(initialBalance: 0);
      cm.setLifetimeEarnings(1000);
      expect(cm.inflatedCost(CurrencyCosts.rotate), 9); // 3 * 3.0
    });
  });
}
```

- [ ] **Step 2: Testleri çalıştır, derleme hatası doğrula**

Run: `flutter test test/game/economy/inflation_test.dart`
Expected: FAIL — `inflatedCost`, `lifetimeEarnings`, `addLifetimeEarnings`, `setLifetimeEarnings` yok

- [ ] **Step 3: CurrencyManager'a inflasyon mekanizması ekle**

`lib/game/economy/currency_manager.dart` değişiklikleri:

```dart
class CurrencyManager {
  CurrencyManager({int initialBalance = 0, int lifetimeEarnings = 0})
      : _balance = initialBalance,
        _lifetimeEarnings = lifetimeEarnings;

  int _balance;
  int _earnedThisGame = 0;
  int _spentThisGame = 0;
  int _lifetimeEarnings;

  int get balance => _balance;
  int get earnedThisGame => _earnedThisGame;
  int get spentThisGame => _spentThisGame;
  int get lifetimeEarnings => _lifetimeEarnings;

  void Function(int newBalance)? onBalanceChanged;

  // ─── İnflasyon ────────────────────────────────────────────────────────────

  /// Birikimli kazanıma dayalı inflasyonlu maliyet hesaplar.
  /// Çarpan: 1.0 → 3.0 aralığında (500 birim başına +1x, max 3x).
  int inflatedCost(int baseCost) {
    final multiplier = (1 + _lifetimeEarnings / 500).clamp(1.0, 3.0);
    return (baseCost * multiplier).ceil();
  }

  /// Dışarıdan lifetime earnings ayarla (SharedPreferences yükleme).
  void setLifetimeEarnings(int value) {
    _lifetimeEarnings = value;
  }

  /// Lifetime earnings ekle (test/migration için).
  void addLifetimeEarnings(int value) {
    _lifetimeEarnings += value;
  }

  // ... mevcut _earn metodu güncelle:
  void _earn(int amount) {
    _balance += amount;
    _earnedThisGame += amount;
    _lifetimeEarnings += amount;
    onBalanceChanged?.call(_balance);
  }

  // ... geri kalan metotlar değişmez
}
```

- [ ] **Step 4: Testleri çalıştır, geçtiğini doğrula**

Run: `flutter test test/game/economy/inflation_test.dart`
Expected: Tüm testler geçer

- [ ] **Step 5: Doğrula ve commit**

Run: `flutter analyze && flutter test`

```bash
git add lib/game/economy/currency_manager.dart test/game/economy/inflation_test.dart
git commit -m "feat(economy): add inflation control with lifetime-earnings-based cost scaling (L.16)"
```

---

## Task 5: L.21 — CI Versioning Otomasyonu

**Files:**
- Modify: `.github/workflows/flutter_ci.yml`
- Create: `scripts/version_bump.sh`

**Context:**
- `pubspec.yaml` versiyonu `1.0.0+1` — elle güncelleniyor.
- CI pipeline: analyze → test → coverage → format.
- Otomasyon: `main`'e push'ta versiyon otomatik artsın. Semantic versioning build numarası git commit count'a bağlansın.
- Sadece `push` event'inde (merge sonrası) çalışsın, PR'da değil.

- [ ] **Step 1: version_bump.sh scripti oluştur**

```bash
#!/usr/bin/env bash
# scripts/version_bump.sh
# pubspec.yaml'daki build number'ı git commit count ile günceller.
# Kullanım: ./scripts/version_bump.sh [--dry-run]

set -euo pipefail

PUBSPEC="pubspec.yaml"

if [ ! -f "$PUBSPEC" ]; then
  echo "Error: $PUBSPEC not found"
  exit 1
fi

# Mevcut versiyon
CURRENT=$(grep '^version:' "$PUBSPEC" | head -1 | sed 's/version: //')
BASE_VERSION=$(echo "$CURRENT" | cut -d+ -f1)

# Build number = toplam commit sayısı
BUILD_NUMBER=$(git rev-list --count HEAD)

NEW_VERSION="${BASE_VERSION}+${BUILD_NUMBER}"

if [ "${1:-}" = "--dry-run" ]; then
  echo "Would update: $CURRENT → $NEW_VERSION"
  exit 0
fi

# pubspec.yaml güncelle
sed -i.bak "s/^version: .*/version: ${NEW_VERSION}/" "$PUBSPEC"
rm -f "${PUBSPEC}.bak"

echo "Updated: $CURRENT → $NEW_VERSION"
```

- [ ] **Step 2: Script'i çalıştırılabilir yap**

```bash
chmod +x scripts/version_bump.sh
```

- [ ] **Step 3: CI workflow'a versioning step ekle**

`.github/workflows/flutter_ci.yml`'da, `push` event'inde (sadece main) `analyze-and-test` job'undan sonra yeni bir job ekle:

```yaml
  version-bump:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    needs: analyze-and-test
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Bump version
        run: ./scripts/version_bump.sh

      - name: Commit version bump
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git diff --quiet pubspec.yaml && exit 0
          git add pubspec.yaml
          git commit -m "chore: bump build number [skip ci]"
          git push
```

`[skip ci]` commit mesajı sonsuz döngüyü önler.

- [ ] **Step 4: Yerel test**

```bash
./scripts/version_bump.sh --dry-run
```
Expected: `Would update: 1.0.0+1 → 1.0.0+<commit_count>`

- [ ] **Step 5: Doğrula ve commit**

Run: `flutter analyze`

```bash
git add scripts/version_bump.sh .github/workflows/flutter_ci.yml
git commit -m "ci: add automatic build number bump on main push (L.21)"
```

---

## Task 6: L.11 — Dependabot Yapılandırması

**Files:**
- Create: `.github/dependabot.yml`

**Context:**
- Proje Dependabot veya Renovate kullanmıyor.
- Flutter (pub) ve GitHub Actions bağımlılıkları güncellenmiyor.
- Dependabot haftalık kontrol yapacak, PR açacak.

- [ ] **Step 1: dependabot.yml oluştur**

```yaml
# .github/dependabot.yml
version: 2
updates:
  # Flutter/Dart bağımlılıkları
  - package-ecosystem: "pub"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
    open-pull-requests-limit: 5
    labels:
      - "dependencies"
    commit-message:
      prefix: "deps"

  # GitHub Actions
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
    open-pull-requests-limit: 3
    labels:
      - "ci"
    commit-message:
      prefix: "ci"
```

- [ ] **Step 2: Commit**

```bash
git add .github/dependabot.yml
git commit -m "ci: add Dependabot for pub and GitHub Actions updates (L.11)"
```

---

## Bağımlılık Grafiği

```
Task 1 (L.18 ELO l10n)        — bağımsız
Task 2 (L.9 SoundBank)        — bağımsız
Task 3 (L.15 availableColors) — bağımsız
Task 4 (L.16 inflation)       — bağımsız
Task 5 (L.21 CI versioning)   — bağımsız
Task 6 (L.11 Dependabot)      — bağımsız
```

Tüm görevler paralel çalıştırılabilir. Önerilen sıra (kolay → zor): 6 → 5 → 1 → 2 → 4 → 3
