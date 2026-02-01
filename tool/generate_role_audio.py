#!/usr/bin/env python3
"""
LietuCoach Role Audio Generator (Traveler v1)

Generates audio files for role packs using Google Cloud Text-to-Speech.
Adapts logic from generate_tts_audio.py for the Role schema.
"""

import os
import sys
import json
import time
from pathlib import Path

# Configuration
CONFIG = {
    'voice': 'lt-LT-Standard-A',
    'rate_normal': 1.0,
    'rate_slow': 0.7,
    'json_path': Path('assets/packs/roles/traveler_v1.json'),
    'output_root': Path('assets/audio/roles/traveler'), # Direct to assets as per user request/sync
    'request_delay': 0.5,
}

def check_credentials():
    creds = os.environ.get('GOOGLE_APPLICATION_CREDENTIALS')
    if not creds:
        repo_root = Path(__file__).resolve().parent.parent
        default_creds = repo_root / '.secrets' / 'gcp_service_account.json'
        if default_creds.exists():
            print(f"✓ Auto-detected credentials: {default_creds}")
            os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = str(default_creds)
            return True
    return bool(creds)

def main():
    print("╔════════════════════════════════════════════╗")
    print("║     LietuCoach Role Audio Generator        ║")
    print("╚════════════════════════════════════════════╝")

    if not check_credentials():
        print("ERROR: Credentials not found in .secrets/gcp_service_account.json")
        sys.exit(1)

    try:
        from google.cloud import texttospeech
        client = texttospeech.TextToSpeechClient()
        print("✓ Connected to Google Cloud TTS")
    except ImportError:
        print("ERROR: google-cloud-texttospeech not installed.")
        print("Run: pip install google-cloud-texttospeech")
        sys.exit(1)
    except Exception as e:
        print(f"ERROR: Client init failed: {e}")
        sys.exit(1)

    # Load JSON
    if not CONFIG['json_path'].exists():
        print(f"ERROR: JSON not found at {CONFIG['json_path']}")
        sys.exit(1)

    with open(CONFIG['json_path'], 'r', encoding='utf-8') as f:
        data = json.load(f)

    stats = {'generated': 0, 'skipped': 0, 'errors': 0}

    # Iterate Scenarios -> Dialogues -> Turns/Takeaways
    for scenario in data.get('scenarios', []):
        scenario_id = scenario['id'] # e.g. "airport"
        
        for dialogue in scenario.get('dialogues', []):
            # Process Turns
            for i, turn in enumerate(dialogue.get('turns', [])):
                text = turn.get('ltText')
                path = turn.get('audioNormalPath') # e.g. "assets/audio/roles/traveler/airport/checkin_01.mp3"
                
                if text and path:
                    # Fix extension if we want OGG, but JSON says MP3.
                    # Current JSON says .mp3. Just Audio plays OGG in MP3 container sometimes, but better to write what it says.
                    # However, Google TTS output is OGG_OPUS (as per other script).
                    # Writing OGG content to .mp3 file usually works in VLC/ExoPlayer but is technically wrong.
                    # User asked about format. Let's write valid content. 
                    # If paths are .mp3, we request MP3 encoding from Google.
                    
                    target_file = Path(path)
                    if target_file.exists():
                        print(f"  Skipping: {target_file.name}")
                        stats['skipped'] += 1
                        continue

                    print(f"  Generating: {target_file.name}")
                    
                    try:
                        synthesis_input = texttospeech.SynthesisInput(text=text)
                        voice = texttospeech.VoiceSelectionParams(
                            language_code='lt-LT', name=CONFIG['voice']
                        )
                        # Determine encoding based on extension
                        suffix = target_file.suffix.lower()
                        if suffix == '.mp3':
                            encoding = texttospeech.AudioEncoding.MP3
                        else:
                            encoding = texttospeech.AudioEncoding.OGG_OPUS

                        audio_config = texttospeech.AudioConfig(
                            audio_encoding=encoding,
                            speaking_rate=CONFIG['rate_normal']
                        )

                        response = client.synthesize_speech(
                            input=synthesis_input, voice=voice, audio_config=audio_config
                        )

                        target_file.parent.mkdir(parents=True, exist_ok=True)
                        with open(target_file, 'wb') as out:
                            out.write(response.audio_content)
                        
                        stats['generated'] += 1
                        time.sleep(CONFIG['request_delay']) # Rate limit

                    except Exception as e:
                        print(f"  FAILED: {e}")
                        stats['errors'] += 1

            # Process Takeaways
            for item in dialogue.get('takeaways', []):
                text = item.get('lt')
                path = item.get('audioNormalPath')
                if text and path:
                    target_file = Path(path)
                    if target_file.exists():
                        stats['skipped'] += 1
                        continue
                    
                    try:
                        # ... repeating logic roughly, functionalizing would be better but simple script ok ...
                         # Reuse MP3 encoding
                        synthesis_input = texttospeech.SynthesisInput(text=text)
                        voice_params = texttospeech.VoiceSelectionParams(language_code='lt-LT', name=CONFIG['voice'])
                        audio_cfg = texttospeech.AudioConfig(audio_encoding=texttospeech.AudioEncoding.MP3, speaking_rate=CONFIG['rate_normal'])
                        
                        resp = client.synthesize_speech(input=synthesis_input, voice=voice_params, audio_config=audio_cfg)
                        
                        target_file.parent.mkdir(parents=True, exist_ok=True)
                        with open(target_file, 'wb') as out:
                            out.write(resp.audio_content)
                        stats['generated'] += 1
                        time.sleep(CONFIG['request_delay'])
                    except Exception as e:
                        print(f"  FAILED takeaway: {e}")
                        stats['errors'] += 1

    print(f"\nDone. Gen: {stats['generated']}, Skip: {stats['skipped']}, Err: {stats['errors']}")

if __name__ == '__main__':
    main()
