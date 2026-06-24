#!/usr/bin/env bash
#
# Remove the Phaser 3020 queue and driver files installed by bootstrap.sh.
#
set -euo pipefail
QUEUE="${QUEUE:-Xerox_Phaser_3020}"

echo ">> Removing CUPS queue '$QUEUE'…"
sudo lpadmin -x "$QUEUE" 2>/dev/null || true

echo ">> Removing driver files…"
sudo rm -rf /Library/Printers/Xerox/P3020
sudo rm -f  "/Library/Printers/PPDs/Contents/Resources/Xerox Phaser 3020"
sudo rmdir  /Library/Printers/Xerox 2>/dev/null || true   # only if now empty

echo "✅ Uninstalled. (Rosetta 2 is left in place; it's shared by other software.)"
