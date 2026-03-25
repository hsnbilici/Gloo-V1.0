# Gloo v1.0 — Kalan Gorevler

> Son guncelleme: 2026-03-26
> **Test:** 2272/2272 PASS | **Analyze:** 0 warning

---

## Bu Oturumda Tamamlananlar

- [x] CLAUDE.md temizligi + trim
- [x] _dev/ dosya temizligi (tamamlanan spec/plan silindi)
- [x] DnD polish: haptic, grid-orantili scale, fade-in, merkez anchor, 53 test
- [x] Bug fix: GelCellPainter koyu renk floor, ice yerlestirme engeli, QuestBar detay, leaderboard hata, level skor reset, level 11-20 cesitlilik, collection recete ipucu
- [x] CI fix: 2 warning
- [x] Loading screen: "Nefes Alan Logo" animasyonlu splash
- [x] **CD.28** Adaptif zorluk: 4 eksenli beceri profili + radar chart + kaldıraclar
- [x] **CD.27a** Arkadas sistemi: follow/arkadas modeli + friends screen + leaderboard tab + WeeklyRivalCard
- [x] **CD.27b** Profil sayfasi: MyProfileScreen + ProfileScreen + get_user_profile RPC
- [x] Supabase migration'lari uygulandi (7 migration + 1 RLS fix)
- [x] 3x code review + tum bulgular fixlendi
- [x] l10n: 40+ yeni string, 12 dil
- [x] Gereksiz dosya temizligi (483MB worktree artigi silindi)
- [x] **CD.27c** Challenge/Invite sistemi Phase 1: migration, models, 6 EF, repository, provider, l10n 12 dil, UI (tabs, cards, sheet, reveal overlay, banner), GameScreen entegrasyonu, 4 integration point, notification
- [x] **CD.27c** Code review fix: C1 l10n interpolation (12 dosya), C2 recipientScore param, C3 accept navigation, I1 overlay l10n, I2 pending+active filter, I3 dark-only bg fix, I4 sheet l10n, I5 deep link challengeId, I6 deduct_balance cleanup, I7 /challenges tab

---

## Seni Bekleyen (Manuel/Harici)

### Ses Uretimi
- [ ] 11 stereo SFX uret (ElevenLabs) → `assets/audio/sfx/`
- [ ] 21 mono SFX kalite yukselt (ElevenLabs) → `assets/audio/sfx/`
- [ ] 4 muzik revize (Suno/Udio) → `assets/audio/music/`
- [ ] 6 yeni muzik uret (Suno/Udio) → `assets/audio/music/`
- [ ] Simulatorde tam test + boyut kontrolu
- Post-processing: SFX -6dBFS, `.ogg`+`.m4a` | Muzik -14LUFS, `.mp3` 192kbps

### Harici Sanatci/Tasarimci
- [ ] 8 GelPersonality karakter ilustrasyonu
- [ ] 5 bina + ada arka plan ilustrasyonu
- [ ] Season Pass gorsel odulleri

### Store Submission
- [ ] Play Console service account + PLAY_SERVICE_ACCOUNT_JSON
- [ ] Play Store metadata (screenshots, feature graphic)
- [ ] iOS entitlements aps-environment → production
- [ ] `assetlinks.json` → gloogame.com/.well-known/
- [ ] `apple-app-site-association` → gloogame.com/.well-known/

---

## Kod Acik Maddeler (Dusuk Oncelik)

- [ ] FriendRepository test dosyasi (mock-based)
- [ ] Friends tab mode filtresi (chip toggle — su an sadece Classic)
- [ ] Deep link auto-follow (su an sadece pre-fill)
- [ ] Follow notification (push bildirim)
- [ ] Adaptif zorluk comboSetup kaldiraci (Phase 2)

## BLOCKED

- [ ] **GD.MGO7 — Ada binalari gating:** gorsel entegrasyon icerik bekliyor

## Vizyon Genisletme (Uzun Vade)

- [ ] **CD.26** Sezonsal icerik dongusu
- [x] **CD.27c** Davet/challenge sistemi — Phase 1 (async Score Battle) TAMAMLANDI
- [x] **CD.27a** Arkadas sistemi (TAMAMLANDI)
- [x] **CD.27b** Profil sayfasi (TAMAMLANDI)
- [x] **CD.28** Adaptif zorluk (TAMAMLANDI)
