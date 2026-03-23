# Gloo Karakter Tasarim Briefi — 8 GelPersonality

**Versiyon:** 0.1 | **Tarih:** 2026-03-23 | **Yazar:** Sanat Yonetmeni
**Kapsam:** 8 sentez rengine karsilik gelen jel karakter kisiliklerinin gorsel tasarim yonu.

---

## I. Genel Stil Rehberi

### Gorsel Vaat

Bu karakterler "canli, parlak, nefes alan jel damlalari" dir — karikatur degil, maskot degil, insan degil. Her biri ayni malzemeden (jel) yapilmis ama farkli bir ic duyguyu tasir. Oyuncu bu karakterleri gordugunde "bunlar ayni maddenin farkli ruhlari" hissetmelidir.

### Stilistik Koordinatlar

```
Soyut ←————●———→ Figuratif        (merkezin hafif solunda)
Minimal ←——●————→ Detayli          (merkezin belirgin solunda)
```

Konum gerekceleri: Karakterler izgara hucresinden turetilmis soyut formlardir — insan anatomisi, hayvan referansi veya geleneksel maskot yaklasimi YOKTUR. Detay yogunlugu dusuk tutulur cunku bu formlar 36x36 piksellik on-izleme boyutuna kadar okunabilir olmalidir.

### Temel Form Sozlesmesi

Her karakter asagidaki yapiya uyar:

1. **Govde:** Yuvarlatilmis, jel kivaminda tek parca kutle. GelCellPainter'in 6 katmanli render dilini miras alir (dis glow, radyal degrade govde, kenar isigi, specular highlight, alt golge, ic parlama noktasi).
2. **Yuz:** Minimal — yalnizca gozler ve (bazi karakterlerde) agiz. Gozler beyaz specular noktalar veya basit geometrik acikliklardir, yuz cizgileri degil. Agiz varsa tek bir egri veya bosluktur.
3. **Ayirt Edici Ozellik (Signature):** Her karakteri diger yedisinden ayiran tek bir gorsel unsur — form varyasyonu, yuzey dokusu, hareket karakteri veya ic isik davranisi. Bu unsur siluet duzeyinde okunabilir OLMALIDIR.
4. **Olcek:** Tum karakterler ayni temel boyuttadir (izgara hucresi olcegi). Buyukluk farki kisilik ifadesi degil — form farki kisilik ifadesidir.

### Malzeme Sozlesmesi (Tum Karakterler Icin Gecerli)

GelCellPainter'in kurulu gorsel dilinden turetilen ortak malzeme kurallari:

- **Isik kaynagi:** Sol ust (Alignment -0.35, -0.35). Tum karakterlerde ayni yon — dunya tutarliligi.
- **Specular highlight:** Ust yuzde genis beyaz elips. Nefes animasyonuyla hafif hareket eder. Bu "jel yuzey gerilimi" nin gorsel kaniti — kaldirilmaz.
- **Dis glow:** Karakterin renginde yumusak isik halkasi. Bu "jel isik yayar" sozlesmesinin parcasi — kaldirilmaz.
- **Alt golge:** Govdenin altinda koyu egri. "Yuzeyden yukselme" illuzyonu — kaldirilmaz.
- **Ic parlama noktasi:** Specular merkezinde kucuk beyaz nokta. "Isik kirilan sivi malzeme" hissi — kaldirilmaz.
- **Nefes animasyonu:** Tum karakterler nefes alir (specular ve glow modülasyonu). Hiz ve genlik kisilige gore degisebilir ama yoklugu mumkun degildir — canli jel nefes alir.

### Renk Kurallari

Her karakterin renk paleti 3 katmanlidir:

| Katman | Islem | Kaynak |
|--------|-------|--------|
| **Ana ton** | GelColor.displayColor degeri | Degistirilemez — oyun mekanigi ile bagli |
| **Acik varyant** | HSL lightness +0.42 | Specular bolge ve govde parlak yuzu |
| **Koyu varyant** | HSL lightness -0.25 | Govde golge yuzu ve alt kenar |

Ek renk EKLENMEZ. Karakter paleti kendi jel renginin acik/koyu varyantlari + beyaz (specular) + siyaha yakin koyu (golge) ile sinirlidir. Bu kisitlama gorsel tutarliligin temelidir.

