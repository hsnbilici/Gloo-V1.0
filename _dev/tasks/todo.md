# Gloo v1.0 — Kalan Gorevler

> Son guncelleme: 2026-03-23
> **Durum:** 186/194 gorev tamamlandi | Kalan 8 gorev + backlog

---

## Yaratici Sprint — Kisa Vadeli

- [x] **CD.1 — Meta-game UI'yi ac:** MetaGameBar HomeScreen'e geri getirildi
- [x] **CD.2 — Sentez anini vurgula:** Hucre glow efekti + synthesisGlowCells sistemi
- [x] **CD.3 — Jel gorunumu:** radiusXs 4→6px
- [x] **CD.4 — Light tema kontrast:** 6 renk koyulastirildi, WCAG AA PASS
- [x] **CD.5 — HomeScreen sadele:** DailyBanner kompakt, QuickPlayBanner padding

## Yaratici Sprint — Orta Vadeli

- [x] **CD.6 — Jel morph efekti:** GelCellPainter isGlowing + SynthesisPulseCell 300ms pulse
- [x] **CD.10 — Gorev sistemi:** Quest id field, 12 gunluk gorev, haftalik tracking + UI
- [x] **CD.11 — Push notification:** FirebaseNotificationService + 3 senaryo + 12 dil l10n

---

## Backlog — Kritik (Code Review)

### CD.11 Notification Fixes (3 kritik + 3 onemli)
- [ ] **CR.11-C1 — main.dart throwaway instance:** `FirebaseNotificationService()` singleton yerine yeni instance olusturuyor. Provider instance uzerinden initialize edilmeli.
- [ ] **CR.11-C2 — Token sync eksik:** `saveDeviceToken` hic cagirilmiyor, `onTokenRefresh` listener no-op. Callback/repository inject edilmeli.
- [ ] **CR.11-C3 — requestPermission hic cagirilmiyor:** iOS ve Android 13+ icin push izni istenmemis. `initialize()` icinde veya ilk schedule oncesinde cagrilmali.
- [ ] **CR.11-I1 — Lifecycle observer eksik:** Comeback notification foreground'da iptal/reschedule yapilmiyor. `WidgetsBindingObserver` ekle.
- [ ] **CR.11-I2 — Provider dispose eksik:** `ref.onDispose` ile `_tokenRefreshSub` cancel edilmeli.
- [ ] **CR.11-I3 — Settings toggle eksik:** Notification enable/disable toggle Settings'te yok.

### CD.10 Quest Fixes (2 kritik + 3 onemli)
- [ ] **CR.10-C1 — d_rs500 quest imkansiz:** `reachScore` callback 1 artiriyor ama target 500. Ya callback score bazli artirmali ya da target 1 olmali.
- [ ] **CR.10-C2 — Eski progress key migration yok:** Guncelleme yapan kullanicilar gunluk ilerlemelerini kaybedecek. Tek seferlik migration gerekli.
- [ ] **CR.10-I1 — ISO week number edge case:** Yil siniri duzeltilmeli (Thursday-based ISO year).
- [ ] **CR.10-I2 — useColorSynthesis enum kaldirilmali:** Dead code, spec'te belirtilmis.
- [ ] **CR.10-I3 — 'Weekly' string hardcoded:** L10n key eklenmeli.

### CD.6 Visual (oneriler)
- [ ] **CR.6-S1 — SquashStretch + Pulse scale carpimi:** 1.12 * 1.15 = 1.29x — gorsel kontrol gerekli.
- [ ] **CR.6-S2 — SynthesisPulseCell 300ms magic number:** `AnimationDurations` sabiti ekle.

### Onceki Backlog
- [ ] **CR.1 — CellRenderData copyWith metodu**
- [ ] **CR.2 — Sentez glow per-cell timer**
- [ ] **CR.3 — Shop tab testleri** (pre-existing)
- [ ] **CR.4 — SoundBank testleri** (pre-existing)

---

## BLOCKED

- [ ] **GD.MGO7 — Ada binalari gating:** MetaGameBar acildi ama icerik/balans calismasi gerekli

## Manuel / Harici Isler

- [ ] Play Console service account + PLAY_SERVICE_ACCOUNT_JSON
- [ ] Play Store metadata tamamla (screenshots, feature graphic)
- [ ] Entegrasyon testleri (cihaz/emulator gerekli)
- [ ] Terms of Service sayfasi (docs/)
- [ ] **APNs sertifikasi (p8 key) Firebase'e yukle** (CD.11)
- [ ] **Firebase Console Cloud Messaging aktif et** (CD.11)
- [ ] **iOS entitlements aps-environment → production** (release oncesi)
