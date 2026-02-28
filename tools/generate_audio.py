#!/usr/bin/env python3
"""
Gloo ASMR Jelly Color Puzzle — Ses Dosyasi Ureticisi
Tum SFX ve muzik dosyalarini sentezleyip OGG formatinda kaydeder.
"""

import os
import wave
import struct
import math
import random
import subprocess
import sys

try:
    import numpy as np
except ImportError:
    print("numpy gerekli: pip3 install numpy")
    sys.exit(1)

SAMPLE_RATE = 48000
BASE_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'audio')
SFX_DIR = os.path.join(BASE_DIR, 'sfx')
MUSIC_DIR = os.path.join(BASE_DIR, 'music')

os.makedirs(SFX_DIR, exist_ok=True)
os.makedirs(MUSIC_DIR, exist_ok=True)


def normalize(signal, peak_db=-6):
    """Normalize signal to peak dBFS."""
    peak = np.max(np.abs(signal))
    if peak == 0:
        return signal
    target = 10 ** (peak_db / 20.0)
    return signal * (target / peak)


def apply_envelope(signal, attack=0.01, decay=0.0, sustain=1.0, release=0.05):
    """ADSR envelope."""
    n = len(signal)
    if n == 0:
        return signal
    env = np.ones(n)
    a_samples = min(int(attack * SAMPLE_RATE), n)
    r_samples = min(int(release * SAMPLE_RATE), n)
    d_samples = min(int(decay * SAMPLE_RATE), n)

    # Attack
    if a_samples > 0:
        env[:a_samples] = np.linspace(0, 1, a_samples)
    # Decay
    if d_samples > 0:
        start = min(a_samples, n)
        end = min(start + d_samples, n)
        if end > start:
            env[start:end] = np.linspace(1, sustain, end - start)
            env[end:] = sustain
    # Release
    if r_samples > 0 and r_samples < n:
        env[-r_samples:] = np.linspace(env[-r_samples], 0, r_samples)

    return signal * env


def sine_wave(freq, duration, phase=0):
    """Generate sine wave."""
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), endpoint=False)
    return np.sin(2 * np.pi * freq * t + phase)


def noise(duration, color='white'):
    """Generate noise."""
    n = int(SAMPLE_RATE * duration)
    white = np.random.randn(n)
    if color == 'white':
        return white
    elif color == 'pink':
        # Simple pink noise approximation
        b = [0.049922035, -0.095993537, 0.050612699, -0.004709510]
        a = [1, -2.494956002, 2.017265875, -0.522189400]
        from scipy.signal import lfilter
        return lfilter(b, a, white)
    return white


def low_pass_simple(signal, cutoff_ratio=0.1):
    """Very simple low-pass filter via moving average."""
    window = max(int(1.0 / cutoff_ratio), 3)
    kernel = np.ones(window) / window
    return np.convolve(signal, kernel, mode='same')


def pitch_slide(start_freq, end_freq, duration):
    """Frequency sweep."""
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), endpoint=False)
    freqs = np.linspace(start_freq, end_freq, len(t))
    phase = np.cumsum(2 * np.pi * freqs / SAMPLE_RATE)
    return np.sin(phase)


def mix_signals(*signals):
    """Mix signals of potentially different lengths by zero-padding shorter ones."""
    max_len = max(len(s) for s in signals)
    result = np.zeros(max_len)
    for s in signals:
        result[:len(s)] += s
    return result


def reverb_tail(signal, decay_time=0.3, mix=0.3):
    """Simple reverb via delayed copies."""
    n = len(signal)
    out = signal.copy()
    delays = [int(SAMPLE_RATE * d) for d in [0.023, 0.041, 0.067, 0.089]]
    for i, delay in enumerate(delays):
        amplitude = mix * (0.7 ** i)
        padded = np.zeros(n)
        if delay < n:
            padded[delay:] = signal[:n - delay] * amplitude
            out += padded
    # Decay tail
    tail_samples = int(decay_time * SAMPLE_RATE)
    if tail_samples > 0 and n > 0:
        fade = np.ones(n)
        fade_start = max(n - tail_samples, 0)
        fade[fade_start:] = np.linspace(1, 0, n - fade_start)
        out *= fade
    return out


