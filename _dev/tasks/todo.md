# Gloo v1.0 — Yol Haritasi

> Son guncelleme: 2026-03-21
> **Durum:** 129/133 gorev tamamlandi | 7 Expert Audit + 1 UI/UX Audit yapildi
> flutter analyze: 0 error | flutter test: 2086 (golden haric)
> **Proje skoru:** 98 / 100 (expert audit sonrasi)

---

## Tamamlanan Manuel Aksiyonlar

- [x] **M.1 — Firebase App Check enforce:** Play Integrity (Android) + App Attest (iOS) kayitli
- [x] **M.2 — GitHub Secrets ekle:** 6 secret eklendi
- [x] **M.3 — Firebase API key rotation:** iOS + Android key'ler rotate edildi
- [x] **M.4 — git rm --cached:** google-services.json + GoogleService-Info.plist tracking'den cikarildi
- [x] **M.5 — updateElo Supabase RPC:** `update-elo` Edge Function deploy edildi
- [x] **M.6 — Privacy policy + store metadata:** GitHub Pages'te yayinda

---

## Tamamlanan Kod Gorevleri (33/33 + CI fix)

| Sprint | Tamamlanan | Gorevler |
|--------|:----------:|----------|
| Sprint 1 | 13/13 | B.1, D.1, D.2, D.3, E.1, F.1, F.2, F.4, F.7, C.2, B.3, F.3, A.2 |
| Sprint 2 | 10/10 | B.2, B.4, C.4, D.4, D.5, E.2, E.3, E.4, E.5, F.5 |
| Sprint 3 | 10/10 | A.1, A.3, A.4, B.5, C.1, C.3, D.6, D.7, E.6, F.6 |
| Post | +1 | TestFlight version bump race condition duzeltildi |

---

## Expert Audit Bulgulari (2026-03-21)

### KRITIK (Bu Hafta)

- [x] **S.1 — Android IAP dogrulama:** Google Play Developer API v3 entegrasyonu ✅
- [x] **S.2 — key.properties:** Zaten gitignore'd, tracked degil. key.properties.example eklendi ✅
- [x] **S.3 — iOS certificate pinning:** ATS explicit HTTPS + CertificatePinningPlugin.swift zaten mevcut ✅

### YUKSEK ONCELIK (Bu Sprint)

- [x] **P.1 — Cell widget rebuild izolasyonu:** `CellStateProvider(row, col)` ile izole rebuild (performans +15-25%) ✅
- [x] **P.2 — Synthesis detection cache:** Modified-zone taramasi ile O(n²) → O(k) ✅
- [x] **P.3 — AnimationController konsolidasyonu:** 200+ controller → tek global effect manager ✅
- [x] **P.4 — PvP stream controller leak:** Closed controller'lari listeden cikart ✅
- [x] **T.1 — game_interactions_test.dart:** 16 test ✅
- [x] **T.2 — game_callbacks_test.dart:** 18 test ✅
- [x] **T.3 — game_grid_builder_test.dart:** 16 test ✅
- [x] **T.4 — game_duel_controller_test.dart:** 18 test ✅
- [x] **S.4 — verify-purchase atomic RPC:** `append_purchased_product` RPC + migration ✅
- [x] **S.5 — Subscription expiry validation:** 35 gun + grace period kontrolu ✅

### ORTA ONCELIK (Bu Ay)

- [x] **U.1 — Light tema renk sabitleri:** 30+ renk eklendi ✅
- [x] **U.2 — Semantics label audit:** 11 interaktif elemente Semantics eklendi ✅
- [x] **U.3 — Text overflow korumasi:** 18 widget'ta maxLines + ellipsis ✅
- [x] **D.1 — Test paralelizasyonu:** `--concurrency 8` eklendi ✅
- [x] **D.2 — Coverage threshold:** %60 → %70 ✅
- [x] **D.3 — Edge Function input validation:** length + format kontrolu eklendi ✅
- [x] **P.5 — Cascade early exit:** Grid hash check eklendi ✅
- [x] **B.1 — Backoff jitter:** Random jitter eklendi ✅

### DUSUK ONCELIK (Gelecek Sprint)

- [x] **D.4 — Leaderboard rank RPC:** Iki sorgu yerine tek server-side transaction ✅
- [x] **T.5 — Shop logic mixin testi:** 12 test ✅
- [x] **T.6 — Matchmaking ELO edge case testleri:** 23 test ✅
- [x] **U.4 — Animation duration sabitleri:** `AnimationDurations` class'i `ui_constants.dart`'a ✅
- [x] **D.5 — Web deployment:** GitHub Pages deploy job eklendi ✅
- [x] **D.6 — SBOM uretimi:** Syft ile SPDX + CycloneDX raporu ✅

### ONCEKI BEKLEYEN ISLER

- [ ] Play Console service account + PLAY_SERVICE_ACCOUNT_JSON
- [ ] Play Store metadata tamamla (screenshots, feature graphic)
- [ ] Entegrasyon testleri (cihaz/emulator gerekli)
- [ ] Terms of Service sayfasi (docs/)

---

## UI/UX Audit Bulgulari (2026-03-21)

> Kapsamli UI/UX degerlendirmesi sonucu tespit edilen ve uygulanan iyilestirmeler.

### TAMAMLANAN (5/5)

