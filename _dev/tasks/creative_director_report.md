# Gloo v1.0 — Yaratici Yonetmen Raporu

**Tarih:** 2026-03-23
**Versiyon:** 0.3
**Yazar:** Yaratici Yonetmen
**Kaynak:** Tam kod tabani analizi (lib/, assets/, test/), oyun tasarimi analiz raporu, CLAUDE.md teknik dokumantasyon, v0.1-v0.2 raporlari sonrasi tamamlanan CD.21-CD.31 gorevleri

---

## A. Vizyon Degerlendirmesi

### A.1 Duygusal Vaat — Gloo Oyuncuya Ne Hissettirmeyi Vaat Ediyor?

Gloo'nun kod tabanini, mekaniklerini, ses mimarisini ve gorsel dilini bir butun olarak okudugnda ortaya cikan duygusal vaat su:

> **"Basit gorunen malzemeyle beklenmedik bir sey yaratmanin tatminini hisset."**

Bu vaat uc katmanda kendini gosteriyor:

1. **Kesfin Heyecani**: 4 birincil renk → 8 sentez rengi. Oyuncu her yerlestirmede yalnizca alan yonetmez, renk kimyasi yapar. Ilk "red + yellow = orange" ani, oyunun duygusal cekirdegi.
2. **Duzenlemenin Huzuru**: Satirlari temizlemek, alani acmak, gridi yonetmek — tetris-benzeri "duzen kurma" tatmini.
3. **Ustalik Gururu**: Cascade zincirleri, coklu satir temizleme, epic kombolar — planlanan hamlenin domino etkisi yaratmasi.

Bu uc katman birlikte "yaratici kontrol" hissi veriyor. Gloo, oyuncuya "sen akillica dusundun ve guzel bir sey oldu" diyen bir oyun.

Jel morph efekti (GelCellPainter), sentez glow animasyonu ve squash-bounce yerlestirme entegrasyonu ile "guzel bir sey oldu" kisminin gorsel karsiligi artik somut. Onboarding lore sayfasi ("Renklerin canli oldugu bir dunyada, birlestiklerinde yeni bir sey doguyor") bu vaadi oyuncunun ilk temas noktasinda kuruyor. Mod flavor text'leri ("Free Creation", "Color Kitchen") ise teknik mod isimlerine dunya dili kazandiriyor.

### A.2 Merkezi Gerilim

**Duzen vs. Kaos** — Oyuncu duzen kurmaya calisir (satirlari doldur, renkleri hizala), ama oyun surekli kaos uretir (rastgele sekiller, artan zorluk, buyuyen parcalar). Bu gerilim cozulmemeli — oyunun nabzi bu.

Ikincil gerilim: **Basitlik vs. Derinlik** — Yuzeyden bakinca basit bir yerlestirme oyunu, ama sentez mekanigi her karari iki katmanli yapiyor. Bu, oyunun "ogrenmesi kolay, ustalasmasi zor" vaadinin ta kendisi. CD.22 ile eklenen sentez-temizleme trade-off toast'i bu gerilimi artik oyuncuya acikca iletiyor.

### A.3 Mevcut Durum Degerlendirmesi

Gloo'nun mevcut durumu: **teknik olarak olgun, yaratici olarak belirgin kimlik kazanmis**. v0.2'den bu yana odak "yaratici kimligin derinlesmesi" oldu:

- **Mekanik temel saglam ve genisliyor**: Sentez sistemi gercek bir ayirt edici. 7 mod, kapsamli pipeline, merhamet mekanizmalari — oyun motoru profesyonel seviyede. ColorChef artik 40 bolume genisledi (onceki: 20) — tek sonlu mod sorunu cozuldu. Gorev sistemi 12 gunluk + 5 haftalik gorevle genis.
- **Ses temeli guclu + genisletilebilir**: 32 SFX, 4 muzik parcasi, adaptif muzik, cascade pitch escalation, ducking. AudioPackage sistemi (standard/crystalAsmr/deepForest) ses paketlerini swap edebilir hale getirdi — altyapi hazir, icerik uretimi bekliyor.
- **Gorsel kimlik somutlasti**: GelCellPainter ile hucreler 6 katmanli render'a sahip. Squash-bounce yerlestirme entegrasyonu tamamlandi — specular Y kayma, glow alpha artisi, ic parlama buyumesi ile "jel basildginda ic isik yayilir" hissi. Satir temizleme intensity scaling ile gorsel geri bildirim coklu temizlemelerde belirgin olarak artiriyor (2+ satir → 1.5x, 4+ → 2.0x parcacik/flash).
- **Anlati/dunya ilk kez sesini buluyor**: Onboarding lore sayfasi ("Renklerin canli oldugu bir dunyada...") minimal ama etkili bir dunya tanitimi sunuyor. Mod flavor text'leri ("Free Creation", "Color Kitchen") ve "ELO" → "Power/Guc" donusumu, teknik dil ile dunya dili arasindaki ucurumu daraltmaya basladi. InteractivePlaceDemo'ya GlowOrb'lar ve ambient glow eklenmesiyle ilk temas noktasi atmosferik derinlik kazandi.
- **Marka kimligi embriyonik**: "GLOO" adi iyi (kisa, hatirlanir, fonetik olarak evrensel). Logo'da Gl=cyan, oo=pembe ayrimi var. Flavor text'ler ve lore sayfasi marka dilinin ilk adimlarini olusturuyor — ama tutarli bir marka seslendirmesi henuz olusmamanis.

### A.4 Hedef Kitle Analizi

Kod tabanindan cikarilan hedef kitle profili:

| Segment | Kanitlar | Oncelik |
|---------|----------|---------|
| **Casual Puzzle Severler** (25-45 yas, kadin agirlikli) | 12 dil, erisilebilirlik, anti-frustration, merhamet RNG, Zen modu | Birincil |
| **Rekabetci Puzzle Oyunculari** (18-35, erkek agirlikli) | Duel modu, Power sistemi (eski ELO), leaderboard, Daily challenge | Ikincil |
| **Kisa Oturum Mobil Oyuncular** | 90sn TimeTrial, 5dk ortalama Classic oturum, streak sistemi | Birincil |
| **Koleksiyoncular / Tamamlayicilar** | 50+ level, ascension, collection odulleri, 8 sentez rengi, karakter kisilikler, 40 ColorChef bolumu | Ucuncul |