### Erisilebilirlik Taahhüdü

- Her karakter siluet ve form ile ayirt edilebilir olmalidir — yalnizca renge bagimli ayrim YASAKTIR.
- Renk koru modunda (colorblind) her karakterin govdesinde 2 harfli kisaltma (GelColor.shortLabel) gosterilir; tasarim bu etiketi engellememelidir.
- Koyu arka plan (0xFF010C14, L=0.0032) uzerinde tum ana tonlar WCAG AA buyuk grafik kriterini (3:1) karsilar — maroon (0xFF8B1A1A) ve brown (0xFF8B6914) en dusuk kontrastli ciftlerdir, bu karakterlerin dis glow'u diger karakterlerden %20 daha genis tutularak algi destegi saglanir.

---

## II. Karakter Briefleri

---

### 1. ORANGE — Maceraci

**Renk:** `0xFFFF7B3C` (sicak turuncu, L=0.4041)
**Sentez Formulu:** Red + Yellow
**Arketip:** Maceraci — ates + gunes enerjisi, ileriye donuk, heyecanli

#### Gorsel Kimlik Cumlesi
Ileri dogru egilen, hareketli, sicak isik yayan bir jel damlasi — duragan gorunse bile "birazdan bir yere firlayacak" hissi verir.

#### Siluet Tasarimi
- **Genel form:** Dairesel govde, ust kisimda hafif one dogru egim (yaklasik 8-10 derece). Bu egim "hareket niyeti" tasir — diger karakterlerin simetrik durusundan ayirir.
- **Ayirt edici ozellik:** Govdenin sag ust kosesinde kucuk, sivri bir "alev ucu" cikintisi. Tek parca jelden firlamis gibi — ayri bir ek degil, govdenin organik uzantisi. Siluette acikca okunur.
- **Kucuk boyut testi:** 36px olcekte one egim + sivri uç yeterli ayrim saglar.

#### Renk Paleti
| Rol | Deger | Kullanim |
|-----|-------|----------|
| Ana | `0xFFFF7B3C` | Govde orta tonu |
| Acik | HSL L+0.42 → sicak sari-turuncu | Sol ust parlak bolge |
| Koyu | HSL L-0.25 → koyu kehribar | Sag alt golge |

#### Yuz
- **Gozler:** Iki kucuk, beyaz, parlak daire — birbirine yakin, hafif one bakan. "Merakli ve heyecanli" ifade.
- **Agiz:** Kucuk, yukari kivrik yay. Acik degil — memnun bir gulums.

#### Animasyon Notlari (Gorsel Niyet)
- Nefes ritmi diger karakterlerden %15 daha hizli — "sabırsız enerji."
- Nefes sirasinda one egim hafifce artar/azalir — "ziplama hazirligi" hissi.
- Hareket ettikce alev ucu kisa bir gecikmeyle takip eder (follow-through prensibi).

#### Negatif Yon
- Gercek alev efekti veya parcacik cikisi OLMAYACAK — bu bir alev degil, jel.
- Cizgi film gozleri (buyuk iris, kirpik) OLMAYACAK.
- Maskot tarzi kol/bacak OLMAYACAK.

---

### 2. GREEN — Bilge

**Renk:** `0xFF3CFF8B` (neon yesil, L=0.7435)
**Sentez Formulu:** Yellow + Blue
**Arketip:** Bilge — doga, denge, dinginlik icinde otorite

#### Gorsel Kimlik Cumlesi
Merkezi sakin, dengeli, hafifce yukariya dogru uzanan bir jel damlasi — etraftaki kaosa ragmen kendi ekseninde duran bir varlik.

#### Siluet Tasarimi
- **Genel form:** Dikey olarak hafifce uzamis oval (boy/en orani ~1.15). Simetrik ve dengeli — "dikilis" hissi verir.
- **Ayirt edici ozellik:** Govdenin ic yapisinda, merkezden disa dogru yayilan 2-3 ince, acik ton cizgi — bir yaprak damarini veya bilgelik halkalarini cagristiran ic desen. Siluette gorunmez ama yakin bakista karakteri tanimlar.
- **Kucuk boyut testi:** 36px olcekte dikey uzamis oval yeterli — ic desen bu boyutta gorsel gurultuye donusmemeli, o nedenle 48px altinda basitlestirilir veya gizlenir.

