#!/usr/bin/env python3
"""
LietuCoach TTS Audio Generator

Generates audio files for content packs using Google Cloud Text-to-Speech.

Usage:
    python tool/generate_tts_audio.py [options]

Options:
    --slow          Also generate slow variant (0.7x speed)
    --force         Regenerate even if file exists
    --unit UNIT_ID  Only process specific unit (e.g., unit_01)
    --dry-run       Show what would be generated without calling API

Environment:
    GOOGLE_APPLICATION_CREDENTIALS  Path to service account JSON
    GCLOUD_PROJECT_ID               Google Cloud project ID
    TTS_VOICE                       Voice name (default: lt-LT-Standard-A)
    TTS_SPEAKING_RATE_NORMAL        Normal speed (default: 1.0)
    TTS_SPEAKING_RATE_SLOW          Slow speed (default: 0.7)

Exit codes:
    0 = Success
    1 = Errors occurred
    2 = Configuration error
"""

import os
import sys
import json
import time
import argparse
from pathlib import Path

# Check for required environment variable before importing google libs
def check_credentials():
    creds = os.environ.get('GOOGLE_APPLICATION_CREDENTIALS')
    if not creds:
        print("ERROR: GOOGLE_APPLICATION_CREDENTIALS not set")
        print("Set it to the path of your service account JSON file")
        sys.exit(2)
    if not Path(creds).exists():
        print(f"ERROR: Credentials file not found: {creds}")
        sys.exit(2)
    return creds

# Configuration defaults
CONFIG = {
    'voice': os.environ.get('TTS_VOICE', 'lt-LT-Standard-A'),
    'rate_normal': float(os.environ.get('TTS_SPEAKING_RATE_NORMAL', '1.0')),
    'rate_slow': float(os.environ.get('TTS_SPEAKING_RATE_SLOW', '0.7')),
    'content_root': Path('content'),
    'request_delay': 0.5,  # seconds between API calls
}

# Counters
stats = {
    'generated': 0,
    'skipped': 0,
    'failed': 0,
}


def find_unit_dirs(content_root: Path, unit_filter: str = None):
    """Find all unit directories under content/a1/"""
    a1_dir = content_root / 'a1'
    if not a1_dir.exists():
        print(f"ERROR: A1 content directory not found: {a1_dir}")
        return []
    
    units = []
    for item in sorted(a1_dir.iterdir()):
        if item.is_dir() and item.name.startswith('unit_'):
            if unit_filter and item.name != unit_filter:
                continue
            unit_json = item / 'unit.json'
            if unit_json.exists():
                units.append(item)
            else:
                print(f"WARNING: {item.name} missing unit.json")
    
    return units


def load_unit_items(unit_dir: Path) -> dict:
    """Load items from unit.json"""
    unit_json = unit_dir / 'unit.json'
    with open(unit_json, 'r', encoding='utf-8') as f:
        data = json.load(f)
    return data.get('items', {})


def generate_audio_file(text: str, output_path: Path, speaking_rate: float, 
                        dry_run: bool, client=None):
    """Generate a single audio file using Google Cloud TTS"""
    if dry_run:
        print(f"  [DRY-RUN] Would generate: {output_path.name}")
        return True
    
    try:
        from google.cloud import texttospeech
        
        synthesis_input = texttospeech.SynthesisInput(text=text)
        
        voice = texttospeech.VoiceSelectionParams(
            language_code='lt-LT',
            name=CONFIG['voice'],
        )
        
        audio_config = texttospeech.AudioConfig(
            audio_encoding=texttospeech.AudioEncoding.OGG_OPUS,
            speaking_rate=speaking_rate,
        )
        
        response = client.synthesize_speech(
            input=synthesis_input,
            voice=voice,
            audio_config=audio_config,
        )
        
        # Ensure parent directory exists
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(output_path, 'wb') as f:
            f.write(response.audio_content)
        
        print(f"  ✓ Generated: {output_path.name}")
        return True
        
    except Exception as e:
        print(f"  ✗ Failed: {output_path.name} - {e}")
        return False


