#!/bin/bash
# Audio Sync Script
# Mirrors audio files from content/ to assets/ for Flutter dev playback
#
# Usage:
#   ./tool/sync_audio_to_assets.sh

set -e

echo "╔════════════════════════════════════════════╗"
echo "║     Audio Sync: content/ -> assets/        ║"
echo "╚════════════════════════════════════════════╝"
echo ""

CONTENT_ROOT="content"
ASSETS_ROOT="assets/audio"
COPIED=0
SKIPPED=0

# Find all unit audio directories
for UNIT_DIR in "$CONTENT_ROOT"/a1/unit_*/; do
    if [ ! -d "$UNIT_DIR" ]; then
        continue
    fi
    
    UNIT_ID=$(basename "$UNIT_DIR")
    SOURCE_DIR="$CONTENT_ROOT/a1/$UNIT_ID/audio"
    DEST_DIR="$ASSETS_ROOT/a1/$UNIT_ID"
    
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "  Skipping $UNIT_ID (no audio folder)"
        continue
    fi
    
    # Create destination directory
    mkdir -p "$DEST_DIR"
    
    # Copy audio files
    for FILE in "$SOURCE_DIR"/*.ogg; do
        if [ ! -f "$FILE" ]; then
            continue
        fi
        
        FILENAME=$(basename "$FILE")
        DEST_PATH="$DEST_DIR/$FILENAME"
        
        # Copy if newer or doesn't exist
        if [ ! -f "$DEST_PATH" ] || [ "$FILE" -nt "$DEST_PATH" ]; then
            cp "$FILE" "$DEST_PATH"
            echo "  ✓ Copied: $FILENAME"
            COPIED=$((COPIED + 1))
        else
            SKIPPED=$((SKIPPED + 1))
        fi
    done
done

echo ""
echo "────────────────────────────────────────────"
echo "Summary:"
echo "  Files copied:  $COPIED"
echo "  Files skipped: $SKIPPED (already up to date)"
echo "────────────────────────────────────────────"
echo ""
echo "✅ Audio sync complete!"