#### Renk Paleti
| Rol | Deger | Kullanim |
|-----|-------|----------|
| Ana | `0xFF3CFF8B` | Govde orta tonu |
| Acik | HSL L+0.42 → neredeyse beyaz-yesil | Ust bolge parlaklik |
| Koyu | HSL L-0.25 → orman yesili | Alt golge |

#### Yuz
- **Gozler:** Yatay olarak hafifce daralmis iki beyaz form — "yarim kapali gozler" hissi. Meditasyon halinde ama tamamen kapali degil.
- **Agiz:** Yok. Sessizlik bilgeliktir.

#### Animasyon Notlari (Gorsel Niyet)
- Nefes ritmi en yavas karakter — derin, olculu, meditatif.
- Nefes sirasinda govde minimal hareket eder; specular highlight neredeyse sabit kalir.
- Ic desen cizgileri nefesle cok hafifce genisler/daralir — "ic enerji akisi."

#### Negatif Yon
- Bitki/yaprak gorunumu OLMAYACAK — bu bir bitki degil, jel.
- Surat ifadesi "bilmis/ukala" OLMAYACAK — bu sakin bir bilgelik, kibirli degil.
- Doga parcaciklari (yaprak, cicek) OLMAYACAK.

---

### 3. PURPLE — Gizemli

**Renk:** `0xFF8B3CFF` (elektrik moru, L=0.2201)
**Sentez Formulu:** Red + Blue
**Arketip:** Gizemli — derinlik, sezgi, bilinmeyen

#### Gorsel Kimlik Cumlesi
Kenarlarinda isik kiran, ic yapisi gorunmeyen, karanliktan dogan bir jel damlasi — yaklastikca daha fazla gorursun ama asla tamamen anlamazsin.

#### Siluet Tasarimi
- **Genel form:** Neredeyse mukemmel daire ama alt kisimda hafif dalgali, belirsiz bir kenar — "tam olarak nerede bittigi belli degil" hissi.
- **Ayirt edici ozellik:** Dis glow'un rengi normal mor degil, hafifce kirmiziya kayan bir varyant — diger karakterlerin kendi rengindeki glow'undan farkli olarak, bu karakterin glow'u "baska bir kaynaktan" geliyormus gibi hissettirir.
- **Kucuk boyut testi:** 36px olcekte dalgali alt kenar + farkli glow tonu ayrim saglar.

#### Renk Paleti
| Rol | Deger | Kullanim |
|-----|-------|----------|
| Ana | `0xFF8B3CFF` | Govde orta tonu |
| Acik | HSL L+0.42 → lavanta-beyaz | Specular bolge |
| Koyu | HSL L-0.25 → derin civciv | Alt golge — normalden daha koyu tutulur |
| Glow varyant | Hue +15 derece (kirmiziya kayan mor) | Yalnizca dis glow katmani |

**Not:** Glow varyant istisnai bir kural kirilimidir — yalnizca bu karakter icin gecerli. Gizemli arketipinin "kaynagi belirsiz isik" temasi bunu dramatik arac olarak gerekcelendirir.

#### Yuz
- **Gozler:** Tek bir yatay beyaz cizgi — iki goz degil, tek kesintisiz isik seridi. "Bu varligin gozleri mi yoksa baska bir sey mi?" belirsizligi.
- **Agiz:** Yok.

#### Animasyon Notlari (Gorsel Niyet)
- Nefes ritmi duzensiz — diger karakterlerin sinusoidal nefesinden farkli olarak, kisa duraklamalar iceren asimetrik bir ritim.
- Dalgali alt kenar nefesle hafifce dalgalanir — "sivi kenar" hissi.
- Glow rengi nefes dongusu boyunca cok yavas hue kaydirir (mor → kirmizi-mor → mor).

#### Negatif Yon
- Yildiz, ay veya kozmik sembol OLMAYACAK.
- Buyucu sapkasi / pelerin referansi OLMAYACAK — bu bir fantezi karakteri degil.
- Govde icinde gorunen "goz" veya "portal" OLMAYACAK — gizemlilik gosterilmez, hissettirilir.

