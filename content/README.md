# Content Packs

This folder contains versioned JSON content packs and audio files for LietuCoach.

## Structure

```
content/
├── VERSION.json              # Content version manifest
└── a1/                       # A1 level content
    └── unit_01/              # Unit folder
        ├── unit.json         # Unit data (lessons, items)
        └── audio/            # Audio files for this unit
            ├── {audioId}_normal.ogg   # Normal speed (required)
            └── {audioId}_slow.ogg     # Slow speed (optional)
```

## VERSION.json

Contains the content manifest:
```json
{
  "contentVersion": "0.1.0",
  "schemaVersion": "v0.1.0",
  "levels": ["a1"],
  "lastUpdated": "2026-01-27"
}
```

- `contentVersion`: Semantic version of content
- `schemaVersion`: Must match `docs/CONTENT_SCHEMA.json` version
- `levels`: Available CEFR levels
- `lastUpdated`: Last modification date

## Unit JSON Structure

Each `unit.json` contains:
- `id`: Unit identifier (pattern: `unit_NN`)
- `title`: English title
- `titleLt`: Lithuanian title (optional)
- `lessons`: Array of lesson objects
- `items`: Dictionary of vocabulary items

See `docs/CONTENT_GUIDE.md` for authoring rules.
See `docs/CONTENT_SCHEMA.json` for validation schema.

## Audio File Rules

### Naming Convention
```
{audioId}_normal.ogg   # Required
{audioId}_slow.ogg     # Optional
```

### Example
For item with `audioId: "a1_u01_labas"`:
```
content/a1/unit_01/audio/a1_u01_labas_normal.ogg
content/a1/unit_01/audio/a1_u01_labas_slow.ogg  (optional)
```

### Format Requirements
- Format: OGG Vorbis
- Quality: q5 (~128kbps)
- Sample rate: 44.1kHz
- Normalization: -16 LUFS

## Validation

Run the content validator:
```bash
dart run tool/validate_content.dart
```

Options:
- `--skip-audio-check`: Skip audio file existence validation
- `--verbose`: Show detailed validation info

## Adding New Content

### Add a New Unit

1. Create folder: `content/a1/unit_NN/`
2. Create `unit.json` following schema
3. Add audio files to `audio/` subfolder
4. Run validator to check

### Add a New Lesson

1. Add lesson object to `unit.json` lessons array
2. Add new items to `items` dictionary
3. Create audio files for new items
4. Run validator to check

## Constraints (A1 Level)

Per lesson:
- 3-6 new vocabulary items
- 6-10 core steps (excludes `lesson_complete`)
- Duration target: 3-5 minutes