def save_wav(filename, signal):
    """Save signal as 16-bit mono WAV."""
    signal = np.clip(signal, -1.0, 1.0)
    data = (signal * 32767).astype(np.int16)
    filepath = os.path.join(SFX_DIR, filename)
    with wave.open(filepath, 'w') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(data.tobytes())
    return filepath


def save_wav_music(filename, signal):
    """Save signal as 16-bit mono WAV in music dir."""
    signal = np.clip(signal, -1.0, 1.0)
    data = (signal * 32767).astype(np.int16)
    filepath = os.path.join(MUSIC_DIR, filename)
    with wave.open(filepath, 'w') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(data.tobytes())
    return filepath


def wav_to_ogg(wav_path):
    """Convert WAV to OGG (Opus) using ffmpeg."""
    ogg_path = wav_path.replace('.wav', '.ogg')
    try:
        subprocess.run(
            ['ffmpeg', '-y', '-i', wav_path, '-c:a', 'libopus', '-b:a', '96k', ogg_path],
            capture_output=True, check=True
        )
        os.remove(wav_path)
        return ogg_path
    except FileNotFoundError:
        print(f"  ffmpeg not found — keeping WAV: {wav_path}")
        return wav_path
    except subprocess.CalledProcessError as e:
        print(f"  ffmpeg error: {e.stderr.decode()[:200]}")
        return wav_path


def wav_to_mp3(wav_path):
    """Convert WAV to MP3 using ffmpeg."""
    mp3_path = wav_path.replace('.wav', '.mp3')
    try:
        subprocess.run(
            ['ffmpeg', '-y', '-i', wav_path, '-c:a', 'libmp3lame', '-q:a', '2', mp3_path],
            capture_output=True, check=True
        )
        os.remove(wav_path)
        return mp3_path
    except (FileNotFoundError, subprocess.CalledProcessError):
        return wav_path


# ─── SFX Generators ──────────────────────────────────────────────────────

def gen_gel_place():
    """Squelchy gel placement — 200-400Hz base + harmonics + noise burst."""
    dur = 0.25
    base = sine_wave(280, dur) * 0.6
    harm = sine_wave(560, dur) * 0.2 + sine_wave(840, dur) * 0.1
    squelch = low_pass_simple(noise(dur) * 0.3, 0.02)
    sig = base + harm + squelch
    sig = apply_envelope(sig, attack=0.005, release=0.08)
    sig = reverb_tail(sig, 0.15, 0.2)
    return normalize(sig)


def gen_gel_place_soft():
    """Softer gel placement variant."""
    dur = 0.2
    base = sine_wave(220, dur) * 0.5
    harm = sine_wave(440, dur) * 0.15
    squelch = low_pass_simple(noise(dur) * 0.15, 0.015)
    sig = base + harm + squelch
    sig = apply_envelope(sig, attack=0.008, release=0.1)
    sig = reverb_tail(sig, 0.2, 0.15)
    return normalize(sig)


def gen_merge(size='small'):
    """Slime merge sound — bubble pop + reverb."""
    params = {
        'small': (300, 0.2, 0.1),
        'medium': (250, 0.3, 0.2),
        'large': (200, 0.4, 0.3),
    }
    freq, dur, rev = params[size]
    bubble = pitch_slide(freq, freq * 1.8, dur * 0.3) * 0.7
    body = sine_wave(freq * 0.8, dur) * 0.4
    pop = noise(0.02) * 0.5
    pop = apply_envelope(pop, attack=0.001, release=0.015)

    sig = np.zeros(int(SAMPLE_RATE * dur))
    sig[:len(bubble)] += bubble
    sig[:len(body)] += body
    pop_start = int(0.05 * SAMPLE_RATE)
    sig[pop_start:pop_start + len(pop)] += pop

    sig = apply_envelope(sig, attack=0.003, release=0.06)
    sig = reverb_tail(sig, rev, 0.25)
    return normalize(sig)


