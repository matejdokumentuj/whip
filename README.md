# Whip 🤠

**Crack the whip on your AI.** Every click explodes with a whip crack sound and spark animation. Your cursor becomes a whip. Motivational one-liners keep the pressure on.

A fun macOS menu bar app for developers who want to keep their AI coding assistants on their toes.

![macOS](https://img.shields.io/badge/macOS-13%2B-blue) ![Swift](https://img.shields.io/badge/Swift-6-orange) ![License](https://img.shields.io/badge/license-MIT-green)

## What it does

- **Every mouse click** triggers a whip crack sound + spark explosion at cursor position
- **Custom whip cursor** replaces your mouse pointer
- **5 sound variations** — procedurally generated, never the same crack twice
- **Motivational roasts** pop up every few clicks ("CRACK! Ship it or whip it!")
- **Menu bar control** — toggle everything from the 🤠 icon
- **Crack counter** — track your daily productivity motivation

## Install

### Download (easiest)

1. Grab `Whip-1.0.0.dmg` from [Releases](../../releases)
2. Open DMG, drag **Whip** to Applications
3. Open Whip from Applications
4. If macOS blocks it: System Settings → Privacy & Security → Open Anyway

### Build from source

Requires macOS 13+ and Xcode Command Line Tools.

```bash
git clone https://github.com/YOUR_USERNAME/whip.git
cd whip
make build    # Build Whip.app
make run      # Build and launch
make install  # Copy to /Applications
make dmg      # Create distributable DMG
```

## Usage

1. Launch Whip — a 🤠 appears in your menu bar
2. Click anywhere — CRACK! Sound + sparks + whip cursor
3. Click the 🤠 to access controls:
   - **Enabled** — master on/off toggle
   - **Whip Cursor** — toggle the custom cursor
   - **Motivational Lines** — toggle the roast popups
   - **Cracks: N** — your session score

## Customization

### Add your own sounds

Replace `crack_1.wav` through `crack_5.wav` in `Whip.app/Contents/Resources/` with your own WAV files. Short (0.3–0.6s), punchy sounds work best.

### Environment variables

| Variable | Description |
|----------|-------------|
| `WHIP_DIR` | Override the sound file search directory |

## How it works

- **Native Swift** — no Electron, no web views, no runtime dependencies
- **`NSEvent.addGlobalMonitorForEvents`** — listens for clicks across all apps
- **`Core Animation`** — GPU-accelerated spark and flash effects
- **`AVAudioPlayer`** — low-latency sound with a pool of pre-loaded players
- **Cursor overlay** — transparent borderless window tracking mouse at 120 FPS

## FAQ

**Will this slow down my Mac?**
No. The app idles at ~0 CPU. Each crack uses a brief GPU animation + audio playback.

**Does it need Accessibility permissions?**
No. It uses `NSEvent` global monitors which don't require special permissions.

**Can I use it during screen sharing?**
Yes, but your colleagues will hear the cracks and see the sparks. That's a feature.

**Does it actually make AI code faster?**
Scientifically unproven. Anecdotally? Absolutely.

## Uninstall

1. Click 🤠 → Quit
2. Delete Whip from Applications

## License

MIT — do whatever you want with it. Whip it, ship it.
