# CD.18 + CD.19 — Ses Paketi SFX Briefi + Muzik Parcalari Briefi

**Versiyon:** 0.1 | **Tarih:** 2026-03-23 | **Yazar:** Sound Design Agent

---

## Bolum A: Genel Notlar

### Teknik Kisitlamalar

| Parametre | Deger |
|---|---|
| Platform | Mobil (iOS + Android) + Web |
| Formatlar | Her SFX icin `.ogg` (Android/Web-Chrome) + `.m4a` (iOS/Safari) ikili dosya |
| Muzik formati | `.mp3` (tum platformlar) |
| SFX normalize | -6 dBFS peak, mono, 48 kHz |
| Muzik normalize | -14 LUFS integrated, stereo, 44.1 kHz |
| SFX suresi | 50ms — 2500ms arasi (dosyaya gore) |
| Muzik loop | Seamless loop, click/pop olmadan |
| Bellek | Mobil — SFX toplam paket < 8 MB, muzik streaming |
| Eszamanli kanal | Max 8 SFX round-robin havuzu |
| Pitch varyasyon | 0.92x — 1.08x speed (AudioManager tarafindan otomatik) |

### Dosya Klasor Yapisi

```
assets/audio/sfx/
  gel_place.ogg / .m4a          ← standard (mevcut)
  crystalAsmr/
    gel_place.ogg / .m4a        ← Crystal ASMR paketi
  deepForest/
    gel_place.ogg / .m4a        ← Deep Forest paketi
assets/audio/music/
  menu_lofi.mp3                 ← mevcut
  ...
  colorchef_groove.mp3          ← yeni
```

AudioManager `_resolvePackagePath()` base name'i alip aktif paketin alt klasorune yonlendiriyor. Dosya yoksa standard'a fallback yapiyor. Yani her paket icin ayni 32 dosya adini kullanmak zorunlu.

---

## Bolum B: Mevcut 32 SFX Dosyasi — Referans Listesi

Asagidaki tablo mevcut standard paketin tum SFX'lerini, tetiklenme baglamlarini ve duygusal islevlerini ozetler. Her iki yeni paket bu 32 dosyanin bire-bir alternatifini icermeli.

| # | Dosya Adi | SoundBank Metodu | Duygusal Islev | Sure (hedef) |
|---|---|---|---|---|
| 1 | `gel_place` | `onGelPlaced()` | Tatmin, kesinlik — "yerlesti" | 80-150ms |
| 2 | `gel_place_soft` | `onGelPlaced(soft:true)` | Hafif dokunma, preview | 50-100ms |
| 3 | `gel_merge_small` | `onGelMerge(<=2)` | Kucuk birlesme, yumusak geri bildirim | 100-200ms |
| 4 | `gel_merge_medium` | `onGelMerge(3)` | Orta birlesme, buyuyen tatmin | 150-300ms |
| 5 | `gel_merge_large` | `onGelMerge(>=4)` | Buyuk birlesme, doruk tatmin | 200-400ms |
| 6 | `line_clear` | `onLineClear(1)` | Temizleme rahatligi, basari | 300-500ms |
| 7 | `line_clear_crystal` | `onLineClear(>=2)` | Coklu temizleme costusu, parlak odul | 400-600ms |
| 8 | `combo_small` | `onCombo(small)` | Hafif zincir, tesvik | 100-200ms |
| 9 | `combo_medium` | `onCombo(medium)` | Buyuyen momentum | 200-350ms |
| 10 | `combo_large` | `onCombo(large)` | Guclu zincir, heyecan | 300-500ms |
| 11 | `combo_epic` | `onCombo(epic)` | Doruk anlik, zafer | 500-800ms |
| 12 | `color_synthesis` | `onSynthesis()` | Kesfetme, simya, surpriz | 300-500ms |
| 13 | `button_tap` | `onButtonTap()` | UI geri bildirim, notr | 30-80ms |
| 14 | `game_over` | `onGameOver()` | Kaybetme, dusus, bitme | 800-1500ms |
| 15 | `level_complete` | `onLevelComplete()` | Basari, kutlama | 800-1200ms |
| 16 | `level_complete_new` | (router SFX) | Yeni rekor/seviye, ekstra parlak | 800-1500ms |
| 17 | `near_miss_tension` | `onNearMiss(false)` | Gerilim, tehlike yaklasiyor | 200-400ms |
| 18 | `near_miss_relief` | `onNearMiss(true)` | Rahatlama, kurtuldun | 200-400ms |
| 19 | `ice_break` | `onIceBreak()` | Buz kirma tatmini | 150-300ms |
| 20 | `ice_crack` | (ek katman) | Buz catlagi, ince | 100-200ms |
| 21 | `powerup_activate` | `onPowerUpActivate()` | Guc kazanma, hazirlik | 200-400ms |
| 22 | `bomb_explosion` | `onBombExplosion()` + `onStoneBroken()` | Patlama etkisi, guc | 300-600ms |
| 23 | `rotate_click` | `onRotate()` | Mekanik donme, hassas | 80-150ms |
| 24 | `undo_whoosh` | `onUndo()` | Geri sarma, zaman geri | 150-300ms |
| 25 | `freeze_chime` | `onFreeze()` | Dondurma, soguk esinti | 200-400ms |
| 26 | `gravity_drop` | `onGravityDrop()` | Dusus, agirlik | 150-300ms |
| 27 | `gel_ozu_earn` | `onGelOzuEarn()` | Para/odul kazanma, kling | 200-400ms |
| 28 | `pvp_victory` | `onPvpVictory()` | Zafer, ustalik | 800-1500ms |
| 29 | `pvp_defeat` | `onPvpDefeat()` | Maglup, yeniden deneme | 600-1000ms |
| 30 | `pvp_obstacle_sent` | `onPvpObstacleSent()` | Saldiri, gonderme | 200-400ms |
| 31 | `pvp_obstacle_received` | `onPvpObstacleReceived()` | Darbe yeme, uyari | 200-400ms |
| 32 | `color_synth` | (legacy alias) | `color_synthesis` ile ayni | 300-500ms |

> **Not:** `color_synth` legacy bir alias. Iki pakette de olusturulmali ama `color_synthesis` ile ayni dosya olabilir.

---

## Bolum C: CD.18 — Crystal ASMR Ses Paketi

### Sonic Identity

**Duygusal Cekirdek:** Tatmin verici dokunsal hassasiyet — ASMR'in "tingle" hissi. Oyuncunun kulaklarinda fiziksel bir karsilik bulacak, neredeyse dokunulan cam/kristal hissi.

**Ses Karakteri:** Sentetik-organik hibrit. Gercek cam/kristal kaynaklari (field recording) + sentez ile zenginlestirilmis parlak harmonikler.

**Frekans Paleti:** Agirlik 2kHz-8kHz bolgede. Alt katman olarak 200-600Hz cam govde resonansi. Sub-bass yok veya minimal — bu paketin ruhu yukarda.

**Referans Koordinatlar:**
- Estetik: Monument Valley serisi ses tasarimi — temiz, minimalist, kristal
- Teknik: Tetris Effect (Enhance Games) — her dokunusta tinglesel geri bildirim
- Negatif: Keskin, agresif cam kirma sesleri (Crash Bandicoot tarzi) — kacinilacak. Ses tatmin etmeli, tedirgn etmemeli.

**Sessizlik Stratejisi:** Crystal ASMR'in gucu sessizlikteki kontrasttir. Sesler arasinda bosluk birakilmali — reverb tail'ler uzun tutulabilir ama overlap olmamali.

---

### Her SFX Icin Detayli Brief

