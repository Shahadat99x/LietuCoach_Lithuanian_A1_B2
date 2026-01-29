import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String _practiceStatsBox = 'practice_stats';

class DailySessionService {
  Box? _box;
  bool _initialized = false;

  // Singleton
  static final DailySessionService _instance = DailySessionService._internal();
  DailySessionService._internal();
  factory DailySessionService() => _instance;

  Future<void> init() async {
    if (_initialized) return;
    _box = await Hive.openBox(_practiceStatsBox);
    _initialized = true;
    _checkDailyReset();
  }

  void _ensureInit() {
    if (!_initialized) throw StateError('DailySessionService not initialized');
  }

  // --- Getters ---

  int get streakCount {
    _ensureInit();
    return _box!.get('streakCount', defaultValue: 0);
  }

  DateTime? get lastPracticeDate {
    _ensureInit();
    final ms = _box!.get('lastPracticeDate');
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  int get xpToday {
    _ensureInit();
    _checkDailyReset();
    return _box!.get('xpToday', defaultValue: 0);
  }

  int get minutesToday {
    _ensureInit();
    _checkDailyReset();
    return _box!.get('minutesToday', defaultValue: 0);
  }

  int get dailyGoalMinutes {
    _ensureInit();
    return _box!.get('dailyGoalMinutes', defaultValue: 10);
  }

  // --- Actions ---

  Future<void> recordSession(int minutes, {int xp = 10}) async {
    _ensureInit();
    _checkDailyReset(); // Ensure today's stats are fresh

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = lastPracticeDate;

    // Update daily stats
    final currentXp = xpToday;
    final currentMin = minutesToday;
    await _box!.put('xpToday', currentXp + xp);
    await _box!.put('minutesToday', currentMin + minutes);

    // Update streak
    // If last practice was yesterday, increment.
    // If last practice was today, do nothing to streak.
    // If last practice was before yesterday, reset to 1.
    
    if (lastDate != null) {
      final lastDateDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final difference = today.difference(lastDateDay).inDays;

      if (difference == 1) {
        // Streak continues
        await _box!.put('streakCount', streakCount + 1);
      } else if (difference > 1) {
        // Streak broken
        await _box!.put('streakCount', 1);
      }
      // If difference == 0 (all same day), streak doesn't change
    } else {
      // First ever practice
      await _box!.put('streakCount', 1);
    }

    await _box!.put('lastPracticeDate', now.millisecondsSinceEpoch);
  }

  Future<void> setDailyGoal(int minutes) async {
    _ensureInit();
    await _box!.put('dailyGoalMinutes', minutes);
  }

  // --- Internal ---

  void _checkDailyReset() {
    // If stored date is not today, reset today's stats
    // We don't write to box immediately to avoid async in getter, 
    // but strict separation is better. 
    // Ideally init() logic handles this or we rely on 'lastDailyReset' key.
    
    // For simplicity, let's rely on stored stats date.
    final lastResetMs = _box!.get('lastResetDate');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (lastResetMs == null) {
       _box!.put('lastResetDate', today.millisecondsSinceEpoch);
       return;
    }

    final lastResetDate = DateTime.fromMillisecondsSinceEpoch(lastResetMs);
    final lastResetDay = DateTime(lastResetDate.year, lastResetDate.month, lastResetDate.day);

    if (today.isAfter(lastResetDay)) {
       _box!.put('xpToday', 0);
       _box!.put('minutesToday', 0);
       _box!.put('lastResetDate', today.millisecondsSinceEpoch);
    }
  }
}