---

### 4. PINK — Neseli

**Renk:** `0xFFFF3CAC` (sicak pembe, L=0.3171 civarinda)
**Sentez Formulu:** Red + White
**Arketip:** Neseli — enerji, sevgi, sicaklik, oyunculuk

#### Gorsel Kimlik Cumlesi
Hafifce ziplayan, yuvarlak, dolgun bir jel damlasi — odaya giren ve havay degistiren sicak enerji.

#### Siluet Tasarimi
- **Genel form:** Diger karakterlerden biraz daha tombul daire — boy/en orani ~0.92 (yatay olarak hafif genis). "Sicak, kucaklanasi" his.
- **Ayirt edici ozellik:** Govdenin ust kisminda iki kucuk, yuvarlak cikinti — "kulaklara" veya "antenlere" benzer ama jelden organik olarak cikan balonsu formlar. Siluette acikca iki nokta olarak okunur.
- **Kucuk boyut testi:** 36px olcekte tombul form + iki ust cikinti kesin ayrim saglar.

#### Renk Paleti
| Rol | Deger | Kullanim |
|-----|-------|----------|
| Ana | `0xFFFF3CAC` | Govde orta tonu |
| Acik | HSL L+0.42 → acik pembe-beyaz | Ust bolge, specular |
| Koyu | HSL L-0.25 → koyu gul | Alt golge |

#### Yuz
- **Gozler:** Iki buyukce (diger karakterlere kiyasla), yuvarlak beyaz parlama — "genis gozlerle bakma" ifadesi. Canlı ve ilgili.
- **Agiz:** Acik, yuvarlak kucuk bir bosluk — "O!" seklinde sasirmis/mutlu ifade. Surekli acik degil, animasyonda acilip kapanabilir.

#### Animasyon Notlari (Gorsel Niyet)
- Nefes ritmi ortalamadan %10 hizli — enerji dolu ama sabırsız degil (Orange kadar hizli degil).
- Nefes sirasinda govde belirgin sekilde genisler/daralir — "balonsu solunum."
- Iki ust cikinti nefesle hafifce sallanir — bagimsiz ama senkron.

#### Negatif Yon
- Kalp sembolü veya kalp formu OLMAYACAK — klise.
- Kirpik veya rujlu dudak OLMAYACAK — cinsiyetlendirilmis tasarim bu projenin gorsel dilinde yeri yok.
- Aşırı "kawaii" estetik OLMAYACAK — bu sevimli ama Gloo evreninin malzeme diliyle tutarli olmali.

---

### 5. LIGHTBLUE — Sakin

**Renk:** `0xFF3CF0FF` (acik camgobesu, L=0.6326 civarinda)
**Sentez Formulu:** Blue + White
**Arketip:** Sakin — huzur, akis, suyun dinginligi

#### Gorsel Kimlik Cumlesi
Neredeyse saydam, icinden isik gecen, durgun suda yansima gibi dingin bir jel damlasi.

#### Siluet Tasarimi
- **Genel form:** Tam daire — en simetrik, en "kusursuz" form. Hicbir cikinti, egim veya dalgalanma yok.
- **Ayirt edici ozellik:** Govdenin ic yapisinda, diger karakterlerden belirgin sekilde daha genis ve daha dusuk alpha'li specular — neredeyse "saydam" hissi veren isik gecirgenlik illuzyonu. Siluette ayrim forumdan degil, govdenin ic pariltisinin farklilasindan gelir.
- **Kucuk boyut testi:** 36px olcekte tam daire + parlak ic yapi diger karakterlerin daha mat govdelerinden ayrilir. Ancak bu, siluet-once tasarim prensibine meydan okur — ek onlem olarak govde kenarinda cok ince (0.5px) daha koyu bir halka cizgisi bulunur.

#### Renk Paleti
| Rol | Deger | Kullanim |
|-----|-------|----------|
| Ana | `0xFF3CF0FF` | Govde orta tonu |
| Acik | HSL L+0.42 → neredeyse beyaz-mavi | Genis specular |
| Koyu | HSL L-0.25 → orta mavi | Alt golge — diger karakterlerden daha acik |