#### 1. `gel_place` — Kristal Yerlestirme
**Duygusal Islev:** Hassas bir kristali yuzeyine oturtmanin tatmini. "Tik" degil, "tiinnk".
**Katman Yapisi:**
- Temel (Foundation): Cam goblet'e hafif parmak vurusu — 300-500Hz govde resonansi, 60ms attack
- Govde (Body): Kristal harmonik — 1.2kHz-2kHz, kisa sustain (80ms)
- Varlik (Presence): Ince "ting" shimmer — 4kHz-6kHz, hizli decay (40ms)
**Varyasyon:** Pitch varyasyonu AudioManager tarafindan otomatik (0.92-1.08x). Ek olarak 2 temel varyant icsel layering ile saglanabilir.
**Uzamsal:** Mono. Kuru (dry) mix, minimal reverb (100ms plate).

#### 2. `gel_place_soft` — Kristal Hafif Dokunma
**Duygusal Islev:** Neredeyse duyulmayan ince cam dokunusu. Preview/ghost hissesi.
**Katman Yapisi:**
- Temel: `gel_place` ile ayni kaynak, -12dB, sadece 4kHz+ HPF ile filtrelenmis
- Govde: Yok — sadece presence katmani
- Varlik: Cok ince cam fisiltisi, 3kHz-5kHz, 40ms
**Uzamsal:** Mono. Tamamen kuru.

#### 3. `gel_merge_small` — Kucuk Kristal Birlesmesi
**Duygusal Islev:** Iki kucuk kristal parcasinin yanyana gelmesinin tatliligi.
**Katman Yapisi:**
- Temel: Iki cam bilye carpismasi — 400Hz, kisa (50ms)
- Govde: Cam harmonik ring — 1.5kHz, 100ms sustain
- Varlik: Ince chime — 3kHz, hizli decay
**Sure:** 100-150ms toplam. Sik tetiklenecek, kisa olmali.

#### 4. `gel_merge_medium` — Orta Kristal Birlesmesi
**Duygusal Islev:** Buyuyen bir koleksiyona ekleme tatmini.
**Katman Yapisi:**
- Temel: Cam harmonik bowl vurusu — 300Hz govde, 100ms
- Govde: Kristal singing bowl resonansi — 1.2kHz-1.8kHz, 200ms sustain
- Varlik: Cift nota shimmer (E5+G5) — 2.6kHz+3.1kHz, 150ms
**Sure:** 200-250ms.

#### 5. `gel_merge_large` — Buyuk Kristal Birlesmesi
**Duygusal Islev:** Buyuk bir kristal yapisinin tamamlanma anindaki tatmin dorugu.
**Katman Yapisi:**
- Temel: Kristal vazo resonansi — 250Hz derin govde, 150ms
- Govde: Uc notali kristal arpeggio (C5-E5-G5) yukari — 2kHz-3kHz, her nota 60ms stagger
- Varlik: Shimmer swell + sparkle — 5kHz-8kHz, granular texture, 200ms tail
**Sure:** 300-400ms. Parlak ve genis hissettirmeli.

#### 6. `line_clear` — Kristal Satir Temizleme
**Duygusal Islev:** Bir satir kristal parcaciga donusup dagilmasinin rahatligi.
**Katman Yapisi:**
- Temel: Cam kirinti cascade — alcak geciren filtrelenmis (200-400Hz), 200ms
- Govde: Ascending kristal arpeggio C4-E4-G4 — her nota 35ms stagger (burst animasyonuyla senkron), 1kHz-2kHz
- Varlik: Yuksek frekans sparkle trail — 4kHz-8kHz granular, 300ms tail
**Onemli:** Cascade pacing'te `pitch` parametresi ile artan pitch (1.0 + step*0.08, cap 1.3x) uygulanacak. Ses buna uygun olmali — yukari transpose edildiginde dogal kalmali.
**Sure:** 400-500ms.

#### 7. `line_clear_crystal` — Coklu Kristal Temizleme
**Duygusal Islev:** Birden fazla satirin kristal kaskatina donusmesinin costusu.
**Katman Yapisi:**
- Temel: `line_clear` temeli + ek sub-layer cam darbe (200Hz pulse)
- Govde: Genisletilmis arpeggio C4-E4-G4-C5 — 4 nota, zengin harmonikler
- Varlik: Daha uzun sparkle + reversed kristal swell (150ms) oncesinde
**Sure:** 500-600ms.

#### 8. `combo_small` — Kucuk Kristal Kombo
**Duygusal Islev:** "Devam et" tesvik eden ince ping.
**Katman Yapisi:**
- Temel: Yok
- Govde: Tek nota kristal ping — E5 (2.6kHz), kisa attack, 80ms decay
- Varlik: Hafif shimmer tail — 5kHz, 50ms
**Volume:** SoundBank'ta 0.5 volume ile calinir. Buna gore normalize edilmeli (daha sicak).
**Sure:** 100-150ms.

#### 9. `combo_medium` — Orta Kristal Kombo
**Duygusal Islev:** Momentum hissi, zincir buyuyor.
**Katman Yapisi:**
- Temel: Hafif cam govde — 400Hz, 60ms
- Govde: Iki nota kristal (E5-G5) — 100ms aralik, 1.5kHz-3kHz
- Varlik: Reverb artisi — plate reverb tail 200ms, 4kHz+
**Sure:** 200-300ms.

#### 10. `combo_large` — Buyuk Kristal Kombo
**Duygusal Islev:** Guclu zincir, heyecan dorugu yaklasirken.
**Katman Yapisi:**
- Temel: Cam resonans hit — 250Hz, 80ms + sub-bass sine pulse 60-80Hz, 100ms
- Govde: 3 nota kristal arpeggio yukari (C5-E5-G5) — 60ms stagger
- Varlik: Sparkle swell — 5kHz-10kHz, granular, 300ms
**Sure:** 350-500ms. Ducking tetikler (SoundBank).

#### 11. `combo_epic` — Epik Kristal Kombo
**Duygusal Islev:** Doruk an. Kristal sarayin canlanisinm sesi.
**Katman Yapisi:**
- Temel: Derin cam resonans — 200Hz govde + sub-bass swell 50-80Hz, 200ms
- Govde: Tam kristal akor (C-E-G-C) — zengin harmonikler, 300ms sustain, 2kHz-4kHz
- Varlik: Reversed cymbal → kristal shimmer swell — 6kHz-12kHz, 400ms build + 200ms tail
**Ozel:** Muzik ducking tetiklenir. Ses buna gore yeterince etkileyici olmali.
**Sure:** 600-800ms.

#### 12. `color_synthesis` — Kristal Renk Sentezi
**Duygusal Islev:** Iki rengin birlesmesinin simyasal kesfetme ani. "Vay, bu oldu!"
**Katman Yapisi:**
- Temel: Cam baloncuk merge — 200-400Hz, pitch slide yukari, 150ms
- Govde: Kristal singing bowl harmonik — 800Hz baslayip 1.5kHz'e glide, 200ms
- Varlik: Prizma efekti — stereo-hisli (mono icinde pan modulation) shimmer 3kHz-6kHz, 150ms
**Sure:** 350-500ms.

#### 13. `button_tap` — Kristal UI Dokunma
**Duygusal Islev:** Temiz, hassas UI geri bildirim. Cam bir butona basmak.
**Katman Yapisi:**
- Temel: Yok
- Govde: Tek kristal tick — 2kHz, 20ms attack, 20ms decay
- Varlik: Mikro shimmer — 5kHz, 10ms
**Onemli:** Cok sik tetiklenir. Yorgunluk yaratmamali, asiri parlak olmamali.
**Sure:** 30-60ms.

