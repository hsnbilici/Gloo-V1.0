# Gloo v1.0 — Organik Buyume & Bagimlilik Raporu

**Tarih:** 2026-03-18
**Durum:** Proje 87/100 kalite puani, 1289 test, 7 oyun modu, 12 dil destegi

---

## OZET

Gloo'nun oyun motoru, ses/haptik sistemi ve ekonomisi guclu. Ancak **viral dagitim**, **gunluk yeniden etklesim** ve **sosyal donguler** zayif. Mevcut haliyle tahmini D1 retention %35-40 (hedef %45), viral katsayi (K-factor) ~0.15 (hedef 0.30+). Asagidaki iyilestirmelerle organik buyume potansiyeli 2-3x artabilir.

---

## MEVCUT GUCLU YANLAR

### Bagimlilik Yapan Mekanikler (Zaten Var)
1. **ASMR Farklilastirma** — 9 SFX tipi + 14 haptik profil + pitch varyasyonu = rakipsiz duyusal deneyim
2. **Sik Mikro-Oduller** — Renk sentezi + satir temizleme her ~20 saniyede bir dopamin tetikliyor
3. **Combo Beklentisi** — Degisken carpanlar (1.2x → 3.0x) "epic combo gelecek mi?" gerilimi yaratir
4. **Uzun Vadeli Ilerleme** — 200+ seviye + ada meta-oyun = aylar boyunca icerik
5. **Gunluk Rituel** — Streak sistemi + gunluk bulmaca aliskanlik dongusu tetikler
6. **Kayip Korkusu** — Near-miss dedektoru (Shannon entropy tabanli) + ikinci sans mekaingi

### Teknik Altyapi (Hazir)
- PvP realtime (Supabase Presence + Broadcast, ELO, bot fallback)
- Global leaderboard (haftalik + tum zamanlar)
- IAP pipeline (receipt dogrulama, redeem code, pending retry)
- Analytics temeli (Firebase, 9+ event tipi)
- Reklam sistemi (GDPR uyumlu, anti-frustration kurallari)

---

## KRITIK EKSIKLER & FIRSATLAR

### A. VIRAL DAGITIM (Mevcut K-Factor: ~0.15)

| Sorun | Etki | Durum |
|-------|------|-------|
| **Video export calismyor** | TikTok/Reels dongusu tamamen kapali | FFmpeg paketi discontinued, ClipRecorder frame yakalyor ama video uretmiyor |
| **Deep link yok** | Paylasimlar App Store'a yonleniyor, oyun icerigine degil | Firebase Dynamic Links veya Branch.io kurulmamis |
| **Otomatik paylasim tetikleyicisi yok** | Kullanici manuel paylasma butonunu bulmali | Near-miss/epic combo sonrasi auto-prompt yok |
| **Referral sistemi yok** | Davet eden/edilen odulsuz | Referral kodu uretimi ve takibi yok |
| **Hashtag/watermark yok** | Paylasilan icerik markasiz | Video uzerinde #Gloo branding yok |

**Cozum Onceligi:**
1. Video export'u fix et (ffmpeg_kit v7+ veya image_to_mp4 paketi)
2. Epic combo / near-miss sonrasi otomatik "Paylas!" dialog goster
3. Firebase Dynamic Links ile deep link altyapisi kur
4. Referral kodu sistemi ekle (davet eden + edilen Jel Ozu odulu)

---

### B. ONBOARDING & ILK DENEYIM (Tahmini %40 Ilk Oyun Churn)

| Sorun | Etki |
|-------|------|
| **Oyun ici tutorial yok** | 3 sayfa onboarding'den sonra bos 8x10 grid'e birakiliyor |
| **Interaktif rehberlik yok** | "Ilk 3 hamle yonlendirilmeli" GDD'de var ama kodda yok |
| **Ilerleme hissi yok** | Ilk oyun 2-5dk, ~100 puan = anlamsiz hissettiriyor |
| **Monetizasyon tanitimi yok** | Gloo+ degeri gosterilmiyor |

