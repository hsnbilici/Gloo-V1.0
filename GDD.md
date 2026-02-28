# Gloo: ASMR Puzzle
## Game Design Document (GDD) — v0.2
**Çalışma Başlığı:** Gloo: ASMR Puzzle
**Tür:** Casual / Puzzle / Satisfying
**Platform:** iOS 16+ / Android 10+
**Hedef Kitle:** 18–35 yaş, ASMR içerik tüketicileri, "satisfying" video takipçileri
**Belge Tarihi:** 2026-02-26

---

## 1. OYUN MEKANİĞİ VE CORE LOOP

### 1.1 Çalışma Başlığı Gerekçesi
"Gloo" — "glue" (yapıştırıcı) ve "goo" (yapışkan madde/jöle) kelimelerinin birleşiminden türetilmiş, kısa ve akılda kalıcı bir isimdir. Jel kapsüllerin yapışkan, akışkan dokusunu ve renklerin birbirine "yapışarak" birleşme mekaniğini sezgisel biçimde çağrıştırır. Uluslararası telaffuzu kolay, mağazada arama dostu.

---

### 1.2 Temel Oyun Mekaniği

**Grid Yapısı:**
- 7x9 veya 8x10 hücreli dinamik ızgara
- Her hücre, standart piksel blok yerine "jel kapsül" (gel capsule) içerir
- Jel kapsüller; yerleştirme, birleşme ve patlama animasyonlarında fizik tabanlı şekil deformasyonu geçirir

**Yerleştirme Mantığı (Block Blast Temeli):**
- Oyuncunun elinde her seferinde 3 adet şekil (tetromino/pentomino türevi) bulunur
- Şekiller ızgaraya sürüklenerek yerleştirilir
- Tam satır veya sütun dolduğunda o hücredeki jel kapsüller "birleşerek" patlar

**ASMR Diferansiyatörü — Renk Sentezi:**
- Standart "aynı renk eşleştir" yerine: **renk sentezi (color synthesis)** sistemi
- Sarı + Mavi = Yeşil jel, Kırmızı + Sarı = Turuncu jel
- 3 veya daha fazla aynı renkli jel bir hatta hizalandığında "birleşme" tetiklenir
- Birleşme sırasında renk karışım animasyonu yavaş çekim efektiyle gösterilir
- Bu çekirdek döngü hem tatmin edicidir (satisfying) hem kognitif meşguliyet sağlar

**Core Loop:**
```
Şekil Al → Strateji Kur → Yerleştir → Renk Sentezi Tetikle →
ASMR Geri Bildirim (Ses + Haptik) → Kombo Zinciri → Skor/Seviye →
Yeni Şekil Al
```

> **Mevcut Uygulama Durumu:** Sentez tespiti skora yansır (`colorSynthesisBonus +50`). Grid üzerinde görsel renk değişimi aktif — `_evaluateBoard()` sentezleri uygulayıp `onColorSynthesis` callback ile `ColorSynthesisBloomEffect` animasyonunu tetikler (flaş + 2 halka + 10 parçacık, 700ms).

---

### 1.3 ASMR Tabanlı Geri Bildirim Sistemi

**Ses Katmanları:**
Ses tasarımı oyunun birincil diferansiyatörüdür. Her etkileşimin kendine özgü bir "dokusu" vardır.

| Eylem | Ses Efekti |
|---|---|
| Jel yerleştirme | Yumuşak "squelch" sesi, yerleşim hızına göre pitch ayarı |
| Renk birleşimi | Yavaş, derin "slime merge" sesi, 3 katmanlı reverb |
| Satır patlaması | Kristal "pop" kaskatı, her hücre 50ms gecikmeli |
| Büyük kombo | Düşük frekanslı ASMR "rumble" + tiz kristal ardışık |
| Near-miss durumu | Gerilim müziği yükselmesi, ardından nefes alınan sessizlik |

**Haptik Geri Bildirim (Taptic Engine / Android Vibration API):**

| Eylem | Haptik Profil |
|---|---|
| Jel yerleştirme | Soft impact (UIImpactFeedbackGenerator.soft) |
| Küçük birleşim | Light impact |
| Büyük kombo | Medium impact → ardından selection tick zinciri |
| Ekran dolu kritik an | Custom waveform: 3x pulse, 100ms aralıklı |
| Seviye tamamlama | Uzun, derin success vibration |

**Görsel Fizik (Jiggle Physics):**
- Her jel kapsül, dokunuş ve yerleşimde 0.3 saniye jello deformasyonu geçirir
- Spring-based interpolation: stiffness=800, damping=15
- Renk geçişleri particle efektiyle desteklenir (renk damlacıkları sıçrar)
- 60 FPS'de render edilmesi zorunlu — bkz. Bölüm 4

---

### 1.4 Oyun Modları

| Alan | Classic | Color Chef | Time Trial | Zen |
|---|---|---|---|---|
| **Amaç** | Satır/sütun temizle, en yüksek skoru kır | Hedef renk kombinasyonlarına ulaş | Süre dolmadan mümkün olduğunca çok temizle | Saf ASMR deneyimi; skor veya süre baskısı yok |
| **Oyun Sonu** | Sığmayan şekil kaldığında | Sınırlı hamle tükendiğinde | 90 saniye (uzatma: rewarded video ile +30 sn) | Kullanıcı manuel olarak durdurduğunda |
| **Özel Kural** | Yok | Min. 3 sentez / tur hedefi; 500+ bölüm | 90 sn başlangıç + rewarded video uzatması | Sınırsız süre; müzik seçimi serbest |
| **Zorluk Eğrisi** | Lineer (ızgara doluluk oranına göre) | Komboya dayalı artan hedef karmaşıklığı | Sabit zaman baskısı; hamle kalitesine odak | Yok |
| **Leaderboard** | Haftalık global skor tablosu | Seviye bazlı bölüm tamamlama | Haftalık hız rekoru tablosu | Yok |
| **Premium mi?** | Hayır — temel mod | Hayır | Hayır | Evet — Gloo+ abonesi veya tek seferlik IAP |

