# Stereo Ses Revizyonu — Odul Seviyesi Tasarim Spesifikasyonu

**Tarih:** 2026-03-23
**Hedef:** Tum ses dosyalarini studio kalitesinde stereo olarak revize etmek — ses tasarim odulu kazanacak seviyede
**Araclar:** Suno/Udio (muzik), ElevenLabs SFX / Freesound (SFX), DAW post-processing

---

## 1. Jel Sonic Kimligi — "Gloo'nun Sesi"

### 1.1 Malzeme Paleti: 4 Katmanli Jel DNA

Her SFX bu fizik tabanli katman paletinden olusur. Katmanlar sesin turune gore agirlik degistirir ama DNA tutarli kalir.

| Katman | Frekans | Karakter | Fizik Karsiligi |
|--------|---------|----------|-----------------|
| **Wobble** | 50-200 Hz | Elastik titresim, derin | Jelin yer cekimiyle titremesi |
| **Squelch** | 200-800 Hz | Islak temas, yapisan | Jelin yuzey temas ani |
| **Bubble** | 800-2 kHz | Hava kabarcigi, canli | Jelin icindeki hava hareketi |
| **Glow** | 2-8 kHz | Biyoluminesans, sihirli | Jelin isik yayma ani |

### 1.2 Imza Motifi: Gloo Chime (C5-E5-G5)

3 notalik ascending major arpeggio — oyunun sonic imzasi.
Notalar: C5 (1047Hz) → E5 (1318Hz) → G5 (1568Hz). Timing: 60ms/nota (toplam 180ms). Tini: "Jel marimba" — sine + soft FM + shimmer tail.

| Kullanim | Motif Varyanti | Icerik |
|----------|---------------|--------|
| color_synthesis | Tam (C5-E5-G5) | 3 nota net |
| combo_small | Orta nota (E5) | Tek nota ima |
| combo_medium | Ilk 2 nota (C5-E5) | 2 nota |
| combo_large | Tam (C5-E5-G5) | 3 nota, genis stereo |
| combo_epic | Tam akor (C+E+G ayni anda) | Akor, en genis stereo |
| game_over | Ters (G5-E5-C5) | Melankolik, yavas, uzun reverb |
| button_tap | Son nota hayaleti (G5) | Subliminal, cok kisa |
| level_complete | Genisletilmis (C4-E4-G4-C5) | Oktav asagi, genis kutlama |
| pvp_victory | Genisletilmis fanfari (C4-G4-C5-E5) | Genis interval, en majestuoz |
| gel_ozu_earn | Son 2 nota (E5-G5) | Kisa odul |

### 1.3 Reverb Karakteri

**Mekan:** Biyoluminesans subalti laboratuvar — yakin ve net, catedral degil.
- Pre-delay: 5-15ms (yakin, intimate)
- Decay: 200-400ms (plate reverb — kisa, net, mobil oyun icin uygun)
- Wet/Dry: %15-25 (SFX netligini korur)
- Damping: Yuksek frekanslar hafifce kesilir (suyun filtreleme etkisi)
- Tum SFX ayni reverb profili — mekan tutarliligi
- **Istisna:** game_over ve pvp_defeat icin decay 800-1200ms (duygusal kuyruk)

### 1.4 Frekans Kurali: SFX Boslugu

Tum muzik parcalarinda **800 Hz - 2 kHz** bolgesi kasitli olarak seyrek tutulur. Bu alan SFX'lerin Bubble katmanina ayrilmis — runtime ducking'e bagimliligi azaltir.

---

## 2. 32 SFX Detayli Brief

### 2.1 Stereo Olacaklar (11 dosya)

#### combo_large
- **Duygusal niyet:** Heyecan dorugu, "devam ediyorsun!"
- **Katmanlar:** Wobble (mono center) + Squelch (mono) + Bubble (stereo wide) + Glow (stereo sparkle sweep L→R)
- **Gloo Chime:** C5-E5-G5 tam, stereo dagitimli
- **Frekans:** 80Hz-6kHz, peak 1.2kHz
- **Sure:** 500-600ms
- **AI Prompt:** "Satisfying game combo reward sound, ascending crystal chime C-E-G, sparkle sweep stereo, gel bubble texture, bright and exciting, 48kHz stereo"
- **Post:** +3dB high shelf 4kHz, stereo widener %30, plate reverb 1.0s

