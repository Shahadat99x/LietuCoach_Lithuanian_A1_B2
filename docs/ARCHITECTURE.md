# Architecture

> **AI CONTRACT**
> This document describes the system architecture.
> Implementation must follow these boundaries.
> Changes require updating DECISIONS.md if they affect locked decisions.

## System Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         FLUTTER APP                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐       │
│  │  UI Screens  │───▶│ Lesson Engine│◀───│Content Loader│       │
│  │              │    │              │    │              │       │
│  │ - Path Map   │    │ - Step Logic │    │ - JSON Parse │       │
│  │ - Lesson     │    │ - Scoring    │    │ - Validation │       │
│  │ - Flashcard  │    │ - Progress   │    │              │       │
│  │ - Dialogue   │    │              │    └──────┬───────┘       │
│  │ - Exam       │    └──────────────┘           │               │
│  └──────────────┘                               │               │
│         │                                       │               │
│         ▼                                       ▼               │
│  ┌──────────────┐                      ┌──────────────┐         │
│  │Audio Provider│                      │Content Packs │         │
│  │              │                      │   (PAD)      │         │
│  │ - Play audio │                      │              │         │
│  │ - Normal/Slow│                      │ - units/*.json│        │
│  └──────────────┘                      │ - audio/*.mp3│         │
│                                        └──────────────┘         │
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐                           │
│  │Local Progress│◀──▶│ Sync Service │                           │
│  │    Store     │    │              │                           │
│  │              │    │ - Auth state │                           │
│  │ - SQLite/Hive│    │ - Push/Pull  │                           │
│  │ - SRS data   │    │ - Conflict   │                           │
│  └──────────────┘    └──────┬───────┘                           │
│                             │                                    │
└─────────────────────────────┼────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │    SUPABASE      │
                    │                  │
                    │ - Auth (OAuth)   │
                    │ - Postgres + RLS │
                    │ - Progress sync  │
                    │ - Cert metadata  │
                    └──────────────────┘
```

## Module Responsibilities

### Content Packs (PAD)
- JSON files defining units, lessons, items
- Audio files (MP3) for phrases
- Delivered via Play Asset Delivery at install time
- Versioned independently from app version

### Content Loader
- Parses JSON content packs
- Validates against schema
- Provides typed Dart objects to Lesson Engine
- Handles missing/corrupt content gracefully

### Lesson Engine
- Executes lesson steps in sequence
- Tracks user answers and scores
- Manages SRS scheduling for items
- Emits progress events

### UI Screens
- Path Map: visual course progression
- Lesson: step-by-step learning flow
- Flashcard: SRS review interface
- Dialogue: interactive conversation practice
- Exam: gated assessments

### Audio Provider
- Plays audio from local PAD assets
- Supports normal and slow playback variants
- Handles audio focus and interruptions

### Local Progress Store
- Persists all user progress locally
- Stores SRS intervals and due dates
- Works fully offline
- Source of truth until sync

### Sync Service
- Monitors auth state
- Pushes local changes to Supabase when online
- Pulls remote changes on app start/resume
- Handles merge conflicts (local wins by default)

## Offline-First Flow

```
1. User launches app
2. Content Loader reads from local PAD assets
3. Local Progress Store provides saved state
4. User completes lessons (progress saved locally)
5. If signed in + online:
   a. Sync Service pushes progress to Supabase
   b. Sync Service pulls any remote updates
6. If offline: app works normally, sync deferred
```

## Data Ownership

| Data Type | Owner | Storage |
|-----------|-------|---------|
| Content (lessons, phrases) | App bundle | PAD local assets |
| Audio files | App bundle | PAD local assets |
| User progress | User | Local first, synced to Supabase |
| SRS intervals | User | Local first, synced to Supabase |
| Certificates | User | Metadata in Supabase, PDF generated locally |
| Auth tokens | Supabase | Secure local storage |