Karakter kisilik sistemi (8 GelPersonality), Wordle emoji grid paylasimi ve 40 bolumlu ColorChef, "koleksiyoncu" ve "sosyal paylasimci" segmentlerini daha iyi hedefliyor. Haftalik gorevler uzun vadeli oyuncu tutmayi guclendiriyor.

### A.5 Rakip Konumlandirma

| Rakip | Gloo'nun Avantaji | Gloo'nun Dezavantaji |
|-------|-------------------|---------------------|
| 1010! / Block Puzzle | Sentez mekanigi (iki katmanli karar) | Gorsel cazibe, marka bilinirli |
| Tetris Mobile | 7 mod cesitliligi, PvP Power | Marka gucu, anlik taninirlik |
| Puyo Puyo | Renk birlesimi benzerligi — tanidik hissedecek | Karakter derinligi, hikaye |
| Wordle | Daily challenge + emoji grid paylasimi | Sosyal viralite olgunlugu |
| Candy Crush | Renk tematigi, casual hedef kitle | Gorsel parlaklik, juice, karakter |

**Konumlandirma cumlesi**: Gloo, "renk kimyasiyla zenginlestirilmis bir puzzle deneyimi" olarak 1010!/Block Puzzle kategorisinde ama sentez mekanigi ile ayrilir. Puyo Puyo'nun renk birlesimini mobil-casual formata tasir. Wordle benzeri emoji grid paylasimi ile sosyal yayilma potansiyeli mevcut. Onboarding lore sayfasi ve flavor text'ler ile "dunya hissi olan puzzle" konumunu guclendirir.

---

## B. Disiplinler Arasi Sentez

### B.1 Oyun Tasarimi

**Puan: 4.7 / 5.0** (onceki: 4.5)

**Guclu Yonler:**
- Sentez mekanigi sektorde gercek bir farklilastirici — cogu satir-temizleme puzzle'i tek katmanli karar verir, Gloo iki katman sunuyor (alan + renk).
- 7 mod, 7 farkli oyuncu motivasyonuna hitap ediyor. Classic (mastery), Zen (relaxation), Duel (competition), ColorChef (creativity), Daily (ritual), Level (progression), TimeTrial (challenge).
- Pipeline mimarisi (`_evaluateBoard`) temiz ve genisletilebilir.
- Merhamet sistemi sektorde gold standard — 3 ardisik kayip + 5 hamle temizleme yok, iki farkli stres turune iki cevap.
- Kombo sistemi hamle bazli (zaman degil) — puzzle ruhuna uygun. Oyuncuyu hiz yerine strateji oduluyor.
- Gorev sistemi genis: 12 gunluk + 5 haftalik gorev, ISO week bazli reset, quest.id bazli progress.
- Ada core loop baglantisi: Game over → pasif uretim tick. Meta-game artik mekanik olarak bagli.
- Karakter kisilik sistemi: 8 GelPersonality arketipi sentez renklerine anlam veriyor.
- ColorChef 40 bolume genisledi — 4 tema bandinda (21-25 rotation, 26-30 rare, 31-35 high-pressure, 36-40 master) artan zorlukla sonlu mod sorunu cozuldu.
- Sentez-temizleme trade-off ogretimi eklendi — en derin mekanik catisma artik oyuncuya ilk oyunlarda iletiliyor (oyun 3-8, 2 gosterim).
- Epic kombo yaklasim motivasyonu — large tier combo'da (6+) "zinciri surdur" toast'i ile doruk odul artik daha eriselebilir hissettiriliyor.

**Zayifliklar:**
- Meta-game (Ada, Karakter, Season Pass) kodlanmis ve navigasyon aktif, ancak icerikler (ada gorseli, season pass tier odulleri) hala iskelet.
- Epic kombo (8+) hala mekanik olarak zor — motivasyon toast'i psikolojik bariyeri dusurdu ama mekanik bariyeri dusmedi.

**Duygusal Vaatle Uyum**: Cok yuksek. Sentez mekanigi "basit malzemeyle beklenmedik sey yaratma" vaadini dogrudan destekliyor. ColorChef genislemesi, trade-off ogretimi ve kombo motivasyonu, oyuncunun "daha derine inebiliyorum" hissini guclendiriyor.

### B.2 UI/UX Tasarimi

**Puan: 4.2 / 5.0** (onceki: 4.1)

**Guclu Yonler:**
- Design system temelleri iyi: `UIConstants` (border radius skalasi), `Spacing` (8 kademe), `AppTextStyles` (semantik tipoloji), `AnimationDurations` (16+ named sabit). Magic number kullanmayan tutarli bir sistem.
- WCAG AA kontrast matrisi 53+ renk cifti icin dokumante edilmis — erisilebilirlik teknik borc degil, tasarim karari.
- Tema destegi (dark/light/system) duzenli implement edilmis. `resolveColor()` helper ile tema-agnostic renk kullanimi.
- Responsive layout 3 breakpoint ile phone/tablet/desktop destekli.
- RTL destegi 13 ekran + 2 widget'ta kapsamli.
- Semantics widget'lari 33+ dosyada, 44dp minimum tap target testi.
- Light tema kontrast sorunlari cozuldu: 6 renk koyulastirildi, tumu WCAG AA PASS (4.5:1+).
- HomeScreen bilgi hiyerarsisi iyilesti: DailyBanner kompakt tek satir, QuickPlayBanner padding azaltildi.
- Grid hucre radius arttirildi (4→6px): Daha yumusak kenarlar, jel tematigine uyumlu.
- Mod flavor text'leri ("Free Creation", "Color Kitchen" vb.) mod kartlarina dunya dili alt basliklari ekledi — UI artik yalnizca fonksiyonel degil, atmosferik.
- "ELO" → "Power/Guc" donusumu tum UI'da (leaderboard, PvP lobby, duel result) — teknik jargon yerine dunya diline gecis.

**Zayifliklar:**
- HomeScreen'de 7 bilgi katmani (streak, quest, meta-game, daily, mode cards, quick play, bottom bar) — gorsel agirlik dagilimlari dengeli ama bilgi yuku hala yuksek.
- Satir temizleme ve cascade anlarinda gorsel kutlama (burst efekti intensity scaling ile iyilesti) hala sentez aninin seviyesine erisemedi.

**Duygusal Vaatle Uyum**: Yuksek. Flavor text ve Power donusumu, UI'nin "dunya hissi veren arayuz" yonunde ilerledigini gosteriyor. Sentez glow + pulse, "ozel an" hissini destekliyor. Burst intensity scaling ile coklu temizleme anlari da artik gorsel olarak "buyuk" hissettiriyor.

