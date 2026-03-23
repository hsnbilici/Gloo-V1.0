# Gloo Adasi — Illustrasyon Tasarim Briefingi

**Versiyon:** 0.1 | **Tarih:** 2026-03-23 | **Yazar:** Sanat Yonetmeni
**Kapsam:** Ada ekranindaki 5 bina, ada arka plani, okyanus/gokyuzu katmanlari ve upgrade gorsel evrimi icin tam illustrasyon yonu.

---

## 1. Gorsel Vaat

Bu ada oyuncunun "kendi jel dunyasini insa ettigini" hissetmesi gereken bir mekandir — tehditkar degil, kesfedilesi; steril degil, canli. Oyuncu her binaya yukselttikce adanin gorsel olarak nefes aldigini, buyudugunu ve renklendigini gormeli. Ada bir odul vitrinidir: oyuncunun ilerlemesinin somut, dokunulabilir kaniti.

---

## 2. Stil Koordinatlari

**Eksenler:**
- **El yapimi <-----[X]---> Dijital:** Dijitale yakin ama organik yuvarlakliklari koruyan bir nokta. Vektorel temizlikte ama jel fiziginin yumusak, amorf karakterini tasiyan cizgiler.
- **Organik <--[X]-------> Geometrik:** Guclu sekilde organik. Binalar "yeryuzunden fiskirmis jel yapilari" gibi okunmali — duz kenar, sert kose, metalik yuzey yok.

**Stil referansi:** Slime Rancher'in iyimser organik dunyasi + Monument Valley'nin temiz renk bloklama disiplini + Ori'nin isik-duygu iliskisi. Ancak hicbirinin kopyasi degil — Gloo'nun kendi jel-bazli mimari dili kurulacak.

**Negatif stil referansi:** Clash of Clans / Township tarzi izometrik "tahta-tas-metal" bina estetigi. Gloo'da ahsap, tugla, celik, beton gibi geleneksel yapi malzemeleri YOKTUR. Her yapi jel, kristal, isik ve organik formlardan olusur.

---

## 3. Jel-Bazli Mimari Dili (Stil Rehberi)

Bu ada dunyanin kendi fizik kurallarina sahip: binalarin malzemesi jeldir — yari saydam, isik geciren, yumusak kenarlarda hafifce bombe yapan, icinden isik sizen yapilar.

### 3.1 Malzeme Kurallari

| Kural | Aciklama |
|-------|----------|
| Yari saydamlik | Her bina yuzeyinin en az %20'si altindaki katmani belli etmeli — icsel isik, ic mekanizma silueti veya renk gecisleri |
| Yuvarlak kenarlar | Hicbir kenarda sert 90-derece kose yok. Her kenar minimum 15-20% yaricapla yuvarlatilmis |
| Bombe efekti | Buyuk duz yuzeyler hafifce disariya bombe yapar — jel malzemenin ic basincini ima eder |
| Isik gecirgenlik | Arka plan isigi binanin ince bolgelerinden gecmeli — siluet tamamen opak olmamali |
| Yuzey parlaklik | Uzerinde tek bir specular highlight noktasi — cam degil, islak jel hissi |
| Organik taban | Binalarin tabani yerle butunesik: topraktan fiskiran, kokulenen, yerden ayrilmaz |

### 3.2 Yasak Malzeme ve Form

- Metal, ahsap, tugla, beton, cam (duz panel cam) gorunumu
- Duz, paralel kenarlar (dikdortgen blok binalar)
- Sivri, agrresif uclar (silah, diken, kanca)
- Mekanik disli, boru, baca gibi endustriyel elemanlar (fabrika bile jel-organik olmali)
- Geleneksel pencere ve kapi formlari (dikdortgen cerceveli)

### 3.3 Siluet Ilkeleri

Her bina 64x64 piksel boyutunda (mobil ekrandaki yaklasik gorunum) siyah siluet olarak birbirinden NET SEKILDE ayirt edilebilir olmali.

| Bina | Siluet Karakteri | Ayirt Edici Form |
|------|-------------------|------------------|
| Jel Fabrikasi | Genis, alcak, yuvarlak — mantar/damla kumesi | Ustunden yukselen 2-3 balon-baca |
| ASMR Kulesi | Ince, dikey, uzun — dalgali minare | Tepede acilan cicek/ses dalgasi formu |
| Renk Laboratuvari | Orta boy, asimetrik — kaynayan kap/reaktor | Ustunden sican renkli kopur silueti |
| Meydan (Arena) | Genis, simetrik, alcak — amfi/kase | Ortada cukurlasan arena formu |
| Liman | Yatay, uzun, egimli — dalga/iskele | Yan tarafa uzanan organik iskele kolu |

---

## 4. Renk Felsefesi

### 4.1 Genel Ada Paleti

