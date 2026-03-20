# Gloo v1.0 — Yol Haritasi

> Son guncelleme: 2026-03-21
> **Durum:** 88/88 gorev tamamlandi | 7 Expert Audit yapildi
> flutter analyze: 0 error | flutter test: 2057 (golden haric)
> **Proje skoru:** 98 / 100 (expert audit sonrasi)

---

## Tamamlanan Manuel Aksiyonlar

- [x] **M.1 — Firebase App Check enforce:** Play Integrity (Android) + App Attest (iOS) kayitli
- [x] **M.2 — GitHub Secrets ekle:** 6 secret eklendi
- [x] **M.3 — Firebase API key rotation:** iOS + Android key'ler rotate edildi
- [x] **M.4 — git rm --cached:** google-services.json + GoogleService-Info.plist tracking'den cikarildi
- [x] **M.5 — updateElo Supabase RPC:** `update-elo` Edge Function deploy edildi
- [x] **M.6 — Privacy policy + store metadata:** GitHub Pages'te yayinda

---

## Tamamlanan Kod Gorevleri (33/33 + CI fix)

| Sprint | Tamamlanan | Gorevler |
|--------|:----------:|----------|
| Sprint 1 | 13/13 | B.1, D.1, D.2, D.3, E.1, F.1, F.2, F.4, F.7, C.2, B.3, F.3, A.2 |
| Sprint 2 | 10/10 | B.2, B.4, C.4, D.4, D.5, E.2, E.3, E.4, E.5, F.5 |
| Sprint 3 | 10/10 | A.1, A.3, A.4, B.5, C.1, C.3, D.6, D.7, E.6, F.6 |
| Post | +1 | TestFlight version bump race condition duzeltildi |

---

## Expert Audit Bulgulari (2026-03-21)

### KRITIK (Bu Hafta)

- [x] **S.1 — Android IAP dogrulama:** Google Play Developer API v3 entegrasyonu ✅
- [x] **S.2 — key.properties:** Zaten gitignore'd, tracked degil. key.properties.example eklendi ✅
- [x] **S.3 — iOS certificate pinning:** ATS explicit HTTPS + CertificatePinningPlugin.swift zaten mevcut ✅

### YUKSEK ONCELIK (Bu Sprint)

- [x] **P.1 — Cell widget rebuild izolasyonu:** `CellStateProvider(row, col)` ile izole rebuild (performans +15-25%) ✅
- [x] **P.2 — Synthesis detection cache:** Modified-zone taramasi ile O(n²) → O(k) ✅
- [x] **P.3 — AnimationController konsolidasyonu:** 200+ controller → tek global effect manager ✅
- [x] **P.4 — PvP stream controller leak:** Closed controller'lari listeden cikart ✅
- [x] **T.1 — game_interactions_test.dart:** 16 test ✅
- [x] **T.2 — game_callbacks_test.dart:** 18 test ✅
- [x] **T.3 — game_grid_builder_test.dart:** 16 test ✅
- [x] **T.4 — game_duel_controller_test.dart:** 18 test ✅
- [x] **S.4 — verify-purchase atomic RPC:** `append_purchased_product` RPC + migration ✅
- [x] **S.5 — Subscription expiry validation:** 35 gun + grace period kontrolu ✅

### ORTA ONCELIK (Bu Ay)

- [x] **U.1 — Light tema renk sabitleri:** 30+ renk eklendi ✅
- [x] **U.2 — Semantics label audit:** 11 interaktif elemente Semantics eklendi ✅
- [x] **U.3 — Text overflow korumasi:** 18 widget'ta maxLines + ellipsis ✅
- [x] **D.1 — Test paralelizasyonu:** `--concurrency 8` eklendi ✅
- [x] **D.2 — Coverage threshold:** %60 → %70 ✅
- [x] **D.3 — Edge Function input validation:** length + format kontrolu eklendi ✅
- [x] **P.5 — Cascade early exit:** Grid hash check eklendi ✅
- [x] **B.1 — Backoff jitter:** Random jitter eklendi ✅

### DUSUK ONCELIK (Gelecek Sprint)

- [x] **D.4 — Leaderboard rank RPC:** Iki sorgu yerine tek server-side transaction ✅
- [x] **T.5 — Shop logic mixin testi:** 12 test ✅
- [x] **T.6 — Matchmaking ELO edge case testleri:** 23 test ✅
- [x] **U.4 — Animation duration sabitleri:** `AnimationDurations` class'i `ui_constants.dart`'a ✅
- [x] **D.5 — Web deployment:** GitHub Pages deploy job eklendi ✅
- [x] **D.6 — SBOM uretimi:** Syft ile SPDX + CycloneDX raporu ✅

### ONCEKI BEKLEYEN ISLER

- [ ] Play Console service account + PLAY_SERVICE_ACCOUNT_JSON
- [ ] Play Store metadata tamamla (screenshots, feature graphic)
- [ ] Entegrasyon testleri (cihaz/emulator gerekli)
- [ ] Terms of Service sayfasi (docs/)

---

## Ozet Tablo

| Kategori | Tamamlanan | Toplam |
|----------|:----------:|:------:|
| Onceki gorevler (P0-P3 + Growth + 100-Plan + Manuel) | 88/88 | 88 |
| Kritik (Bu Hafta) | 3/3 | 3 |
| Yuksek Oncelik (Bu Sprint) | 10/10 | 10 |
| Orta Oncelik (Bu Ay) | 8/8 | 8 |
| Dusuk Oncelik | 6/6 | 6 |
| Onceki Bekleyen | 0/4 | 4 |
| **Toplam** | **115/119** | **119** |

**115/119 gorev tamamlandi (%97). Kalan 4 gorev: onceki bekleyen (manual aksiyonlar).**
**Test sayisi: 2057 (1947 → +110 yeni test)**
