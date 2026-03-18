# Gloo: ASMR Jel Puzzle
**Durum:** Beta / Uretime Hazirlik (%97)
**Platform:** Android + iOS + Web (Flutter 3.41.2)

---

## Belgeler

| Belge | Aciklama |
|---|---|
| [GDD.md](./_dev/docs/GDD.md) | Oyun Tasarim Belgesi — tum mekanikler, ASO stratejisi, monetizasyon |
| [TECHNICAL_ARCHITECTURE.md](./_dev/docs/TECHNICAL_ARCHITECTURE.md) | Teknik mimari, kod yapisi, kritik algoritma ornekleri |
| [CLAUDE.md](./CLAUDE.md) | Gelistirme rehberi — build komutlari, mimari, API notlari |

---

## Ozet

Block Blast izgara mekanigini ASMR tabanli jel fizigi ve renk sentezi ile harmanlayan casual puzzle oyunu.

**Diferansiyatorler:**
- Statik bloklar yerine spring-physics tabanli jel kapsuller (6 katman CustomPainter)
- Renk karistirma mekanigi — 4 birincil renkten 8 sentez renk uretimi
- 7 oyun modu: Classic, Color Chef, Time Trial, Zen, Daily Puzzle, Level, PvP Duel
- Otomatik near-miss tespiti (Shannon entropy) ve loss aversion mekaniklari
- 7 VFX protokolu: breathing gel, squash & stretch, cascade burst, chain lightning, danger pulse, color bloom, ambient atmosphere
- 12 dil destegi (TR, EN, DE, ZH, JA, KO, RU, ES, AR, FR, HI, PT)

---

## Ozellikler

### Oyun Mekanikleri
- 8x10 izgara (Level modunda dinamik: 6x6 → 10x12)
- 19+ sekil, Smart RNG ile agirlikli dagitim
- 12 renk sistemi (4 birincil + 8 sentez)
- 6 ozel hucre tipi: normal, ice (1-2 katman), locked, stone, gravity, rainbow
- 6 power-up: rotate, bomb, peek, undo, rainbow, freeze
- Jel Ozu soft currency ekonomisi
- Merhamet mekanizmasi (3 ardisik kayip → zorluk azaltma)

### Seviye Sistemi
- 50 onceden tanimli seviye + 51+ prosedurel uretim
- 5 harita formu: rectangle, diamond, cross, L-shape, corridor
- Color Chef: 50 hedef renk sentezi seviyesi

### Meta-Game
- Ada yonetimi (5 bina, yukseltme sistemi)
- Karakter/kostum sistemi (yetenek agaci)
- Sezon pasi (8 hafta, 50 tier)
- Gunluk + haftalik gorev sistemi
- PvP lobby (ELO bazli eslestirme, 5 lig)

### VFX
- GelCellPainter: 6 katmanli jel render (glow, gradient, specular, shadow, breathing)
- Squash & Stretch: 4 fazli yerlestirme animasyonu (380ms)
- Wave Ripple: Manhattan distance bazli dalga yayilimi
- CellBurstEffect: 16 parcacik, Bezier trajectory
- ColorSynthesisBloomEffect: Flas + 2 halka + parcaciklar
- AmbientGelDroplets: 10 yuzucu damlacik, mod bazli renk
- NearMiss vignette: Radyal gradient tehlike overlay'i

### Monetizasyon
- AdMob: Interstitial, rewarded (ikinci sans), banner (test ID'leri aktif)
- IAP: 7 urun tanimli (kRemoveAds, kSoundCrystal, kSoundForest, kTexturePack, kStarterPack, kGlooPlusMonthly, kGlooPlusYearly)
- Gloo+ abonelik: Zen modu kilidi, +%50 Jel Ozu bonus
- Redeem code sistemi (Supabase dogrulama + lokal onbellek)

---

## Tech Stack

| Katman | Teknoloji |
|---|---|
| Framework | Flutter 3.19+ (Puro ile yonetilir) |
| State Management | Riverpod 2.5 (sadece UI) |
| Navigasyon | GoRouter 13 |
| Animasyon | flutter_animate 4.5 + CustomPainter |
| Ses | just_audio 0.9 (8 kanal SFX havuzu, pitch varyasyonu) |
| Yerel Depolama | SharedPreferences |
| Backend | Supabase (8 tablo, 22 RLS, 3 RPC, 3 Edge Function, Realtime PvP) |
| Monetizasyon | google_mobile_ads + in_app_purchase |
| Oyun Motoru | Saf Dart (GlooGame orkestrator — Flame KULLANILMIYOR) |

---

## Proje Istatistikleri

- ~90+ Dart dosyasi
- ~22,000+ satir kod
- 1204 birim test, 60+ test dosyasi, 0 hata
- 14 feature dizini (game_screen, home_screen, onboarding, daily_puzzle, settings, leaderboard, shop, collection, level_select, pvp, island, character, season_pass, quests)

---

## Faz Durumu

| Faz | Durum |
|---|---|
| Faz 1 — MVP | Tamamlandi (izgara, 7 mod, renk sentezi, skor, kombo, power-up, l10n) |
| Faz 2 — Viral | Tamamlandi (near-miss, ClipRecorder + FFmpeg video pipeline, ShareManager) |
| Faz 3 — Monetizasyon | Tamamlandi (AdMob test, IAP tanimli, Gloo+ enum) |
| Faz 4 — Hybrid-Casual | Tamamlandi (14 ekran + 7 VFX + Supabase backend + PvP Realtime + CI/CD) |
| Sprint 1-3 | Tamamlandi (guvenlik hardening, backend kalite, gorsel branding) |
| Sprint 6-7 | Tamamlandi (home refactor, GameScreen refactor, provider migration, 290 test) |
| Sprint 8-10 | Tamamlandi (guvenlik fix, mimari polish, test genisletme — toplam 1204 test) |

---

## Test

```bash
flutter test    # 1204 test, 0 hata
flutter analyze # 0 issue
```

---

## Build

Detayli build talimatlari icin [CLAUDE.md](./CLAUDE.md)'ye bakiniz.

```bash
flutter build apk --debug
flutter build web --release
```

**Not:** Proje yolunda non-ASCII karakter varsa `impellerc` hatasi alinir — ASCII-safe bir yola kopyalayarak build edin (detay: CLAUDE.md).
