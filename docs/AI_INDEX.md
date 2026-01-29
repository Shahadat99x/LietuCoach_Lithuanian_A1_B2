# AI INDEX - LietuCoach

> **AI CONTRACT**
> This is the entry point for all AI agents working on this codebase.
> If conflicts arise between documents, DECISIONS.md wins.
> Do not change locked decisions without updating DECISIONS.md first.
> **Source of truth priority**: DECISIONS.md > ARCHITECTURE.md > CONTENT_GUIDE.md > STATUS.md > TOOLING.md > RELEASE.md > QA_CHECKLIST.md

## Reading Order
1. [AI_INDEX.md](AI_INDEX.md) (this file)
2. [DECISIONS.md](DECISIONS.md) - locked architectural decisions
3. [PROJECT.md](PROJECT.md) - vision and goals
4. [ARCHITECTURE.md](ARCHITECTURE.md) - system design
5. [CONTENT_GUIDE.md](CONTENT_GUIDE.md) - content authoring rules
6. [STATUS.md](STATUS.md) - current progress
7. [TOOLING.md](TOOLING.md) - development workflows
8. [RELEASE.md](RELEASE.md) - build and deploy
9. [QA_CHECKLIST.md](QA_CHECKLIST.md) - testing

## Repo Map
- `/lib/` - Flutter app code (Dart)
- `/assets/` - Small bundled assets (icons, fonts)
- `/content/` - JSON content packs + audio files (bundled via PAD)
- `/docs/` - Documentation
- `/tool/` - Build and validation scripts

## Project Snapshot
- **App**: Flutter (Dart), Android-first
- **Content Model**: Offline-first; versioned JSON packs bundled via Play Asset Delivery
- **Audio**: Pre-generated TTS files (normal + slow variants), bundled with content
- **Auth**: Supabase Auth (Google OAuth + optional email)
- **Progress Sync**: Local-first storage; optional cloud sync via Supabase Postgres
- **Push**: Firebase Cloud Messaging (FCM) - future

## Do Not Change (Locked Decisions)
See [DECISIONS.md](DECISIONS.md) for full list. Summary:
- Mobile framework: Flutter
- Content delivery: JSON packs + PAD (not Supabase-served)
- Auth provider: Supabase Auth only
- Audio: Pre-generated TTS files, no on-device TTS
- Offline-first: Local progress store with optional sync

## Do Not Introduce
- Firebase Auth
- Firestore
- Serving lesson content from Supabase in MVP
- On-demand per-user TTS generation

## Current Focus
1. Finalize content schema root + align CONTENT_GUIDE.md and schema
2. Implement tool/validate_content.dart (schema + semantic checks)
3. Implement content loader + first vertical slice (Unit -> Lesson -> Steps -> Completion)

## Commands
```bash
# Run app
flutter run

# Lint and analyze
flutter analyze

# Run tests
flutter test

# Validate content (TODO: implement)
dart run tool/validate_content.dart

# Build release AAB
flutter build appbundle --release
```

## Handoff Packet
Copy this into a new chat to preserve context:

```
PROJECT: LietuCoach - Lithuanian language learning app (Android, Flutter)
ENTRY POINT: docs/AI_INDEX.md
LOCKED DECISIONS: docs/DECISIONS.md
CURRENT STATUS: docs/STATUS.md
CONTENT RULES: docs/CONTENT_GUIDE.md
CONTENT SCHEMA: docs/CONTENT_SCHEMA.json

Stack: Flutter + JSON packs (PAD) + Supabase Auth + local-first progress
Current phase: Implementing content schema + validator + first screens
```