**Mod Notları:**
- **Classic:** MVP'de tam işlevsel. Temel retention döngüsünün çekirdeği.
- **Color Chef:** Seviye editörü Faz 2'de geliştirilecek; MVP'de ilk 20 bölüm sabit tanımlı.
- **Time Trial:** TikTok paylaşımı için ideal format (bkz. Bölüm 2). 90 sn kısa oturum, doğrudan paylaş.
- **Zen:** Faz 3 monetizasyon katmanında Gloo+ aboneliğinin ana çekim noktası.

---

### 1.5 Onboarding ve Tutorial

**İlk Oturum Akışı:**
1. "Gloo" logo animasyonu — jel kapsüllerin birleşip logo şeklini oluşturması (~2 sn)
2. Otomatik olarak Classic Mod açılır; boş bir ızgara gösterilir
3. İlk 3 hamle interaktif ipucu eşliğinde yönlendirilir:
   - **Hamle 1:** "Bir şekil seç" — el panelindeki ilk slot pulsing animasyonla vurgulanır
   - **Hamle 2:** "Izgaraya yerleştir" — hedef hücreler parlayan overlay ile işaretlenir
   - **Hamle 3:** "Satırı temizle" — tam satır doldurulunca patlama otomatik tetiklenir, "Harika!" toast çıkar
4. Tutorial tamamlandığında oyuncu serbest bırakılır

**İpucu Gösterimi Kuralları:**
- Yalnızca ilk 3 oturumda aktif; `SharedPreferences` `onboarding_done` flag'i `true` olduğunda gösterilmez
- Oyuncu herhangi bir anda ipucu balonunu kapatabilir; `onboarding_done` true'ya set edilir
- İpuçları mevcut dil (`stringsProvider`) üzerinden çekilir — hardcoded string yok

**Renk Körü Modu İlk Açılış Uyarısı:**
- Uygulama ilk kez başlatıldığında "Renk körü modunu etkinleştirmek ister misiniz?" dialog gösterilir
- `SharedPreferences` `colorblind_prompt_shown` flag'i ile kontrol edilir; bir kez sorar
- Onay verilirse `audioSettingsProvider.colorBlindMode` true'ya set edilir; `GelColor.shortLabel` etiketleri otomatik etkinleşir

---

## 2. VİRALİTE ÖZELLİKLERİ VE ASO STRATEJİSİ

### 2.1 Otomatik Video Kayıt ve Viral Döngü

**Near-Miss Algılama Sistemi:**
Oyun her frame'de aşağıdaki kriterleri değerlendirir:

```
near_miss_score = (
  dolu_hücre_oranı * 0.4 +          // Izgara doluluk yüzdesi
  son_hamle_kombo_büyüklüğü * 0.3 + // Kombo zincir uzunluğu
  renk_çeşitliliği_azalması * 0.2 +  // Renk homojenleşme hızı
  kalan_yerleştirme_seçeneği * 0.1   // Çıkmaz durumu yakınlığı
)
if near_miss_score > 0.85: tetikle_kayıt()
```

**Kombo Algılama:**
- 3 ardışık satır/sütun patlaması: "Combo" kayıt tetikleyicisi
- 5+ ardışık: "Epic Combo" — otomatik slow-motion efekti ve kayıt
- Renk sentezi zinciri (4+ farklı renk birleşimi tek hamlede): "Color Master" etiketi

**Video Üretim Pipeline:**
1. Kritik an 3 saniye öncesinden başlayarak frame buffer'a kaydedilir
2. Olay gerçekleştikten 2 saniye sonraya kadar kayıt sürer (toplam ~5 sn)
3. Otomatik post-processing:
   - Slow-motion: kritik anda 0.5x hız
   - Renk grading: daha doygun, ASMR estetiğine uygun LUT
   - Filigran: uygulama logosu + "Gloo" hashtag + skor
4. Kullanıcıya "Bu anı paylaş!" bildirimi çıkar
5. Sistem paylaşım sayfasına yönlendirir (iOS: UIActivityViewController, Android: Intent.ACTION_SEND)

**Viral Kanca Elementleri:**
- Videolar 5-7 saniye — TikTok/Reels için ideal süre
- İlk kare her zaman en tatmin edici patlama anı (dikkat çekici thumbnail)
- Altyazı otomatik eklenir: "#ASMR #satisfying #puzzle #Gloo"

---

### 2.2 ASO (App Store Optimization) Stratejisi

**Birincil Anahtar Kelimeler (Yüksek Hacim):**

| Anahtar Kelime | Aylık Arama Hacmi (tahmini) | Rekabet |
|---|---|---|
| asmr games | 180.000+ | Orta |
| satisfying games | 150.000+ | Orta |
| sort puzzle | 200.000+ | Yüksek |
| color sort | 380.000+ | Yüksek |
| jelly puzzle | 90.000+ | Düşük-Orta |
| brain games | 500.000+ | Çok Yüksek |
| slime games | 70.000+ | Düşük |
| block blast | 2.000.000+ | Çok Yüksek |

