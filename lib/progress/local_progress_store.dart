/// Local Progress Store (Hive implementation)
///
/// Offline-first persistence for lesson/exam progress.

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'progress_models.dart';
import 'progress_store.dart';

/// Schema version for migration handling
const int _schemaVersion = 1;
const String _schemaVersionKey = 'schema_version';
const String _lessonProgressBox = 'lesson_progress';
const String _unitProgressBox = 'unit_progress';
const String _userStatsBox = 'user_stats';
const String _metaBoxName = 'meta';

/// Unit ordering for progression
const List<String> unitOrder = ['unit_01', 'unit_02', 'unit_03'];

/// Local implementation using Hive
class LocalProgressStore implements ProgressStore {
  Box<Map>? _lessonBox;
  Box<Map>? _unitBox;
  Box<Map>? _statsBox;
  Box<dynamic>? _metaBox;
  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;

    // Initialize Hive (Calling initFlutter here is redundant as it's done in hive_init.dart)
    // await Hive.initFlutter();

    // Open meta box first to check schema
    _metaBox = await Hive.openBox(_metaBoxName);

    // Check schema version
    final storedVersion = _metaBox!.get(_schemaVersionKey) as int?;
    if (storedVersion != null && storedVersion != _schemaVersion) {
      // Schema mismatch - clear all data for MVP
      await _clearAllBoxes();
    }

    // Open data boxes
    _lessonBox = await Hive.openBox<Map>(_lessonProgressBox);
    _unitBox = await Hive.openBox<Map>(_unitProgressBox);
    _statsBox = await Hive.openBox<Map>(_userStatsBox);

    // Store current schema version
    await _metaBox!.put(_schemaVersionKey, _schemaVersion);

    _initialized = true;
  }

  Future<void> _clearAllBoxes() async {
    await Hive.deleteBoxFromDisk(_lessonProgressBox);
    await Hive.deleteBoxFromDisk(_unitProgressBox);
    await Hive.deleteBoxFromDisk(_userStatsBox);
  }

  void _ensureInit() {
    if (!_initialized) {
      throw StateError(
        'LocalProgressStore not initialized. Call init() first.',
      );
    }
  }

  @override
  Future<LessonProgress?> getLessonProgress(
    String unitId,
    String lessonId,
  ) async {
    _ensureInit();
    final key = '${unitId}_$lessonId';
    final map = _lessonBox!.get(key);
    if (map == null) return null;
    return LessonProgress.fromMap(map);
  }

  @override
  Future<List<LessonProgress>> getUnitLessonProgress(String unitId) async {
    _ensureInit();
    return _lessonBox!.values
        .where((map) => map['unitId'] == unitId)
        .map((map) => LessonProgress.fromMap(map))
        .toList();
  }

  @override
  Future<List<LessonProgress>> getAllLessonProgress() async {
    _ensureInit();
    return _lessonBox!.values
        .map((map) => LessonProgress.fromMap(map))
        .toList();
  }

  @override
  Future<void> saveLessonProgress(LessonProgress progress) async {
    _ensureInit();
    final key = progress.key;
    await _lessonBox!.put(key, progress.toMap());
  }

  @override
  Future<UnitProgress?> getUnitProgress(String unitId) async {
    _ensureInit();
    final map = _unitBox!.get(unitId);
    if (map == null) return null;
    return UnitProgress.fromMap(map);
  }

  @override
  Future<List<UnitProgress>> getAllUnitProgress() async {
    _ensureInit();
    return _unitBox!.values.map((map) => UnitProgress.fromMap(map)).toList();
  }

  @override
  Future<void> saveUnitProgress(UnitProgress progress) async {
    _ensureInit();
    await _unitBox!.put(progress.unitId, progress.toMap());
  }

  @override
  Future<UserStats> getUserStats() async {
    _ensureInit();
    final map = _statsBox!.get('user');
    if (map == null) return UserStats();
    return UserStats.fromMap(map);
  }

  @override
  Future<void> saveUserStats(UserStats stats) async {
    _ensureInit();
    await _statsBox!.put('user', stats.toMap());
  }

  @override
  Future<bool> isUnitUnlocked(String unitId) async {
    _ensureInit();

    // Unit 01 is always unlocked
    final unitIndex = unitOrder.indexOf(unitId);
    if (unitIndex <= 0) return true;

    // Need previous unit exam passed
    final prevUnitId = unitOrder[unitIndex - 1];

    // Check exam passed
    final prevUnitProgress = await getUnitProgress(prevUnitId);
    return prevUnitProgress?.examPassed ?? false;
  }

  @override
  Future<bool> areAllLessonsCompleted(
    String unitId,
    List<String> lessonIds,
  ) async {
    _ensureInit();
    if (lessonIds.isEmpty) return true;

    final progress = await getUnitLessonProgress(unitId);
    final completedIds = progress
        .where((p) => p.completed)
        .map((p) => p.lessonId)
        .toSet();

    return lessonIds.every((id) => completedIds.contains(id));
  }

  @override
  Future<void> clearAll() async {
    _ensureInit();
    await _lessonBox!.clear();
    await _unitBox!.clear();
    await _statsBox!.clear();
  }

  @override
  Future<void> dispose() async {
    await _lessonBox?.close();
    await _unitBox?.close();
    await _statsBox?.close();
    await _metaBox?.close();
    _initialized = false;
  }
}

/// Global singleton for progress store
ProgressStore? _instance;

ProgressStore get progressStore {
  _instance ??= LocalProgressStore();
  return _instance!;
}

/// Allow injecting a mock for testing
@visibleForTesting
void setMockProgressStore(ProgressStore? mock) {
  _instance = mock;
}

Future<void> initProgressStore() async {
  await progressStore.init();
}
