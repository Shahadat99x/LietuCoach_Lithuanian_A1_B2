/// LietuCoach Content Validator
///
/// Validates content packs against schema and semantic rules.
///
/// Usage:
///   dart run tool/validate_content.dart [options]
///
/// Options:
///   --skip-audio-check   Skip audio file existence validation
///   --verbose            Show detailed validation info
///
/// Exit codes:
///   0 = All content valid
///   1 = Validation errors found
///   2 = System error (file not found, etc.)

import 'dart:convert';
import 'dart:io';

// Configuration
const String schemaVersion = 'v0.1.0';
const String contentRoot = 'content';
const String schemaPath = 'docs/CONTENT_SCHEMA.json';

// A1 constraints from CONTENT_GUIDE.md
const int minNewItemsPerLesson = 3;
const int maxNewItemsPerLesson = 6;
const int minCoreStepsPerLesson = 6;
const int maxCoreStepsPerLesson = 10;

// Validation counters
int unitsValidated = 0;
int lessonsChecked = 0;
int errorsFound = 0;
int warningsFound = 0;

// Options
bool skipAudioCheck = false;
bool verbose = false;

void main(List<String> args) {
  // Parse arguments
  skipAudioCheck = args.contains('--skip-audio-check');
  verbose = args.contains('--verbose');

  print('╔════════════════════════════════════════════╗');
  print('║     LietuCoach Content Validator           ║');
  print('╚════════════════════════════════════════════╝');
  print('');

  try {
    // 1. Validate VERSION.json
    if (!validateVersionJson()) {
      exit(2);
    }

    // 2. Discover and validate unit packs
    final unitDirs = discoverUnits();
    if (unitDirs.isEmpty) {
      logWarning('No unit packs found in $contentRoot/a1/');
    }

    for (final unitDir in unitDirs) {
      validateUnit(unitDir);
    }

    // 3. Summary
    print('');
    print('────────────────────────────────────────────');
    print('Summary:');
    print('  Units validated:  $unitsValidated');
    print('  Lessons checked:  $lessonsChecked');
    print('  Errors:           $errorsFound');
    print('  Warnings:         $warningsFound');
    print('────────────────────────────────────────────');

    if (errorsFound > 0) {
      print('');
      print('❌ Validation FAILED with $errorsFound error(s)');
      exit(1);
    } else {
      print('');
      print('✅ All content valid!');
      exit(0);
    }
  } catch (e, stack) {
    print('');
    logError('System error: $e');
    if (verbose) {
      print(stack);
    }
    exit(2);
  }
}

bool validateVersionJson() {
  final versionFile = File('$contentRoot/VERSION.json');
  if (!versionFile.existsSync()) {
    logError('VERSION.json not found at $contentRoot/VERSION.json');
    return false;
  }

  try {
    final content = versionFile.readAsStringSync();
    final version = jsonDecode(content) as Map<String, dynamic>;

    if (!version.containsKey('schemaVersion')) {
      logError('VERSION.json missing "schemaVersion" field');
      return false;
    }

    final fileSchemaVersion = version['schemaVersion'] as String;
    if (fileSchemaVersion != schemaVersion) {
      logError(
        'Schema version mismatch: VERSION.json has "$fileSchemaVersion", '
        'expected "$schemaVersion"',
      );
      return false;
    }

    logSuccess('VERSION.json valid (schema $schemaVersion)');
    return true;
  } catch (e) {
    logError('Failed to parse VERSION.json: $e');
    return false;
  }
}

List<Directory> discoverUnits() {
  final a1Dir = Directory('$contentRoot/a1');
  if (!a1Dir.existsSync()) {
    logWarning('A1 content directory not found: $contentRoot/a1');
    return [];
  }

  final units = <Directory>[];
  for (final entity in a1Dir.listSync()) {
    if (entity is Directory) {
      final name = entity.path.split(Platform.pathSeparator).last;
      if (name.startsWith('unit_')) {
        final unitJson = File('${entity.path}/unit.json');
        if (unitJson.existsSync()) {
          units.add(entity);
        } else {
          logWarning('Unit directory missing unit.json: ${entity.path}');
        }
      }
    }
  }

  units.sort((a, b) => a.path.compareTo(b.path));
  if (verbose) {
    print('Found ${units.length} unit(s) to validate');
  }
  return units;
}

void validateUnit(Directory unitDir) {
  final unitName = unitDir.path.split(Platform.pathSeparator).last;
  final unitJsonPath = '${unitDir.path}/unit.json';
  print('');
  print('Validating: $unitName');

  try {
    final content = File(unitJsonPath).readAsStringSync();
    final unit = jsonDecode(content) as Map<String, dynamic>;

    // Basic structure checks
    if (!validateUnitStructure(unit, unitJsonPath)) {
      return;
    }

    final unitId = unit['id'] as String;
    final items = unit['items'] as Map<String, dynamic>;
    final lessons = unit['lessons'] as List<dynamic>;

    // Validate items
    validateItems(items, unitDir, unitId);

    // Validate each lesson
    for (final lesson in lessons) {
      validateLesson(lesson as Map<String, dynamic>, items, unitJsonPath);
    }

    unitsValidated++;
    logSuccess('$unitName validated successfully');
  } catch (e) {
    logError('Failed to parse $unitJsonPath: $e');
  }
}