**Uzun Kuyruk (Long-tail) Hedef:**
- "satisfying color sort puzzle"
- "asmr slime block game"
- "jelly merge puzzle offline"
- "color mixing puzzle relaxing"

**Başlık Stratejisi:**
```
iOS: Gloo: ASMR Color Puzzle
Android: Gloo - Satisfying Jelly Sort
```
(Platform algoritmalarına göre A/B test edilecek)

**Alt Başlık (Subtitle / Short Description):**
```
iOS:   "Satisfying jelly merge & color sort"
Android: "Relax with ASMR slime block puzzle"
```

**Uygulama Açıklaması Yapısı:**
- İlk 3 satır en güçlü kanca: "Feel every pop. Hear every merge."
- Emoji kullanımı: platform normuna uygun, her madde için tek emoji
- Anahtar kelimeler doğal yerleştirilecek, spam değil
- Yerelleştirme: EN, TR, DE, JA, KO (ASMR tüketimi yüksek pazarlar)

**İkon Konsepti:**
- Zemin: derin lacivert veya siyah (dikkat çeker, kalabalık mağazada öne çıkar)
- Merkez: parlak renklerde birleşen 3 jel kapsül, deformasyon anı
- Renk paleti: canlı pembe + fosforlu yeşil + mor gradient çarpışması
- Tipografi yok — simge tamamen görsele dayalı
- A/B testleri: parlaklık seviyeleri, arka plan rengi, jel şekli varyantları

**Önizleme Videosu (Preview/Feature Graphic) Konsepti:**
- Açılış: ASMR ses dalgası görselleştirilir, "sshhh" sesi
- 3 saniye: büyük kombo patlaması slow-motion, ses efektleri ön planda
- 5 saniye: renk birleşim animasyonu
- 8 saniye: oyuncu TikTok paylaşımı yapıyor ekran içi görseli
- Kapanış: "Free to Play" + ikon + tagline "Feel the merge"
- Müzik: lo-fi ASMR beat, düşük BPM

---

## 3. PSİKOLOJİK ÖDÜL SİSTEMİ VE MONETİZASYON

### 3.1 Retention Mekanizmaları

**Kısa Vade (Seans İçi):**
- Variable Reward Schedule: Kombo büyüklükleri rastgele değil, Fibonacci benzeri bir eğride dağılır. Oyuncu her büyük kombonun ardından bir sonrakini bekler.
- Anticipation Window: Near-miss anında ekran hafifçe titreyip durur, 0.5 saniye bekleme süresi oyuncuya "neredeyse oldu!" hissi verir.
- Color Harmony Feedback: Renk sentezi tamamlandığında ekranın köşelerinden merkeze doğru renk dalgası yayılır — görsel mükemmellik hissi.

**Orta Vade (Günlük Geri Dönüş):**
- Günlük Görev Sistemi: "Bugün 3 mor jel oluştur", "Near-miss'ten kurtar" gibi basit ama tatmin edici görevler
- Streak Sistemi: 7 günlük zincir tamamlandığında özel jel dokusu kilidi açılır
- Günlük Bulmaca: Her gün değişen, paylaşılabilir özel bir bölüm (Wordle benzeri sosyal etkileşim)

**Uzun Vade (Haftalık / Aylık):**
- Sezonluk Temalar: Her 4 haftada yeni jel dokusu paketi (Noel teması, okyanus teması, vb.)
- Koleksiyon Sistemi: Nadir renk kombinasyonları "renk koleksiyonu" albümüne eklenir
- Turnuvalar: Haftalık skora dayalı kupa sistemi, ödül olarak premium ses paketi

### 3.2 Monetizasyon Mimarisi

**Temel İlke:** Oyun tamamen oynanabilir olmalı, ödeme duvarı asla temel mekaniği engellememeli. Gelir, estetik ve konfor satışından gelir.

**Katman 1 — Reklam (F2P Temel Gelir):**
- Interstitial reklamlar: Her 4 oyun sonrası, asla oyun ortasında kesilmez
- Rewarded Video: "Bir can daha kazan" seçeneği — oyuncu kontrolünde
- Banner: Ana menüde, asla oyun ekranında
- Hedef: Organik kullanıcı başına $0.08-0.15 eCPM (casual oyun benchmarkı)

**Katman 2 — IAP (In-App Purchase):**

| Ürün | Fiyat | Değer Önerisi |
|---|---|---|
| Reklamsız Deneyim | $2.99 tek seferlik | Reklamları tamamen kaldırır |
| Ses Paketi — "Crystal ASMR" | $1.99 | 15 yeni kristal ses efekti |
| Ses Paketi — "Deep Forest" | $1.99 | Doğa sesleri + yeni haptik profil |
| Jel Doku Paketi | $2.99 | 20 yeni jel görünümü (metalik, holografik, vb.) |
| Starter Pack | $4.99 | Reklamsız + 2 ses paketi + 1 doku paketi |

**Katman 3 — Abonelik (Gloo+):**
- Aylık $1.99 / Yıllık $9.99
- İçerir: Reklamsız, tüm ses paketleri, Zen Modu, erken erişim sezonluk temalar
- Hedef: Kullanıcıların %3-5'i aboneliğe geçer — LTV'yi dramatik artırır

