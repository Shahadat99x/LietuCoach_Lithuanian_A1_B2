# Tooling Guide

## Content Pack Structure

```
content/
├── VERSION.json              # Content version manifest
└── a1/                       # A1 level content
    └── unit_01/              # Unit folder
        ├── unit.json         # Unit data (lessons, items)
        └── audio/            # Audio files for this unit
            ├── {audioId}_normal.ogg   # Required
            └── {audioId}_slow.ogg     # Optional
```

## Google Cloud TTS Audio Generation

Audio files are generated offline using Google Cloud Text-to-Speech. Credentials never go into the Flutter app.

### Prerequisites
1. Google Cloud project with Text-to-Speech API enabled
2. Service account with TTS permissions
3. Python 3.8+ with `google-cloud-texttospeech` installed

### Setup
```bash
# Install Python dependency
pip install google-cloud-texttospeech

# Copy and edit environment config
cp tool/.env.example tool/.env
# Edit tool/.env with your credentials path
```

### Environment Variables
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"
export TTS_VOICE="lt-LT-Standard-A"  # Lithuanian voice
```

### Running TTS Generation
```bash
# Generate normal variant for unit_01
python tool/generate_tts_audio.py --unit unit_01

# Generate normal + slow variants
python tool/generate_tts_audio.py --unit unit_01 --slow

# Force regenerate all
python tool/generate_tts_audio.py --force

# Dry run (no API calls)
python tool/generate_tts_audio.py --dry-run
```

### Why Secrets Stay Out of Flutter
- TTS runs **offline** during content authoring
- Service account JSON is **never committed** (in .gitignore)
- Audio files are pre-generated and bundled with content packs
- Flutter app only plays local files, never calls TTS API

## Dev-Only Audio Mirroring

During development, audio must be copied from `content/` to `assets/` for Flutter playback.

### Sync Scripts
```powershell
# PowerShell (Windows)
.\tool\sync_audio_to_assets.ps1

# Bash (Unix)
./tool/sync_audio_to_assets.sh
```

### Path Resolution
```
audioId: "a1_u01_labas" + variant: "normal"
-> assets/audio/a1/unit_01/a1_u01_labas_normal.ogg
```

### Slow Variant Fallback
If slow variant doesn't exist, the app falls back to normal automatically.

> **Note**: In Phase 6+, Play Asset Delivery (PAD) will replace this mechanism.

## Content Validation

### Validation Tool
Location: `tool/validate_content.dart`

### Running Validation
```bash
dart run tool/validate_content.dart

# Options:
#   --skip-audio-check   Skip audio file existence check
#   --verbose            Show detailed validation info
```

### What It Validates
1. **VERSION.json** - Schema version matches expected
2. **Unit discovery** - Finds `unit_*/unit.json` in `content/a1/`
3. **Structure checks**:
   - Required fields present (id, title, lessons, items)
   - ID patterns valid (unit_XX, lesson_XX_topic)
4. **Semantic rules**:
   - All `phraseId` in teach_phrase steps exist in `items`
   - `correctIndex < options.length` for mcq/listening_choice/dialogue_choice
   - `correctOrder` length matches `words` length, indices valid and unique
   - 3-6 new items per lesson (via teach_phrase steps)
   - 6-10 core steps per lesson (excludes lesson_complete)
5. **Audio files** - `{audioId}_normal.ogg` exists for each item

### Example Output
```
╔════════════════════════════════════════════╗
║     LietuCoach Content Validator           ║
╚════════════════════════════════════════════╝

  ✅ VERSION.json valid (schema v0.1.0)

Validating: unit_01
  ✅ unit_01 validated successfully

────────────────────────────────────────────
Summary:
  Units validated:  1
  Lessons checked:  2
  Errors:           0
  Warnings:         0
────────────────────────────────────────────

