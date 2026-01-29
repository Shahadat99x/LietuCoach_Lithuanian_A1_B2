#!/bin/bash
# LietuCoach check script
# Runs flutter analyze + flutter test + content validation + optional TTS generation
#
# Options:
#   --with-tts  Run TTS generation if credentials are set

set -e

WITH_TTS=false
for arg in "$@"; do
    if [ "$arg" = "--with-tts" ]; then
        WITH_TTS=true
    fi
done

echo "╔════════════════════════════════════════════╗"
echo "║           LietuCoach Check                 ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Optional: TTS generation
if [ "$WITH_TTS" = true ] || [ -n "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
    if [ -n "$GOOGLE_APPLICATION_CREDENTIALS" ] && [ -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
        echo "Running TTS audio generation..."
        python tool/generate_tts_audio.py --unit unit_01
        echo ""
        
        echo "Syncing audio to assets..."
        ./tool/sync_audio_to_assets.sh
        echo ""
    else
        echo "Skipping TTS generation (GOOGLE_APPLICATION_CREDENTIALS not set)"
        echo ""
    fi
fi

echo "Running flutter analyze..."
flutter analyze
echo ""

echo "Running flutter test..."
flutter test
echo ""

echo "Running content validator..."
dart run tool/validate_content.dart
echo ""

echo "╔════════════════════════════════════════════╗"
echo "║           All checks passed!               ║"
echo "╚════════════════════════════════════════════╝"
