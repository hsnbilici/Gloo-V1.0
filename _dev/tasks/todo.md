# Gloo v1.0 — Kalan Gorevler

> Son guncelleme: 2026-03-25
> **Test:** 2243/2243 PASS | **Analyze:** 0 warning

---

## Bu Oturumda Tamamlananlar

- [x] CLAUDE.md temizligi + trim (453→427 satir)
- [x] _dev/ dosya temizligi (tamamlanan spec/plan silindi)
- [x] DnD polish: haptic feedback, grid-orantili scale, placement fade-in, merkez anchor
- [x] DnD fix: 1-2 hucre cellCount guard + 53 anchor testi
- [x] Bug fix: GelCellPainter koyu renk floor (maroon/brown)
- [x] Bug fix: Ice hucreleri yerlestirme engelliyor (iceLayer > 0)
- [x] Bug fix: QuestBar genisletilebilir detay paneli
- [x] Bug fix: Leaderboard hata yakalama + SQL migration fix
- [x] Bug fix: Level mod skor reset + level 11-20 cesitlilik
- [x] Bug fix: Collection ekrani recete ipucu (kilitli kartlarda)
- [x] CI fix: 2 warning duzeltildi (override, unused variable)
- [x] Loading screen: "Nefes Alan Logo" animasyonlu splash
- [x] **CD.28** Adaptif zorluk: 4 eksenli beceri profili + radar chart + kaldıraclar
- [x] **CD.27a** Arkadas sistemi: follow/arkadas modeli + friends screen + leaderboard tab + WeeklyRivalCard
- [x] l10n: hardcoded English strings lokalize edildi

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
  - `20260325_add_friend_code.sql`
  - `20260325_create_follows.sql`
  - `20260325_friends_leaderboard_view.sql`
  - `20260325_get_friends_rank.sql`

## Kod Acik Maddeler (Dusuk Oncelik)

- [ ] FriendRepository test dosyasi (mock-based)
- [ ] Friends tab mode filtresi (chip toggle — su an sadece Classic)
- [ ] Deep link auto-follow (su an sadece pre-fill)
- [ ] Follow notification (push bildirim)
- [ ] Adaptif zorluk comboSetup kaldiraci (Phase 2)
- [ ] profiles_select_search RLS kisitlama (SELECT tum kolonlari aciyor)

## BLOCKED

- [ ] **GD.MGO7 — Ada binalari gating:** gorsel entegrasyon icerik bekliyor

## Vizyon Genisletme (Uzun Vade)

- [ ] **CD.26** Sezonsal icerik dongusu
- [x] **CD.27a** Arkadas sistemi (TAMAMLANDI)
- [ ] **CD.27b** Profil sayfasi
- [ ] **CD.27c** Davet/challenge sistemi
- [x] **CD.28** Adaptif zorluk (TAMAMLANDI)