#### combo_epic
- **Duygusal niyet:** Doruk an, "inanilmaz!"
- **Katmanlar:** Wobble (stereo sub rumble) + Squelch (mono impact) + Bubble (stereo burst) + Glow (widest stereo shimmer + reversed cymbal)
- **Gloo Chime:** C5-E5-G5-C6 genisletilmis, ping-pong delay
- **Frekans:** 40Hz-8kHz, genis spektrum
- **Sure:** 800-1000ms
- **AI Prompt:** "Epic game achievement sound, ascending chime C-E-G-C octave, reversed cymbal swell, wide stereo shimmer, gel wobble bass, triumphant and magical, 48kHz stereo"
- **Post:** Multiband compression, stereo widener %50, hall reverb 1.4s, +2dB air 8kHz
- **Not:** Sample rate 48kHz'e normalize (mevcut 96kHz tutarsizligi duzeltilecek)

#### line_clear_crystal
- **Duygusal niyet:** Cascade costusu, temizlik tatmini
- **Katmanlar:** Bubble (stereo arpeggio L→R sweep) + Glow (stereo crystal shimmer)
- **Gloo Chime:** Olmaz — cascade pitch sistemi zaten melodic
- **Frekans:** 400Hz-7kHz, parlak
- **Sure:** 700-900ms
- **AI Prompt:** "Crystal chime arpeggio sweeping left to right, satisfying puzzle line clear, sparkling stereo, clean and bright, 48kHz stereo"
- **Post:** High-pass 300Hz, stereo widener %40, short plate 0.6s

#### level_complete
- **Duygusal niyet:** Basari, tamamlama gururu
- **Katmanlar:** Wobble (mono victory drum) + Glow (stereo ascending chime) + Bubble (stereo confetti sparkle)
- **Gloo Chime:** C5-E5-G5-C6 genisletilmis
- **Frekans:** 100Hz-7kHz
- **Sure:** 1000-1200ms
- **AI Prompt:** "Level complete celebration fanfare, bright ascending chime C-E-G-C, stereo sparkle confetti, warm and triumphant, game reward, 48kHz stereo"
- **Post:** Gentle compression, stereo widener %35, plate reverb 1.2s

#### level_complete_new
- **Duygusal niyet:** Yeni rekor, ekstra gurur
- **Katmanlar:** level_complete + ek Glow katmani (stereo gold shimmer)
- **Gloo Chime:** C5-E5-G5-C6 + ek harmonik
- **Frekans:** 100Hz-8kHz
- **Sure:** 1100-1300ms
- **AI Prompt:** "New record achievement sound, golden triumphant fanfare, extra shimmer layer, wider stereo than normal level complete, celebration, 48kHz stereo"
- **Post:** Ayni + ek high shelf +2dB 6kHz, widener %45

#### pvp_victory
- **Duygusal niyet:** Zafer, en genis stereo field
- **Katmanlar:** Wobble (stereo power bass) + Squelch (mono impact) + Glow (widest stereo fanfare)
- **Gloo Chime:** C5-E5-G5-C6 en genis stereo dagitim
- **Frekans:** 60Hz-8kHz, full spectrum
- **Sure:** 1100-1300ms
- **AI Prompt:** "PvP victory fanfare, triumphant wide stereo brass and chime, powerful bass hit, celebration sparkle, competitive game win, 48kHz stereo"
- **Post:** Multiband, widener %50, hall 1.4s, limiter

#### pvp_defeat
- **Duygusal niyet:** Maglup ama umutlu — "bir dahaki sefere"
- **Katmanlar:** Glow (narrow stereo, descending) + Wobble (mono, gentle)
- **Gloo Chime:** G5-E5-C5 ters, yavas, dar stereo
- **Frekans:** 150Hz-4kHz, karartilmis
- **Sure:** 1000-1200ms
- **AI Prompt:** "Gentle game defeat sound, descending tone, narrow stereo, melancholic but warm and hopeful, not punishing, soft gel texture, 48kHz stereo"
- **Post:** Low-pass 4kHz, narrow stereo (mono-ya yakin), reverb 1.2s dampened

#### game_over
- **Duygusal niyet:** Bitis, "bu dunya hala burada"
- **Katmanlar:** Glow (stereo reverb tail) + Wobble (mono gentle descent)
- **Gloo Chime:** G5-E5-C5 ters, uzun reverb tail
- **Frekans:** 100Hz-5kHz, yumusak
- **Sure:** 1400-1600ms
- **AI Prompt:** "Game over gentle descending tone, reverse chime G-E-C, long stereo reverb tail, warm and accepting, not punishing, underwater feel, 48kHz stereo"
- **Post:** Long plate reverb 2.0s, gentle low-pass 5kHz, stereo tail spread

