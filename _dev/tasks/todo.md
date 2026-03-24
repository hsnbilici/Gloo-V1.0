# Gloo v1.0 — Kalan Gorevler

> Son guncelleme: 2026-03-25
> **Test:** 2188/2188 PASS | **Yaratici Skor:** 4.1/5.0

---

## Bu Oturumda Tamamlananlar

- [x] CLAUDE.md temizligi + trim (453→405 satir)
- [x] _dev/ dosya temizligi (tamamlanan spec/plan silindi)
- [x] DnD polish: haptic feedback, grid-orantili scale, placement fade-in, merkez anchor (3-4lu sekiller)
- [x] Bug fix: GelCellPainter koyu renk floor (maroon/brown)
- [x] Bug fix: QuestBar genisletilebilir detay paneli
- [x] Bug fix: Leaderboard hata yakalama + SQL migration fix
- [x] Bug fix: Level mod skor reset + level 11-20 cesitlilik
- [x] Bug fix: Collection ekrani recete ipucu (kilitli kartlarda)
- [x] CI fix: 2 warning duzeltildi (override, unused variable)
- [x] Loading screen: "Nefes Alan Logo" animasyonlu splash
- [x] **CD.28** Adaptif zorluk: 4 eksenli beceri profili + radar chart + kaldıraclar

## Aktif: Stereo Ses Revizyonu (Kod tamamlandi — ses uretimi bekliyor)

**Kod (TAMAMLANDI):** AudioPaths + musicForMode, mod-bazli muzik, grid crossfade, sessizlik gap'leri.

**Ses Uretimi (SENi BEKLiYOR):**
- [ ] 11 stereo SFX uret (ElevenLabs) → `assets/audio/sfx/` uzerine yaz
- [ ] 21 mono SFX kalite yukselt (ElevenLabs) → `assets/audio/sfx/` uzerine yaz
- [ ] 4 muzik revize (Suno/Udio) → `assets/audio/music/` uzerine yaz
- [ ] 6 yeni muzik uret (Suno/Udio) → `assets/audio/music/` yeni dosyalar
- [ ] Simulatorde tam test + boyut kontrolu

**Post-processing hatirlatma:**
- SFX: -6 dBFS, plate reverb 200-400ms, `.ogg` Vorbis + `.m4a` AAC-LC
- Muzik: -14 LUFS, 800Hz-2kHz notch, seamless loop, `.mp3` 192kbps

---

## Harici Sanatci/Tasarimci Bekleniyor

- [ ] 8 GelPersonality karakter ilustrasyonu (brief: `_dev/briefs/character_design_brief.md`)
- [ ] 5 bina + ada arka plan ilustrasyonu (brief: `_dev/briefs/island_design_brief.md`)
- [ ] Season Pass gorsel odulleri (tablo: `_dev/briefs/season_pass_tiers.md`)

## Manuel / Harici Isler (Store Submission Oncesi)

- [ ] Play Console service account + PLAY_SERVICE_ACCOUNT_JSON
- [ ] Play Store metadata (screenshots, feature graphic)
- [ ] iOS entitlements aps-environment → production (release oncesi)
- [ ] `assetlinks.json` → gloogame.com/.well-known/ (Android deep link)
- [ ] `apple-app-site-association` → gloogame.com/.well-known/ (iOS universal link)
- [ ] Supabase migration'lari uygula:
  - `20260325_fix_leaderboard_view_order.sql`
  - `20260325_fix_elo_leaderboard_filter.sql`

## BLOCKED

- [ ] **GD.MGO7 — Ada binalari gating:** gorsel entegrasyon icerik bekliyor

## Vizyon Genisletme (Uzun Vade)

- [ ] **CD.26** Sezonsal icerik dongusu
- [ ] **CD.27** Sosyal ozellikler
- [x] **CD.28** Adaptif zorluk (TAMAMLANDI)
