#!/usr/bin/env bash
# scripts/version_bump.sh
# pubspec.yaml'daki build number'ı git commit count ile günceller.
# Kullanım: ./scripts/version_bump.sh [--dry-run]

set -euo pipefail

PUBSPEC="pubspec.yaml"

if [ ! -f "$PUBSPEC" ]; then
  echo "Error: $PUBSPEC not found"
  exit 1
fi

# Mevcut versiyon
CURRENT=$(grep '^version:' "$PUBSPEC" | head -1 | sed 's/version: //')
BASE_VERSION=$(echo "$CURRENT" | cut -d+ -f1)

# Build number = toplam commit sayısı
BUILD_NUMBER=$(git rev-list --count HEAD)

NEW_VERSION="${BASE_VERSION}+${BUILD_NUMBER}"

if [ "${1:-}" = "--dry-run" ]; then
  echo "Would update: $CURRENT → $NEW_VERSION"
  exit 0
fi

# pubspec.yaml güncelle
sed -i.bak "s/^version: .*/version: ${NEW_VERSION}/" "$PUBSPEC"
rm -f "${PUBSPEC}.bak"

echo "Updated: $CURRENT → $NEW_VERSION"
