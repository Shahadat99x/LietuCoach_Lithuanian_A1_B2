# Architectural Decisions

> **AI CONTRACT**
> These decisions are LOCKED. Do not modify without explicit user approval.
> All other docs defer to this file in case of conflict.
> When adding new decisions, assign the next number and include rationale.

## Locked Decisions

### D1: Mobile Framework - Flutter (Dart)
- **Rationale**: Single codebase for Android/iOS, strong offline support, hot reload
- **Implication**: All mobile code in Dart; no native modules unless necessary

### D2: Content Delivery - JSON Packs via Play Asset Delivery (PAD)
- **Rationale**: Large content + audio bundles; PAD allows efficient install-time delivery
- **Implication**: Content updates require new Play Store release (new AAB)
- **Implication**: Content is NOT served from Supabase in MVP
- **Implication**: Remote content updates (e.g., R2 download) are post-MVP

### D3: Audio - Pre-generated TTS Files
- **Rationale**: Consistent quality, offline playback, no per-user TTS costs
- **Implication**: Audio files bundled with content packs
- **Implication**: Each phrase has normal and slow audio variants

### D4: Progress Storage - Offline-first Local Store
- **Rationale**: App must work fully offline; sync is optional enhancement
- **Implication**: SQLite or Hive for local storage
- **Implication**: Sync only when user signs in and is online

### D5: Authentication - Supabase Auth
- **Rationale**: Simple OAuth integration, no vendor lock-in, generous free tier
- **Implication**: Google OAuth as primary method
- **Implication**: Optional email/password for users without Google

### D6: Backend Database - Supabase Postgres with RLS
- **Rationale**: Stores user progress, SRS data, certificate metadata
- **Implication**: Row-level security for multi-tenant data isolation
- **Implication**: Content is NOT in Supabase (see D2)

### D7: Push Notifications - Firebase Cloud Messaging (FCM)
- **Rationale**: Standard Android push; no Firebase Auth/Firestore needed
- **Implication**: FCM only for notifications; no other Firebase services
- **Implication**: Deferred to post-MVP
- **Implication**: Do not add Firebase Auth or Firestore

### D8: Content Not Hardcoded
- **Rationale**: Separates content authoring from app development
- **Implication**: All lessons, phrases, audio refs in JSON files
- **Implication**: Dart code is content-agnostic

### D9: Content Validation Required
- **Rationale**: Prevent broken/invalid packs and reduce AI hallucinations
- **Implication**: CI and local workflow must run schema + semantic validation for JSON packs before merge/release

## Decision Log Format
When adding decisions:
```
### D<N>: <Title>
- **Rationale**: Why this choice
- **Implication**: What this means for implementation
```
