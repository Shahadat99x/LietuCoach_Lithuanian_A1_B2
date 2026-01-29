import 'dart:math';

import '../../content/content.dart';
import '../../progress/progress.dart';
import '../../srs/srs.dart';

enum PracticeMode {
  dailyMix,
  listening,
  hardWords,
}

class PracticeItem {
  final String id;
  final String? unitId;
  final String? lessonId;
  final String ltText;
  final String enText;
  final String audioId;

  const PracticeItem({
    required this.id,
    this.unitId,
    this.lessonId,
    required this.ltText,
    required this.enText,
    required this.audioId,
  });
}

class PracticePlan {
  final PracticeMode mode;
  final int estimatedMinutes;
  final List<SrsCard> itemsFlashcards;
  final List<PracticeItem> itemsListening;

  const PracticePlan({
    required this.mode,
    required this.estimatedMinutes,
    this.itemsFlashcards = const [],
    this.itemsListening = const [],
  });

  bool get isEmpty => itemsFlashcards.isEmpty && itemsListening.isEmpty;
}

class PracticePlanner {
  final SrsStore _srsStore;
  final ProgressStore _progressStore;
  final ContentRepository _contentRepository;

  PracticePlanner({
    SrsStore? srs,
    ProgressStore? progress,
    ContentRepository? content,
  })  : _srsStore = srs ?? srsStore,
        _progressStore = progress ?? progressStore,
        _contentRepository = content ?? ContentRepository();

  /// Build a daily mixed session
  /// Priority: Due Cards -> Recent -> Current Unit -> Hard Words (fallback)
  Future<PracticePlan> planDailyMix({int limit = 10}) async {
    // 1. Get Due Cards
    var dueCards = await _srsStore.getDueCards(limit: limit);
    
    // 2. If not enough due, fill with Recently Learned
    if (dueCards.length < limit) {
      final recent = await _srsStore.getRecentlyLearned(limit: limit - dueCards.length);
      // Avoid duplicates
      final existingIds = dueCards.map((c) => c.cardId).toSet();
      dueCards.addAll(recent.where((c) => !existingIds.contains(c.cardId)));
    }

    // 3. (Optional) If still low, could fetch from content, but for MVP let's stick to SRS items
    // If we have absolutely no cards, we might want to fetch from current unit words
    List<PracticeItem> fallbackItems = [];
    if (dueCards.isEmpty) {
       fallbackItems = await _fetchCurrentUnitItems(limit);
    }

    // LISTENING ITEMS
    // For listening, we re-use the same cards if available, or fetch new ones.
    // Let's take 5 items for listening from the cards we found
    final listeningSource = dueCards.take(5).toList();
    final listeningItems = listeningSource.map((c) => PracticeItem(
      id: c.cardId,
      unitId: c.unitId,
      lessonId: null,
      ltText: c.front,
      enText: c.back,
      audioId: c.audioId,
    )).toList();
    
    // If we fell back to content items, use them
    if (listeningItems.isEmpty && fallbackItems.isNotEmpty) {
       if (fallbackItems.isNotEmpty) {
         listeningItems.addAll(fallbackItems.take(5));
       }
    }

    // Estimate time: 30s per card, 20s per listening item
    final minutes = ((dueCards.length * 30 + listeningItems.length * 20) / 60).ceil();

    return PracticePlan(
      mode: PracticeMode.dailyMix,
      estimatedMinutes: minutes < 1 ? 1 : minutes,
      itemsFlashcards: dueCards,
      itemsListening: listeningItems,
    );
  }

  Future<PracticePlan> planListening({int limit = 10}) async {
    // Prefer cards with audio
    // 1. Due/Recent
    final cards = await _srsStore.getDueCards(limit: limit);
    if (cards.length < limit) {
      final recent = await _srsStore.getRecentlyLearned(limit: limit - cards.length);
       final existingIds = cards.map((c) => c.cardId).toSet();
      cards.addAll(recent.where((c) => !existingIds.contains(c.cardId)));
    }

    // Convert to PracticeItems
    var items = cards.map((c) => PracticeItem(
      id: c.cardId,
      unitId: c.unitId,
      lessonId: null,
      ltText: c.front,
      enText: c.back,
      audioId: c.audioId,
    )).toList();

    // Fallback if no cards
    if (items.isEmpty) {
      items = await _fetchCurrentUnitItems(limit);
    }
    
    // Ensure we limit to request
    if (items.length > limit) items = items.sublist(0, limit);

    final minutes = ((items.length * 20) / 60).ceil();

    return PracticePlan(
      mode: PracticeMode.listening,
      estimatedMinutes: minutes < 1 ? 1 : minutes,
      itemsListening: items,
    );
  }

  Future<PracticePlan> planHardWords({int limit = 10}) async {
    // Get all cards, sort by ease or check stats
    // SrsStore implementation of "getHardCards" might be needed or we filter manually
    // For MVP, we'll fetch all and filter manually (assuming dataset is small) 
    // or rely on SRS "Hard" interval logic if exposed.
    // Let's assume for now we use 'getDueCards' as a proxy or just iterate (inefficient but works for small A1).
    // Better: Add `getHardCards` to SrsStore later. For now, we mock with due cards.
    // Actually, let's implement a simple filter on all cards if exposed, OR just use due.
    
    // Strategy: Just grab due cards for now as "Hard" usually means due sooner.
    final cards = await _srsStore.getDueCards(limit: limit);

    final minutes = ((cards.length * 30) / 60).ceil();

    return PracticePlan(
      mode: PracticeMode.hardWords,
      estimatedMinutes: minutes < 1 ? 1 : minutes,
      itemsFlashcards: cards,
    );
  }

  Future<List<PracticeItem>> _fetchCurrentUnitItems(int limit) async {
    // 1. Find current active unit
    // Since we don't have direct access to "current unit" logic in ProgressStore via public API easily
    // without iterating, let's assume Unit 01 as safest MVP fallback or try to read progress.
    // We can iterate units from unit_01 up.
    
    String targetUnitId = 'unit_01';
    // Ideally we check progress
    // var progress = await _progressStore.getUnitProgress('unit_01');
    // if (progress?.examPassed == true) targetUnitId = 'unit_02';
    // ... simplified exploration
    
    final result = await _contentRepository.loadUnit(targetUnitId);
    if (result.isFailure) return [];
    
    final unit = result.value;
    final items = <PracticeItem>[];
    
    for (var lesson in unit.lessons) {
      for (var step in lesson.steps) {
        if (step is TeachPhraseStep) {
          // Look up item in unit.items
          final itemData = unit.items[step.phraseId];
          if (itemData != null) {
            items.add(PracticeItem(
              id: step.phraseId,
              unitId: unit.id,
              lessonId: lesson.id,
              ltText: itemData.lt,
              enText: itemData.en,
              audioId: itemData.audioId,
            ));
          }
        }
        if (items.length >= limit) break;
      }
      if (items.length >= limit) break;
    }
    
    return items;
  }
}