**Katman 4 — Redeem Code (Promosyon):**
- Influencer, etkinlik veya müşteri memnuniyeti amaçlı ücretsiz ürün dağıtımı
- Akış: Kullanıcı Shop ekranında kodu girer → Supabase `redeem_codes` tablosunda doğrulanır (`max_uses`, `expires_at` kontrolleri) → `current_uses` artırılır → `PurchaseService.unlockProducts()` ile ürünler açılır → Lokal olarak `redeemed_codes` ve `unlocked_products` SharedPreferences'ta saklanır
- Kodlar büyük harfe dönüştürülür, aynı kod ikinci kez girilemez (lokal + uzak çift kontrol)
- Sunucu tarafı: Supabase RPC veya Edge Function ile atomik doğrulama + güncelleme

**Monetizasyon Dengesi (Anti-Frustration Kuralları):**
- Oyuncu 5 dakika içinde iki kez kaybederse: ekstra reklam gösterilmez
- Premium içerik asla oyun mekaniğine avantaj sağlamaz (pay-to-win yok)
- İlk 10 seviye tamamen reklamsız — oyuncunun oyunu anlaması için güvenli alan

### 3.3 Retention Metrikleri Hedefleri

| Metrik | Hedef |
|---|---|
| D1 Retention | >45% |
| D7 Retention | >22% |
| D30 Retention | >10% |
| Ortalama Seans Süresi | 8-12 dk |
| Günlük Seans Sayısı | 3-5 seans |
| Viral K-Factor | >0.3 |

---

## 4. TEKNOLOJİ YIĞINI VE PERFORMANS MİMARİSİ

### 4.1 Platform Kararı: Flutter

**Flutter Seçim Gerekçesi:**

Flutter, bu projenin teknik gereksinimlerini React Native'e kıyasla daha iyi karşılar:

| Kriter | Flutter | React Native |
|---|---|---|
| Fizik simülasyonu | Doğrudan Canvas/Impeller erişimi | Bridge overhead var |
| Custom ASMR animasyonlar | AnimationController + CustomPainter | Reanimated 3 ile yakın |
| Haptik geri bildirim | flutter_haptic_feedback (Taptic tam destek) | react-native-haptic-feedback (sınırlı) |
| 60 FPS garantisi | Impeller renderer (iOS), Skia (Android) | JS thread bağımlılığı |
| Ses senkronizasyonu | flame_audio veya just_audio + isolate | expo-av, daha az kontrol |
| Geliştirici deneyimi | Tek codebase, hot reload | Tek codebase, hot reload |

**Karar: Flutter 3.19+, Dart 3.3+**

---

### 4.2 Oyun Motoru Katmanı

**Seçenek: Flame Engine (Flutter üzerinde)**