def gen_line_clear():
    """Ascending arpeggio C4→E4→G4→C5 crystal chime."""
    freqs = [261.63, 329.63, 392.00, 523.25]  # C4 E4 G4 C5
    dur_per = 0.1
    gap = 0.035
    total = len(freqs) * (dur_per + gap) + 0.3
    sig = np.zeros(int(SAMPLE_RATE * total))

    for i, f in enumerate(freqs):
        start = int(i * (dur_per + gap) * SAMPLE_RATE)
        note = sine_wave(f, dur_per) * 0.4 + sine_wave(f * 2, dur_per) * 0.2
        note = apply_envelope(note, attack=0.003, release=0.05)
        end = min(start + len(note), len(sig))
        sig[start:end] += note[:end - start]

    # Crystal shimmer overlay
    shimmer = mix_signals(sine_wave(3000, 0.15) * 0.1, sine_wave(4000, 0.1) * 0.08)
    shimmer = apply_envelope(shimmer, attack=0.01, release=0.08)
    s = int(0.3 * SAMPLE_RATE)
    e = min(s + len(shimmer), len(sig))
    sig[s:e] += shimmer[:e - s]

    sig = reverb_tail(sig, 0.3, 0.25)
    return normalize(sig)


def gen_line_clear_crystal():
    """Higher-pitched crystal variant."""
    freqs = [523.25, 659.25, 783.99, 1046.50]  # C5 E5 G5 C6
    dur_per = 0.08
    total = len(freqs) * dur_per + 0.4
    sig = np.zeros(int(SAMPLE_RATE * total))

    for i, f in enumerate(freqs):
        start = int(i * dur_per * SAMPLE_RATE)
        note = sine_wave(f, dur_per) * 0.35 + sine_wave(f * 3, dur_per) * 0.12
        note = apply_envelope(note, attack=0.002, release=0.04)
        end = min(start + len(note), len(sig))
        sig[start:end] += note[:end - start]

    sig = reverb_tail(sig, 0.4, 0.3)
    return normalize(sig)


def gen_combo(tier='small'):
    """Combo sounds — escalating from ping to full chord."""
    if tier == 'small':
        # Single note ping E5
        sig = sine_wave(659.25, 0.15) * 0.5 + sine_wave(1318.5, 0.15) * 0.2
        sig = apply_envelope(sig, attack=0.003, release=0.08)
        sig = reverb_tail(sig, 0.2, 0.2)

    elif tier == 'medium':
        # Two notes E5→G5
        n1 = sine_wave(659.25, 0.12) * 0.45
        n2 = sine_wave(783.99, 0.15) * 0.5
        n1 = apply_envelope(n1, attack=0.003, release=0.05)
        n2 = apply_envelope(n2, attack=0.003, release=0.08)
        sig = np.zeros(int(SAMPLE_RATE * 0.4))
        sig[:len(n1)] += n1
        s = int(0.13 * SAMPLE_RATE)
        sig[s:s + len(n2)] += n2
        sig = reverb_tail(sig, 0.25, 0.25)

    elif tier == 'large':
        # Three note arpeggio + sub-bass
        notes = [(659.25, 0.1), (783.99, 0.1), (1046.5, 0.15)]
        sig = np.zeros(int(SAMPLE_RATE * 0.5))
        for i, (f, d) in enumerate(notes):
            s = int(i * 0.1 * SAMPLE_RATE)
            n = sine_wave(f, d) * 0.4 + sine_wave(f * 2, d) * 0.15
            n = apply_envelope(n, attack=0.003, release=0.06)
            e = min(s + len(n), len(sig))
            sig[s:e] += n[:e - s]
        # Sub-bass hit
        sub = sine_wave(70, 0.2) * 0.35
        sub = apply_envelope(sub, attack=0.005, release=0.1)
        sig[:len(sub)] += sub
        sig = reverb_tail(sig, 0.3, 0.3)

    else:  # epic
        # Full chord + reversed cymbal swell + heavy sub-bass
        chord_freqs = [523.25, 659.25, 783.99, 1046.5]
        sig = np.zeros(int(SAMPLE_RATE * 0.8))
        for f in chord_freqs:
            n = sine_wave(f, 0.4) * 0.25
            n = apply_envelope(n, attack=0.01, release=0.15)
            sig[:len(n)] += n
        # Sub-bass
        sub = sine_wave(60, 0.3) * 0.4
        sub = apply_envelope(sub, attack=0.01, release=0.15)
        sig[:len(sub)] += sub
        # Cymbal swell (reversed noise)
        cym = noise(0.3) * 0.15
        cym = apply_envelope(cym, attack=0.25, release=0.02)
        sig[:len(cym)] += cym
        sig = reverb_tail(sig, 0.4, 0.35)

    return normalize(sig)