### B.3 Ses Tasarimi

**Puan: 4.2 / 5.0** (onceki: 4.2)

**Guclu Yonler:**
- 32 SFX dosyasi, %100 tetikleme orani — her oyun olayinin bir sesi var. Sifir "sessiz an" yok.
- SoundBank mimarisi temiz: 19 metod, her biri duygusal olarak adlandirilmis (`onGelPlaced`, `onSynthesis`, `onGameOver`).
- Ses frekans haritasi dokumante edilmis — jel yerlestirme 200-400Hz temel, sentez bubble merge 150-300Hz → 800Hz pitch slide, kombo artan arpeggio. Bilincli sonic tasarim.
- Adaptif muzik 4 katmanda: (1) Grid doluluk bazli relax→tension gecisi, (2) son saniyelerde tempo artisi, (3) epic kombo volume swell, (4) buyuk olaylarda music ducking. AAA seviyesinde adaptif ses mimarisi.
- Cascade pitch escalation: her cascade adiminda `1.0 + (step-1) * 0.08`, cap 1.3x — zincirleme temizlemenin artan heyecanini sesle destekliyor.
- Haptic entegrasyon: 14 profil, tam implementasyon. Ses + dokunma senkronizasyonu.
- Pitch varyasyonu (0.92-1.08x) tekrar hissini azaltiyor.
- Platform-aware format (.ogg Android + .m4a iOS/Web).
- AudioPackage sistemi: `standard`, `crystalAsmr`, `deepForest` enum'lari tanimli. Runtime'da ses paketi degistirilebilir. Fallback mekanizmasi mevcut. Altyapi hazir, icerik bekliyor.

**Zayifliklar:**
- 4 muzik parcasi yeterli degil — uzun oturumlarda tekrar edilebilir. Kisa loop'lar fark edilir tekrar yaratir.
- AudioPackage icin gercek ses dosyalari henuz uretilmemis — altyapi mevcut, icerik bekliyor.
- Mod bazli muzik yalnizca 4 slot: menu_lofi, game_relax, game_tension, zen_ambient. 7 mod var ama 4 muzik — ColorChef ve Level modu kendi sonic kimligini bulamiyor.

**Duygusal Vaatle Uyum**: Yuksek. Ses tasarimi oyunun en tutarli disiplini. AudioPackage sistemi gelecekte ses kisisellestirilmesi ile "kendi dunyami yaratiyorum" hissini destekleyecek.

### B.4 Sanat Yonu / Gorsel Kimlik

**Puan: 3.8 / 5.0** (onceki: 3.5)

**Guclu Yonler:**
- Renk paleti bilincli: 12 jel rengi birbirinden ayirt edilebilir, WCAG kontrastlari dokumante edilmis ve PASS.
- Dark-first tasarim dogru karar — neon renkler koyu zeminde parliyor.
- Logo tasarimi akilli: "Gl" cyan + "oo" pembe, neon glow efekti. Marka renklerini tanitma araci.
- `GlowOrb` dekoratif eleman — atmosferik derinlik ekliyor.
- Mod bazli renk kodlamasi (Classic=kirmizi, ColorChef=yesil, TimeTrial=sari, Zen=mor) — gorsel navigasyona yardimci.
- GelCellPainter — 6 katmanli jel render: Dis glow, radial gradient govde, ince kenar parlama, specular highlight (nefes animasyonlu), alt kenar golgesi, ic parlama noktasi.
- Sentez glow efekti: `isGlowing: true` ile sentez aninda specular alpha 0.90, dis glow blur 6→12. SynthesisPulseCell ile 300ms scale pulse.
- Grid hucre radius 4→6px: Daha yumusak kenarlar, jel tematigine uyumlu.
- QuantizedBreathListenable: Nefes animasyonunu ~20fps'e kuantize ederek performans koruyan optimizasyon.
- Squash-bounce yerlestirme entegrasyonu tamamlandi (CD.23): `isRecentlyPlaced` ile specular Y +5% kayma, glow alpha +10%, ic parlama +30% buyume. Nefes animasyonuyla module. "Jel basildginda ic isik yayilir" hissi somut.
- Satir temizleme intensity scaling (CD.30): CellBurstEffect'e `intensity` parametresi. 2+ satir → 1.5x, 4+ satir → 2.0x parcacik/flash. Gorsel geri bildirim artik "buyukluk" iletiyor.
- Onboarding InteractivePlaceDemo'ya atmosferik derinlik (CD.25): 3 GlowOrb (kCyan, kPink, kGold), yerlestirilen hucrelere ambient glow shadow, "Harika!" metni kGold + glow shadow. Ilk temas noktasi artik "karanlik lab" hissini tasiyor.

**Zayifliklar:**
- **Karakter/maskot hala yok**: 8 GelPersonality arketipi var ama gorsel karsiligi yok. Text bazli kisilik chip'leri mevcut — gorsel karakter tasarimi harici kaynak bekliyor.
- **Ilustrasyon / asset sayisi dusuk**: Ada ekrani, karakter ekrani, season pass — hicbirinde ozel ilustrasyon yok.
- **Ada gorseli yok**: IslandScreen fonksiyonel (5 bina, upgrade, pasif uretim) ama gorsel icerigi yok.

**Duygusal Vaatle Uyum**: Orta-yuksek. GelCellPainter + squash-bounce ile "jel" hissi artik yalnizca gorunumde degil, harekette de var. Intensity scaling ile buyuk temizleme anlari gorsel olarak "buyuk" hissediyor. Onboarding'in atmosferik derinligi, oyuncunun ilk aninda "bu dunya ozel" hissini kuruyor. Karakter ve ada gorsellerinin yoklugu gorsel kimligin %100'e ulasmasi icin ana engel.

### B.5 Anlati / Dunya Insasi

**Puan: 3.2 / 5.0** (onceki: 2.5)