Flame, Flutter ekosisteminde en olgun 2D oyun motorudur:
- `flame: ^1.18.0`
- Component sistemi ile jel kapsülleri bağımsız varlıklar olarak modellenir
- Built-in collision detection, effect system, camera
- Flutter widget ağacıyla entegrasyon (UI overlay'lar, reklamlar)

**Alternatif: Saf Flutter (CustomPainter + Physics)**
Eğer oyun mekaniği Flame'in sağladığından daha az karmaşıksa (ki ilk iterasyon için bu geçerli olabilir), saf Flutter CustomPainter + AnimationController yaklaşımı tercih edilebilir — daha az bağımlılık, daha kolay kontrol.

**Öneri:** MVP için saf Flutter, v2.0 için Flame geçişi.

---

### 4.3 Fizik Simülasyonu

**Jöle/Jel Deformasyon Fiziği:**

Gerçek zamanlı fizik motoru (Box2D, Bullet) mobil cihazlarda yüksek pil tüketimine yol açar. Bu proje için **prosedürel animasyon + spring physics** yaklaşımı önerilir:

```dart
// Jel deformasyon parametreleri
class GelPhysics {
  static const double stiffness = 800.0;  // Yay sertliği
  static const double damping = 15.0;     // Sönümleme
  static const double mass = 1.0;

  // Spring interpolation
  // x(t) = A * e^(-damping*t) * cos(omega*t + phi)
  // Bu formül jöle salınımını fizik tabanlı olmadan simüle eder
}
```

Kütüphane: `spring_animation` veya manuel implementasyon
Deformasyon mesh: Her jel kapsül 8 kontrol noktalı Bézier eğrisi olarak temsil edilir

**Particle Sistemi (Renk Damlacıkları):**
- `flame_particles` veya özel `CustomPainter` particle sistemi
- Patlama anında 12-20 damlacık fırlar, 0.4 saniyede solar
- GPU-friendly: tüm partiküller single draw call ile render edilir

---

### 4.4 Ses ve Haptik Mimarisi

**Ses Kütüphanesi:**
```yaml
dependencies:
  just_audio: ^0.9.36        # Düşük latency oynatma
  audio_session: ^0.1.16     # iOS audio session yönetimi
  flutter_soloud: ^2.0.0     # < 5ms latency için SoLoud binding
```

`flutter_soloud` tercih sebebi: OpenAL tabanlı, mobilde 5ms altı latency sağlar. ASMR'de gecikme hissedildiğinde deneyim bozulur.

**Ses Önbelleği:**
- Oyun başlangıcında tüm ses efektleri RAM'e yüklenir (toplam ~15MB)
- Background music: streaming, önbelleğe alınmaz
- Ses kanalları: efektler için 8 eşzamanlı kanal ayrılır

**Haptik Mimarisi:**
```yaml
dependencies:
  flutter_haptic_feedback: ^0.5.0
  haptic_feedback: ^0.5.1+1
```

iOS Taptic Engine Mapping:
- `HapticFeedback.lightImpact()` → yerleştirme
- `HapticFeedback.mediumImpact()` → birleşim
- `HapticFeedback.heavyImpact()` → büyük kombo
- Custom waveform için `CoreHaptics` (platform channel ile)

Android: `Vibration.vibrate(pattern: [0, 50, 50, 100])` benzeri pattern API

---

### 4.5 Video Kayıt ve Paylaşım Modülü

**Ekran Kaydı Yaklaşımı:**
- iOS: `ReplayKit` framework (platform channel)
- Android: `MediaProjection` API (platform channel)
- Flutter paket: `screen_recorder: ^0.7.0` veya özel platform channel

**Video Post-Processing:**
- `ffmpeg_kit_flutter: ^6.0.3` — mobilde FFmpeg
- Slow-motion: `-filter:v "setpts=2.0*PTS"` (0.5x hız)
- Filigran ekleme: `-vf "movie=watermark.png [wm]; [in][wm] overlay=10:10 [out]"`
- Renk grading: `lut3d` filtresi ile önceden hazırlanmış ASMR LUT dosyası

**Paylaşım:**
```yaml
dependencies:
  share_plus: ^9.0.0    # Cross-platform paylaşım
  social_share: ^2.5.1  # TikTok/Instagram direct share
```

---

### 4.6 Render Mimarisi ve 60 FPS Stratejisi

**Impeller (Flutter 3.16+ iOS default):**
- Metal API üzerinde çalışır, Skia'dan %20-40 daha hızlı
- Shader pre-compilation: jel efektleri için custom fragment shader'lar derlenir
- `flutter build ipa --enable-impeller` (zaten default)

**Android: Skia → Impeller Geçişi:**
- `android:enableImpeller="true"` manifest flag (Flutter 3.19+ stable)
- Vulkan backend, OpenGL ES fallback

**Frame Budget Analizi (60 FPS = 16.7ms/frame):**

| Sistem | Hedef Süre |
|---|---|
| Oyun mantığı güncelleme | < 2ms |
| Fizik hesaplama | < 3ms |
| Render (CustomPainter) | < 8ms |
| Ses ve haptik tetikleme | < 1ms |
| UI overlay | < 2ms |
| **Toplam** | **< 16ms** |

**Optimizasyon Kuralları:**
1. `RepaintBoundary` ile oyun canvas ve UI ayrı layer'larda render edilir
2. Jel kapsüllerin statik halleri `cached_network_image` benzeri bir cache sistemiyle önbelleğe alınır
3. Particle efektler belirli sayının üzerinde giderse LOD (Level of Detail) düşürülür
4. `compute()` isolate'lar: ağır hesaplamalar (video encoding, skor hesaplama) ana UI thread'ini bloklamaz

---

### 4.7 Tam Bağımlılık Listesi (pubspec.yaml Özeti)

> **Not:** MVP'de yalnızca `[MVP]` etiketli paketler yüklüdür. `[Faz 2]` ve `[Faz 3]` paketleri ilerleyen aşamalarda eklenecektir. Web platformuyla uyumsuz paketler ilgili satırda belirtilmiştir.

**Mevcut MVP Bağımlılıkları (`pubspec.yaml` gerçek hali):**

| Paket | Sürüm | Amaç | Faz |
|---|---|---|---|
| `flutter_animate` | ^4.5.0 | Yüksek seviye animasyon DSL | [MVP] |
| `flutter_riverpod` | ^2.5.1 | Durum yönetimi | [MVP] |
| `go_router` | ^13.2.0 | Navigasyon | [MVP] |
| `equatable` | ^2.0.5 | Değer karşılaştırma | [MVP] |
| `collection` | ^1.18.0 | Koleksiyon yardımcıları | [MVP] |
| `shared_preferences` | ^2.3.2 | Yerel kalıcı depolama | [MVP] |
| `path_provider` | ^2.1.2 | Dosya sistemi yolları | [MVP] |
| `share_plus` | ^10.0.2 | Cross-platform paylaşım | [MVP] |
| `flutter_localizations` | SDK dahili | Çoklu dil desteği | [MVP] |

**Planlanan Bağımlılıklar (faz etiketleri ile):**

| Paket | Sürüm | Amaç | Faz | Web Uyumu |
|---|---|---|---|---|
| `flame` | ^1.18.0 | 2D oyun motoru (v2 geçişi) | [Faz 2] | Kısmi |
| `just_audio` | ^0.9.36 | Ses oynatma | [Faz 2] | Evet |
| `audio_session` | ^0.1.16 | iOS audio session yönetimi | [Faz 2] | Hayır |
| `flutter_soloud` | ^2.0.0 | <5ms latency ses (OpenAL) | [Faz 2] | Hayır |
| `flutter_haptic_feedback` | ^0.5.0 | Haptik geri bildirim | [Faz 2] | Hayır |
| `ffmpeg_kit_flutter` | ^6.0.3 | Video post-processing | [Faz 2] | Hayır |
| `firebase_analytics` | ^10.8.0 | Analytics | [Faz 3] | Evet |
| `firebase_crashlytics` | ^3.4.0 | Crash reporting | [Faz 3] | Kısmi |
| `google_mobile_ads` | ^4.0.0 | AdMob reklam | [Faz 3] | Hayır |
| `supabase_flutter` | ^2.3.0 | Backend as a Service | [Faz 3] | Evet |
| `isar` | ^3.1.0 | Yerel yüksek performanslı DB | [Faz 3] | Hayır |

---

### 4.8 Backend Mimarisi

**Supabase (BaaS) Tercih Gerekçesi:**
- PostgreSQL tabanlı, gerçek zamanlı subscriptions (leaderboard)
- Row Level Security ile kullanıcı verisi güvenliği
- Storage bucket: video kliplerin sunucuya opsiyonel yüklenmesi
- Edge Functions: viral video işleme pipeline (opsiyonel v2)
- Ücretsiz tier yeterli — başlangıçta sıfır backend maliyeti

**Veri Modeli ve Şema:**

```sql
-- profiles: Kullanıcı profilleri
-- auth.users ile 1:1 ilişki; Supabase Auth'tan otomatik oluşturulur
CREATE TABLE profiles (
  id          uuid PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  username    text UNIQUE NOT NULL,
  country     text,                   -- ISO 3166-1 alpha-2 (analytics)
  device_id   uuid,                   -- Anonim kullanıcı takibi için
  created_at  timestamptz DEFAULT now()
);
-- RLS: SELECT herkese açık (leaderboard); INSERT/UPDATE yalnızca auth.uid() = id

-- scores: Oyun skorları
CREATE TABLE scores (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid REFERENCES profiles ON DELETE CASCADE,
  mode        text NOT NULL CHECK (mode IN ('classic','colorchef','timetrial','zen')),
  score       int  NOT NULL CHECK (score >= 0),
  created_at  timestamptz DEFAULT now()
);
-- INDEX: (mode, score DESC) — leaderboard sorguları için
-- RLS: SELECT herkese açık; INSERT yalnızca auth.uid() = user_id

-- daily_tasks: Günlük görev tanımları ve tamamlanma durumu
CREATE TABLE daily_tasks (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date        date NOT NULL,
  seed        int  NOT NULL,          -- Deterministik bulmaca üretimi
  description text NOT NULL,
  user_id     uuid REFERENCES profiles ON DELETE CASCADE,
  completed   boolean DEFAULT false,
  completed_at timestamptz
);
-- INDEX: (date, user_id)
-- RLS: SELECT/UPDATE yalnızca auth.uid() = user_id

-- seasons: Sezonluk tema ve içerik takibi
CREATE TABLE seasons (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,
  theme_key   text NOT NULL,          -- Uygulama içi tema tanımlayıcısı
  starts_at   timestamptz NOT NULL,
  ends_at     timestamptz NOT NULL,
  active      boolean DEFAULT false
);
-- RLS: SELECT herkese açık; INSERT/UPDATE yalnızca service_role

-- redeem_codes: Promosyon / hediye kodları
-- Admin panelinden oluşturulur; uygulama içinde doğrulanır
CREATE TABLE redeem_codes (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code          text UNIQUE NOT NULL,
  product_ids   text[] NOT NULL,       -- Açılacak IAP ürün ID'leri
  max_uses      int NOT NULL DEFAULT 1,
  current_uses  int NOT NULL DEFAULT 0,
  expires_at    timestamptz,           -- NULL = süresiz
  created_at    timestamptz DEFAULT now()
);
-- INDEX: (code) — unique constraint zaten index oluşturur
-- RLS: SELECT/UPDATE yalnızca authenticated; INSERT yalnızca service_role
```

**Örnek RLS Politikaları:**

```sql
-- profiles: herkes okuyabilir, sadece kendi satırını değiştirebilir
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "profiles_select" ON profiles FOR SELECT USING (true);
CREATE POLICY "profiles_modify" ON profiles FOR ALL USING (auth.uid() = id);

-- scores: herkes okuyabilir, sadece kendi skoru ekleyebilir
ALTER TABLE scores ENABLE ROW LEVEL SECURITY;
CREATE POLICY "scores_select" ON scores FOR SELECT USING (true);
CREATE POLICY "scores_insert" ON scores FOR INSERT WITH CHECK (auth.uid() = user_id);
```

**Storage Bucket:**
- `viral-clips`: Oyuncuların opsiyonel olarak yüklediği paylaşım klipleri
- Dosya başına max 50MB; bucket RLS: dosya sahibi siler/günceller, herkes okur

---

## 5. PROJE YOL HARİTASI

### Faz 1 — MVP (8 Hafta) ✅
- [x] Temel ızgara ve Block Blast yerleştirme mekaniği
- [x] Renk sentezi sistemi (12 renk, 8 karışım)
- [x] Jel deformasyon animasyonu (spring physics + gel deformer)
- [x] ASMR ses altyapısı (AudioManager + 30 ses yolu tanımlı, dosyalar üretilecek)
- [x] Haptik geri bildirim (HapticManager, 13 profil)
- [x] 7 Oyun Modu (Classic, ColorChef, TimeTrial, Zen, Daily, Level, Duel)
- [x] iOS, Android ve Web build

### Faz 2 — Viral Loop (4 Hafta) ✅
- [x] Near-miss algılama sistemi (Shannon entropy)
- [x] Otomatik video kayıt pipeline (RepaintBoundary + ClipRecorder)
- [x] FFmpeg post-processing (slow-mo, renk grading, filigran)
- [x] Sosyal paylaşım entegrasyonu (share_plus, XFile video)
- [x] Günlük Bulmaca modu

### Faz 3 — Monetizasyon (3 Hafta) ✅
- [x] AdMob rewarded + interstitial + banner entegrasyonu (test ID)
- [x] IAP (7 ürün tanımlı, Store'da tanimlanacak)
- [x] Gloo+ abonelik sistemi
- [x] Zen Modu (Gloo+ kilidi)
- [x] Supabase backend (leaderboard, daily, redeem code, meta-game, PvP)
- [x] PvP Realtime (Supabase Realtime Presence + Broadcast)
- [x] CI/CD (GitHub Actions: analyze, test, Android/iOS build)

### Faz 4 — ASO & Launch (2 Hafta)
- [ ] A/B test ikonları
- [ ] App Store önizleme videosu prodüksiyonu
- [ ] Metadata tüm dillerde yazımı
- [ ] Soft launch (Philippines, Canada — düşük CPI pazarlar)
- [ ] Metrik analizi → Global launch

---

### 5.1 Beta Test Süreci

**Neden Philippines + Canada?**

| Kriter | Philippines | Canada |
|---|---|---|
| CPI (Cost Per Install) | <$0.30 (çok düşük) | ~$0.80 (makul) |
| Dil | İngilizce baskın | İngilizce / Fransızca |
| Mobil oyun penetrasyonu | Yüksek (%72 mobil oyuncu) | Yüksek (%65) |
| iOS + Android dengesi | Android ağırlıklı | iOS ağırlıklı |
| Temsil ettiği pazar | Güneydoğu Asya | Kuzey Amerika / Batı Avrupa |

Bu iki ülke; ana hedef pazarlar (US, EU, JP) için hem düşük maliyetli hem temsil edici bir test ortamı sağlar. Metrikler bu ülkelerde sağlıklı görünürse global launch için güven verici sinyaldir.

**iOS — TestFlight:**
1. Dahili test (Internal): 25 davetli tester — geliştirici ekibi + yakın çevre; App Review gerekmez
2. Harici test (External): 10.000 tester kapasitesi; App Review gerektirir (~1-2 gün)
3. Minimum süre: 2 hafta harici test verisi toplanmalı
4. Build geçerlilik süresi: 90 gün

**Android — Google Play Aşamaları:**
1. Internal Testing: Sınırsız tester; App Review gerekmez; anlık yayın
2. Closed Testing (Alpha): Belirli e-posta listeleri; %100 rollout
3. Open Testing (Beta): Herkese açık; Play Store'da "Beta" rozeti
4. Production: Kademeli rollout önerilir (%10 → %25 → %50 → %100)

**Soft Launch Geçiş Kriterleri:**

| Metrik | Hedef Eşik | Kaynak |
|---|---|---|
| D1 Retention | > %40 | Firebase Analytics |
| D7 Retention | > %20 | Firebase Analytics |
| Crash-free sessions | > %99 | Firebase Crashlytics |
| ANR oranı | < %0.47 | Google Play Console |
| Ortalama seans süresi | > 7 dakika | Analytics |

Bu kriterlerin tamamı sağlandığında Production aşamasına geçilir.

---

### 5.2 Post-Launch İçerik Takvimi

| Zaman | İçerik | Tür | Notlar |
|---|---|---|---|
| Launch | Classic + Time Trial + Color Chef (Faz 1-3) | Core | Temel mod seti |
| Launch +1 ay | Okyanus Teması (mavi-turkuaz palet, dalga ASMR sesi) | Sezon | Faz 4 sezon sistemi |
| Launch +2 ay | Günlük Görev sistemi canlıya alınır | Feature | Supabase `daily_tasks` aktif |
| Launch +3 ay | Uzay Teması + yeni şekil (hexagon koordinat sistemi) | Sezon | Yeni `GelShape` tipine ekleme |
| Launch +4 ay | Streak sistemi + koleksiyon albümü | Feature | Uzun vade retention |
| Launch +6 ay | Gloo+ abonelik lansmanı | Monetizasyon | RevenueCat entegrasyonu |
| Launch +8 ay | Zen Modu (Gloo+ dahil) | Premium Feature | ASMR içerik seti genişleme |

**İçerik Takvimi Prensipleri:**
- Her sezon 4 hafta sürer; eski sezon içerikleri kalıcı koleksiyona eklenir
- Güncellemeler mağaza yorumlarını tetikler — ASO için avantajlı
- Major feature güncellemeler App Review süresini hesaba katarak 2 hafta önceden hazırlanır

---

## 6. ERİŞİLEBİLİRLİK

### 6.1 Renk Körü Modu

**Mevcut Uygulama (Faz 1'de tam işlevsel):**
- `audioSettingsProvider.colorBlindMode` true olduğunda `_buildGrid()` her dolu hücrenin üstüne `GelColor.shortLabel` metnini bindirerek gösterir
- Kısa etiketler: K (Kırmızı), S (Sarı), M (Mavi), B (Beyaz), T (Turuncu), Mo (Mor), P (Pembe), AM (Açık Mor), L (Lacivert), Bo (Bordo), Ka (Kahverengi), Be (Bej)
- Toggle konumu: `settings_screen.dart` → ERİŞİLEBİLİRLİK bölümü (`kColorTimeTrial` aksanı)
- İlk açılışta dialog sorulur (bkz. Bölüm 1.5)

**Şekil Diferansiyatörleri (Faz 2 hedefi):**
- Her `GelColor` için farklı doku deseni (nokta, çizgi, eğim) — renk yetersiz olduğunda şekilden ayırt edilebilir
- Renk kombinasyonları WCAG kontrast rehberine göre seçilmiş; birincil renkler (kırmızı/sarı/mavi/beyaz) deuteranopia + protanopia senaryolarında test edilecek

### 6.2 Kontrast ve Tipografi

**Mevcut Durum:**
- Tüm metin renkleri `kMuted` (#94A3B8) zemin üzerinde WCAG AA standardını (~6:1 kontrast oranı) karşılar
- `color_constants.dart` tek kaynak; ekranlarda yerel renk tanımlaması yapılmamalı
- Yeni renk eklendiğinde kontrast oranı `https://webaim.org/resources/contrastchecker/` ile doğrulanmalı

**Gelecek Hedef:**
- Sabit `fontSize` değerleri yerine `Theme.of(context).textTheme` kullanımı — cihaz erişilebilirlik ayarlarındaki `textScaleFactor` değişimini otomatik destekler
- Mevcut kodda bazı widget'lar sabit `fontSize` kullanıyor; Faz 2'de kademeli geçiş yapılacak

### 6.3 Ekran Okuyucu Desteği

- Tüm interaktif butonlarda `Semantics(label:)` etiketi olmalı
- `GameScreen` içindeki ızgara hücreleri: `Semantics(label: 'Hücre $row-$col, ${color.shortLabel}')` ile erişilebilir
- `GameOverlay` HUD elementleri: skor, mod adı, doluluk oranı `Semantics` ile açıklanmalı
- Faz 1'de kısmen uygulanmış; Faz 2'de kapsamlı erişilebilirlik audit yapılacak

---

## 7. VERİ GİZLİLİĞİ VE GDPR

### 7.1 Toplanan Veriler

| Veri | Amaç | Zorunlu mu? |
|---|---|---|
| Oyun skoru, mod, süre | Leaderboard, analytics | Evet |
| Cihaz dili, platform | Analytics segmentasyonu | Evet |
| E-posta adresi | Gloo+ hesap yönetimi | Hayır (opsiyonel) |
| Anonim `device_id` UUID | Giriş yapmayan kullanıcı takibi | Evet |
| Crash ve hata logları | Kalite iyileştirme (Crashlytics) | Hayır (opt-out mümkün) |

**Toplanmayan Veriler:** Konum, kişisel iletişim bilgisi, finansal veri (IAP Apple/Google üzerinden işlenir).

### 7.2 Veri Saklama ve Güvenlik

- **Platform:** Supabase (EU-West-1 bölgesi — GDPR uyumlu)
- **Şifreleme:** Transit: TLS 1.3; Durağan: AES-256 (Supabase varsayılanı)
- **Anonim kullanıcılar:** Supabase Auth anonim oturum + `device_id` UUID; kişisel veri tutulmaz
- **Kayıtlı kullanıcılar:** E-posta Supabase Auth'ta saklanır; oyun verisi `profiles` tablosunda
- **Veri saklama süresi:** Aktif hesap süresince; hesap silindiğinde cascade ile temizlenir

### 7.3 Kullanıcı Hakları (GDPR Madde 17 — Silinme Hakkı)

```sql
-- Hesap ve tüm ilişkili veriyi tamamen sil
DELETE FROM profiles WHERE id = auth.uid();
-- CASCADE: scores, daily_tasks, viral_clips otomatik silinir
-- Supabase Auth kaydı ayrıca silinmeli (Auth API üzerinden)
```

- **Uygulama içi:** Settings → Hesabım → Hesabı Sil — onay dialogu + "Geri alamazsınız" uyarısı
- **Veri dışa aktarma:** Faz 3 özelliği; JSON formatında e-posta ile gönderilir

### 7.4 Analytics Opt-Out

- Settings → Veri Paylaşımı toggle → `SharedPreferences` `analytics_enabled` flag
- `analytics_enabled = false` ise Firebase Analytics event'leri gönderilmez
- Crashlytics opt-out: `FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false)`
- Reklam kişiselleştirme opt-out: AdMob `RequestConfiguration.setTagForUnderAgeOfConsent()` + `NonPersonalizedAds` modu

### 7.5 Yaş Sınırı ve COPPA

- **PEGI-3:** Şiddet, kumar veya uygunsuz içerik yok
- **App Store:** Content rating "4+" (şiddet/müstehcenlik yok)
- **Google Play:** "Everyone" — iç satın alımlar mevcut (bildirim gerektirir)
- **COPPA (ABD — 13 yaş altı):** Oyun 13 yaş altına pazarlanmaz. App Store / Play Store yaş sınırı ayarı bu koşulu otomatik kapsar. Eğer kullanıcı 13 yaşından küçük olduğunu beyan ederse (`DoB` toplanmıyorsa bu beyan istenmez) hesap oluşturma engellenir.
- **Veri toplama:** 13 yaş altı için kişisel veri toplanmaz; anonim `device_id` modunda çalışır

---

## 8. RİSK ANALİZİ

| Risk | Olasılık | Etki | Azaltma Stratejisi |
|---|---|---|---|
| Flutter Flame performans yetersizliği | Orta | Yüksek | MVP saf Flutter ile, gerekirse Unity geçişi |
| App Store ASMR içerik politikası değişikliği | Düşük | Orta | Ses efektleri "relaxing" olarak kategorilendir |
| Renk körü kullanıcılar için erişilebilirlik | Yüksek | Orta | Renk körü modu + şekil/desen diferansiyatörler (bkz. Bölüm 6) |
| Video kayıt pil tüketimi | Orta | Orta | Yalnızca tetiklenen anlarda kayıt, pil < %20'de pasif |
| Rakip "color sort" oyunları (yüksek rekabet) | Yüksek | Orta | ASMR + fizik kombinasyonu gerçek diferansiyatör |
| GDPR uyumsuzluk cezası | Düşük | Yüksek | Supabase EU-West, opt-out mekanizmaları, gizlilik politikası (bkz. Bölüm 7) |

---

*Bu belge yaşayan bir dokümandır. Playtest geri bildirimlerine göre güncellenecektir.*
*Versiyon geçmişi Git ile takip edilir.*
