# Execution Phases

> **AI CONTRACT**
> This is the master execution plan. Single source of truth for end-to-end delivery.
> Do not skip phases. Each phase gate must pass before starting the next.
> Locked decisions apply: Flutter, JSON packs + PAD, pre-generated TTS, offline-first, Supabase Auth optional, FCM later.

---

## Phase 0 — Repo Foundation

### Goal
Establish project structure, documentation, and bootable Flutter app.

### Deliverables
- [x] Documentation complete (AI_INDEX, DECISIONS, ARCHITECTURE, CONTENT_GUIDE, CONTENT_SCHEMA)
- [ ] Flutter project initialized with clean structure
- [ ] Folder structure: `/lib`, `/content`, `/tool`, `/assets`
- [ ] Basic app shell (MaterialApp with placeholder home screen)

### Acceptance Criteria
- App launches on Android emulator without errors
- No lint warnings or errors
- Folder conventions match TOOLING.md

### Verification Commands
```bash
flutter pub get
flutter analyze        # must pass with no errors
flutter run            # must launch app
flutter test           # must not fail (even if no tests yet)
```

### Exit Gate
Do not start Phase 0.5 until:
- `flutter run` boots successfully
- `flutter analyze` returns 0 issues

---

## Phase 0.5 — App Shell + Design System

### Goal
Establish navigation patterns and reusable UI components before building features.

### Deliverables
- [ ] Bottom navigation with 5 tabs: Path, Practice, Roles, Cards, Profile
- [ ] GoRouter or Navigator 2.0 routing scaffold
- [ ] Design tokens file (`lib/theme/tokens.dart`):
  - Spacing scale (4, 8, 12, 16, 24, 32)
  - Typography (headings, body, caption)
  - Border radius (sm, md, lg)
  - Color palette (primary, secondary, surface, error)
- [ ] Shared components (`lib/widgets/`):
  - PrimaryButton
  - AppCard
  - ProgressBar
  - AudioPlayButton (placeholder, no audio yet)
- [ ] Sample screens using components (placeholder content)

### Acceptance Criteria
- All 5 tabs navigate correctly
- Components use design tokens (no magic numbers)
- Dark mode toggle works (optional but recommended)
- Components documented with usage example

### Verification Commands
```bash
flutter run
# Manual: Tap each tab → Verify navigation → Check components render
flutter analyze
```

### Exit Gate
Do not start Phase 1 until:
- Navigation is stable and implemented
- Component library used in all sample screens
- No hardcoded colors/spacing in widgets

---

## Phase 1 — Content Schema + Validator + Pack Structure

### Goal
Validate content packs before they enter the app. Prevent broken JSON from causing runtime errors.

### Deliverables
- [ ] `tool/validate_content.dart` implemented
- [ ] Pack folder structure finalized:
  ```
  content/
    a1/
      manifest.json
      unit_01/
        unit.json
        audio/
          a1_u01_hello_normal.ogg
  ```
- [ ] Sample unit: `content/a1/unit_01/unit.json` (Unit 01 only)
- [ ] VERSION.json updated

### Acceptance Criteria
- Validator checks: JSON syntax, schema compliance, phraseId refs, audioId refs
- Sample unit passes validation
- Invalid content produces clear error messages with file/line context

### Verification Commands
```bash
dart run tool/validate_content.dart
# Expected: "All content valid!" or list of specific errors
```

### Exit Gate
Do not start Phase 1.5 until:
- `dart run tool/validate_content.dart` passes on sample content
- Pack folder structure documented and followed
- At least Unit 01 with 2+ lessons exists

---

## Phase 1.5 — Audio Provider + Local Playback

### Goal
Establish audio playback abstraction before wiring full content. Prevents rework when PAD is integrated later.

### Deliverables
- [ ] AudioProvider service (`lib/services/audio_provider.dart`)
  - `play(audioId, {slow: false})`
  - `stop()`
  - `isPlaying` stream
- [ ] Path resolution: `audioId` → `content/a1/unit_XX/audio/{audioId}_normal.ogg`
- [ ] Play sample audio from expected pack path
- [ ] AudioPlayButton wired to AudioProvider

### Acceptance Criteria
- Audio plays from local file path
- Normal and slow variants supported (slow optional in MVP)
- Audio stops when new audio starts
- Works offline (no network calls)

