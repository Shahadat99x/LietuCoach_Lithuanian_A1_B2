import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/content/content.dart';
import 'package:lietucoach/features/practice/practice_planner.dart';
import 'package:lietucoach/progress/progress.dart';
import 'package:lietucoach/srs/srs.dart';

// --- Fakes ---

class FakeSrsStore implements SrsStore {
  List<SrsCard> dueCards = [];
  List<SrsCard> recentCards = [];

  @override
  Future<List<SrsCard>> getDueCards({int limit = 10}) async {
    return dueCards.take(limit).toList();
  }

  @override
  Future<List<SrsCard>> getRecentlyLearned({int limit = 10}) async {
    return recentCards.take(limit).toList();
  }

  @override
  Future<void> init() async {}
  
  @override
  Future<int> getAllCardsCount() async => dueCards.length + recentCards.length;

  // Stubs for unused methods
  @override
  Future<void> clearAll() async {}
  @override
  Future<void> dispose() async {}
  @override
  Future<List<SrsCard>> getAllCards() async => [];
  @override
  Future<SrsCard?> getCard(String cardId) async => null;
  @override
  Future<SrsStats> getStats() async => SrsStats.empty();
  @override
  Future<void> updateAfterReview(String cardId, SrsRating rating) async {}
  @override
  Future<void> upsertCards(List<SrsCard> cards) async {}
}

class FakeProgressStore implements ProgressStore {
  @override
  Future<void> init() async {}
  
  @override
  Future<bool> isUnitUnlocked(String unitId) async => true;
  
  // Stubs for unused methods
  @override
  Future<bool> areAllLessonsCompleted(String unitId, List<String> lessonIds) async => false;
  @override
  Future<void> clearAll() async {}
  @override
  Future<void> dispose() async {}
  @override
  Future<List<LessonProgress>> getAllLessonProgress() async => [];
  @override
  Future<List<UnitProgress>> getAllUnitProgress() async => [];
  @override
  Future<LessonProgress?> getLessonProgress(String unitId, String lessonId) async => null;
  @override
  Future<UnitProgress?> getUnitProgress(String unitId) async => null;
  @override
  Future<List<LessonProgress>> getUnitLessonProgress(String unitId) async => [];
  @override
  Future<UserStats> getUserStats() async => UserStats();
  @override
  Future<void> saveLessonProgress(LessonProgress progress) async {}
  @override
  Future<void> saveUnitProgress(UnitProgress progress) async {}
  @override
  Future<void> saveUserStats(UserStats stats) async {}
}

class FakeContentRepository extends ContentRepository {
  Unit? mockUnit;

  @override
  Future<Result<Unit, ContentLoadFailure>> loadUnit(String unitId) async {
    if (mockUnit != null) {
      return Result.success(mockUnit!);
    }
    return Result.failure(ContentLoadFailure.notFound(unitId));
  }
}

// --- Tests ---

void main() {
  late PracticePlanner planner;
  late FakeSrsStore srsStore;
  late FakeContentRepository contentRepository;

  setUp(() {
    srsStore = FakeSrsStore();
    contentRepository = FakeContentRepository();
    planner = PracticePlanner(
      srs: srsStore,
      progress: FakeProgressStore(),
      content: contentRepository,
    );
  });

  final testCard1 = SrsCard(
    cardId: 'c1',
    unitId: 'u1',
    // lessonId removed
    phraseId: 'p1', // Added phraseId
    front: 'Labas',
    back: 'Hello',
    audioId: 'audio1',
    dueAt: DateTime.now().subtract(const Duration(days: 1)),
    intervalDays: 1,
    ease: 2.5,
  );

  final testCard2 = SrsCard(
    cardId: 'c2',
    unitId: 'u1',
    // lessonId removed
    phraseId: 'p2', // added phraseId
    front: 'Ačiū',
    back: 'Thanks',
    audioId: 'audio2',
    dueAt: DateTime.now().add(const Duration(days: 1)), // Not due
    intervalDays: 1,
    ease: 2.5,
  );

  group('PracticePlanner', () {
    test('planDailyMix picks due cards first', () async {
      srsStore.dueCards = [testCard1];
      
      final plan = await planner.planDailyMix(limit: 5);
      
      expect(plan.mode, PracticeMode.dailyMix);
      expect(plan.itemsFlashcards.length, 1);
      expect(plan.itemsFlashcards.first.cardId, 'c1');
      // Should also have listening item from the same card
      expect(plan.itemsListening.length, 1);
      expect(plan.itemsListening.first.id, 'c1');
    });

    test('planDailyMix fills with recently learned if due is empty', () async {
      srsStore.dueCards = [];
      srsStore.recentCards = [testCard2];
      
      final plan = await planner.planDailyMix(limit: 5);
      
      expect(plan.itemsFlashcards.length, 1);
      expect(plan.itemsFlashcards.first.cardId, 'c2');
    });

    test('planDailyMix falls back to content items if SRS is empty', () async {
      srsStore.dueCards = [];
      srsStore.recentCards = [];
      
      // Mock Unit Content
      contentRepository.mockUnit = Unit(
        id: 'unit_01',
        title: 'Test Unit',
        lessons: [
          Lesson(
            id: 'l1',
            title: 'Lesson 1',
            steps: [
              TeachPhraseStep(phraseId: 'p1'),
            ],
          ),
        ],
        items: {
          'p1': Item(lt: 'Taip', en: 'Yes', audioId: 'audio_p1'),
        },
      );

      final plan = await planner.planDailyMix(limit: 5);
      
      // No flashcards (since we only pull flashcards from SRS cards for now)
      // But we should have listening items from content? 
      // Wait, planner logic says `fallbackItems` are used for LISTENING items if empty.
      // And `dueCards` (flashcards) are only from SRS.
      
      expect(plan.itemsFlashcards.isEmpty, true);
      expect(plan.itemsListening.isNotEmpty, true);
      expect(plan.itemsListening.first.ltText, 'Taip');
    });
    
    test('planListening picks due cards first', () async {
      srsStore.dueCards = [testCard1];
      
      final plan = await planner.planListening(limit: 5);
      
      expect(plan.mode, PracticeMode.listening);
      expect(plan.itemsListening.length, 1);
      expect(plan.itemsListening.first.id, 'c1');
    });

    test('planHardWords picks due cards for MVP', () async {
      srsStore.dueCards = [testCard1];
      
      final plan = await planner.planHardWords(limit: 5);
      
      expect(plan.mode, PracticeMode.hardWords);
      expect(plan.itemsFlashcards.length, 1);
      expect(plan.itemsFlashcards.first.cardId, 'c1');
    });
  });
}