#### 14. `game_over` — Kristal Dagilma
**Duygusal Islev:** Kristal yapinin parcalanmasi — huzunlu ama guzel.
**Katman Yapisi:**
- Temel: Derin cam kirima — 150-300Hz, 300ms, descending
- Govde: Descending kristal arpeggio (G4-E4-C4-A3) — melankolik, 600ms
- Varlik: Cam parcaciklarin yere dusme granular layer — 2kHz-6kHz, 800ms seyrek tail
**Ton:** Minorde, ama agresif degil. Usulca dagilma, vahsi kirma degil.
**Sure:** 1000-1500ms.

#### 15. `level_complete` — Kristal Zafer Fanfari
**Duygusal Islev:** Tamamlama gururu. Kristal tacinm parlamasi.
**Katman Yapisi:**
- Temel: Cam goblet tam resonans — 300Hz, 200ms sustain
- Govde: Ascending major arpeggio (C4-E4-G4-C5) kristal bells ile — 600ms
- Varlik: Shimmer swell + sparkle burst — 5kHz-10kHz, 400ms
**Sure:** 800-1200ms.

#### 16. `level_complete_new` — Kristal Yeni Rekor
**Duygusal Islev:** `level_complete` + ekstra parlaklk. "Bu ozel!"
**Katman Yapisi:**
- `level_complete` katmanlari + ek:
- Varlik+: Kristal chime cascade — 6kHz-12kHz, 3 nota yukaridan asagi, 500ms ek tail
- Govde+: Majestik akor pad — 1kHz-2kHz, 400ms sustain
**Sure:** 1000-1500ms.

#### 17. `near_miss_tension` — Kristal Gerilim
**Duygusal Islev:** "Tehlike yakin!" — kristal catlama sesi, stres.
**Katman Yapisi:**
- Temel: Dusuk cam vibrasyon — 150Hz, titresim hissi, 100ms
- Govde: Dissonant kristal — minor 2nd interval (E4+F4), 100ms
- Varlik: Ince cam catlak — 3kHz-5kHz, keskin transient
**Sure:** 200-350ms.

#### 18. `near_miss_relief` — Kristal Rahatlama
**Duygusal Islev:** "Kurtuldun!" — kristal berrakliga donusu.
**Katman Yapisi:**
- Temel: Hafif cam govde — 300Hz, 80ms
- Govde: Konsonant kristal resolve — major 3rd (C4-E4), 120ms
- Varlik: Yumusak chime — 4kHz, 100ms, sıcak
**Sure:** 200-350ms.

#### 19. `ice_break` — Kristal Buz Kirma
**Duygusal Islev:** Buz kirmanin tatmini — ama kristal dunyada buz = donmus kristal.
**Katman Yapisi:**
- Temel: Cam/buz kirinti darbe — 200-400Hz, keskin transient, 50ms
- Govde: Kristal parcalanma — 1kHz-2kHz, 100ms, birden fazla mikro-transient
- Varlik: Yuksek frekans buz catlak — 4kHz-8kHz, kisa, keskin
**Sure:** 150-250ms.

#### 20. `ice_crack` — Kristal Buz Catlagi
**Duygusal Islev:** Buz catlak uyarisi — daha ince, oncu ses.
**Katman Yapisi:**
- Temel: Yok
- Govde: Ince cam catlak — 1.5kHz, 40ms
- Varlik: Mikro crack — 5kHz-8kHz, 30ms
**Sure:** 80-150ms.

#### 21. `powerup_activate` — Kristal Guc Aktiflesme
**Duygusal Islev:** Kristal enerji akisi — guc kazanma heyecani.
**Katman Yapisi:**
- Temel: Cam resonans swell — 200Hz, crescendo 100ms
- Govde: Ascending kristal glissando — 800Hz-2kHz, 150ms
- Varlik: Sparkle burst — 5kHz-10kHz, 100ms, stereo-ish pan
**Sure:** 200-350ms.

#### 22. `bomb_explosion` — Kristal Patlama
**Duygusal Islev:** Kristal yapinin kontrolllu patlamasi — guclu ama zarif.
**Katman Yapisi:**
- Temel: Cam darbe + sub-bass thump — 60-150Hz, 100ms, keskin transient
- Govde: Cam kirinti burst — 500Hz-2kHz, granular parcacik, 200ms
- Varlik: Yuksek frekans cam parcacik savrulma — 4kHz-10kHz, 300ms decay
**Ozel:** Muzik ducking tetikler. Ses parcalanma hissi vermeli ama sert degil.
**Sure:** 350-600ms.

#### 23. `rotate_click` — Kristal Donme
**Duygusal Islev:** Hassas mekanizna donmesi — kristal disli.
**Katman Yapisi:**
- Temel: Yok
- Govde: Cam tick — 1.5kHz, kisa (30ms)
- Varlik: Mikro shimmer — 4kHz, 20ms
**Sure:** 60-120ms.

#### 24. `undo_whoosh` — Kristal Geri Sarma
**Duygusal Islev:** Zaman geri akisi — kristal parcacik hizi.
**Katman Yapisi:**
- Temel: Hafif hava hareketi — 200-400Hz filtered noise, 100ms
- Govde: Descending kristal glissando — 2kHz→800Hz, 150ms
- Varlik: Reversed shimmer — 5kHz-8kHz, 100ms onceden build
**Sure:** 150-250ms. Ekran gecislerinde %40 volume ile calinir.

#### 25. `freeze_chime` — Kristal Dondurma
**Duygusal Islev:** Soguk esinti, zaman durma — kristal donma.
**Katman Yapisi:**
- Temel: Derin cam resonans — 200Hz, soguk karakter, 100ms
- Govde: Kristal chime cluster (yuksek register) — 2kHz-3kHz, 150ms sustain
- Varlik: "Buz" shimmer — 6kHz-10kHz, granular, soguk tonalite, 200ms tail
**Sure:** 250-400ms.

#### 26. `gravity_drop` — Kristal Dusus
**Duygusal Islev:** Agirlik ve dusus — kristal parcalanin yere inmesi.
**Katman Yapisi:**
- Temel: Descending pitch cam govde — 400Hz→200Hz, 100ms glide
- Govde: Cam bilye yuzey darbesi — 800Hz, 60ms, bounce hissi
- Varlik: Ince tink — 3kHz, 30ms
**Debounce:** 50ms timestamp guard mevcut. Hizli art arda tetiklenebilir.
**Sure:** 150-250ms.

#### 27. `gel_ozu_earn` — Kristal Odul
**Duygusal Islev:** Para/odul toplama — kristal coin.
**Katman Yapisi:**
- Temel: Yok
- Govde: Kristal coin kling — 1.5kHz-2.5kHz, 2 nota (C5-E5), 100ms
- Varlik: Parlak shimmer tail — 5kHz, 150ms
**Debounce:** 300ms Timer guard. Kisa ve net olmali.
**Sure:** 200-350ms.

#### 28. `pvp_victory` — Kristal PvP Zafer
**Duygusal Islev:** Rakip uzerinde ustallik — kristal tahtiya oturma.
**Katman Yapisi:**
- Temel: Derin kristal resonans fanfare — 200Hz govde, 300ms
- Govde: Majestik ascending major arpeggio (C4-G4-C5-E5) — kristal bells, 600ms
- Varlik: Tam sparkle cascade + shimmer swell — 5kHz-12kHz, 600ms
**Sure:** 1000-1500ms.

