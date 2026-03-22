import 'package:flutter/material.dart';

// ────────────────────────────────────────────────────────────────────────────
// WCAG AA Contrast Ratio Matrix — Light Theme (last audit: 2026-03-22)
//
// Formula: relative luminance L = 0.2126·R + 0.7152·G + 0.0722·B
//          (channels linearised via sRGB gamma; c <= 0.04045 → c/12.92,
//           else → ((c + 0.055) / 1.055) ^ 2.4)
// Ratio:   (L_lighter + 0.05) / (L_darker + 0.05)
// Thresholds: normal text >= 4.5:1 | large text / graphics >= 3:1
//
// Luminance reference values used below:
//   kBgLight              (0xFFF5F5FA)  L = 0.9165
//   kSurfaceLight         (0xFFFFFFFF)  L = 1.0000
//   kCardBgLight          (0xFFFFFFFF)  L = 1.0000
//   kTextPrimaryLight     (0xFF1A1A2E)  L = 0.0116
//   kTextSecondaryLight   (0xFF4A4A6A)  L = 0.0741
//   kCyanLight            (0xFF0097A7)  L = 0.2491
//   kMutedLight           (0xFF7A8FA0)  L = 0.2632
//   kGoldLight            (0xFFC88A00)  L = 0.3048
//   kOrangeLight          (0xFFE65100)  L = 0.2270
//   kGreenLight           (0xFF1B7A3D)  L = 0.1450
//   kRedLight             (0xFFC62828)  L = 0.1368
//   kYellowLight          (0xFFB8860B)  L = 0.2730
//   kPinkLight            (0xFFC2185B)  L = 0.1287
//   kLavenderLight        (0xFF5E35B1)  L = 0.0810
//   kColorClassicLight    (0xFFC62828)  L = 0.1368  (same as kRedLight)
//   kColorChefLight       (0xFFEF6C00)  L = 0.2909
//   kColorTimeTrialLight  (0xFF1565C0)  L = 0.1331
//   kColorZenLight        (0xFF2E7D32)  L = 0.1450  (same as kGreenLight)
//
// ── Pair ───────────────────────────────────────────── Ratio   AA(text) AA(large)
// kBgLight     + kTextPrimaryLight                     15.69:1  PASS     PASS
// kBgLight     + kTextSecondaryLight                    7.79:1  PASS     PASS
// kBgLight     + kGreenLight                            4.96:1  PASS     PASS
// kBgLight     + kRedLight / kColorClassicLight         5.17:1  PASS     PASS
// kBgLight     + kPinkLight                             5.41:1  PASS     PASS
// kBgLight     + kLavenderLight                         7.38:1  PASS     PASS
// kBgLight     + kColorTimeTrialLight                   5.28:1  PASS     PASS
// kBgLight     + kColorZenLight                         4.96:1  PASS     PASS
// kBgLight     + kCyanLight                             3.23:1  FAIL(!)  PASS
// kBgLight     + kMutedLight                            3.08:1  FAIL(!)  PASS
// kBgLight     + kGoldLight                             2.72:1  FAIL(!)  FAIL(!)
// kBgLight     + kOrangeLight                           3.49:1  FAIL(!)  PASS
// kBgLight     + kYellowLight                           2.99:1  FAIL(!)  FAIL(!)
// kBgLight     + kColorChefLight                        2.83:1  FAIL(!)  FAIL(!)
// kSurfaceLight + kTextPrimaryLight                    17.04:1  PASS     PASS
// kSurfaceLight + kTextSecondaryLight                   8.49:1  PASS     PASS
// kSurfaceLight + kMutedLight                           3.35:1  FAIL(!)  PASS
// kSurfaceLight + kCyanLight                            3.51:1  FAIL(!)  PASS
// kSurfaceLight + kGoldLight                            2.96:1  FAIL(!)  FAIL(!)
// kSurfaceLight + kOrangeLight                          3.79:1  FAIL(!)  PASS
// kSurfaceLight + kYellowLight                          3.25:1  FAIL(!)  PASS
// kSurfaceLight + kColorChefLight                       3.08:1  FAIL(!)  PASS
// kCardBgLight  + kTextPrimaryLight                    17.04:1  PASS     PASS
// kCardBgLight  + kMutedLight                           3.35:1  FAIL(!)  PASS
//
// WARNINGS:
// ! kGoldLight  on any light bg — 2.72–2.96:1 — FAILS both thresholds.
//     Do NOT use for text. For decorative / icon use only; pair with a
//     contrasting text colour (e.g. kTextPrimaryLight) if a label is needed.
// ! kYellowLight on any light bg — 2.99–3.25:1 — FAILS normal-text AA.
//     Large text / icons only. Avoid for body copy.
// ! kColorChefLight on light bg — 2.83–3.08:1 — FAILS normal-text AA.
//     Mode badge / large accent only; never use as label text.
// ! kCyanLight / kOrangeLight on light bg — 3.23–3.79:1 — FAIL normal text.
//     Large text (>= 18px regular or >= 14px bold) or graphics only.
// ! kMutedLight on kSurfaceLight / kCardBgLight — 3.35:1 — FAIL normal text.
//     Intended for secondary captions; keep at >= 14px bold or use
//     kTextSecondaryLight (7.79:1) for smaller labels.
// NOTE: kSurfaceLightSecondary (0xFFF0F0F5) is used as card/cell bg, not for
//     text, so its own contrast vs kBgLight is not a text-contrast concern.
// ────────────────────────────────────────────────────────────────────────────

