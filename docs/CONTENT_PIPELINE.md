# Content Creation Pipeline

This document outlines the standard workflow for adding new content units to LietuCoach.

## Directory Structure
Content lives in `content/` and is organized by level and unit:
```
content/
  a1/
    unit_01/
      unit.json
    unit_02/
      unit.json
    ...
```

## Workflow

### 1. Create Unit Skeleton
Create a new directory `content/a1/unit_XX/` (where XX is the next number).
Create `unit.json` inside it.

### 2. JSON Structure Rules
- **Unit ID**: `unit_XX`
- **Lesson ID**: `lesson_XX_topic_slug` (e.g., `lesson_01_countries`)
- **Phrase ID**: `word_in_snake_case` (e.g., `labas_rytas`)
- **Audio ID**: `a1_uXX_phrase_slug` (e.g., `a1_u03_labas_rytas`)
  - *Note*: `audioId` must be globally unique. Prefix with level and unit.

### 3. Authoring Checklist
- [ ] Define `items` dictionary first (vocabulary list).
- [ ] Construct `lessons` list using `teach_phrase` steps for all new items.
- [ ] Add practice steps (`mcq`, `match`, `reorder`, `listening_choice`) mixing old and new items.
- [ ] Ensure translations are simple and consistent (A1 level).

### 4. Validation
Run the validator script to check for schema errors, broken IDs, or missing audio refs.
```bash
dart run tool/validate_content.dart
```

### 5. Audio Generation
After validation passes, generate TTS audio for new phrases.
*Requires .secrets/openai_api_key.txt*
```bash
python tool/generate_tts_audio.py
```

### 6. Asset Sync
Copy generated audio and json to the application assets directory.
```pwsh
.\tool\sync_content_to_assets.ps1
.\tool\sync_audio_to_assets.ps1
```

## Common Issues
- **Duplicate IDs**: Ensure `phraseId` is unique within the unit.
- **Missing Audio**: If `audioId` is defined, the file must exist (handled by TTS tool).
- **Schema Mismatch**: Use `dart run tool/validate_content.dart` to debug.

## Step Types Guide
- **teach_phrase**: `{"type": "teach_phrase", "phraseId": "..."}`
- **mcq**: `{"type": "mcq", "prompt": "...", "options": [...], "correctIndex": N}`
- **match**: `{"type": "match", "pairs": [{"left": "...", "right": "..."}, ...]}`
- **reorder**: `{"type": "reorder", "words": [...], "correctOrder": [...]}`