**Ozel not:** Bu karakter diger 7 karakterden daha yuksek ortalama parlakliga sahiptir. Koyu arka plan uzerinde "en parlak, en saf" gorsel agirliga sahip olur — bu kasitlidir ve huzurun "berraklik" ile ifadesini destekler.

#### Yuz
- **Gozler:** Iki kucuk, cok hafif parlayan nokta — neredeyse gozle gorulmeyecek kadar subtle. "Gozleri var mi yok mu?" sinirina yakin.
- **Agiz:** Yok. Mutlak dinginlik.

#### Animasyon Notlari (Gorsel Niyet)
- Nefes ritmi Green ile ayni hizda ama farkli karakterde — Green'in nefesi "kasitli kontrol", LightBlue'nunki "dogal gel-git."
- Specular highlight nefesle belirgin sekilde genisler/daralir — "icienden isik yayiliyor" hissi.
- Govde formu neredeyse hic degismez — hareket icsel, dissal degil.

#### Negatif Yon
- Su damlasi formu (ust sivri, alt genis) OLMAYACAK — bu bir damla degil, bir kutle.
- Dalga veya kabarcik efekti OLMAYACAK — sakinlik hareketsizliktir.
- Buz hucresiyle (kIceBlue) karistirilabilecek isik tonlarindan KACINILACAK — LightBlue daha sicak ve daha doygun, buz daha soguk ve daha pastel.

---

### 6. LIME — Yaratici

**Renk:** `0xFF9DFF3C` (elektrik yesil-sari, L yuksek)
**Sentez Formulu:** Green + Yellow
**Arketip:** Yaratici — tazelik, yenilik, beklenmedik cozum

#### Gorsel Kimlik Cumlesi
Asimetrik, beklenmedik acilarda cikintilari olan, "kurallara uymayan" bir jel damlasi — diger karakterlerin simetri sozlesmesini kasitli olarak kirar.

#### Siluet Tasarimi
- **Genel form:** Temel oval ama 2-3 noktada farkli yonlere cikan kucuk, organik cikinti — "amip gibi ama kontrol altinda." Asimetrik ama dengesiz degil.
- **Ayirt edici ozellik:** Asimetri. Diger 7 karakter bilaterel simetri (veya simetriye yakin) iken Lime kasitli olarak asimetriktir. Bu onun "yaratici kural kirici" kimliginin gorsel kaniti.
- **Kucuk boyut testi:** 36px olcekte duzensiz siluet kesin ayrim saglar — hicbir baska karakter bu kadar asimetrik degil.

#### Renk Paleti
| Rol | Deger | Kullanim |
|-----|-------|----------|
| Ana | `0xFF9DFF3C` | Govde orta tonu |
| Acik | HSL L+0.42 → parlak sari-yesil | Cikintilarin uc noktalari |
| Koyu | HSL L-0.25 → koyu zeytin-yesil | Govde merkezi golge |

**Ozel not:** Koyu varyant govde merkezinde, acik varyant cikintilarin uclarinda — diger karakterlerin "isik sol ustten" kuralinin tersi. Bu kasitli bir gorsel dil kirilmasidir ve "yaratici" kimligini destekler. Ancak specular highlight hala sol ust kaynakli kalir — tam kural kirimi degil, varyasyon.

#### Yuz
- **Gozler:** Farkli boyutta iki beyaz nokta — biri daha buyuk, biri daha kucuk. Asimetri yuz ifadesine de yansir.
- **Agiz:** Yana dogru cekik tek cizgi — "hmm, ilginc" ifadesi.

#### Animasyon Notlari (Gorsel Niyet)
- Nefes sirasinda cikintiler bagimsiz ritimlerle hafifce hareket eder — "her parcanin kendi aklı var" hissi.
- Nefes amplitüdü ortalamanın ustunde — enerji dolu ama Orange'in "ileri" enerjisinden farkli, bu "her yone" enerji.
- Siluet nefesle minimal de olsa degisir — diger karakterlerde siluet sabitken Lime'in silueti "nefes alir."

