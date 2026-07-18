#!/usr/bin/env python3
"""Procedural audio synthesis for Soul Saver. Pure stdlib — writes 16-bit mono WAVs."""
import math, os, random, struct, wave

SR = 44100
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")
rng = random.Random(7)

def buf(seconds):
    return [0.0] * int(SR * seconds)

def mix(dst, src, at=0.0, gain=1.0):
    o = int(at * SR)
    for i, s in enumerate(src):
        j = o + i
        if 0 <= j < len(dst):
            dst[j] += s * gain
    return dst

def sine(freq, seconds, gain=1.0, phase=0.0):
    out = buf(seconds)
    for i in range(len(out)):
        out[i] = math.sin(phase + 2 * math.pi * freq * i / SR) * gain
    return out

def noise(seconds, gain=1.0):
    return [rng.uniform(-1, 1) * gain for _ in range(int(SR * seconds))]

def lowpass(sig, cutoff):
    out = [0.0] * len(sig)
    a = 1.0 - math.exp(-2 * math.pi * cutoff / SR)
    y = 0.0
    for i, s in enumerate(sig):
        y += a * (s - y)
        out[i] = y
    return out

def highpass(sig, cutoff):
    lp = lowpass(sig, cutoff)
    return [s - l for s, l in zip(sig, lp)]

def env_adsr(sig, a, d, s_level, r):
    n = len(sig); out = [0.0] * n
    an, dn, rn = int(a * SR), int(d * SR), int(r * SR)
    sn = max(0, n - an - dn - rn)
    i = 0
    for k in range(an):
        if i >= n: break
        out[i] = sig[i] * (k / max(1, an)); i += 1
    for k in range(dn):
        if i >= n: break
        out[i] = sig[i] * (1.0 + (s_level - 1.0) * k / max(1, dn)); i += 1
    for k in range(sn):
        if i >= n: break
        out[i] = sig[i] * s_level; i += 1
    for k in range(rn):
        if i >= n: break
        out[i] = sig[i] * s_level * (1.0 - k / max(1, rn)); i += 1
    return out

def env_exp(sig, decay):
    return [s * math.exp(-i / SR / decay) for i, s in enumerate(sig)]

def crossfade_loop(sig, fade=0.5):
    """Make a seamless loop by crossfading the tail into the head."""
    fn = int(fade * SR)
    n = len(sig)
    out = sig[: n - fn]
    for i in range(fn):
        t = i / fn
        out[i] = sig[n - fn + i] * (1 - t) + sig[i] * t
    return out

def normalize(sig, peak=0.9):
    m = max(1e-9, max(abs(s) for s in sig))
    return [s * peak / m for s in sig]

def save(name, sig, peak=0.9):
    sig = normalize(sig, peak)
    path = os.path.join(OUT, name + ".wav")
    with wave.open(path, "w") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, s)) * 32767)) for s in sig))
    print("wrote", path, f"{len(sig)/SR:.2f}s")

os.makedirs(OUT, exist_ok=True)

# ---------------- music beds ----------------

def drone_loop():
    dur = 20.0
    out = buf(dur)
    # deep root drone in D (36.7 Hz too low; use 55 A / 73.4 D)
    for f, g in [(55.0, 0.5), (55.0 * 1.5, 0.18), (110.0, 0.22), (73.42, 0.3), (146.8, 0.1)]:
        s = sine(f, dur, g)
        # slow independent amplitude breathing
        rate = rng.uniform(0.05, 0.13); ph = rng.uniform(0, 6.28)
        s = [v * (0.7 + 0.3 * math.sin(ph + 2 * math.pi * rate * i / SR)) for i, v in enumerate(s)]
        mix(out, s)
    rumble = lowpass(noise(dur, 1.0), 90)
    mix(out, rumble, 0, 0.35)
    return crossfade_loop(out, 1.5)

def chant_loop():
    """Vowel-ish choir pad, slow minor movement. Sits above the drone as danger rises."""
    dur = 24.0
    out = buf(dur)
    # chord tones over D minor-ish drift: D3 A3 D4 F4 -> C3 G3 C4 E4
    chords = [[146.8, 220.0, 293.7, 349.2], [130.8, 196.0, 261.6, 329.6]]
    seg = dur / 2
    for ci, chord in enumerate(chords):
        for f in chord:
            s = buf(seg)
            for i in range(len(s)):
                t = i / SR
                vib = 1.0 + 0.004 * math.sin(2 * math.pi * 4.8 * t + f)
                # formant-ish stack: fundamental + soft harmonics = "ahh"
                v = (math.sin(2 * math.pi * f * vib * t) * 0.5
                     + math.sin(2 * math.pi * f * 2 * vib * t) * 0.22
                     + math.sin(2 * math.pi * f * 3 * vib * t) * 0.12
                     + math.sin(2 * math.pi * f * 4 * vib * t) * 0.05)
                s[i] = v * 0.22
            s = env_adsr(s, 2.5, 0.0, 1.0, 2.5)
            mix(out, s, ci * seg)
    breath = lowpass(highpass(noise(dur, 1.0), 500), 1600)
    mix(out, breath, 0, 0.03)
    return crossfade_loop(out, 2.0)

def bell(freq=98.0, dur=7.0, strike=1.0):
    """Big church bell: classic inharmonic partial stack."""
    partials = [(0.5, 0.6, 5.0), (1.0, 1.0, 4.0), (1.2, 0.55, 3.0), (1.5, 0.4, 2.6),
                (2.0, 0.6, 2.0), (2.66, 0.25, 1.4), (3.0, 0.2, 1.1), (4.2, 0.12, 0.7)]
    out = buf(dur)
    for ratio, g, decay in partials:
        s = env_exp(sine(freq * ratio, dur, g), decay)
        mix(out, s)
    clank = env_exp(highpass(noise(0.08, 1.0), 2000), 0.02)
    mix(out, clank, 0, 0.5 * strike)
    return out

