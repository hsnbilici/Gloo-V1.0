# Season Pass — 50 Tier Odul Tablosu

**Versiyon:** 0.1 | **Tarih:** 2026-03-23

---

## 1. Tasarim Hedefleri

### Oyuncu Deneyimi
- **Erken tier'lar (1-15):** Hizli ilerleme hissi. Oyuncu ilk 2-3 oturumda en az 3-5 tier gecmeli. Kucuk ama sik oduller "bu calisiyor" sinyali verir.
- **Orta tier'lar (16-35):** Momentum devam eder ama hiz azalir. Burada anlamli oduller (kostum parcalari, buyuk Jel Ozu) motivasyonu tasiyan cekim noktalarini olusturur.
- **Gec tier'lar (36-50):** Sadece duzenli oynayanlara acik. Ozel/nadirlik hissi yaratan ekskluzif oduller. Premium track'te ciddi differansiyasyon.

### Ekonomi Dengesi
- Free track toplam: ~1.050 Jel Ozu + 55 Enerji + 3 kostum parcasi + 2 dekorasyon. Oynayan herkesin temel power-up ihtiyacini karsilayacak kadar Jel Ozu, ama "istedigim her seyi alabiliyorum" hissini vermeyecek kadar kontrollü.
- Premium track toplam: ~1.780 Jel Ozu + 40 Enerji + 7 kostum + 5 dekorasyon + 1 ses paketi. Free'nin ~2.7x degeri — Gloo+ abonelik justification'i icin yeterli fark.
- Referans: Slay the Spire'in unlock sistemi gibi "her odul bir sonraki oturuma neden verir" mantigi. Fortnite'in free/premium gap'i gibi premium'un gosterilebilir kozmetik avantaji.

### Milestone Felsefesi
Tier 10, 20, 30, 40, 50 ozel odullerdir. Bunlar:
- Free track'te bile dikkate deger (sadece 15 Jel Ozu degil)
- Premium'da "bunu kacirmak istemem" yaratan ekskluzivler
- Sosyal gosterim potansiyeli olan kozmetikler (kostum seti, dekorasyon)

---

## 2. XP Egrisi

### Formul

```
xpRequired(tier) = 100 + (tier - 1) * 8
```

Bu lineer artis yerine mevcut koddaki `100 + i * 20`'ye gore cok daha yumak bir egri. Gerekce:

| Mevcut (agresif) | Onerilen (yumusak) | Fark |
|---|---|---|
| Tier 1 = 100 XP | Tier 1 = 100 XP | Ayni |
| Tier 10 = 280 XP | Tier 10 = 172 XP | %39 daha kolay |
| Tier 25 = 580 XP | Tier 25 = 292 XP | %50 daha kolay |
| Tier 50 = 1080 XP | Tier 50 = 492 XP | %54 daha kolay |
| Toplam: 30.500 XP | Toplam: 14.800 XP | %51 daha az grind |

### Neden yumusak egri?

XP kazanimi `max(10, score ~/ 100)`. Ortalama bir Classic oyunda ~800-1200 puan → ~10 XP/oyun. Gloo+ 2x → ~20 XP/oyun. Mevcut egriyle Tier 50'ye ulasmak:
- Free: 30.500 / 10 = 3.050 oyun (~2+ ay gunluk 50 oyun). Bu kabul edilemez.
- Onerilen: 14.800 / 10 = 1.480 oyun, Gloo+ ile 740 oyun.

Sezon suresi 30 gun varsayimiyla:
- Gunluk 25 oyun oynayan free oyuncu: ~Tier 35-40'a ulasir (hepsi degil — iyi)
- Gunluk 25 oyun oynayan Gloo+ oyuncu: Tier 50'yi rahat tamamlar
- Gunluk 10 oyun oynayan casual: ~Tier 15-20 (free oduller yeterli motivasyon)

Bu denge, Gloo+ aboneliginin "sezonu tamamlama" vaadini somut kilarken, free oyuncuyu da ise yarayan bir yola koyar.

### XP Degerleri Tablosu