Ada renk sistemi oyunun mevcut `color_constants.dart` paletini dogrudan kullanir. Her bina oyundaki karsilik geldigi moda/isleve ait aksan rengini tasir.

| Bina | Birincil Renk (dark tema) | Hex | Light tema karsiligi | Hex |
|------|---------------------------|-----|---------------------|-----|
| Jel Fabrikasi | kGreen | `#3CFF8B` | kGreenLight | `#1B7A3D` |
| ASMR Kulesi | kLavender | `#B080FF` | kLavenderLight | `#5E35B1` |
| Renk Laboratuvari | kOrange | `#FF8C42` | kOrangeLight | `#C43E00` |
| Meydan (Arena) | kColorClassic | `#FF4D6D` | kColorClassicLight | `#C62828` |
| Liman | kDiamondBlue | `#00BFFF` | kDiamondBlueLight | `#0277BD` |

**Doygunluk kurali:** Level 0 (insa edilmemis) binalar gri-mavi monokrom (`kMuted` #6B8FA8 tonlarinda, %30-40 doygunluk). Her upgrade seviyesi doygunlugu ve isik yogunlugunu kademeli olarak artirir. Maks seviyede tam doygunluk + glow efekti.

**Yasak renkler:** Siyah (binada ana renk olarak), koyu kahverengi, hardal sarisi. Bunlar jel dunyanin canli, isik geciren karakteriyle celisir.

**Erisilebilirlik taahhudi:** Her bina diger binalardan yalnizca renk ile degil, siluet formu + ikon ile de ayirt edilir. Deuteranopi/protanopi filtresinde yesil (fabrika) ve turuncu (lab) en riskli cift — bu ikisi arasinda siluet farki maksimum tutulur (alcak-genis vs. asimetrik-dikey) ve ikon sistemi (disli vs. deney tupu) renk-bagimsiz kimlik saglar. Birbiriyle karisma riski olan ciftlerde deger (value/lightness) farki minimum 30% olmali.

### 4.2 Arka Plan Renkleri

| Katman | Dark Tema | Light Tema |
|--------|-----------|------------|
| Gokyuzu ust | kBgDark `#010C14` → kCyan %3 tint | kBgLight `#F5F5FA` → acik mavi tint |
| Gokyuzu alt (ufuk) | kSurfaceDark `#0F1420` → kGreen %5 tint | kSurfaceLight `#FFFFFF` → acik yesil tint |
| Okyanus | kDiamondBlue %15 alfa + kBgDeepDark | kDiamondBlueLight %10 alfa + kBgLight |
| Ada zemini | kGreen %8 + kBgDark | kGreenLight %6 + kBgLight |

---

## 5. Bina Detayli Illustrasyon Briefleri

---

### 5.1 Jel Fabrikasi (gelFactory)

## Konsept Briefingi: Jel Fabrikasi

**Kime:** Ortam / Prop illustrator
**Gorsel Gorev:** Oyuncuya "burada bir seyler uretiliyor, buyuyor, canlaniyor" hissi vermeli. Tehlikeli fabrika degil — rahatlatici, ritmik, organik bir uretim yeri.

**Dunya Baglami:** Ada ekonomisinin kalbi. Pasif Jel Ozu uretimi (level * 2/saat). En siklikla upgrade edilen, ilk insa edilen bina olmasi muhtemel. Gorsel olarak adanin merkezinde veya on planda konumlanmali.

**Form Dili:**
- Mantar kolonisi / petri kabi melezi. Ana govde genis, basik, yuvarlak bir jel kubbe.
- Ustunden 2-3 balon-baca yukselir — duman degil, icinden renkli jel baloncuklari yukari suzulen organik bacalar.
- Tabaninda kucuk jel damlalari birikir — uretim ciktisi gorsel olarak "damlayan jel" ile anlatilir.

**Siluet Gereksinimleri:** Genis ve alcak profil. Balon-bacalar siluette ana ayirt edici. 64px'de "mantar kumesi + yukari cikan balonlar" okunmali.

**Renk Yonu:**
- Birincil: kGreen (`#3CFF8B`) — govde tonu
- Ikincil: kMascotGreenMid (`#00CC66`) — golge ve derinlik
- Vurgu: kCyan (`#00E5FF`) — balon-bacalardaki jel baloncuklari icinde isik
- Ic isik: kMascotGreenLight (`#5CFFA8`) — govdenin icinden sizen isik

**Isik Varsayimi:** Sol ustten ana isik (gokyuzu). Govdenin alt yarisinda yaygin golge, ancak ic isik bu golgeyi kirarak yari saydam malzemeyi vurgular. Specular highlight sag ust ceyrek bolge.

**Upgrade Gorsel Evrimi (5 Seviye):**

| Seviye | Gorsel Degisim |
|--------|----------------|
| 0 (insa edilmemis) | Zeminde fosil-siluet: gri-mavi (`kMuted`) tonlarinda, sekli belli ama soluk bir jel kalintisi. Balon-baca yok. |
| 1 | Kubbe belirir, kucuk, tek balon-baca. Dusuk doygunluk yesil. Jel damlamasi yok. Sakin. |
| 2 | Kubbe buyur, 2 balon-baca. Orta doygunluk. Icerisinden hafif isik sizar. Ilk jel damlalari tabanda. |
| 3 | Tam kubbe + 2 baca + cevresinde kucuk mantar tomurcuklar. Doygunluk artisi. Balonlar icinde renkli parcaciklar gorunur. |
| 4 | Mantar kumesi genisler. 3 baca. Guclu ic isik — govde belirgin sekilde yari saydam. Taban damlalari ritmik animasyon alir. |
| 5 (MAKS) | Tam parlaklik + cevre glow (kGreen %15 alfa, yaricap ~bina genisliginin %40'i). Bacalardan surekli yukari suzulen jel baloncuklari. Tabaninda kucuk "uretim havuzu". Govde nefes alir gibi hafifce genisler-daralir. |

**Negatif Yon:** Endustriyel baca, duman, disli, metal boru. Bu bir kimya fabrikasi DEGIL — canli bir organizma gibi "ureten" bir jel yapisi.

**Serbestlik Alani:** Mantar/balon silueti korunduğu surece baca sayisi, tomurcuk dizilimi ve taban havuzunun sekli sanatcinin yorumuna acik.

---

### 5.2 ASMR Kulesi (asmrTower)

## Konsept Briefingi: ASMR Kulesi

**Kime:** Ortam / Prop illustrator
**Gorsel Gorev:** "Dinle, sakinles, guzelligi hisset" — bu bina sesin gorsel karsiligi. Oyuncuya huzur ve merak hissettirmeli.

**Dunya Baglami:** Yeni ses paketlerini acar (3 seviye). Estetik bir bonus binasi — ses ve gorselligin butunlestigi nokta. Dikey formu adaya ritmik bir vurgu katar.

**Form Dili:**
- Ince, uzun, dalgali govde — ruzgarda hafifce esnen bir jel minare.
- Tepede acilan cicek formu — ses dalgalarini yayan bir organik anten/cicek.
- Govde uzerinde yatay halkalar — titresim nodallarini gosteren jel bantlar. Bantlar seviye arttikca cogunlur.
- Taban genis ve stabil, yukari dogru incelir — devrilme endisesi vermemeli.

**Siluet Gereksinimleri:** Ince ve dikey — adadaki en uzun yapi. Tepedeki acilan cicek formu siluette birincil tanimlayici. 64px'de "uzun cubuk + tepede cicek/yelpaze" okunmali.

**Renk Yonu:**
- Birincil: kLavender (`#B080FF`) — govde tonu
- Ikincil: kThemeTertiary (`#8B5CF6`) — golge/derinlik katmani
- Vurgu: kPink (`#FF69B4`) — tepedeki cicek/ses dalgasi icin
- Ic isik: kLavender acik tonu — govde icinden sizen yumusak mor isik

**Isik Varsayimi:** Ayni genel isik (sol ust). Kulede isik govde boyunca yukari dogru hareket eder — ses titresiminin gorsel metaforu. Tepedeki cicek en parlak bolge.

**Upgrade Gorsel Evrimi (3 Seviye):**

| Seviye | Gorsel Degisim |
|--------|----------------|
| 0 (insa edilmemis) | Zeminde spiral siluet — gri-mavi, donuk, sessiz bir jel fosili. |
| 1 | Kisa, kalin govde. Tepede kapali tomurcuk. Dusuk doygunluk lavanta. Titresim bantlari yok. |
| 2 | Govde uzar ve incelir. Tomurcuk yari acilir. 2-3 titresim bandi belirir. Orta doygunluk. Govdede hafif ic isik. |
| 3 (MAKS) | Tam yukseklik. Cicek tamamen acilir — ses dalgasi halkalari cicekten yayilir. 4-5 titresim bandi glow ile parlar. Guclu ic isik. Cevre glow (kLavender %12 alfa). |

**Animasyon Notu:** Govde hafifce sallanir (ruzgar/ses titresimi). Tepedeki cicekten cikan ses dalgasi halkalari 2-3 saniyede bir pulse eder ve kaybolur. Maks seviyede titresim bantlari sirali olarak yanar-soner (asagidan yukariya, ritim efekti).

**Negatif Yon:** Radyo kulesi, anten, metal direk. Mekanik hoparlor veya megafon. Bu organik bir ses kaynagi — teknolojik degil.

**Serbestlik Alani:** Cicek formu (laleler, nilüfer, orkide ilhamli olabilir), govde dalgasinin amplitudu ve titresim bandi sayisi sanatcinin yorumuna acik.

---

### 5.3 Renk Laboratuvari (colorLab)

## Konsept Briefingi: Renk Laboratuvari

**Kime:** Ortam / Prop illustrator
**Gorsel Gorev:** "Burada renkler karisir, yeni seyler olusur" — deney, kesif ve surpriz hissi. Oyuncuya merak ve heyecan vermeli.

**Dunya Baglami:** Yeni sentez kombinasyonlarini acar (3 seviye). Oyunun renk sentezi mekaniginin fiziksel karsiligi. Aktif, fokurdayan, renkli bir yapi.

**Form Dili:**
- Ana govde: buyuk, asimetrik bir jel reaktor/kazan — yandan bakan deney tupu silueti.
- Ustunden "kopuren" renkli jel taskinlari — kabarciklar, damlalar, siritmalar.
- Yanlarda kucuk reaktor uzantilari — ana govdeye jel borularla bagli (borular da organik, damarlari andiran).
- Tabandan cikan jel kokleri binalari besliyor hissi.

**Siluet Gereksinimleri:** Orta boy, asimetrik. Ust siniri duzenli degil — kopuren/tasan jel siluette kaotik ama okunabilir bir ust hat olusturur. 64px'de "tasan kap + kabarciklar" okunmali.

**Renk Yonu:**
- Birincil: kOrange (`#FF8C42`) — govde tonu
- Ikincil: kAmberGlow (`#FFA000`) — sicak golge
- Vurgu renkleri (kopuren jelller): Sentez renklerinden secme — kOrangeVivid (`#FF7B3C`), GelColor.purple displayColor (`#8B3CFF`), GelColor.green displayColor (`#3CFF8B`). Her kopuren kabarcik farkli renkte.
- Ic isik: kAmber (`#FFD740`) — reaktorun icinden sizen sicak isik

**Isik Varsayimi:** Iki isik kaynagi — genel gokyuzu isigi (sol ust) + binanin kendi ic isigi (sicak amber, icerden disari). Bu cift isik jel saydamligini vurgular.

**Upgrade Gorsel Evrimi (3 Seviye):**

| Seviye | Gorsel Degisim |
|--------|----------------|
| 0 (insa edilmemis) | Zeminde yayilmis renkli lekeler — kurumus jel kalintisi, gri-turuncu tonlari. |
| 1 | Kucuk, basit kazan formu. Kopurme yok, sakin yuzey. Tek renk (turuncu). Yan uzantilar yok. |
| 2 | Kazan buyur, ilk kopurmeler baslar (2-3 kabarcik). Bir yan uzanti belirir. Iki farkli renk kopurer. Ic isik aktif. |
| 3 (MAKS) | Tam boyut. Surekli kopurme — 5+ kabarcik, en az 3 farkli renk. 2 yan uzanti. Guclu ic isik + cevre glow (kOrange %12 alfa). Tabandan renkli jel akintisi. |

**Animasyon Notu:** Kabarciklar govde yuzeyinden yukari cikar, buyur ve patlar (veya suzulerek kaybolur). Her kabarcik farkli renkte. Seviye arttikca kabarcik sikligı ve cesitliligi artar.

**Negatif Yon:** Bilim-kurgu laboraturavi, cam tupler, metal stativ, pipet. Skolastik/akademik bilim gorunumu degil — organik, daginik, yasayan bir deney alani.

**Serbestlik Alani:** Kopurme yogunlugu, kabarcik boyut dagilimi, yan uzantilarin formu sanatcinin yorumuna acik.

---

### 5.4 Meydan / Arena (arena)

## Konsept Briefingi: Meydan (Arena)

**Kime:** Ortam / Prop illustrator
**Gorsel Gorev:** "Burada rekabet var — ama saygili, heyecanli, korkutucu degil" hissi. PvP'nin erisim noktasi. Enerji ve heyecan tasimali.

**Dunya Baglami:** PvP modunu acar (tek seviye, binary: var/yok). Insa edilince adaya sosyal/rekabetci bir atmosfer katar. Gorsel olarak simetrik ve "davet eden" bir yapi.

**Form Dili:**
- Simetrik, genis, alcak profil — jel amfi tiyatro / kase formu.
- Ortada cukurlasan arena alani — icinde parlayan bir jel disk/platform.
- Cevresi basamakli oturma alani (jel basamaklar, yuvarlak kenarli).
- Ust kenari hafifce disari kivrilan bir jel sinir — bombe halka.
- Iki yanda giris acikligi — kapisi olmayan, davet eden gecisler.

**Siluet Gereksinimleri:** Genis ve simetrik — adadaki en genis yapi. Ortadaki cukurluk siluette belirgin. 64px'de "kase/amfi + ortada platform" okunmali. Dikey formlara (kule, fabrika) karsi yatay karakter.

**Renk Yonu:**
- Birincil: kColorClassic (`#FF4D6D`) — govde tonu (pembe-kirmizi)
- Ikincil: kCoral (`#FF6B6B`) — basamak/oturma alani
- Vurgu: kCyan (`#00E5FF`) — merkez platformdaki isik
- Ic isik: kRed (`#FF3B3B`) — arena icinden yayilan sicak kirmizi isik

**Isik Varsayimi:** Merkezdeki platform en parlak nokta — goz buraya cekilir. Kenarlardaki basamaklar kademeli olarak koyulesir. Arena ic isigi sicak kirmizi, dis govde genel gokyuzu isigini alir.

**Upgrade Gorsel Evrimi (1 Seviye — Binary):**

| Seviye | Gorsel Degisim |
|--------|----------------|
| 0 (insa edilmemis) | Zeminde dairesel cukurluk — gri-mavi tonlarda soluk bir arena fosili. Icerideki platform karanlik. |
| 1 (MAKS) | Tam yapi. Basamaklar belirgin. Merkez platform parlar (kCyan pulse). Govde tam doygunluk. Cevre glow (kColorClassic %10 alfa). Giris acikliklarindan isik sizintisi. |

Tek seviyeli oldugundan gecis dramatik olmali: insa aninda "canlanma" animasyonu onemli. Platform onceleri karanlik → tap ile insa → parlama dalgasi merkezden kenarlara yayilir.

**Animasyon Notu:** Merkez platform yavas pulse (nefes efekti, 3-4 sn donum). Maks seviyede giris acikliklarinda hafif isik parcaciklari (davet efekti).

**Negatif Yon:** Kolize, stadyum, metal kafes, kan/kavga imgeleri. Bu bir "meydan" — topluluk alani, savaas arenaasi degil.

**Serbestlik Alani:** Basamak sayisi, giris acikliginin formu, merkez platformun deseni sanatcinin yorumuna acik.

---

### 5.5 Liman (harbor)

## Konsept Briefingi: Liman

**Kime:** Ortam / Prop illustrator
**Gorsel Gorev:** "Buradan bir yerlere gidilebilir, yeni seyler gelir" — aciklik, kesfetme istegi, mevsimsel heyecan. Sezonluk etkinliklerin kapisi.

**Dunya Baglami:** Sezonluk etkinliklere erisim saglar (tek seviye, binary). Adanin kenarinda, okyanusa bakan konumda. Dis dunyayla baglanti noktasi.

**Form Dili:**
- Yatay, uzun profil — adanin kenarindan okyanusa dogru uzanan organik iskele.
- Ana govde: adanin kenarina tutunmus yari-dairesel bir jel platform.
- Iskele kolu: platformdan okyanusa uzanan organik, esnek gorunumlu bir jel kopru.
- Iskele ucunda kucuk bir fener/isaret — gelen "gemilere" (etkinliklere) isaret.
- Tabani okyanus dalgalarina karisiyor — sert bir kesim degil, jelin suyla bulustuğu organik gecis.

**Siluet Gereksinimleri:** Yatay ve asimetrik — bir tarafi adaya yapisik, diger tarafi okyanusa uzanir. 64px'de "platform + uzanan iskele kolu + uctaki fener" okunmali.

**Renk Yonu:**
- Birincil: kDiamondBlue (`#00BFFF`) — govde tonu
- Ikincil: kIceBlue (`#88CCFF`) — iskele kolunun acik tonlari
- Vurgu: kGold (`#FFD700`) — fener isigi, sezonluk odul hissi
- Ic isik: kIceHighlight (`#E8F6FF`) — jel govdenin icinden sizen soguk isik

**Isik Varsayimi:** Genel gokyuzu isigi + fenerdeki sicak altin isik. Fener isigi ile gokyuzunun soguk isigi arasindaki sicak-soguk kontrasti derinlik ve dramatik etki yaratir.

**Upgrade Gorsel Evrimi (1 Seviye — Binary):**

| Seviye | Gorsel Degisim |
|--------|----------------|
| 0 (insa edilmemis) | Adanin kenarinda kirik iskele kalintisi — gri-mavi tonlarda, okyanusa uzanan soluk bir siluet. Fener karanlik. |
| 1 (MAKS) | Tam yapi. Iskele kolu okyanusa uzanir. Fener yanar (kGold glow). Govde tam doygunluk (kDiamondBlue). Cevre glow (kDiamondBlue %10 alfa). Iskele ucunda dalga-jel etkilesimi. |

Insa ani: iskele kolu adanin kenarindan okyanusa dogru "uzanarak buyur" — jelin amorf, akan karakterini vurgulayan bir canlanma.

**Animasyon Notu:** Fener isigi yavas pulse (deniz feneri ritmi, 4-5 sn). Okyanus dalgalari iskele tabaninda jel ile etkilesir (hafif salinim). Sezonluk etkinlik aktifken iskele ucunda renkli bayraklar/isaret parcaciklari.

**Negatif Yon:** Tahta iskele, metal vins, beton rihtim, gemi halatı. Geleneksel liman altyapisi yok — her sey jel ve organik.

**Serbestlik Alani:** Fener formu, iskele kolunun egrisi, dalga-jel etkilesim detayi sanatcinin yorumuna acik.

---

## 6. Ada Arka Plani ve Atmosfer

### 6.1 Ada Zemini

**Form:** Yuvarlak, organik hatli bir ada — ada kenarlari duz degil, girintili cikintili ama yumusak. Ada "okyanus uzerinde yuzen buyuk bir jel kumesi" gibi okunmali.

**Yuzey:** Yosun-jel melezi bir zemin dokusu. Bitkiler de jel-bazli: cam yerine yari saydam jel yapraklar, cimen yerine jel tutamlari. Binalar arasinda ince jel yollar (vein/damar gorunumu — ada kendi ic dolasim sistemine sahip gibi).

**Renk:** Baskin yesil tonlari (kGreen ailesinden dusuk doygunlukta). Binalar arasindaki yollar kCyan %10 alfa ile hafif parlak. Ada kenari okyanusa dogru koyulesir.

### 6.2 Okyanus

**Deger (Value) Iliskisi:** Okyanus adanin arkaplanindadir — deger olarak adanin zemin tonundan KOYU olmali (dark temada) veya daha SOGUK (light temada). Bu deger farki adanin figurunu zemin uzerinde net okutturur.

**Dalga Stili:** Yumusak, yuvarlak dalga formlari — jel dunyanin okyanusu da "jelimsice". Kopur, keskin dalga ucu yok. Dalgalar okyanus yuzeyinde yavas, ritmik salinimlar.

**Renk:** kDiamondBlue (`#00BFFF`) dusuk alfa (%10-15) + kBgDark/kBgLight bazinda. Ufuk cizgisine dogru doygunluk azalir (atmosferik perspektif).

**Derinlik katmanlari:** On plan dalgalari (buyuk, yavas), orta plan dalgalari (kucuk, orta hiz), arka plan ufuk cizgisi (sakin). Parallax potansiyeli var ama implementasyon teknik sanatci ile koordine edilmeli.

### 6.3 Gokyuzu

**Dark Tema:** kBgDark (`#010C14`) bazinda. Ufuk cizgisine dogru hafifce acilir (kSurfaceDark `#0F1420`). Ust kesimde 3-5 kucuk parlak nokta (yildiz degil — uzak jel parcaciklari). Ay/gunes yok — isik kaynagi "gece gokyuzunun kendisi" olarak soyut kalir.

**Light Tema:** kBgLight (`#F5F5FA`) bazinda. Ufuk cizgisinde kDiamondBlueLight %5 tint ile hafif mavi gecis. Acik, ferah, "sabah hissi". Bulut yok — temiz gokyuzu (jel dunyada bulut yerine yari saydam jel parcaciklari suzulebilir ama bu opsiyonel).

**Isik Yonu:** Sol ust — tum binalar ve ada elemanlari icin tutarli tek isik kaynagi. Golgelerin yonu bu kaynaga gore tutarli olmali (sag alt tarafa dusen golgeler).

### 6.4 Atmosfer Katmani

- Ada etrafinda hafif jel sisi — dusuk alfa, yesil-mavi tonlarda. Derinlik hissi verir, binaları on plana cikarir.
- Okyanus uzerinde daha yogun atmosferik perspektif — uzak ufuk daha soluk ve dusuk kontrastli.
- Parcacik efekti: Ada uzerinde suzulen kucuk jel parcaciklari (kCyan %8 alfa, 3-5px, yavas hareket). Adanin "canli" hissetmesini saglar.

---

## 7. Isik Briefingi: Ada Genel

**Isigin Duygusal Islevi:** Sicak ama gizemli — oyuncuyu kesfetmeye davet eden, guvenli ama surpriz vadeden bir isik.

**Anahtar Isik:** Sol ust, soguk-notr (kIceHighlight `#E8F6FF` tonunda). Yumusak kenarli — sert golgeler yok. Jel malzemenin yari saydamligi sert golgeyi zaten kirar.

**Dolgu ve Golge Karakteri:** Golgeler koyu mavi-yesil tonlarinda (kBgDark bazinda). Hicbir golge tamamen siyah degil — jel dunyanin her yerinde isik sizar. Golge opakligi maksimum %70.

**Renk Sicakligi Stratejisi:** Genel isik soguk (mavi-beyaz), binalarin ic isiklari sicak (bina renginin acik tonu). Bu soguk-sicak kontrastı binalari canlI, cevrelerini sakin kilar. Fener (Liman) ve Arena merkezi sicak vurgu olarak calisir.

**Odak ve Yonlendirme:** Isik en parlak binalarin ustunde yogunlasir — oyuncunun gozu oncelikle aktif (insa edilmis) binalara gider. Insa edilmemis binalar dusuk isik + dusuk doygunluk ile arka plana cevrilir.

**Platform Notu:** Gercek zamanli mobil render — isik efektleri (glow, ic isik) muhtemelen sprite-based veya gradient overlay olarak uygulanacak. Dinamik golge hesaplamasi yerine baked isik/golge katmanlari tercih edilmeli. Teknik sanatci ile koordine edilmeli.

---

## 8. Animasyon Notlari (Tum Ada)

Bu bolum gorsel niyet tanimlar — teknik animasyon implementasyonu (controller, easing, fps) teknik sanatci ile koordine edilmelidir.

### 8.1 Genel Ilkeler

| Ilke | Aciklama |
|------|----------|
| Organik tempo | Tum animasyonlar yavas ve yumusak. En hizli donum suresi ~2 saniye. Jel dunyada hicbir sey ani hareket etmez. |
| Nefes ritmi | Her maks seviye bina hafifce "nefes alir" — scale 1.0 → 1.02 → 1.0, ~3-4 sn donum. Tum binalar ayni ritimde degil, hafif offset. |
| Reduce Motion | `shouldReduceMotion(context)` true ise tum animasyonlar statik pozisyona sabitlenir. Nefes, pulse, parcacik efekti durur. |
| Seviye gecisi | Upgrade aninda 800ms'lik bir "buyume" animasyonu — bina eski formundan yeni formuna morph eder (veya flash-cross-fade). |

### 8.2 Bina-Ozel Animasyonlar

| Bina | Animasyon | Tetikleyici |
|------|-----------|-------------|
| Jel Fabrikasi | Balon-bacadan yukari suzulen jel kabarciklari | Surekli (maks seviye) |
| Jel Fabrikasi | Taban damlalari | Surekli (seviye 4+) |
| ASMR Kulesi | Govde sallanmasi | Surekli (seviye 1+) |
| ASMR Kulesi | Tepedeki cicekten ses dalgasi halkalari | Periyodik pulse (3 sn) |
| Renk Lab | Kabarcik olusma + patlamasi | Surekli (seviye 2+) |
| Arena | Merkez platform pulse | Surekli (insa edilmis) |
| Liman | Fener isik pulse | Surekli (insa edilmis) |
| Liman | Dalga-iskele etkilesimi | Surekli (insa edilmis) |
| Genel | Suzulen jel parcaciklari | Surekli |

### 8.3 Insa/Upgrade Animasyonu

Oyuncu "Upgrade" butonuna bastiginda:

1. **Hazirlik (0-200ms):** Bina hafifce kuculur (0.97x scale) — "guc toplama" hissi
2. **Patlama (200-500ms):** Bina yeni boyutuna genisler + renk doygunlugu artar + bina renginde parcacik patlamasi (8-12 parcacik, radyal)
3. **Yerlесme (500-800ms):** Bina yeni boyutunda stabilize olur + yeni detaylar fade-in olur
4. **Glow (800-1200ms):** Cevre glow bir kez parlayip normal seviyeye doner

---

## 9. Gorsel Evrim — Ada Genel Yay

Ada oyuncunun ilerlemesini gorsel olarak yansitir. Hic bina insa edilmemisken ada soluk, sessiz ve gri-mavi tonlarindadir. Her bina insa/upgrade edildikce ada canlanir:

| Asama | Ada Durumu | Gorsel Ton |
|-------|-----------|------------|
| Bos ada | Tum binalar fosil-siluet | Monokrom gri-mavi. Okyanus sakin. Parcacik yok. |
| 1-2 bina insa | Ilk renkler belirir | Dusuk doygunluk. Ada zemini hafif yesillenir. Ilk parcaciklar. |
| 3-4 bina insa | Ada canlanir | Orta doygunluk. Okyanus dalgalari aktif. Jel yollar gorunur olur. |
| Tum binalar insa | Tam canli ada | Tam doygunluk. Tum animasyonlar aktif. Ada "nefes alir". |
| Tum binalar MAKS | "Parlayan ada" | Her bina glow yayar. Ada kenari ince isik cercevesi alir. Gokyuzunde ek jel parcaciklari. |

Bu gorsel yay oyuncunun bilincdisina "ilerledikce dunya guzellesiyor" mesajini verir — acik odul olmadan bile upgrade motivasyonu yaratir.

---

## 10. Referans Koordinatlari

### Estetik (Bu Hissi Veren)
- **Slime Rancher** — Organik, iyimser, jel-bazli dunya yapisi. Binaların "canli organizma" gibi hissetmesi.
- **Ori and the Blind Forest / Will of the Wisps** — Isik ve renk ile duygu yonetimi. Ic isik ve glow efektlerinin duygusal etkisi.
- **Monument Valley** — Temiz renk bloklama, az detay ile derin atmosfer. Renk disiplini.

### Yapisal (Bu Yontemi Kullanan)
- **Stardew Valley** — Bina upgrade gorsel evrimi (tek sprite setinden kademeli degisim). Ekonomik ve uretilebilir upgrade sprite sistemi.
- **Townscaper** — Prosedural organik bina formları. Sert kenar olmadan mimari olusturma.

### Negatif (Kacinilacak)
- **Clash of Clans / Township** — Geleneksel izometrik "tahta-metal-tas" bina estetigi. Gloo'nun jel dunyasiyla uyumsuz.
- **Sim City / City Builder turevi** — Endustriyel, mekanik, gri, beton agirlikli yapi dili.
- **Cyberpunk/Neon-punk** — Asiri parlak neon, sert kenarli, agresif isik. Gloo'nun isigi yumusak ve davet edici olmali, gozleri yormamali.

---

## 11. Gorsel Test Plani

### Siluet Testi
- 5 bina 64x64 siyah siluet olarak yan yana konulduğunda her biri 3 saniye icinde dogru tanimlanabilmeli.
- Siluetler deuteranopi/protanopi filtresi altinda da form farki ile ayirt edilebilmeli.

### Deger (Value) Testi
- Tum illustrasyonlar gri tonlamaya donusturulduğunde (renk kaldirildiginda) hiyerarsi korunmali: binalar > ada zemini > okyanus > gokyuzu.
- Her binanin ic isik kaynagiyla dis yuzey arasindaki deger kontrastı gri tonlamada belirgin olmali.

### Renk Koru Simulasyonu
- Deuteranopi filtresinde: Jel Fabrikasi (yesil) ve Renk Lab (turuncu) arasindaki fark siluet + ikon ile okunabilmeli.
- Protanopi filtresinde: Arena (kirmizi-pembe) soluklasmasi durumunda form ve ic isik kontrastı ile tanimlanabilmeli.

### Olcek Testi
- Tum binalar mobil ekranda (360px genislik) kart icinde ~52x52 ikon boyutunda ve tam ada gorunumunde (~80-120px) net okunmali.

### Upgrade Gecisi Testi
- Seviye 0 → 1 gecisi en dramatik gorsel fark olmali — "hicbir sey" → "bir seyler var" net hissedilmeli.
- Seviye N → N+1 gecisleri deger katmali — oyuncu "bu upgrade gorsel olarak ne degistirdi?" sorusunu yanitlayabilmeli.

---

## 12. Uretim Notlari

### Teslimat Formati
- Her bina icin: seviye basina ayri asset (0, 1, 2, ..., maks) VEYA sprite sheet
- Ada arka plani: katmanli (gokyuzu, okyanus, ada zemini) — parallax veya basit stack icin ayrilmis
- Animasyon kareleri: sprite sheet veya Lottie/Rive formati (teknik sanatci ile koordine edilmeli)
- Glow/isik katmanlari: ayri alfa katmani olarak — runtime'da additif blend icin

### Boyut Kisitlamasi
- Mobil platform: toplam ada asset seti <5MB (sikistirilmis)
- Her bina sprite: maks 256x256px @2x (yuksek DPI icin 512x512)
- Arka plan katmanlari: maks 1024px genislik @2x

### Iterasyon Sureci
1. Ilk teslim: 5 bina siluet + form skeci (siyah-beyaz)
2. Ikinci teslim: Renk ve isik uygulanmis halller (seviye 0 + maks)
3. Ucuncu teslim: Tum ara seviyeler + ada arka plani
4. Dorduncu teslim: Animasyon kareleri / Rive dosyalari

---

## 13. Acik Sorular

- [ ] Ada izometrik mi yoksa dumduz on gorunumlu mu (flat/front-facing)? Mevcut UI kart-bazli liste gorunumu kullanıyor — illustrasyonlar ikon olarak mi, yoksa tam ada sahnesi olarak mi uygulanacak?
- [ ] Binalar arasi mekansal iliski (hangi bina nerede konumlanir) game design tarafindan tanimlanmali
- [ ] Gece/gunduz dongusu var mi, yoksa ada her zaman ayni isik altinda mi?
- [ ] Sezonluk etkinliklerde ada gorunumu degisecek mi (kar, yaprak, vb.)? Varsa asset varyantlari planlanmali.
- [ ] Maskot (GlooMascot) adada gorunecek mi? Konumu ve etkilesimi tanimlanmali.

---

## 14. Revizyon Gecmisi

| Ver. | Tarih | Ozet |
|------|-------|------|
| 0.1 | 2026-03-23 | Ilk taslak — 5 bina + ada arka plani briefi |
