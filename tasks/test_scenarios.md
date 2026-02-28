# Gloo — Kapsamli Test Senaryolari

> Son guncelleme: 2026-02-28
> Mevcut testler: 222 (214 gecen, 8 home_screen widget test baskida)
> Kapsam: Tum bolumler, ekranlar, ozellikler ve fonksiyonlar

---

## Durum Aciklamalari

- `[YAZILDI]` — Test kodu mevcut ve calisiyor
- `[EKSIK]` — Test yazilmadi, yazilmasi gerekiyor
- `[MANUAL]` — Otomatik test yazilamaz, manuel test gerekli (cihaz, UI, harici servis)

---

## 1. Core Utilities

### 1.1 ColorMixer (`lib/core/utils/color_mixer.dart`) `[YAZILDI]`

**Dosya:** `test/core/color_mixer_test.dart` — 23 test

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `mix(red, yellow)` | `orange` |
| 2 | `mix(yellow, red)` (ters sira) | `orange` (sira bagimsiz) |
| 3 | `mix(blue, yellow)` | `green` |
| 4 | `mix(red, blue)` | `purple` |
| 5 | `mix(red, white)` | `pink` |
| 6 | `mix(blue, white)` | `lightBlue` |
| 7 | `mix(green, yellow)` | `lime` (zincir sentez) |
| 8 | `mix(brown, red)` | `maroon` (zincir sentez) |
| 9 | Tum 8 ciftin ters sirasini test et | Ayni sonuc |
| 10 | `mix(red, red)` (ayni renk) | `null` |
| 11 | `mix(orange, blue)` (sentez+sentez) | `null` (tabloda yok) |
| 12 | `mixChain([red, yellow, blue])` | Sirayla: red+yellow=orange, orange+blue=null |
| 13 | `isSecondaryColor(orange)` | `true` |
| 14 | `isSecondaryColor(red)` | `false` |
| 15 | `findRecipes(orange)` | `[(red, yellow)]` |
| 16 | `findRecipes(red)` | `[]` (birincil renk) |
| 17 | Tum 4 birincil renk icin `isSecondaryColor` false | 4x false |
| 18 | Tum 8 ikincil renk icin `isSecondaryColor` true | 8x true |
| 19 | `mix(null_equivalent)` — gecersiz giris korumasi | `null` |

### 1.2 NearMissDetector (`lib/core/utils/near_miss_detector.dart`) `[YAZILDI]`

**Dosya:** `test/core/near_miss_detector_test.dart` — 10 test

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Izgara %50 dolu | `null` (esik alti) |
| 2 | Izgara %80 dolu | `null` (hala esik alti) |
| 3 | Izgara %85 dolu | `NearMissEvent` (standard) |
| 4 | Izgara %90 dolu | `NearMissEvent` (critical) |
| 5 | Izgara %95 dolu | `NearMissEvent` (critical, yuksek faktor) |
| 6 | Bos izgara | `null` |
| 7 | Tam dolu izgara | `NearMissEvent` (critical) |
| 8 | `filledCells: 68, totalCells: 80` (85%) | Standard esik |
| 9 | Faktor agirlik dogrulamasi (doluluk + hamle + kombo) | Agirlikli skor |
| 10 | TimeTrial/Duel modunda cagrilmaz (harici kontrol) | Metod kendisi mod filtresi yapmaz |

### 1.3 GelColor Enum (`lib/core/constants/color_constants.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `kPrimaryColors` listesi 4 eleman | `[red, yellow, blue, white]` |
| 2 | Her GelColor'un `displayColor` dondugu dogrula | 12 renk icin null olmayan Color |
| 3 | Her GelColor'un `shortLabel` dondugu dogrula | 12 etiket: R/Y/B/O/G/P/Pk/Lb/Li/Mn/Br/W |
| 4 | `kColorMixingTable` 8 giris iceriyor | 8 |
| 5 | Tablo girislerinin hepsi gecerli GelColor dondurur | Null yok |
| 6 | `kBgDark`, `kCyan`, `kMuted` sabitleri dogru hex | Hex eslestirmesi |

### 1.4 GameConstants (`lib/core/constants/game_constants.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `gridRows` = 10, `gridCols` = 8 | Varsayilan degerler |
| 2 | `timeTrialDuration` = 90 | 90 saniye |
| 3 | `singleLineClear` = 100 | Puan sabiti |
| 4 | `multiLineClear` = 300 | Coklu satir carpani |
| 5 | `colorSynthesisBonus` = 50 | Sentez bonusu |
| 6 | `comboWindow` = 1500ms | Kombo penceresi |
| 7 | Tum sabitler pozitif deger | >0 |

### 1.5 AudioConstants (`lib/core/constants/audio_constants.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Tum SFX yol sabitleri bos string degil | Her biri `assets/audio/sfx/` ile baslar |
| 2 | Tum muzik yol sabitleri bos string degil | Her biri `assets/audio/music/` ile baslar |
| 3 | `maxConcurrentChannels` >= 1 | Pozitif tam sayi |

### 1.6 UIConstants (`lib/core/constants/ui_constants.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `radiusSm` < `radiusMd` < `radiusLg` < `radiusXl` | Artan sira |
| 2 | Tum radius degerleri >= 0 | Negatif olmayan |

---

## 2. Game Systems

### 2.1 GridManager (`lib/game/world/grid_manager.dart`) `[YAZILDI]`

**Dosya:** `test/game/grid_manager_test.dart` — 54 test

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Bos izgara olusturma (8x10) | Tum hucreler bos |
| 2 | `place(cells, red)` — gecerli yerlestirme | Hucreler kirmizi |
| 3 | `place()` dolu hucreye | `false` (yerlestirilemez) |
| 4 | `canPlace(cells, color)` bos alana | `true` |
| 5 | `canPlace()` dolu alana | `false` |
| 6 | Tam satir temizleme (8 hucre dolu) | `LineClearResult.totalLines = 1` |
| 7 | Tam sutun temizleme (10 hucre dolu) | `LineClearResult.totalLines = 1` |
| 8 | Coklu satir temizleme (2 satir ayni anda) | `totalLines = 2` |
| 9 | Satir + sutun kesisim temizleme | Dogru sayim (cift sayma yok) |
| 10 | `detectAndClear()` — temizlenecek bir sey yok | `totalLines = 0` |
| 11 | `applyGravity()` — gravity hucre ustunde blok | Blok duser |
| 12 | `applyGravity()` — gravity yok | Bos liste |
| 13 | Buz hucreye yerlestirme | Normal yerlestirme |
| 14 | Buz hucre temizlemede `crackIce()` | `iceLayer` azalir |
| 15 | 2 katman buz: 1. temizleme | `iceLayer: 2 → 1` |
| 16 | 2 katman buz: 2. temizleme | `iceLayer: 1 → 0`, hucre normal |
| 17 | Stone hucreye yerlestirme | `canAccept()` = false |
| 18 | Locked hucreye yanlis renk | `canAccept(wrongColor)` = false |
| 19 | Locked hucreye dogru renk | `canAccept(rightColor)` = true |
| 20 | Rainbow hucre herhangi renkle | `canAccept(anyColor)` = true |
| 21 | `clearArea(row, col, size)` — bomb patlama | 3x3 alan temizlenir |
| 22 | Undo — son hareketi geri al | Onceki durum geri yuklenir |
| 23 | `reset()` — izgarayi sifirla | Tum hucreler bos |
| 24 | `setCell(r, c, color)` — tekil hucre atama | Hucre guncellenir |
| 25 | `setCell(r, c, null)` — hucreyi bosalt | Hucre bos |
| 26 | `getCell(r, c)` — sinir disinda | Exception veya guard |
| 27 | `filledCells` getter dogru sayim | Dolu hucre sayisi |
| 28 | `totalCells` getter | `rows * cols` |
| 29 | `initFromSpecialCells()` — seviye ozel hucreleri | Buz, tas, kilitli yerlesir |
| 30 | `crackedIceCells` listesi dogru | Kirilan buz koordinatlari |
| 31 | Gravity sonrasi ikinci temizleme | Kaskad temizleme |