| Tier | XP | Kumulatif | Tier | XP | Kumulatif |
|---|---|---|---|---|---|
| 1 | 100 | 100 | 26 | 300 | 5.300 |
| 2 | 108 | 208 | 27 | 308 | 5.608 |
| 3 | 116 | 324 | 28 | 316 | 5.924 |
| 4 | 124 | 448 | 29 | 324 | 6.248 |
| 5 | 132 | 580 | 30 | 332 | 6.580 |
| 6 | 140 | 720 | 31 | 340 | 6.920 |
| 7 | 148 | 868 | 32 | 348 | 7.268 |
| 8 | 156 | 1.024 | 33 | 356 | 7.624 |
| 9 | 164 | 1.188 | 34 | 364 | 7.988 |
| 10 | 172 | 1.360 | 35 | 372 | 8.360 |
| 11 | 180 | 1.540 | 36 | 380 | 8.740 |
| 12 | 188 | 1.728 | 37 | 388 | 9.128 |
| 13 | 196 | 1.924 | 38 | 396 | 9.524 |
| 14 | 204 | 2.128 | 39 | 404 | 9.928 |
| 15 | 212 | 2.340 | 40 | 412 | 10.340 |
| 16 | 220 | 2.560 | 41 | 420 | 10.760 |
| 17 | 228 | 2.788 | 42 | 428 | 11.188 |
| 18 | 236 | 3.024 | 43 | 436 | 11.624 |
| 19 | 244 | 3.268 | 44 | 444 | 12.068 |
| 20 | 252 | 3.520 | 45 | 452 | 12.520 |
| 21 | 260 | 3.780 | 46 | 460 | 12.980 |
| 22 | 268 | 4.048 | 47 | 468 | 13.448 |
| 23 | 276 | 4.324 | 48 | 476 | 13.924 |
| 24 | 284 | 4.608 | 49 | 484 | 14.408 |
| 25 | 292 | 4.900 | 50 | 492 | 14.900 |

---

## 3. Odul Tipleri Aciklamasi

| Tip | Enum | Aciklama | Free'de? | Premium'da? |
|---|---|---|---|---|
| Jel Ozu | `gelOzu` | Temel para birimi. Power-up, talent, streak freeze | Evet (ana kaynak) | Evet (buyuk miktarlar) |
| Enerji | `energy` | Jel Enerjisi. Ada binasi, karakter gelisimi | Evet (ara odul) | Evet (buyuk miktarlar) |
| Kostum | `costume` | Hat/glasses/accessory parcalari | Sinirli (3 parca) | Bol (7 parca) |
| Dekorasyon | `decoration` | Grid temasi, arka plan efekti | Sinirli (2 parca) | Bol (5 parca) |
| Ses Paketi | `decoration`* | Ozel SFX seti (itemId ile ayirt edilir) | Yok | 1 adet (Tier 50) |

*Ses paketi su an `SeasonRewardType` enum'unda yok. Implementasyonda `decoration` type + `itemId: 'sound_pack_...'` ile temsil edilebilir, ya da enum'a `soundPack` eklenir. Bunu acik soru olarak birakmak dogru.

---

## 4. 50 Tier Odul Tablosu

### Odul ID Konvansiyonu
- Kostumler: `sp1_hat_01`, `sp1_glasses_01`, `sp1_acc_01` (sp1 = season pass 1)
- Dekorasyonlar: `sp1_deco_grid_neon`, `sp1_deco_bg_aurora` vb.
- Ses paketi: `sp1_sfx_retro`

### Tablo