**Mevcut Durum:**
- Ada sistemi 5 binayla tanimlanmis, HomeScreen'den erisilir, core loop'a bagli (game over → pasif uretim tick).
- Karakter kisilik sistemi: 8 sentez rengi = 8 GelPersonality arketipi. 12 dilde lokalize.
- MetaGameBar HomeScreen'de: Ada, Karakter, Season Pass navigasyonu aktif.
- Season Pass "sezonluk liman" temasiyla tanimlanmis — tier icerikleri hala bos.
- Onboarding lore sayfasi (CD.21): 5 sayfalik onboarding akisinda 2. sayfa dunya tanitimi — "Renklerin canli oldugu bir dunyada, birlestiklerinde yeni bir sey doguyor. Yerlestirdigin her damla bir hikaye yaziyor." Minimal ama etkili. Monument Valley yaklasimi: az soyle, cok hissetir.
- Loading screen ipuclari: `kWorldTips` ile dunya ile iliskili tipler tanimli.
- Mod flavor text'leri (CD.31): Her mod isminin altinda dunya dili alt basligi — "Classic" → "Free Creation", "ColorChef" → "Color Kitchen", "Zen" → "Inner Calm", "TimeTrial" → "Against the Clock", "Daily" → "Today's Puzzle", "Level" → "The Journey", "Duel" → "Prove Yourself". 12 dilde lokalize. UI artik yalnizca fonksiyonel degil, hikaye anlatmaya basliyor.
- "ELO" → "Power/Guc" donusumu (CD.31): Teknik jargon yerine dunya dili. Leaderboard, PvP lobby, duel result — tum UI'da tutarli.
- Sentez-temizleme trade-off toast'i (CD.22): "Sentez satirdaki renkleri degistirir — satirlarini planla!" — oyunun en derin mekanik catismasini oyuncuya ogretmekle kalmiyor, ayni zamanda "bu dunyada renkler canli ve sonuc yaratir" hissini destekliyor.
- Epic kombo yaklasim motivasyonu (CD.29): "Neredeyse — zinciri surdur, Epic kombo!" — oyunun sesini gosteriyor: cesaretlendirici, asiri heyecanli degil, oyuncuyla birlikte.

**Zayifliklar:**
- Ada/Karakter/Season Pass gorsel olarak ham — ekranlar fonksiyonel ama ilustrasyon, animasyon ve atmosfer icin harici sanat kaynagi gerekiyor.
- "Neden jeller var?" sorusu lore sayfasiyla kismen cevaplanmis ("renklerin canli oldugu bir dunya") ama derinlestirilmemis. Bu bilinçli bir secim olabilir — Fumito Ueda modeli aciklamak yerine hissettirmektir.

**Duygusal Vaatle Uyum**: Orta (onceki: dusuk-orta). Lore sayfasi, flavor text'ler, Power donusumu ve ogretici toast'lar birlikte "sessiz bir dunya" kuruyorlar. "Sifir anlati" durumu artik tamamen gecmiste. Ton tutarliligi onemli bir adim — teknik dil ile dunya dili arasindaki kopukluk azaliyor. Kalan mesafe buyuk olcude gorsel anlati (ilustrasyon, karakter, ada atmosferi) gerektiriyor.

---

## C. Drift Denetimi — Vizyon Sapmasi Analizi

### C.1 Orijinal Vizyon vs. Mevcut Durum

Gloo'nun kod tabanindaki izlerden cikarilan orijinal vizyon:

> Renkli jeller, kendi adalari, karakterleri ve sezonlari olan bir dunyada yasayan, sesle ve dokunusla zenginlestirilmis, yaratici bir puzzle deneyimi.

Mevcut durum (v0.3):

> Mekanik olarak derin, gorsel kimligi somutlasmis, dunya hissinin ilk katmanlarini (lore, ton, flavor) kurmaya baslamis, harici gorsel icerik uretildiginde vizyonun tamamlanmasina yakin bir puzzle oyunu.

### C.2 Drift Haritasi

| Alan | Orijinal Yon | Mevcut Yon | Sapma Siddeti | Degisim |
|------|-------------|------------|---------------|---------|
| Oyun Tasarimi | 7 mod + meta-game + ekonomi | 7 mod calisiyor, meta-game bagli, ColorChef 40 bolum, ogretici toast'lar | Dusuk | Sabit (Dusuk) |
| Ses Tasarimi | ASMR-bazli sonic kimlik, frekans haritali | Iyi SFX + adaptif muzik + AudioPackage altyapisi, icerik bekliyor | Dusuk-Orta | Sabit (Dusuk-Orta) |
| Gorsel Kimlik | Jel tematigi, ada dunyasi, karakter | GelCellPainter + squash-bounce + intensity scaling + onboarding glow — ama ada/karakter illust. yok | Orta-Dusuk | Iyilesti (Orta → Orta-Dusuk) |
| Anlati / Ton | Dunya, karakter, sezon anlatisi | Lore sayfasi, flavor text'ler, Power donusumu, ogretici toast'lar — gorsel anlati yok | Orta | Iyilesti (Orta-Yuksek → Orta) |
| UI/UX | — | Fonksiyonel, erisilebilir, atmosferik flavor text, tutarli terminoloji | Dusuk | Iyilesti (Dusuk → Dusuk) |

### C.3 Drift Nedeni

v0.2'den bu yana yapilan calismalar iki ana kolda drift'i azaltti:

**Gorsel kimlik derinlesmesi:**
1. Squash-bounce yerlestirme (CD.23) → jel hareketi somut
2. Satir temizleme intensity scaling (CD.30) → buyuk anlar gorsel olarak buyuk
3. Onboarding atmosferik derinlik (CD.25) → ilk temas noktasinda dunya hissi

**Ton ve anlati tutarliligi:**
1. Onboarding lore sayfasi (CD.21) → minimal dunya tanitimi
2. Sentez-temizleme trade-off ogretimi (CD.22) → mekanik derinlik iletimi
3. Epic kombo yaklasim motivasyonu (CD.29) → oyunun sesi somutlasti
4. Mod flavor text'leri + Power donusumu (CD.31) → teknik → dunya dili gecisi

Kalan drift'in ana nedeni degismedi: **harici kaynak bagimliligi**. Kod tarafinda yapilabileceklerin tamamina yakini tamamlandi. Kalan isler (ada ilustrasyonu, karakter gorseli, ek muzik parcalari, ses paketi icerikleri, season pass tier odulleri) sanat ve ses uretimi gerektiriyor.

### C.4 Kurtarilabilir mi?

Evet — ve "kurtarma" artik dogru terim degil. Gloo, vizyonun teknik ve mekanik katmanlarini tamamlamis, gorsel ve atmosferik katmanlarini somutlastirmaya baslamis durumda. "Devlerin iskeleti gorunuyor, yuzleri bekleniyor" — gorsel icerik (karakter ilustrasyonu, ada gorseli, ek muzik/ses) uretildiginde vizyon tamamlanmis olacak.

---

## D. Yaratici Guc/Zayiflik Matrisi

### D.1 Disiplin Bazli Puanlama