#### 29. `pvp_defeat` — Kristal PvP Maglup
**Duygusal Islev:** Yenilgi kabulu — kristal solma.
**Katman Yapisi:**
- Temel: Cam govde descending — 300Hz→150Hz, 200ms
- Govde: Descending minor arpeggio (E4-C4-A3) — kristal, melankolik, 400ms
- Varlik: Seyrek parcacik tail — 3kHz-5kHz, solarak, 400ms
**Sure:** 700-1000ms.

#### 30. `pvp_obstacle_sent` — Kristal Saldiri Gonderme
**Duygusal Islev:** Rakibe engel firlama — kristal mermi.
**Katman Yapisi:**
- Temel: Cam darbe transient — 300Hz, 30ms
- Govde: Ascending kristal whoosh — 1kHz→3kHz, 120ms
- Varlik: Parlak trail — 5kHz-8kHz, 100ms
**Sure:** 200-350ms.

#### 31. `pvp_obstacle_received` — Kristal Darbe Alma
**Duygusal Islev:** Rakipten engel gelme — kristal catlak uyari.
**Katman Yapisi:**
- Temel: Dusuk darbe — 150Hz, 60ms
- Govde: Dissonant kristal hit — 1kHz-2kHz, minor 2nd, 100ms
- Varlik: Keskin cam catlak — 4kHz-6kHz, 50ms
**Sure:** 200-350ms.

#### 32. `color_synth` — (Legacy Alias)
`color_synthesis` ile ayni dosya. Paket icinde kopyasi olmali.

---

## Bolum D: CD.18 — Deep Forest Ses Paketi

### Sonic Identity

**Duygusal Cekirdek:** Dogayla ic ice olmanin huzuru ve toprakla bagli olmanin agir tatmini. Orman zeminine bass yaprak, dal kirilmasina yumusak odun, su damlasina berrak ritim.

**Ses Karakteri:** Tamamen organik. Field recording tabanli — gercek odun, yaprak, su, toprak, tas kaynaklari. Sentez minimalde: sadece reverb/EQ isleme.

**Frekans Paleti:** Agirlik 100Hz-1kHz bolgede (toprak, odun, govde). Ust harmonikler yaprak hisirtisi ve su damlasi ile 2kHz-6kHz. Sub-bass toprak/agac govdesi ile 40-100Hz. Sicak, karanlik tonalite — kristal paketin tam tersi.

**Referans Koordinatlar:**
- Estetik: Ori and the Blind Forest — orman sesleri, organik sicaklik
- Teknik: Rain World — prosedural dogal ses katmanlari
- Negatif: Karikatur hayvan sesleri, "orman temalı" muziksel efektler — kacinilacak. Sesler dogadan gelmeli ama asiri literal olmamali.

**Sessizlik Stratejisi:** Orman sessizligi = yaprak hisirtisinin kesilmesi. Onemli anlarda (combo_epic, level_complete) oncesinde dogal seslerin bir an durma hissi.

---

### Her SFX Icin Detayli Brief

#### 1. `gel_place` — Toprak Yerlestirme
**Duygusal Islev:** Islak toprak/kil uzerine bir sey oturtmanin tatmini. Saglamlik.
**Katman Yapisi:**
- Temel (Foundation): Islak toprak/kil impact — 150-300Hz, derin "thud", 80ms
- Govde (Body): Odun yuzey resonansi — 400-800Hz, kisa (60ms), sicak
- Varlik (Presence): Ince yaprak fisirtisi — 2kHz-4kHz, 30ms
**Sure:** 80-150ms.

#### 2. `gel_place_soft` — Yaprak Dokunma
**Duygusal Islev:** Kuru yapraga hafif dokunma. Neredeyse sessiz, dogal.
**Katman Yapisi:**
- Temel: Yok
- Govde: Hafif yaprak fisirtisi — 600Hz-1.2kHz, 40ms
- Varlik: Mikro hava hareketi — 2kHz-3kHz, 20ms
**Sure:** 50-80ms.

#### 3. `gel_merge_small` — Kucuk Dal Birlesmesi
**Duygusal Islev:** Iki kucuk dal parcasinin birlesme tikligi.
**Katman Yapisi:**
- Temel: Ince odun tick — 300-500Hz, 40ms
- Govde: Dal uzerine dal — 800Hz, kuru, 60ms
- Varlik: Yaprak suslemesi — 2kHz, 30ms
**Sure:** 80-130ms.

#### 4. `gel_merge_medium` — Orta Odun Birlesmesi
**Duygusal Islev:** Kucuk bir odun yapisi kurmanin ilerleyisi.
**Katman Yapisi:**
- Temel: Odun govde impact — 200-400Hz, 80ms, sicak resonans
- Govde: Iki dal carpismasi — 600-1kHz, 100ms
- Varlik: Yaprak fisirtisi swell — 2kHz-3kHz, 80ms
**Sure:** 150-250ms.

#### 5. `gel_merge_large` — Buyuk Agac Birlesmesi
**Duygusal Islev:** Buyuk bir agac dalinin yerine oturmasinin agir tatmini.
**Katman Yapisi:**
- Temel: Derin agac govde resonansi — 80-200Hz, 150ms, derin "thoom"
- Govde: Agac dalinin kirilma-otesin kilitlenmesi — 400-800Hz, odun carpma, 100ms
- Varlik: Yaprak savrulma + kus kanat cirpma antirisi — 2kHz-5kHz, 150ms
**Sure:** 250-400ms.

#### 6. `line_clear` — Yaprak Savrulma
**Duygusal Islev:** Bir satir yapragin ruzgarla savrulup temizlenmesinin rahatligi.
**Katman Yapisi:**
- Temel: Toprak rumble — 100-200Hz, 150ms, hafif
- Govde: Yaprak yigini savrulma — 400Hz-1.2kHz, hisirtili, 250ms, ascending
- Varlik: Ruzgar wishi — 2kHz-5kHz, filtered noise sweep, 300ms
**Cascade pitch uyumu:** Dogal pitch artisi ruzgarin sertlesmesi gibi hissetmeli.
**Sure:** 350-500ms.

#### 7. `line_clear_crystal` — Coklu Yaprak Firtinasi
**Duygusal Islev:** Birden fazla satir — mini orman firtinasi, guclu ruzgar.
**Katman Yapisi:**
- Temel: Derin toprak rumble — 60-150Hz, 200ms
- Govde: Yogun yaprak + ince dal kirilma cascade — 300Hz-1.5kHz, 300ms
- Varlik: Guclu ruzgar sweep + uzak kus ucusu — 2kHz-6kHz, 400ms
**Sure:** 450-600ms.

#### 8. `combo_small` — Kucuk Orman Kombo
**Duygusal Islev:** Ince dal tick — "devam et" sinyali.
**Katman Yapisi:**
- Temel: Yok
- Govde: Tek dal tick — 600-800Hz, kuru odun, 50ms
- Varlik: Yaprak suslemesi — 2kHz, 30ms
**Volume:** 0.5 ile calinir. Buna gore sicak normalize.
**Sure:** 80-130ms.

#### 9. `combo_medium` — Orta Orman Kombo
**Duygusal Islev:** Buyuyen momentum — dallar uzerinden atlayan sincap enerjisi.
**Katman Yapisi:**
- Temel: Odun govde tap — 300Hz, 50ms
- Govde: Iki dal tick yukari pitch — 600Hz→1kHz, 100ms
- Varlik: Yaprak hisirtisi artisi — 2kHz-3kHz, 100ms
**Sure:** 150-250ms.