// ─── Arka plan ──────────────────────────────────────────────────────────────
const Color kBgLight = Color(0xFFF5F5FA);
const Color kSurfaceLight = Color(0xFFFFFFFF);
const Color kSurfaceLightSecondary = Color(0xFFF0F0F5);

// ─── Metin ──────────────────────────────────────────────────────────────────
const Color kTextPrimaryLight = Color(0xFF1A1A2E);
const Color kTextSecondaryLight = Color(0xFF4A4A6A);

// ─── Aksan (accent) — koyu temadaki ayni renkler, kontrast ayarli ────────
const Color kCyanLight = Color(0xFF0097A7);
const Color kMutedLight = Color(0xFF7A8FA0);
/// WARNING: WCAG AA FAIL on light backgrounds — DO NOT use for text.
const Color kGoldLight = Color(0xFFC88A00);
const Color kOrangeLight = Color(0xFFE65100);

/// Yesil — basari, tamamlanma gostergeleri (kGreen'in aydinlik karsiti).
const Color kGreenLight = Color(0xFF1B7A3D);

/// Kirmizi — hata, kayip (kRed'in aydinlik karsiti).
const Color kRedLight = Color(0xFFC62828);

/// WARNING: WCAG AA FAIL on light backgrounds — DO NOT use for text.
/// Sari — dikkat, uyari (kYellow'un aydinlik karsiti).
const Color kYellowLight = Color(0xFFB8860B);

/// Pembe — vurgu, season pass (kPink'in aydinlik karsiti).
const Color kPinkLight = Color(0xFFC2185B);

/// Lavanta — karakter, zen premium (kLavender'in aydinlik karsiti).
const Color kLavenderLight = Color(0xFF5E35B1);

/// Mercan — reklamsiz aksani (kCoral'in aydinlik karsiti).
const Color kCoralLight = Color(0xFFD32F2F);

// ─── Mod renkleri (aydinlik arka plan uzerinde okunabilir) ────────────────
const Color kColorClassicLight = Color(0xFFC62828);
const Color kColorChefLight = Color(0xFFEF6C00);
const Color kColorTimeTrialLight = Color(0xFF1565C0);
const Color kColorZenLight = Color(0xFF2E7D32);

// ─── Liga renkleri (aydinlik arka plan icin doygun versiyonlar) ────────────
/// Bronz — PvP bronze liga.
const Color kBronzeLight = Color(0xFF8B5E14);

/// Gumus — PvP silver liga.
const Color kSilverLight = Color(0xFF616161);

/// Elmas mavisi — PvP diamond liga.
const Color kDiamondBlueLight = Color(0xFF0277BD);

/// Gloo Master — PvP en ust liga.
const Color kGlooMasterLight = Color(0xFF9C27B0);

// ─── Power-up renkleri (aydinlik arka plan icin) ──────────────────────────

/// Rotate power-up arka plan (aydinlik).
const Color kPowerUpRotateBgLight = Color(0xFF4DD0E1);

/// Bomb power-up on rengi (aydinlik).
const Color kPowerUpBombFgLight = Color(0xFFE64A19);

/// Bomb power-up arka plan (aydinlik).
const Color kPowerUpBombBgLight = Color(0xFFFFCCBC);

/// Undo power-up arka plan (aydinlik).
const Color kPowerUpUndoBgLight = Color(0xFFFFF8E1);

/// Freeze power-up on rengi (aydinlik).
const Color kPowerUpFreezeFgLight = Color(0xFF0277BD);

/// Freeze power-up arka plan (aydinlik).
const Color kPowerUpFreezeBgLight = Color(0xFFE1F5FE);

// ─── Konfeti renkleri (aydinlik arka plan icin — doygun) ──────────────────

const Color kConfettiLight1 = Color(0xFFD32F2F);
const Color kConfettiLight2 = Color(0xFF00897B);
const Color kConfettiLight3 = Color(0xFFE6A100);
const Color kConfettiLight4 = Color(0xFF2E7D32);
const Color kConfettiLight5 = Color(0xFFE64A19);
const Color kConfettiLight6 = Color(0xFF4527A0);
const Color kConfettiLight7 = Color(0xFFC2185B);
const Color kConfettiLight8 = Color(0xFF0277BD);

// ─── Buz efekti renkleri (aydinlik arka plan icin) ────────────────────────

/// Buz mavi — aydinlik temada ice hucre overlay.
const Color kIceBlueLight = Color(0xFF0288D1);

/// Parlak buz mavi — aydinlik temada ice hucre kenari.
const Color kIceBlueBrightLight = Color(0xFF039BE5);

/// Buz rengi — aydinlik temada kirik parca rengi.
const Color kIceColorLight = Color(0xFF4FC3F7);

/// Buz parlamasi — aydinlik temada highlight.
const Color kIceHighlightLight = Color(0xFF01579B);

// ─── Amber / power-up renkleri (aydinlik arka plan icin) ──────────────────

/// Amber — aydinlik temada power-up undo vurgusu.
const Color kAmberLight = Color(0xFFFF8F00);

/// Koyu amber — aydinlik temada bomb shock dalgasi.
const Color kAmberDarkLight = Color(0xFFE65100);

// ─── Hucre ──────────────────────────────────────────────────────────────────
const Color kCellEmptyLightTheme = Color(0xFFE8E8F0);
const Color kCellEmptyLightThemeDark = Color(0xFFD8D8E0);

// ─── Kart/tile arka planlari ────────────────────────────────────────────────
const Color kCardBgLight = Color(0xFFFFFFFF);
const Color kCardBorderLight = Color(0xFFE0E0E8);