def process_unit(unit_dir: Path, generate_slow: bool, force: bool, 
                 dry_run: bool, client=None):
    """Process all items in a unit"""
    unit_id = unit_dir.name
    print(f"\nProcessing: {unit_id}")
    
    items = load_unit_items(unit_dir)
    if not items:
        print(f"  No items found in {unit_id}")
        return
    
    audio_dir = unit_dir / 'audio'
    
    for phrase_id, item in items.items():
        lt_text = item.get('lt', '')
        audio_id = item.get('audioId', '')
        
        if not lt_text or not audio_id:
            print(f"  ⚠ Skipping {phrase_id}: missing lt or audioId")
            continue
        
        # Generate normal variant
        normal_path = audio_dir / f"{audio_id}_normal.ogg"
        if normal_path.exists() and not force:
            print(f"  → Skipping (exists): {normal_path.name}")
            stats['skipped'] += 1
        else:
            success = generate_audio_file(
                lt_text, normal_path, CONFIG['rate_normal'], 
                dry_run, client
            )
            if success:
                stats['generated'] += 1
            else:
                stats['failed'] += 1
            
            if not dry_run:
                time.sleep(CONFIG['request_delay'])
        
        # Generate slow variant if requested
        if generate_slow:
            slow_path = audio_dir / f"{audio_id}_slow.ogg"
            if slow_path.exists() and not force:
                print(f"  → Skipping (exists): {slow_path.name}")
                stats['skipped'] += 1
            else:
                success = generate_audio_file(
                    lt_text, slow_path, CONFIG['rate_slow'],
                    dry_run, client
                )
                if success:
                    stats['generated'] += 1
                else:
                    stats['failed'] += 1
                
                if not dry_run:
                    time.sleep(CONFIG['request_delay'])


def main():
    parser = argparse.ArgumentParser(
        description='Generate TTS audio for LietuCoach content packs'
    )
    parser.add_argument('--slow', action='store_true',
                        help='Also generate slow variant (0.7x speed)')
    parser.add_argument('--force', action='store_true',
                        help='Regenerate even if file exists')
    parser.add_argument('--unit', type=str,
                        help='Only process specific unit (e.g., unit_01)')
    parser.add_argument('--dry-run', action='store_true',
                        help='Show what would be generated without calling API')
    
    args = parser.parse_args()
    
    print("╔════════════════════════════════════════════╗")
    print("║     LietuCoach TTS Audio Generator         ║")
    print("╚════════════════════════════════════════════╝")
    print()
    
    # Check credentials unless dry run
    client = None
    if not args.dry_run:
        check_credentials()
        try:
            from google.cloud import texttospeech
            client = texttospeech.TextToSpeechClient()
            print(f"✓ Connected to Google Cloud TTS")
            print(f"  Voice: {CONFIG['voice']}")
            print(f"  Normal rate: {CONFIG['rate_normal']}")
            if args.slow:
                print(f"  Slow rate: {CONFIG['rate_slow']}")
        except ImportError:
            print("ERROR: google-cloud-texttospeech not installed")
            print("Run: pip install google-cloud-texttospeech")
            sys.exit(2)
        except Exception as e:
            print(f"ERROR: Failed to initialize TTS client: {e}")
            sys.exit(2)
    else:
        print("🔍 DRY RUN MODE - no API calls will be made")
    
    # Find units
    units = find_unit_dirs(CONFIG['content_root'], args.unit)
    if not units:
        print("No units found to process")
        sys.exit(0)
    
    print(f"\nFound {len(units)} unit(s) to process")
    
    # Process each unit
    for unit_dir in units:
        process_unit(
            unit_dir,
            generate_slow=args.slow,
            force=args.force,
            dry_run=args.dry_run,
            client=client,
        )
    
    # Summary
    print("\n────────────────────────────────────────────")
    print("Summary:")
    print(f"  Generated: {stats['generated']}")
    print(f"  Skipped:   {stats['skipped']}")
    print(f"  Failed:    {stats['failed']}")
    print("────────────────────────────────────────────")
    
    if stats['failed'] > 0:
        print("\n❌ Completed with errors")
        sys.exit(1)
    else:
        print("\n✅ Audio generation complete!")
        sys.exit(0)


if __name__ == '__main__':
    main()
