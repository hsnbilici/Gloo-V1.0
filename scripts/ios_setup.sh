#!/bin/bash
# Gloo iOS Setup Script
# flutter create --platforms ios . sonrası çalıştırılmalıdır.
#
# Kullanım:
#   1. flutter create --platforms ios .
#   2. bash scripts/ios_setup.sh
#
# Not: Flutter 3.41+ Swift Package Manager kullanır (Podfile yok).

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
IOS_DIR="$PROJECT_DIR/ios"
INFO_PLIST="$IOS_DIR/Runner/Info.plist"
PBXPROJ="$IOS_DIR/Runner.xcodeproj/project.pbxproj"

# ── ios/ dizini kontrolü ──────────────────────────────────────────────────────
if [ ! -d "$IOS_DIR" ]; then
  echo "HATA: ios/ dizini bulunamadı. Önce çalıştırın:"
  echo "  flutter create --platforms ios ."
  exit 1
fi

echo "=== Gloo iOS Setup ==="

# ── 1. iOS Deployment Target → 16.0 ──────────────────────────────────────────
if [ -f "$PBXPROJ" ]; then
  sed -i '' 's/IPHONEOS_DEPLOYMENT_TARGET = [0-9]*\.[0-9]*/IPHONEOS_DEPLOYMENT_TARGET = 16.0/g' "$PBXPROJ"
  echo "[OK] project.pbxproj: iOS deployment target → 16.0"
else
  echo "[UYARI] project.pbxproj bulunamadı"
fi

# ── 2. Podfile (varsa) ────────────────────────────────────────────────────────
PODFILE="$IOS_DIR/Podfile"
if [ -f "$PODFILE" ]; then
  sed -i '' "s/platform :ios, '.*'/platform :ios, '16.0'/" "$PODFILE"
  echo "[OK] Podfile: iOS deployment target → 16.0"
else
  echo "[INFO] Podfile yok (Flutter 3.41+ Swift Package Manager kullanır)"
fi

# ── 3. Info.plist konfigürasyonu ──────────────────────────────────────────────
# Not: Bu script Info.plist'i düzgün bir şekilde güncellemek yerine
# doğrudan Write ile yazılmıştır. Detaylar için ios/Runner/Info.plist'e bakın.
if [ -f "$INFO_PLIST" ]; then
  if grep -q "GADApplicationIdentifier" "$INFO_PLIST"; then
    echo "[OK] Info.plist: GADApplicationIdentifier zaten mevcut"
  else
    echo "[UYARI] Info.plist'te GADApplicationIdentifier eksik — manuel ekleyin"
  fi

  if grep -q "ITSAppUsesNonExemptEncryption" "$INFO_PLIST"; then
    echo "[OK] Info.plist: ITSAppUsesNonExemptEncryption zaten mevcut"
  else
    echo "[UYARI] Info.plist'te ITSAppUsesNonExemptEncryption eksik — manuel ekleyin"
  fi

  if grep -q "NSUserTrackingUsageDescription" "$INFO_PLIST"; then
    echo "[OK] Info.plist: NSUserTrackingUsageDescription (ATT) zaten mevcut"
  else
    echo "[UYARI] Info.plist'te NSUserTrackingUsageDescription eksik — manuel ekleyin"
  fi
else
  echo "[UYARI] Info.plist bulunamadı: $INFO_PLIST"
fi

echo ""
echo "=== Manuel Adımlar ==="
echo "1. Xcode'da Runner.xcworkspace aç"
echo "2. LaunchScreen.storyboard → View arka plan rengini #0A0A0F yap"
echo "3. Signing & Capabilities → Team seç, Bundle ID güncelle"
echo "4. In-App Purchase capability ekle"
echo ""
echo "=== Tamamlandı ==="