#### bomb_explosion
- **Duygusal niyet:** Patlama ama jel-bazli — sert degil, elastik
- **Katmanlar:** Wobble (stereo sub boom) + Squelch (stereo debris scatter L/R) + Bubble (stereo pop cluster)
- **Frekans:** 40Hz-6kHz
- **Sure:** 500-600ms
- **AI Prompt:** "Soft gel explosion, elastic wobble boom, stereo debris scatter left and right, bubble pop cluster, not aggressive or metallic, organic and soft, 48kHz stereo"
- **Post:** Sub bass enhancement, stereo widener %40, short room 0.4s

#### near_miss_tension
- **Duygusal niyet:** Gerilim, "dikkat!"
- **Katmanlar:** Glow (stereo detuned shimmer) + Wobble (mono tension riser)
- **Frekans:** 200Hz-5kHz, rahatsiz edici harmonikler
- **Sure:** 400-500ms
- **AI Prompt:** "Tension warning sound, detuned stereo shimmer, brief suspense riser, game near-miss alert, unsettling but not scary, gel texture, 48kHz stereo"
- **Post:** Slight chorus/detune, stereo widener %25, short reverb 0.6s

#### freeze_chime
- **Duygusal niyet:** Soguk esinti, donma ani
- **Katmanlar:** Glow (stereo ice shimmer, wide) + Bubble (stereo frozen pop)
- **Frekans:** 1kHz-8kHz, parlak ve soguk
- **Sure:** 400-500ms
- **AI Prompt:** "Ice freeze sound, cold shimmer chime, stereo wide frozen breath, crystalline and pure, game freeze power-up, 48kHz stereo"
- **Post:** High shelf +4dB 3kHz, stereo widener %45, plate reverb 0.8s

### 2.2 Mono Kalacaklar (21 dosya) — Kalite Yukseltmesi

Mono dosyalar da Jel DNA'siyla yeniden uretilecek (placeholder kalitesinden cikacak):

| Dosya | Duygusal Niyet | Katman Agirligi | AI Prompt Onu |
|-------|---------------|-----------------|---------------|
| gel_place | Tatmin, yerlestirme | Squelch dominant | "Soft gel placement, wet squelch, satisfying drop" |
| gel_place_soft | Hafif dokunma | Squelch hafif | "Very soft gel touch, gentle, minimal" |
| gel_merge_small | Kucuk birlestirme | Bubble dominant | "Small gel merge, tiny bubble pop" |
| gel_merge_medium | Orta birlestirme | Bubble + Squelch | "Medium gel merge, wet bubble cluster" |
| gel_merge_large | Buyuk birlestirme | Wobble + Bubble | "Large gel merge, deep wobble with bubbles" |
| line_clear | Tek satir temizleme | Bubble sweep | "Single line clear, quick crystal sweep" |
| combo_small | Kucuk kombo | Glow hint | "Small combo ding, single note hint C5" |
| combo_medium | Orta kombo | Glow 2-nota | "Medium combo chime, two notes C-E ascending" |
| color_synthesis | Sentez olusma | Glow tam chime | "Color synthesis magic, full C-E-G chime, bubble merge" |
| color_synth | Kisa sentez | Glow kisa | "Quick synthesis ping, brief magical" |
| button_tap | UI dokunma | Glow hayalet C5 | "Soft UI tap, ghost of C5 note, very brief" |
| rotate_click | Dondurmeclk | Squelch click | "Gel rotation click, soft mechanical" |
| undo_whoosh | Geri alma | Wobble reverse | "Reverse whoosh, gel undo, brief" |
| ice_break | Buz kirma | Bubble crack | "Ice breaking, crystalline crack, brief" |
| ice_crack | Buz catlak | Bubble micro | "Tiny ice crack, micro fracture" |
| gravity_drop | Dusme | Wobble drop | "Gel gravity drop, descending wobble" |
| gel_ozu_earn | Odul alma | Glow coin | "Currency earn sparkle, brief reward ding" |
| near_miss_relief | Rahatlama | Glow relief | "Relief exhale sound, tension release" |
| powerup_activate | Guc aktif | Glow + Bubble | "Power-up activation, magical gel charge" |
| pvp_obstacle_sent | Engel gonderme | Squelch throw | "Obstacle sent whoosh, competitive throw" |
| pvp_obstacle_received | Engel alma | Wobble impact | "Obstacle received impact, gel splat" |

