# LietuCoach

LietuCoach is an offline-first Lithuanian language learning app built with Flutter.  
It is designed for international students, immigrants, workers, travelers, and anyone starting Lithuanian from beginner levels.

## Key Highlights

- **Android-first Flutter app** with a scalable architecture
- **Offline-first learning** (content and progress available without internet)
- **Structured CEFR path** (A1-focused now, higher levels planned)
- **Lesson engine** with multiple exercise types
- **Audio-first practice** using pre-generated local TTS assets
- **Spaced repetition (SRS)** and review workflows
- **Optional cloud sync** and authentication via Supabase
- **Role-based practical packs** (e.g., traveler scenarios)

## Architecture at a Glance

- **Client**: Flutter (Dart)
- **Content delivery**: Versioned JSON packs bundled with app assets / PAD workflow
- **Audio**: Pre-generated OGG files (normal + optional slow variants)
- **Local storage**: Hive-based local progress and SRS persistence
- **Auth & sync**: Supabase Auth + Postgres (with local-first sync strategy)

For authoritative architecture decisions, see:
- [`docs/DECISIONS.md`](docs/DECISIONS.md)
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)

## Current Product Surface

Core app areas in the current codebase include:
- Onboarding
- Path (list + map views)
- Lessons and unit exams
- Practice hub and listening queue
- Cards (SRS review)
- Roles (thematic practical content)
- Profile, settings, sync, and account actions
- Certificate generation/export

## Repository Structure

```text
lib/        Flutter application code
content/    Versioned language content packs (JSON + audio references)
assets/     Bundled app assets for runtime
docs/       Project, architecture, content, QA, and release documentation
tool/       Validation, sync, and content/audio generation scripts
supabase/   Migrations and backend setup assets
test/       Automated tests
```

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK (via Flutter)
- Android SDK + Java 17+ (for Android builds)

### Install & Run

```bash
flutter pub get
flutter run
```

### Quality Checks

```bash
flutter analyze
flutter test
dart run tool/validate_content.dart
```

## Configuration

### Run fully offline (default)

```bash
flutter run
```

### Run with Supabase Auth/Sync

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

See [`docs/TOOLING.md`](docs/TOOLING.md) for Supabase and OAuth setup details.

## Content Workflow

1. Author or update unit content in `content/`
2. Validate content:
   ```bash
   dart run tool/validate_content.dart
   ```
3. Generate TTS audio (offline tooling):
   ```bash
   python tool/generate_tts_audio.py --unit unit_01 --slow
   ```
4. Sync content/audio into dev assets if needed:
   ```bash
   ./tool/sync_audio_to_assets.sh
   ```

Full guidance:
- [`docs/CONTENT_GUIDE.md`](docs/CONTENT_GUIDE.md)
- [`docs/CONTENT_PIPELINE.md`](docs/CONTENT_PIPELINE.md)
- [`docs/TOOLING.md`](docs/TOOLING.md)

## Build & Release

```bash
flutter build appbundle --release
```

Release process and versioning:
- [`docs/RELEASE.md`](docs/RELEASE.md)
- [`docs/QA_CHECKLIST.md`](docs/QA_CHECKLIST.md)
- [`docs/QA_RELEASE_CHECKLIST.md`](docs/QA_RELEASE_CHECKLIST.md)

## Documentation Index

Start with: [`docs/AI_INDEX.md`](docs/AI_INDEX.md)

Recommended order:
1. `docs/AI_INDEX.md`
2. `docs/DECISIONS.md`
3. `docs/PROJECT.md`
4. `docs/ARCHITECTURE.md`
5. `docs/CONTENT_GUIDE.md`
6. `docs/STATUS.md`
7. `docs/TOOLING.md`
8. `docs/RELEASE.md`
9. `docs/QA_CHECKLIST.md`

## Status

Active project with implemented core learning flows and ongoing polish/release work.  
See [`docs/STATUS.md`](docs/STATUS.md) and root [`STATUS.md`](STATUS.md) for latest updates.

## License

License not specified yet (`TODO`).