def gen_button_tap():
    """Short UI click."""
    dur = 0.06
    sig = sine_wave(1200, dur) * 0.4 + sine_wave(2400, dur) * 0.15
    click = noise(0.008) * 0.3
    click = apply_envelope(click, attack=0.001, release=0.005)
    sig = apply_envelope(sig, attack=0.001, release=0.03)
    sig[:len(click)] += click
    return normalize(sig)


def gen_level_complete():
    """Triumphant ascending phrase."""
    freqs = [523.25, 659.25, 783.99, 1046.5, 1318.5]  # C5 E5 G5 C6 E6
    dur_per = 0.12
    total = len(freqs) * dur_per + 0.5
    sig = np.zeros(int(SAMPLE_RATE * total))

    for i, f in enumerate(freqs):
        s = int(i * dur_per * SAMPLE_RATE)
        n = mix_signals(sine_wave(f, dur_per * 1.5) * 0.35, sine_wave(f * 2, dur_per) * 0.12)
        n = apply_envelope(n, attack=0.005, release=0.1)
        e = min(s + len(n), len(sig))
        sig[s:e] += n[:e - s]

    sig = reverb_tail(sig, 0.5, 0.3)
    return normalize(sig)


def gen_game_over():
    """Descending sad phrase."""
    freqs = [392.00, 349.23, 293.66, 261.63]  # G4 F4 D4 C4
    dur_per = 0.2
    total = len(freqs) * dur_per + 0.4
    sig = np.zeros(int(SAMPLE_RATE * total))

    for i, f in enumerate(freqs):
        s = int(i * dur_per * SAMPLE_RATE)
        n = sine_wave(f, dur_per * 1.2) * 0.35
        n = apply_envelope(n, attack=0.01, release=0.12)
        e = min(s + len(n), len(sig))
        sig[s:e] += n[:e - s]

    sig = reverb_tail(sig, 0.4, 0.3)
    return normalize(sig)


def gen_near_miss_tension():
    """Tense warning pulse."""
    dur = 0.4
    pulse = sine_wave(220, dur) * 0.4
    # Tremolo
    t = np.linspace(0, dur, int(SAMPLE_RATE * dur), endpoint=False)
    tremolo = 0.5 + 0.5 * np.sin(2 * np.pi * 8 * t)
    pulse *= tremolo
    # Dissonant overtone
    dis = sine_wave(233, dur) * 0.15  # Slightly detuned
    sig = pulse + dis
    sig = apply_envelope(sig, attack=0.02, release=0.1)
    return normalize(sig)


def gen_near_miss_relief():
    """Relief resolution chord."""
    dur = 0.3
    sig = sine_wave(523.25, dur) * 0.3 + sine_wave(659.25, dur) * 0.25 + sine_wave(783.99, dur) * 0.2
    sig = apply_envelope(sig, attack=0.01, release=0.15)
    sig = reverb_tail(sig, 0.3, 0.25)
    return normalize(sig)


def gen_ice_break():
    """Ice cracking sound — noise burst + high freq."""
    dur = 0.15
    crack = noise(dur) * 0.5
    crack = low_pass_simple(crack, 0.08)
    high = mix_signals(sine_wave(3500, 0.05) * 0.3, sine_wave(5000, 0.03) * 0.15)
    high = apply_envelope(high, attack=0.001, release=0.03)
    sig = apply_envelope(crack, attack=0.001, release=0.05)
    sig[:len(high)] += high
    return normalize(sig)


def gen_ice_crack():
    """Subtle ice crack."""
    dur = 0.1
    sig = noise(dur) * 0.35
    sig = low_pass_simple(sig, 0.12)
    sig = apply_envelope(sig, attack=0.001, release=0.04)
    # Tiny ping
    ping = sine_wave(4000, 0.02) * 0.2
    ping = apply_envelope(ping, attack=0.001, release=0.015)
    sig[:len(ping)] += ping
    return normalize(sig)


def gen_powerup_activate():
    """Sparkle activation sound."""
    dur = 0.35
    sweep = pitch_slide(800, 2000, dur) * 0.3
    shimmer = mix_signals(sine_wave(1500, dur) * 0.15, sine_wave(3000, dur * 0.5) * 0.1)
    sparkle = noise(0.05) * 0.2
    sparkle = apply_envelope(sparkle, attack=0.002, release=0.03)
    sig = np.zeros(int(SAMPLE_RATE * dur))
    sig[:len(sweep)] += sweep
    sig[:len(shimmer)] += shimmer
    s = int(0.05 * SAMPLE_RATE)
    sig[s:s + len(sparkle)] += sparkle
    sig = apply_envelope(sig, attack=0.005, release=0.1)
    sig = reverb_tail(sig, 0.2, 0.2)
    return normalize(sig)


