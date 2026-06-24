#!/usr/bin/env bash
#
# Wait for the Phaser 3020 to appear on USB (it sleeps off the bus), then print.
# Usage: scripts/wake-and-print.sh [file-to-print]   (defaults to the test page)
#
set -euo pipefail
QUEUE="${QUEUE:-Xerox_Phaser_3020}"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC="${1:-$REPO/test/test-page.pdf}"

echo "Waiting for the Phaser 3020 on USB — press its power/wake button if it's asleep…"
for _ in $(seq 1 60); do
  if lpinfo -v 2>/dev/null | grep -qiE 'usb:.*(phaser|3020)'; then
    echo
    echo "✓ Printer detected. Sending: $DOC"
    lp -d "$QUEUE" "$DOC"
    sleep 2
    lpstat -p "$QUEUE"
    exit 0
  fi
  printf "."
  sleep 2
done
echo
echo "✗ Timed out (120s): the printer never appeared on USB."
echo "  Check it's powered on and awake, and that the USB cable is seated (try a direct port)."
exit 1