✅ All content valid!
```

## Audio File Organization

### Directory Structure
```
content/a1/{unit_id}/audio/{audioId}_{variant}.ogg
```

### Naming Convention
- `audioId`: Globally unique, e.g., `a1_u01_hello`
- `variant`: `normal` (required) or `slow` (optional)

### Format Requirements
- Format: OGG Vorbis
- Quality: q5 (~128kbps)
- Sample rate: 44.1kHz
- Normalization: -16 LUFS

## Adding New Content

### Add a New Unit

1. Create folder: `content/a1/unit_NN/`
2. Create `unit.json` following schema:
   ```json
   {
     "id": "unit_NN",
     "title": "Unit Title",
     "lessons": [...],
     "items": {...}
   }
   ```
3. Create audio files in `audio/` subfolder
4. Run validation: `dart run tool/validate_content.dart`

### Add a New Lesson

1. Add lesson object to `lessons` array in `unit.json`
2. Add new items to `items` dictionary
3. Create audio files for new items
4. Run validation to verify

### Lesson Constraints (A1)
- 3-6 new vocabulary items (via teach_phrase)
- 6-10 core steps (excludes lesson_complete)
- Duration target: 3-5 minutes

## Development Workflow

### Check Scripts

PowerShell (Windows):
```powershell
.\tool\check.ps1
```

Bash (Unix):
```bash
./tool/check.sh
```

Both scripts run:
1. `flutter analyze`
2. `flutter test`
3. `dart run tool/validate_content.dart`

### Full Workflow
```
1. Edit content JSON files
2. Run: dart run tool/validate_content.dart
3. Fix any validation errors
4. Run: flutter run (test in emulator)
5. Verify lesson flow works
6. Run: ./tool/check.ps1 (full check)
7. Commit changes
```

## Step Types Reference

| Type | Required Fields |
|------|-----------------|
| teach_phrase | phraseId, showTranslation |
| mcq | prompt, options, correctIndex |
| match | pairs |
| reorder | words, correctOrder |
| fill_blank | sentence, blank, answer |
| listening_choice | audioId, options, correctIndex |
| dialogue_choice | context, options, correctIndex |
| lesson_complete | (optional: itemsLearned, xpEarned) |

See `docs/CONTENT_GUIDE.md` for full authoring rules.
See `docs/CONTENT_SCHEMA.json` for JSON schema.

## Supabase Configuration (Phase 5)

### Running with Supabase Auth
The app uses Supabase for authentication and cloud sync. Credentials are passed via `--dart-define`:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### VS Code launch.json Example
```json
{
  "configurations": [
    {
      "name": "LietuCoach (Supabase)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "toolArgs": [
        "--dart-define=SUPABASE_URL=https://xxx.supabase.co",
        "--dart-define=SUPABASE_ANON_KEY=eyJ..."
      ]
    }
  ]
}
```

### Running Without Supabase
The app works fully offline without Supabase. Simply run:
```bash
flutter run
```
Auth and sync features will be disabled but lessons, SRS, and progress work normally.

### Database Setup
Apply migrations in Supabase SQL Editor:
```sql
-- Copy contents of supabase/migrations/001_init.sql
```

### OAuth Setup (Google)
1. In Supabase Dashboard → Authentication → Providers → Google
2. Enable Google provider
3. Add OAuth credentials from Google Cloud Console
4. **Important**: In Supabase Dashboard → Authentication → URL Configuration:
   - Add `io.lietucoach.app://login-callback` to **Redirect URLs**
5. In Google Cloud Console, add authorized redirect URI:
   - `https://vdxmuhstoizfbsulhrml.supabase.co/auth/v1/callback`

### Deep Link Redirect URL
The app uses the following deep link for OAuth callback:
```
io.lietucoach.app://login-callback
```

This must be added to:
1. **Supabase** → Authentication → URL Configuration → Redirect URLs
2. **AndroidManifest.xml** (already configured)
3. **auth_service.dart** `redirectTo` parameter (already configured)