#### 10. `combo_large` — Buyuk Orman Kombo
**Duygusal Islev:** Agac dalindan dala hizla ilerleyen enerji.
**Katman Yapisi:**
- Temel: Agac govde darbe — 100-200Hz, 80ms + toprak sub-thump 60Hz, 60ms
- Govde: Uc dal tiklamasinin ascending serisi — 500Hz-1.2kHz, 60ms stagger
- Varlik: Yaprak kaskat + uzak kus alarmi — 2kHz-5kHz, 250ms
**Sure:** 300-450ms.

#### 11. `combo_epic` — Epik Orman Kombo
**Duygusal Islev:** Ormanin uyandigi an. Agaclar titresiyor, yapraklar ufleniyor, toprak gurlyor.
**Katman Yapisi:**
- Temel: Derin agac kok resonansi — 40-100Hz, 200ms swell + toprak titresimi
- Govde: Buyuk dal kirilma + odun govde harmonik — 200Hz-1kHz, 300ms
- Varlik: Tam ruzgar swell + kus suru ucusu + yaprak firtinasi — 2kHz-8kHz, 400ms
**Ozel:** Muzik ducking. Ses ormanin "nefes almasi" gibi olmali.
**Sure:** 500-800ms.

#### 12. `color_synthesis` — Orman Simyasi
**Duygusal Islev:** Iki dogal elementin bulusup yeni bir sey yaratmasinin buyusu. Cicek acmasi.
**Katman Yapisi:**
- Temel: Islak toprak bubble — 150-300Hz, 100ms, organik
- Govde: Su damlasi + odun resonans harmonik — 600Hz→1.2kHz pitch glide, 200ms
- Varlik: Cicek acma efekti — yumusak yuksek frekans petal-like rustle 3kHz-5kHz, 150ms
**Sure:** 300-500ms.

#### 13. `button_tap` — Odun Tiklamasi
**Duygusal Islev:** Kucuk bir odun parcasina tik. Dogal UI geri bildirim.
**Katman Yapisi:**
- Temel: Yok
- Govde: Kuru odun tick — 500-800Hz, 20ms
- Varlik: Mikro yaprak — 2kHz, 10ms
**Sure:** 30-60ms.

#### 14. `game_over` — Agac Devrilmesi
**Duygusal Islev:** Buyuk bir agacin yavas devrilmesinin melankolisi.
**Katman Yapisi:**
- Temel: Derin agac govde creak descending — 60-200Hz, 400ms, yavas
- Govde: Dallar kirilan ses cascade — 300-800Hz, 600ms, azalan yogunluk
- Varlik: Son yaprak dusme sesleri — 1.5kHz-3kHz, seyrek, 500ms tail
**Ton:** Huzunlu ama dogal. Sert cokme degil, agir, yumusak dusme.
**Sure:** 1000-1500ms.

#### 15. `level_complete` — Orman Kutlamasi
**Duygusal Islev:** Ormanin kutlama ritmi — kuslar, yaprak dans, odun perkaston.
**Katman Yapisi:**
- Temel: Toprak thump ritmi — 100-200Hz, 3 vurusu ascending, 400ms
- Govde: Odun xylophone ascending majr — 400Hz-1.2kHz, 4 nota, 500ms
- Varlik: Kus song snippeti (2-3 nota) + yaprak swell — 2kHz-6kHz, 400ms
**Sure:** 800-1200ms.

#### 16. `level_complete_new` — Orman Yeni Rekor
**Duygusal Islev:** `level_complete` + ekstra — kuslarin tam korosu.
**Katman Yapisi:**
- `level_complete` katmanlari + ek:
- Govde+: Odun marimba ek arpeggio — 800Hz-1.5kHz, 400ms
- Varlik+: Kus korosu snippet + ruzgar swell — 3kHz-8kHz, 500ms
**Sure:** 1000-1500ms.

#### 17. `near_miss_tension` — Orman Gerilimi
**Duygusal Islev:** "Tehlike!" — agac dalinin catlama sesi, yirtici yaklasiyor.
**Katman Yapisi:**
- Temel: Derin toprak titresimi — 60-100Hz, 100ms
- Govde: Agac dali stress cracki — 400-800Hz, gerilimli creak, 100ms
- Varlik: Kus alarm cigi (kisa) — 3kHz-5kHz, 50ms, keskin
**Sure:** 200-350ms.

#### 18. `near_miss_relief` — Orman Rahatlama
**Duygusal Islev:** "Tehlike gecti" — kus tekrar otmeye basliyor.
**Katman Yapisi:**
- Temel: Hafif yaprak hareketi — 200Hz, 60ms
- Govde: Yumusak odun settle — 400-600Hz, 80ms
- Varlik: Tek kus notasi (tatli) — 2.5kHz, 80ms, majr
**Sure:** 200-350ms.

#### 19. `ice_break` — Buz/Kabuk Kirma
**Duygusal Islev:** Agac kabugu veya donmus toprak kirilmasinin tatmini.
**Katman Yapisi:**
- Temel: Toprak/buz crack — 150-300Hz, keskin transient, 50ms
- Govde: Kabuk parcalanma — 500Hz-1kHz, 100ms, crunchy texture
- Varlik: Buz kristalleri savrulma — 3kHz-6kHz, ince, 80ms
**Sure:** 150-250ms.

#### 20. `ice_crack` — Buz/Kabuk Catlagi
**Duygusal Islev:** Donmus yaprak/dal catlak uyarisi.
**Katman Yapisi:**
- Temel: Yok
- Govde: Ince dal snap — 600-1kHz, 30ms
- Varlik: Buz kristal tick — 3kHz-5kHz, 20ms
**Sure:** 80-150ms.

#### 21. `powerup_activate` — Orman Gucu
**Duygusal Islev:** Dogadan enerji cekme — kok swell.
**Katman Yapisi:**
- Temel: Toprak rumble swell — 80-200Hz, crescendo 120ms
- Govde: Agac govde resonans ascending — 300Hz→800Hz, 150ms
- Varlik: Yaprak swell + ruzgar wishi — 2kHz-5kHz, 100ms
**Sure:** 200-350ms.

#### 22. `bomb_explosion` — Agac Patlamasi
**Duygusal Islev:** Agac govdesinin parcalanmasi — guclu, organik.
**Katman Yapisi:**
- Temel: Derin agac impact + toprak sub-thump — 40-150Hz, 120ms, ağır
- Govde: Odun kirilma burst + dal kaskat — 200Hz-1.2kHz, 250ms
- Varlik: Yaprak/toprak savrulma — 2kHz-6kHz, 300ms, granular
**Sure:** 350-600ms.

#### 23. `rotate_click` — Odun Donme
**Duygusal Islev:** Kucuk odun mekanizma donmesi.
**Katman Yapisi:**
- Temel: Yok
- Govde: Odun peg donme — 400-700Hz, kuru tick, 30ms
- Varlik: Mikro yaprak — 2kHz, 15ms
**Sure:** 60-120ms.

#### 24. `undo_whoosh` — Ruzgar Geri Esme
**Duygusal Islev:** Ruzgarin ters esmesi — zaman geri akisi.
**Katman Yapisi:**
- Temel: Hafif toprak swell — 100-200Hz, 80ms
- Govde: Yaprak savrulma reversed — 400Hz-1kHz, 150ms, ters akis hissi
- Varlik: Ruzgar whoosh descending — 2kHz-5kHz, filtered noise sweep, 120ms
**Sure:** 150-250ms.