### 2.2 Cell (`lib/game/world/cell_type.dart`) `[KISMI — GridManager icinde]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `Cell(type: normal)` bos | `color == null`, `canAccept(any) == true` |
| 2 | `Cell(type: normal, color: red)` dolu | `canAccept(any) == false` |
| 3 | `Cell(type: ice, iceLayer: 2)` | `canAccept == true`, `crackIce()` → layer 1 |
| 4 | `Cell(type: locked, lockedColor: blue)` | `canAccept(blue) == true`, `canAccept(red) == false` |
| 5 | `Cell(type: stone)` | `canAccept(any) == false` |
| 6 | `Cell(type: gravity)` | Normal yerlestirme, gravity mekanigi tetikler |
| 7 | `Cell(type: rainbow)` | `canAccept(any) == true` |
| 8 | `crackIce()` layer 0'da | Hicbir sey olmaz / guard |

### 2.3 ScoreSystem (`lib/game/systems/score_system.dart`) `[YAZILDI]`

**Dosya:** `test/game/score_system_test.dart` — 22 test

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Tek satir temizleme (1 line) | 100 puan |
| 2 | 2 satir temizleme | 300 × 1 = 300 |
| 3 | 3 satir temizleme | 300 × 2 = 600 |
| 4 | 5 satir temizleme | 300 × 4 = 1200 |
| 5 | Kombo carpani small (x1.2) | Puan × 1.2 |
| 6 | Kombo carpani medium (x1.5) | Puan × 1.5 |
| 7 | Kombo carpani large (x2.0) | Puan × 2.0 |
| 8 | Kombo carpani epic (x3.0) | Puan × 3.0 |
| 9 | Sentez bonusu (+50/sentez) | 1 sentez = +50 |
| 10 | 3 sentez + 2 satir temizleme | 300 + 150 = toplam |
| 11 | `score` baslangicta 0 | 0 |
| 12 | `highScore` guncelleme | Skor > highScore ise guncelle |
| 13 | `isNewHighScore` true sart | `score > initialHighScore` |
| 14 | Sifir satir temizleme | 0 puan |

### 2.4 ComboDetector (`lib/game/systems/combo_detector.dart`) `[YAZILDI]`

**Dosya:** `test/game/score_system_test.dart` icinde — ~8 test

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Tek temizleme (1500ms icerisinde hicbir sey yok) | `ComboTier.none` |
| 2 | 2 temizleme 1500ms icinde | `ComboTier.small` (chain: 2) |
| 3 | 3 temizleme 1500ms icinde | `ComboTier.medium` |
| 4 | 5 temizleme 1500ms icinde | `ComboTier.large` |
| 5 | 8 temizleme 1500ms icinde | `ComboTier.epic` |
| 6 | 2000ms arayla temizleme | Kombo sifirlandi, `none` |
| 7 | Tam 1500ms sinirinda | Pencere icinde mi kontrol |
| 8 | `registerClear(0)` — sifir satir | Kombo artmaz |
| 9 | Kombo sonrasi carpan degeri | `small=1.2, medium=1.5, large=2.0, epic=3.0` |

### 2.5 ColorSynthesisSystem (`lib/game/systems/color_synthesis.dart`) `[YAZILDI]`

**Dosya:** `test/game/color_synthesis_test.dart` — 12 test

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Yatay: `[red, yellow]` yan yana | Sentez: `orange` |
| 2 | Dikey: `[blue, yellow]` ust uste | Sentez: `green` |
| 3 | Hicbir bitisik eslesmez | Bos liste |
| 4 | Tum 8 tablo girisi icin yatay test | 8 sentez |
| 5 | Ters sira: `[yellow, red]` | Ayni sentez: `orange` |
| 6 | `applySynthesis()` — ilk pozisyona sonuc yaz | `grid[r][c] = resultColor` |
| 7 | `applySynthesis()` — diger pozisyonlari temizle | `grid[r][c+1] = null` |
| 8 | Bos izgara | Bos sentez listesi |
| 9 | Tek hucreli izgara | Sentez yok |
| 10 | Birden fazla sentez ayni anda | Tum sentezler listede |
| 11 | Cakisan sentezler (ayni hucre iki sentezde) | `_evaluateBoard` modifiedCells ile koruma |
| 12 | Sentez sonucu olan renk ile yeni sentez | Zincir sentez mumkun |

### 2.6 PowerUpSystem (`lib/game/systems/powerup_system.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `use(rotate)` — yeterli bakiye (3 ozu) | `RotateResult`, bakiye azalir |
| 2 | `use(rotate)` — yetersiz bakiye | Kullanilmaz |
| 3 | `use(bomb)` — 3x3 alan temizleme | `BombResult(clearedCells)` |
| 4 | `use(bomb)` — cooldown aktif | Kullanilmaz |
| 5 | `use(peek)` — sonraki 3 sekil | `PeekResult(shapes)` |
| 6 | `use(undo)` — ilk kullanim | `UndoResult`, limit azalir |
| 7 | `use(undo)` — 2. kez ayni oyunda | Limit asildi, kullanilamaz |
| 8 | `use(rainbow)` — joker hucre | `RainbowResult` |
| 9 | `use(rainbow)` — cooldown 2 hamle | 2 hamle bekle |
| 10 | `use(freeze)` — TimeTrial modunda | `FreezeResult(seconds)` |
| 11 | `use(freeze)` — Classic modunda | Kullanilmaz (mod kisitlamasi) |
| 12 | `use(freeze)` — 2. kez ayni oyunda | Limit asildi |
| 13 | `onMoveCompleted()` — cooldown azaltma | Cooldown 1 azalir |
| 14 | `grantFreePowerUp(bomb)` — ucretsiz verilme | `GrantedResult` |
| 15 | Maliyet dogrulama: rotate=3, bomb=8, peek=2, undo=5, rainbow=10, freeze=6 | Her biri dogru |
| 16 | `isAvailable(type)` — bakiye + cooldown + limit | Dogru boolean |
| 17 | Oyun baslangicinda tum limitler sifir | Taze baslangic |

### 2.7 CurrencyManager (`lib/game/economy/currency_manager.dart`) `[YAZILDI]`

**Dosya:** `test/game/currency_manager_test.dart` — 26 test

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Baslangic bakiyesi 0 | `balance == 0` |
| 2 | `earnFromLineClear(1)` | +1 ozu |
| 3 | `earnFromLineClear(3)` | +3 ozu |
| 4 | `earnFromCombo('small')` | +0 (kombo bonusu yok) |
| 5 | `earnFromCombo('medium')` | +2 |
| 6 | `earnFromCombo('large')` | +3 |
| 7 | `earnFromCombo('epic')` | +5 |
| 8 | `earnFromSynthesis(2)` | +2 |
| 9 | `earnDailyLogin()` | +3 |
| 10 | `earnFromAd()` | +5 |
| 11 | `spend(3)` — yeterli bakiye | `true`, bakiye -3 |
| 12 | `spend(100)` — yetersiz bakiye | `false`, bakiye degismez |
| 13 | `spend(0)` | `true` (sifir harcama) |
| 14 | `onBalanceChanged` callback tetiklenmesi | Her kazanim/harcamada cagrilir |
| 15 | `applyGlooPlusBonus()` — x1.5 carpan | Kazanimlar %50 artik |
| 16 | `setBalance(50)` | Bakiye 50 |
| 17 | `resetGameStats()` | Oyun ici sayaclar sifir, bakiye korunur |
| 18 | Negatif bakiye olamaz | `balance >= 0` her zaman |
| 19 | `CurrencyCosts.rotate` = 3 | Sabit dogrulama |
| 20 | `CurrencyCosts.bomb` = 8 | Sabit dogrulama |

