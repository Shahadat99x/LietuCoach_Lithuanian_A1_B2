import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/features/certificate/certificate_repository.dart';
import 'package:lietucoach/features/profile/services/local_account_data_wiper.dart';
import 'package:lietucoach/features/roles/service/role_progress_service.dart';
import 'package:lietucoach/progress/progress.dart';
import 'package:lietucoach/srs/srs.dart';
import 'package:lietucoach/sync/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeProgressStore implements ProgressStore {
  bool cleared = false;

  @override
  Future<void> clearAll() async {
    cleared = true;
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<bool> areAllLessonsCompleted(
    String unitId,
    List<String> lessonIds,
  ) async => false;

  @override
  Future<List<LessonProgress>> getAllLessonProgress() async => [];

  @override
  Future<List<UnitProgress>> getAllUnitProgress() async => [];

  @override
  Future<LessonProgress?> getLessonProgress(
    String unitId,
    String lessonId,
  ) async => null;

  @override
  Future<UserStats> getUserStats() async => UserStats();

  @override
  Future<UnitProgress?> getUnitProgress(String unitId) async => null;

  @override
  Future<List<LessonProgress>> getUnitLessonProgress(String unitId) async => [];

  @override
  Future<void> init() async {}

  @override
  Future<bool> isUnitUnlocked(String unitId) async => true;

  @override
  Future<void> saveLessonProgress(LessonProgress progress) async {}

  @override
  Future<void> saveUnitProgress(UnitProgress progress) async {}

  @override
  Future<void> saveUserStats(UserStats stats) async {}
}

class _FakeSrsStore implements SrsStore {
  bool cleared = false;

  @override
  Future<void> clearAll() async {
    cleared = true;
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<List<SrsCard>> getAllCards() async => [];

  @override
  Future<int> getAllCardsCount() async => 0;

  @override
  Future<SrsCard?> getCard(String cardId) async => null;

  @override
  Future<List<SrsCard>> getDueCards({int limit = 10}) async => [];

  @override
  Future<List<SrsCard>> getRecentlyLearned({int limit = 10}) async => [];

  @override
  Future<SrsStats> getStats() async => SrsStats(dueToday: 0, totalCards: 0);

  @override
  Future<void> init() async {}

  @override
  Future<void> updateAfterReview(String cardId, SrsRating rating) async {}

  @override
  Future<void> upsertCards(List<SrsCard> cards) async {}
}

class _FakeCertificateRepository extends CertificateRepository {
  bool initialized = false;
  bool cleared = false;

  @override
  Future<void> init() async {
    initialized = true;
  }

  @override
  Future<void> clearAll() async {
    cleared = true;
  }
}

class _FakeSyncService extends SyncService {
  bool reset = false;

  @override
  Future<void> resetLocalSyncMeta() async {
    reset = true;
  }
}

class _FakeRoleProgressService extends RoleProgressService {
  bool cleared = false;

  @override
  Future<void> clearAll() async {
    cleared = true;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'seen_onboarding': true});
  });

  test('LocalAccountDataWiper clears local learning and sync data', () async {
    final progress = _FakeProgressStore();
    final srs = _FakeSrsStore();
    final certs = _FakeCertificateRepository();
    final sync = _FakeSyncService();
    final roles = _FakeRoleProgressService();

    final wiper = LocalAccountDataWiper(
      progress: progress,
      srs: srs,
      certificateRepository: certs,
      sync: sync,
      roleProgress: roles,
    );

    final warnings = await wiper.wipeAfterAccountDeletion();
    final prefs = await SharedPreferences.getInstance();

    expect(warnings, isEmpty);
    expect(progress.cleared, isTrue);
    expect(srs.cleared, isTrue);
    expect(certs.initialized, isTrue);
    expect(certs.cleared, isTrue);
    expect(sync.reset, isTrue);
    expect(roles.cleared, isTrue);
    expect(prefs.getBool('seen_onboarding'), isFalse);
  });
}
