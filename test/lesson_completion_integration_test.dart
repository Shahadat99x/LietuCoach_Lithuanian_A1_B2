import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:lietucoach/features/lesson/lesson_list_screen.dart';
import 'package:lietucoach/progress/progress.dart';
import 'package:lietucoach/content/content.dart';
import 'package:lietucoach/srs/srs.dart';

import 'unit_exam_entry_test.mocks.dart';

// Manual stub for SrsStore
class MockSrsStore extends Mock implements SrsStore {
  @override
  Future<SrsCard?> getCard(String cardId) async => null;
  @override
  Future<void> upsertCards(List<SrsCard> cards) async {}
  @override
  Future<SrsStats> getStats() async => SrsStats(dueToday: 0, totalCards: 0);
  @override
  Future<void> init() async {}
  @override
  Future<void> dispose() async {}
}

void main() {
  group('Lesson Completion Integration', () {
    late MockProgressStore mockStore;
    late MockContentRepository mockRepo;
    late MockSrsStore mockSrsStore;

    final unit01 = Unit(
      id: 'unit_01',
      title: 'Unit 1',
      lessons: [
        Lesson(
          id: 'lesson_01',
          title: 'L1',
          steps: [LessonCompleteStep(itemsLearned: 0, xpEarned: 0)],
        ),
        Lesson(id: 'lesson_02', title: 'L2', steps: []),
      ],
      items: {},
    );

    setUp(() {
      mockStore = MockProgressStore();
      mockRepo = MockContentRepository();
      mockSrsStore = MockSrsStore();

      setMockProgressStore(mockStore);
      setMockSrsStore(mockSrsStore);

      when(
        mockRepo.loadUnit('unit_01'),
      ).thenAnswer((_) async => Result.success(unit01));
      when(
        mockStore.getUnitLessonProgress('unit_01'),
      ).thenAnswer((_) async => []);
      when(mockStore.getUnitProgress('unit_01')).thenAnswer((_) async => null);
      when(
        mockStore.areAllLessonsCompleted(any, any),
      ).thenAnswer((_) async => false);
      when(mockStore.saveLessonProgress(any)).thenAnswer((_) async {});
    });

    testWidgets('Completing a lesson persists progress', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LessonListScreen(unitId: 'unit_01', repository: mockRepo),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('L1'));
      await tester.pumpAndSettle();

      // Should show 'Perfect!' since score is 0/0 (100%)
      expect(find.text('Perfect!'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      verify(
        mockStore.saveLessonProgress(
          argThat(
            isA<LessonProgress>()
                .having((p) => p.unitId, 'unitId', 'unit_01')
                .having((p) => p.lessonId, 'lessonId', 'lesson_01')
                .having((p) => p.completed, 'completed', true),
          ),
        ),
      ).called(1);
    });

    group('Canonical ID Verification', () {
      test('LessonProgress generic key generation', () {
        final p = LessonProgress(unitId: 'u1', lessonId: 'l1');
        expect(p.key, 'u1_l1');
      });
    });
  });
}