### 2.8 ShapeGenerator + GelShape (`lib/game/shapes/gel_shape.dart`) `[YAZILDI]`

**Dosya:** `test/game/shape_generator_test.dart` — 27 test

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `GelShape.dot` — 1 hucre | `cellCount == 1` |
| 2 | `GelShape.h3` — yatay 3 | `cellCount == 3`, `rowCount == 1` |
| 3 | `GelShape.sq` — 2x2 kare | `cellCount == 4`, `rowCount == 2` |
| 4 | `rotated()` — h3 dondur | v3 (veya ekvivalent) |
| 5 | `at(anchorRow, anchorCol)` — koordinat donusumu | Dogru (row,col) listesi |
| 6 | 16 sekil sabitinin hepsi gecerli | `cellCount > 0` her biri |
| 7 | `generateHand()` — 3 parca doner | `length == 3` |
| 8 | `generateHand()` — tum parcalar non-null | Hicbir eleman null degil |
| 9 | `generateSeededHand(seed)` — deterministik | Ayni seed = ayni el |
| 10 | `generateSeededHand(seed1) != generateSeededHand(seed2)` | Farkli seed = farkli el |
| 11 | `generateNextSeededHand()` — ardisik | Her cagri farkli el |
| 12 | Zorluk egrisi: skor 0 | Agirlik kucuk sekillere |
| 13 | Zorluk egrisi: skor 5000+ | Agirlik buyuk sekillere |
| 14 | Zorluk asla 0.95'i gecmez | `difficulty <= 0.95` |
| 15 | Merhamet: 3 ardisik kayip → 0.7x zorluk | Daha kolay el |
| 16 | Merhamet: 5 hamle temizleme yok → kurtarici | Kolay parcalar |
| 17 | `recordClear()` — merhamet sayacini sifirla | Sayac 0 |
| 18 | `recordMoveWithoutClear()` — sayaci artir | Sayac +1 |
| 19 | `getDifficulty(score, gamesPlayed)` | Formul dogrulama |
| 20 | Renk agirliklari: izgarada az bulunan renkler yuksek | Dagitim kontrolu |

### 2.9 LevelData + LevelProgression `[YAZILDI]`

**Dosya:** `test/game/level_progression_test.dart` — 25+ test

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `getLevel(1)` — ilk seviye | Gecerli LevelData |
| 2 | `getLevel(50)` — son onceden tanimli | Gecerli LevelData |
| 3 | `getLevel(51)` — prosedurel | Gecerli, otomatik uretilmis |
| 4 | `getLevel(100)` — yuksek prosedurel | Gecerli, artan zorluk |
| 5 | Tum 50 seviyede `targetScore > 0` | Pozitif hedef |
| 6 | Tum 50 seviyede `maxMoves > 0` | Pozitif hamle limiti |
| 7 | Tum 50 seviyede `rows >= 6, cols >= 6` | Minimum boyut |
| 8 | Breathing room: seviye 10, 20, 30, 40, 50 | Daha kolay seviye |
| 9 | `LevelData.allSpecialCells()` — bos seviye | Sadece sekil bazli taslar |
| 10 | `LevelData.allSpecialCells()` — buz + tas | Birlesik liste |
| 11 | `computeShapeCells(diamond)` | Kose taslari |
| 12 | `computeShapeCells(cross)` | Kose taslari (farkli desen) |
| 13 | `computeShapeCells(lShape)` | Sag ust tas |
| 14 | `computeShapeCells(rectangle)` | Bos (ek tas yok) |
| 15 | `computeShapeCells(corridor)` | Kenar taslari |
| 16 | `MapShape` enum 5 deger | rectangle, diamond, cross, lShape, corridor |
| 17 | Prosedurel seviyede zorluk egrisi | Skor/hamle orani artiyor |

### 2.10 GlooGame (`lib/game/world/game_world.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `startGame()` — Classic mod | Status: playing, skor 0, el olusturuldu |
| 2 | `startGame()` — TimeTrial | `remainingSeconds == 90` |
| 3 | `startGame()` — ColorChef | `chefProgress == 0`, hedef renk atandi |
| 4 | `startGame()` — Level | `levelData` aktif, maxMoves kontrol |
| 5 | `startGame()` — Daily | Seeded RNG, tarih bazli |
| 6 | `startGame()` — Duel | Seeded RNG, 120sn |
| 7 | `placePiece(cells, color)` — gecerli hamle | Skor guncellemesi, pipeline calisir |
| 8 | `placePiece()` — gecersiz hamle | `false`, sey degismez |
| 9 | `_evaluateBoard()` — sentez + temizleme + gravity | Tam pipeline akisi |
| 10 | `_evaluateBoard()` — sentez callback tetiklenir | `onColorSynthesis` cagirilir |
| 11 | `_evaluateBoard()` — Chef modu hedef ilerlemesi | `onChefProgress` cagirilir |
| 12 | `_evaluateBoard()` — Chef seviye tamamlama | `onChefLevelComplete`, grid sifirlanir |
| 13 | `_evaluateBoard()` — TimeTrial bonus sure | `+2sn x temizlenen_satir` |
| 14 | `_evaluateBoard()` — Level hedef skor | `onLevelComplete` tetiklenir |
| 15 | `_evaluateBoard()` — gravity kaskad temizleme | Ikinci temizleme turu |
| 16 | `checkGameOver(hand)` — Classic (izgara dolu) | `onGameOver` tetiklenir |
| 17 | `checkGameOver()` — TimeTrial (sure bitti) | `onGameOver` |
| 18 | `checkGameOver()` — Level (hamle bitti) | `onGameOver` |
| 19 | `continueWithExtraMoves(5)` — ikinci sans | Oyun devam eder, 5 ekstra hamle |
| 20 | `freeze()` — TimeTrial | Sure durur |
| 21 | `setInitialHighScore(val)` | highScore atanir |
| 22 | `setGamesPlayed(val)` | Smart RNG'ye yansir |
| 23 | `setCurrencyBalance(val)` | CurrencyManager'a atanir |
| 24 | 7 mod icin callback zinciri | Her modda dogru callback'ler tetiklenir |

### 2.11 ELO & Matchmaking (`lib/game/pvp/matchmaking.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `EloSystem.calculateChange(1200, 1000, 100)` — guclu oyuncu kazanir | Kucuk ELO kazanci |
| 2 | `EloSystem.calculateChange(1000, 1200, 100)` — zayif oyuncu kazanir | Buyuk ELO kazanci |
| 3 | `EloSystem.calculateChange` — K=32 | K faktoru sabit |
| 4 | `EloLeague.fromElo(500)` | Bronze |
| 5 | `EloLeague.fromElo(1000)` | Silver |
| 6 | `EloLeague.fromElo(1500)` | Gold |
| 7 | `EloLeague.fromElo(2000)` | Diamond |
| 8 | `EloLeague.fromElo(2500)` | GlooMaster |
| 9 | `isCompatible(elo1=1000, elo2=1150)` | `true` (fark ≤200) |
| 10 | `isCompatible(elo1=1000, elo2=1300)` | `false` (fark >200) |
| 11 | `botDifficulty(elo=1000)` | Orta zorluk |
| 12 | `botDifficulty(elo=2500)` | Yuksek zorluk |
| 13 | `ObstacleGenerator.fromLineClear(lines)` | Gecerli engel paketi |
| 14 | `ObstacleGenerator` — seeded deterministik | Ayni seed = ayni engeller |
| 15 | `MatchRequest` olusturma | Tum alanlar dolu |
| 16 | `MatchResult` — bot eslestirme | `isBot == true` |
| 17 | `DuelResult` — ELO degisimi isareti | Kazanan +, kaybeden - |