bool validateUnitStructure(Map<String, dynamic> unit, String path) {
  bool valid = true;

  // Required fields
  final requiredFields = ['id', 'title', 'lessons', 'items'];
  for (final field in requiredFields) {
    if (!unit.containsKey(field)) {
      logError('$path: Missing required field "$field"');
      valid = false;
    }
  }

  if (!valid) return false;

  // ID pattern check
  final id = unit['id'] as String;
  if (!RegExp(r'^unit_[a-z0-9_]+$').hasMatch(id)) {
    logError('$path: Invalid unit id "$id" (expected pattern: unit_[a-z0-9_]+)');
    valid = false;
  }

  // Lessons is array
  if (unit['lessons'] is! List) {
    logError('$path: "lessons" must be an array');
    valid = false;
  }

  // Items is object
  if (unit['items'] is! Map) {
    logError('$path: "items" must be an object');
    valid = false;
  }

  return valid;
}

void validateItems(
  Map<String, dynamic> items,
  Directory unitDir,
  String unitId,
) {
  for (final entry in items.entries) {
    final phraseId = entry.key;
    final item = entry.value as Map<String, dynamic>;

    // Check phraseId pattern
    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(phraseId)) {
      logError('Item "$phraseId": Invalid phraseId pattern');
    }

    // Required item fields
    if (!item.containsKey('lt')) {
      logError('Item "$phraseId": Missing "lt" (Lithuanian text)');
    }
    if (!item.containsKey('en')) {
      logError('Item "$phraseId": Missing "en" (English translation)');
    }
    if (!item.containsKey('audioId')) {
      logError('Item "$phraseId": Missing "audioId"');
      continue;
    }

    // Audio existence check
    if (!skipAudioCheck) {
      final audioId = item['audioId'] as String;
      final audioPath = '${unitDir.path}/audio/${audioId}_normal.ogg';
      final audioFile = File(audioPath);
      if (!audioFile.existsSync()) {
        logError(
          'Item "$phraseId": Audio file not found: $audioPath',
        );
      }
    }
  }
}

void validateLesson(
  Map<String, dynamic> lesson,
  Map<String, dynamic> items,
  String unitPath,
) {
  lessonsChecked++;

  // Lesson ID check
  if (!lesson.containsKey('id')) {
    logError('$unitPath: Lesson missing "id"');
    return;
  }

  final lessonId = lesson['id'] as String;
  final lessonPrefix = '$unitPath -> $lessonId';

  // ID pattern
  if (!RegExp(r'^lesson_[a-z0-9_]+$').hasMatch(lessonId)) {
    logError('$lessonPrefix: Invalid lesson id pattern');
  }

  // Required fields
  if (!lesson.containsKey('title')) {
    logError('$lessonPrefix: Missing "title"');
  }
  if (!lesson.containsKey('steps')) {
    logError('$lessonPrefix: Missing "steps"');
    return;
  }

  final steps = lesson['steps'] as List<dynamic>;

  // Count core steps (exclude lesson_complete)
  final coreSteps =
      steps.where((s) => (s as Map)['type'] != 'lesson_complete').toList();

  if (coreSteps.length < minCoreStepsPerLesson) {
    logError(
      '$lessonPrefix: Too few core steps (${coreSteps.length}, '
      'minimum: $minCoreStepsPerLesson)',
    );
  }
  if (coreSteps.length > maxCoreStepsPerLesson) {
    logError(
      '$lessonPrefix: Too many core steps (${coreSteps.length}, '
      'maximum: $maxCoreStepsPerLesson)',
    );
  }

  // Count new items (unique phraseIds from teach_phrase steps)
  final newItemIds = <String>{};
  for (final step in steps) {
    final stepMap = step as Map<String, dynamic>;
    if (stepMap['type'] == 'teach_phrase') {
      final phraseId = stepMap['phraseId'] as String?;
      if (phraseId != null) {
        newItemIds.add(phraseId);
      }
    }
  }

  if (newItemIds.length < minNewItemsPerLesson) {
    logError(
      '$lessonPrefix: Too few new items introduced (${newItemIds.length}, '
      'minimum: $minNewItemsPerLesson)',
    );
  }
  if (newItemIds.length > maxNewItemsPerLesson) {
    logError(
      '$lessonPrefix: Too many new items introduced (${newItemIds.length}, '
      'maximum: $maxNewItemsPerLesson)',
    );
  }

  // Validate each step
  for (int i = 0; i < steps.length; i++) {
    validateStep(
      steps[i] as Map<String, dynamic>,
      items,
      '$lessonPrefix -> step[$i]',
    );
  }
}