def make_all():
    save("music_drone", drone_loop(), 0.55)
    save("music_chant", chant_loop(), 0.5)
    save("bell_toll", bell(98.0, 8.0), 0.85)
    save("bell_small", bell(392.0, 2.0, 0.4), 0.5)

    # level-up: three ascending gold chimes with shimmer
    lu = buf(1.4)
    for k, f in enumerate([587.3, 880.0, 1174.7]):
        c = env_exp(sine(f, 1.0, 0.6), 0.35)
        c2 = env_exp(sine(f * 2.01, 1.0, 0.2), 0.2)
        mix(lu, c, k * 0.11); mix(lu, c2, k * 0.11)
    shimmer = env_exp(highpass(noise(1.2, 1.0), 6000), 0.4)
    mix(lu, shimmer, 0.2, 0.06)
    save("levelup", lu, 0.7)

    # ember pickup: tiny soft chime (played constantly — keep gentle)
    pk = env_exp(sine(1318.5, 0.18, 0.5), 0.05)
    mix(pk, env_exp(sine(2637.0, 0.15, 0.2), 0.04))
    save("pickup", pk, 0.45)

    # card select / page turn
    pg = env_adsr(lowpass(highpass(noise(0.25, 1.0), 800), 4000), 0.02, 0.1, 0.3, 0.1)
    mix(pg, env_exp(sine(1046.5, 0.3, 0.3), 0.1), 0.05)
    save("ui_select", pg, 0.5)

    # player hurt: dull thud + cloth
    ht = env_exp(sine(90, 0.3, 1.0), 0.07)
    mix(ht, env_exp(lowpass(noise(0.2, 1.0), 700), 0.05), 0, 0.5)
    save("hurt", ht, 0.8)

    # swarm death: soft cinder puff (constant sound — very soft, band-limited)
    dp = env_exp(lowpass(highpass(noise(0.22, 1.0), 300), 2400), 0.06)
    mix(dp, env_exp(sine(180, 0.15, 0.4), 0.05))
    save("death_puff", dp, 0.5)

    # thurible whoosh
    wh = buf(0.45)
    nz = noise(0.45, 1.0)
    for i in range(len(wh)):
        t = i / len(wh)
        cutoff_mod = 300 + 2200 * math.sin(math.pi * t)
        wh[i] = nz[i] * (0.3 + 0.7 * math.sin(math.pi * t))
    wh = lowpass(wh, 1500)
    save("whoosh", wh, 0.5)

    # holy impact: bright pluck + sparkle (weapon hits)
    hi = env_exp(sine(784, 0.35, 0.6), 0.08)
    mix(hi, env_exp(sine(1568, 0.3, 0.3), 0.06))
    mix(hi, env_exp(highpass(noise(0.2, 1.0), 5000), 0.05), 0, 0.15)
    save("holy_impact", hi, 0.5)

    # sanctus shockwave: mid bell-boom
    save("shockwave", bell(196.0, 1.6, 0.8), 0.7)

    # boss roar: falling saw + growl noise
    rr = buf(1.4)
    for i in range(len(rr)):
        t = i / SR
        f = 130 * math.exp(-t * 0.9) + 40
        ph = 2 * math.pi * f * t
        saw = 2 * ((ph / (2 * math.pi)) % 1.0) - 1
        rr[i] = saw * 0.5
    rr = lowpass(rr, 500)
    growl = lowpass(noise(1.4, 1.0), 350)
    growl = [g * (1 + 0.8 * math.sin(2 * math.pi * 31 * i / SR)) for i, g in enumerate(growl)]
    mix(rr, env_adsr(growl, 0.05, 0.3, 0.6, 0.6), 0, 0.5)
    rr = env_adsr(rr, 0.03, 0.2, 0.8, 0.7)
    save("roar", rr, 0.85)

    # vestige claim: music-box motif (Lucia)
    vs = buf(2.4)
    notes = [(880.0, 0.0), (1174.7, 0.35), (1046.5, 0.7), (1318.5, 1.05)]
    for f, at in notes:
        n = env_exp(sine(f, 1.4, 0.5), 0.5)
        mix(n, env_exp(sine(f * 3, 0.8, 0.08), 0.2))
        mix(vs, n, at)
    save("vestige", vs, 0.6)

    # gate opening: rising radiant chord
    gt = buf(4.5)
    for k, f in enumerate([293.7, 440.0, 587.3, 880.0, 1174.7]):
        s = sine(f, 3.5, 0.4)
        s = env_adsr(s, 1.2 + k * 0.3, 0.0, 1.0, 1.2)
        mix(gt, s, k * 0.25)
    mix(gt, env_adsr(highpass(noise(4.0, 1.0), 7000), 2.0, 0.0, 1.0, 1.5), 0.5, 0.05)
    save("gate_open", gt, 0.65)

    # chest / reliquary fanfare
    cf = buf(1.6)
    for k, f in enumerate([523.3, 659.3, 784.0, 1046.5]):
        mix(cf, env_exp(sine(f, 1.0, 0.5), 0.4), k * 0.09)
    save("fanfare", cf, 0.65)

    # elite spitter shot
    sp = env_exp(lowpass(noise(0.2, 1.0), 900), 0.06)
    mix(sp, env_exp(sine(220, 0.2, 0.6), 0.06))
    save("spit", sp, 0.5)

if __name__ == "__main__":
    make_all()