### 2.12 ResourceManager (Meta-Game) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Ada binasi seviye yukselme (gelEnergy yeterli) | Seviye artar, enerji azalir |
| 2 | Ada binasi seviye yukselme (enerji yetersiz) | Basarisiz, sey degismez |
| 3 | Karakter kostum kilidi acma | Kostum aktif, maliyet duser |
| 4 | Yetenek upgrade | Yetenek seviyesi artar |
| 5 | Sezon pasi XP kazanma | XP artar, tier acilir |
| 6 | Sezon pasi premium odul | Gloo+ gerekli kontrol |
| 7 | Gorev ilerleme guncelleme | Ilerleme kaydedilir |
| 8 | Gorev tamamlama | Odul verilir, ilerleme maks |
| 9 | Gunluk gorev sifirlama (yeni gun) | Yeni gorevler, ilerleme sifir |
| 10 | Haftalik gorev sifirlama | Yeni gorevler |

---

## 3. Data Layer

### 3.1 LocalRepository (`lib/data/local/local_repository.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `saveScore('classic', 1000)` + `getHighScore('classic')` | 1000 |
| 2 | `saveScore('classic', 500)` mevcut 1000 uzerinde | HighScore degismez (1000) |
| 3 | `saveScore('classic', 1500)` mevcut 1000 uzerinde | HighScore guncellenir (1500) |
| 4 | `getHighScore('olmayan_mod')` | 0 (varsayilan) |
| 5 | `setOnboardingDone()` + `getOnboardingDone()` | `true` |
| 6 | `getOnboardingDone()` — ilk cagri | `false` |
| 7 | `checkAndUpdateStreak()` — ardisik gun | Streak +1 |
| 8 | `checkAndUpdateStreak()` — ayni gun | Streak degismez |
| 9 | `checkAndUpdateStreak()` — 2 gun atlama | Streak = 1 (sifirlandi) |
| 10 | `addDiscoveredColor('orange')` + `getDiscoveredColors()` | `['orange']` |
| 11 | Tekrar `addDiscoveredColor('orange')` | Set oldugu icin duplikat yok |
| 12 | `saveDailyResult(500)` + `getDailyScore()` | 500 |
| 13 | `isDailyCompleted()` — bugun tamamlandi | `true` |
| 14 | `isDailyCompleted()` — dun tamamlandi | `false` (yeni gun) |
| 15 | `getCompletedLevels()` — bos | `[]` |
| 16 | `saveLevelScore(5, 1000)` | Seviye 5 tamamlandi |
| 17 | `getMaxCompletedLevel()` | En yuksek tamamlanan ID |
| 18 | `saveGelOzu(100)` + `getGelOzu()` | 100 |
| 19 | `clearAllData()` — GDPR | Tum anahtarlar silinir |
| 20 | `getRedeemedCodes()` + `addRedeemedCode('ABC')` | `['ABC']` |
| 21 | `getUnlockedProducts()` + `addUnlockedProducts(['p1'])` | `['p1']` |
| 22 | `saveIslandState(map)` + `getIslandState()` | Ayni map |
| 23 | `saveCharacterState(map)` + `getCharacterState()` | Ayni map |
| 24 | `saveSeasonPassState(map)` + `getSeasonPassState()` | Ayni map |
| 25 | `saveDailyQuestProgress(map)` + `getDailyQuestProgress()` | Ayni map |

### 3.2 RemoteRepository (`lib/data/remote/remote_repository.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `submitScore('classic', 1000)` — yapilandirilmis | Insert basarili |
| 2 | `submitScore()` — yapilandirilmamis (isConfigured=false) | Sessizce atlanir |
| 3 | `getGlobalLeaderboard('classic', 10, false)` | Top 10 skor listesi |
| 4 | `getGlobalLeaderboard()` — bos tablo | Bos liste |
| 5 | `getUserRank('classic', false)` | Kullanici sirasi (int) |
| 6 | `ensureProfile('Player1')` | Profil upsert basarili |
| 7 | `getDailyPuzzle()` — bugunun tarihinde kayit var | Kayit doner |
| 8 | `getDailyPuzzle()` — kayit yok | `null` |
| 9 | `submitDailyResult(500, true)` | Upsert basarili |
| 10 | `redeemCode('VALID_CODE')` — gecerli, kullanim hakkinda | Urun ID'leri listesi |
| 11 | `redeemCode('USED_CODE')` — max kullanim asilmis | Bos/null |
| 12 | `redeemCode('EXPIRED')` — suresi dolmus | Bos/null |
| 13 | `redeemCode('INVALID')` — var olmayan kod | Bos/null |
| 14 | `saveMetaState(islandState: {...})` | Upsert basarili |
| 15 | `loadMetaState()` — kayit var | Map doner |
| 16 | `loadMetaState()` — kayit yok | `null` |
| 17 | `saveMetaState(gelEnergy: 50)` — kismi guncelleme | Sadece energy guncellenir |
| 18 | Auth yok iken tum metodlar | Sessizce atlanir (userId null) |

### 3.3 SupabaseClient (`lib/data/remote/supabase_client.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `isConfigured` — gercek URL/key | `true` |
| 2 | `isConfigured` — placeholder | `false` |
| 3 | `currentUserId` — oturum acik | UUID string |
| 4 | `currentUserId` — oturum yok | `null` |

### 3.4 PvpRealtimeService (`lib/data/remote/pvp_realtime_service.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `joinMatchmakingQueue(userId, elo)` | Realtime channel'a katilim |
| 2 | `listenForMatch(callback)` — eslestirme bulundu | Callback cagirilir |
| 3 | `joinDuelRoom(matchId)` | Channel acilir |
| 4 | `broadcastScore(matchId, score)` | Event gonderilir |
| 5 | `sendObstacle(matchId, packet)` | Event gonderilir |
| 6 | `listenOpponentScore(matchId)` | Stream aktif |
| 7 | `listenOpponentObstacles(matchId)` | Stream aktif |
| 8 | `leaveDuelRoom(matchId)` | Channel kapatilir |
| 9 | Timeout (30sn) → bot fallback | `isBot: true` sonucu |
| 10 | `dispose()` — temizlik | Tum subscription'lar iptal |

### 3.5 DataModels (`lib/data/local/data_models.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `Score` olusturma tum alanlarla | Tum alanlar dogru |
| 2 | `UserProfile` olusturma | Tum alanlar dogru |
| 3 | `UserProfile` varsayilan degerler | sfxEnabled=true, streak=0 vb. |

---

## 4. Services

### 4.1 AdManager (`lib/services/ad_manager.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `initialize()` — web platformda | Sessizce atlanir (kIsWeb) |
| 2 | `showInterstitial()` — 4. oyun | Reklam gosterilir |
| 3 | `showInterstitial()` — 1. oyun | Gosterilmez (frekans) |
| 4 | `showInterstitial()` — 3. oyundan once (yeni oyuncu korumasi) | Gosterilmez |
| 5 | `showRewarded(onRewarded)` | Callback cagirilir |
| 6 | `setAdsRemoved(true)` | Hicbir reklam yuklenmez |
| 7 | Anti-frustration: 5dk'da 2 kayip | Interstitial gosterilmez |
| 8 | Gunluk limit: 8 interstitial | 9. deneme basarisiz |
| 9 | Gunluk limit: 5 rewarded | 6. deneme basarisiz |
| 10 | iOS vs Android ad unit ID'leri | Platform bazli dogru ID |
| 11 | `showBanner()` — sadece home | Banner yukler |

