# Royale: A Casio AE-1200-a-like written in Zig

This is an unofficial personal fork of **Royale**, created by **Evie Finch
([qt-dork](https://github.com/qt-dork))**. All credit for the original watchface,
its design, artwork, and original implementation belongs to the original creator.
I do not claim authorship of Royale.

**Original project:** [qt-dork/zig-pebble-face](https://github.com/qt-dork/zig-pebble-face)

The modifications in this fork were **vibe coded with OpenAI Codex** for my own
Pebble Time 2. They add preferences and fixes I wanted for personal use. This is
not an official release from the original creator, and the original creator is
not responsible for these changes. Support for this fork is best-effort, with no
promise of ongoing maintenance. Please report fork-specific issues here rather
than asking the original creator to support them.

The original copyright notice and [license](LICENSE) are preserved. Credit also
goes to [vsergeev/zig-pebble-sdk](https://github.com/vsergeev/zig-pebble-sdk) for the
Zig integration and [Rebble Clay](https://github.com/pebble-dev/clay) for the
configuration framework.

![Original Royale watchface by Evie Finch](https://cdn.some.pics/ewie/69e0f1b5d85be.png)

Pebble Time 2 (`emery`) watchface using the [Zig Pebble SDK](https://github.com/vsergeev/zig-pebble-sdk).

## Changes in this fork

- Updated the build to Zig 0.16.0 and Pebble SDK 4.33.1.
- Added 24-hour time (`00`–`23`), preserving the original faint PM artwork.
- Fixed timezone minute wrapping and fractional-hour offset calculations.
- Added a 30-second refresh option.
- Added temporary live seconds after a wrist flick, returning to the selected
  refresh interval afterward.

The build, automated checks, and emulator behavior have been tested. That does
not establish long-term battery performance or wrist-detection reliability on
physical watches; this fork is shared as an experimental personal build.

## Build

Requires **Zig 0.16.0**, **Pebble SDK 4.33.1**, Node.js/npm, and uv.
The vendored Zig SDK integration is version 1.4.2; its exact upstream revision
and local changes are recorded in [sdk/UPSTREAM.md](sdk/UPSTREAM.md).

```sh
uv tool install pebble-tool
pebble sdk install 4.33.1
npm ci
zig build
```

The build generates the phone configuration bundle from `src/pkjs` and produces
`zig-out/royale.pbw`. It does not use the historical prebuilt JavaScript or PBW
in `src/pkjs/pebble-js-app.js` and `build/`.

Current XDG SDK locations and older Linux/macOS locations are detected automatically.
To choose another installation explicitly:

```sh
zig build -Dpebble_sdk_path=/absolute/path/to/SDKs/4.33.1
pebble install --emulator emery zig-out/royale.pbw
```

The metadata field `sdkVersion: 3` is Pebble's app metadata format, not the
installed SDK release; it remains 3 when building with SDK 4.33.1.

## Install on your watch

This build supports **Pebble Time 2 only**.

### From your phone (no PC or CLI required)

1. Open the [GitHub releases page](https://github.com/Gober-x64/zig-pebble-face/releases)
   on your phone and select the release you want.
2. Under **Assets**, download **royale.pbw**, not either of the “Source code” archives.
3. Open the downloaded file with the **Pebble app**:
   - **Android:** open Downloads in your file manager, tap `royale.pbw`, and choose
     **Open with → Pebble**.
   - **iPhone:** open **Files → Downloads**, select `royale.pbw`, and use
     **Share → Pebble** if that option is available.
4. Keep your watch connected to the phone and follow the Pebble app's installation
   prompts.

This method does not require Zig, the Pebble SDK, or Dev Connect. File-opening
options vary by phone and Pebble app version. If Pebble is not offered, make sure
its app is up to date; you can also use the computer method below.
See [Rebble's direct-file installation instructions](https://help.rebble.io/lockerSync/).

### From a computer (alternative)

With the Pebble CLI installed, open **Devices → ⋮ → Enable Dev Connect** in the
Pebble phone app and sign in. Use the same account on your computer:

```sh
pebble login
pebble install --cloudpebble zig-out/royale.pbw
```

Keep the phone connected to your watch. The existing Royale watchface is updated
in place because its UUID is unchanged. Open its settings in the phone app to
choose the time format, refresh rate, and wrist-flick duration.
See the [official installation instructions](https://developer.repebble.com/sdk/).

## Settings

- **Time format:** follow the watch preference (default), 12-hour, or 24-hour.
  The 24-hour display uses `00`–`23`, with a leading zero. The original PM legend stays in its original position and faint mint-green
  color, like inactive LCD segments; it never lights up in 24-hour mode.
- **Refresh:** every second, 15 seconds, 30 seconds, or minute. Existing saved
  values remain compatible. The digital seconds and analog dial share this cadence.
- **Wrist flick:** show live seconds for 5, 10 (default), or 15 seconds, or disable
  the feature. Another flick restarts the window. When it expires, the selected
  cadence resumes; minute-only mode returns to minute ticks. Saving settings
  cancels an active window and applies the new settings immediately.
- **Analog timezone:** track local time or one of the listed fixed UTC offsets.
  Minute carry/borrow and midnight rollover are handled correctly, including
  fractional-hour zones. City selections **do not automatically adjust for DST**;
  choose “None (Default)” to use the watch's local time and DST.

## Checks

```sh
zig test src/zig/time_logic.zig
npm test
```

For the emulator smoke test, install the PBW first, install Pillow in your Python
environment, and run `python tests/emulator.py` with `pebble` on PATH. It changes
emulator time/settings and captures screenshots under `/tmp/royale-*.png`.
The test checks minute-only refresh, flick activation, repeated flicks, timeout,
and the original inactive PM indicator. Physical wrist recognition still needs an on-watch check.