#### 25. `freeze_chime` — Orman Donmasi
**Duygusal Islev:** Ormanin donmasi — yapraklar donuyor, ruzgar kesilir.
**Katman Yapisi:**
- Temel: Derin agac creak (soguk) — 100-200Hz, 100ms
- Govde: Donmus dal chime — 500Hz-1kHz, soguk metalik odun tonu, 150ms
- Varlik: Buz kristal formation — 3kHz-6kHz, granular build, 200ms
**Sure:** 250-400ms.

#### 26. `gravity_drop` — Meyve/Kozalak Dusme
**Duygusal Islev:** Agactan dusen meyve/kozalakin yere inmesi.
**Katman Yapisi:**
- Temel: Toprak impact — 100-200Hz, descending, 80ms
- Govde: Odun/meyve bounce — 300-600Hz, 2 mikro-bounce, 100ms
- Varlik: Yaprak kisirti — 2kHz-3kHz, 40ms
**Sure:** 150-250ms.

#### 27. `gel_ozu_earn` — Orman Odulu
**Duygusal Islev:** Dogal odul toplama — tohum/meyve bulma.
**Katman Yapisi:**
- Temel: Yok
- Govde: Odun marimba iki nota (C5-E5) — 400-800Hz, sicak, 80ms
- Varlik: Yaprak sparkle — 2kHz-3kHz, 100ms
**Sure:** 200-350ms.

#### 28. `pvp_victory` — Orman Zafer
**Duygusal Islev:** Ormanin krali — tum kuslar seninle otuyor.
**Katman Yapisi:**
- Temel: Agac govde drum roll — 60-200Hz, 300ms ascending
- Govde: Odun marimba majr fanfare ascending — 300Hz-1.2kHz, 4 nota, 500ms
- Varlik: Kus korosu crescendo + yaprak swell — 2kHz-8kHz, 500ms
**Sure:** 1000-1500ms.

#### 29. `pvp_defeat` — Orman Maglup
**Duygusal Islev:** Sessizlesen orman — kuslar sustu.
**Katman Yapisi:**
- Temel: Agac creak descending — 80-150Hz, 200ms
- Govde: Descending odun notalar — 600Hz→300Hz, 3 nota, 400ms
- Varlik: Son yaprak dusmesi + sessizlik — 2kHz, seyrek, 300ms
**Sure:** 700-1000ms.

#### 30. `pvp_obstacle_sent` — Orman Saldiri
**Duygusal Islev:** Dal/tas firlama — dogal mermi.
**Katman Yapisi:**
- Temel: Odun snap — 200-400Hz, 30ms, keskin
- Govde: Ruzgar whoosh ascending — 400Hz-1.5kHz, 120ms
- Varlik: Yaprak trail — 2kHz-4kHz, 80ms
**Sure:** 200-350ms.

#### 31. `pvp_obstacle_received` — Orman Darbe
**Duygusal Islev:** Dal/tas carpma — organik darbe.
**Katman Yapisi:**
- Temel: Toprak impact — 100-200Hz, 50ms
- Govde: Odun darbe — 400-800Hz, crunchy, 80ms
- Varlik: Yaprak savrulma — 2kHz-3kHz, 60ms
**Sure:** 200-350ms.

#### 32. `color_synth` — (Legacy Alias)
`color_synthesis` ile ayni dosya.

---

## Bolum E: CD.19 — Muzik Parcalari Briefi

### Mevcut Muzik Haritasi

| Dosya | Kullanim Yeri | Baglam |
|---|---|---|
| `menu_lofi.mp3` | HomeScreen | Menu dolasma, rahat |
| `game_relax.mp3` | Classic, ColorChef, Level, Daily (grid <%70) | Normal oyun |
| `game_tension.mp3` | TimeTrial, Duel + grid >=70% crossfade | Gerilim, basinc |
| `zen_ambient.mp3` | Zen modu | Meditasyon, dinlenme |

### Eksik Muzik Ihtiyaclari Analizi

Mevcut 4 parca 7 oyun modunu kapsior ama bazi modlar kendi duygusal kimligini hak ediyor. Asagida 6 yeni parca oneriyorum (5-8 araliginda kalarak).

---

### Parca 1: `colorchef_groove.mp3` — ColorChef Modu

## Muzik Briefingi: ColorChef Groove

**Sahne / Baglam:** Oyuncu renkleri birlestirip yeni renkler kesfediyor. Sentez odakli, kesfetme modu. Oyun temposu orta — dusunme + deneme.

**Duygusal Yay:** Merak (baslangic) → Kesfetme sevinci (orta) → Tatmin (sentez anlarinda)

**Muzikal Karakter:**
- **Tempo:** 95-105 BPM — ne acele ettiren ne uyutan. Kesfetme tempolu.
- **Key:** Eb Major / C minor — sicak ama gizemli. Sentez hissi.
- **Enstrumantasyon:** Yumusak elektrik piyano (Rhodes/Wurlitzer karakter), finger-pluck bass, hafif shaker/brush perkaston, minimal synth pad (sicak analog). Ara sira marimba/vibraphone melodic snippet.
- **Dinamik Aralik:** Dusuk (-18 to -12 LUFS momentary). Oyun seslerinin onunde durmamali.

**Oyun Dongusuyle Iliski:** Destekleyici — kesfetme motivasyonunu koruyor ama dikkat cekmiyor.

**Loop Davranisi:** Seamless loop. 90-120 saniye uzunluk. Loop noktasinda bar-aligned gecis. Bas ve melodinin kapanista seyrelip acilista yumusak girmesi (4 bar intro/outro overlap bolgesi).

**Stem Yapisi (gelecekte adaptif icin):**
- `drums_perc` — shaker + brush + rim
- `bass` — finger-pluck elektrik bas
- `keys` — Rhodes pad + melodic snippet'lar
- `atmosphere` — pad + texture

**Muzikal Referanslar:**
- Disco Elysium OST — "Instrument of Surrender" (sicak Rhodes, kesfetme hissi)
- Stardew Valley — "Spring" parcalari (merak, dogal akis)
- Tom Misch — "South of the River" (groove + sicaklik)

**Negatif Referanslar:**
- Agresif funk veya upbeat pop — cok dikkat dagitici
- Dark ambient — moda uygun degil, sentez kesfetme karanlik degil

**Teknik Ozellikler:**
- Format: MP3, 192 kbps+, stereo, 44.1 kHz
- Loop noktasi: Bar-aligned (4/4), seamless
- Loudness: -14 LUFS integrated, -1 dBTP

---

### Parca 2: `level_quest.mp3` — Level Modu

## Muzik Briefingi: Level Quest

**Sahne / Baglam:** Oyuncu 50+ seviyeyi teker teker gecerken. Her seviyede belirli hedef skor + hamle siniri. Odakli, stratejik, ilerlemeli.

**Duygusal Yay:** Karar verme odagi (baslangic) → Ilerleyen guven (orta) → Hedefe yaklasan heyecan (loop tekrar)

**Muzikal Karakter:**
- **Tempo:** 108-118 BPM — `game_relax`'tan biraz daha enerjik, stratejik dusunceyi destekleyen ama uyutmayan bir tempo.
- **Key:** G Major / E minor — parlak ama derinlikli.
- **Enstrumantasyon:** Pizzicato strings (ilerleme hissi), hafif gitar arpeggios, minimal elektronik perkaston (sidestick, hi-hat), yumusak synth bass, ara sira glockenspiel/celesta (seviye tamamlama antirisi).
- **Dinamik Aralik:** Orta-dusuk. Puzzle dusunme anlarini engellememeli.

**Oyun Dongusuyle Iliski:** Destekleyici + hafif itici. `game_relax`'in sakinliginden biraz daha "hedefe yurume" enerjisi.