#### Negatif Yon
- Ampul veya disi cark sembolü OLMAYACAK — yaraticilik sembolle degil formla ifade edilir.
- Goz kamastiricı parlaklik OLMAYACAK — lime rengi zaten yuksek luminans tasiyor, ek parlama gorsel yorgunluk yaratir.
- "Deli bilim insani" estetigi OLMAYACAK — bu kaotik degil, kasitli-asimetrik.

---

### 7. MAROON — Guclu

**Renk:** `0xFF8B1A1A` (koyu bordo, L=0.0681 civarinda)
**Sentez Formulu:** Purple + Orange
**Arketip:** Guclu — dayaniklilik, kararlilik, sessiz otorite

#### Gorsel Kimlik Cumlesi
Yogun, agir, merkezi karanlik bir jel kitlesi — kucuk ama icindeki yogunlugu hissettiren, kolayca hareket ettirilemeyecek bir varlik.

#### Siluet Tasarimi
- **Genel form:** Diger karakterlerden %8-10 daha genis taban — "yerlesik, agir" hissi. Ust kisim hafifce daralir ama sivrilasmaz. Trapezoid-yuvarlatilmis.
- **Ayirt edici ozellik:** Govdenin alt kenarinda diger karakterlerden daha belirgin, daha kalin golge — "bu daha agir, yüzeye daha cok basıyor" hissi. Ek olarak govdenin ic yapisinda, merkezde diger karakterlerden daha koyu bir cekirdek bolgesi — "yogunluk merkezi."
- **Kucuk boyut testi:** 36px olcekte genis taban + koyu merkez yeterli ayrim saglar.

#### Renk Paleti
| Rol | Deger | Kullanim |
|-----|-------|----------|
| Ana | `0xFF8B1A1A` | Govde orta tonu |
| Acik | HSL L+0.42 → sicak kirmizi | Sol ust parlak bolge |
| Koyu | HSL L-0.25 → neredeyse siyah-bordo | Koyu cekirdek + alt golge |

**Erisilebilirlik notu:** Maroon, koyu arka plan uzerinde en dusuk kontrastli karakterdir. Dis glow %20 daha genis (blur radius 6 → 7.2) ve %15 daha yuksek alpha (0.40 → 0.46) tutularak algi destegi saglanir. Siluet ayriminin renge degil forma dayanmasi bu karakter icin kritiktir.

#### Yuz
- **Gozler:** Iki kucuk, dar, yatay beyaz cizgi — "kısılmıs gozler." Sert degil, kararlı.
- **Agiz:** Yok. Guc konusmaz.

