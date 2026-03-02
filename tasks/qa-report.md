# QA Raporu — Gloo v1.0

> Son guncelleme: 2026-03-02 | Sprint 17 sonrasi
> flutter analyze: 0 issue | flutter test: 1204/1204

---

## Platform Durumu

| Platform | Durum | Not |
|----------|-------|-----|
| Web (Chrome/Edge) | Calisir | |
| Android | Calisir | AVD Gloo_Pixel8 |
| iOS | Calisir | Xcode 26.3, iPhone 16e Simulator |

---

## Tamamlanan Duzeltmeler (Bu Oturum)

| Sprint | Duzeltme |
|--------|----------|
| 14 | Firebase App Check entegrasyonu (Play Integrity + App Attest) |
| 15 | K.1-K.4: isConfigured guard, kDebugMode wrap, try-catch, GDPR |
| 16 | debugNeedsLayout crash fix (addPostFrameCallback) |
| 16 | Bottom overflow fix (resizeToAvoidBottomInset: false) |
| 17 | Android release keystore + CI signing + workflow permissions |

---

## Bilinen Kisitlamalar

| Alan | Not |
|------|-----|
| AdMob | Test ID aktif — uretime geciste gercek ID gerekli |
| Firebase App Check | Kod hazir — Console enforce adimi bekleniyor |
| Android signing | Keystore yerel — GitHub Secrets yuklenmesi kaldi |
| Store submission | Apple + Google hesap dogrulama bekleniyor |
