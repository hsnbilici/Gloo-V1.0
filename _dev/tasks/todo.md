# Gloo v1.0 — Kalan Gorevler

> Son guncelleme: 2026-03-23
> **Durum:** 194/198 gorev tamamlandi | Kalan 4 gorev + backlog + uzun vadeli

---

## Uzun Vadeli — Vizyon Genisletme

- [ ] **CD.12 — Maskot/Karakter Tasarimi** (Cok Yuksek etki)
  - Jel bazli karakter ailesi, her sentez rengi bir kisilik
  - **Altyapi:** CharacterState + CharacterScreen TAM implemente (kostum, yetenek, energy). Route `/character` aktif.
  - **Eksik:** Gorsel karakter asset'leri (ilustrasyon/animasyon), kisilik tanimlari, onboarding entegrasyonu
  - **Bagimlilik:** Gorsel asset uretimi (ilustrator gerekli)

- [ ] **CD.13 — Ada Sistemi Tam Entegrasyon** (Yuksek etki)
  - 5 bina fonksiyonel, gorsel ada buyuyor, binalar animasyonlu
  - **Altyapi:** IslandState + IslandScreen TAM implemente (5 bina, upgrade, pasif uretim). Route `/island` aktif. MetaGameBar acildi (CD.1).
  - **Eksik:** Ada gorsel asset'leri, bina animasyonlari, core loop baglantisi (oyun sonu → ada guncelleme), arena→PvP ve harbor→SeasonPass gating
  - **Bagimlilik:** GD.MGO7 (BLOCKED gorev) ile ortak

- [ ] **CD.14 — Sosyal/Viralite Katmani** (Yuksek etki)
  - Daily sonuc paylasimi (Wordle formati), Duel davet, Collection paylasimi
  - **Altyapi:** ShareManager 3 metod hazir (`shareScore`, `shareDailyResult`, `shareComboResult`). l10n, analytics entegre.
  - **Eksik:** Wordle-format emoji grid, deep link davet sistemi, Collection paylasim UI, share card gorseli
  - **Bagimlilik:** Deep link altyapisi (Firebase Dynamic Links veya app_links)

- [ ] **CD.15 — ASMR Ses Paketleri** (Orta etki)
  - Alternatif ses paketleri (orman, yagmur, deniz) + jel uzerine ambient katman
  - **Altyapi:** AudioConstants'ta Faz 4 frekans haritasi tanimli. SoundBank 19 metod, AudioManager 8 kanal.
  - **Eksik:** Ses paketi degistirme mekanizmasi (AudioManager'da `setAudioPackage()` yok — asset path swap gerekli), ASMR ses dosyalari uretimi, Shop'ta paket satin alma UI
  - **Bagimlilik:** Ses asset uretimi (ses tasarimcisi gerekli), Shop entegrasyonu

---

## Backlog (Code Review Onerileri)

- [ ] **CR.6-S1 — SquashStretch + Pulse scale carpimi:** 1.12 * 1.15 = 1.29x — gorsel kontrol gerekli
- [ ] **CR.6-S2 — SynthesisPulseCell 300ms magic number:** `AnimationDurations` sabiti ekle
- [ ] **CR.1 — CellRenderData copyWith metodu**
- [ ] **CR.2 — Sentez glow per-cell timer**
- [ ] **CR.3 — Shop tab testleri** (pre-existing)
- [ ] **CR.4 — SoundBank testleri** (pre-existing)

---

## BLOCKED

- [ ] **GD.MGO7 — Ada binalari gating:** MetaGameBar acildi ama icerik/balans calismasi gerekli (CD.13 ile ortak)

## Manuel / Harici Isler

- [ ] Play Console service account + PLAY_SERVICE_ACCOUNT_JSON
- [ ] Play Store metadata tamamla (screenshots, feature graphic)
- [ ] Entegrasyon testleri (cihaz/emulator gerekli)
- [ ] Terms of Service sayfasi (docs/)
- [ ] **APNs sertifikasi (p8 key) Firebase'e yukle** (CD.11)
- [ ] **Firebase Console Cloud Messaging aktif et** (CD.11)
- [ ] **iOS entitlements aps-environment → production** (release oncesi)
