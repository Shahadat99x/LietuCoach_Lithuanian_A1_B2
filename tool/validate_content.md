# Content Validation Tool

## Purpose
Validate content JSON files against the schema and check internal references.

## Status: TODO (placeholder)

## Planned Implementation

```dart
// tool/validate_content.dart
// TODO: Implement

import 'dart:io';
import 'dart:convert';

void main(List<String> args) async {
  print('LietuCoach Content Validator');
  print('============================');
  
  // TODO: Load schema from docs/CONTENT_SCHEMA.json
  // TODO: Validate content/VERSION.json
  // TODO: For each level in manifest:
  //       - Validate manifest.json
  //       - Validate each unit JSON
  //       - Check phraseId references exist in items
  //       - Check audioId references have files
  // TODO: Report errors with file/line context
  // TODO: Exit with non-zero code if errors found
  
  print('Validation not yet implemented.');
  exit(1);
}
```

## Validation Checks

### Schema Validation
- [ ] VERSION.json matches versionManifest schema
- [ ] manifest.json matches levelManifest schema
- [ ] unit*.json matches unit schema
- [ ] All step objects match their type-specific schema

### Reference Validation
- [ ] All `phraseId` in steps exist in unit's `items` dictionary
- [ ] All `audioId` in items have corresponding audio files
- [ ] No duplicate IDs within a unit
- [ ] Lesson IDs unique within unit
- [ ] Unit IDs unique within level

### Content Quality Checks
- [ ] Lessons have 6-10 steps
- [ ] Units have 3-6 new items per lesson
- [ ] `correctIndex` within bounds of `options` array

## Usage (Future)

```bash
# Validate all content
dart run tool/validate_content.dart

# Validate specific level
dart run tool/validate_content.dart --level a1

# Validate with verbose output
dart run tool/validate_content.dart --verbose
```

## Dependencies (Future)
- `json_schema` package for JSON Schema validation
- Built-in `dart:io` for file operations

## Next Steps
1. Set up Dart project structure
2. Implement schema loading and validation
3. Implement reference checking
4. Add to CI/CD pipeline