- [x] **UX.1 — Renk koru modu metin kontrasti:** `shortLabel` ve `_ColorBlindPatternPainter` desenleri luminance-tabanli renk secimi yaparak koyu hucreler uzerinde okunabilirlik sagliyor ✅
- [x] **UX.2 — Level complete yildiz sistemi:** 1-3 yildiz (score/targetScore orani: 1x=1★, 1.5x=2★, 2x=3★), staggered easeOutBack animasyon, gold/muted gorsel hiyerarsisi ✅
- [x] **UX.3 — Bottom bar basma geri bildirimi:** AnimatedScale (0.92x) + ikon/metin parlaklik artisi ile press state ✅
- [x] **UX.4 — Tutorial skip butonu (tum adimlar):** Adim 0-1'de "Skip" butonu, IgnorePointer disinda interaktif, Semantics erisilebilir ✅
- [x] **UX.5 — Zen modu kilit etiketi l10n:** Hardcoded `'GLOO+'` → `l.glooPlusTitle` ile lokalize ✅

### ORTA ONCELIK — Gelecek Sprint

- [x] **UX.6 — Typography sistemi merkezi:** `AppTextStyles` abstract class: displayLarge (32), heading (18), subheading (16), body (14), bodySecondary (13), label (11), caption (10), micro (9) ✅
- [x] **UX.7 — Dikey bosluk standardizasyonu:** `Spacing` abstract class: xxs (2), xs (4), sm (8), md (12), lg (16), xl (20), xxl (24), xxxl (32) ✅
- [x] **UX.8 — Home screen bilgi yogunlugu:** Level + Duel modlari yatay cift (Row + Expanded) olarak gruplanip gorsel hiyerarsi iyilestirildi ✅
- [x] **UX.9 — Ilk acilis dialog yigilmasi:** Onboarding'e 4. sayfa (Tercihler) eklendi — analytics consent + renk koru modu toggle'lari; dialog yigilmasi ortadan kaldirildi ✅
- [x] **UX.10 — ModeCard badge non-featured:** `isFeatured &&` kosulu kaldirildi — `badgeLabel != null` kontrolu yeterli. Levels ve Duel "NEW" badge artik gosteriliyor ✅

### DUSUK ONCELIK — Nice-to-Have

- [x] **UX.11 — Desktop/tablet hover/focus gorseli:** BottomItem ve ModeCard'a MouseRegion ile hover state eklendi — arka plan vurgusu, border parlaklik artisi, click cursor ✅
- [x] **UX.12 — Bottom bar ikon farklilastirmasi:** Collection ikonu `collections_bookmark_rounded` → `auto_awesome_mosaic_rounded` ile degistirildi ✅
- [x] **UX.13 — Season pass claim gostergesi:** TierCard'da claimed free/premium odullerde check_circle overlay + icon soluklasmasi eklendi ✅
- [x] **UX.14 — Onboarding marka adi sabiti:** Hardcoded `'GLOO'` → `kAppName` sabiti (`app_constants.dart`) ile degistirildi ✅

---

## Ozet Tablo

| Kategori | Tamamlanan | Toplam |
|----------|:----------:|:------:|
| Onceki gorevler (P0-P3 + Growth + 100-Plan + Manuel) | 88/88 | 88 |
| Kritik (Bu Hafta) | 3/3 | 3 |
| Yuksek Oncelik (Bu Sprint) | 10/10 | 10 |
| Orta Oncelik (Bu Ay) | 8/8 | 8 |
| Dusuk Oncelik | 6/6 | 6 |
| UI/UX Audit — Tamamlanan | 5/5 | 5 |
| UI/UX Audit — Orta Oncelik | 5/5 | 5 |
| UI/UX Audit — Dusuk Oncelik | 4/4 | 4 |
| Onceki Bekleyen | 0/4 | 4 |
| **Toplam** | **129/133** | **133** |

**129/133 gorev tamamlandi (%97). Kalan 4 gorev: manuel/harici isler (Play Console, screenshots, entegrasyon testleri, ToS).**
**Test sayisi: 2086 (2057 → +29 yeni/guncellenen test)**

---

## Game Designer Analizi: Core Loop ve Oyuncu Deneyimi (2026-03-22)

> Dunya standartlarinda oyun tasarimcisi perspektifinden derinlemesine analiz.

### Guclu Yanlar

- Pipeline mimarisi (placePiece → _evaluateBoard) temiz ve genisletilebilir
- Merhamet RNG (3 kayip → zorluk dusme, 5 hamle temizleyemezse kurtarici el) tur standartlarinin uzerinde
- Renk sentezi sistemi gercekten ayirt edici (4 birincil → 8 sentez, cifte odul)
- Near-Miss dedektoru Shannon entropy tabanli — turde nadir sofistikasyon
- 7 mod ayni core loop uzerinde anlamli fark yaratiyor

### Tespit Edilen Sorunlar

| # | Sorun | Risk | Aciklama |
|---|-------|------|----------|
| GD.1 | Sentez otomatik, oyuncu kasitli planlayamiyor | Orta-Yuksek | "Kazandim ama nasil?" → Flow state engeli |
| GD.2 | Seviye tasariminda scaffolding zayif | Yuksek | Sadece 2/50 seviyede aciklama var |
| GD.3 | Kombo penceresi (1500ms) zaman bazli ama oyun turn-based | Orta | Stratejik dusunmeyi cezalandiriyor |
| GD.4 | Ekonomi enflasyonu salt ceza gibi hissedilebilir | Orta | Maliyet artiyor, kazanim artmiyor |
| GD.5 | Cascade geri bildirimi yetersiz | Orta | En tatmin edici anlar cok hizli geciyor |
| GD.6 | Talent sistemi core loop'a entegre degil | Orta | Meta-game bos vaat riski |