**Mono SFX Genel Post-Processing Zinciri:**
1. Trim (bosluk kes)
2. EQ: High-pass 40Hz (rumble temizle), low-pass 12kHz (mobile uyumluluk)
3. De-ess 5-8kHz (gerekirse)
4. Compression: 3:1 ratio, -18dB threshold, 5ms attack, 50ms release
5. Normalize -6 dBFS true peak
6. Plate reverb: 5-15ms pre-delay, 200-400ms decay, %15-25 wet (Jel mekan profili)
7. Final trim + fade (gerekirse 10ms fade-out)
8. Format export (.ogg Vorbis mono 96kbps + .m4a AAC-LC mono 96kbps)

### 2.3 Teknik Spec — Tum SFX

| Parametre | Stereo (11) | Mono (21) |
|-----------|-------------|-----------|
| Calisma formati | WAV 48kHz 24-bit stereo | WAV 48kHz 24-bit mono |
| Export .ogg | Ogg Vorbis stereo 128 kbps | Ogg Vorbis mono 96 kbps |
| Export .m4a | AAC-LC stereo 128 kbps | AAC-LC mono 96 kbps |
| Normalize | -6 dBFS true peak (tavan) | -6 dBFS true peak (tavan) |
| Mono uyumluluk | Phase cancellation testi zorunlu | N/A |
| Gloo Chime | Ilgili SFX'lerde entegre | color_synthesis + button_tap + gel_ozu_earn |
| **Not** | Normalize -6 dBFS dosya TAVANI. Mix hiyerarsisi (Bolum 4) runtime volume ile saglanir — AudioManager.playSfx(volume:) | |

---

## 3. 10 Muzik Parcasi Detayli Brief

### 3.1 Mevcut 4 Parcainin Revizyonu

#### menu_lofi (revize)
- **Mood:** Sicak, davetkar, "eve hosgeldin"
- **BPM:** 78 | **Key:** Bb Maj | **Sure:** 150sn
- **Enstrumantasyon:** Vinyl-textured lofi drums, warm Rhodes, jel-pad synth (Wobble katmani), hafif sub bass
- **Gloo Chime:** Intro'da C5-E5-G5 bir kez, sonra melodiye gomulu
- **SFX Boslugu:** 800Hz-2kHz -6dB notch
- **Dinamik:** Duz — hicbir zaman climax yok, surekli rahatlik
- **Loop:** Son 100ms xfade, beat-aligned
- **Suno Prompt:** "lofi hip hop chill beat, warm vinyl crackle, rhodes piano, soft synth pad, game menu music, relaxing and inviting, C-E-G chime motif, Bb major, 78 BPM, seamless loop, stereo, high quality"

#### game_relax (revize)
- **Mood:** Odakli, huzurlu, "dusunuyorum"
- **BPM:** 98 | **Key:** C Maj | **Sure:** 180sn
- **Enstrumantasyon:** Floating synth pad, gentle electronic pulse, soft pluck, ambient texture
- **SFX Boslugu:** 800Hz-2kHz -6dB notch
- **Dinamik:** Minimal dalga — 45sn'de hafif swell, geri cekilme
- **Crossfade notu:** C Major secimi kasitli — game_tension (C min) ile ayni root note, crossfade gecisi harmoni bozulmadan yapilabilir
- **Suno Prompt:** "ambient electronic focus music, gentle synth pulse, floating pad, puzzle game background, calm and focused, C major, 98 BPM, no vocals, stereo, seamless loop, high quality"