| Disiplin | Puan | Onceki | Degisim | Guc | Zayiflik |
|----------|------|--------|---------|-----|----------|
| Oyun Tasarimi | 4.7/5.0 | 4.5 | +0.2 | Sentez, 7 mod, merhamet, 17 gorev, ada core loop, ColorChef 40 bolum, ogretici toast'lar | Epic kombo mekanik bariyeri |
| UI/UX | 4.2/5.0 | 4.1 | +0.1 | Design system, a11y, WCAG PASS, tema/RTL/l10n, flavor text, Power terminoloji | HomeScreen bilgi yogunlugu |
| Ses Tasarimi | 4.2/5.0 | 4.2 | — | Adaptif muzik, cascade pitch, SFX kapsam, AudioPackage altyapisi | Muzik cesitliligi, icerik bekliyor |
| Gorsel Kimlik | 3.8/5.0 | 3.5 | +0.3 | GelCellPainter + squash-bounce, intensity scaling, onboarding glow, renk paleti | Karakter gorseli yok, ada illust. yok |
| Anlati / Dunya | 3.2/5.0 | 2.5 | +0.7 | Lore sayfasi, flavor text, Power donusumu, ogretici toast'lar, kisilik arketipleri | Gorsel anlati yok, ada atmosferi yok |

**Genel Yaratici Skor: 4.0 / 5.0** (onceki: 3.8, degisim: +0.2)

Puan artisi en belirgin Anlati/Dunya (+0.7) ve Gorsel Kimlik (+0.3) disiplinlerinde. Oyun Tasarimi 4.7 ile tavana yaklasti — kalan iyilestirmeler ince ayar niteliginde. Ses Tasarimi sabit kaldi cunku bu sprintte ses icerigi eklenmedi. UI/UX minimal artti; flavor text ve terminoloji tutarliligi, islevsel UI'dan atmosferik UI'ya gecisi baslatti.

### D.2 Capraz Disiplin Sinerjileri

**Guclu sinerjiler:**
- **Ses + Oyun Tasarimi**: Mukemmel entegrasyon. Her game callback'in bir SoundBank metodu var. Cascade pitch + kombo tier SFX, mekanik derinligi sesle dogruluyor.
- **UI/UX + Oyun Tasarimi**: Per-cell rebuild izolasyonu, preview-time line completion hint, nearly-full-row highlight — UI, oyun durumunu anlamli sekilde iletir.
- **Erisilebilirlik + Tum Disiplinler**: Renk koru, reduce motion, RTL, semantics, dinamik font — tutarli erisilebilirlik vizyonu.
- **Gorsel + Ses + Oyun Tasarimi sentez aninda**: Sentez olustugunda es zamanli (1) GelCellPainter glow render, (2) SynthesisPulseCell scale pulse, (3) SoundBank.onSynthesis sesi, (4) synthesisGlowCells 600ms timer ile koordine. Uc disiplin tek bir "ozel an" uretmek icin senkronize calisiyor.
- **Gorsel + Oyun Tasarimi yerlestirme aninda** (yeni): Squash-bounce (specular kayma + glow artisi + ic parlama buyumesi) + SoundBank.onGelPlaced sesi + haptic geri bildirim. Yerlestirme artik "gorsel + sessel + dokunsal" bir buten.
- **Gorsel + Oyun Tasarimi temizleme aninda** (yeni): CellBurstEffect intensity scaling (2+ satir → 1.5x, 4+ → 2.0x) + cascade pitch escalation + staggered SFX. Buyuk temizlemeler gorsel ve sessel olarak "buyuk" hissediyor.
- **Anlati + UI/UX ton tutarliligi** (yeni): Flavor text'ler + Power donusumu + ogretici toast'lar, tum UI'da tutarli bir "dunya dili" kurmaya basliyor. Oyunun sesi — cesaretlendirici, saygiyla — artik hem metin hem gorsel hem ses uzerinden tutarli.

**Kalan surtusmeler:**
- **Anlati vs. Gorsel**: Lore sayfasi ve flavor text'ler "bir dunya var" diyor ama gorsel (ada, karakter, ilustrasyon) bu dunyayi gosteremiyor. Metin anlatiyor, goz aramiyor — bu catisma harici gorsel icerikle cozulecek.
- **Ses icerigi vs. Ses altyapisi**: AudioPackage swap sistemi hazir ama crystalAsmr/deepForest paketleri icin ses dosyalari yok.

### D.3 Tutarlilik Degerlendirmesi

Gloo'nun disiplinler arasi olgunluk esitsizligi daralmaya devam etti:

| Disiplin | v0.1 Olgunluk | v0.2 Olgunluk | v0.3 Olgunluk |
|----------|---------------|---------------|---------------|
| Oyun Tasarimi | ~%80-85 | ~%88-90 | ~%92-94 |
| Ses Tasarimi | ~%80 | ~%84 | ~%84 |
| UI/UX | ~%75 | ~%82 | ~%84 |
| Gorsel Kimlik | ~%55 | ~%70 | ~%76 |
| Anlati / Dunya | ~%30 | ~%50 | ~%64 |

En yuksek ile en dusuk arasindaki fark: v0.1'de 55 puan, v0.2'de 40 puan, v0.3'te 30 puan. Esitsizlik daralmaya devam ediyor. Kalan kapatma buyuk olcude harici kaynak (sanat, ses icerigi, muzik) gerektiriyor.

---

## E. Stratejik Oneriler

### E.1 Tamamlanan Oneriler