**Cozum Onceligi:**
1. Tutorial seviyesi ekle (onceden tanimli, 2 hamlede kazanilan)
2. Ilk 3 hamleyi overlay ile yonlendir ("Buraya dokun")
3. Ilk zafer popup'i: "5 satir temizledin! Skor tablosunu kontrol et"
4. 2. oyun sonrasi Streak + Shop teaser goster

---

### C. GUNLUK YENIDEN ETKILESIM (D7 Retention Tahmini: %15-18)

| Sorun | Etki |
|-------|------|
| **Streak odulu yok** | Badge gosteriyor ama somut odul yok (3 gun = 10 Jel, 7 gun = 50 Jel olmali) |
| **Push notification yok** | Firebase Messaging entegre degil, "geri don" hatirlatmasi gonderilemiyor |
| **Gunluk gorev sistemi yok** | Quests klasoru bos, "3 combo yap" gibi gorevler yok |
| **Sinirli sureli etkinlik yok** | FOMO/kitlik mekanigi eksik |
| **Streak kirilma bildirimi yok** | "Streak kirildi! Bugun oyna ve yeniden basla" mesaji yok |

**Cozum Onceligi:**
1. Streak milestone odulleri ekle (3/7/14/30 gun = artan Jel Ozu)
2. Firebase Messaging entegre et (gunluk hatirlatma, streak uyarisi)
3. 3 gunluk gorev sistemi kur (tamamlama = bonus Jel)
4. Haftalik etkinlik takvimi (ozel leaderboard, sinirli mod)

---

### D. SOSYAL DONGULER (Izole Deneyim)

| Sorun | Etki |
|-------|------|
| **Arkadas listesi yok** | Kimin oynadigini goremiyorsun |
| **Arkadas meydan okumasi yok** | "Skorumu yen" linki gonderilemiyor |
| **Klan/guild sistemi yok** | Topluluk hissi yok |
| **Seyirci modu yok** | Rakibin oyununu izleyemiyorsun |
| **Arkadas leaderboard'u yok** | Sadece global siralamaya bakiliyor |

**Cozum Onceligi:**
1. "Meydan Oku" butonu ekle (skor + deep link paylasimi)
2. Arkadas listesi (Supabase social graph)
3. Arkadas leaderboard'u filtreleme

---

### E. MONETIZASYON BOSLUKLARI (Tahmini ARPU: $0.18, Hedef: $0.25+)

| Sorun | Etki |
|-------|------|
| **Kozmetik magazasi yok** | Ses/doku paketleri tanimli ama UI yok, satin alinamiyor |
| **Battle Pass (ucretli) yok** | Season Pass framework var ama monetize edilmemis |
| **Mevsimsel kozmetikler yok** | FOMO yaratacak sinirli sureli icerik yok |
| **Enerji/stamina sistemi yok** | Sinirsiz oynama = monetizasyon firsati kaciriliyor |

---

### F. HIS & CILALAMA (Juice) Iyilestirmeleri

#### Hizli Kazanimlar (1-2 Gun)
| Iyilestirme | Etki |
|-------------|------|
| High score'da konfeti patlamasi | Kutlama dopamini |
| Bomba patlamasinda 100ms freeze-frame | Dramatik etki |
| Kucuk combo icin SFX eklenmesi | Ses hiyerarsisi tamamlanir |
| Gravity cascade'de tekrarlanan SFX | Fizik tutarliligi |
| 3+ satir temizlemede ekran flash'i | Gorsel doruk |

