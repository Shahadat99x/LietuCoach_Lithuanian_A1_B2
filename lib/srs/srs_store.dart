/// SRS Store Interface
///
/// Abstract interface for SRS card persistence.

import 'srs_models.dart';

/// Abstract interface for SRS storage
abstract class SrsStore {
  /// Initialize the store
  Future<void> init();

  /// Get cards that are due for review
  Future<List<SrsCard>> getDueCards({int limit = 10});

  /// Get recently learned cards (not due yet)
  Future<List<SrsCard>> getRecentlyLearned({int limit = 10});

  /// Get total count of all cards
  Future<int> getAllCardsCount();

  /// Get a specific card by ID
  Future<SrsCard?> getCard(String cardId);

  /// Get all cards (for sync)
  Future<List<SrsCard>> getAllCards();

  /// Insert or update cards (upsert)
  Future<void> upsertCards(List<SrsCard> cards);

  /// Update a card after review with rating
  Future<void> updateAfterReview(String cardId, SrsRating rating);

  /// Get SRS statistics
  Future<SrsStats> getStats();

  /// Clear all cards
  Future<void> clearAll();

  /// Dispose resources
  Future<void> dispose();
}