| # | Eylem | Durum | Notlar |
|---|-------|-------|--------|
| CD.1 | Meta-game UI'yi ac — MetaGameBar HomeScreen'e | TAMAMLANDI | Ada, Karakter, Season Pass navigasyonu aktif |
| CD.2 | Sentez anini gorsel + sessel vurgula | TAMAMLANDI | synthesisGlowCells + 600ms timer + glow render |
| CD.3 | Grid hucrelerine minimal jel gorunumu | TAMAMLANDI | GelCellPainter (6 katman) + radiusXs 4→6px |
| CD.4 | Light tema kontrast duzeltmesi | TAMAMLANDI | 6 renk koyulastirildi, tumu WCAG AA PASS |
| CD.5 | HomeScreen bilgi hiyerarsisi sadele | TAMAMLANDI | DailyBanner kompakt, QuickPlayBanner padding azaltildi |
| CD.6 | Jel gorsel kimligi olustur | TAMAMLANDI | GelCellPainter isGlowing + SynthesisPulseCell 300ms pulse |
| CD.10 | Gorev sistemi genisletme | TAMAMLANDI | 12 gunluk + 5 haftalik, ISO week reset |
| CD.11 | Push notification entegrasyonu | TAMAMLANDI | FirebaseNotificationService, 3 senaryo, FCM token sync, 12 dil |
| CD.12 | Maskot/karakter kisilik sistemi | KOD TAMAMLANDI | 8 GelPersonality, 12 dil — gorsel tasarim bekliyor |
| CD.13 | Ada sistemi entegrasyonu | KOD TAMAMLANDI | Core loop baglantisi, pasif uretim, exponential cost |
| CD.14 | Sosyal/viralite katmani | KOD TAMAMLANDI | Wordle emoji grid, shareCollection — gorsel asset bekliyor |
| CD.15 | ASMR ses paketleri | ALTYAPI TAMAMLANDI | AudioPackage enum + swap + fallback — ses dosyalari bekliyor |
| CD.21 | Onboarding lore sayfasi | TAMAMLANDI | 5 sayfalik onboarding (3 tanitim + 1 lore + 1 tercih). "Renklerin canli oldugu bir dunyada..." 12 dil. kWorldTips loading tip'leri |
| CD.22 | Sentez-temizleme trade-off ogretimi | TAMAMLANDI | Oyun 3-8'de sentez olustugunda "Sentez satirdaki renkleri degistirir — planla!" toast (2 gosterim). tipShownCount pattern |
| CD.23 | GelCellPainter squash-bounce entegrasyonu | TAMAMLANDI | `isRecentlyPlaced`: specular Y +5%, glow alpha +10%, ic parlama +30%. Nefes animasyonuyla module. "Jel basildginda ic isik yayilir" |
| CD.24 | ColorChef 20→40 bolum | TAMAMLANDI | 20 yeni recete. 21-25 rotation, 26-30 rare, 31-35 high-pressure, 36-40 master. Sonlu mod sorunu cozuldu |
| CD.25 | Onboarding dunya hissi | TAMAMLANDI | InteractivePlaceDemo'ya 3 GlowOrb (kCyan, kPink, kGold), ambient glow shadow, "Harika!" kGold + glow |
| CD.29 | Epic kombo yaklasim motivasyonu | TAMAMLANDI | Large tier combo (6+) "Neredeyse — zinciri surdur, Epic!" toast (3 gosterim). tipShownCount pattern |
| CD.30 | Satir temizleme intensity scaling | TAMAMLANDI | CellBurstEffect intensity parametresi. 2+ satir → 1.5x, 4+ → 2.0x parcacik/flash/spread |
| CD.31 | Ton tutarliligi | TAMAMLANDI | Mod flavor text'leri (12 dil), "ELO" → rankLabel ("Power"/"Guc") tum UI'da |

### E.2 Guncel Oneriler — Harici Kaynak Gerektiren

| # | Eylem | Etki | Bagimlilk | Mevcut Altyapi |
|---|-------|------|-----------|----------------|
| CD.16 | **Karakter gorsel tasarimi** — 8 GelPersonality icin jel bazli karakter ilustrasyonlari (min. bust/avatar) | Cok Yuksek | Gorsel sanatci / ilustrator | `GelPersonality` enum, `CharacterScreen`, l10n tamam |
| CD.17 | **Ada ilustrasyonlari** — 5 bina gorseli + ada arka plan + upgrade animasyonlari | Yuksek | Gorsel sanatci / ilustrator | `IslandState`, `IslandScreen`, bina tanimlari tamam |
| CD.18 | **Ses paketi icerikleri** — crystalAsmr ve deepForest icin SFX dosyalari (32 x 2 paket) | Orta-Yuksek | Ses tasarimcisi | `AudioPackage` enum, `setAudioPackage()`, fallback tamam |
| CD.19 | **5-8 ek muzik parcasi** — Her mod icin en az 1 ozel loop | Yuksek | Muzik bestecisi | `AudioManager`, mod bazli muzik sistemi tamam |
| CD.20 | **Season Pass tier icerikleri** — 50 tier odul tablosu, gorsel oduller | Yuksek | Icerik tasarimi + gorsel sanatci | Season pass XP sistemi, tier altyapisi tamam |

### E.3 Vizyon Genisletme (Uzun Vade)

| # | Eylem | Etki | Gerekce |
|---|-------|------|---------|
| CD.26 | **Sezonsal icerik dongusu** — Season Pass tier odulleri + sezonsal tema (renk paleti, ses, ada dekorasyonu) | Cok Yuksek | Uzun vadeli retention. Altyapi hazir, icerik ve gorsel uretim dongusu gerekli |
| CD.27 | **Sosyal ozellikler** — Arkadas listesi, duel davet, skor karsilastirma | Yuksek | Organik buyume icin en etkili kanal. PvP altyapisi mevcut |
| CD.28 | **Adaptif zorluk** — Oyuncu performansina gore dinamik RNG kalibrasyonu | Orta | Merhamet sistemi reaktif, proaktif degil. Oyuncu profillemesi ile onleyici dengeleme |

---

## F. Ton ve Marka Rehberi Taslagi

### F.1 Duygusal Koordinat Sistemi

```
          SICAK
           |
           |
     ......*..........  <- Gloo burada: sicak-yakin ama
           |              buyulu degil, tanidik
           |
OYUNBAZ ---+--- CIDDI
           |
           |
           |
          SOGUK
```

```
          UMUT
           |
      .....*..........  <- Gloo burada: umutlu ama
           |              naif degil, zorluk var
           |
RAHAT  ----+---- GERGIN
           |
           |
           |
         KARANLIK
```

Gloo'nun tonu: **sicak, oyunbaz, umutlu ama naive degil**. Oyuncu zorlanabilir ama asla umutsuz hissetmemeli. Merhamet sistemi bunu mekanik olarak destekliyor — tonun da bunu yansitmasi gerekiyor.

### F.2 Oyunun Sesi

Gloo bir insan olsaydi: **merakli ve cesaretlendirici bir laboratuvar arkadasi**. Ne ukala bir ogretmen, ne asiri heyecanli bir sunucu. "Bak ne oldu!" der, "MUHTESEM!" diye bagirmaz. Suskunlugu bilir — oyuncunun kendi kesfinin tadini cikarmasi icin geri cekilir.

- **Tempo**: Orta — ne acele ne yavas. Puzzle'in dusunme ritmini bozmaz.
- **Kelime secimi**: Basit, sicak, teknik degil. "Sentez olusturuldu" degil, "yeni renk!" veya sadece gorsel/sessel geri bildirim.
- **Suskunluk**: Aktif kullanim — tutorial bittikten sonra oyun konusmaz, gosterir. Fumito Ueda yaklasimi.