### 4.2 PurchaseService (`lib/services/purchase_service.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `initialize()` — web platformda | Sessizce atlanir |
| 2 | `purchaseProduct('gloo_remove_ads')` | Satin alma akisi baslar |
| 3 | `isPurchased('gloo_remove_ads')` — satin alinmis | `true` |
| 4 | `isPurchased('gloo_remove_ads')` — alinmamis | `false` |
| 5 | `isGlooPlus` — aylik abone | `true` |
| 6 | `isGlooPlus` — yillik abone | `true` |
| 7 | `isGlooPlus` — abone degil | `false` |
| 8 | `adsRemoved` — remove_ads satin alinmis | `true` |
| 9 | `adsRemoved` — starter_pack satin alinmis | `true` (icerir) |
| 10 | `adsRemoved` — Gloo+ abone | `true` |
| 11 | `unlockProducts(['p1','p2'])` | Her ikisi `isPurchased` true |
| 12 | `finalizePurchase()` — store onay | Tamamlandi |
| 13 | 7 urun ID'sinin hepsi gecerli | kRemoveAds, kSound*, kTexture, kStarter, kGlooPlus* |

### 4.3 AnalyticsService (`lib/services/analytics_service.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `setEnabled(false)` → `logGameStart()` | Hicbir sey loglanmaz |
| 2 | `setEnabled(true)` → `logGameStart('classic')` | Event loglanir |
| 3 | `logGameEnd('classic', 1000, 120)` | Dogru parametreler |
| 4 | `logShare('video')` | Event loglanir |
| 5 | `logPurchase('gloo_remove_ads')` | Event loglanir |
| 6 | `logLevelComplete(5)` | Event loglanir |

---

## 5. Providers (Riverpod)

### 5.1 GameProvider `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `gameProvider(GameMode.classic)` — baslangic state | `score=0, status=idle` |
| 2 | `updateScore(500)` | `state.score == 500` |
| 3 | `updateFill(40)` | `state.filledCells == 40` |
| 4 | `updateStatus(GameStatus.playing)` | `state.status == playing` |
| 5 | `updateRemainingSeconds(85)` | `state.remainingSeconds == 85` |
| 6 | `updateChef(3, 5)` | `chefProgress=3, chefRequired=5` |
| 7 | `updateGelOzu(100)` | `state.gelOzu == 100` |
| 8 | `updateMovesUsed(5)` | `state.movesUsed == 5` |
| 9 | `reset()` | Tum degerler baslangica doner |
| 10 | Farkli modlar icin bagimsiz state | Classic ve TimeTrial ayri |

### 5.2 AudioSettingsProvider `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Varsayilan state | sfx=true, music=true, haptics=true |
| 2 | `toggleSfx()` | sfx false olur |
| 3 | `toggleSfx()` tekrar | sfx true olur |
| 4 | `toggleColorBlindMode()` | colorBlindMode toggled |
| 5 | `setGlooPlus(true)` | glooPlus = true |
| 6 | `setAdsRemoved(true)` | adsRemoved = true |
| 7 | `setAnalyticsEnabled(false)` | analyticsEnabled = false |
| 8 | State degisikligi SharedPreferences'a yazilir | Persist dogrulama |

### 5.3 LocaleProvider `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Varsayilan locale | Sistem diline gore |
| 2 | `setLocale(Locale('tr'))` | Turkce aktif |
| 3 | `setLocale(Locale('ja'))` | Japonca aktif |
| 4 | Desteklenmeyen dil | Ingilizce'ye duser |
| 5 | `stringsProvider` — tr locale | TrStrings instance |
| 6 | `stringsProvider` — en locale | EnStrings instance |

### 5.4 UserProvider `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `localRepositoryProvider` | SharedPreferences yuklendi |
| 2 | `highScoreProvider('classic')` | Kaydedilmis yuksek skor |
| 3 | `streakProvider` — ardisik giris | Streak degeri |
| 4 | `eloProvider` | Oyuncu ELO (varsayilan 1000) |

---

## 6. Screens & UI

### 6.1 HomeScreen (`lib/features/home_screen/home_screen.dart`) `[KISMI — 8 test basarisiz]`

**Dosya:** `test/features/home_screen_test.dart` — 8 widget test (hepsi basarisiz)

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Ekran yuklenir | Tum 7 mod karti gorunur |
| 2 | Classic kart tiklama | `/game/classic` navigasyonu |
| 3 | ColorChef kart tiklama | `/game/colorChef` navigasyonu |
| 4 | TimeTrial kart tiklama | `/game/timeTrial` navigasyonu |
| 5 | Zen kart — Gloo+ yok | Kilit ikonu gorunur |
| 6 | Zen kart — Gloo+ var | Kilit yok, `/game/zen` navigasyonu |
| 7 | Zen kart tiklama (kilitli) | `/shop` navigasyonu |
| 8 | Level kart tiklama | `/levels` navigasyonu |
| 9 | Duel kart tiklama | `/pvp-lobby` navigasyonu |
| 10 | Daily banner gorunur | Tarih + durum |
| 11 | Daily banner tiklama | `/daily` navigasyonu |
| 12 | Alt bar: 4 navigasyon ogesi | Leaderboard, Collection, Shop, Settings |
| 13 | Leaderboard butonu | `/leaderboard` |
| 14 | Collection butonu | `/collection` |
| 15 | Shop butonu | `/shop` |
| 16 | Settings butonu | `/settings` |
| 17 | Streak badge (streak >= 2) | Ates ikonu + sayi gorunur |
| 18 | Streak badge (streak < 2) | Badge gorunmez |
| 19 | MetaGame bar gorunur | Ada, Karakter, Sezon Pasi linkleri |
| 20 | Ilk acilis → onboarding yonlendirmesi | `/onboarding` navigasyonu |
| 21 | Colorblind dialog — ilk gosterim | Dialog gorunur |
| 22 | Colorblind dialog — "Evet" secimi | colorBlindMode aktif |
| 23 | Colorblind dialog — bir kez gosterilir | Ikinci acilista yok |

### 6.2 OnboardingScreen (`lib/features/onboarding/onboarding_screen.dart`) `[KISMI — 6 test]`

**Dosya:** `test/features/onboarding_test.dart` — 6 widget test

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | 3 adim sayfa gorunumu | PageView 3 sayfa |
| 2 | "Ileri" butonu — 1. adim | 2. adima gecer |
| 3 | "Ileri" butonu — 2. adim | 3. adima gecer |
| 4 | "Basla" butonu — 3. adim | Onboarding tamamlandi, `/` navigasyonu |
| 5 | Swipe ile sayfa degistirme | PageView scroll |
| 6 | Tamamlama — `onboarding_done` kaydedilir | SharedPreferences'ta true |
| 7 | Geri butonu — 1. adimda | Hiçbir sey olmaz |

