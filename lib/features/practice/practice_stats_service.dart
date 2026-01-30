import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lietucoach/progress/progress.dart';

/// Event types that contribute to practice stats
enum PracticeEventType {
  lessonCompletion,
  examCompletion,
  dailyMixCompletion,
  srsReview,
  listeningSession,
  manualDebug,
}

/// A service to manage user practice statistics, streaks, and daily goals.
class PracticeStatsService extends ChangeNotifier {
  // Singleton instance
  static final PracticeStatsService _instance =
      PracticeStatsService._internal();

  factory PracticeStatsService() {
    return _instance;
  }

  PracticeStatsService._internal();

  /// Constants for meaningful practice thresholds
  static const int _srsCardThreshold = 5;
  static const int _listeningSecondsThreshold = 60;

  // Temporary buffers for "meaningful" checks
  int _sessionCardsReviewed = 0;
  int _sessionListeningSeconds = 0;

  /// Load current stats
  Future<UserStats> get stats async {
    return await progressStore.getUserStats();
  }

  /// Initialize service (check streak on app start)
  Future<void> init() async {
    await _checkStreakMaintenance();
  }

  /// Update daily goal
  Future<void> updateDailyGoal(int minutes) async {
    final current = await stats;
    final updated = current.copyWith(dailyGoalMinutes: minutes);
    await progressStore.saveUserStats(updated);
    notifyListeners();
  }

  /// Record a practice event
  Future<void> recordPracticeEvent({
    required PracticeEventType type,
    int xpDelta = 0,
    int minutesDelta = 0,
    int cardsReviewedDelta = 0,
    int listeningSecondsDelta = 0,
  }) async {
    final now = DateTime.now();
    var current = await stats;

    // buffer accumulation
    _sessionCardsReviewed += cardsReviewedDelta;
    _sessionListeningSeconds += listeningSecondsDelta;

    // Check strict meaningfulness rules
    bool isMeaningful = false;

    switch (type) {
      case PracticeEventType.lessonCompletion:
      case PracticeEventType.examCompletion:
      case PracticeEventType.dailyMixCompletion:
      case PracticeEventType.manualDebug:
        isMeaningful = true; // Always meaningful
        break;
      case PracticeEventType.srsReview:
        if (_sessionCardsReviewed >= _srsCardThreshold) {
          isMeaningful = true;
          _sessionCardsReviewed = 0; // Reset buffer after claiming
        }
        break;
      case PracticeEventType.listeningSession:
        if (_sessionListeningSeconds >= _listeningSecondsThreshold) {
          isMeaningful = true;
          _sessionListeningSeconds = 0; // Reset buffer after claiming
        }
        break;
    }

    // Update Daily Minutes
    // Check if we need to reset daily minutes for a new day
    final todayDate = DateTime(now.year, now.month, now.day);
    if (current.lastSessionDate == null ||
        !DateUtils.isSameDay(current.lastSessionDate, todayDate)) {
      current.minutesToday = 0;
    }

    // Apply updates
    int newTotalXp = current.totalXp + xpDelta;
    int newMinutesToday = current.minutesToday + minutesDelta;
    int newLessons =
        current.lessonsCompleted +
        (type == PracticeEventType.lessonCompletion ? 1 : 0);
    int newExams =
        current.examsCompleted +
        (type == PracticeEventType.examCompletion ? 1 : 0);

    // Apply Streak Logic (only if meaningful)
    int newStreak = current.currentStreak;
    DateTime? newLastActivity = current.lastActivityDate;

    if (isMeaningful) {
      if (current.lastActivityDate == null) {
        // First ever activity
        newStreak = 1;
        newLastActivity = todayDate;
      } else {
        final lastDate = DateUtils.dateOnly(current.lastActivityDate!);
        final diff = todayDate.difference(lastDate).inDays;

        if (diff == 0) {
          // Same day, streak maintained, no increment
          newLastActivity = todayDate;
        } else if (diff == 1) {
          // Yesterday was active, increment streak
          newStreak += 1;
          newLastActivity = todayDate;
        } else {
          // Gap > 1 day, streak reset
          newStreak = 1;
          newLastActivity = todayDate;
        }
      }
    }

    // Save
    final updated = current.copyWith(
      totalXp: newTotalXp,
      minutesToday: newMinutesToday,
      lessonsCompleted: newLessons,
      examsCompleted: newExams,
      currentStreak: newStreak,
      lastActivityDate: newLastActivity,
      lastSessionDate: todayDate,
    );

    await progressStore.saveUserStats(updated);
    notifyListeners();
  }

  /// Run on startup to reset streak if missed yesterday (visual update mainly)
  Future<void> _checkStreakMaintenance() async {
    final current = await stats;
    if (current.lastActivityDate == null) return;

    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    // lastDate was not used in logical check here, we rely on lastSessionDate

    // If we missed yesterday (diff > 1), streak effectively is 0 for display logic,
    // but we don't hard reset it in DB until the next activity actually happens?
    // Duolingo usually shows "Streak broken" visual.
    // For simplicity, if diff > 1, we can speculatively reset it or let the UI handle it.
    // Let's rely on recordPracticeEvent to set it to 1 on next activity.
    // UI should show 0 if difference > 1 && today != lastDate.

    // However, we DO need to reset minutesToday if date changed
    if (current.lastSessionDate == null ||
        !DateUtils.isSameDay(current.lastSessionDate, today)) {
      final updated = current.copyWith(minutesToday: 0, lastSessionDate: today);
      await progressStore.saveUserStats(updated);
      notifyListeners();
    }
  }

  /// Helper to check if streak is active for UI
  bool isStreakActive(UserStats stats) {
    if (stats.currentStreak == 0) return false;
    if (stats.lastActivityDate == null) return false;

    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final lastDate = DateUtils.dateOnly(stats.lastActivityDate!);
    final diff = today.difference(lastDate).inDays;

    // Active if practiced today (0) or yesterday (1)
    return diff <= 1;
  }
}

/// Global instance
final practiceStatsService = PracticeStatsService();
