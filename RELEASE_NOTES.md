# Royale 1.2.0 — unofficial personal fork

Royale was created by **Evie Finch ([qt-dork](https://github.com/qt-dork))**.
All credit for the original watchface, design, artwork, and original code belongs
to the original creator. I do not claim authorship of Royale.

**Original repository:** https://github.com/qt-dork/zig-pebble-face

The changes in this fork were **vibe coded with OpenAI Codex** for my own Pebble
Time 2. This is an unofficial, experimental release, shared as-is. Support and
future updates are best-effort; the original creator is not responsible for
this fork. The original copyright and license are preserved in the repository.

## What's changed

- Updated to **Zig 0.16.0**, **Pebble SDK 4.33.1**, and Zig Pebble SDK integration 1.4.2.
- Added **24-hour time (00–23)**, with an option to follow the watch's time format.
  The original PM legend remains faint and in its original position in 24-hour mode.
- Fixed the analog timezone hand's minute-wrapping bug and fractional-hour offsets.
- Refresh choices: **every second, 15 seconds, 30 seconds, or minute**.
- A wrist flick can show live seconds for **5, 10, or 15 seconds**, then return to
  your selected refresh rate. Repeated flicks restart the window; the feature
  can also be disabled.
- Regenerate the phone settings bundle during builds so the new controls are included.

## Compatibility and limitations

- **Pebble Time 2 (emery) only.**
- City timezone selections use **fixed UTC offsets**, without automatic daylight
  saving. Choose “None (Default)” to follow the watch's local time.
- Build, automated checks, and emulator checks passed. Long-term battery usage
  and physical wrist detection still need real-world testing.
- This build retains Royale's original UUID, so it **replaces the original
  Royale installation** rather than installing alongside it.

## Install

Download **royale.pbw** from this release's assets. With the Pebble CLI installed,
enable **Devices → ⋮ → Enable Dev Connect** in the Pebble phone app and sign in.
Use the same account on your computer:

```sh
pebble login
pebble install --cloudpebble /path/to/royale.pbw
```

Keep your phone connected to the watch during installation. Then open Royale's
settings in the phone app to choose your time format, refresh rate, and wrist-flick
duration.
