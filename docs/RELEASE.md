# Release Guide

## Build Android AAB

### Prerequisites
- Flutter SDK installed
- Android SDK with build-tools
- Java 17+
- Signing key configured in `android/key.properties`

### Build Command
```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### Build APK (for testing)
```bash
flutter build apk --release
```

## Versioning

### App Version
Located in `pubspec.yaml`:
```yaml
version: 1.0.0+1
#        ^^^^^  ^
#        |      build number (versionCode)
#        semantic version (versionName)
```

- Increment build number for every release
- Follow semver for version name

### Content Version
Located in `content/VERSION.json`:
```json
{
  "a1": 1,
  "a2": 0,
  "schema": "0.1.0"
}
```

- `a1`: Content version for A1 level (increment when content changes)
- `a2`: Content version for A2 level
- `schema`: Content schema version

### Version Alignment
- Content updates require new app release (PAD bundles with AAB)
- App version and content version track independently
- Schema version must match what app code expects

## Play Asset Delivery (PAD)

### Strategy: Install-Time Delivery
All content packs delivered at install time (not on-demand).

Rationale:
- Simpler implementation
- Guaranteed offline availability
- No download prompts for users

### Asset Pack Structure
```
android/
  app/
    src/
      main/
        assets/
          content/       <- Lesson JSON files
          audio/         <- Audio MP3 files
```

### Future: On-Demand Packs
For very large content (A2, B1, B2), consider:
- Splitting by level into separate asset packs
- Using on-demand delivery for higher levels
- Showing download UI before first use

## Play Console Steps

### Internal Testing
1. Build release AAB
2. Go to Play Console > Internal testing
3. Upload AAB
4. Add test accounts
5. Publish to internal track

### Closed Testing
1. After internal validation
2. Create closed testing track
3. Upload same or updated AAB
4. Invite beta testers (up to 100)
5. Collect feedback

### Production Release
1. After closed testing approval
2. Review all metadata (description, screenshots)
3. Ensure content rating questionnaire complete
4. Set rollout percentage (start with 10-20%)
5. Monitor for 48 hours
6. Increase rollout to 100%

## Secrets Management
- Do NOT commit signing keys to repo
- Use environment variables or local `key.properties`
- Play Console API keys stored securely (not in repo)

## Hotfix Process
1. Create hotfix branch from release tag
2. Apply minimal fix
3. Increment build number only
4. Build and test
5. Expedited review if critical