def gen_bomb_explosion():
    """Deep explosion — sub-bass + noise."""
    dur = 0.5
    sub = mix_signals(sine_wave(50, dur) * 0.5, sine_wave(80, dur * 0.7) * 0.3)
    boom = noise(0.15) * 0.4
    boom = low_pass_simple(boom, 0.03)
    boom = apply_envelope(boom, attack=0.002, release=0.08)
    sig = apply_envelope(sub, attack=0.005, release=0.2)
    sig[:len(boom)] += boom
    sig = reverb_tail(sig, 0.3, 0.3)
    return normalize(sig)


def gen_rotate_click():
    """Quick mechanical click."""
    dur = 0.08
    sig = sine_wave(1800, dur) * 0.3
    click = noise(0.01) * 0.4
    click = apply_envelope(click, attack=0.001, release=0.008)
    sig = apply_envelope(sig, attack=0.001, release=0.04)
    sig[:len(click)] += click
    return normalize(sig)


def gen_undo_whoosh():
    """Reverse whoosh sound."""
    dur = 0.3
    sweep = pitch_slide(2000, 400, dur) * 0.35
    wind = noise(dur) * 0.15
    wind = low_pass_simple(wind, 0.04)
    sig = sweep + wind
    sig = apply_envelope(sig, attack=0.15, release=0.05)
    return normalize(sig)


def gen_freeze_chime():
    """Icy chime — high freq + crystalline."""
    dur = 0.4
    chime = sine_wave(2093, dur) * 0.3  # C7
    harm = sine_wave(4186, dur * 0.5) * 0.15
    crystal = sine_wave(3135, 0.2) * 0.12  # G7
    sig = np.zeros(int(SAMPLE_RATE * dur))
    sig[:len(chime)] += chime
    sig[:len(harm)] += harm
    s = int(0.1 * SAMPLE_RATE)
    sig[s:s + len(crystal)] += crystal
    sig = apply_envelope(sig, attack=0.005, release=0.15)
    sig = reverb_tail(sig, 0.35, 0.3)
    return normalize(sig)


def gen_gravity_drop():
    """Falling/dropping sound."""
    dur = 0.2
    drop = pitch_slide(600, 150, dur) * 0.4
    thud = sine_wave(100, 0.05) * 0.3
    thud = apply_envelope(thud, attack=0.002, release=0.03)
    sig = np.zeros(int(SAMPLE_RATE * dur))
    sig[:len(drop)] += drop
    sig = apply_envelope(sig, attack=0.003, release=0.05)
    # Thud at the end
    t = int(0.15 * SAMPLE_RATE)
    e = min(t + len(thud), len(sig))
    sig[t:e] += thud[:e - t]
    return normalize(sig)


def gen_color_synth():
    """Short synthesis blip."""
    dur = 0.2
    sig = pitch_slide(200, 800, dur) * 0.4
    buzz = sine_wave(150, 0.1) * 0.2
    sig[:len(buzz)] += buzz
    sig = apply_envelope(sig, attack=0.005, release=0.08)
    return normalize(sig)


def gen_color_synthesis():
    """Full synthesis — bubble merge + pitch slide."""
    dur = 0.4
    bubble = pitch_slide(150, 300, 0.15) * 0.35
    slide = pitch_slide(300, 800, 0.25) * 0.3
    buzz = sine_wave(100, 0.1) * 0.2
    sig = np.zeros(int(SAMPLE_RATE * dur))
    sig[:len(bubble)] += bubble
    s = int(0.15 * SAMPLE_RATE)
    sig[s:s + len(slide)] += slide
    sig[:len(buzz)] += buzz
    sig = apply_envelope(sig, attack=0.005, release=0.1)
    sig = reverb_tail(sig, 0.25, 0.2)
    return normalize(sig)


def gen_pvp_obstacle_sent():
    """Whoosh outward."""
    dur = 0.2
    sig = pitch_slide(400, 1200, dur) * 0.35
    sig = apply_envelope(sig, attack=0.005, release=0.06)
    return normalize(sig)