**Loop Davranisi:** Seamless loop. 80-100 saniye. Loop gecisi 2 bar overlap.

**Stem Yapisi:**
- `rhythm` — perkaston + pizzicato pulse
- `bass` — synth bass
- `melody` — gitar + celesta
- `pad` — strings pad

**Muzikal Referanslar:**
- Captain Toad: Treasure Tracker OST — seviye bazli puzzle enerjisi
- Celeste — "First Steps" (karari, ileri giden, ama baskici degil)
- Lena Raine — melodic minimal yaklasimi

**Negatif Referanslar:**
- Epik orkestral — olcek fazla buyuk, bu kucuk puzzle seviyeleri
- Tekrarci chiptune — karakter uyumsuzlugu

**Teknik Ozellikler:**
- Format: MP3, 192 kbps+, stereo, 44.1 kHz
- Loop noktasi: Bar-aligned, seamless
- Loudness: -14 LUFS integrated, -1 dBTP

---

### Parca 3: `daily_ritual.mp3` — Daily Modu

## Muzik Briefingi: Daily Ritual

**Sahne / Baglam:** Gunluk bulmaca — her gun tek sans, herkesin ayn seed. Ritual his, ozel an. Rutine donmesini istiyoruz ama her seferinde biraz ozel hissettirmeli.

**Duygusal Yay:** "Bugunun meydan okumasi" merak (baslangic) → Odaklanma (orta) → Tatmin/hayal kirikligi (sonuc — muzik loop)

**Muzikal Karakter:**
- **Tempo:** 88-95 BPM — sabah kahvesi tempolu. Acele yok ama uyanik.
- **Key:** D Major — sicak, gunesli, pozitif ama asiri nesesli degil.
- **Enstrumantasyon:** Akustik gitar fingerpick, yumusak upright bass, hafif brush perkaston, sicak pad (analog synth veya mellowed strings), ara sira kalimba veya thumb piano (gunluk rituel hissi).
- **Dinamik Aralik:** Dusuk. Lo-fi estetik ama `menu_lofi`'den farkli karakter.

**Oyun Dongusuyle Iliski:** Destekleyici — gunluk rituel atmosferini olusturuyor.

