# QA Raporu — 2026-03-02

## Saglik Skoru

| Platform | Skor (/100) | Durum |
|----------|-------------|-------|
| iOS      | 82          | Iyi   |
| Android  | 84          | Iyi   |
| Web      | 84          | Iyi   |

> Puanlama: 100'den basla. CRITICAL: -15, HIGH: -10, MEDIUM: -5, LOW: -2.
> 80+ = Iyi, 50-79 = Orta, <50 = Kritik

## Ozet

| Severity | Acik |
|----------|------|
| CRITICAL | 0    |
| HIGH     | 0    |
| MEDIUM   | 2    |
| LOW      | 4    |
| INFO     | 4    |

## Statik Analiz

- `flutter analyze`: **0 issue** — temiz
- `dart format`: **25 dosya formatlanmamis** (182 dosya tarandi)

## Test Suite

- Toplam: **1204 test**
- Gecen: **1204** | Basarisiz: **0** | Atlanan: **0**

---

## Acik Bulgular

### CRITICAL

Temiz.

### HIGH

Temiz.

### MEDIUM

**S7-SEC-3 — GDPR deleteUserData() tam kapsam dogrulanamaz**
- Dosya: `lib/data/remote/remote_repository.dart:407`
- `deleteUserData()` Supabase Edge Function `delete-user`'i cagiriyor. Client tarafinda basarili response donuyor ancak Edge Function'un `pvp_matches` ve `redeem_usages` tablolarini gercekten silip silmedigi dogrulanamaz. Edge Function kodu proje disinda (Supabase Dashboard).
- Etki: GDPR uyumluluk riski.
- Oneri: Edge Function kodunu denetle veya entegrasyon testi ekle.

**S7-SEC-5 — PvP seed spoofing riski**
- Dosya: `lib/data/remote/remote_repository.dart:189-197`
- `createPvpMatch()` insert'te `seed` gondermez (DB DEFAULT kullanilir). Ancak Supabase client INSERT'lerde ek alan eklenebilir — RLS/policy ile `seed` kolonuna yazma engellenmemisse client teorik olarak seed belirleyebilir.
- Etki: Duel modunda hile riski.
- Oneri: Supabase RLS policy'de `seed` kolonunu INSERT'ten haric tut veya mac olusturmayi RPC'ye tasi.

### LOW

**L-1 — 25 dosya dart format ile formatlanmamis**
- Komut: `dart format --set-exit-if-changed -o none lib/ test/`
- 182 dosya tarandi, 25 dosya uyumsuz.
- Onceki durum: 78 dosya (Sprint 8-10'da iyilestirildi).

**L-2 — 5 ekranda ListView children yerine builder kullanilmali**
- `lib/features/settings/settings_screen.dart:74`
- `lib/features/shop/shop_screen.dart:178`
- `lib/features/quests/quest_overlay.dart:164`
- `lib/features/island/island_screen.dart:179`
- `lib/features/character/character_screen.dart:173`
- Etki: Uzun listelerde gereksiz widget olusturma. Mevcut ekranlarda liste kisa oldugu icin pratikte dusuk etki.

**L-3 — 4 StatelessWidget const constructor eksik**
- `_SeasonBackground` (`season_pass_screen.dart:461`)
- `_IslandBackground` (`island_screen.dart:448`)
- `_GlooMascot` (`character_screen.dart:223`)
- `_CharBackground` (`character_screen.dart:464`)
- Not: `_MetaGameBar` public `MetaGameBar` olarak refactor edildi ve `const` constructor eklendi — duzeltildi.

**L-4 — iOS ProMotion 60fps siniri**
- `ios/Runner/Info.plist:5-6`: `CADisableMinimumFrameDurationOnPhone` = `false`
- ProMotion destekli cihazlarda (iPhone 13 Pro+) 120fps yerine 60fps ile sinirli.
- Platform: Yalnizca iOS.

### INFO

- `lib/firebase_options.dart`: Gercek Firebase anahtarlari (`gloo-f7905`). Uretimde `flutterfire configure` ile dogrulanmali.
- `lib/data/remote/supabase_client.dart`: Gercek Supabase anahtarlari girilmis. `isConfigured` guard mevcut.
- `lib/services/ad_manager.dart` + `android/app/src/main/AndroidManifest.xml`: AdMob **test ID**'leri aktif (`ca-app-pub-3940256099942544`). Uretimde gercek ID'lerle degistirilmeli.
- 26 paket guncellenebilir, 1 paket discontinued (`ffmpeg_kit_flutter_full_gpl`). `flutter pub outdated` ile kontrol edilebilir.

---

## Platform-Spesifik Sorunlar

| Platform | Acik Sorun | Detay |
|----------|-----------|-------|
| iOS      | 1 LOW     | ProMotion 60fps siniri (L-4) |
| Android  | 0         | — |
| Web      | 0         | — |
| Tumu     | 2 MEDIUM + 3 LOW | GDPR, seed spoofing, format, ListView, const |

## Performans Metrikleri

| Metrik | Deger |
|--------|-------|
| Statik analiz issue | 0 |
| Test sayisi | 1204 |
| Test basari orani | %100 |
| Formatlanmamis dosya | 25 / 182 |
| Discontinued paket | 1 |
| Guncellenebilir paket | 26 |

## Duzeltme Gecmisi Ozeti

Sprint 1-12 boyunca toplam 15+ bulgu duzeltildi. Sprint 8-10'da guvenlik sertlestirme (SEC-1, SEC-2, SEC-4), test genisletme (+191 test), ve format iyilestirmesi yapildi. Sprint 12'de 4 HIGH (startup crash, try-catch eksikleri, hata yonetimi), 4 MEDIUM (withOpacity deprecation, Color API, provider sorunlari) ve 3 LOW (dead code, import, dispose) duzeltildi. Kalan 2 MEDIUM bulgu harici bagimlilik gerektiriyor (Supabase Edge Function / RLS policy). 4 LOW bulgu dusuk oncelikli kod kalitesi iyilestirmeleri.
