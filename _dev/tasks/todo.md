# Gloo v1.0 — Kalan Gorevler

> Son guncelleme: 2026-03-23
> **Durum:** 175/180 gorev tamamlandi | Kalan 5 gorev

---

## Yaratici Sprint — Kisa Vadeli (Creative Director Raporu)

- [x] **CD.1 — Meta-game UI'yi ac:** MetaGameBar HomeScreen'e geri getirildi (QuestBar altina)
- [x] **CD.2 — Sentez anini vurgula:** Hucre glow efekti + synthesisGlowCells sistemi eklendi
- [x] **CD.3 — Jel gorunumu:** radiusXs 4→6px (tum grid hucreleri otomatik etkilendi)
- [x] **CD.4 — Light tema kontrast:** 6 renk koyulastirildi, tumu WCAG AA PASS (4.5:1+)
- [x] **CD.5 — HomeScreen sadele:** DailyBanner kompakt (tek satir), QuickPlayBanner padding azaltildi

### Backlog (Code Review Bulgulari)

- [ ] **CR.1 — CellRenderData copyWith metodu:** Reconstruction bloklarinda flag kaybi riski — her yeni boolean alan tum reconstruction sitelerini guncellemeyi gerektiriyor. `copyWith` metodu ile bu hata sinifi onlenebilir.
- [ ] **CR.2 — Sentez glow per-cell timer:** Coklu sentezde tum hucreler tek timer ile temizleniyor — ilk sentez hucresi fazla uzun glowluyor. Per-cell timestamp yaklasimiyla duzeltilmeli.
- [ ] **CR.3 — Shop tab testleri:** TabBarView yapisi nedeniyle 10 shop testi basarisiz — widget'lar farkli tab'larda bulunuyor ama test scroll ile ariyor.
- [ ] **CR.4 — SoundBank testleri:** 8 sound_bank_test basarisiz — pre-existing, mock interface uyumsuzlugu.

---

## BLOCKED

- [ ] **GD.MGO7 — Ada binalari gating:** arena->PvP, harbor->SeasonPass, factory->pasif uretim (M efor)
  - MetaGameBar acildi (CD.1) ama ada binalari icin icerik/balans calismasi gerekli

## Manuel / Harici Isler

- [ ] Play Console service account + PLAY_SERVICE_ACCOUNT_JSON
- [ ] Play Store metadata tamamla (screenshots, feature graphic)
- [ ] Entegrasyon testleri (cihaz/emulator gerekli)
- [ ] Terms of Service sayfasi (docs/)
