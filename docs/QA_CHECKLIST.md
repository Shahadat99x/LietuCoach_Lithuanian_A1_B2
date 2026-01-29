# QA Checklist

## Manual Smoke Tests

### Onboarding
- [ ] Fresh install shows onboarding flow
- [ ] Language selection works
- [ ] Skip login option available
- [ ] Login with Google OAuth works
- [ ] Progress from onboarding saves correctly

### Path Map
- [ ] Path map loads without errors
- [ ] Completed units show as complete
- [ ] Locked units show lock indicator
- [ ] Current unit is highlighted
- [ ] Tapping unit opens lesson list

### Lesson Flow
- [ ] Lesson starts with intro step
- [ ] Each step type renders correctly:
  - [ ] teach_phrase (audio plays)
  - [ ] mcq (options tappable)
  - [ ] match (pairs draggable)
  - [ ] reorder (words draggable)
  - [ ] fill_blank (keyboard input)
  - [ ] listening_choice (audio plays)
  - [ ] dialogue_choice (context displays)
- [ ] Progress bar updates per step
- [ ] Lesson complete screen shows summary

### Wrong Answer Handling
- [ ] Wrong answer shows feedback
- [ ] Correct answer revealed
- [ ] Item marked for review
- [ ] Can continue after wrong answer
- [ ] Wrong items appear in review queue

### Review / Mistakes
- [ ] Review section accessible from home
- [ ] Shows items due for review
- [ ] SRS scheduling works (items reappear)
- [ ] Completing review updates due dates

### Offline Mode
- [ ] App launches without internet
- [ ] Content loads from local assets
- [ ] Lessons playable offline
- [ ] Progress saves locally
- [ ] No error dialogs when offline

### Downloads (PAD)
- [ ] Content packs install with app
- [ ] No additional downloads needed for MVP
- [ ] Audio files play without delay

### Exam Gating
- [ ] Exam appears after completing unit lessons
- [ ] Cannot skip exam
- [ ] Passing unlocks next unit
- [ ] Failing shows retry option
- [ ] Score displayed accurately

### Certificate Export
- [ ] Certificate available after level completion
- [ ] PDF generates correctly
- [ ] User name appears on certificate
- [ ] Completion date accurate
- [ ] Share/save works

### Sign-in Sync
- [ ] Signing in triggers sync
- [ ] Local progress uploads
- [ ] Progress from another device downloads
- [ ] Conflict resolution works (local wins)
- [ ] Sign out clears synced state

## Release Checklist

### Pre-Release
- [ ] All smoke tests pass
- [ ] `flutter analyze` shows no errors
- [ ] `flutter test` all tests pass
- [ ] Content validation passes
- [ ] Version numbers updated (app + content)
- [ ] CHANGELOG updated

### Build
- [ ] AAB builds successfully
- [ ] APK builds for internal testing
- [ ] App size within limits (<150MB)
- [ ] PAD assets bundled correctly

### Play Console
- [ ] Upload AAB to internal track
- [ ] Test on physical devices (3+ models)
- [ ] Promote to closed testing
- [ ] Gather feedback, fix critical issues
- [ ] Promote to production

### Post-Release
- [ ] Monitor crash reports
- [ ] Check analytics for anomalies
- [ ] Respond to user feedback
- [ ] Tag release in git