| Tier | XP | Free Odul | Free Miktar | Premium Odul | Premium Miktar | Notlar |
|------|-----|-----------|-------------|--------------|----------------|--------|
| 1 | 100 | Jel Ozu | 15 | Jel Ozu | 30 | Hos geldin odulu — aninda tatmin |
| 2 | 108 | Enerji | 5 | Jel Ozu | 20 | |
| 3 | 116 | Jel Ozu | 15 | Enerji | 10 | |
| 4 | 124 | Jel Ozu | 20 | Jel Ozu | 25 | |
| 5 | 132 | Enerji | 5 | Kostum: `sp1_hat_01` (Jel Bere) | 1 | Ilk premium kozmetik — erken hook |
| 6 | 140 | Jel Ozu | 15 | Jel Ozu | 30 | |
| 7 | 148 | Jel Ozu | 20 | Enerji | 10 | |
| 8 | 156 | Enerji | 5 | Jel Ozu | 25 | |
| 9 | 164 | Jel Ozu | 20 | Jel Ozu | 35 | |
| **10** | **172** | **Kostum: `sp1_glasses_01` (Parlak Gozluk)** | **1** | **Dekorasyon: `sp1_deco_grid_neon` (Neon Grid)** | **1** | **MILESTONE — her iki track'te kozmetik** |
| 11 | 180 | Jel Ozu | 20 | Jel Ozu | 30 | |
| 12 | 188 | Enerji | 8 | Enerji | 10 | |
| 13 | 196 | Jel Ozu | 20 | Jel Ozu | 35 | |
| 14 | 204 | Jel Ozu | 25 | Kostum: `sp1_glasses_01` (Prizma Gozluk) | 1 | |
| 15 | 212 | Jel Ozu | 25 | Jel Ozu | 40 | |
| 16 | 220 | Enerji | 8 | Enerji | 12 | |
| 17 | 228 | Jel Ozu | 25 | Jel Ozu | 35 | |
| 18 | 236 | Jel Ozu | 20 | Dekorasyon: `sp1_deco_bg_aurora` (Aurora Arka Plan) | 1 | |
| 19 | 244 | Enerji | 8 | Jel Ozu | 40 | |
| **20** | **252** | **Kostum: `sp1_hat_02` (Kristal Tac)** | **1** | **Kostum: `sp1_acc_01` (Jel Kanat)** | **1** | **MILESTONE — free'de ilk sapka, premium'da aksesuar** |
| 21 | 260 | Jel Ozu | 25 | Jel Ozu | 40 | |
| 22 | 268 | Enerji | 10 | Enerji | 15 | |
| 23 | 276 | Jel Ozu | 30 | Jel Ozu | 45 | |
| 24 | 284 | Jel Ozu | 25 | Kostum: `sp1_hat_02` (Lav Kask) | 1 | |
| 25 | 292 | Dekorasyon: `sp1_deco_grid_pastel` (Pastel Grid) | 1 | Jel Ozu | 50 | Free'de ilk dekorasyon — yarimda harika hediye |
| 26 | 300 | Jel Ozu | 30 | Enerji | 15 | |
| 27 | 308 | Enerji | 10 | Jel Ozu | 45 | |
| 28 | 316 | Jel Ozu | 30 | Dekorasyon: `sp1_deco_bg_deep_ocean` (Derin Okyanus) | 1 | |
| 29 | 324 | Jel Ozu | 30 | Jel Ozu | 50 | |
| **30** | **332** | **Dekorasyon: `sp1_deco_bg_sunset` (Gunbatimi)** | **1** | **Kostum: `sp1_acc_02` (Gokkusagi Halka)** | **1** | **MILESTONE — iki track'te de kozmetik** |
| 31 | 340 | Jel Ozu | 30 | Jel Ozu | 50 | |
| 32 | 348 | Enerji | 10 | Enerji | 15 | |
| 33 | 356 | Jel Ozu | 35 | Jel Ozu | 55 | |
| 34 | 364 | Jel Ozu | 30 | Kostum: `sp1_glasses_02` (Hologram Gozluk) | 1 | |
| 35 | 372 | Enerji | 10 | Jel Ozu | 55 | |
| 36 | 380 | Jel Ozu | 35 | Dekorasyon: `sp1_deco_grid_galaxy` (Galaksi Grid) | 1 | |
| 37 | 388 | Jel Ozu | 35 | Jel Ozu | 60 | |
| 38 | 396 | Enerji | 12 | Enerji | 20 | |
| 39 | 404 | Jel Ozu | 35 | Jel Ozu | 55 | |
| **40** | **412** | **Kostum: `sp1_acc_01` (Jel Bileklik)** | **1** | **Dekorasyon: `sp1_deco_bg_nebula` (Nebula Arka Plan)** | **1** | **MILESTONE — gec oyun kozmetik** |
| 41 | 420 | Jel Ozu | 40 | Jel Ozu | 60 | |
| 42 | 428 | Enerji | 12 | Enerji | 20 | |
| 43 | 436 | Jel Ozu | 40 | Jel Ozu | 65 | |
| 44 | 444 | Jel Ozu | 35 | Kostum: `sp1_hat_03` (Alev Tac) | 1 | |
| 45 | 452 | Jel Ozu | 40 | Jel Ozu | 70 | |
| 46 | 460 | Enerji | 15 | Enerji | 25 | |
| 47 | 468 | Jel Ozu | 45 | Jel Ozu | 70 | |
| 48 | 476 | Jel Ozu | 40 | Dekorasyon: `sp1_deco_grid_diamond` (Elmas Grid) | 1 | |
| 49 | 484 | Jel Ozu | 45 | Jel Ozu | 80 | Son buyuk para odulu |
| **50** | **492** | **Jel Ozu** | **100** | **Ses Paketi: `sp1_sfx_retro` (Retro SFX)** | **1** | **FINAL MILESTONE — free'de buyuk Jel Ozu, premium'da ekskluziv ses** |

---

## 5. Odul Dagilim Ozeti

