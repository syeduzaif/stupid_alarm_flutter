#!/usr/bin/env python3
"""Synthesize the bundled alarm sounds as small looping WAV files.

Run from the repo root:  python3 tool/generate_sounds.py
Outputs 16-bit mono 22050 Hz WAVs into assets/sounds/.
"""
import math
import os
import struct
import wave

RATE = 22050


def _clamp(v):
    return max(-1.0, min(1.0, v))


def write_wav(path, samples):
    with wave.open(path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        frames = b"".join(
            struct.pack("<h", int(_clamp(s) * 32767)) for s in samples
        )
        w.writeframes(frames)
    print(f"wrote {path} ({len(samples) / RATE:.2f}s)")


def silence(seconds):
    return [0.0] * int(RATE * seconds)


def tone(freq, seconds, volume=0.8, attack=0.01, release=0.03, harmonics=()):
    """Sine tone with a short attack/release envelope and optional harmonics."""
    n = int(RATE * seconds)
    out = []
    for i in range(n):
        t = i / RATE
        v = math.sin(2 * math.pi * freq * t)
        for mult, amp in harmonics:
            v += amp * math.sin(2 * math.pi * freq * mult * t)
        env = 1.0
        if t < attack:
            env = t / attack
        elif seconds - t < release:
            env = (seconds - t) / release
        out.append(volume * env * v)
    return out


def sweep(f0, f1, seconds, volume=0.6):
    """Linear frequency sweep (used for chirps)."""
    n = int(RATE * seconds)
    out = []
    phase = 0.0
    for i in range(n):
        t = i / RATE
        f = f0 + (f1 - f0) * (t / seconds)
        phase += 2 * math.pi * f / RATE
        env = math.sin(math.pi * t / seconds)  # smooth in/out
        out.append(volume * env * math.sin(phase))
    return out


def classic():
    """Harsh double-beep, the traditional alarm-clock pattern."""
    beep = tone(880, 0.18, volume=0.9, harmonics=[(2, 0.35), (3, 0.15)])
    gap = silence(0.08)
    group = beep + gap + beep
    return group + silence(0.45) + group + silence(0.45)


def gentle():
    """Soft rising three-note chime (C5 E5 G5) with long tails."""
    out = []
    for freq in (523.25, 659.25, 783.99):
        out += tone(freq, 0.55, volume=0.45, attack=0.05, release=0.35,
                    harmonics=[(2, 0.15)])
        out += silence(0.12)
    return out + silence(0.8)


def energetic():
    """Fast ascending beep run that demands attention."""
    out = []
    for freq in (600, 750, 900, 1100, 1300):
        out += tone(freq, 0.09, volume=0.85, harmonics=[(2, 0.3)])
        out += silence(0.04)
    return out + silence(0.35)


def nature():
    """Synthesized bird-like chirps with pauses."""
    out = []
    out += sweep(3400, 2600, 0.14)
    out += silence(0.1)
    out += sweep(3000, 3800, 0.1, volume=0.5)
    out += silence(0.25)
    out += sweep(4200, 3200, 0.12, volume=0.55)
    out += silence(0.9)
    return out


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    out_dir = os.path.join(here, "..", "assets", "sounds")
    os.makedirs(out_dir, exist_ok=True)
    write_wav(os.path.join(out_dir, "default_alarm.wav"), classic())
    write_wav(os.path.join(out_dir, "gentle_wake.wav"), gentle())
    write_wav(os.path.join(out_dir, "energetic.wav"), energetic())
    write_wav(os.path.join(out_dir, "nature.wav"), nature())


if __name__ == "__main__":
    main()
