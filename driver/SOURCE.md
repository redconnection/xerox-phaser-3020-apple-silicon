# Bundled driver — source, attribution & integrity

> **These files are NOT part of this project's MIT license.** They are the proprietary
> work of **Xerox Corporation** and **Samsung Electronics Co., Ltd.**, redistributed here
> only for convenience and preservation. All rights remain with the respective owners.
> If a rights holder objects, they will be removed — open an issue.

## What this is

The Xerox Phaser 3020 is a host-based printer built on a **Samsung** print engine (USB
vendor ID `0x0924`, Samsung Electronics). It has no PostScript/PCL; it must be driven with a
software rasterizer that emits **SPL (Samsung Printer Language)**. These files are that
rasterizer and its support data, extracted from Xerox's official macOS driver:

| File | Role |
|------|------|
| `rastertosec` | CUPS filter: CUPS raster → SPL. The core "missing piece." (`x86_64` + `i386`) |
| `prefilter` | Vendor pre-processing helper |
| `commandtosec` | CUPS filter for maintenance commands (clean/align) |
| `SCMS/libscmssc.dylib` | Screening / colour-management library loaded by the filter |
| `SCMS/P3020sc.cts` | Screening table for the 3020 |
| `Xerox_Phaser_3020.ppd` | PPD describing the printer and wiring in the filters |

## Where it came from

- **Product:** Xerox Phaser 3020 Print Driver
- **Version:** **1.06.00**, released **2020-03-05**
- **Package:** `Xerox_Phaser_3020_Driver_1.06.00.dmg` (~8.6 MB)
- **Official page (durable):** https://www.support.xerox.com/en-us/content/147163
  (Xerox support → Phaser 3020 → Downloads → macOS 10.15 driver)
- **Direct CDN URL (as of 2026-06, locale folder may change):**
  `https://download.support.xerox.com/pub/drivers/3020/drivers/macOS10_15/ar/Xerox_Phaser_3020_Driver_1.06.00.dmg`

> ⚠️ **Availability caveat:** the official download is hosted by Xerox and may be moved or
> removed at any time, entirely at their discretion. The copies here are a hedge against that.
> Re-extract from an official DMG anytime with [`scripts/extract-driver.sh`](../scripts/extract-driver.sh).

The driver targets macOS 10.15–12. Its CUPS filter is an **Intel (x86_64) Mach-O** binary,
which is why it runs on Apple Silicon **through Rosetta 2** — that's the whole trick (see the
[README](../README.md)).

## Integrity (SHA-256)

Source DMG:
```
0f9abb6d92f556149f9a1c2a5c908cda1a65d5f02a0f344af131709ffd0fde84  Xerox_Phaser_3020_Driver_1.06.00.dmg
```

Extracted files in this directory:
```
fbf7a0264d4032a8b7602b829520b1edf185f292602ad41d3d8f3e6f5a9795e2  rastertosec
d139320249a5d14487087979657c497aca64a4ef3842e93a26f072a745a203b9  prefilter
9afd372841b5ba6235eb2e93a8771dcaffb7bd745cd12b2887b0893231e56055  commandtosec
a63a5346af10e120a2459847f311cb2d2c756424a73edbace2390cd524871f4e  SCMS/libscmssc.dylib
5bf5a186db8bef962230e8dac7dbf277643dbbaed28a5fbdda5699e4131beb15  SCMS/P3020sc.cts
d8726b45ab6b5bbce47bae20f7375001f3637c59b380bb1b8da35cd082af7d90  Xerox_Phaser_3020.ppd
```

Verify with:
```bash
cd driver && shasum -a 256 -c <<'EOF'
fbf7a0264d4032a8b7602b829520b1edf185f292602ad41d3d8f3e6f5a9795e2  rastertosec
d139320249a5d14487087979657c497aca64a4ef3842e93a26f072a745a203b9  prefilter
9afd372841b5ba6235eb2e93a8771dcaffb7bd745cd12b2887b0893231e56055  commandtosec
a63a5346af10e120a2459847f311cb2d2c756424a73edbace2390cd524871f4e  SCMS/libscmssc.dylib
5bf5a186db8bef962230e8dac7dbf277643dbbaed28a5fbdda5699e4131beb15  SCMS/P3020sc.cts
d8726b45ab6b5bbce47bae20f7375001f3637c59b380bb1b8da35cd082af7d90  Xerox_Phaser_3020.ppd
EOF
```
