#!/usr/bin/env python3
"""
Generate 5 whip crack variations from a reference recording (crack_base.wav).

Creates subtle variations via resampling (pitch shift), volume envelope tweaks,
and slight trimming so each crack sounds distinct but authentic.

Output: crack_1.wav .. crack_5.wav
"""

import wave, struct, math, os, array

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BASE_PATH = os.path.join(SCRIPT_DIR, "crack_base.wav")

# Variation parameters: pitch_factor (>1 = higher), trim_start_frac, gain
VARIATIONS = [
    {"name": "crack_1", "pitch": 1.00, "trim_start": 0.00, "gain": 1.0},   # Original
    {"name": "crack_2", "pitch": 0.93, "trim_start": 0.00, "gain": 0.95},  # Slightly lower/deeper
    {"name": "crack_3", "pitch": 1.07, "trim_start": 0.01, "gain": 1.05},  # Slightly higher/snappier
    {"name": "crack_4", "pitch": 0.97, "trim_start": 0.005, "gain": 0.98}, # Subtle low shift
    {"name": "crack_5", "pitch": 1.04, "trim_start": 0.008, "gain": 1.02}, # Subtle high shift
]


def read_wav(path):
    """Read mono 16-bit WAV, return (samples_as_floats, sample_rate)."""
    with wave.open(path, "r") as f:
        assert f.getnchannels() == 1, "Expected mono"
        assert f.getsampwidth() == 2, "Expected 16-bit"
        sr = f.getframerate()
        n = f.getnframes()
        raw = f.readframes(n)
        samples = struct.unpack(f"<{n}h", raw)
        return [s / 32768.0 for s in samples], sr


def resample(samples, factor):
    """Simple linear-interpolation resample. factor>1 = higher pitch (shorter)."""
    out_len = int(len(samples) / factor)
    out = []
    for i in range(out_len):
        src = i * factor
        idx = int(src)
        frac = src - idx
        if idx + 1 < len(samples):
            out.append(samples[idx] * (1 - frac) + samples[idx + 1] * frac)
        elif idx < len(samples):
            out.append(samples[idx])
    return out


def write_wav(path, samples, sr):
    """Write mono 16-bit WAV."""
    pcm = [int(max(-32768, min(32767, s * 32767))) for s in samples]
    with wave.open(path, "w") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(sr)
        f.writeframes(struct.pack(f"<{len(pcm)}h", *pcm))


def main():
    if not os.path.exists(BASE_PATH):
        print(f"Error: {BASE_PATH} not found. Place the reference recording there.")
        return

    base_samples, sr = read_wav(BASE_PATH)
    print(f"Base: {len(base_samples)} samples, {sr} Hz, {len(base_samples)/sr:.2f}s")

    for var in VARIATIONS:
        # Trim start
        trim = int(var["trim_start"] * sr)
        trimmed = base_samples[trim:]

        # Pitch shift via resampling
        shifted = resample(trimmed, var["pitch"])

        # Apply gain
        gained = [s * var["gain"] for s in shifted]

        # Soft clip
        clipped = [math.tanh(s * 1.5) / math.tanh(1.5) for s in gained]

        # Normalize to 95% peak
        peak = max(abs(s) for s in clipped) or 1.0
        normalized = [s / peak * 0.95 for s in clipped]

        path = os.path.join(SCRIPT_DIR, f"{var['name']}.wav")
        write_wav(path, normalized, sr)
        size = os.path.getsize(path)
        print(f"  {var['name']}.wav ({size:,} bytes) — pitch:{var['pitch']:.2f} gain:{var['gain']:.2f}")

    print("Done!")


if __name__ == "__main__":
    main()