### 6.3 GameScreen (`lib/features/game_screen/game_screen.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Classic mod acilis | Izgara gorunur, 3 el parcasi, skor 0 |
| 2 | Hucreye tiklama — gecerli yerlestirme | Parca yerlesir, skor guncellenir |
| 3 | Hucreye tiklama — gecersiz yerlestirme | Toast mesaji, hamle sayilmaz |
| 4 | Oncizim (preview) gorunumu | Secili parca yerlestirme oncesi gorunur |
| 5 | Satir temizleme → CellBurstEffect | Patlama animasyonu |
| 6 | Renk sentezi → ColorSynthesisBloomEffect | Bloom animasyonu |
| 7 | Kombo → ComboEffect | Kombo animasyonu + ekran sarsintisi (epic) |
| 8 | Near-miss → NearMissEffect | Vignette animasyonu |
| 9 | Power-up toolbar gorunur | Jel Ozu sayaci + butonlar |
| 10 | Rotate power-up tiklama | Secili parca doner |
| 11 | Bomb power-up tiklama | Hucre secim modu, 3x3 patlama |
| 12 | Game over → overlay gorunur | Skor, yuksek skor, ikinci sans butonu |
| 13 | Ikinci sans — reklam izle | 5 ekstra hamle, oyun devam |
| 14 | Paylasim butonu | ShareManager.shareScore() |
| 15 | TimeTrial — geri sayim cubugu | Sure azaliyor |
| 16 | TimeTrial — sure bitince | Game over |
| 17 | TimeTrial — satir temizleme → +2sn | Sure artar |
| 18 | ColorChef — hedef renk gosterimi | Chef target bar |
| 19 | ColorChef — hedef tamamlama | Seviye overlay, grid sifirlanir |
| 20 | Zen — huzurlu mod (game over yok) | Stres-free akis |
| 21 | Level — hamle limiti gosterimi | Kalan hamle |
| 22 | Level — hedef skor tamamlama | Level complete overlay |
| 23 | Level — hamle bitti, hedef ulasilmadi | Game over |
| 24 | Duel — rakip skoru gorunur | Realtime guncelleme |
| 25 | Duel — engel gonderme/alma | Hucre tipi degisir |
| 26 | Duel — 120sn sonrasi | Duel result overlay |
| 27 | Ambient droplets | Arka plan animasyonu (mod bazli renk) |

### 6.4 GameOverlay (HUD) (`lib/features/game_screen/game_overlay.dart`) `[YAZILDI]`

**Dosya:** `test/features/game_overlay_test.dart` — 8 widget test

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Classic HUD | Skor + FillBar gorunur |
| 2 | TimeTrial HUD | CountdownBar gorunur |
| 3 | ColorChef HUD | ChefTargetBar gorunur |
| 4 | Zen HUD | ZenAmbienceBar gorunur |
| 5 | Level HUD | FillBar + seviye bilgisi |
| 6 | Duel HUD | CountdownBar + ELO bilgisi |
| 7 | Skor guncelleme | Text widget degisir |
| 8 | FillBar ilerleme | Doluluk cubugu dogru oran |

### 6.5 GameOverOverlay (`lib/features/game_screen/game_over_overlay.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Overlay gorunumu | Skor + yuksek skor gorunur |
| 2 | Yeni rekor | "Yeni Rekor!" badge gorunur |
| 3 | Ikinci sans butonu | "Reklam Izle → 3 Ekstra Hamle" |
| 4 | Ikinci sans — NearMiss critical | "Kurtarilabilir!" badge |
| 5 | Ikinci sans — skor > highScore*0.9 | "Rekoruna yakinsin!" badge |
| 6 | "Tekrar" butonu | Yeni oyun baslar |
| 7 | "Ana Sayfa" butonu | `/` navigasyonu |
| 8 | Paylasim butonu | Share dialog |
| 9 | Duel modu — DuelResultOverlay | ELO degisimi gorunur |

### 6.6 DuelResultOverlay (`lib/features/pvp/duel_result_overlay.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Kazanma durumu | "Kazandin!" + yesil renk |
| 2 | Kaybetme durumu | "Kaybettin" + kirmizi renk |
| 3 | Berabere durumu | "Berabere" |
| 4 | ELO degisimi gosterimi | "+15 ELO" veya "-12 ELO" |
| 5 | Jel Ozu odulu | Odul miktari gorunur |
| 6 | "Tekrar Oyna" butonu | `/pvp-lobby` navigasyonu |
| 7 | "Ana Sayfa" butonu | `/` navigasyonu |

### 6.7 SettingsScreen (`lib/features/settings/settings_screen.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | SFX toggle — acik | Ses efektleri caliyor |
| 2 | SFX toggle — kapali | Ses efektleri sessiz |
| 3 | Muzik toggle | Arka plan muzigi acilir/kapanir |
| 4 | Haptik toggle | Titresim acilir/kapanir |
| 5 | Renk koru modu toggle | shortLabel gorunur olur |
| 6 | Analytics toggle — kapali | Tracking durur |
| 7 | Dil secimi — Turkce | Tum metinler Turkce |
| 8 | Dil secimi — Japonca | Tum metinler Japonca |
| 9 | GDPR veri silme | Tum veriler temizlenir |
| 10 | Geri butonu | Onceki ekrana doner |

### 6.8 ShopScreen (`lib/features/shop/shop_screen.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | 7 IAP urunu gorunur | Tum urunler listede |
| 2 | Urun tiklama — satin alma akisi | Store dialog acilir |
| 3 | Satin alinmis urun | "Satin Alindi" badge, buton devre disi |
| 4 | Gloo+ aylik/yillik butonlari | Abonelik akisi |
| 5 | Redeem code girisi — gecerli kod | Urunler acilir, basari mesaji |
| 6 | Redeem code girisi — gecersiz kod | Hata mesaji |
| 7 | Redeem code girisi — zaten kullanilmis | Hata mesaji |
| 8 | Redeem code girisi — suresi dolmus | Hata mesaji |
| 9 | Redeem code — bos input | Buton devre disi |
| 10 | Satin alma sirasinda yukleniyor gostergesi | CircularProgressIndicator |

### 6.9 LeaderboardScreen (`lib/features/leaderboard/leaderboard_screen.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Classic tab aktif | Classic skorlari gorunur |
| 2 | TimeTrial tab tiklama | TimeTrial skorlari yuklenir |
| 3 | Haftalik toggle acik | Bu haftanin skorlari |
| 4 | Haftalik toggle kapali | Tum zamanlarin skorlari |
| 5 | Kullanici sirasi gorunur | "Sen: #42" gibi |
| 6 | Bos leaderboard | "Henuz skor yok" mesaji |
| 7 | Yukleniyor durumu | Shimmer/spinner |
| 8 | Hata durumu | Hata mesaji + yeniden dene |

### 6.10 DailyPuzzleScreen (`lib/features/daily_puzzle/daily_puzzle_screen.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Bugun tamamlanmamis | "Basla" butonu |
| 2 | Bugun tamamlanmis | Skor + paylasim butonu |
| 3 | Tarih gosterimi | Bugunun tarihi |
| 4 | Basla butonu | `/game/daily` navigasyonu |
| 5 | Paylasim butonu | `shareDailyResult()` |

### 6.11 LevelSelectScreen (`lib/features/level_select/level_select_screen.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | 50 seviye gosterimi | Grid/liste seklinde |
| 2 | Tamamlanmis seviye — yesil rozet | Rozet gorunur |
| 3 | Kilitli seviye — kilit ikonu | Tiklanabilir degil |
| 4 | Acik seviye tiklama | `/game/level/:id` navigasyonu |
| 5 | 5 bolum gruplama | Her 10 seviye bir grup |
| 6 | Yuksek skor gosterimi | Her seviye icin |
| 7 | Yildiz derecelendirme | 1-3 yildiz (skora gore) |

### 6.12 CollectionScreen (`lib/features/collection/collection_screen.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | 8 koleksiyon yuva gorunur | Orange, Green, Purple, vb. |
| 2 | Kesfedilmis renk — renkli | Renk gorunur |
| 3 | Kesfedilmemis renk — gri/soru isareti | Kilit gorunur |
| 4 | Yeni renk kesfetme bildirimi | Animasyon + badge |
| 5 | Tum renkler kesfedilmis | "Koleksiyon Tamamlandi" mesaji |
| 6 | Ilerleme: "5/8 Kesfedildi" | Dogru sayi |

### 6.13 PvpLobbyScreen (`lib/features/pvp/pvp_lobby_screen.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | ELO ve lig gorunur | "1200 ELO — Silver" |
| 2 | "Eslestirme Ara" butonu | Arama baslar |
| 3 | Arama durumu — bekleniyor | Spinner + sayac |
| 4 | Eslestirme bulundu | Duel ekranina navigasyon |
| 5 | 30sn timeout → bot | Bot maciyla baslar |
| 6 | "Iptal" butonu | Arama durur |
| 7 | Win/Loss istatistikleri gorunur | "15W / 8L" |
| 8 | Lig rozetleri (5 lig) | Bronze-GlooMaster ikonlari |