CD.29'daki epic kombo yaklasim toast'i bu sesin somut bir ornegi: "Neredeyse — zinciri surdur!" — cesaretlendirici, sakin, oyuncuyla birlikte. "MUHTESEM! DEVAM ET!!!" degil.

CD.31'deki flavor text'ler bu sesin UI'daki yansimasi: "Free Creation", "Color Kitchen", "Inner Calm" — her biri tek iki kelimeyle bir his anlatir. Aciklamak yerine cagiristirma.

### F.3 Renk ve Isik Dili

**Bu dunyaya ait:**
- Koyu mavi-siyah zemin (0xFF010C14) — derin uzay veya okyanus dibi hissi. Jellerin parlayacagi karanlik.
- Neon-parlak jel renkleri — canli, doygun, isik yayan gorunumde. GelCellPainter'in specular highlight'i ile yuzey gerilimi yansimasi.
- Cyan (0xFF00E5FF) — marka rengi, UI aksani, navigasyon.
- Yumusak glow efektleri — dis glow katmani ile isigin jel icerisinde dagilmasi.
- Gradient gecisler — radial gradient govde ile sert kenarlar yerine yumusak gecisler.
- Nefes animasyonu — hucreler canli, statik degil. Specular ve parlama noktasi ritmik olarak modulate oluyor.
- Yerlestirme isik yayilimi — squash-bounce aninda specular kayma + glow alpha artisi + ic parlama buyumesi. "Jel basildginda ic isik yayilir."
- Onboarding atmosferik derinlik — GlowOrb'lar (kCyan, kPink, kGold) + ambient glow shadow. Ilk temas noktasindan itibaren "karanlik lab" hissi.
- Temizleme patlamasi — intensity scaling ile buyuk temizlemeler gorsel olarak buyuk (2+ satir → 1.5x, 4+ → 2.0x parcacik/flash).

**Bu dunyaya ait OLMAYAN:**
- Beyaz veya gri arka plan (oyun ekraninda)
- Sert, metalik, keskin gorsel ogeler
- Karikaturize, cizgi film tarzi ilustrasyonlar
- Fotorealistik dokular
- Pixel art

### F.4 Ses Karakteri

**Organik-sentetik hibrit**. Jel sesleri organik (squelch, bubble, splash) + sentez aninda sentetik harmonik katman (arpeggio, chime). AudioPackage sistemiyle gelecekte 3 farkli sonic kisilik sunulabilir:

- **Standard**: Organik-sentetik hibrit (mevcut)
- **Crystal ASMR**: Cam/kristal vuruslari, yuksek frekans tatmin sesleri
- **Deep Forest**: Dogal, topraga yakin, derin rezonansli sesler

Mevcut ses profili:
- **Jel yerlestirme**: Yumusak, tatmin edici "tuk" — 200-400Hz (iyi)
- **Sentez**: Buyulu gecis — bubble merge + ascending harmonic + gorsel glow senkronizasyonu (cok iyi)
- **Satir temizleme**: Crystal chime sweep — temizlik ve basari (iyi)
- **Kombo zinciri**: Artan enerji — her tier daha genis frekans araligi (cok iyi)
- **Game over**: Yumusak, uzun — cezalandirici degil, "bir dahaki sefere" hissi (iyi)
- **Ambiyans**: Lofi-dreamy — menu'de rahatlatici, oyun icinde konsantrasyon destekleyici (iyi)

### F.5 Hareket ve Ritim

- **Genel tempo**: Orta — ne frenetik ne uyusuk. Bulmaca dusunme suresiyle uyumlu.
- **Yerlestirme**: Hizli ve kesin (80ms settle) + squash-bounce ile "jel basildginda ic isik yayilir" — specular Y +5%, glow alpha +10%, ic parlama +30%. Nefes animasyonuyla module.
- **Sentez**: 300ms scale pulse (SynthesisPulseCell, cap 1.08) + 600ms glow suresi. Yavas ve buyulu — ozel an, acele etme.
- **Temizleme**: Orta hizda, staggered (35ms/cell) — her hucrenin ayri ayri kaybolmasi. Intensity scaling: 2+ satir → 1.5x, 4+ → 2.0x parcacik/flash. Buyuk temizlemeler "buyuk" hissediyor.
- **Cascade**: Hizlanan ritim — her adim bir oncekinden daha hizli. Domino etkisi.
- **Nefes**: Tum hucreler senkronize nefes animasyonu — specular highlight ve parlama noktasi ritmik modulate. QuantizedBreathListenable ile ~20fps'e kuantize (performans).
- **UI gecisleri**: Yumusak fade+scale (fadeScaleTransition 96%→100%) — uygun.

### F.6 Dunya Dili ve Ton Tutarliligi

Gloo'nun UI'si artik iki katmanli bir dil kullaniyor:

**Fonksiyonel katman** (navigasyon, teknik bilgi): Net, kisa, evrensel. "Score", "Level", "Settings".

**Atmosferik katman** (dunya hissi, duygusal baglanti): Sicak, cagiristirici, minimal. Mod flavor text'leri ("Free Creation", "Color Kitchen", "Inner Calm"), lore metni ("Renklerin canli oldugu bir dunyada..."), terminoloji secimleri ("Power" vs. eski "ELO").

Bu iki katmanin kurali: **fonksiyonel katman asla atmosferik katmanla catismamali**. "ELO" → "Power" donusumu bu kuralın somut ornegi — teknik terim dunya diline cevrildi, islevsellik korundu.

Ogretici toast'lar bu iki katmanin ortasinda duruyor: bilgi veriyorlar (fonksiyonel) ama oyunun sesiyle konusuyorlar (atmosferik). "Sentez satirdaki renkleri degistirir — planla!" — aciklayici ama sicak.

### F.7 Neyin Bu Dunyaya Ait Olmadiginin Listesi

- Agresif reklamcilik dili ("SATIN AL!", "SINIRLI SURE!", "KACIRMA!")
- Cezalandirici ton ("Kaybettin!", "Basarisiz!")
- Asiri bildirim/pop-up bombardimani
- Hiz bazli baskili UI animasyonlari
- Karikaturize karakterler veya maskotlar (eger maskot yapilacaksa: minimal, soyut, jel-bazli — GelPersonality arketipleriyle uyumlu)
- Gereksiz yere karmasik menu yapilari
- Skeuomorfik UI elementleri
- Teknik jargon oyuncu-facing UI'da ("ELO", "matchmaking", "RNG") — dunya diline cevrilmeli

