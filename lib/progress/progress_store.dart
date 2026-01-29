/// Progress Store Interface
///
/// Abstract interface for progress persistence.
/// Allows swapping implementations (local, cloud, mock).

import 'progress_models.dart';

/// Abstract interface for progress storage
abstract class ProgressStore {
  /// Initialize storage
  Future<void> init();

  /// Get lesson progress by unit and lesson ID
  Future<LessonProgress?> getLessonProgress(String unitId, String lessonId);

  /// Get all lesson progress for a unit
  Future<List<LessonProgress>> getUnitLessonProgress(String unitId);

  /// Get all lesson progress (for sync)
  Future<List<LessonProgress>> getAllLessonProgress();

  /// Save lesson progress
  Future<void> saveLessonProgress(LessonProgress progress);

  /// Get unit progress (exam status)
  Future<UnitProgress?> getUnitProgress(String unitId);

  /// Get all unit progress (for sync)
  Future<List<UnitProgress>> getAllUnitProgress();

  /// Save unit progress
  Future<void> saveUnitProgress(UnitProgress progress);

  /// Get user stats
  Future<UserStats> getUserStats();

  /// Save user stats
  Future<void> saveUserStats(UserStats stats);

  /// Check if unit is unlocked
  /// Unit 1 is always unlocked
  /// Unit N is unlocked if unit N-1 exam is passed
  Future<bool> isUnitUnlocked(String unitId);

  /// Check if specific lessons in a unit are completed
  Future<bool> areAllLessonsCompleted(String unitId, List<String> lessonIds);

  /// Clear all progress (for testing/reset)
  Future<void> clearAll();

  /// Dispose resources
  Future<void> dispose();
}
