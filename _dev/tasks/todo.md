# Gloo v1.0 — Kalan Gorevler

> Son guncelleme: 2026-03-23
> **Test:** 2151/2151 PASS | **Yaratici Skor:** 4.0/5.0

---

## Backlog (Code Review Onerileri — Dusuk Oncelik)

- [ ] **CR.31-S1 — kWorldTips UI entegrasyonu:** `tips.dart`'taki 4 tip tanimli ama hicbir widget tarafindan tuketilmiyor. Loading screen veya game-over tip olarak bagla.
- [ ] **CR.31-S2 — Epic toast Duel modu guard:** Duel'da zaman baskisi altinda motivasyon toast'i dikkat dagitabilir. `widget.mode != GameMode.duel` guard ekle.
- [ ] **CR.31-S3 — rankLabel kelime sirasi l10n:** `'$elo ${l.rankLabel}'` format tum dillerde dogru olmayabilir (JP/KO). `eloDisplay(int)` interpolated l10n metodu tercih et.

---

## BLOCKED

- [ ] **GD.MGO7 — Ada binalari gating:** Arena→PvP, harbor→SeasonPass UI gating (gorsel entegrasyon icerik bekliyor)

## Manuel / Harici Isler

- [ ] Play Console service account + PLAY_SERVICE_ACCOUNT_JSON
- [ ] Play Store metadata tamamla (screenshots, feature graphic)
- [ ] Entegrasyon testleri (cihaz/emulator gerekli)
- [ ] Terms of Service sayfasi (docs/)
- [ ] APNs sertifikasi (p8 key) Firebase'e yukle
- [ ] Firebase Console Cloud Messaging aktif et
- [ ] iOS entitlements aps-environment → production (release oncesi)

## Asset Uretimi Bekleyen (Harici Kaynak)

- [ ] **CD.16** Karakter gorsel tasarimi — 8 GelPersonality ilustrasyon (gorsel sanatci)
- [ ] **CD.17** Ada ilustrasyonlari — 5 bina + arka plan + animasyon (gorsel sanatci)
- [ ] **CD.18** Ses paketi icerikleri — crystalAsmr + deepForest SFX (ses tasarimcisi)
- [ ] **CD.19** 5-8 ek muzik parcasi — mod bazli loop'lar (muzik bestecisi)
- [ ] **CD.20** Season Pass tier icerikleri — 50 tier odul + gorseller (icerik + sanatci)
- [ ] Deep link altyapisi — Firebase Dynamic Links veya app_links

## Vizyon Genisletme (Uzun Vade)

- [ ] **CD.26** Sezonsal icerik dongusu (Season Pass + sezonsal tema)
- [ ] **CD.27** Sosyal ozellikler (arkadas listesi, duel davet)
- [ ] **CD.28** Adaptif zorluk (oyuncu profilleme + dinamik RNG)