### Verification Commands
```bash
flutter run
# Manual: Tap audio button → Verify audio plays → Tap again → Verify stops
```

### Exit Gate
Do not start Phase 2 until:
- Audio plays from pack-like file path
- AudioProvider abstraction allows future PAD swap
- Sample audio file included in repo

---

## Phase 2 — Vertical Slice: Lesson Engine

### Goal
Load content from JSON and render a playable lesson with all step types.

### Deliverables
- [ ] ContentLoader service (reads unit.json, returns typed models)
- [ ] LessonEngine (manages step progression, scoring, answers)
- [ ] UI for all step types:
  - teach_phrase, mcq, match, reorder, fill_blank, listening_choice, dialogue_choice, lesson_complete
- [ ] Audio playback integrated via AudioProvider
- [ ] Lesson complete screen with score

### Acceptance Criteria
- User can start a lesson, complete all steps, see score
- Wrong answers show feedback
- Audio plays for teach_phrase and listening_choice
- Works fully offline (no network calls)

### Verification Commands
```bash
flutter run
# Manual: Open app → Start lesson → Complete all steps → See completion screen
```

### Content Generation Gate
After Phase 2 works:
- Generate A1 Unit 01 and Unit 02 only
- Validate both units
- Run through app end-to-end
- Fix any issues before generating remaining units

### Exit Gate
Do not start Phase 3 until:
- One lesson is completable end-to-end
- All 8 step types render correctly
- Audio plays without errors
- Unit 01 and Unit 02 validated and playable

---

## Phase 3 — Path Map + Progression

### Goal
Display course structure and manage unlock logic.

### Deliverables
- [ ] Path map screen (units as nodes, lessons within)
- [ ] Lock/unlock state per unit
- [ ] Unit exam auto-generation from unit items
- [ ] Local progress store (SQLite or Hive)
- [ ] Progress persistence across app restarts

### Acceptance Criteria
- Locked units show lock icon
- Completing all lessons unlocks unit exam
- Passing exam (≥80%) unlocks next unit
- Progress survives app kill and relaunch

### Verification Commands
```bash
flutter run
# Manual: Complete lessons → Take exam → Verify next unit unlocks
# Kill app → Relaunch → Verify progress persisted
```

### Content Generation Gate
After Phase 3 exam generation works:
- Generate remaining A1 units (03-10 or as planned)
- Validate all units
- Smoke test exam generation for each

### Exit Gate
Do not start Phase 4 until:
- Path map shows correct lock states
- Exam gating works
- Progress persists offline
- All A1 units generated and validated

---

## Phase 4 — Flashcards (SRS)

### Goal
Spaced repetition review for learned items.

### Deliverables
- [ ] Flashcard UI (front/back, flip animation)
- [ ] SRS scheduler (intervals: 1d, 3d, 7d, 14d, 30d+)
- [ ] Due queue calculation
- [ ] Hard/Good/Easy buttons with interval updates
- [ ] "Weak areas" practice generator
- [ ] Review session complete screen

### Acceptance Criteria
- Cards due today appear in review queue
- Answering updates next review date
- Weak items (short intervals) prioritized
- SRS data persists locally

### Verification Commands
```bash
flutter run
# Manual: Learn items → Wait (or mock time) → Review due cards → Verify intervals update
```

### Exit Gate
Do not start Phase 5 until:
- SRS scheduling works correctly
- Review queue populates based on due dates
- Data persists across sessions

---

## Phase 5 — Auth + Sync (Optional Login)

### Goal
Allow users to sign in and sync progress across devices.

### Deliverables
- [ ] Supabase project setup (Auth + Postgres)
- [ ] Google OAuth integration
- [ ] Sync service (push local → remote, pull remote → local)
- [ ] Conflict resolution (local wins or timestamp-based)
- [ ] Sign-out clears synced flag (keeps local data)

### Acceptance Criteria
- User can sign in with Google
- Progress uploads to Supabase
- Second device (or fresh install) pulls progress after sign-in
- Offline changes sync when back online
- App works fully without signing in

### Verification Commands
```bash
flutter run
# Manual: Sign in → Complete lesson → Sign in on second device → Verify progress synced
```

### Exit Gate
Do not start Phase 6 until:
- Auth flow works end-to-end
- Sync works bidirectionally
- App remains fully functional offline