**Loop Davranisi:** Seamless loop. 100-120 saniye. Uzun loop — tekrar hissi azaltmak icin (gunluk oynandiginda her seferinde farkli bolumde baslamak ideal — ama bu AudioManager'da seek gerektirdigi icin Phase 2).

**Stem Yapisi:**
- `rhythm` — brush + shaker
- `bass` — upright bass
- `melody` — akustik gitar + kalimba
- `pad` — warm analog pad

**Muzikal Referanslar:**
- Gustavo Santaolalla — The Last of Us (akustik intimacy)
- Khruangbin — "Time (You and I)" (gunluk rituel hissi, sicak groove)
- Minecraft — C418 "Sweden" (sakin ama duygusal)

**Negatif Referanslar:**
- Generic lo-fi hip hop beats — `menu_lofi` ile karisir, farkli karakter olmali
- Alarm/sabah muzigi klisesi — asiri iyimser, yapay

**Teknik Ozellikler:**
- Format: MP3, 192 kbps+, stereo, 44.1 kHz
- Loop noktasi: Bar-aligned, seamless
- Loudness: -14 LUFS integrated, -1 dBTP

---

### Parca 4: `duel_arena.mp3` — Duel Modu

## Muzik Briefingi: Duel Arena

**Sahne / Baglam:** 120 saniye, ELO bazli PvP. Rakiple eszamanli oynama, engel gonderme/alma. Rekabetci, adrenalini yuksek.

**Duygusal Yay:** Hazirlik gerilimi (baslangic) → Tam savas enerjisi (orta) → Son 30 saniyede tirmanan yoigunluk (tempo 1.15x otomatik)

**Muzikal Karakter:**
- **Tempo:** 128-135 BPM — `game_tension`'dan daha hizli ve rekabetci. Son 30 saniyede 1.15x tempo uygulanacak (AudioManager.setMusicSpeed), yani 147-155 BPM'e cikacak — buna dayanikli olmali.
- **Key:** A minor / F minor — karanlik, rekabetci, karari.
- **Enstrumantasyon:** Elektronik — agresif synth bass (sidechainded), driving hi-hat pattern, snare build-up'lar, distorted synth stab'lar, tension riser efektleri (bar sonlarinda). Melodi minimal — ritim ve enerji oncelikli.
- **Dinamik Aralik:** Orta-yuksek. Diger muziklerden daha agresif ama SFX'leri bastirmamali (ozellikle pvp_obstacle sesleri).

**Oyun Dongusuyle Iliski:** Aktif driver — oyuncuyu hizlandiran, rekabeti hissettiren.

**Loop Davranisi:** Seamless loop. 60-80 saniye (mac 120sn, 1.5-2 loop). Kisa loop — enerji dusmemeli. Loop noktasinda enerji dusmemesi kritik.

**Stem Yapisi:**
- `drums` — kick + snare + hi-hat
- `bass` — sidechained synth bass
- `synth` — stab'lar + riser'lar
- `tension` — pad + FX layer

**Muzikal Referanslar:**
- Hades — Darren Korb "The Unseen Ones" (rekabetci enerji)
- Tetris Effect — "Connected" hizi ve baskisi
- Carpenter Brut — "Turbo Killer" (sentetik agresiflik — ama daha hafif)

**Negatif Referanslar:**
- Generic EDM drop — cok ticari, kimliksiz
- Metal/rock — enstrumantasyon uyumsuz
- `game_tension` ile ayni ses — Duel kendi kimligini hak ediyor

**Teknik Ozellikler:**
- Format: MP3, 192 kbps+, stereo, 44.1 kHz
- Loop noktasi: Bar-aligned, seamless
- 1.15x speed'te dogal kalmali (pitch/artifact kontrolu)
- Loudness: -14 LUFS integrated, -1 dBTP

---

### Parca 5: `menu_chill.mp3` — Alternatif Menu Muzigi

## Muzik Briefingi: Menu Chill (Alternatif)

**Sahne / Baglam:** Mevcut `menu_lofi` alternatifi. Oyuncu uzun sure menu'de kaldiginda veya tercih olarak secebilecegi ikinci menu muzigi. Gloo'nun jel temasina daha yakin, organik.

**Duygusal Yay:** Karsilama sicakligi (baslangic) → Rahat kesfetme (orta) → Oyuna davet (loop)

**Muzikal Karakter:**
- **Tempo:** 75-85 BPM — `menu_lofi`'den biraz daha yavas, daha ambient.
- **Key:** Bb Major — sicak, yumusak, davetkar.
- **Enstrumantasyon:** Yumusak synth pad'ler (jelimsi wobble texture — Gloo kimligi), hafif pluck melodiler, derin sub-bass hum, minimal perkaston (occasional soft kick, rimshot). Cok az vokal chop/texture (sozsuz, jelimsi).
- **Dinamik Aralik:** Cok dusuk. Neredeyse ambient.

**Oyun Dongusuyle Iliski:** Atmosferik — menu deneyimini sarar, aksiyona davet etmez.

**Loop Davranisi:** Seamless loop. 120-150 saniye (uzun loop — menu'de tekrar hissi en az olmali).

**Stem Yapisi:**
- `pad` — jel-textured synth pad
- `melody` — pluck + chop
- `bass` — sub-bass hum
- `texture` — ambient layer + mikro FX

**Muzikal Referanslar:**
- Outer Wilds — Andrew Prahlow (merak, sicaklik, uzay — ama Gloo'ya uyarlanmis)
- Brian Eno — "Music for Airports" (ambient ama sicak)
- Monument Valley OST — minimal, zarif

**Negatif Referanslar:**
- Lo-fi hip hop beat — `menu_lofi` zaten bu rolu dolduruyor
- New age / spa muzigi — cok pasif, oyuna davet etmiyor

**Teknik Ozellikler:**
- Format: MP3, 192 kbps+, stereo, 44.1 kHz
- Loop noktasi: Bar-aligned, seamless
- Loudness: -14 LUFS integrated, -1 dBTP

---

### Parca 6: `tension_escalation.mp3` — Gerilim Tirmandirma (Alternatif)

## Muzik Briefingi: Tension Escalation

**Sahne / Baglam:** Grid %70+ dolulukta veya TimeTrial son 15 saniyede `game_tension`'a crossfade yerine alternatif gerilim muzigi. Mevcut `game_tension`'dan daha organik, daha cinematik.

**Duygusal Yay:** Uyari (baslangic) → Tirmanan basinc (orta) → Neredeyse kopma noktasi (loop)

**Muzikal Karakter:**
- **Tempo:** 120-128 BPM — `game_tension` ile ayni aralik (crossfade uyumlulugu icin).
- **Key:** C minor — klasik gerilim tonalitesi.
- **Enstrumantasyon:** Nabiz atan cello ostinato, gerilim string tremolo, elektronik pulse (sidechained), minimal metalik perkaston, soluksuz pad swell'ler. Melodi yok — sadece harmonik gerilim ve ritim.
- **Dinamik Aralik:** Orta. SFX'ler (ozellikle near_miss, combo) duyulmali.

**Oyun Dongusuyle Iliski:** Stres amplifikatoru — ama kontrolllu. Panik degil, odaklanma baskisi.

**Loop Davranisi:** Seamless loop. 45-60 saniye (kisa — gerilim aninda uzun loop gereksiz). TimeTrial'da 1.15x speed uygulanabilir.

**Stem Yapisi:**
- `pulse` — elektronik + cello ostinato
- `strings` — tremolo + pad
- `perc` — metalik perkaston
- `fx` — riser + swell

**Muzikal Referanslar:**
- Inside OST — Martin Stig Andersen (minimal gerilim)
- Bloodborne — "Ludwig's Theme" intro bolumu (string gerilimi — ama bu olcekte degil, sadece his)
- Trent Reznor & Atticus Ross — "The Social Network" (nabiz atan gerilim)

**Negatif Referanslar:**
- Jump scare muzigi — asiri dramatik, puzzle oyununa uygun degil
- Generic "epic trailer" build-up — kimliksiz

**Teknik Ozellikler:**
- Format: MP3, 192 kbps+, stereo, 44.1 kHz
- Loop noktasi: Bar-aligned, seamless
- 1.15x speed'te dogal kalmali
- Loudness: -14 LUFS integrated, -1 dBTP

---

## Bolum F: Uygulama Yol Haritasi

### Oncelik Sirasi

1. **CD.19 Muzik** — `duel_arena.mp3` ve `colorchef_groove.mp3` en yuksek oncelik (mod kimligi eksikligi en cok hissedilen yerler)
2. **CD.19 Muzik** — `level_quest.mp3`, `daily_ritual.mp3` (mod deneyimini zenginlestirir)
3. **CD.19 Muzik** — `menu_chill.mp3`, `tension_escalation.mp3` (alternatifler — daha dusuk oncelik)
4. **CD.18 SFX** — Crystal ASMR paketi (premium icerik — Shop satisi)
5. **CD.18 SFX** — Deep Forest paketi (premium icerik — Shop satisi)

### Dosya Teslim Kontrol Listesi

Her SFX dosyasi icin:
- [ ] `.ogg` versiyonu (Vorbis, 48kHz, mono, -6dBFS)
- [ ] `.m4a` versiyonu (AAC-LC, 48kHz, mono, -6dBFS)
- [ ] Dosya adi buyuk/kucuk harf uyumu (tam olarak yukaridaki tabloyla eslesmeli)
- [ ] Sure hedef araliginda
- [ ] Pitch varyasyon testi (0.92x ve 1.08x'te dogal dinleniyor mu?)
- [ ] Cascade pitch testi (`line_clear` icin 1.0x → 1.3x araliginda dogal mi?)

Her muzik dosyasi icin:
- [ ] `.mp3` versiyonu (192+ kbps, stereo, 44.1kHz)
- [ ] Seamless loop testi (click/pop yok)
- [ ] Loudness: -14 LUFS integrated, -1 dBTP
- [ ] 1.15x speed testi (tempo sesleri icin)
- [ ] SFX ile birlikte dinleme testi (mask etme kontrolu)

### Kod Degisiklikleri Gereksinimleri

Yeni muzik parcalari icin:
1. `audio_constants.dart`'a yeni `AudioPaths` static getter'lar ekle
2. `sound_bank.dart` veya ilgili ekranlarda muzik secim mantgini guncelle (mod bazli)
3. `pubspec.yaml`'a yeni asset path'leri ekle
4. SFX paketleri icin: `assets/audio/sfx/crystalAsmr/` ve `assets/audio/sfx/deepForest/` klasorlerini olustur, dosyalari yerlestir — kod degisikligi gerekmez (mevcut `resolveSfxPath` + fallback mekanizmasi otomatik handle eder)

---

## Bolum G: Kor Dinleme Testi Plani

### SFX Paketleri Icin

**Dogrulanacak Hipotez:** Her paket standard paketten farkli bir duygusal karakter olusturuyor ve oyun icerisinde tutarli bir kimlik tasiyor.

**Test Kosullari:**
1. Kulaklikla 5 dakika Classic mod — standard paket
2. Kulaklikla 5 dakika Classic mod — Crystal ASMR
3. Kulaklikla 5 dakika Classic mod — Deep Forest
4. Sirayi rastgele degistir (sirasi etkisi onleme)

**Anahtar Sorular:**
1. "Uc deneyim arasinda hissettiigin en buyuk fark neydi?"
2. "Hangi paket sana en tatmin verici geldi? Neden?"
3. "Herhangi bir ses seni rahatsiz etti mi veya oyundan kopardı mi?"
4. "Seslerin birbirleriyle uyumlu hissettini mi, yoksa bazi sesler pakete ait degil gibi mi geldi?"

**Basari Sinyalleri:**
- Katilimci 3 paketi farkli kelimelerle tanimliyor (kristal/cam vs odun/doga vs jel/yumusak)
- Hicbir pakette "garip" veya "yanlis" hisseden tekil SFX yok
- Tatmin skalasinda (1-5) ortalama >= 3.5

### Muzik Parcalari Icin

**Dogrulanacak Hipotez:** Her yeni muzik parcasi ilgili moda duygusal olarak uyuyor ve mevcut parcalarla karismiyor.

**Test Kosullari:** Her parcayi ilgili modda 2 tam oyun boyunca dinlet.

**Anahtar Sorular:**
1. "Bu muzik oyun moduna uygun mu hissettirdi?"
2. "Muzik tekrar ettigini fark ettin mi? Ne zaman?"
3. "Ses efektlerini net duyabildin mi, yoksa muzik onlari bastirdi mi?"

**Iterasyon Tetikleyicileri:**
- Loop farkedilmesi < 2 dongu ise → loop uzunlugu artir veya varyasyon ekle
- SFX maskelenmesi varsa → muzik mix'inde 800Hz-3kHz bolgede -2dB notch
- Mod uyumsuzlugu hissediliyorsa → tempo veya tonalite revisit