void validateStep(
  Map<String, dynamic> step,
  Map<String, dynamic> items,
  String path,
) {
  if (!step.containsKey('type')) {
    logError('$path: Missing "type"');
    return;
  }

  final type = step['type'] as String;

  switch (type) {
    case 'teach_phrase':
      validateTeachPhrase(step, items, path);
      break;
    case 'mcq':
      validateMcq(step, path);
      break;
    case 'match':
      // Basic structure check only
      if (!step.containsKey('pairs')) {
        logError('$path: match step missing "pairs"');
      }
      break;
    case 'reorder':
      validateReorder(step, path);
      break;
    case 'fill_blank':
      validateFillBlank(step, path);
      break;
    case 'listening_choice':
      validateListeningChoice(step, items, path);
      break;
    case 'dialogue_choice':
      validateDialogueChoice(step, path);
      break;
    case 'lesson_complete':
      // No special validation needed
      break;
    default:
      logError('$path: Unknown step type "$type"');
  }
}

void validateTeachPhrase(
  Map<String, dynamic> step,
  Map<String, dynamic> items,
  String path,
) {
  if (!step.containsKey('phraseId')) {
    logError('$path: teach_phrase missing "phraseId"');
    return;
  }

  final phraseId = step['phraseId'] as String;
  if (!items.containsKey(phraseId)) {
    logError('$path: phraseId "$phraseId" not found in unit items');
  }
}

void validateMcq(Map<String, dynamic> step, String path) {
  if (!step.containsKey('options')) {
    logError('$path: mcq missing "options"');
    return;
  }
  if (!step.containsKey('correctIndex')) {
    logError('$path: mcq missing "correctIndex"');
    return;
  }

  final options = step['options'] as List;
  final correctIndex = step['correctIndex'] as int;

  if (correctIndex < 0 || correctIndex >= options.length) {
    logError(
      '$path: correctIndex ($correctIndex) out of bounds '
      '(options length: ${options.length})',
    );
  }
}

void validateReorder(Map<String, dynamic> step, String path) {
  if (!step.containsKey('words')) {
    logError('$path: reorder missing "words"');
    return;
  }
  if (!step.containsKey('correctOrder')) {
    logError('$path: reorder missing "correctOrder"');
    return;
  }

  final words = step['words'] as List;
  final correctOrder = step['correctOrder'] as List;

  // Length match
  if (correctOrder.length != words.length) {
    logError(
      '$path: correctOrder length (${correctOrder.length}) != '
      'words length (${words.length})',
    );
  }

  // Indices valid and unique
  final indices = <int>{};
  for (final idx in correctOrder) {
    final index = idx as int;
    if (index < 0 || index >= words.length) {
      logError('$path: correctOrder index $index out of bounds');
    }
    if (indices.contains(index)) {
      logError('$path: correctOrder has duplicate index $index');
    }
    indices.add(index);
  }
}

void validateFillBlank(Map<String, dynamic> step, String path) {
  final required = ['sentence', 'blank', 'answer'];
  for (final field in required) {
    if (!step.containsKey(field)) {
      logError('$path: fill_blank missing "$field"');
    }
  }
}

void validateListeningChoice(
  Map<String, dynamic> step,
  Map<String, dynamic> items,
  String path,
) {
  if (!step.containsKey('audioId')) {
    logError('$path: listening_choice missing "audioId"');
    return;
  }
  if (!step.containsKey('options')) {
    logError('$path: listening_choice missing "options"');
    return;
  }
  if (!step.containsKey('correctIndex')) {
    logError('$path: listening_choice missing "correctIndex"');
    return;
  }

  final audioId = step['audioId'] as String;
  final options = step['options'] as List;
  final correctIndex = step['correctIndex'] as int;

  // Check audioId exists in items
  bool audioFound = false;
  for (final item in items.values) {
    if ((item as Map)['audioId'] == audioId) {
      audioFound = true;
      break;
    }
  }
  if (!audioFound) {
    logError('$path: audioId "$audioId" not found in unit items');
  }

  // correctIndex bounds
  if (correctIndex < 0 || correctIndex >= options.length) {
    logError(
      '$path: correctIndex ($correctIndex) out of bounds '
      '(options length: ${options.length})',
    );
  }
}

void validateDialogueChoice(Map<String, dynamic> step, String path) {
  if (!step.containsKey('context')) {
    logError('$path: dialogue_choice missing "context"');
    return;
  }
  if (!step.containsKey('options')) {
    logError('$path: dialogue_choice missing "options"');
    return;
  }
  if (!step.containsKey('correctIndex')) {
    logError('$path: dialogue_choice missing "correctIndex"');
    return;
  }

  final options = step['options'] as List;
  final correctIndex = step['correctIndex'] as int;

  if (correctIndex < 0 || correctIndex >= options.length) {
    logError(
      '$path: correctIndex ($correctIndex) out of bounds '
      '(options length: ${options.length})',
    );
  }
}

// Logging helpers
void logError(String message) {
  errorsFound++;
  print('  ❌ ERROR: $message');
}

void logWarning(String message) {
  warningsFound++;
  print('  ⚠️  WARNING: $message');
}

void logSuccess(String message) {
  print('  ✅ $message');
}
