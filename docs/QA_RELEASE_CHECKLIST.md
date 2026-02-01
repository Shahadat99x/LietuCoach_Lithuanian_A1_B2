# QA Release Checklist
Version: 1.0.0 (Phase 7 Candidate)

## A) Core Navigation
- [ ] **Bottom Nav**: Switching tabs preserves state (e.g. scroll position in Path).
- [ ] **Back Stack**: Back button works correctly in deeply nested screens (e.g. Lesson -> Path).
- [ ] **Tab Reselection**: Tapping current tab scrolls to top (optional polish).

## B) Path Tab
### Classic List
- [ ] Scroll performance is 60fps.
- [ ] Locked units show "Locked" state clearly.
- [ ] Tapping "Continue" opens the correct next lesson.
### Map View
- [ ] Scroll performance is smooth (RepaintBoundary working).
- [ ] Nodes align correctly with connectors.
- [ ] Tapping Locked Node shows Bottom Sheet (with 24px radius).
- [ ] Pulse animation works on current node.

## C) Lessons & Exam
- [ ] **Audio**: Plays correctly. If missing, no crash.
- [ ] **Progress**: Progress bar updates smoothly.
- [ ] **Result Sheet**: Animates in from bottom. "Continue" button works.
- [ ] **Exit**: "X" button prompts confirmation or exits cleanly.
- [ ] **Completion**: Finishing lesson updates Path progress immediately.

## D) Practice Tab (Daily Hub)
- [ ] **Hero Card**: "Start Session" button works.
- [ ] **Grid**: Tapping modes provides scale feedback (ScaleButton).
- [ ] **Empty State**: If no plan, shows premium empty state or CTA.
- [ ] **Listening Mode**: Launches correctly.

## E) Cards Tab (SRS)
- [ ] **Empty State**: "Start Your Collection" shown for new users.
- [ ] **Caught Up**: "All Caught Up" shown if no reviews.
- [ ] **Review**: Session starts, cards flip, ease buttons work.
- [ ] **Stats**: "Due Today" and "Total" numbers are accurate.

## F) Roles Tab
- [ ] **Unlock Sheet**: Tapping locked role shows bottom sheet (consistent style).
- [ ] **Available Role**: Tapping opens role detail (or placeholder).
- [ ] **Scale Feedback**: Cards scale on press.

## G) Profile & Settings
- [ ] **Auth**: Sign-In with Google works (simulated/real).
- [ ] **Sync**: "Sync Now" button works. Shows "Offline" if no network.
- [ ] **Settings**: Dark Mode toggle works (if implemented).

## H) Offline Resilience
- [ ] **Launch**: App opens without internet.
- [ ] **Path**: Content loads from local DB.
- [ ] **Images/Audio**: Fallbacks displayed if assets missing.
- [ ] **Sync**: Fails gracefully with "Offline" message.
