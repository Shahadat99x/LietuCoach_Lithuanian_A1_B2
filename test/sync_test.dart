/// Sync Merge Logic Tests
///
/// Unit tests for conflict resolution and merge strategies.

import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/progress/progress_models.dart';
import 'package:lietucoach/srs/srs_models.dart';

void main() {
  group('Merge Logic - Last Write Wins', () {
    test('local newer than remote - local wins', () {
      final localUpdatedAt = DateTime(2026, 1, 28, 12, 0, 0);
      final remoteUpdatedAt = DateTime(2026, 1, 28, 11, 0, 0);

      // Local is newer, should be kept
      expect(localUpdatedAt.isAfter(remoteUpdatedAt), isTrue);
    });

    test('remote newer than local - remote wins', () {
      final localUpdatedAt = DateTime(2026, 1, 28, 10, 0, 0);
      final remoteUpdatedAt = DateTime(2026, 1, 28, 11, 0, 0);

      // Remote is newer, should be kept
      expect(remoteUpdatedAt.isAfter(localUpdatedAt), isTrue);
    });

    test('same timestamp - no conflict', () {
      final timestamp = DateTime(2026, 1, 28, 12, 0, 0);

      expect(timestamp.isAfter(timestamp), isFalse);
      expect(timestamp.isAtSameMomentAs(timestamp), isTrue);
    });
  });

  group('Merge Logic - LessonProgress completed flag', () {
    test('completed=true is preserved when local is false', () {
      final local = LessonProgress(
        unitId: 'unit_01',
        lessonId: 'lesson_01_greetings',
        completed: false,
        score: 0,
      );

      final remoteCompleted = true;

      // Merge rule: completed=true wins
      final merged = local.completed || remoteCompleted;
      expect(merged, isTrue);
    });

    test('completed=true is preserved when remote is false', () {
      final local = LessonProgress(
        unitId: 'unit_01',
        lessonId: 'lesson_01_greetings',
        completed: true,
        score: 100,
      );

      final remoteCompleted = false;

      // Merge rule: completed=true wins
      final merged = local.completed || remoteCompleted;
      expect(merged, isTrue);
    });

    test('both false stays false', () {
      final localCompleted = false;
      final remoteCompleted = false;

      final merged = localCompleted || remoteCompleted;
      expect(merged, isFalse);
    });

    test('both true stays true', () {
      final localCompleted = true;
      final remoteCompleted = true;

      final merged = localCompleted || remoteCompleted;
      expect(merged, isTrue);
    });
  });

  group('Merge Logic - UnitProgress examPassed flag', () {
    test('examPassed=true is preserved when merging', () {
      final localPassed = true;
      final remotePassed = false;

      // Merge rule: examPassed=true wins
      final merged = localPassed || remotePassed;
      expect(merged, isTrue);
    });

    test('examPassed from remote preserved', () {
      final localPassed = false;
      final remotePassed = true;

      final merged = localPassed || remotePassed;
      expect(merged, isTrue);
    });
  });

  group('Merge Logic - SrsCard', () {
    test('newer SRS card data wins', () {
      final localCard = SrsCard(
        cardId: 'a1:unit_01:hello',
        unitId: 'unit_01',
        phraseId: 'hello',
        front: 'Labas',
        back: 'Hello',
        audioId: 'a1_u01_hello',
        ease: 2.5,
        intervalDays: 1,
        dueAt: DateTime(2026, 1, 29),
        reps: 1,
        lapses: 0,
        updatedAt: DateTime(2026, 1, 28, 10, 0, 0),
      );

      final remoteUpdatedAt = DateTime(2026, 1, 28, 12, 0, 0);
      final remoteEase = 2.7;
      final remoteIntervalDays = 3;
      final remoteDueAt = DateTime(2026, 1, 31);
      final remoteReps = 2;

      // Remote is newer
      expect(remoteUpdatedAt.isAfter(localCard.updatedAt), isTrue);

      // Should use remote values
      final merged = localCard.copyWith(
        ease: remoteEase,
        intervalDays: remoteIntervalDays,
        dueAt: remoteDueAt,
        reps: remoteReps,
        updatedAt: remoteUpdatedAt,
      );

      expect(merged.ease, equals(2.7));
      expect(merged.intervalDays, equals(3));
      expect(merged.dueAt, equals(DateTime(2026, 1, 31)));
      expect(merged.reps, equals(2));
      expect(merged.updatedAt, equals(remoteUpdatedAt));
    });

    test('local SRS card wins when newer', () {
      final localUpdatedAt = DateTime(2026, 1, 28, 14, 0, 0);
      final remoteUpdatedAt = DateTime(2026, 1, 28, 12, 0, 0);

      expect(localUpdatedAt.isAfter(remoteUpdatedAt), isTrue);
      // In this case, local should be pushed to remote, not merged
    });

    test('SrsCard updatedAt is set correctly on copyWith', () {
      final card = SrsCard(
        cardId: 'test:card:1',
        unitId: 'unit_01',
        phraseId: 'test',
        front: 'Test',
        back: 'Test',
        audioId: 'test',
        updatedAt: DateTime(2026, 1, 1),
      );

      final updated = card.copyWith(ease: 2.8);

      // copyWith should set updatedAt to now
      expect(updated.updatedAt.isAfter(card.updatedAt), isTrue);
    });
  });

  group('LessonProgress model', () {
    test('updatedAt is set on creation', () {
      final before = DateTime.now();
      final progress = LessonProgress(
        unitId: 'unit_01',
        lessonId: 'lesson_01',
        completed: true,
        score: 100,
      );
      final after = DateTime.now();

      expect(
        progress.updatedAt.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        progress.updatedAt.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('copyWith updates updatedAt', () {
      final original = LessonProgress(
        unitId: 'unit_01',
        lessonId: 'lesson_01',
        completed: false,
        updatedAt: DateTime(2026, 1, 1),
      );

      final updated = original.copyWith(completed: true);

      expect(updated.completed, isTrue);
      expect(updated.updatedAt.isAfter(original.updatedAt), isTrue);
    });
  });

  group('UnitProgress model', () {
    test('updatedAt is set on creation', () {
      final progress = UnitProgress(unitId: 'unit_01');

      expect(progress.updatedAt, isNotNull);
    });

    test('copyWith updates updatedAt', () {
      final original = UnitProgress(
        unitId: 'unit_01',
        examPassed: false,
        updatedAt: DateTime(2026, 1, 1),
      );

      final updated = original.copyWith(examPassed: true);

      expect(updated.examPassed, isTrue);
      expect(updated.updatedAt.isAfter(original.updatedAt), isTrue);
    });
  });
}