#### Animasyon Notlari (Gorsel Niyet)
- Nefes ritmi en yavas ikinci karakter (Green'den sonra) — ama Green'in "meditatif" yavasligindan farkli, bu "agir kutle yavasligi."
- Nefes amplitudu en dusuk — "bu zor hareket ediyor" hissi.
- Hareket ettikce kisa bir gecikme + agir durma — ataleti yuksek.

#### Negatif Yon
- Kaya veya metal gorunumu OLMAYACAK — bu hala jel, sadece yogun jel.
- Kizgin veya tehditkar ifade OLMAYACAK — guc saldırganlik degil, dayaniklilik.
- Dis glow'u kirmiziya kaydirmak OLMAYACAK — bordo kalir; kirmizi Red ile karisir.

---

### 8. BROWN — Sadik

**Renk:** `0xFF8B6914` (sicak kahverengi, L=0.1570)
**Sentez Formulu:** Orange + Blue
**Arketip:** Sadik — toprak, guven, degismez baglilik

#### Gorsel Kimlik Cumlesi
Sicak, stabil, "eski bir dost" gibi hissettiren bir jel damlasi — gosterissiz ama her zaman orada.

#### Siluet Tasarimi
- **Genel form:** Tam oval, diger karakterlerden biraz daha alttan agirlikli — agirlik merkezi dusuk, "topraklanmis" hissi. Ama Maroon'un trapezoid genisliginden farkli — bu daha yuvarlak, daha yumusak.
- **Ayirt edici ozellik:** Govdenin yuzeyinde, diger karakterlerde olmayan cok subtle bir "mat bolge" — specular highlight diger 7 karakterden %30 daha dusuk alpha'li. "Cilali degil ama bakimli" hissi. Mat jel, parlak jelden daha "guvenilir" gorsel mesaj tasir.
- **Kucuk boyut testi:** 36px olcekte alttan agirlikli oval + dusuk parlaklik ayrim saglar. Maroon'dan ayrim: Maroon genis taban + koyu cekirdek, Brown yuvarlak + mat yuzey.

#### Renk Paleti
| Rol | Deger | Kullanim |
|-----|-------|----------|
| Ana | `0xFF8B6914` | Govde orta tonu |
| Acik | HSL L+0.42 → sicak altın-kahve | Sol ust bolge (dusuk alpha) |
| Koyu | HSL L-0.25 → koyu cikolata | Alt golge |

**Erisilebilirlik notu:** Brown, Maroon'dan sonra en dusuk kontrastli ikinci karakterdir. Ayni onlem: dis glow %20 daha genis, %15 daha yuksek alpha. Form ayriminin renk ayrimindan bagimsiz calismasi zorunludur.

#### Yuz
- **Gozler:** Orta boyutta, yuvarlak, sicak beyaz iki nokta — "guven veren bakis." Ne cok buyuk (Pink gibi heyecanli) ne cok kucuk (LightBlue gibi kaybolmus).
- **Agiz:** Kapalı, yatay duz cizgi — ne mutlu ne mutsuz, "buradayim" ifadesi.

#### Animasyon Notlari (Gorsel Niyet)
- Nefes ritmi tam ortalama — ne hizli ne yavas, "metronom gibi duzenli."
- Nefes amplitudu orta — ne belirgin ne gorulmez.
- Tum animasyon parametreleri kasitli olarak "ortanca" — Brown'un gorsel kimligi "asiri olmama" uzerine kurulu.

#### Negatif Yon
- Toprak parcacigi veya toz efekti OLMAYACAK — bu bir toprak degil, jel.
- "Surgun" veya "agac kutugu" formuna kaymak OLMAYACAK.
- Maroon ile karisacak koyu ton OLMAYACAK — Brown daha sicak (sari alt ton), Maroon daha soguk (kirmizi alt ton). Bu ayrim korunmali.

---

## III. Karakter Ayrim Matrisi

Asagidaki tablo, 8 karakterin birbirinden gorsel olarak nasil ayrildigini ozetler. Her satir-sutun kesisimi "bu iki karakter nasil ayirt edilir?" sorusunu yanitlar.

| # | Karakter | Birincil Ayrim (Siluet) | Ikincil Ayrim (Isik/Yuzey) | Ucuncu Ayrim (Animasyon) |
|---|----------|------------------------|---------------------------|-------------------------|
| 1 | Orange | One egimli + alev ucu | Standart render | Hizli nefes |
| 2 | Green | Dikey uzamis oval | Ic desen cizgileri | Yavas nefes |
| 3 | Purple | Dalgali alt kenar | Farkli renkli glow | Duzensiz ritim |
| 4 | Pink | Tombul + iki ust cikinti | Standart render | Balonsu solunum |
| 5 | LightBlue | Tam daire + ince halka | Genis, saydam specular | Icsel hareket |
| 6 | Lime | Asimetrik cikintlar | Ters isik dagilimi | Bagimsiz parca hareketi |
| 7 | Maroon | Genis taban, trapezoid | Koyu cekirdek, genis glow | Minimal amplitüd |
| 8 | Brown | Alttan agirlikli oval | Mat yuzey, dusuk specular | Metronom ritim |

**Kritik test:** Tum 8 karakter siyah-beyaz (deger/value only) gorunumde birbirinden ayirt edilebilir olmalidir. Renk kaldirildiginda hiyerarsi ve ayrim korunmalidir.

---

## IV. Ne OLMAMALI — Genel Yasaklar

| Yasak | Gerekce |
|-------|---------|
| Insan anatomisi (kol, bacak, parmak) | Jel malzeme sozlesmesini kirar |
| Hayvan referansi (kulak, kuyruk, kanat) | Tur karistirmasi — bu jel, hayvan degil |
| Aksesuar (sapka, gozluk, fiyonk) | Jel uzerine koyulan nesne malzeme illuzyonunu yikar |
| Detayli yuz (iris, kirpik, kas, dis) | Minimal yuz sozlesmesiyle celisir |
| Parlak parcacik efekti (yildiz, kivilcim) | Oyun icindeki sentez efektiyle karisir |
| Cinsiyetlendirilmis gorsel isaret | Evrensel jel kimlikleri — cinsiyet gostergesi yok |
| 4+ renkli palet | 3 katmanli renk kisitlamasi (acik/ana/koyu) asılmaz |
| Govde icinde nesne (kalp, yildiz, sembol) | Jel seffaf ama ici bos degil — ic yapi malzeme ozelligidir, tasiyici depo degil |
| Anime/manga proporsiyon | Stil koordinatlarıyla uyumsuz |
| Fotorealistik render | Jel hucresinin stilize dili korunmali |

---

## V. Uretim Notlari

### Calisma Boyutlari
- **Ana tasarim:** 256x256 piksel (4x oyun icesi maksimum gosterim)
- **Oyun icesi:** 64x64 piksel (standart izgara hucresi)
- **On-izleme:** 36x36 piksel (el silueti)
- **Profil/koleksiyon:** 128x128 piksel

Her tasarim 36px boyutunda siluet testinden gecmelidir — form bu olcekte taninir olmalidir.

### Teslim Formati
- Kaynaklar vektorel (SVG veya Figma component) — render olcegi bagimsiz olmali.
- Her karakter icin 3 durum: idle (nefes), highlight (sentez ani), ve siluet (siyah dolgu).
- Renk koru varyanti: govde uzerinde shortLabel etiketi ile.

### Teknik Sanat Koordinasyonu
GelCellPainter'in mevcut 6 katmanli render pipeline'ina ek karakter-spesifik katmanlar (ic desen, mat yuzey, farkli glow rengi vb.) teknik sanatci ile koordine edilmelidir. Bu brief gorsel niyeti tanimlar — shader implementasyonu ve performans butcesi teknik sanatcinin alanidir.

### Onay Kriterleri
1. 8 karakter yan yana konuldiginda hicbiri bir digeriyle karismiyor
2. Siyah-beyaz (grayscale) gorunumde 8 farkli form okunuyor
3. 36px boyutunda her karakter taninabiliyor
4. Deuteranopi ve protanopi filtrelerinde form ayriminin korunuyor
5. Koyu arka plan (0xFF010C14) uzerinde her karakter yeterli gorsel agirliga sahip
6. Hicbir karakter oyun icesi hucre renderindan (GelCellPainter) "kopuk" gorsel dilde degil
7. Her karakterin animasyon niyeti kelimelerle tarif edilebilir (sessiz animasyon testi)

---

## VI. Referans Koordinatlar

### Estetik (Bu hissi ariyoruz)
- **LocoRoco** karakterleri — minimal yuz, jel govde, form ile kisilik ifadesi. Ancak LocoRoco daha karikaturize; Gloo daha soyut ve daha "malzeme-odakli."
- **Monument Valley** renk tutarliligi — sinirli palet icinde maksimum cesitlilik.
- **Journey** yaratik tasarimi — minimal detay ile maksimum duygusal ifade.

### Yapisal (Bu yontemi referans aliyoruz)
- **Hollow Knight** karakter tasarimi — siluet-once yaklasim. Her karakter kucuk boyutta bile taninir.
- **Ori and the Blind Forest** isik karakterleri — isik ve glow ile malzeme hissi.

### Negatif (Bunlardan kaciniyoruz)
- **Candy Crush** karakter estetigi — asiri karikaturize, aksesuar agirlikli, kisilik forma degil eklentilere yuklu.
- **Slime Rancher** jel yaratiklari — sevimli ama anatomik (agiz, goz, kulak belirgin); Gloo daha soyut.
- **Cut the Rope** Om Nom — maskot-merkezli, insansi ifadeler; Gloo'nun "malzeme-once" dilinden uzak.

---

*Bu brief, konsept sanatcisinin gorsel kesfine baslamasi icin yeterli yonu verir. Ilk taslaklar (rough sketches) 8 karakterin yan yana siluet karti olarak teslim edilmelidir — renk ve detaydan once form onayi alinir.*
