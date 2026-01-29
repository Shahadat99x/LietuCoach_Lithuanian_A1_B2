/// Local SRS Store (Hive implementation)
///
/// Offline-first persistence for SRS flashcards.

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'srs_models.dart';
import 'srs_store.dart';
import 'srs_scheduler.dart';

const String _srsCardsBox = 'srs_cards';

/// Local implementation using Hive
class LocalSrsStore implements SrsStore {
  Box<Map>? _cardsBox;
  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;

    // Hive should already be initialized by LocalProgressStore
    _cardsBox = await Hive.openBox<Map>(_srsCardsBox);
    _initialized = true;
  }

  void _ensureInit() {
    if (!_initialized) {
      throw StateError('LocalSrsStore not initialized. Call init() first.');
    }
  }

  @override
  Future<List<SrsCard>> getDueCards({int limit = 10}) async {
    _ensureInit();
    final now = DateTime.now();

    final dueCards = _cardsBox!.values
        .map((map) => SrsCard.fromMap(map))
        .where(
          (card) =>
              card.dueAt.isBefore(now) || card.dueAt.isAtSameMomentAs(now),
        )
        .toList();

    // Sort by due date (oldest first)
    dueCards.sort((a, b) => a.dueAt.compareTo(b.dueAt));

    return dueCards.take(limit).toList();
  }

  @override
  Future<List<SrsCard>> getRecentlyLearned({int limit = 10}) async {
    _ensureInit();
    final now = DateTime.now();

    final recentCards = _cardsBox!.values
        .map((map) => SrsCard.fromMap(map))
        .where((card) => card.dueAt.isAfter(now))
        .toList();

    // Sort by most recently reviewed (approximated by due date being furthest? Or actually we should invoke lastReviewDate if we had it. 
    // SrsCard has intervalDays. Higher interval = learned longer ago? No.
    // For "recently learned", we might want items with *short* intervals that are not due.
    // Or simply items that are NOT due.
    // Let's sort by due date ascending (so items due soonest - but after now).
    recentCards.sort((a, b) => a.dueAt.compareTo(b.dueAt));

    return recentCards.take(limit).toList();
  }

  @override
  Future<int> getAllCardsCount() async {
    _ensureInit();
    return _cardsBox!.length;
  }

  @override
  Future<SrsCard?> getCard(String cardId) async {
    _ensureInit();
    final map = _cardsBox!.get(cardId);
    if (map == null) return null;
    return SrsCard.fromMap(map);
  }

  @override
  Future<List<SrsCard>> getAllCards() async {
    _ensureInit();
    return _cardsBox!.values.map((m) => SrsCard.fromMap(m)).toList();
  }

  @override
  Future<void> upsertCards(List<SrsCard> cards) async {
    _ensureInit();
    for (final card in cards) {
      await _cardsBox!.put(card.cardId, card.toMap());
    }
  }

  @override
  Future<void> updateAfterReview(String cardId, SrsRating rating) async {
    _ensureInit();
    final card = await getCard(cardId);
    if (card == null) return;

    final updatedCard = calculateNextReview(card, rating);
    await _cardsBox!.put(cardId, updatedCard.toMap());
  }

  @override
  Future<SrsStats> getStats() async {
    _ensureInit();
    final now = DateTime.now();
    final allCards = _cardsBox!.values.map((m) => SrsCard.fromMap(m)).toList();

    final dueCards = allCards
        .where(
          (card) =>
              card.dueAt.isBefore(now) || card.dueAt.isAtSameMomentAs(now),
        )
        .toList();

    // Find next due card (among non-due cards)
    final futureCards = allCards
        .where((card) => card.dueAt.isAfter(now))
        .toList();
    futureCards.sort((a, b) => a.dueAt.compareTo(b.dueAt));

    return SrsStats(
      dueToday: dueCards.length,
      totalCards: allCards.length,
      nextDue: futureCards.isNotEmpty ? futureCards.first.dueAt : null,
    );
  }

  @override
  Future<void> clearAll() async {
    _ensureInit();
    await _cardsBox!.clear();
  }

  @override
  Future<void> dispose() async {
    await _cardsBox?.close();
    _initialized = false;
  }
}

/// Global singleton for SRS store
SrsStore? _srsInstance;

SrsStore get srsStore {
  _srsInstance ??= LocalSrsStore();
  return _srsInstance!;
}

/// Allow injecting a mock for testing
@visibleForTesting
void setMockSrsStore(SrsStore? mock) {
  _srsInstance = mock;
}

Future<void> initSrsStore() async {
  await srsStore.init();
}

/// Notifier for SRS state changes
/// Listen to this to refresh UI when cards are added/updated
class SrsNotifier extends ChangeNotifier {
  void notifyCardsChanged() {
    notifyListeners();
  }
}

final SrsNotifier srsNotifier = SrsNotifier();

/// Helper to notify after card changes
Future<void> notifySrsCardsChanged() async {
  srsNotifier.notifyCardsChanged();
}
