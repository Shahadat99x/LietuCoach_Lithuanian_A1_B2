import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/features/lesson/lesson_list_screen.dart';
import 'package:lietucoach/progress/progress.dart';
import 'package:lietucoach/content/content.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<ProgressStore>(), MockSpec<ContentRepository>()])
import 'unit_exam_entry_test.mocks.dart';

void main() {
  group('LessonListScreen Exam Entry', () {
    late MockProgressStore mockStore;
    late MockContentRepository mockRepo;

    setUp(() {
      mockStore = MockProgressStore();
      mockRepo = MockContentRepository();

      // Inject mock store
      setMockProgressStore(mockStore);

      when(
        mockStore.areAllLessonsCompleted(any, any),
      ).thenAnswer((_) async => false);

      // Default: Unit 01 with 2 lessons
      when(mockRepo.loadUnit('unit_01')).thenAnswer(
        (_) async => Result.success(
          Unit(
            id: 'unit_01',
            title: 'Unit 1',
            lessons: [
              Lesson(id: 'l1', title: 'L1', steps: []),
              Lesson(id: 'l2', title: 'L2', steps: []),
            ],
            items: {},
          ),
        ),
      );
    });

    testWidgets('Shows Locked Exam when lessons incomplete', (tester) async {
      // 1 lesson complete, 1 incomplete
      when(mockStore.getUnitLessonProgress('unit_01')).thenAnswer(
        (_) async => [
          LessonProgress(unitId: 'unit_01', lessonId: 'l1', completed: true),
        ],
      );
      when(mockStore.getUnitProgress('unit_01')).thenAnswer((_) async => null);

      await tester.pumpWidget(
        MaterialApp(
          home: LessonListScreen(unitId: 'unit_01', repository: mockRepo),
        ),
      );
      await tester.pumpAndSettle();

      // Find "Unit Exam" text
      expect(find.text('Unit Exam'), findsOneWidget);
      expect(find.text('Complete all lessons first'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('Shows Unlocked Exam when all lessons complete', (
      tester,
    ) async {
      // 2 lessons complete
      when(mockStore.getUnitLessonProgress('unit_01')).thenAnswer(
        (_) async => [
          LessonProgress(unitId: 'unit_01', lessonId: 'l1', completed: true),
          LessonProgress(unitId: 'unit_01', lessonId: 'l2', completed: true),
        ],
      );
      when(
        mockStore.areAllLessonsCompleted('unit_01', any),
      ).thenAnswer((_) async => true);
      when(mockStore.getUnitProgress('unit_01')).thenAnswer((_) async => null);

      await tester.pumpWidget(
        MaterialApp(
          home: LessonListScreen(unitId: 'unit_01', repository: mockRepo),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1)); // Wait for futures
      await tester.pump(); // Rebuild with data

      expect(find.text('Unit Exam'), findsOneWidget);
      expect(find.text('Test your knowledge'), findsOneWidget);
      expect(find.byIcon(Icons.quiz), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsNothing);
    });

    testWidgets('Shows Passed Exam', (tester) async {
      // 2 lessons complete + passed
      when(mockStore.getUnitLessonProgress('unit_01')).thenAnswer(
        (_) async => [
          LessonProgress(unitId: 'unit_01', lessonId: 'l1', completed: true),
          LessonProgress(unitId: 'unit_01', lessonId: 'l2', completed: true),
        ],
      );
      when(
        mockStore.areAllLessonsCompleted('unit_01', any),
      ).thenAnswer((_) async => true);
      when(mockStore.getUnitProgress('unit_01')).thenAnswer(
        (_) async =>
            UnitProgress(unitId: 'unit_01', examPassed: true, examScore: 90),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LessonListScreen(unitId: 'unit_01', repository: mockRepo),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1)); // Wait for futures
      await tester.pump();

      expect(find.text('Exam Passed'), findsOneWidget);
      expect(find.text('Score: 90% • Tap to retake'), findsOneWidget);
      // Icons.workspace_premium might not be finding by IconData if it's platform dependent?
      // Using IconData directly is safe for widgets tests.
    });
  });
}
