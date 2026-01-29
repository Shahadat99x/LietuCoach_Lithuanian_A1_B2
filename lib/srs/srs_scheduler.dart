/// SRS Scheduler - SM-2 style spaced repetition algorithm
///
/// Calculates next review intervals based on rating.

import 'srs_models.dart';

/// Minimum ease factor
const double minEase = 1.3;

/// Maximum ease factor
const double maxEase = 3.0;

/// Default ease factor for new cards
const double defaultEase = 2.5;

/// Ease adjustment per rating
const double easeHardDelta = -0.15;
const double easeEasyDelta = 0.15;

/// First review intervals (days)
const int firstIntervalHard = 1;
const int firstIntervalGood = 3;
const int firstIntervalEasy = 7;

/// Calculate the next review state for a card after rating
SrsCard calculateNextReview(SrsCard card, SrsRating rating) {
  final now = DateTime.now();
  double newEase = card.ease;
  int newInterval;
  int newReps = card.reps;
  int newLapses = card.lapses;

  if (card.isNew) {
    // First review - fixed intervals
    switch (rating) {
      case SrsRating.hard:
        newInterval = firstIntervalHard;
        newEase = _clampEase(card.ease + easeHardDelta);
      case SrsRating.good:
        newInterval = firstIntervalGood;
      // Ease stays the same
      case SrsRating.easy:
        newInterval = firstIntervalEasy;
        newEase = _clampEase(card.ease + easeEasyDelta);
    }
    newReps = 1;
  } else {
    // Subsequent review - interval based on ease
    switch (rating) {
      case SrsRating.hard:
        // Hard: interval * 1.2, ease decreases
        newInterval = (card.intervalDays * 1.2).round().clamp(1, 365 * 2);
        newEase = _clampEase(card.ease + easeHardDelta);
        newLapses = card.lapses + 1;
      case SrsRating.good:
        // Good: interval * ease
        newInterval = (card.intervalDays * card.ease).round().clamp(1, 365 * 2);
      // Ease stays the same
      case SrsRating.easy:
        // Easy: interval * ease * 1.3, ease increases
        newInterval = (card.intervalDays * card.ease * 1.3).round().clamp(
          1,
          365 * 2,
        );
        newEase = _clampEase(card.ease + easeEasyDelta);
    }
    newReps = card.reps + 1;
  }

  // Calculate next due date
  final nextDue = DateTime(
    now.year,
    now.month,
    now.day,
  ).add(Duration(days: newInterval));

  return card.copyWith(
    ease: newEase,
    intervalDays: newInterval,
    dueAt: nextDue,
    lastReviewedAt: now,
    reps: newReps,
    lapses: newLapses,
  );
}

/// Clamp ease to valid range
double _clampEase(double ease) {
  return ease.clamp(minEase, maxEase);
}