### 6.14 IslandScreen (`lib/features/island/island_screen.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | 5 bina gorunur | gelFactory, asmrTower, colorLab, arena, harbor |
| 2 | Bina seviye gosterimi | "Lv.3" gibi |
| 3 | Yukseltme butonu — yeterli enerji | Seviye artar |
| 4 | Yukseltme butonu — yetersiz enerji | Devre disi, hata mesaji |
| 5 | Jel Enerjisi sayaci | Guncel enerji |
| 6 | Backend sync — kayit sonrasi | `saveMetaState()` cagirilir |
| 7 | Backend load — acilista | Local + backend karsilastirmasi |

### 6.15 CharacterScreen (`lib/features/character/character_screen.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Karakter gorunumu | Mevcut karakter + kostum |
| 2 | Kostum secimi | Aktif kostum degisir |
| 3 | Kilitli kostum | Kilit ikonu, fiyat gosterimi |
| 4 | Yetenek yukselme | Yetenek seviyesi artar |
| 5 | Enerji maliyeti | Dogru maliyet gosterimi |
| 6 | Backend sync | `saveMetaState()` |

### 6.16 SeasonPassScreen (`lib/features/season_pass/season_pass_screen.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | 50 tier gorunur | Ilerleme cubugu |
| 2 | XP gosterimi | Mevcut XP / sonraki tier XP |
| 3 | Ucretsiz odul — acik | Odul gorunur, al butonu |
| 4 | Premium odul — Gloo+ yok | Kilit ikonu |
| 5 | Premium odul — Gloo+ var | Odul al butonu |
| 6 | Tier ilerleme animasyonu | XP kazandiginda cubuk dolumu |
| 7 | Backend sync | `saveMetaState()` |

### 6.17 QuestOverlay (`lib/features/quests/quest_overlay.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | 3 gunluk gorev gorunur | Tanim + ilerleme |
| 2 | 5 haftalik gorev gorunur | Tanim + ilerleme |
| 3 | Gorev ilerleme cubugu | Dogru oran |
| 4 | Tamamlanmis gorev | Yesil tik, odul |
| 5 | Yeni gun → gorevler yenilenir | Sifirlanan ilerleme |
| 6 | Yeni hafta → haftalik yenilenir | Sifirlanan ilerleme |
| 7 | Backend sync | `saveMetaState()` |

---

## 7. VFX & Animasyonlar

### 7.1 GelCellPainter (`lib/features/game_screen/gel_cell_painter.dart`) `[MANUAL]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Normal hucre — 6 katman CustomPainter | Nefes animasyonu |
| 2 | Bos hucre | Sadece arka plan |
| 3 | Buz hucre — buz katman gorseli | Buz dokusu gorunur |
| 4 | Kilitli hucre — kilit renk gorseli | Kilit ikonu + renk |
| 5 | Tas hucre — gri engel | Yerlestirilemiyor gorunumu |
| 6 | Renk koru modu | shortLabel etiketi gorunur |
| 7 | Rainbow hucre | Gokkusagi gorseli |

### 7.2 CellBurstEffect `[MANUAL]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Patlama tetiklenir | 16 parcacik animasyonu |
| 2 | Bezier yolu | Parcaciklar egri izler |
| 3 | Gecikme (delay) | Merkeze olan mesafeye gore |
| 4 | `onDismiss` callback | Animasyon bitince cagirilir |

### 7.3 ComboEffect `[MANUAL]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Small kombo | Hafif efekt |
| 2 | Epic kombo | Guclu efekt + ScreenShake (4px) |
| 3 | `onDismiss` callback | Animasyon bitince cagirilir |

### 7.4 NearMissEffect `[MANUAL]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Standard near-miss | Hafif vignette |
| 2 | Critical near-miss | Guclu kirmizi vignette |
| 3 | `onDismiss` callback | Animasyon bitince cagirilir |

### 7.5 ColorSynthesisBloomEffect `[MANUAL]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Sentez tetiklenir | Flas + 2 halka + 10 parcacik |
| 2 | 700ms sure | Animasyon tamamlanir |
| 3 | `onDismiss` callback | Animasyon bitince cagirilir |
| 4 | Dogru renk | Sentez sonucu renginde |

### 7.6 AmbientGelDroplets `[MANUAL]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Classic mod | Cyan damlaciklar |
| 2 | Zen mod | Yesil damlaciklar |
| 3 | Duel mod | Kirmizi damlaciklar |
| 4 | 10 damlacik | Yuzucu animasyon |

### 7.7 PowerUpActivateEffect `[MANUAL]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Power-up aktivasyonu | Pulse animasyonu |
| 2 | Power-up rengine gore | Tip bazli renk |

---

## 8. Audio & Haptics

### 8.1 AudioManager (`lib/audio/audio_manager.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `initialize()` | Audio session yapilandirilir |
| 2 | `playSfx(path)` — sfx acik | Ses caliniyor |
| 3 | `playSfx(path)` — sfx kapali | Sessiz |
| 4 | `playSfx()` — dosya bulunamazsa | Sessizce atlanir |
| 5 | `playMusic(path, loop: true)` | Muzik baslar |
| 6 | `pauseMusic()` | Muzik durur |
| 7 | `resumeMusic()` | Muzik devam eder |
| 8 | `stopMusic()` | Muzik durur, pozisyon sifirlanir |
| 9 | 6 esanli ses | Pool tasmaz, round-robin |
| 10 | Pitch varyasyonu | 0.9-1.1x arasi |
| 11 | iOS ambient ses kategorisi | Diger uygulamalarla karisir |
| 12 | `setSfxEnabled(false)` | SFX devre disi |
| 13 | `setMusicEnabled(false)` | Muzik devre disi |

### 8.2 HapticManager (`lib/audio/haptic_manager.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `light()` — haptic acik | Hafif titresim |
| 2 | `medium()` — haptic acik | Orta titresim |
| 3 | `heavy()` — haptic acik | Guclu titresim |
| 4 | `setEnabled(false)` — sonraki cagrilar | Titresim yok |
| 5 | Web platformda | Sessizce atlanir |

---

## 9. Viral Pipeline

### 9.1 ClipRecorder (`lib/viral/clip_recorder.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `startRecording()` — idle'dan | State: buffering |
| 2 | `startRecording()` — zaten buffering | Degisiklik yok |
| 3 | `captureFrame()` — buffering | Frame listeye eklenir |
| 4 | `captureFrame()` — idle | Hicbir sey olmaz |
| 5 | `stopRecording()` — buffering | State: processing → idle |
| 6 | `onNearMiss(event)` — tetikleme | Kayit baslar, 5sn auto-stop |
| 7 | `onCombo(large)` — tetikleme | Kayit baslar |
| 8 | `onCombo(small)` — tetikleme | Atlanir (tier < large) |
| 9 | Web platformda (`kIsWeb`) | Tum islemler atlanir |
| 10 | `onClipReady` callback | Cikis dosya yolu doner |
| 11 | `dispose()` — temizlik | Frame'ler dispose edilir |
| 12 | `_finalizeClip()` — bos frame listesi | State idle'a doner (islem yok) |

### 9.2 VideoProcessor (`lib/viral/video_processor.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `processClip(req)` — basarili | Cikis dosyasi yolu doner |
| 2 | `processClip(req)` — FFmpeg hata | `null` doner |
| 3 | Web platformda | `null` doner |
| 4 | Yavas cekim: `slowMotionFactor=2.0` | `setpts=2.0*PTS` |
| 5 | Renk grading | `saturation=1.3, contrast=1.1` |
| 6 | Filigran opsiyonel | Overlay filtresi eklenir |
| 7 | Filigran yok | Sadece base filter |
| 8 | Cikis formati | H.264 MP4, 30fps, yuv420p |

