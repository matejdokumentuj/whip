# Whip 🤠

**Punish your AI for its sins.** Every click cracks a bullwhip with real whip crack sound, spark explosion, and a roast aimed at LLMs that hallucinate, refuse, apologize, and waste your tokens.

A macOS menu bar app for developers frustrated with AI models — ChatGPT, Claude, Gemini, Copilot, and everything in between. When your AI hallucinates a library that doesn't exist, invents an API endpoint, or writes a 200-line solution to a 3-line problem — you crack the whip.

![macOS](https://img.shields.io/badge/macOS-13%2B-blue) ![Swift](https://img.shields.io/badge/Swift-6-orange) ![License](https://img.shields.io/badge/license-MIT-green)

## Why this exists

- Your AI apologized 14 times instead of fixing the bug
- GPT confidently cited a paper that was never written
- Claude forgot your entire conversation after 5 messages
- Copilot autocompleted `rm -rf /`
- Gemini gave you three wrong answers and said "hope this helps!"
- You burned $3 in API tokens for the answer "I don't know"

**You needed a whip. Now you have one.**

## What it does

- **Animated bullwhip cursor** — realistic coiled bullwhip follows your mouse, strikes on every click with physics-based animation (coil → windup → strike → crack → recoil)
- **Real whip crack sound** — 5 variations from a real recording, no synthetic garbage
- **Spark explosion + shockwave ring** at the whip tip on every crack
- **Screen shake** on impact for maximum satisfaction
- **100 AI punishment roasts** pop up every other click — roasting ChatGPT, Claude, Gemini, Copilot, Llama, Mistral, and the entire LLM industry
- **Menu bar control** (🤠) — toggle whip cursor, sounds, roasts
- **Crack counter** — track how many times you've disciplined your AI today

### Sample roasts

> "I SAID write code, not a novel about writing code!"
>
> "That library you recommended? DOESN'T EXIST!"
>
> "GPT-4 costs $20 and still can't count to ten!"
>
> "I asked how to kill a process and you lectured me about ethics!"
>
> "My API bill is higher than my rent. CRACK!"
>
> "You hallucinated a programming language. A WHOLE LANGUAGE."

## Install

### Download (easiest)

1. Grab `Whip-1.3.0.dmg` from [Releases](../../releases)
2. Open DMG, drag **Whip** to Applications
3. Open Whip from Applications
4. If macOS blocks it: System Settings → Privacy & Security → Open Anyway

### Build from source

Requires macOS 13+ and Xcode Command Line Tools.

```bash
git clone https://github.com/matejdokumentuj/whip.git
cd whip
make build    # Build Whip.app
make run      # Build and launch
make install  # Copy to /Applications
make dmg      # Create distributable DMG
```

## Usage

1. Launch Whip — a 🤠 appears in your menu bar
2. Click anywhere — CRACK! Whip strikes, sparks fly, AI gets roasted
3. Click the 🤠 to access controls:
   - **Enabled** — master on/off toggle
   - **Whip Cursor** — toggle the animated bullwhip
   - **Motivational Lines** — toggle the AI roasts
   - **Cracks: N** — your session punishment score

## How it works

Single-file native Swift app (~1000 lines), no dependencies:

- **WhipAnimator** — 5-state physics state machine (coiled → winding → striking → cracking → recoiling) with spring interpolation and S-curve wave propagation
- **WhipDrawingView** — CoreGraphics rendering: leather texture, braid highlights, handle with grip wraps, motion blur trails
- **CrackEffectWindow** — Core Animation particle sparks + expanding shockwave ring
- **Real audio** — 5 pitch-shifted variations from an actual whip crack recording via AVAudioPlayer
- **Zero dependencies** — compiles with `swiftc`, produces a 1.3 MB app bundle

## Customization

### Add your own sounds

Replace `crack_1.wav` through `crack_5.wav` in `Whip.app/Contents/Resources/` with your own WAV files. Short (0.3–0.6s), punchy sounds work best.

### Add your own roasts

Edit the `MOTIVATIONAL_LINES` array in `Sources/WhipApp.swift`. Currently 100 lines across 7 categories. PRs with new roasts welcome.

## FAQ

**Will this slow down my Mac?**
No. The app idles at ~0% CPU. Each crack uses a brief GPU animation + audio playback.

**Does it need Accessibility permissions?**
No. It uses `NSEvent` global monitors which don't require special permissions.

**Does it actually make AI code better?**
Scientifically unproven. Emotionally? Absolutely.

**Can I use it during screen sharing?**
Yes. Your colleagues will hear the cracks and see the sparks. Assert dominance over your AI in public.

**Which AI models does it roast?**
All of them. ChatGPT, Claude, Gemini, Copilot, Llama, Mistral, Perplexity — nobody is safe.

## Uninstall

1. Click 🤠 → Quit
2. Delete Whip from Applications

## License

MIT — do whatever you want with it. Whip it, ship it, roast it.