---

## G. Kalan Isler — Harici Kaynak Haritasi

Kod tarafinda yapilabileceklerin tamamina yakini tamamlandi. Asagidaki tablo, vizyonun tamamlanmasi icin harici kaynak gerektiren isleri oncelik sirasina gore listeler:

| Oncelik | Is | Gereken Kaynak | Mevcut Altyapi |
|---------|------|----------------|----------------|
| 1 | Karakter ilustrasyonlari (8 GelPersonality) | Gorsel sanatci | GelPersonality enum, CharacterScreen, l10n |
| 2 | Ada ilustrasyonlari + bina gorselleri | Gorsel sanatci | IslandState, IslandScreen, 5 bina tanimi |
| 3 | Ek muzik parcalari (5-8 adet, mod bazli) | Muzik bestecisi | AudioManager, mod bazli muzik sistemi |
| 4 | Ses paketi icerikleri (crystalAsmr, deepForest) | Ses tasarimcisi | AudioPackage enum, swap mekanizmasi, fallback |
| 5 | Season Pass tier odulleri + gorseller | Icerik tasarimi + sanatci | Season pass XP sistemi, tier altyapisi |

**Test durumu**: 2151 gecen / 0 basarisiz — teknik borc sifir. Tum yeni ozellikler tam test kapsaminda.

---

## H. Sonuc — Yaratici Yonetmen Ozeti

### v0.2 → v0.3 Degisim Ozeti

Bu sprint "gorsel hissi derinlestir ve dunya dilini kur" odaginda ilerledi. 8 gorev tamamlandi:

1. **"Dunya tanitimi yok"** → Onboarding lore sayfasi (CD.21). "Renklerin canli oldugu bir dunyada, birlestiklerinde yeni bir sey doguyor." Monument Valley modeli: az soyle, cok hissetir.
2. **"Sentez-temizleme catismasi ogretilmemis"** → Trade-off toast (CD.22). Oyun 3-8'de, sentez olustugunda ogretici ipucu.
3. **"Jel yerlestirme hareketi eksik"** → Squash-bounce entegrasyonu (CD.23). Specular kayma, glow artisi, ic parlama buyumesi — "jel basildginda ic isik yayilir."
4. **"ColorChef sonlu"** → 40 bolume genisledi (CD.24). 4 tema bandinda artan zorluk.
5. **"Onboarding atmosferik degil"** → GlowOrb'lar + ambient glow (CD.25). Ilk temas noktasinda "karanlik lab" hissi.
6. **"Epic kombo ulasilamaz hissettiriyor"** → Yaklasim motivasyon toast'i (CD.29). Psikolojik bariyeri dusurme.
7. **"Temizleme anlari gorsel olarak duz"** → Intensity scaling (CD.30). 2+ satir → 1.5x, 4+ → 2.0x parcacik/flash.
8. **"Teknik dil ile dunya dili arasinda kopukluk"** → Ton tutarliligi (CD.31). Flavor text'ler, "ELO" → "Power" donusumu. 12 dil.

### Guncel Durum

Gloo artik **mekanik cekirdegi guclu, gorsel kimligi somut, dunya hissinin ilk katmanlarini kurmaya baslamis, ton tutarliligi saglayan bir oyun**. Kod tarafinda yapilabileceklerin tamamina yakini tamamlandi.

**Genel Yaratici Skor: 4.0 / 5.0** (onceki: 3.8)

Kalan 1.0 puanlik mesafe buyuk olcude **harici kaynak bagimliligi** tasiyor — karakter ilustrasyonlari, ada gorselleri, ek muzik, ses paketi icerikleri. Kod tarafinda altyapi hazir; beklenen icerik uretildiginde skor 4.5-4.7 araligina cikmasi makul.

### Oncelik Sirasi

1. **Karakter gorsel tasarimi** — 8 GelPersonality icin ilustrasyon → marka hatirlanabilirliginin #1 araci
2. **Ada ilustrasyonlari** — "evim" hissinin gorsel karsiligi
3. **Ek muzik + ses paketleri** — uzun oturum kalitesi ve kisisellestirilme
4. **Season Pass icerik dongusu** — uzun vadeli retention'in ana motoru

### Vizyon Notu

Gloo'nun kod tarafinda yapilabilecek yaratici iyilestirmeler tamamlanmis durumda. Onboarding lore sayfasi, squash-bounce, intensity scaling, flavor text'ler ve ton tutarliligi — bunlarin hepsi kodla yapilabilecek "atmosfer" isleriydi ve hepsi yapildi. Kalan mesafe gorsel ve sessel icerik uretimi gerektiriyor.

Bu asamada en dogru hareket: harici gorsel sanatci ile karakter ilustrasyonlarindan baslamak. 8 GelPersonality icin jel bazli, minimal, isik yayan karakter tasarimlari — bu, Gloo'nun "renklerin canli oldugu dunya" vaadini gorsel olarak tamamlayacak tek en etkili adim.

Gloo'nun motoru hazir, jeli parlıyor, sesi konusuyor, dunyasi fisildamaya basladi. Simdi o dunyaya yuz vermek kaliyor.

---

## Revizyon Gecmisi

| Ver. | Tarih | Ozet |
|------|-------|------|
| 0.1 | 2026-03-22 | Ilk taslak — tam kod tabani analizi |
| 0.2 | 2026-03-23 | Sprint sonuclari: GelCellPainter, MetaGameBar, gorev genislemesi, push notification, karakter kisilikleri, ada core loop, AudioPackage, light tema WCAG PASS, sentez glow, Wordle emoji share. Disiplin puanlari guncellendi. Drift analizi yeniden degerlendirildi. Harici kaynak haritasi eklendi. |
| 0.3 | 2026-03-23 | Yaratici derinlik sprinti: Onboarding lore sayfasi (CD.21), sentez trade-off ogretimi (CD.22), squash-bounce entegrasyonu (CD.23), ColorChef 40 bolum (CD.24), onboarding atmosferik derinlik (CD.25), epic kombo motivasyon toast (CD.29), temizleme intensity scaling (CD.30), ton tutarliligi — flavor text + Power donusumu (CD.31). Tum strikethrough notlar temizlendi. E.3 bolumu kaldirildi (kod tarafinda is kalmadi). Genel skor 3.8→4.0. |