#### game_tension (revize)
- **Mood:** Gergin, tempolu, "zaman daralıyor"
- **BPM:** 124 | **Key:** C min | **Sure:** 150sn
- **Enstrumantasyon:** Cello ostinato, sidechained bass, string tremolo, electronic percussion
- **SFX Boslugu:** 800Hz-2kHz -4dB notch (tension'da SFX boslugu daha dar — gerilim hissi icin)
- **Dinamik:** Kademeli artan — 90sn'de peak
- **1.15x speed:** Test edilmeli (Duel/TimeTrial tempo artisi)
- **Suno Prompt:** "tense cinematic game music, cello ostinato, sidechained bass, string tremolo, urgent and driving, C minor, 124 BPM, electronic percussion, no vocals, stereo, seamless loop, high quality"

#### zen_ambient (revize)
- **Mood:** Derin huzur, meditasyon, "nefes al"
- **BPM:** 65 (veya beat-less) | **Key:** Eb Maj | **Sure:** 240sn
- **Enstrumantasyon:** Deep evolving pad, no percussion, underwater reverb, sub harmonics
- **SFX Boslugu:** 800Hz-2kHz -8dB notch (en genis boslu — Zen'de SFX en net duyulmali)
- **Dinamik:** Neredeyse statik — yavas evrim
- **Suno Prompt:** "deep ambient meditation music, evolving synth pad, no beat, underwater reverb, ethereal and peaceful, Eb major, very slow, no vocals, stereo, seamless loop, high quality"

### 3.2 6 Yeni Parca

#### colorchef_groove (yeni)
- **BPM:** 100 | **Key:** Eb Maj | **Sure:** 150sn
- **Enstrumantasyon:** Rhodes, finger-pluck bass, soft woodblock, experimental textures
- **Mood:** Oyunbaz, kesfetme, "lab/mutfak"
- **Suno Prompt:** "playful experimental groove, rhodes piano, plucked bass, soft percussion, creative lab atmosphere, Eb major, 100 BPM, puzzle game, no vocals, stereo, seamless loop, high quality"

#### level_quest (yeni)
- **BPM:** 112 | **Key:** G Maj | **Sure:** 150sn
- **Enstrumantasyon:** Pizzicato strings, acoustic guitar, gentle brass hints
- **Mood:** Ilerleme, macera, "yolculuk"
- **Suno Prompt:** "adventure quest music, pizzicato strings, acoustic guitar, gentle progression, journey feel, G major, 112 BPM, game level music, no vocals, stereo, seamless loop, high quality"

#### daily_ritual (yeni)
- **BPM:** 92 | **Key:** D Maj | **Sure:** 120sn
- **Enstrumantasyon:** Akustik gitar, kalimba, soft shaker
- **Mood:** Rutin, rahatlatici ama odakli
- **Suno Prompt:** "gentle daily ritual music, acoustic guitar, kalimba, soft shaker, calm and focused, D major, 92 BPM, daily puzzle game, no vocals, stereo, seamless loop, high quality"

#### duel_arena (yeni)
- **BPM:** 130 | **Key:** A min | **Sure:** 120sn
- **Enstrumantasyon:** Aggressive electronic, sidechained bass, glitch percussion
- **Mood:** Rekabetci, adrenalin
- **1.15x speed:** Zorunlu test
- **Suno Prompt:** "competitive electronic game music, aggressive synth, sidechained bass, glitch percussion, PvP arena battle, A minor, 130 BPM, intense and driven, no vocals, stereo, seamless loop, high quality"

#### menu_chill (yeni)
- **BPM:** 78 | **Key:** Bb Maj | **Sure:** 150sn
- **Enstrumantasyon:** Darker lofi, night variant, deeper pad
- **Mood:** Gece, sakin, menu_lofi'nin karanlik versiyonu
- **Suno Prompt:** "dark lofi chill night music, deep synth pad, soft vinyl, muted drums, late night atmosphere, Bb major, 78 BPM, game menu night variant, no vocals, stereo, seamless loop, high quality"

#### tension_escalation (yeni)
- **BPM:** 124 | **Key:** C min | **Sure:** 120sn
- **Enstrumantasyon:** Cinematic strings, evolving tension, game_tension'dan farkli (daha cinematik)
- **Mood:** Grid %70+ doluyken crossfade hedefi
- **Suno Prompt:** "cinematic tension escalation, building strings, dramatic suspense, game pressure increasing, C minor, 124 BPM, orchestral electronic hybrid, no vocals, stereo, seamless loop, high quality"

### 3.3 Teknik Spec — Tum Muzik

| Parametre | Deger |
|-----------|-------|
| Calisma formati | WAV 44.1kHz 24-bit stereo |
| Export | .mp3 stereo 44.1kHz 192 kbps CBR |
| Loudness | -14 LUFS integrated, -1 dBTP true peak |
| SFX Boslugu | 800Hz-2kHz notch (-4 ile -8 dB arasi) |
| Loop | Sample-accurate seamless (son 100ms xfade, beat-aligned) |
| 1.15x speed | Duel + TimeTrial parcalarinda zorunlu test |
| Gloo Chime | menu_lofi intro + melodiye gomulu referanslar |

### 3.4 Mod-Muzik Esleme Tablosu

| Mod / Durum | Mevcut Muzik | Yeni Muzik |
|-------------|-------------|------------|
| HomeScreen | menu_lofi | menu_lofi (gece: menu_chill alternating) |
| Classic | game_relax | game_relax |
| ColorChef | game_relax | colorchef_groove |
| Level | game_relax | level_quest |
| Daily | game_relax | daily_ritual |
| TimeTrial | game_tension | game_tension |
| Duel | game_tension | duel_arena |
| Zen | zen_ambient | zen_ambient |
| Grid >=70% | crossfade → game_tension | crossfade → tension_escalation |

### 3.5 Sessizlik Stratejisi (Odul Seviyesi Fark)

Kritik anlarda SFX oncesinde kasitli sessizlik — dramatik etki:

| An | Sessizlik Suresi | Neden |
|----|-----------------|-------|
| game_over oncesi | 150ms | "Bir sey bitti" hissini kurar |
| combo_epic oncesi | 80ms | Doruk ani vurgular |
| level_complete oncesi | 100ms | Basariyi belirginlestirir |
| Zen modu | Dogal sessizlik | Muzik zaten minimal, SFX araliklari genis |

---

## 4. Mix Hiyerarsisi

| Oncelik | Ses | Volume Hedefi |
|---------|-----|--------------|
| 1 (en yuksek) | Sentez (color_synthesis) | -6 dBFS |
| 2 | Combo (tier bazli) | -8 ile -4 dBFS |
| 3 | Line clear | -10 dBFS |
| 4 | Gel place | -14 dBFS |
| 5 | Muzik | -18 dBFS (SFX altinda) |
| 6 | UI (button_tap) | -20 dBFS |

Ducking matrisi (mevcut AudioManager'da implementeli):
- Epic/large combo → muzik %50 volume, 500ms
- Bomb explosion → muzik %50 volume, 500ms
- Grid %70+ → relax→tension crossfade

---

## 5. Uygulama Sirasi

### Faz 1: Standard Paket Stereo Revizyon
1. 11 stereo SFX uretimi (AI + post-processing)
2. 21 mono SFX kalite yukseltmesi (AI + post-processing)
3. 4 muzik yeniden uretimi (Suno/Udio)
4. combo_epic.m4a sample rate duzeltmesi
5. Tum dosyalari assets/ klasorune yerlestir, test et

### Faz 2: 6 Yeni Muzik Parcasi
1. 6 muzik uretimi (Suno/Udio)
2. Mod-bazli muzik secim mantigi guncelle (audio_constants.dart)
3. Kod degisikligi: yeni AudioPaths + mod-muzik eslesmesi

### Faz 3: Crystal ASMR + Deep Forest (mevcut brief)

---

## 6. Kod Degisiklikleri

### Faz 1 icin: SIFIR
Mevcut mono dosyalari stereo ile degistirmek drop-in. `just_audio` otomatik handle eder.

### Faz 2 icin:
- `audio_constants.dart`: 6 yeni muzik path + mod-bazli secim map'i
- `audio_manager.dart`: `_musicForMode(GameMode)` helper (veya mevcut `playMusic` cagrilarini guncelle)
- `game_screen.dart` / `game_callbacks.dart`: Mod bazli muzik baslat (Bolum 3.4 tablosuna gore)
- `game_callbacks.dart`: Sessizlik gap'leri — `Future.delayed` ile game_over (150ms), combo_epic (80ms), level_complete (100ms) SFX oncesi bekleme
- `home_screen.dart`: menu_chill alternasyon — saat bazli (21:00-06:00 arasi menu_chill, diger saatler menu_lofi) veya `Random` bazli %30 sans

---

## 7. Kabul Kriterleri

- [ ] 32 SFX Jel DNA katman yapisina uygun
- [ ] 11 SFX stereo, phase cancellation testi gecmis
- [ ] 21 SFX mono, kalite yukseltilmis (placeholder degil)
- [ ] Gloo Chime (C5-E5-G5) tutarli sekilde entegre
- [ ] 10 muzik parcasi stereo, -14 LUFS, seamless loop
- [ ] SFX Boslugu (800Hz-2kHz) tum muziklerde mevcut
- [ ] combo_epic.m4a 48kHz normalize
- [ ] Boyut butcesi < 35MB (veya muzik streaming ile < 10MB)
- [ ] 1.15x speed testi gecmis (duel, timeTrial parcalari)
- [ ] Tum mevcut testler geciyor (2155/2155)
