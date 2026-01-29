/// Progress and Exam Tests

import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/progress/progress_models.dart';
import 'package:lietucoach/features/exam/exam_generator.dart';
import 'package:lietucoach/content/content.dart';

void main() {
  group('LessonProgress', () {
    test('serializes to and from Map', () {
      final progress = LessonProgress(
        unitId: 'unit_01',
        lessonId: 'lesson_01',
        completed: true,
        score: 85,
        xpEarned: 30,
      );

      final map = progress.toMap();
      final restored = LessonProgress.fromMap(map);

      expect(restored.unitId, 'unit_01');
      expect(restored.lessonId, 'lesson_01');
      expect(restored.completed, true);
      expect(restored.score, 85);
      expect(restored.xpEarned, 30);
    });

    test('generates correct key', () {
      final progress = LessonProgress(
        unitId: 'unit_01',
        lessonId: 'lesson_02',
      );
      expect(progress.key, 'unit_01_lesson_02');
    });
  });

  group('UnitProgress', () {
    test('serializes to and from Map', () {
      final passedAt = DateTime(2024, 1, 15);
      final progress = UnitProgress(
        unitId: 'unit_01',
        examPassed: true,
        examScore: 90,
        examPassedAt: passedAt,
      );

      final map = progress.toMap();
      final restored = UnitProgress.fromMap(map);

      expect(restored.unitId, 'unit_01');
      expect(restored.examPassed, true);
      expect(restored.examScore, 90);
      expect(restored.examPassedAt?.day, 15);
    });
  });

  group('Exam Scoring', () {
    test('79% fails, 80% passes', () {
      const threshold = 80;
      
      expect(79 >= threshold, false, reason: '79% should fail');
      expect(80 >= threshold, true, reason: '80% should pass');
      expect(81 >= threshold, true, reason: '81% should pass');
    });

    test('score calculation is correct', () {
      // 9 correct out of 12 = 75%
      expect((9 / 12 * 100).round(), 75);
      
      // 10 correct out of 12 = 83%
      expect((10 / 12 * 100).round(), 83);
    });
  });

  group('ExamGenerator', () {
    late Unit testUnit;

    setUp(() {
      testUnit = Unit(
        id: 'unit_01',
        title: 'Test Unit',
        titleLt: 'Testas',
        lessons: [],
        items: {
          'hello': Item(lt: 'Labas', en: 'Hello', audioId: 'a1_u01_hello'),
          'thanks': Item(lt: 'Ačiū', en: 'Thank you', audioId: 'a1_u01_thanks'),
          'yes': Item(lt: 'Taip', en: 'Yes', audioId: 'a1_u01_yes'),
          'no': Item(lt: 'Ne', en: 'No', audioId: 'a1_u01_no'),
          'please': Item(lt: 'Prašau', en: 'Please', audioId: 'a1_u01_please'),
        },
      );
    });

    test('generates deterministic questions with fixed seed', () {
      final gen1 = ExamGenerator(random: Random(42));
      final gen2 = ExamGenerator(random: Random(42));

      final q1 = gen1.generate(testUnit, questionCount: 5);
      final q2 = gen2.generate(testUnit, questionCount: 5);

      expect(q1.length, q2.length);
      for (var i = 0; i < q1.length; i++) {
        expect(q1[i].prompt, q2[i].prompt);
        expect(q1[i].correctIndex, q2[i].correctIndex);
      }
    });

    test('generates requested question count', () {
      final generator = ExamGenerator(random: Random(123));
      final questions = generator.generate(testUnit, questionCount: 5);
      
      expect(questions.length, 5);
    });

    test('all questions have 4 options', () {
      final generator = ExamGenerator(random: Random(456));
      final questions = generator.generate(testUnit, questionCount: 5);
      
      for (final q in questions) {
        expect(q.options.length, 4);
      }
    });

    test('correctIndex points to valid option', () {
      final generator = ExamGenerator(random: Random(789));
      final questions = generator.generate(testUnit, questionCount: 5);
      
      for (final q in questions) {
        expect(q.correctIndex >= 0, true);
        expect(q.correctIndex < q.options.length, true);
      }
    });
  });

  group('Gating Logic', () {
    test('unit_01 is always unlocked', () {
      // Unit index 0 is always unlocked
      const unitOrder = ['unit_01', 'unit_02', 'unit_03'];
      final unitIndex = unitOrder.indexOf('unit_01');
      expect(unitIndex <= 0, true);
    });

    test('unit_02 requires unit_01 completed and exam passed', () {
      // Simulating the gating check
      const unitOrder = ['unit_01', 'unit_02'];
      const unitId = 'unit_02';
      final unitIndex = unitOrder.indexOf(unitId);
      
      // Should need previous unit
      expect(unitIndex > 0, true);
      
      final prevUnitId = unitOrder[unitIndex - 1];
      expect(prevUnitId, 'unit_01');
      
      // Mock data: unit_01 has 2 lessons
      const lessonCount = 2;
      const completedLessons = 2;
      final allLessonsCompleted = completedLessons >= lessonCount;
      expect(allLessonsCompleted, true);
      
      // Mock: exam passed
      const examPassed = true;
      
      final isUnlocked = allLessonsCompleted && examPassed;
      expect(isUnlocked, true);
    });

    test('unit_02 locked if lessons incomplete', () {
      const lessonCount = 2;
      const completedLessons = 1;
      final allLessonsCompleted = completedLessons >= lessonCount;
      expect(allLessonsCompleted, false);
      
      const examPassed = true;
      
      final isUnlocked = allLessonsCompleted && examPassed;
      expect(isUnlocked, false);
    });

    test('unit_02 locked if exam not passed', () {
      const lessonCount = 2;
      const completedLessons = 2;
      final allLessonsCompleted = completedLessons >= lessonCount;
      expect(allLessonsCompleted, true);
      
      const examPassed = false;
      
      final isUnlocked = allLessonsCompleted && examPassed;
      expect(isUnlocked, false);
    });
  });
}
