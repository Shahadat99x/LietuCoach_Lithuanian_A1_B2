import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/features/practice/practice_stats_service.dart';
import 'package:lietucoach/progress/progress.dart';
import '../../mock_progress_store.dart';

void main() {
  group('PracticeStatsService', () {
    late PracticeStatsService service;
    late MockProgressStore mockStore;

    setUp(() {
      mockStore = MockProgressStore();
      setMockProgressStore(mockStore);
      service = PracticeStatsService();
      // Reset singleton state if needed (not easily possible with current singleton implementation,
      // but we can rely on mockStore returning fresh data)
    });

    test('Initial stats are empty', () async {
      final stats = await service.stats;
      expect(stats.totalXp, 0);
      expect(stats.currentStreak, 0);
    });

    test('recordPracticeEvent increments XP and minutes', () async {
      await service.recordPracticeEvent(
        type: PracticeEventType.manualDebug,
        xpDelta: 10,
        minutesDelta: 5,
      );

      final stats = await service.stats;
      expect(stats.totalXp, 10);
      expect(stats.minutesToday, 5);
    });

    test('Streak increments for new day', () async {
      // Setup: Last active yesterday
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await mockStore.saveUserStats(
        UserStats(lastActivityDate: yesterday, currentStreak: 5),
      );

      await service.recordPracticeEvent(type: PracticeEventType.manualDebug);

      final stats = await service.stats;
      expect(stats.currentStreak, 6);
    });

    test('Streak resets after gap', () async {
      // Setup: Last active 2 days ago
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      await mockStore.saveUserStats(
        UserStats(lastActivityDate: twoDaysAgo, currentStreak: 5),
      );

      await service.recordPracticeEvent(type: PracticeEventType.manualDebug);

      final stats = await service.stats;
      expect(stats.currentStreak, 1);
    });

    test('Streak maintained on same day', () async {
      // Setup: Last active today
      final today = DateTime.now();
      await mockStore.saveUserStats(
        UserStats(lastActivityDate: today, currentStreak: 5),
      );

      await service.recordPracticeEvent(type: PracticeEventType.manualDebug);

      final stats = await service.stats;
      expect(stats.currentStreak, 5);
    });

    test('SRS buffer threshold works', () async {
      // 1. Review 4 cards - no update
      await service.recordPracticeEvent(
        type: PracticeEventType.srsReview,
        cardsReviewedDelta: 4,
      );
      var stats = await service.stats;
      expect(stats.totalXp, 0); // No XP yet (assuming 0 base) or check flag

      // 2. Review 1 more - triggers threshold (>=5)
      await service.recordPracticeEvent(
        type: PracticeEventType.srsReview,
        cardsReviewedDelta: 1,
        xpDelta: 10,
      );
      stats = await service.stats;
      expect(stats.totalXp, 10); // Now it committed
    });

    test('UserStats serialization includes dailyGoalMinutes', () {
      final stats = UserStats(dailyGoalMinutes: 45);
      final map = stats.toMap();

      expect(map['dailyGoalMinutes'], 45);

      final fromMap = UserStats.fromMap(map);
      expect(fromMap.dailyGoalMinutes, 45);
    });
  });
}