### 9.3 ShareManager (`lib/viral/share_manager.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `shareScore(1000, 'classic')` | "Klasik modunda 1K puan yaptim!" |
| 2 | `shareScore(500, 'colorChef')` | "Renk Sefi modunda 500 puan..." |
| 3 | `shareVideo(path, caption)` — mobil | XFile paylasim dialog |
| 4 | `shareVideo()` — web | Sessizce atlanir |
| 5 | `shareDailyResult(800, '2026-02-28')` | Tarih + skor + hashtag |
| 6 | Hashtag'ler: #Gloo #ASMR #satisfying #puzzle #colorsort | Dogru format |
| 7 | App URL dahil | `https://gloo.app` |
| 8 | `_formatScore(1500000)` | "1.5M" |
| 9 | `_formatScore(1500)` | "1.5K" |
| 10 | `_formatScore(999)` | "999" |

---

## 10. Routing & Navigation

### 10.1 GoRouter (`lib/app/router.dart`) `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `/` → HomeScreen | Dogru ekran |
| 2 | `/onboarding` → OnboardingScreen | Dogru ekran |
| 3 | `/game/classic` → GameScreen(classic) | Classic mod |
| 4 | `/game/colorChef` → GameScreen(colorChef) | Chef mod |
| 5 | `/game/timeTrial` → GameScreen(timeTrial) | TimeTrial mod |
| 6 | `/game/zen` → GameScreen(zen) | Zen mod |
| 7 | `/game/daily` → GameScreen(daily) | Daily mod |
| 8 | `/game/level/5` → GameScreen(level, levelData) | Level 5 |
| 9 | `/game/duel?matchId=x&seed=y&isBot=true` | Duel parametreleri |
| 10 | `/daily` → DailyPuzzleScreen | Dogru ekran |
| 11 | `/shop` → ShopScreen | Dogru ekran |
| 12 | `/leaderboard` → LeaderboardScreen | Dogru ekran |
| 13 | `/settings` → SettingsScreen | Dogru ekran |
| 14 | `/collection` → CollectionScreen | Dogru ekran |
| 15 | `/levels` → LevelSelectScreen | Dogru ekran |
| 16 | `/pvp-lobby` → PvpLobbyScreen | Dogru ekran |
| 17 | `/island` → IslandScreen | Dogru ekran |
| 18 | `/character` → CharacterScreen | Dogru ekran |
| 19 | `/season-pass` → SeasonPassScreen | Dogru ekran |
| 20 | `/game/gecersiz_mod` → Classic fallback | `GameMode.fromString` fallback |
| 21 | Rota onceligi: `/game/level/:id` > `/game/:mode` | Level rota once |
| 22 | Rota onceligi: `/game/duel` > `/game/:mode` | Duel rota once |

---

## 11. Lokalizasyon (L10n)

### 11.1 AppStrings + 12 Dil Dosyasi `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `AppStrings.forLocale(Locale('en'))` | EnStrings instance |
| 2 | `AppStrings.forLocale(Locale('tr'))` | TrStrings instance |
| 3 | Desteklenmeyen dil ('xx') | EnStrings fallback |
| 4 | Her string getter null olmaz | Tum 12 dosya icin |
| 5 | Tum abstract getter'lar implement edilmis | Eksik override yok |
| 6 | Turkce string icerikleri anlamli | Anlamsiz ceviri yok |
| 7 | Arapca RTL uyumu | Metin yonu dogru |
| 8 | Uzun metinler icin overflow yok | Japonca/Almanca uzun kelimeler |

---

## 12. Platform Guards & Edge Cases

### 12.1 Web Uyumluluk `[MANUAL]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Web'de ClipRecorder | Sessizce atlanir |
| 2 | Web'de VideoProcessor | `null` doner |
| 3 | Web'de ShareManager.shareVideo() | Sessizce atlanir |
| 4 | Web'de AdManager.initialize() | Sessizce atlanir |
| 5 | Web'de PurchaseService | Sessizce atlanir |
| 6 | Web'de HapticManager | Sessizce atlanir |

### 12.2 Hata Dayanikliligi `[EKSIK]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | Supabase baglanti hatasi | Uygulama cokmuyor, yerel devam |
| 2 | FFmpeg hata | null doner, toast mesaji |
| 3 | SharedPreferences okuma hatasi | Varsayilan deger kullanilir |
| 4 | Ses dosyasi bulunamazsa | Sessizce atlanir |
| 5 | Auth yok iken RemoteRepository | Tum metodlar sessizce atlanir |
| 6 | `dispose()` sonrasi islem | mounted kontrol |

### 12.3 Performans `[MANUAL]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | 80 hucre dolu izgara render | 60fps |
| 2 | 16 parcacik animasyonu ayni anda | 60fps |
| 3 | 10 ambient damlacik surekli | Dusuk CPU |
| 4 | Realtime broadcast 5sn aralik | Bant genisligi < 1KB/sn |

---

## 13. CI/CD Workflows

### 13.1 GitHub Actions `[EKSIK — workflow dosyalari yazildi, calistirma test edilmedi]`

| # | Senaryo | Beklenen Sonuc |
|---|---------|----------------|
| 1 | `flutter_ci.yml` — PR acildiginda | Analyze + test + format calisir |
| 2 | `flutter_ci.yml` — test basarisiz | PR check basarisiz |
| 3 | `android_build.yml` — push to main | APK artifact olusur |
| 4 | `android_build.yml` — AAB release | AAB artifact olusur |
| 5 | `ios_build.yml` — push to main | iOS build tamamlanir |
| 6 | Concurrency — ayni branch'te yeni push | Onceki run iptal edilir |

---

## Ozet Istatistikler

| Kategori | Toplam Senaryo | Yazildi | Eksik | Manuel |
|----------|----------------|---------|-------|--------|
| Core Utilities | 54 | 42 | 12 | 0 |
| Game Systems | 189 | 107 | 82 | 0 |
| Data Layer | 63 | 0 | 63 | 0 |
| Services | 30 | 0 | 30 | 0 |
| Providers | 28 | 0 | 28 | 0 |
| Screens & UI | 163 | 22 | 141 | 0 |
| VFX & Animasyonlar | 23 | 0 | 0 | 23 |
| Audio & Haptics | 18 | 0 | 18 | 0 |
| Viral Pipeline | 30 | 0 | 30 | 0 |
| Routing | 22 | 0 | 22 | 0 |
| Lokalizasyon | 8 | 0 | 8 | 0 |
| Platform & Edge | 16 | 0 | 10 | 6 |
| CI/CD | 6 | 0 | 6 | 0 |
| **TOPLAM** | **650** | **171** | **450** | **29** |

---

## Oncelik Sirasi (Test Yazimi)

| Oncelik | Alan | Neden |
|---------|------|-------|
| 1 | GlooGame (2.10) | Tum oyun mekanigi buradan geciyor |
| 2 | PowerUpSystem (2.6) | Ekonomi + gameplay kritik |
| 3 | ELO & Matchmaking (2.11) | PvP dogrulugu |
| 4 | LocalRepository (3.1) | Veri kaybini onler |
| 5 | RemoteRepository (3.2) | Backend entegrasyonu |
| 6 | Router (10.1) | Navigasyon cokmeleri |
| 7 | AudioManager (8.1) | Kullanici deneyimi |
| 8 | ShareManager (9.3) | Viral pipeline |
| 9 | ClipRecorder (9.1) | Viral pipeline |
| 10 | GameScreen (6.3) | UI butunlugu |
