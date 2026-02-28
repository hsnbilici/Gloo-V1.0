# Gloo — Kalan Isler

> Son guncelleme: 2026-03-01
> **Kalan: 13 madde** | Harici hesap/cihaz: 13 | Performans: 0

---

## 1. Performans Optimizasyonu — Tamamlanan (33/33)

- [x] 1.1 — **[CRITICAL] GelCellPainter.shouldRepaint()** — `breathPhase` kontrolu eklendi + shader cache + blur paint cache
- [x] 1.2 — **[CRITICAL] PvP stream subscription leak** — `_cancelSubscriptions()` metodu, handleGameOver + dispose'da cagriliyor
- [x] 1.3 — **[HIGH] Burst/bloom listesi** — `addAll()` + maks 200 burst / 20 bloom siniri
- [x] 1.4 — **[HIGH] Hot path .toList()** — Incelendi: `checkGameOver(List<GelShape>)` parametre tipi List, .toList() zorunlu (3 eleman, ihmal edilebilir)
- [x] 1.5 — **[HIGH] ClipRecorder frame buffer** — 150 frame siniri, eski frame `.dispose()` ile temizleniyor
- [x] 1.6 — **[MEDIUM] setState duel** — Incelendi: grid in-place mutate edildigi icin bos setState zorunlu, aciklayici yorum eklendi
- [x] 1.7 — **[MEDIUM] AudioManager SFX pool** — Lazy init: `List.filled(n, null)` + `_getNextPlayer()` ile ilk kullanimda olusturma
- [x] 2.1 — **[HIGH] Haptic main thread bloklama** — `_fireAndForget()` helper, 10 multi-step profil fire-and-forget
- [x] 2.2 — **[MEDIUM] Matchmaking timeout lifecycle** — `_leaveMatchmakingQueue()` ve `dispose()` icinde timer + debounce iptal
- [x] 3.1 — **[CRITICAL] Cold start paralel** — `Future.wait([Supabase, AdManager, PurchaseService])` ile paralellestirme
- [x] 3.2 — **[CRITICAL] ProGuard/R8** — `isMinifyEnabled + isShrinkResources = true` + `proguard-rules.pro` olusturuldu
- [x] 3.3 — **[HIGH] Shader cache** — `_cachedBodyShader` + size/color key ile tekrar kullanim
- [x] 3.4 — **[HIGH] Blur paint cache** — `_cachedGlowPaint` + color key ile tekrar kullanim
- [x] 3.5 — **[MEDIUM] ClipRRect** — 5 ClipRRect → Container + BoxDecoration + Clip.hardEdge
- [x] 3.6 — **[MEDIUM] Matchmaking debounce** — 250ms `_evaluateDebounce` Timer eklendi

### Tur 2 Tamamlanan (11/11)

- [x] GridManager.grid getter cached (`_invalidateCache()` ile)
- [x] GridManager.filledCells manual loop (allocation-free)
- [x] MediaQuery.of(context) local variable olarak cache'lendi
- [x] ScreenShake Future.delayed → cancellable Timer
- [x] audioSettingsProvider.colorBlindMode LayoutBuilder disina cikarildi
- [x] AmbientDropletPainter cached in state, repaint: listenable, pre-allocated Paint
- [x] BurstPainter 6 Paint pre-allocated, Offset allocation eliminated
- [x] shape_preview.dart collection-for
- [x] island_screen.dart collection-for
- [x] season_pass_screen.dart tiers → file-level constant
- [x] CADisableMinimumFrameDurationOnPhone → false

### Tur 3 Tamamlanan (5/5)

- [x] P.1 — **[MEDIUM] Future.delayed → Timer: WaveRipple** — `_delayTimer` + dispose iptal
- [x] P.2 — **[MEDIUM] Future.delayed → Timer: ShopScreen toast** — `_toastTimer` + dispose iptal
- [x] P.3 — **[MEDIUM] Future.delayed → Timer: _recentlyPlacedCells** — `_waveClearTimer` + dispose iptal
- [x] P.4 — **[MEDIUM] GelShape.at()/rotated() collection-for** — `.map().toList()` → `[for ...]`, kSmall/Medium/LargeShapes da duzeltildi
- [x] P.5 — **[MEDIUM] findRecipes() static cache** — `_recipeCache.putIfAbsent()` ile tek seferlik hesaplama