### Oneriler (Oncelik Sirasina Gore)

- [ ] **GD.O1 — Sentez ipucu overlay:** Secili seklin rengiyle sentez potansiyeli olan bitisik bos hucrelere hafif glow (Orta efor)
- [x] **GD.O2 — Cascade pacing:** `onCascadeStep` callback + 250ms delayed SFX (Dusuk efor) ✅ (T21)
- [x] **GD.O3 — Komboyu hamle bazli yap:** 1500ms pencere → ardisik temizleme = combo (Dusuk efor) ✅
- [ ] **GD.O4 — Seviye 1-10 mikro gorevler:** Her seviyeye 1 ogretim gorevi ekle (Orta efor)
- [x] **GD.O5 — Siradaki 1 sekil silueti her zaman gorunsun:** nextShapeSilhouette + muted 36x36 preview, Peek aktifken gizli (Dusuk efor) ✅ (T31)
- [x] **GD.O6 — Talent → Core Loop baglantisi:** betterHand → ShapeGenerator, colorMaster → ScoreSystem (Dusuk efor) ✅

---

## Game Designer Analizi: Monetizasyon ve Ekonomi Dengesi (2026-03-22)

> Ekonomi dongusu, IAP yapisi, reklam dengesi ve meta-game entegrasyonu analizi.

### Guclu Yanlar

- Anti-frustration reklam sistemi 3 katmanli koruma (yeni oyuncu, kayip serisi, gunluk cap)
- Starter Pack degeri net (%50 indirim algilama, 4 urun tek pakette)
- Ikili para birimi (Jel Ozu / Jel Enerjisi) net ayrilmis
- Power-up maliyet/cooldown dengesi makul (oyun basi hafif pozitif birikim)
- Sunucu tarafli receipt dogrulama + graceful degradation
- GDPR/UMP consent akisi kuralcil

### Tespit Edilen Sorunlar

| # | Sorun | Risk | Aciklama |
|---|-------|------|----------|
| GD.M1 | `applyGlooPlusBonus()` hicbir yerde cagrilmiyor — BUG | KRITIK | Gloo+ aboneleri %50 Jel Ozu bonusunu almiyor |
| GD.M2 | `inflatedCost()` tanimli ama hicbir yerde kullanilmiyor | Yuksek | Enflasyon sistemi ya calismali ya kaldirilmali |
| GD.M3 | Gloo+ deger teklifi zayif — Starter Pack ile kanibalizasyon | Orta | Aylik $1.99 icin sadece Zen modu + "early access" |
| GD.M4 | Meta-game sistemleri (ada, karakter, gorev, season pass) UI'a bagli degil | Orta | Hayalet sistemler — retention'a katki yapmiyor |
| GD.M5 | Jel Ozu harcama ciklileri kisitli — currency bloat riski | Dusuk-Orta | 200+ birikim sonrasi kaynak anlamsizlasiyor |
| GD.M6 | Level tamamlama odulleri tanimlanmamis | Orta | Level modunun retention motoru olmasi engelleniyor |
| GD.M7 | Consumable IAP yok | Dusuk-Orta | Para harcamak isteyip abonelik istemeyenler icin duvar |
| GD.M8 | Rewarded reklam → power-up UI baglantisi eksik | Dusuk | `grantFreePowerUp` var ama tetikleyen UI yok |

### Oneriler (Oncelik Sirasina Gore)

- [x] **GD.MO1 — [BUG] `applyGlooPlusBonus` cagrisini ekle:** `_clearAndScore()` veya game-end callback'inde (Dusuk efor, HEMEN) ✅
- [x] **GD.MO2 — Rewarded reklam → power-up UI bagla:** Game Over'da "reklam izle = ucretsiz Bomb" butonu (Dusuk efor)
- [x] **GD.MO3 — Level tamamlama odulleri:** `levelId * 2` Jel Ozu, Gloo+ bonus otomatik (Dusuk efor) ✅ (T32)
- [ ] **GD.MO4 — Gorev sistemini UI'a bagla:** `kDailyQuestPool`'dan gunluk 3 gorev, HomeScreen'e kart (Orta efor)
- [ ] **GD.MO5 — Jel Ozu consumable IAP ekle:** 100 = $0.99, 500 = $3.99 (Dusuk efor)
- [ ] **GD.MO6 — Gloo+ deger teklifini guclendir:** %50 bonus aktif et, 2x gorev odulu, ozel gorevler (Dusuk-Orta efor)
- [x] **GD.MO7 — Enflasyon sistemini netlistir:** `inflatedCost` power-up'lara baglandi + formul 1000/2x'e yumusatildi (Dusuk efor) ✅ (T23)
- [ ] **GD.MO8 — Starter Pack / Gloo+ kanibalizasyonunu coz:** Reklamsizi Starter'dan cikar VEYA Gloo+'a exclusive ekle (Dusuk efor)

---

## Game Designer Analizi: Seviye Tasarimi ve Zorluk Egrisi (2026-03-22)

> Tester geri bildirimi: "Puan kazanimi zor." Kok neden analizi ve puanlama dekonstruksiyonu.

### Puanlama Sistemi Dekonstruksiyonu