def gen_pvp_obstacle_received():
    """Impact incoming."""
    dur = 0.25
    impact = sine_wave(150, dur) * 0.4
    hit = noise(0.03) * 0.35
    hit = apply_envelope(hit, attack=0.001, release=0.02)
    sig = apply_envelope(impact, attack=0.003, release=0.1)
    sig[:len(hit)] += hit
    return normalize(sig)


def gen_pvp_victory():
    """Triumphant fanfare."""
    freqs = [523.25, 659.25, 783.99, 1046.5]
    dur_per = 0.15
    total = len(freqs) * dur_per + 0.4
    sig = np.zeros(int(SAMPLE_RATE * total))
    for i, f in enumerate(freqs):
        s = int(i * dur_per * SAMPLE_RATE)
        n = mix_signals(sine_wave(f, dur_per * 1.5) * 0.35, sine_wave(f * 2, dur_per) * 0.12)
        n = apply_envelope(n, attack=0.005, release=0.1)
        e = min(s + len(n), len(sig))
        sig[s:e] += n[:e - s]
    sig = reverb_tail(sig, 0.4, 0.3)
    return normalize(sig)


def gen_pvp_defeat():
    """Sad descending tones."""
    freqs = [392.00, 311.13, 261.63]  # G4 Eb4 C4
    dur_per = 0.25
    total = len(freqs) * dur_per + 0.3
    sig = np.zeros(int(SAMPLE_RATE * total))
    for i, f in enumerate(freqs):
        s = int(i * dur_per * SAMPLE_RATE)
        n = sine_wave(f, dur_per * 1.3) * 0.3
        n = apply_envelope(n, attack=0.01, release=0.15)
        e = min(s + len(n), len(sig))
        sig[s:e] += n[:e - s]
    sig = reverb_tail(sig, 0.35, 0.3)
    return normalize(sig)


def gen_level_complete_new():
    """Sparkly level complete with extra shine."""
    base = gen_level_complete()
    # Add sparkle overlay
    sparkle = mix_signals(sine_wave(4000, 0.1) * 0.08, sine_wave(5000, 0.08) * 0.06)
    sparkle = apply_envelope(sparkle, attack=0.002, release=0.05)
    s = int(0.4 * SAMPLE_RATE)
    e = min(s + len(sparkle), len(base))
    base[s:e] += sparkle[:e - s]
    return normalize(base)


def gen_gel_ozu_earn():
    """Currency earn — coin-like ding."""
    dur = 0.2
    sig = mix_signals(sine_wave(1500, dur) * 0.35, sine_wave(3000, dur * 0.5) * 0.15)
    sig = apply_envelope(sig, attack=0.002, release=0.1)
    sig = reverb_tail(sig, 0.15, 0.15)
    return normalize(sig)


# ─── Music Generators ─────────────────────────────────────────────────────

def gen_lofi_loop(duration=30.0, key_freq=261.63, tempo_bpm=75, name='loop'):
    """Generate a lofi ambient loop."""
    sig = np.zeros(int(SAMPLE_RATE * duration))
    beat_dur = 60.0 / tempo_bpm

    # Pad chords
    chord_freqs_list = [
        [key_freq, key_freq * 5 / 4, key_freq * 3 / 2],  # I
        [key_freq * 4 / 3, key_freq * 5 / 3, key_freq * 2],  # IV
        [key_freq * 3 / 2, key_freq * 15 / 8, key_freq * 9 / 4],  # V
        [key_freq * 5 / 6, key_freq, key_freq * 5 / 4],  # vi
    ]

    chord_dur = beat_dur * 4
    t_pos = 0
    chord_idx = 0

    while t_pos < duration:
        freqs = chord_freqs_list[chord_idx % len(chord_freqs_list)]
        for f in freqs:
            note = sine_wave(f, min(chord_dur, duration - t_pos)) * 0.08
            note = apply_envelope(note, attack=0.3, release=0.3)
            s = int(t_pos * SAMPLE_RATE)
            e = min(s + len(note), len(sig))
            sig[s:e] += note[:e - s]

        t_pos += chord_dur
        chord_idx += 1

    # Gentle noise bed
    noise_bed = noise(duration) * 0.02
    noise_bed = low_pass_simple(noise_bed, 0.005)
    sig[:len(noise_bed)] += noise_bed

    # Smooth crossfade for looping (last 2 seconds fade into first 2 seconds)
    fade_samples = int(2.0 * SAMPLE_RATE)
    if len(sig) > fade_samples * 2:
        fade_out = np.linspace(1, 0, fade_samples)
        fade_in = np.linspace(0, 1, fade_samples)
        sig[-fade_samples:] *= fade_out
        sig[:fade_samples] *= fade_in

    return normalize(sig, peak_db=-10)