### Tur 4 Tamamlanan (2/2)

- [x] 2.3 — **[LOW] OGG → M4A ikili format** — 32 .ogg dosya .m4a'ya donusturuldu, `_sfxExt` getter aktif (iOS → .m4a, diger → .ogg)
- [x] 3.7 — **[LOW] split-per-abi** — AAB zaten otomatik hallediyor, ek islem gerekmiyor

---

## 2. iOS App Store Hazirligi

> Gerekli: Apple Developer Account + Xcode

- [ ] 2.1 — Apple Developer Account'ta App ID kaydet
- [ ] 2.2 — Signing & Capabilities ayarla (Xcode)
- [ ] 2.3 — In-App Purchase capability ekle
- [ ] 2.4 — App Store Connect'te 7 IAP urunu tanimla
- [ ] 2.5 — StoreKit Sandbox test *(fiziksel cihaz)*
- [ ] 2.6 — Ekran goruntuleri (6.7", 6.1", 5.5" — 12 dil)
- [ ] 2.7 — App Store onizleme videosu
- [ ] 2.8 — TestFlight dahili + harici test
- [ ] 2.9 — Submit for Review

---

## 3. Android Play Store Hazirligi

> Gerekli: Google Play Console + Java

- [ ] 3.1 — `flutter build appbundle --release` basarili build
- [ ] 3.2 — Google Play Console'da uygulama olustur
- [ ] 3.3 — Store listesi: baslik, aciklama, ekran goruntuleri (12 dil)
- [ ] 3.4 — Icerik derecelendirme anketi
- [ ] 3.5 — IAP urunlerini Play Console'da tanimla
- [ ] 3.6 — Dahili test → Kapali test → Acik test → Uretim
- [ ] 3.7 — AdMob gercek App ID + ad unit ID'leri

---

## 4. Diger Kalan Isler

- [x] 4.1 — iOS `.m4a` ikili format uret — 32 dosya FFmpeg ile donusturuldu
- [ ] 4.2 — Viral pipeline end-to-end cihaz testi
- [ ] 4.3 — TikTok/Instagram direct share
- [ ] 4.4 — Uygulama ikonu tasarla
- [ ] 4.5 — Splash screen / logo animasyonu
- [ ] 4.6 — Gorsel asset'ler: `assets/images/ui/` + `assets/images/gel_textures/`
- [ ] 4.7 — Flutter DevTools ile performans profili — 60fps hedefi *(cihaz testi)*
- [ ] 4.8 — Fastlane veya Shorebird entegrasyonu *(opsiyonel)*

---

## Tamamlanan Fazlar (Referans)

| Faz | Aciklama |
|-----|----------|
| A | 723 birim test (37 dosya, 0 hata) |
| B | Supabase entegrasyon (6 tablo + 15 RLS + indeksler) |
| C | PvP Realtime (Presence + Broadcast + bot fallback + ELO) |
| D | Meta-game backend (meta_states + cross-device sync) |
| E | Firebase Analytics + Crashlytics (gloo-f7905) |
| F | 36 ses dosyasi (32 SFX .ogg + 4 muzik .mp3) |
| G | Viral pipeline (screen_recorder + FFmpeg + share) |
| J | CI/CD (3 GitHub Actions workflow) |
| K | Kod kalitesi (refactoring, rename, README, GDD) |
| L | Bundle ID, GDPR/ATT, memory leak fix, dosya refactoring |
| M | Performans optimizasyonu: 33/33 tamamlandi (4 CRITICAL + 8 HIGH + 15 MEDIUM + 4 LOW + 2 LOW opsiyonel) |
