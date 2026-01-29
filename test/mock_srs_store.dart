/// Mock SRS Store for testing
///
/// In-memory implementation of SrsStore for tests.

import 'package:lietucoach/srs/srs.dart';

class MockSrsStore implements SrsStore {
  final Map<String, SrsCard> _cards = {};

  @override
  Future<void> init() async {}

  @override
  Future<List<SrsCard>> getDueCards({int limit = 10}) async {
    final now = DateTime.now();
    final dueCards = _cards.values
        .where(
          (card) =>
              card.dueAt.isBefore(now) || card.dueAt.isAtSameMomentAs(now),
        )
        .toList();
    dueCards.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return dueCards.take(limit).toList();
  }

  @override
  Future<List<SrsCard>> getRecentlyLearned({int limit = 10}) async {
    final now = DateTime.now();
    final learned = _cards.values
        .where((card) => card.dueAt.isAfter(now))
        .toList();
    learned.sort(
      (a, b) => b.dueAt.compareTo(a.dueAt),
    ); // Most future first? Or recently reviewed?
    // Recently learned usually means "lastReviewedAt" is recent.
    // Let's sort by updated/lastReviewed desc.
    learned.sort((a, b) {
      final aTime = a.lastReviewedAt ?? a.updatedAt;
      final bTime = b.lastReviewedAt ?? b.updatedAt;
      return bTime.compareTo(aTime);
    });
    return learned.take(limit).toList();
  }

  @override
  Future<SrsCard?> getCard(String cardId) async {
    return _cards[cardId];
  }

  @override
  Future<int> getAllCardsCount() async {
    return _cards.length;
  }

  @override
  Future<List<SrsCard>> getAllCards() async {
    return _cards.values.toList();
  }

  @override
  Future<void> upsertCards(List<SrsCard> cards) async {
    for (final card in cards) {
      _cards[card.cardId] = card;
    }
  }

  @override
  Future<void> updateAfterReview(String cardId, SrsRating rating) async {
    final card = _cards[cardId];
    if (card == null) return;

    final updatedCard = calculateNextReview(card, rating);
    _cards[cardId] = updatedCard;
  }

  @override
  Future<SrsStats> getStats() async {
    final now = DateTime.now();
    final dueCards = _cards.values
        .where(
          (card) =>
              card.dueAt.isBefore(now) || card.dueAt.isAtSameMomentAs(now),
        )
        .toList();

    final futureCards = _cards.values
        .where((card) => card.dueAt.isAfter(now))
        .toList();
    futureCards.sort((a, b) => a.dueAt.compareTo(b.dueAt));

    return SrsStats(
      dueToday: dueCards.length,
      totalCards: _cards.length,
      nextDue: futureCards.isNotEmpty ? futureCards.first.dueAt : null,
    );
  }

  @override
  Future<void> clearAll() async {
    _cards.clear();
  }

  @override
  Future<void> dispose() async {}
}
