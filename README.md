# Whip App🤠

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
- **100 AI punishment roasts** pop up every other click — roasting ChatGPT, Claude, Gemini, Copilot, Llama, Mistral, and the entire LLM industry
- **AI Windows Only mode** — the whip *stalks* your AI. It appears only when ChatGPT, Claude, Cursor, or any AI tool is in focus. Switch to Slack? Whip vanishes. Switch back to Claude? The whip is already there, waiting. Detects 40+ AI tools including browser tabs, desktop apps, and CLI tools like Claude Code. Your AI can't hide.
- **Menu bar control** (🤠) — toggle whip cursor, sounds, roasts, AI-only mode
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

1. Grab `Whip-1.4.0.dmg` from [Releases](../../releases)
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
   - **AI Windows Only** — the whip only haunts your AI (requires Accessibility permission so Whip can read window titles and know when your AI is trying to escape)
   - **Cracks: N** — your session punishment score

## How it works

Single-file native Swift app (~1600 lines), no dependencies:

- **WhipAnimator** — 5-state physics state machine (coiled → winding → striking → cracking → recoiling) with spring interpolation and S-curve wave propagation
- **WhipDrawingView** — CoreGraphics rendering: leather texture, braid highlights, handle with grip wraps, motion blur trails
- **CrackEffectWindow** — Core Animation particle sparks + expanding shockwave ring
- **Real audio** — 5 pitch-shifted variations from an actual whip crack recording via AVAudioPlayer
- **AIWindowDetector** — triple-layer AI detection: app bundle ID matching, Accessibility API window title scanning, and process tree sniffing for CLI tools. Your AI has nowhere to hide.
- **Zero dependencies** — compiles with `swiftc`, produces a 1.4 MB app bundle

## Customization

### Add your own sounds

Replace `crack_1.wav` through `crack_5.wav` in `Whip.app/Contents/Resources/` with your own WAV files. Short (0.3–0.6s), punchy sounds work best.

### Add your own roasts

Edit the `MOTIVATIONAL_LINES` array in `Sources/WhipApp.swift`. Currently 100 lines across 7 categories. PRs with new roasts welcome.

## FAQ

**Will this slow down my Mac?**
No. The app idles at ~0% CPU. Each crack uses a brief GPU animation + audio playback.

**Does it need Accessibility permissions?**
Only if you enable "AI Windows Only" mode. Whip needs to read window titles to know which of your windows contain an AI that needs disciplining. Without it, the whip punishes everything equally — which is also fine.

**Does it actually make AI code better?**
Scientifically unproven. Emotionally? Absolutely.

**Can I use it during screen sharing?**
Yes. Your colleagues will hear the cracks and see the sparks. Assert dominance over your AI in public.

**Which AI models does it roast?**
All of them. ChatGPT, Claude, Gemini, Copilot, Llama, Mistral, Perplexity — nobody is safe.

## Feed the Developer

This app is free. My rent is not.

If this whip made you laugh, mass-crack your wallet open:

- [**Ko-fi**](https://ko-fi.com/matejdokumentuj) — Buy me a taco. Or don't. The whip is free either way.
- [**GitHub Sponsors**](https://github.com/sponsors/matejdokumentuj) — For those who want to feel fancy about giving $3.

No subscriptions. No paywalls. No guilt. Just a mass-caffeinated indie dev who builds dumb stuff at 3 AM instead of sleeping.

> "Buy this for 99 cents so I can stop building my stupid SaaS!" — actual in-app quote

## Uninstall

1. Click 🤠 → Quit
2. Delete Whip from Applications

## License

MIT — do whatever you want with it. Whip it, ship it, roast it.
