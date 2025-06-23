#!/usr/bin/env python3
"""
SNES-Style Audio Generator for Wedding Game
Creates authentic 16-bit chiptune sound effects using numpy and wave
"""

import numpy as np
import wave
import math
import os

class SNESAudioGenerator:
    def __init__(self, sample_rate=22050):  # Classic SNES sample rate
        self.sample_rate = sample_rate
        self.bit_depth = 16
        
    def generate_tone(self, frequency, duration, amplitude=0.5, wave_type='sine'):
        """Generate a basic tone with SNES characteristics"""
        samples = int(self.sample_rate * duration)
        t = np.linspace(0, duration, samples, False)
        
        if wave_type == 'sine':
            wave_data = amplitude * np.sin(2 * np.pi * frequency * t)
        elif wave_type == 'square':
            wave_data = amplitude * np.sign(np.sin(2 * np.pi * frequency * t))
        elif wave_type == 'sawtooth':
            wave_data = amplitude * (2 * (t * frequency - np.floor(t * frequency + 0.5)))
        elif wave_type == 'triangle':
            wave_data = amplitude * (2 * np.arcsin(np.sin(2 * np.pi * frequency * t)) / np.pi)
        
        return wave_data
    
    def apply_envelope(self, wave_data, attack=0.1, decay=0.1, sustain=0.7, release=0.2):
        """Apply ADSR envelope to simulate classic SNES sound shaping"""
        samples = len(wave_data)
        envelope = np.ones(samples)
        
        attack_samples = int(attack * samples)
        decay_samples = int(decay * samples)
        release_samples = int(release * samples)
        sustain_samples = samples - attack_samples - decay_samples - release_samples
        
        # Attack
        envelope[:attack_samples] = np.linspace(0, 1, attack_samples)
        
        # Decay
        start_idx = attack_samples
        end_idx = start_idx + decay_samples
        envelope[start_idx:end_idx] = np.linspace(1, sustain, decay_samples)
        
        # Sustain
        start_idx = end_idx
        end_idx = start_idx + sustain_samples
        envelope[start_idx:end_idx] = sustain
        
        # Release
        start_idx = end_idx
        envelope[start_idx:] = np.linspace(sustain, 0, release_samples)
        
        return wave_data * envelope
    
    def add_vibrato(self, wave_data, vibrato_frequency=5, vibrato_depth=0.1):
        """Add vibrato effect common in SNES audio"""
        samples = len(wave_data)
        t = np.linspace(0, len(wave_data) / self.sample_rate, samples)
        vibrato = 1 + vibrato_depth * np.sin(2 * np.pi * vibrato_frequency * t)
        return wave_data * vibrato
    
    def quantize_to_8bit(self, wave_data):
        """Simulate 8-bit quantization for more authentic SNES sound"""
        # Convert to 8-bit equivalent resolution
        quantized = np.round(wave_data * 127) / 127
        return quantized
    
    def save_wav(self, wave_data, filename):
        """Save wave data as WAV file"""
        # Ensure directory exists
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        
        # Convert to 16-bit integers
        wave_data_int = np.int16(wave_data * 32767)
        
        with wave.open(filename, 'w') as wav_file:
            wav_file.setnchannels(1)  # Mono
            wav_file.setsampwidth(2)  # 16-bit
            wav_file.setframerate(self.sample_rate)
            wav_file.writeframes(wave_data_int.tobytes())
    
    def create_wedding_bell(self):
        """Create a cheerful wedding bell chime"""
        # Bell-like sound with multiple harmonics
        base_freq = 523  # C5
        duration = 1.5
        
        # Create bell harmonics
        harmonics = [1, 2, 3, 4.2, 5.4]  # Bell-like harmonic series
        amplitudes = [1.0, 0.6, 0.4, 0.3, 0.2]
        
        bell_sound = np.zeros(int(self.sample_rate * duration))
        
        for harmonic, amplitude in zip(harmonics, amplitudes):
            freq = base_freq * harmonic
            tone = self.generate_tone(freq, duration, amplitude * 0.3, 'sine')
            bell_sound += tone
        
        # Apply envelope and effects
        bell_sound = self.apply_envelope(bell_sound, 0.01, 0.1, 0.6, 0.8)
        bell_sound = self.add_vibrato(bell_sound, 3, 0.05)
        
        return bell_sound
    
    def create_success_chime(self):
        """Create a success/achievement sound"""
        notes = [523, 659, 784]  # C-E-G major chord
        duration = 0.4
        
        chord = np.zeros(int(self.sample_rate * duration))
        
        for note in notes:
            tone = self.generate_tone(note, duration, 0.3, 'sine')
            tone = self.apply_envelope(tone, 0.02, 0.1, 0.8, 0.3)
            chord += tone
        
        return chord
    
    def create_menu_select(self):
        """Create a menu selection beep"""
        frequency = 800
        duration = 0.1
        
        beep = self.generate_tone(frequency, duration, 0.5, 'square')
        beep = self.apply_envelope(beep, 0.01, 0.02, 0.9, 0.05)
        beep = self.quantize_to_8bit(beep)
        
        return beep
    
    def create_menu_confirm(self):
        """Create a menu confirmation sound"""
        # Two-tone confirmation
        tone1 = self.generate_tone(600, 0.08, 0.4, 'square')
        tone2 = self.generate_tone(800, 0.12, 0.4, 'square')
        
        # Add small gap between tones
        gap = np.zeros(int(self.sample_rate * 0.02))
        
        confirm = np.concatenate([tone1, gap, tone2])
        confirm = self.apply_envelope(confirm, 0.01, 0.05, 0.8, 0.1)
        
        return confirm
    
    def create_celebration_fanfare(self):
        """Create a celebratory fanfare"""
        # Rising notes sequence
        notes = [392, 440, 494, 523, 587, 659]  # G-A-B-C-D-E
        duration_per_note = 0.15
        
        fanfare = np.array([])
        
        for note in notes:
            tone = self.generate_tone(note, duration_per_note, 0.6, 'square')
            tone = self.apply_envelope(tone, 0.01, 0.05, 0.8, 0.05)
            fanfare = np.concatenate([fanfare, tone])
        
        # Add final chord
        final_chord = np.zeros(int(self.sample_rate * 0.5))
        for note in [523, 659, 784]:  # C major chord
            tone = self.generate_tone(note, 0.5, 0.4, 'sine')
            tone = self.apply_envelope(tone, 0.02, 0.1, 0.7, 0.3)
            final_chord += tone
        
        fanfare = np.concatenate([fanfare, final_chord])
        
        return fanfare
    
    def create_disaster_alarm(self):
        """Create a disaster warning sound"""
        # Alternating high-low alarm
        high_freq = 1000
        low_freq = 600
        duration = 0.3
        
        high_tone = self.generate_tone(high_freq, duration, 0.6, 'square')
        low_tone = self.generate_tone(low_freq, duration, 0.6, 'square')
        
        # Apply sharp envelope for alarm effect
        high_tone = self.apply_envelope(high_tone, 0.01, 0.1, 0.9, 0.05)
        low_tone = self.apply_envelope(low_tone, 0.01, 0.1, 0.9, 0.05)
        
        # Repeat pattern
        alarm = np.concatenate([high_tone, low_tone, high_tone, low_tone])
        
        return alarm
    
    def create_bingo_correct(self):
        """Create a correct answer sound for Glen's bingo"""
        # Happy ascending arpeggio
        notes = [523, 659, 784, 1047]  # C-E-G-C octave
        duration_per_note = 0.1
        
        arpeggio = np.array([])
        
        for i, note in enumerate(notes):
            amplitude = 0.5 - (i * 0.05)  # Gradually decrease volume
            tone = self.generate_tone(note, duration_per_note, amplitude, 'sine')
            tone = self.apply_envelope(tone, 0.01, 0.02, 0.9, 0.02)
            arpeggio = np.concatenate([arpeggio, tone])
        
        return arpeggio
    
    def create_bingo_wrong(self):
        """Create a wrong answer sound for Glen's bingo"""
        # Descending disappointed sound
        notes = [400, 350, 300]
        duration_per_note = 0.2
        
        sad_sound = np.array([])
        
        for note in notes:
            tone = self.generate_tone(note, duration_per_note, 0.4, 'sawtooth')
            tone = self.apply_envelope(tone, 0.05, 0.1, 0.7, 0.3)
            sad_sound = np.concatenate([sad_sound, tone])
        
        return sad_sound

# Generate all the wedding game sound effects
def generate_wedding_sounds():
    generator = SNESAudioGenerator()
    output_dir = "/home/joe/Documents/wedding-game-v7/assets/audio/sfx/"
    
    sounds = {
        "wedding_bell_chime.wav": generator.create_wedding_bell(),
        "success_chime.wav": generator.create_success_chime(),
        "menu_select_snes.wav": generator.create_menu_select(),
        "menu_confirm_snes.wav": generator.create_menu_confirm(),
        "celebration_fanfare.wav": generator.create_celebration_fanfare(),
        "disaster_alarm.wav": generator.create_disaster_alarm(),
        "bingo_correct.wav": generator.create_bingo_correct(),
        "bingo_wrong.wav": generator.create_bingo_wrong(),
    }
    
    for filename, wave_data in sounds.items():
        filepath = output_dir + filename
        generator.save_wav(wave_data, filepath)
        print(f"Generated: {filename}")

if __name__ == "__main__":
    generate_wedding_sounds()
    print("All SNES-style wedding sound effects generated successfully!")