| Puan Kaynagi | Formul | Sorun |
|---|---|---|
| Tekli satir temizleme | 100 puan | En sik eylem, en dusuk odul |
| Coklu satir (N>=2) | 300*(N-1) | 3 satir = 600, yetersiz odullendirme |
| Kombo carpani | x1.2 → x3.0 (1500ms pencere) | Zamana dayali — turn-based oyunda pratikte tetiklenemez |
| Sentez bonusu | 50 puan (sabit) | Stratejik bir eylem icin cok dusuk |
| Yerlestirme puani | YOK | Her hamle sessiz — geri bildirim dongusu bos |

**Tipik oyun basi beklenen puan: 300-700.** Cok iyi oynayan: 900-1200.

### Zorluk Duvari Analizi

| Seviye | Hedef | Hamle | Puan/Hamle | Durum |
|---|---|---|---|---|
| 1-10 | 200-600 | sinirsiz | - | Makul |
| 15 | 850 | sinirsiz | - | Siki |
| 25 | 1000 | sinirsiz | - | Cok zor |
| 41 | 1300 | 40 | 32.5 | Sinir noktasi |
| 45 | 1500 | 34 | 44.1 | DUVAR |
| 49 | 1700 | 28 | 60.7 | Matematiksel olarak imkansiza yakin |

### "Puan Kazanimi Zor" — 7 Kok Neden

1. **Tekli temizleme puani (100) cok dusuk** — en sik eylem en az puan
2. **Kombo sistemi (1500ms) pratikte calismaz** — turn-based oyunda zamana dayali carpan anlamsiz
3. **Sentez bonusu (50) cok dusuk** — stratejik eylemin odulu yetersiz
4. **Hamle sinirlari (41+) cok dar** — 28 hamlede 1700 puan matematiksel olarak saglanamaz
5. **Tek puan yolu** — sadece satir temizleme puan verir, yerlestirme puani yok
6. **Buyuk sekil biasi** — yuksek skorda buyuk sekiller artarak temizleme firsatlarini azaltir
7. **Merhamet mekanizmasi gec devreye giriyor** — 3 kayip cok gec, oyuncu cogu zaman 2. kayipta birakiryor

### Tespit Edilen Sorunlar

| # | Sorun | Risk | Aciklama |
|---|-------|------|----------|
| GD.L1 | Tekli satir temizleme puani 100 — cok dusuk | KRITIK | Tester sikayet kok nedeni |
| GD.L2 | Kombo 1500ms zamana dayali — turn-based'de calismaz | YUKSEK | x3.0 carpan pratikte kullanilmaz |
| GD.L3 | Sentez bonusu 50 — stratejik degeri yok | YUKSEK | Sentez yerine satir temizlemek her zaman karli |
| GD.L4 | Seviye 41-50 hedef/hamle orani imkansiz | YUKSEK | Seviye 49: 60.7 puan/hamle gerekli |
| GD.L5 | Yerlestirme puani yok — geri bildirim boslugu | ORTA | 5 hamle boyunca 0 puan = "ilerleme yok" hissi |
| GD.L6 | Prosedural seviyelerde monotonluk | ORTA | Seviye 101+ benzer desenler |
| GD.L7 | Merhamet esigi 3 kayip — cok gec | ORTA | Cogu oyuncu 2. kayipta birakiyor |

### Oneriler (Oncelik Sirasina Gore)

