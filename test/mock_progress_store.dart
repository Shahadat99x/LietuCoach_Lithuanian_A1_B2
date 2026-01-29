/// Mock Progress Store for testing
import 'package:lietucoach/progress/progress.dart';

class MockProgressStore implements ProgressStore {
  final Map<String, LessonProgress> _lessons = {};
  final Map<String, UnitProgress> _units = {};
  final UserStats _userStats = UserStats();

  @override
  Future<void> init() async {}

  @override
  Future<LessonProgress?> getLessonProgress(
    String unitId,
    String lessonId,
  ) async {
    return _lessons['${unitId}_$lessonId'];
  }

  @override
  Future<List<LessonProgress>> getUnitLessonProgress(String unitId) async {
    return _lessons.values.where((p) => p.unitId == unitId).toList();
  }

  @override
  Future<List<LessonProgress>> getAllLessonProgress() async {
    return _lessons.values.toList();
  }

  @override
  Future<void> saveLessonProgress(LessonProgress progress) async {
    _lessons[progress.key] = progress;
  }

  @override
  Future<UnitProgress?> getUnitProgress(String unitId) async {
    return _units[unitId];
  }

  @override
  Future<List<UnitProgress>> getAllUnitProgress() async {
    return _units.values.toList();
  }

  @override
  Future<void> saveUnitProgress(UnitProgress progress) async {
    _units[progress.unitId] = progress;
  }

  @override
  Future<UserStats> getUserStats() async {
    return _userStats;
  }

  @override
  Future<void> saveUserStats(UserStats stats) async {
    _userStats.totalXp = stats.totalXp;
    _userStats.currentStreak = stats.currentStreak;
    _userStats.lastActivityDate = stats.lastActivityDate;
    _userStats.lessonsCompleted = stats.lessonsCompleted;
    _userStats.examsCompleted = stats.examsCompleted;
  }

  @override
  Future<bool> isUnitUnlocked(String unitId) async {
    if (unitId == 'unit_01') return true;

    if (unitId == 'unit_02') {
      final prevUnitLessons = await getUnitLessonProgress('unit_01');
      final allLessons = prevUnitLessons.where((l) => l.completed).length >= 2;
      final examPassed = _units['unit_01']?.examPassed ?? false;
      return allLessons && examPassed;
    }
    return false;
  }

  @override
  Future<bool> areAllLessonsCompleted(
    String unitId,
    List<String> lessonIds,
  ) async {
    final progress = await getUnitLessonProgress(unitId);
    final completedIds = progress
        .where((p) => p.completed)
        .map((p) => p.lessonId)
        .toSet();
    return lessonIds.every((id) => completedIds.contains(id));
  }

  @override
  Future<void> clearAll() async {
    _lessons.clear();
    _units.clear();
  }

  @override
  Future<void> dispose() async {}
}
