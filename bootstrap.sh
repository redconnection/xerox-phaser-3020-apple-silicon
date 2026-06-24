#!/usr/bin/env bash
#
# One-command setup for the Xerox Phaser 3020 on macOS (Apple Silicon or Intel).
# Installs Rosetta 2 if needed, installs the bundled vendor driver, and creates a
# CUPS queue bound to the USB-connected printer. Safe to re-run (idempotent).
#
# See README.md for how/why this works.
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRIVER="$REPO/driver"
DEST="/Library/Printers/Xerox/P3020"
PPD_SYS="/Library/Printers/PPDs/Contents/Resources/Xerox Phaser 3020"
QUEUE="${QUEUE:-Xerox_Phaser_3020}"

[ "$(uname)" = "Darwin" ] || { echo "This is for macOS only."; exit 1; }

# --- 1. Rosetta 2 (Apple Silicon only) -------------------------------------
if [ "$(uname -m)" = "arm64" ]; then
  if /usr/bin/pgrep -q oahd || [ -d /Library/Apple/usr/libexec/oah ]; then
    echo ">> Rosetta 2 already present."
  else
    echo ">> Installing Rosetta 2 (needed to run the Intel print filter)…"
    sudo softwareupdate --install-rosetta --agree-to-license
  fi
fi

# --- 2. Detect the printer's USB device URI (don't hardcode the serial) ----
echo ">> Looking for the Phaser 3020 on USB…"
URI="$(lpinfo -v 2>/dev/null | awk '/usb:.*([Pp]haser|3020)/{print $2; exit}')"
if [ -z "${URI:-}" ]; then
  echo "!! Phaser 3020 not found on USB."
  echo "   Power it on, press a button to wake it, check the cable (plug straight into the Mac),"
  echo "   then re-run ./bootstrap.sh.  Current CUPS USB devices:"
  lpinfo -v 2>/dev/null | grep -i usb || echo "   (none)"
  exit 1
fi
echo ">> Found: $URI"

# --- 3. Install the driver files where the PPD expects them ----------------
echo ">> Installing driver to $DEST (you'll be asked for your password)…"
sudo install -d -m 755 "$DEST/SCMS"
sudo install -m 755 "$DRIVER/rastertosec"          "$DEST/rastertosec"
sudo install -m 755 "$DRIVER/prefilter"            "$DEST/prefilter"
sudo install -m 755 "$DRIVER/commandtosec"         "$DEST/commandtosec"
sudo install -m 755 "$DRIVER/SCMS/libscmssc.dylib" "$DEST/SCMS/libscmssc.dylib"
sudo install -m 644 "$DRIVER/SCMS/P3020sc.cts"     "$DEST/SCMS/P3020sc.cts"
sudo xattr -dr com.apple.quarantine "$DEST" 2>/dev/null || true   # clear "downloaded" flag

# PPD into the system repository too (lets the GUI "Add Printer" find it)
sudo install -d -m 755 "$(dirname "$PPD_SYS")"
sudo install -m 644 "$DRIVER/Xerox_Phaser_3020.ppd" "$PPD_SYS"

# --- 4. Create / replace the CUPS queue ------------------------------------
echo ">> Creating CUPS queue '$QUEUE'…"
sudo lpadmin -x "$QUEUE" 2>/dev/null || true
sudo lpadmin -p "$QUEUE" -E -v "$URI" -P "$DRIVER/Xerox_Phaser_3020.ppd" \
     -D "Xerox Phaser 3020 (SPL via Rosetta 2)" -L "USB"
sudo cupsenable "$QUEUE"
sudo cupsaccept "$QUEUE"

# --- 5. Sanity: filter loads under Rosetta ---------------------------------
echo ">> Verifying the filter runs:"
arch -x86_64 "$DEST/rastertosec" </dev/null 2>&1 | head -1 || true

echo
echo "✅ Done. '$QUEUE' is installed and ready."
echo "   Test it:  ./scripts/wake-and-print.sh"
echo "   Or print from any app (⌘P) and choose 'Xerox Phaser 3020'."