- [x] **GD.LO1 — Tekli satir puanini 100 → 150 yap:** Tum seviyelerde ~%50 puan artisi (Cok dusuk efor, HEMEN) ✅
- [x] **GD.LO2 — Sentez bonusunu 50 → 150 yap:** Sentez stratejik anlam kazanir (Cok dusuk efor, HEMEN) ✅ (GD notu: playtestte 100'e dusurme degerlendirilmeli)
- [x] **GD.LO3 — Seviye 41-50 hedef skorlarini %25-30 dusur:** Duvari yumustir (Cok dusuk efor) ✅ (GD notu: yeni puanlamaya gore hedefler cok dusuk olabilir — playtestte izle)
- [x] **GD.LO4 — Seviye 41-50 hamle sinirlarini genilet:** 28→40 hamle gibi (Cok dusuk efor) ✅
- [x] **GD.LO5 — Komboyu hamle bazliya cevir:** 1500ms → ardisik N hamlede temizleme (Orta efor, en yuksek yapisal etki) ✅ (GD notu: chain+=linesCleared epic'e hızlı ulaştırıyor — chain++ olmalı mı? + 1 hamle toleransı değerlendirilmeli)
- [x] **GD.LO6 — Yerlestirme basina puan ekle:** hucre basina 10 puan — geri bildirim dongusu (Dusuk efor) ✅
- [x] **GD.LO7 — Coklu satir temizlemeyi ustel odul yap:** 2→400, 3→1000, 4→2000 (Dusuk efor) ✅
- [x] **GD.LO8 — Merhamet esigini 3→2 kayba dusur:** Daha erken mudahale (Cok dusuk efor) ✅
- [ ] **GD.LO9 — Prosedural seviyelere temali kisitlamalar ekle:** Her 5 seviyede farkli kural (Orta efor)
- [x] **GD.LO10 — "Neredeyse dolu satir" gorsel geri bildirimi:** `isNearlyFullRow` + amber highlight (Dusuk efor) ✅ (T20)

---

## Game Designer Analizi: PvP/Duel Sistemi (2026-03-22)

> Matchmaking, engel sistemi, ELO, realtime altyapisi ve asimetrik frustration analizi.

### Guclu Yanlar

- Duplicate match onlemi (leksikografik ID) zarif ve etkili
- Reconnection stratejisi production-ready (exponential backoff, 5 deneme)
- Bot fallback 30sn sonra garanti eslesme — kucuk oyuncu tabaninda kritik
- Idempotent submit (duplicate skor korunmasi)
- Server-side ELO hesaplama (Edge Function)

### Tespit Edilen Sorunlar

| # | Sorun | Risk | Aciklama |
|---|-------|------|----------|
| GD.P1 | Kombo sistemi duel'de islevsiz — 1500ms turn-based'de calismaz | KRITIK | Medium+ kombo engelleri hic gonderilmiyor |
| GD.P2 | Engel gelis animasyonu/SFX yok — sessiz yerlesim | CIDDI | Oyuncu "ne oldu?" hissiyle kaliyor |
| GD.P3 | Tas engeli kalici ve temizlenemez — geri donulemez alan kaybi | CIDDI | Asimetrik frustration'in ana kaynagi |
| GD.P4 | Bot engel simulasyonu yok — bot maci PvP ogretmiyor | YUKSEK | Ilk gercek macta oyuncu surpriz yasiyor |
| GD.P5 | Skor broadcast 5sn aralikla — canli yarisma hissi zayif | ORTA | Catch-up gerilimi yok |
| GD.P6 | PvP ELO leaderboard yok | ORTA | Rekabet motivasyonunun gorsel katmani eksik |
| GD.P7 | Hardcoded Turkce stringler (lobby + sonuc overlay) | YUKSEK | 12 dil destegini kirar |
| GD.P8 | Bot ELO manipulasyonu — sinir yok | ORTA | Surekli bot macla ELO sisirebilir |
| GD.P9 | Epic kombo engeli cok guclu — 9 buz tek seferde | ORTA | Kombo duzeltilince asimetri patlar |
| GD.P10 | Rematch secenegi yok — ayni rakiple tekrar oynayamaz | DUSUK | Rekabet hissini kirar |

### Oneriler (Oncelik Sirasina Gore)

- [x] **GD.PO1 — Hardcoded Turkce stringleri l10n'e tasi:** `pvp_lobby_matchmaking.dart` + `duel_result_overlay.dart` (Dusuk efor, HEMEN) ✅
- [ ] **GD.PO2 — Engel gelis animasyonu + SFX ekle:** 0.8sn golge → yerlesim, `SoundBank.onObstacleReceived()` (Dusuk-Orta efor)
- [x] **GD.PO3 — Tas engelini temizlenebilir yap:** Komsu satir/sutun temizlenince stone kiriliyor + onStoneBroken callback (Dusuk efor) ✅ (T34)
- [x] **GD.PO4 — Bot'a engel simulasyonu ekle:** 17sn aralikla 1-2 buz engeli (Dusuk efor) ✅ (T35)
- [x] **GD.PO5 — Skor broadcast'ini event-driven yap:** 5sn periodic → 500ms polling + score-change check (Dusuk efor) ✅ (T36)
- [x] **GD.PO6 — PvP ELO Leaderboard ekle:** LeaderboardScreen'e 3. tab (Dusuk efor)
- [x] **GD.PO7 — Epic kombo engelini 9→4-5 buza dusur:** Kombo duzeltmesiyle birlikte (Dusuk efor) ✅
- [x] **GD.PO8 — Bot ELO kazanimini sinirla:** Bot win ELO %50 azaltma, kayip tam (Dusuk efor) ✅ (T22)
- [x] **GD.PO9 — K-Factor'u ELO segmentine gore dinamik yap:** <800:K=40, 800-1199:K=32, 1200-1599:K=28, 1600+:K=24 + Edge Function sync (Dusuk efor) ✅ (T30)
- [ ] **GD.PO10 — Rematch secenegi ekle:** Ayni rakiple tekrar oynama (Orta efor)

---

## Game Designer Analizi: Onboarding ve Retention (2026-03-22)

> Ilk 5 dakika deneyimi, tutorial etkinligi, retention hook'lari ve churn noktalari analizi.

### Ilk 5 Dakika Kritik Bulgulari

- Onboarding 4 sayfa tamamen metin bazli — gorsel/animasyon/interaktif eleman yok
- Tutorial sadece 3 adim: sec-onizle-yerlestir. Sentez, kombo, power-up, skor sistemi ogretilmiyor
- Onboarding skip edilince 3 ardisik dialog (Consent → ATT → Colorblind) — dialog fatigue
- 7 mod birden gorunuyor — paradox of choice
- MetaGameBar hayalet sistemlere yonlendiriyor — "oyun bitmemis" hissi
- Ilk oyunda "aha!" ani belirsiz — sentez tesadufe bagli, kombo pratikte imkansiz

### Churn Noktalari

| Nokta | Zaman | Risk | Neden |
|---|---|---|---|
| Dialog zinciri | D0, dk 0-1 | Yuksek | 3 ardisik popup, oyun hala oynanmamis |
| "Ne yapacagimi bilmiyorum" | D0, dk 2-4 | Yuksek | Tutorial yetersiz, bos grid korkutucu |
| Ilk kayip | D0, dk 4-6 | Cok yuksek | Referans yok, "neden kaybettim" yok, merhamet yok |
| 2-3. oyun arasi | D0-D1 | Orta-yuksek | "Wow" ani yoksa D1'e donmuyor |
| D1 donus | D1 | Yuksek | Push notification yok, streak hatirlatmasi yok |
| D3-D7 mod kesfi | D3+ | Orta | 7 mod yonlendirilmeden sunuluyor |

### Retention Hook'lari Durumu

| Hook | Durum |
|---|---|
| Streak sistemi | Var ama hatirlatma yok (push notification yok) |
| Gunluk bulmaca | Var, DailyBanner gorunuyor |
| Push notification | YOK — hicbir altyapi yok |
| Gunluk gorevler | HAYALET — repository'de var, UI'da yok |
| Season Pass / Ada / Karakter | HAYALET — butonlar var, icerik yok |
| Streak Freeze | YOK |

### Tespit Edilen Sorunlar

| # | Sorun | Risk | Aciklama |
|---|-------|------|----------|
| GD.R1 | Onboarding pasif ve metin bazli | YUKSEK | Oyuncular okumuyor, show don't tell gerekli |
| GD.R2 | Tutorial sentez/kombo/power-up ogretmiyor | KRITIK | Oyunun en ayirt edici mekanigi tutorial disinda |
| GD.R3 | Skip sonrasi 3 ardisik dialog | YUKSEK | Dialog fatigue, D0 churn |
| GD.R4 | 7 mod birden gorunuyor | ORTA | Paradox of choice |
| GD.R5 | MetaGameBar hayalet sistemlere yonlendiriyor | YUKSEK | Guven kirici |
| GD.R6 | Push notification altyapisi yok | KRITIK | D1 retention'in en onemli araci eksik |
| GD.R7 | Ilk oyunda referans noktasi yok | ORTA | "150 puan iyi mi?" sorusu cevapsiz |
| GD.R8 | Game Over'da "neden kaybettin" ozeti yok | ORTA | Ogretme firsati kaciriliyor |
| GD.R9 | Gunluk gorev sistemi UI'da yok | YUKSEK | D1-D7 retention hook eksik |
| GD.R10 | Ilk 5 oyunda zorluk ayari yok | ORTA | Kucuk sekil agirligi ile erken basari hissi saglanmali |

### Oneriler (Oncelik Sirasina Gore)

**P0 — Hemen:**
- [ ] **GD.RO1 — Onboarding'i interaktif yap:** Her sayfaya animasyonlu mini-demo ekle (Orta efor)
- [ ] **GD.RO2 — "Guided First Game" tasarla:** Ilk oyunda kasitli renkler + sentez toast'i (Buyuk efor)
- [x] **GD.RO3 — Dialog zincirini birlestir:** 3 popup → 1 combined dialog (Kucuk efor) ✅
- [x] **GD.RO4 — MetaGameBar'i gizle veya "Coming Soon" yap:** Hayalet sistemleri sakla (Kucuk efor) ✅
- [x] **GD.RO5 — Ilk 5 oyunda zorluk dusur:** `gamesPlayed < 5` → %80 kucuk sekil (Kucuk efor) ✅

**P1 — Bu Sprint:**
- [ ] **GD.RO6 — Push notification altyapisi kur:** firebase_messaging + D1/D2/D3 senaryolari (Orta efor)
- [x] **GD.RO7 — Progressive mod acilimi:** Classic → 3 oyun sonra Color Chef → 5 sonra Time Trial (Orta efor)
- [x] **GD.RO8 — Game Over'da ozet ekle:** "4 satir, 1 sentez, %87 dolu" + ipucu (Kucuk efor) ✅
- [ ] **GD.RO9 — Gunluk gorev sistemini UI'a bagla:** HomeScreen'de mini progress (Orta efor)
- [x] **GD.RO10 — "Beat your score" karti Home'a ekle:** "Son skor: 450 | Rekor: 1200" (Kucuk efor) ✅

**P2 — Gelecek Sprint:**
- [x] **GD.RO11 — Streak Freeze mekanigi:** 100 Jel Ozu ile satin alinabilir (Orta efor)
- [x] **GD.RO12 — Ilk oyunlarda share prompt'u ayarla:** Epic combo yerine ilk high score'da kucuk paylas butonu (Kucuk efor)

---

## Game Designer Analizi: Meta-Game ve Uzun Vadeli Ilerleme (2026-03-22)

> Ada, karakter, talent, season pass, gorev ve koleksiyon sistemlerinin durum analizi.

### Meta-Game Sistem Durumu

| Sistem | Veri Modeli | UI | Core Loop Baglantisi | Durum |
|---|---|---|---|---|
| Ada (5 bina) | Hazir | Var | YOK — binalar gameplay'i degistirmiyor | HAYALET |
| Karakter + Talent (4 tip) | Hazir | Var | YOK — bonus metodlari hic cagrilmiyor | KRITIK KOPUKLUK |
| Season Pass (50 tier) | Hazir | Var | YOK — XP kazanim kaynagi sifir | TAMAMEN INERT |
| Gorev (6 gunluk, 5 haftalik) | Hazir | YOK | YOK — tracking yok | EN HAZIR AMA EN KISIR |
| Koleksiyon (8 renk) | Hazir | Calisiyor | Kismi | SIGI — 8 item, odul yok |
| Level Progression | Hazir | Calisiyor | Calisiyor | EN SAGLIKLI ama odul yok |
| Ekonomi: Jel Ozu | Hazir | Calisiyor | Calisiyor | Fonksiyonel, sink yetersiz |
| Ekonomi: Jel Enerjisi | Hazir | Kazanim calisiyor | Harcama efektsiz | Para kazaniliyor, karsiligi yok |

### Tespit Edilen Sorunlar

| # | Sorun | Risk | Aciklama |
|---|-------|------|----------|
| ~~GD.MG1~~ | ~~Talent bonuslari GlooGame'e baglanmamis~~ | ~~KRITIK~~ | ✅ 4 bonus entegre edildi (T9) |
| GD.MG2 | Season Pass XP kaynagi sifir — oyuncu Tier 0'da donuk | KRITIK | addXp() hicbir yerden cagrilmiyor |
| GD.MG3 | Ada binalari sadece kosmetik — gameplay etkisi yok | YUKSEK | gelFactory pasif uretim yok, arena PvP gating yok |
| GD.MG4 | applyGlooPlusBonus cagrilmiyor — ticari vaat kirik | KRITIK | App Store/Play policy ihlali riski |
| GD.MG5 | Gorev sistemi UI'da yok | YUKSEK | En yuksek ROI ozellik entegre edilmemis |
| GD.MG6 | inflatedCost kullanilmiyor | ORTA | Enflasyon olume terk edilmis kod |
| GD.MG7 | Koleksiyon sigi ve odulsuz | ORTA | 8 item, tamamlama motivasyonu yok |
| GD.MG8 | Level tamamlama odulleri yok | ORTA | Neden 200. seviyeyi oynayasim? |
| GD.MG9 | D30+ endgame bos — sadece Duel ELO ve leaderboard kalmis | YUKSEK | Tum meta-game efektsiz → veteran churn |
| GD.MG10 | Kostum sistemi tamamen bos — CostumePiece var, kostum tanimli degil | ORTA | Season Pass odulleri anlamsiz |

### Oneriler (Oncelik Sirasina Gore)

**Ayni Gun Ship Edilebilir (XS-S):**
- [x] **GD.MGO1 — [BUG] applyGlooPlusBonus fix:** game_callbacks.dart'ta oyun sonu callback'inde cagir (XS efor) ✅
- [x] **GD.MGO2 — Talent → GlooGame entegrasyonu:** 4 bonus noktasini bagla (S efor, 1-2 gun) ✅
- [x] **GD.MGO3 — MetaGameBar'i kosullu goster:** Calismayan sistemleri gizle veya "Coming Soon" (XS efor) ✅

**Bu Sprint (S-M):**
- [ ] **GD.MGO4 — Gorev sistemi entegrasyonu:** GlooGame callback + HomeScreen widget + odul dagitim (M efor)
- [x] **GD.MGO5 — Season Pass XP kaynagi:** Game Over'da score/100 XP (S efor) ✅ (T33)
- [x] **GD.MGO6 — Level tamamlama odulleri:** levelId * 2 Jel Ozu (S efor) ✅ (T32)

**Sonraki Sprint (M-L):**
- [ ] **GD.MGO7 — Ada binalarini gating mekanigi yap:** arena→PvP, harbor→SeasonPass, factory→pasif uretim (M efor)
- [ ] **GD.MGO8 — Koleksiyonu genislet:** 8→16+ renk, tamamlama odulleri (S efor)
- [x] **GD.MGO9 — inflatedCost entegrasyonu:** T23 ile tamamlandi (power-up maliyetlerine baglandi) ✅
- [ ] **GD.MGO10 — Ascension/Prestige sistemi:** Level 50 sonrasi zorluk katmanlari (L efor)

---

## Game Designer Review Backlog (2026-03-22)

> Sprint 3 task'larinin game-designer review'indan cikan ek oneriler.

### T11 — Dialog Zinciri

- [x] **GD.BL1 — Ilk oyun sonrasi colorblind inline prompt:** Game Over overlay'de inline prompt + "Enable Color Assist" butonu (Kucuk efor) ✅ (T25)

### T12 — Yeni Oyuncu Zorlugu

- [x] **GD.BL2 — Level modunu yeni oyuncu korumasindan muaf tut:** Level 1 zaten 6x6 grid ile kendi egrisine sahip (XS efor) ✅ (T18)
- [x] **GD.BL3 — ColorChef'e ayri agirlik tablosu:** %35 kucuk / %50 orta / %15 buyuk, zorluktan bagimsiz (S efor) ✅ (T26)
- [x] **GD.BL4 — Zorluk gecisini kademeli yap:** Oyun 3: %70/%20/%10, Oyun 4: %55/%30/%15, Oyun 5+: normal — keskin gecis yerine ramp (S efor) ✅ (T19)

### T13 — Game Over Ozeti

- [x] **GD.BL5 — Ipucu gosterim sayisini persist et:** _selectTipKey() ile akilli rotasyon, max 2 gosterim/tip (S efor) ✅ (T27)
- [x] **GD.BL6 — Grid doluluk metrigini gozden gecir:** Ham yuzde yerine baglamli yorum — 4 kademe (Clean Board / Well Managed / Getting Crowded / Very Full) ✅ (T24)
- [x] **GD.BL7 — Kisisel rekor karsilastirmasi:** Stat rekor persistence + "New Record!" / "Record: X" gösterimi (S efor) ✅ (T28)

### T14 — Beat Your Score Karti

- [x] **GD.BL8 — "So close" vurgu state:** lastScore >= highScore * 0.8 ise amber renk + "Beat it?" etiketi (S efor) ✅ (T29)
- [x] **GD.BL9 — Per-mode progress metadata chip:** Level (ilerleme), Duel (ELO delta) icin ayri bilgi kartlari (M efor)

---

## Game Designer Review Backlog — Sprint 4 (2026-03-22)

> Sprint 4 task'larinin game-designer review'indan cikan ek oneriler.

### T18+T19 — Yeni Oyuncu Korumasi

- [x] **GD.BL10 — Daily ve Duel modlarini yeni oyuncu korumasindan muaf tut:** Seeded modlarda koruma seed'i bozabilir. Kara liste yerine beyaz liste kullan (sadece classic, colorChef, timeTrial, zen'de aktif) (XS efor)

### T20 — Neredeyse Dolu Satir

- [x] **GD.BL11 — Nearly-full esigini mutlak sayiya cevir:** %75 yerine "playable - filled <= 2" — farkli grid boyutlarinda tutarli (XS efor)

### T21 — Cascade Pacing

- [x] **GD.BL12 — Cascade SFX icin artan pitch ekle:** `playSfx`'e opsiyonel `speed` parametresi, step basina +0.08 pitch (1.0 → max 1.3) (S efor)
- [x] **GD.BL13 — Cascade delay'i 250ms → 180ms'ye dusur:** Bulmaca oyunu ritmine daha uygun (XS efor)
- [x] **GD.BL14 — Reduce Motion acikken cascade delay'i 0'a dusur:** `shouldReduceMotion` guard ekle (XS efor)

### T22 — Bot ELO

- [x] **GD.BL15 — Bot mac sikligi analytics event'i ekle:** `daily_bot_matches_count` metrigi. 4 hafta veri sonrasi diminishing returns karari (Dusuk efor)

### T23 — Enflasyon

- [x] **GD.BL16 — inflatedCost formulunu yumusat:** 500/3x → 1000/2x. Rainbow max 20 (30 yerine) ✅ (hemen uygulandı)
- [x] **GD.BL17 — Power-up toolbar'da enflasyon gorsel ipucu:** Ustu cizgili baz maliyet veya ilk enflasyonda tek seferlik tooltip (Orta efor)
- [x] **GD.BL18 — Gloo+ icin enflasyon cap'ini 1.5x'e sinirla:** Premium deger hissi, tam muafiyet degil (Dusuk efor)

### T24 — Grid Doluluk Metrigi

- [x] **GD.BL19 — "Clean Board" → "Room to Grow" etiket degisikligi:** Dusuk doluluk + dusuk skor kombinasyonunda negatif algi riski (XS efor)
- [x] **GD.BL20 — Alt esigi %30 → %20'ye cek:** Gercek "temiz" oyunu dogru yakalamak icin (XS efor)

---

## Game Designer Review Backlog — Sprint 5 (2026-03-22)

> Sprint 5 task'larinin game-designer review'indan cikan ek oneriler.

### T25 — Colorblind Prompt

- [x] **GD.BL21 — Colorblind prompt'u ilk oyun yerine 2-5. oyun arasina ertele:** Ilk Game Over'da cognitif yuk cok yuksek (Dusuk efor)
- [x] **GD.BL22 — Colorblind prompt TextButton tap target 44dp dogrulamasi:** a11y test'e dahil et (XS efor)

### T26 — ColorChef Agirliklari

- [x] **GD.BL23 — gamesPlayed mod-bazli mi global mi dogrula:** Mod-bazli ise ColorChef'te koruma esigini 5→2'ye dusur (XS efor)

### T27 — Tip Rotasyonu

- [x] **GD.BL24 — Tip rotasyon bloguna toplam gosterim tavani ekle:** synthCount + comboCount >= 6 ise null don ✅ (T37)

### T28 — Rekor Karsilastirmasi

- [x] **GD.BL25 — "This time: X — Record: Y" subtitle'ini kaldir:** Sadece "New Record!" goster, gorsel karisikligi azalt (Orta efor)

### T29 — "So close" State

- [x] **GD.BL26 — Game Over'da rekor kirildiginda HomeScreen'de "New personal best!" goster:** Pozitif durum kutlamasi (Dusuk efor)

### T30 — Dinamik K-Factor

- [x] **GD.BL27 — Bot maclarinda K-Factor azaltmasi:** Bot farming onlemi — T22 ile birlikte degerlendir (Orta efor)
- [x] **GD.BL28 — K-Factor tier sync yorumu:** matchmaking.dart ve calculate-elo/index.ts basina sync uyarisi ekle (XS efor)

### T31 — Siluet Preview

- [x] **GD.BL29 — Silueti gamesPlayed < 5 ise gizle:** Yeni oyuncu icin bilissel yuk azaltma (XS efor)
- [ ] **GD.BL30 — Preview-time line completion hint:** Sekil preview'i satiri tamamlayacaksa "temizlenecek" sinyali goster (M efor)

---

## Game Designer Review Backlog — Sprint 6 (2026-03-22)

> Sprint 6 task'larinin game-designer review'indan cikan ek oneriler.

### T32 — Level Odulleri

- [x] **GD.BL31 — Level odul tavani (cap: 30) + ayri earnFromLevelComplete:** Lineer formul Level 50'de 100 Jel Ozu — ekonomi kirilma noktasi. `min(levelId * 2, 30)` veya tiered yaklasim (Yuksek efor)

### T33 — Season Pass XP

- [x] **GD.BL32 — Season Pass XP minimum floor (10) + Level modu bonus XP:** `max(10, score ~/ 100)` formulu — dusuk skorlu modlarda XP ihmal edilebilir durumda (Yuksek efor)

### T35 — Bot Engelleri

- [x] **GD.BL33 — Bot engel agresifligini difficulty parametresine bagla:** Dusuk ELO bot: 20sn/1 buz, Yuksek ELO bot: 12sn/3-4 buz (Orta efor)

### T36 — Skor Broadcast

- [x] **GD.BL34 — Score broadcast event-driven refactor:** 500ms polling yerine onScoreGained + 300ms debounce (Dusuk efor, teknik borc)