### Free Track Toplami
| Tip | Toplam | Adet |
|---|---|---|
| Jel Ozu | 1.060 | 32 tier |
| Enerji | 56 (8 kez: 5+5+5+8+8+8+10+10+10+10+12+12+15) — duzeltme asagida | 13 tier |
| Kostum | 3 parca (glasses T10, hat T20, acc T40) | 3 tier |
| Dekorasyon | 2 parca (grid T25, bg T30) | 2 tier |

Detayli Jel Ozu: 15+15+20+20+15+20+20+20+25+25+25+25+30+30+30+30+30+35+35+35+35+35+40+40+40+40+45+45+100 = ~1.060
Detayli Enerji: 5+5+5+8+8+8+10+10+10+10+12+12+15 = 118

### Premium Track Toplami
| Tip | Toplam | Adet |
|---|---|---|
| Jel Ozu | 1.780 | 29 tier |
| Enerji | 207 | 10 tier |
| Kostum | 7 parca | 7 tier |
| Dekorasyon | 5 parca | 5 tier |
| Ses Paketi | 1 parca (Tier 50) | 1 tier |

### Karsilastirma: Free vs Premium Toplam Deger

Jel Ozu bazinda kaba deger hesabi (kostum ~200, dekorasyon ~150, ses paketi ~300 Jel Ozu esdegeri):

- **Free:** ~1.060 + 118 enerji + 3*200 + 2*150 = ~2.078 esdeger
- **Premium:** ~1.780 + 207 enerji + 7*200 + 5*150 + 300 = ~4.437 esdeger
- **Premium/Free orani:** ~2.1x — saglikli. Cok az olsa premium gereksiz hisseder, cok fazla olsa free oyuncu cezalanmis hisseder.

---

## 6. Pacing ve Ritim Analizi

### Odul Tipi Ritmi (her 5 tier'da bir dongu)

```
Tier 1-4:  Jel Ozu / Enerji / Jel Ozu / Jel Ozu    (birikim fazı)
Tier 5:    Enerji (free) + Kostum (premium)           (premium hook)
Tier 6-9:  Jel Ozu / Jel Ozu / Enerji / Jel Ozu     (birikim fazı)
Tier 10:   MILESTONE — her iki track'te kozmetik      (buyuk odul)
```

Bu dongu her 10 tier'da tekrarlanir: 8 Jel Ozu/Enerji dolgu + 1 ara kozmetik + 1 milestone. Oyuncunun asla "3 tier boyunca sadece Jel Ozu aldim, sikildim" dememesi icin:
- Her 3 tier'da en az bir Enerji (farkli tip)
- Her 5 tier'da en az bir kozmetik (premium track'te)
- Her 10 tier'da kesin milestone

### Hiz Egrisi Hissi

| Faz | Tier Araligi | Oyun/Tier | His |
|---|---|---|---|
| Alisma | 1-5 | ~10-13 oyun | "Hizla ilerliyorum!" |
| Ivme | 6-15 | ~15-21 oyun | "Duzenli ilerleme var" |
| Maraton | 16-35 | ~22-37 oyun | "Calisiyorum ama oduller buna deger" |
| Sprint | 36-50 | ~38-49 oyun | "Son tier'lar zor ama ekskluziv" |

---

## 7. Tasarim Gerekceleri

### Neden Jel Ozu agirlikli?

Jel Ozu oyunun tek hard currency'si. Power-up maliyetleri (3-10 arasi), streak freeze (100), talent upgrade (80-360 arasi) — harcama yeri cok. Season Pass'ten gelen Jel Ozu, oyuncunun power-up kullanmaktan cekinmesini azaltir. Bu, daha fazla power-up kullanimi → daha yuksek skor → daha fazla XP → daha hizli tier ilerlemesi seklinde pozitif feedback loop yaratir. Clash Royale'in Pass Royale'inde de benzer bir yaklasim var: free pass temel kaynaklari verir, premium pass hem daha fazla kaynak hem ekskluzif kozmetik.

### Neden free track'te az ama var kozmetik?

Tamamen kozmetiksiz free track, "bu benim icin degil" hissi yaratir. 3 free kozmetik (Tier 10, 20, 40), oyuncuya "premium'da cok daha fazlasi var ama ben de bir seyler aliyorum" hissini verir. Fortnite'in free pass'inde de bu strateji gorulur: az sayida ama gosterisli free kozmetik, premium'a gecisi tesvik eder.

### Neden lineer XP egrisi?

Logaritmik/ustel egri yerine `100 + (tier-1)*8` lineer artis sectim. Nedenleri:
1. **Tahmin edilebilirlik:** Oyuncu her tier'in kabaca ne kadar surecegini sezgisel olarak anlayabilir.
2. **Son tier'lar zor ama imkansiz degil:** Tier 50 = 492 XP, Tier 1'in ~5 kati. Ustel egride bu oran 10-20x olurdu — bu casual oyuncuyu tamamen dislar.
3. **Gloo+ deger onerisi:** 2x XP ile sezonu rahat tamamlamak, abonenin "param bosuna gitmedi" hissini dogrular.

