#!/usr/bin/env python3
"""
Generate multiple whip crack sound variations.

Each variation uses different parameters for:
  - Pre-whoosh intensity
  - Crack sharpness & frequency content
  - Snap body resonance
  - Room tail character

Output: crack_1.wav .. crack_5.wav
"""

import wave, struct, math, random, os, sys

SAMPLE_RATE = 44100
OUT_DIR = os.path.dirname(os.path.abspath(__file__))

VARIATIONS = [
    {
        "name": "crack_1",  # Classic sharp crack
        "crack_freq": [4000, 7500, 12000],
        "crack_decay": 200,
        "snap_freqs": [600, 1100, 1800, 350],
        "snap_decay": 18,
        "room_decay": 6,
        "whoosh_gain": 0.15,
        "crack_gain": 1.2,
    },
    {
        "name": "crack_2",  # Deep heavy crack
        "crack_freq": [2500, 5000, 8000],
        "crack_decay": 150,
        "snap_freqs": [400, 800, 1200, 250],
        "snap_decay": 14,
        "room_decay": 4,
        "whoosh_gain": 0.22,
        "crack_gain": 1.0,
    },
    {
        "name": "crack_3",  # Sharp snappy crack
        "crack_freq": [5000, 9000, 14000],
        "crack_decay": 280,
        "snap_freqs": [800, 1400, 2200, 500],
        "snap_decay": 22,
        "room_decay": 8,
        "whoosh_gain": 0.10,
        "crack_gain": 1.4,
    },
    {
        "name": "crack_4",  # Double pop
        "crack_freq": [3500, 6500, 11000],
        "crack_decay": 180,
        "snap_freqs": [550, 1000, 1600, 300],
        "snap_decay": 16,
        "room_decay": 5,
        "whoosh_gain": 0.18,
        "crack_gain": 1.1,
        "double_pop": True,
    },
    {
        "name": "crack_5",  # Whip with echo
        "crack_freq": [4500, 8000, 13000],
        "crack_decay": 220,
        "snap_freqs": [700, 1200, 2000, 400],
        "snap_decay": 20,
        "room_decay": 3,
        "whoosh_gain": 0.12,
        "crack_gain": 1.3,
        "echo_delay": 0.08,
    },
]


def generate(var: dict, seed: int):
    random.seed(seed)
    duration = 0.6
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples

    cf = var["crack_freq"]
    cd = var["crack_decay"]
    sf = var["snap_freqs"]
    sd = var["snap_decay"]
    rd = var["room_decay"]
    wg = var["whoosh_gain"]
    cg = var["crack_gain"]
    has_double = var.get("double_pop", False)
    echo_delay = var.get("echo_delay", 0)

    for i in range(num_samples):
        t = i / SAMPLE_RATE
        s = 0.0

        # Layer 1: Pre-whoosh
        if t < 0.08:
            env = math.sin(math.pi * t / 0.08) * wg
            s += env * (
                random.uniform(-1, 1) * 0.3
                + math.sin(2 * math.pi * 120 * t) * 0.4
                + math.sin(2 * math.pi * 200 * t) * 0.3
            )

        # Layer 2: Sonic crack
        crack_start = 0.07
        crack_end = 0.09
        if crack_start <= t < crack_end:
            dt = t - crack_start
            if dt < 0.0005:
                env = dt / 0.0005
            else:
                env = math.exp(-(dt - 0.0005) * cd)
            crack = random.uniform(-1, 1)
            for freq in cf:
                crack += math.sin(2 * math.pi * freq * t) * 0.25
            # Double pop
            if has_double and 0.004 < dt < 0.012:
                crack += random.uniform(-1, 1) * 0.8 * math.exp(-(dt - 0.004) * 250)
            s += env * crack * cg

        # Layer 3: Snap body
        if 0.08 <= t < 0.28:
            dt = t - 0.08
            env = math.exp(-dt * sd) * 0.5
            body = random.uniform(-1, 1) * 0.35
            for j, freq in enumerate(sf):
                body += math.sin(2 * math.pi * freq * t) * (0.25 - j * 0.03)
            s += env * body

        # Layer 4: Room tail
        if 0.12 <= t < 0.6:
            dt = t - 0.12
            env = math.exp(-dt * rd) * 0.12
            s += env * (
                random.uniform(-1, 1) * 0.5
                + math.sin(2 * math.pi * 180 * t) * 0.3
                + math.sin(2 * math.pi * 90 * t) * 0.2
            )

        samples[i] = s

    # Echo effect
    if echo_delay > 0:
        delay_samples = int(echo_delay * SAMPLE_RATE)
        for i in range(delay_samples, num_samples):
            samples[i] += samples[i - delay_samples] * 0.3

    # Normalize
    peak = max(abs(s) for s in samples) or 1.0
    samples = [s / peak for s in samples]

    # Soft clip
    samples = [math.tanh(s * 2.0) * 0.92 for s in samples]

    # High-pass DC removal
    prev = 0.0
    for i in range(len(samples)):
        orig = samples[i]
        samples[i] = 0.995 * (prev + orig - (samples[i - 1] if i > 0 else 0))
        prev = samples[i]

    # Write WAV
    pcm = [int(max(-1, min(1, s)) * 32767) for s in samples]
    path = os.path.join(OUT_DIR, f"{var['name']}.wav")
    with wave.open(path, "w") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(SAMPLE_RATE)
        f.writeframes(struct.pack("<" + "h" * len(pcm), *pcm))
    size = os.path.getsize(path)
    print(f"  {var['name']}.wav ({size:,} bytes)")
    return path


if __name__ == "__main__":
    print("Generating whip crack variations...")
    for i, var in enumerate(VARIATIONS):
        generate(var, seed=42 + i * 7)
    print("Done!")