#### Orta Efor (3-5 Gun)
| Iyilestirme | Etki |
|-------------|------|
| Tehlike bolgesi animasyonu (grid doluluk %'sine gore kirmizi ton) | Gorsel uyari |
| Combo metre UI (epic combo'ya dogru dolma) | Heyecan insa |
| Buyuk temizlemelerde kamera zoom (1.05-1.1x) | Olcek algisi |
| Dinamik muzik tempo (doluluk arttikca hizlanma) | Tempo senkronizasyonu |
| Basarim sistemi (5-10 rozet) | Tamamlamacilik |

---

## ONCELIK SIRASI: ORGANIK BUYUME YOLHARITASI

### TIER 1 — Hemen Yap (2 Sprint, En Yuksek ROI)

| # | Gorev | D1 Etkisi | Viral Etkisi | Efor |
|---|-------|-----------|-------------|------|
| 1 | **Onboarding tutorial** (interaktif ilk 3 hamle) | +8% D1 | — | 3-4 gun |
| 2 | **Video export fix** (ffmpeg alternatifi) | — | +3% K-factor | 2-3 gun |
| 3 | **Otomatik paylasim tetikleyicisi** (combo/near-miss sonrasi) | — | +2% K-factor | 1-2 gun |
| 4 | **Streak milestone odulleri** (3/7/14/30 gun) | +5% D7 | — | 1 gun |
| 5 | **Push notification** (Firebase Messaging) | +8% D7 | — | 2-3 gun |
| 6 | **Konfeti + freeze-frame + combo SFX** (juice) | +3% D1 | — | 1-2 gun |

**Beklenen Etki:** D1 %35 → %45, K-factor 0.15 → 0.25

### TIER 2 — Sonraki Adim (3 Sprint)

| # | Gorev | Etki |
|---|-------|------|
| 7 | Gunluk gorev sistemi (3 gorev/gun, Jel odulu) | +5% DAU |
| 8 | Deep link altyapisi (Firebase Dynamic Links) | +2% viral |
| 9 | Kozmetik magazasi (ses/doku paketi secim UI) | +2% ARPU |
| 10 | Battle Pass ucretli track ($6.99/sezon) | +10% ARPU |
| 11 | Sinirli sureli etkinlikler (aylik tema, haftalik ozel leaderboard) | +5% DAU spike |
| 12 | Basarim/rozet sistemi (50+ basarim) | +12% retention |

### TIER 3 — Olceklendirme (4+ Sprint)

| # | Gorev | Etki |
|---|-------|------|
| 13 | Arkadas sistemi + meydan okuma | +2% viral |
| 14 | Klan/guild sistemi | +25% uzun vadeli DAU |
| 15 | Seyirci modu & tekrar izleme | +3% PvP etkilesim |
| 16 | Referral programi (davet kodu + odul) | +3% K-factor |
| 17 | Mevsimsel kozmetikler (FOMO) | +15% retention |

---

## REKABET ANALIZI

| Kriter | Gloo | Block Blast | Candy Crush | Wordle |
|--------|------|-------------|-------------|--------|
| Ses/Haptik | ★★★★★ | ★★★ | ★★★★ | ★★ |
| Sosyal | ★★☆ | ★★★ | ★★★★★ | ★★★★ |
| Gunluk Rituel | ★★★★ | ★★ | ★★★★ | ★★★★★ |
| Viral Dongular | ★★☆ | ★★★ | ★★★★ | ★★★★★ |
| Monetizasyon | ★★★ | ★★★★ | ★★★★★ | ★★ |
| Onboarding | ★★☆ | ★★★★ | ★★★★★ | ★★★★ |

**Gloo'nun Farklilasma Noktasi:** ASMR ses + haptik deneyim (rakipsiz). Bu avantaji TikTok/Reels viral dongusuyle birlestirmek buyume icin en buyuk firsat.

---

## SONUC

**Oyun mekanigi ve teknik altyapi guclu.** Eksik olan "buyume motorlari":

1. **Kullaniciyi getir** → Video export + deep link + referral (viral)
2. **Kullaniciyi tut** → Tutorial + streak odulleri + push notification (retention)
3. **Kullaniciyi geri getir** → Gunluk gorevler + etkinlik takvimi + FOMO (re-engagement)
4. **Kullanicidan kazan** → Kozmetik magaza + battle pass + mevsimsel icerik (monetization)

Tier 1 iyilestirmeleri (~2 sprint) tamamlanmadan organik buyume potansiyeli sinirli kalacak.