def gen_menu_lofi():
    return gen_lofi_loop(30.0, 261.63, 72, 'menu')


def gen_game_relax():
    return gen_lofi_loop(30.0, 293.66, 80, 'relax')  # D4


def gen_game_tension():
    return gen_lofi_loop(30.0, 220.00, 95, 'tension')  # A3, faster


def gen_zen_ambient():
    """Very slow, dreamy ambient."""
    return gen_lofi_loop(30.0, 196.00, 55, 'zen')  # G3, very slow


# ─── Main ─────────────────────────────────────────────────────────────────

def main():
    sfx_files = [
        ('gel_place.ogg', gen_gel_place),
        ('gel_place_soft.ogg', gen_gel_place_soft),
        ('gel_merge_small.ogg', lambda: gen_merge('small')),
        ('gel_merge_medium.ogg', lambda: gen_merge('medium')),
        ('gel_merge_large.ogg', lambda: gen_merge('large')),
        ('line_clear.ogg', gen_line_clear),
        ('line_clear_crystal.ogg', gen_line_clear_crystal),
        ('combo_small.ogg', lambda: gen_combo('small')),
        ('combo_medium.ogg', lambda: gen_combo('medium')),
        ('combo_large.ogg', lambda: gen_combo('large')),
        ('combo_epic.ogg', lambda: gen_combo('epic')),
        ('button_tap.ogg', gen_button_tap),
        ('level_complete.ogg', gen_level_complete),
        ('game_over.ogg', gen_game_over),
        ('near_miss_tension.ogg', gen_near_miss_tension),
        ('near_miss_relief.ogg', gen_near_miss_relief),
        ('ice_break.ogg', gen_ice_break),
        ('ice_crack.ogg', gen_ice_crack),
        ('powerup_activate.ogg', gen_powerup_activate),
        ('bomb_explosion.ogg', gen_bomb_explosion),
        ('rotate_click.ogg', gen_rotate_click),
        ('undo_whoosh.ogg', gen_undo_whoosh),
        ('freeze_chime.ogg', gen_freeze_chime),
        ('gravity_drop.ogg', gen_gravity_drop),
        ('color_synth.ogg', gen_color_synth),
        ('color_synthesis.ogg', gen_color_synthesis),
        ('pvp_obstacle_sent.ogg', gen_pvp_obstacle_sent),
        ('pvp_obstacle_received.ogg', gen_pvp_obstacle_received),
        ('pvp_victory.ogg', gen_pvp_victory),
        ('pvp_defeat.ogg', gen_pvp_defeat),
        ('level_complete_new.ogg', gen_level_complete_new),
        ('gel_ozu_earn.ogg', gen_gel_ozu_earn),
    ]

    music_files = [
        ('menu_lofi.mp3', gen_menu_lofi),
        ('game_relax.mp3', gen_game_relax),
        ('game_tension.mp3', gen_game_tension),
        ('zen_ambient.mp3', gen_zen_ambient),
    ]

    print(f"=== Gloo Ses Dosyasi Ureticisi ===")
    print(f"SFX: {len(sfx_files)} dosya")
    print(f"Music: {len(music_files)} dosya")
    print()

    # SFX
    for filename, generator in sfx_files:
        wav_name = filename.replace('.ogg', '.wav')
        print(f"  Uretiliyor: {filename}...", end=' ')
        signal = generator()
        wav_path = save_wav(wav_name, signal)
        result = wav_to_ogg(wav_path)
        print(f"OK ({os.path.getsize(result)} bytes)")

    # Music
    for filename, generator in music_files:
        wav_name = filename.replace('.mp3', '.wav')
        print(f"  Uretiliyor: {filename}...", end=' ')
        signal = generator()
        wav_path = save_wav_music(wav_name, signal)
        result = wav_to_mp3(wav_path)
        print(f"OK ({os.path.getsize(result)} bytes)")

    print(f"\nToplam: {len(sfx_files) + len(music_files)} dosya uretildi.")
    print(f"SFX dizini: {SFX_DIR}")
    print(f"Music dizini: {MUSIC_DIR}")


if __name__ == '__main__':
    main()