### Milestone tier'lar neden onemli?

Milestone'lar (10/20/30/40/50) scroll-through listede gorsel anker noktalari olusturur. "Tier 20'ye gelince su sapkayi alacagim" gibi somut, yakin hedefler koyar. Self-Determination Theory'deki "competence" ihtiyacini karsilar — uzun bir yolda ara basarilari hissetme.

---

## 8. Implementasyon Notlari

### Enum Genislemesi
Mevcut `SeasonRewardType`: `gelOzu`, `costume`, `decoration`, `energy`. Ses paketi icin:
- **Opsiyon A:** `decoration` type + `itemId: 'sound_pack_...'` (degisiklik yok, ama semantik kirli)
- **Opsiyon B:** Enum'a `soundPack` ekle (temiz, ama enum degisikligi tum switch/case'leri etkiler)
- **Oneri:** Opsiyon B. 4 dosyada degisiklik: `season_pass.dart`, `season_pass_widgets.dart` (icon mapping), ilgili claim logic.

### Veri Yapisi
Mevcut `_kSeasonTiers` zaten `List<SeasonTier>` olarak tanimli. Asagidaki kodu `season_pass_screen.dart`'taki mevcut `List.generate` ile degistirmek yeterli. Ancak 50 tier'in elle tanimlanmasi daha dogru — generate yerine const list.

### Tier verisini ayirma
`_kSeasonTiers`'i `season_pass_screen.dart`'tan cikarip `lib/game/meta/season_pass.dart`'a tasimak mimariye daha uygun. Screen dosyasi veri tanimlamamali.

### Kostum parcalari
`CostumeSlot` enum'u 3 slot tanimliyor: `hat`, `glasses`, `accessory`. Tablodaki 10 kostum parcasi (3 free + 7 premium) bu slotlara dagitildi:
- Hat: 4 (free T20, premium T5/T24/T44)
- Glasses: 3 (free T10, premium T14/T34)
- Accessory: 3 (free T40, premium T20/T30)

---

## 9. Acik Sorular

- [ ] Sezon suresi kac gun? (30 gun varsayildi — 45-60 gun olursa XP egrisi rahatlar, tier basi odul arttirilabilir)
- [ ] `soundPack` reward type eklenmeli mi yoksa `decoration` altinda mi kalacak?
- [ ] Kostum ve dekorasyon asset'leri hazir mi? Isimler placeholder — asset pipeline ile eslestirilmeli.
- [ ] Tamamlanamayan sezon'da kalan tier'lar ne olacak? (sifirlanir mi, catch-up mekanizmasi mi?)
- [ ] Season Pass 2, 3... icin tier verileri ayri dosyada mi tutulacak? (sifirlanir mi, yeni liste mi yuklenir?)

---

## 10. Dogrulama Plani

### Playtest Hipotezi
"Gunluk 15-20 dakika oynayan free oyuncu, 30 gun icinde Tier 25-30 arasina ulasir ve bu ilerlemeden tatmin olur."

### Test Yontemi
1. XP kazanim oranini 50 oyunluk orneklemle olc (farkli modlar, farkli beceri seviyeleri)
2. Ortalama XP/oyun degerini tabloya uygula, 30 gunluk simulasyon calistir
3. Ilk 10 tier'in 1. oturumda (30-45 dk) erisilebilir oldugunu dogrula
4. Milestone tier'larda oyuncunun heyecan/tatmin ifadesini gozlemle

### Basari Sinyalleri
- Oyuncular Season Pass ekranini haftada 3+ kez ziyaret ediyor (ilerleme kontrol motivasyonu)
- Tier 10'a ulasan oyuncularin %60+'i Tier 20'ye de ulasiyor (retention)
- Gloo+ donusum orani Season Pass lansmani sonrasi %15+ artis gosteriyor

### Iterasyon Tetikleyicileri
- Eger Tier 10'a 7+ gunde ulasan oyuncu orani %50'yi gecerse → erken tier XP'sini dusur
- Eger Tier 50'ye ulasan Gloo+ orani %30'un altinda kalirsa → gec tier XP'sini dusur veya bonus XP etkinligi ekle
- Eger free track retention'i Tier 15 sonrasi %40'in altina duserse → free kozmetik sayisini artir (Tier 15 ve 35'e ekle)
