#!/usr/bin/env bash
#
# Rebuild driver/ from a Xerox Phaser 3020 macOS driver DMG.
# This documents exactly which files we vendor and where they come from.
#
# Usage:
#   scripts/extract-driver.sh [path-to.dmg]
# With no argument it downloads the known v1.06.00 driver from Xerox.
#
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRIVER="$REPO/driver"

# Official Xerox download. Durable landing page (pick the macOS 10.15 driver):
#   https://www.support.xerox.com/en-us/content/147163
# Direct CDN URL as of 2026-06 (locale folder may change over time):
URL="https://download.support.xerox.com/pub/drivers/3020/drivers/macOS10_15/ar/Xerox_Phaser_3020_Driver_1.06.00.dmg"

TMP="$(mktemp -d)"
cleanup() { hdiutil detach "$TMP/mnt" >/dev/null 2>&1 || true; rm -rf "$TMP"; }
trap cleanup EXIT

DMG="${1:-}"
if [ -z "$DMG" ]; then
  echo ">> Downloading driver from Xerox…"
  DMG="$TMP/driver.dmg"
  curl -fL -o "$DMG" "$URL"
fi
echo ">> DMG sha256: $(shasum -a 256 "$DMG" | awk '{print $1}')"

mkdir -p "$TMP/mnt" "$TMP/zip"
hdiutil attach "$DMG" -nobrowse -readonly -mountpoint "$TMP/mnt" >/dev/null
unzip -qo "$TMP/mnt/MAC_Data/Printer Driver.zip" -d "$TMP/zip"
SRC="$TMP/zip/Printer Driver/10.6"   # vendor's legacy folder name; binaries are x86_64

mkdir -p "$DRIVER/SCMS"
cp "$SRC/Filter- SPL/rastertosec"          "$DRIVER/rastertosec"
cp "$SRC/Filter- SPL/prefilter"            "$DRIVER/prefilter"
cp "$SRC/Command File Filter/commandtosec" "$DRIVER/commandtosec"
cp "$SRC/SCMS/libscmssc.dylib"             "$DRIVER/SCMS/libscmssc.dylib"
cp "$SRC/SCMS/P3020sc.cts"                 "$DRIVER/SCMS/P3020sc.cts"
gzip -dc "$SRC/PPD/gzipfile/Xerox Phaser 3020.gz" > "$DRIVER/Xerox_Phaser_3020.ppd"
chmod +x "$DRIVER"/rastertosec "$DRIVER"/prefilter "$DRIVER"/commandtosec
xattr -dr com.apple.quarantine "$DRIVER" 2>/dev/null || true

echo ">> Extracted into driver/.  rastertosec arch: $(lipo -archs "$DRIVER/rastertosec")"
echo ">> Checksums (paste into driver/SOURCE.md):"
( cd "$REPO" && shasum -a 256 driver/rastertosec driver/prefilter driver/commandtosec \
      driver/SCMS/libscmssc.dylib driver/SCMS/P3020sc.cts driver/Xerox_Phaser_3020.ppd )