---

## Phase 6 — PAD Download + Storage UI

### Goal
Configure Play Asset Delivery for production content distribution.

### Deliverables
- [ ] PAD asset pack configuration in `android/`
- [ ] Install-time pack for A1 Unit 01-03
- [ ] On-demand packs for remaining units (if needed)
- [ ] Download progress UI
- [ ] Auto-download next unit on Wi-Fi
- [ ] Storage management screen (pack sizes, delete unused)

### Acceptance Criteria
- App installs with starter content
- Audio files play from PAD assets
- On-demand download works on Wi-Fi
- Storage UI shows accurate sizes
- Offline mode works after download

### Verification Commands
```bash
flutter build appbundle --release
# Upload to Play Console internal track
# Install on device → Verify content loads from PAD
# Disable network → Verify offline works
```

### Exit Gate
Do not start Phase 7 until:
- PAD packs bundle correctly in AAB
- Audio plays reliably from bundled assets
- Offline mode confirmed working
- Storage UI functional

---

## Phase 7 — Certificate PDF

### Goal
Generate completion certificate for A1 level.

### Deliverables
- [ ] PDF generation library integrated (pdf package)
- [ ] Certificate template (name, date, level, disclaimer)
- [ ] Trigger on A1 level completion
- [ ] Save to device / share intent

### Acceptance Criteria
- PDF generates locally (no backend call)
- User name appears on certificate
- Completion date is accurate
- Disclaimer states "not official CEFR certification"
- Share/save works

### Verification Commands
```bash
flutter run
# Manual: Complete A1 → Generate certificate → Share/save → Verify PDF content
```

### Exit Gate
Do not start Phase 8 until:
- Certificate generates without errors
- PDF is readable and complete

---

## Phase 8 — QA + Release

### Goal
Final quality pass and Play Store submission.

### Deliverables
- [ ] Smoke tests pass (see QA_CHECKLIST.md)
- [ ] Performance audit:
  - Startup <3s cold start
  - Scroll 60fps
  - Audio latency <100ms
- [ ] Accessibility basics (TalkBack, contrast, touch targets ≥48dp)
- [ ] Observability:
  - Crash reporting (Sentry or Crashlytics)
  - Local logging strategy (debug builds)
  - Error boundaries in UI
- [ ] Play Store assets:
  - App icon (512x512)
  - Feature graphic (1024x500)
  - Screenshots (phone + tablet)
  - Short/long descriptions
- [ ] Privacy policy URL
- [ ] Release AAB signed

### Acceptance Criteria
- No P0/P1 bugs
- App size <150MB
- Crash-free rate target: 99%+
- All QA_CHECKLIST items pass

### Verification Commands
```bash
flutter analyze
flutter test
flutter build appbundle --release
# Test on 3+ physical devices
# Run through QA_CHECKLIST.md manually
# Verify crash reporting receives test crash
```

### Exit Gate
Release when:
- All checklist items complete
- AAB uploaded to Play Console
- Internal testing approved
- Staged rollout (10% → 100%)

---

## Phase Summary

| Phase | Focus | Key Deliverable | Exit Gate |
|-------|-------|-----------------|-----------|
| 0 | Repo Foundation | Flutter app boots | `flutter run` works |
| 0.5 | App Shell | Navigation + components | Tabs stable, tokens used |
| 1 | Content Pipeline | Validator + pack structure | Validator passes |
| 1.5 | Audio Provider | Local audio playback | Audio plays from path |
| 2 | Vertical Slice | Playable lesson | All step types work |
| 3 | Progression | Path map + exams | Gating + persistence |
| 4 | SRS | Flashcard review | Scheduling works offline |
| 5 | Auth/Sync | Supabase integration | Bidirectional sync |
| 6 | PAD | Content delivery | AAB with PAD works |
| 7 | Certificate | PDF generation | PDF exports correctly |
| 8 | Release | Play Store | QA complete, AAB submitted |

---

## Content Generation Schedule

| When | Generate |
|------|----------|
| After Phase 1 | Unit 01 only (sample) |
| After Phase 2 | Unit 01 + Unit 02 (validate engine) |
| After Phase 3 | Remaining A1 units (03-10) |
| After Phase 6 | Audio files for all units |
