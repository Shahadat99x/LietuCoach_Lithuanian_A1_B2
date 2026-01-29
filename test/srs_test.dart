/// SRS Tests - Scheduling and persistence tests
///
/// Tests for spaced repetition algorithm and storage.

import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/srs/srs.dart';

void main() {
  group('SRS Scheduler', () {
    late SrsCard newCard;

    setUp(() {
      newCard = SrsCard(
        cardId: 'a1:unit_01:labas',
        unitId: 'unit_01',
        phraseId: 'labas',
        front: 'Labas',
        back: 'Hello',
        audioId: 'a1_u01_labas',
        ease: 2.5,
        intervalDays: 0,
        reps: 0,
      );
    });

    group('First Review', () {
      test('Hard rating: interval=1, ease decreases', () {
        final result = calculateNextReview(newCard, SrsRating.hard);

        expect(result.intervalDays, 1);
        expect(result.ease, closeTo(2.35, 0.01));
        expect(result.reps, 1);
      });

      test('Good rating: interval=3, ease stays', () {
        final result = calculateNextReview(newCard, SrsRating.good);

        expect(result.intervalDays, 3);
        expect(result.ease, 2.5);
        expect(result.reps, 1);
      });

      test('Easy rating: interval=7, ease increases', () {
        final result = calculateNextReview(newCard, SrsRating.easy);

        expect(result.intervalDays, 7);
        expect(result.ease, closeTo(2.65, 0.01));
        expect(result.reps, 1);
      });
    });

    group('Subsequent Review', () {
      late SrsCard reviewedCard;

      setUp(() {
        reviewedCard = SrsCard(
          cardId: 'a1:unit_01:labas',
          unitId: 'unit_01',
          phraseId: 'labas',
          front: 'Labas',
          back: 'Hello',
          audioId: 'a1_u01_labas',
          ease: 2.5,
          intervalDays: 3,
          reps: 1,
        );
      });

      test('Hard rating: interval * 1.2, ease decreases, lapses+1', () {
        final result = calculateNextReview(reviewedCard, SrsRating.hard);

        // 3 * 1.2 = 3.6 -> 4
        expect(result.intervalDays, 4);
        expect(result.ease, closeTo(2.35, 0.01));
        expect(result.reps, 2);
        expect(result.lapses, 1);
      });

      test('Good rating: interval * ease', () {
        final result = calculateNextReview(reviewedCard, SrsRating.good);

        // 3 * 2.5 = 7.5 -> 8
        expect(result.intervalDays, 8);
        expect(result.ease, 2.5);
        expect(result.reps, 2);
      });

      test('Easy rating: interval * ease * 1.3, ease increases', () {
        final result = calculateNextReview(reviewedCard, SrsRating.easy);

        // 3 * 2.5 * 1.3 = 9.75 -> 10
        expect(result.intervalDays, 10);
        expect(result.ease, closeTo(2.65, 0.01));
        expect(result.reps, 2);
      });
    });

    group('Ease Clamping', () {
      test('Ease cannot go below 1.3', () {
        var card = SrsCard(
          cardId: 'test',
          unitId: 'unit_01',
          phraseId: 'test',
          front: 'Test',
          back: 'Test',
          audioId: 'test',
          ease: 1.35, // Close to minimum
          intervalDays: 0,
          reps: 0,
        );

        final result = calculateNextReview(card, SrsRating.hard);
        // 1.35 - 0.15 = 1.2, should clamp to 1.3
        expect(result.ease, 1.3);
      });

      test('Ease cannot go above 3.0', () {
        var card = SrsCard(
          cardId: 'test',
          unitId: 'unit_01',
          phraseId: 'test',
          front: 'Test',
          back: 'Test',
          audioId: 'test',
          ease: 2.95, // Close to maximum
          intervalDays: 0,
          reps: 0,
        );

        final result = calculateNextReview(card, SrsRating.easy);
        // 2.95 + 0.15 = 3.1, should clamp to 3.0
        expect(result.ease, 3.0);
      });
    });
  });

  group('SrsCard', () {
    test('createId generates stable card ID', () {
      final id = SrsCard.createId('a1', 'unit_01', 'labas');
      expect(id, 'a1:unit_01:labas');
    });

    test('isNew returns true for cards with 0 reps', () {
      final card = SrsCard(
        cardId: 'test',
        unitId: 'unit_01',
        phraseId: 'test',
        front: 'Test',
        back: 'Test',
        audioId: 'test',
        reps: 0,
      );
      expect(card.isNew, true);
    });

    test('isNew returns false for reviewed cards', () {
      final card = SrsCard(
        cardId: 'test',
        unitId: 'unit_01',
        phraseId: 'test',
        front: 'Test',
        back: 'Test',
        audioId: 'test',
        reps: 1,
      );
      expect(card.isNew, false);
    });

    test('serialization round-trip preserves data', () {
      final original = SrsCard(
        cardId: 'a1:unit_01:labas',
        unitId: 'unit_01',
        phraseId: 'labas',
        front: 'Labas',
        back: 'Hello',
        audioId: 'a1_u01_labas',
        ease: 2.7,
        intervalDays: 14,
        dueAt: DateTime(2025, 1, 15),
        lastReviewedAt: DateTime(2025, 1, 1),
        reps: 5,
        lapses: 1,
      );

      final map = original.toMap();
      final restored = SrsCard.fromMap(map);

      expect(restored.cardId, original.cardId);
      expect(restored.unitId, original.unitId);
      expect(restored.phraseId, original.phraseId);
      expect(restored.front, original.front);
      expect(restored.back, original.back);
      expect(restored.audioId, original.audioId);
      expect(restored.ease, original.ease);
      expect(restored.intervalDays, original.intervalDays);
      expect(restored.dueAt, original.dueAt);
      expect(restored.lastReviewedAt, original.lastReviewedAt);
      expect(restored.reps, original.reps);
      expect(restored.lapses, original.lapses);
    });
  });

  group('SrsStats', () {
    test('empty factory creates zero stats', () {
      final stats = SrsStats.empty();
      expect(stats.dueToday, 0);
      expect(stats.totalCards, 0);
      expect(stats.nextDue, null);
    });
  });
}
