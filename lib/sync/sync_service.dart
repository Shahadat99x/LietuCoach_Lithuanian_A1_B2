/// Sync Service for Cloud Synchronization
///
/// Bidirectional sync between local stores and Supabase.
/// Offline-first: local is source of truth, sync is best-effort.

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../auth/auth.dart';
import '../config/env.dart';
import '../progress/progress.dart';
import '../srs/srs.dart';
import '../features/certificate/certificate.dart';

/// Result of a sync operation
class SyncResult {
  final bool success;
  final String message;
  final int pushed;
  final int pulled;

  const SyncResult({
    required this.success,
    required this.message,
    this.pushed = 0,
    this.pulled = 0,
  });

  factory SyncResult.success({int pushed = 0, int pulled = 0}) => SyncResult(
    success: true,
    message: 'Synced $pushed up, $pulled down',
    pushed: pushed,
    pulled: pulled,
  );

  factory SyncResult.failure(String message) =>
      SyncResult(success: false, message: message);
}

/// Sync service singleton
class SyncService extends ChangeNotifier {
  static const String _lastSyncKey = 'lastSyncAt';
  static const String _syncBoxName = 'sync_meta';
  static const Duration _autoSyncDebounce = Duration(seconds: 60);

  Box? _syncBox;
  bool _isSyncing = false;
  DateTime? _lastSyncAt;
  DateTime? _lastAutoSyncAttempt;
  String _statusMessage = 'Idle';

  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncAt => _lastSyncAt;
  String get statusMessage => _statusMessage;

  /// Initialize sync service
  Future<void> init() async {
    _syncBox = await Hive.openBox(_syncBoxName);
    final lastSyncStr = _syncBox?.get(_lastSyncKey) as String?;
    if (lastSyncStr != null) {
      _lastSyncAt = DateTime.tryParse(lastSyncStr);
    }

    // Listen to Auth changes for auto-sync
    authService.addListener(_onAuthChanged);

    // Initial startup check
    if (authService.isAuthenticated) {
      autoSync(reason: 'startup');
    }
  }

  void _onAuthChanged() {
    if (authService.isAuthenticated) {
      // Small delay to ensure session is fully established if needed
      Future.delayed(const Duration(seconds: 1), () {
        autoSync(reason: 'login');
      });
    }
  }

  @override
  void dispose() {
    authService.removeListener(_onAuthChanged);
    super.dispose();
  }

  /// Get Supabase client if configured
  SupabaseClient? get _supabase {
    if (!Env.isSupabaseConfigured) return null;
    return Supabase.instance.client;
  }

  /// Trigger automatic sync with debounce
  Future<void> autoSync({required String reason}) async {
    if (_isSyncing) return;

    final now = DateTime.now();
    if (_lastAutoSyncAttempt != null) {
      final difference = now.difference(_lastAutoSyncAttempt!);
      if (difference < _autoSyncDebounce) {
        debugPrint('Sync: Auto-sync skipped (debounce): $reason');
        return;
      }
    }

    debugPrint('Sync: Auto-sync triggered: $reason');
    _lastAutoSyncAttempt = now;
    await syncNow();
  }

  /// Perform sync now
  Future<SyncResult> syncNow() async {
    if (!Env.isSupabaseConfigured) {
      _statusMessage = 'Config Error';
      notifyListeners();
      return SyncResult.failure('Supabase not configured');
    }

    if (!authService.isAuthenticated) {
      _statusMessage = 'Not Signed In';
      notifyListeners();
      return SyncResult.failure('Not signed in');
    }

    if (_isSyncing) {
      return SyncResult.failure('Sync already in progress');
    }

    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _statusMessage = 'Offline (Pending)';
      notifyListeners();
      debugPrint('Sync: Offline, skipping');
      return SyncResult.failure('Offline - Sync pending');
    }

    _isSyncing = true;
    _statusMessage = 'Syncing...';
    notifyListeners();

    try {
      final userId = authService.currentUser!.id;
      final client = _supabase!;

      int pushed = 0;
      int pulled = 0;

      // Sync lesson progress
      final lessonResult = await _syncLessonProgress(client, userId);
      pushed += lessonResult.pushed;
      pulled += lessonResult.pulled;

      // Sync unit progress
      final unitResult = await _syncUnitProgress(client, userId);
      pushed += unitResult.pushed;
      pulled += unitResult.pulled;

      // Sync SRS cards
      final srsResult = await _syncSrsCards(client, userId);
      pushed += srsResult.pushed;
      pulled += srsResult.pulled;

      // Sync Practice Stats
      final practiceResult = await _syncPracticeStats(client, userId);
      pushed += practiceResult.pushed;
      pulled += practiceResult.pulled;

      // Sync Certificates
      final certResult = await _syncCertificates(client, userId);
      pushed += certResult.pushed;
      pulled += certResult.pulled;

      // Update last sync time
      _lastSyncAt = DateTime.now();
      await _syncBox?.put(_lastSyncKey, _lastSyncAt!.toIso8601String());

      debugPrint('Sync: Complete - pushed $pushed, pulled $pulled');
      _statusMessage = 'Synced';

      return SyncResult.success(pushed: pushed, pulled: pulled);
    } catch (e) {
      debugPrint('Sync: Error - $e');
      _statusMessage = 'Error';
      return SyncResult.failure(e.toString());
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Sync lesson progress
  Future<({int pushed, int pulled})> _syncLessonProgress(
    SupabaseClient client,
    String userId,
  ) async {
    int pushed = 0;
    int pulled = 0;

    // Get local data
    final localItems = await progressStore.getAllLessonProgress();
    final localMap = {for (var p in localItems) p.key: p};

    // Get remote data
    final remoteData = await client
        .from('lesson_progress')
        .select()
        .eq('user_id', userId);

    final remoteMap = <String, Map<String, dynamic>>{};
    for (final row in remoteData) {
      final key = '${row['unit_id']}_${row['lesson_id']}';
      remoteMap[key] = row;
    }

    // Merge: pull remote changes
    for (final entry in remoteMap.entries) {
      final remote = entry.value;
      final local = localMap[entry.key];
      final remoteUpdated = DateTime.parse(remote['updated_at']);

      if (local == null || remoteUpdated.isAfter(local.updatedAt)) {
        // Remote is newer or local doesn't exist - pull
        final merged = LessonProgress(
          unitId: remote['unit_id'],
          lessonId: remote['lesson_id'],
          // completed=true wins (special rule)
          completed:
              (local?.completed ?? false) || (remote['completed'] ?? false),
          score: remote['score'] ?? local?.score ?? 0,
          xpEarned: remote['xp'] ?? local?.xpEarned ?? 0,
          updatedAt: remoteUpdated,
        );
        await progressStore.saveLessonProgress(merged);
        pulled++;
      }
    }

    // Push local changes
    for (final local in localItems) {
      final remoteKey = local.key;
      final remote = remoteMap[remoteKey];

      if (remote == null) {
        // Local only - push
        await _upsertLessonProgress(client, userId, local);
        pushed++;
      } else {
        final remoteUpdated = DateTime.parse(remote['updated_at']);
        if (local.updatedAt.isAfter(remoteUpdated)) {
          // Local is newer - push
          await _upsertLessonProgress(client, userId, local);
          pushed++;
        }
      }
    }

    return (pushed: pushed, pulled: pulled);
  }

  Future<void> _upsertLessonProgress(
    SupabaseClient client,
    String userId,
    LessonProgress progress,
  ) async {
    await client.from('lesson_progress').upsert({
      'user_id': userId,
      'unit_id': progress.unitId,
      'lesson_id': progress.lessonId,
      'completed': progress.completed,
      'score': progress.score,
      'xp': progress.xpEarned,
      'updated_at': progress.updatedAt.toIso8601String(),
    }, onConflict: 'user_id,unit_id,lesson_id');
  }

  /// Sync unit progress
  Future<({int pushed, int pulled})> _syncUnitProgress(
    SupabaseClient client,
    String userId,
  ) async {
    int pushed = 0;
    int pulled = 0;

    // Get local data
    final localItems = await progressStore.getAllUnitProgress();
    final localMap = {for (var p in localItems) p.unitId: p};

    // Get remote data
    final remoteData = await client
        .from('unit_progress')
        .select()
        .eq('user_id', userId);

    final remoteMap = <String, Map<String, dynamic>>{};
    for (final row in remoteData) {
      remoteMap[row['unit_id']] = row;
    }

    // Merge: pull remote changes
    for (final entry in remoteMap.entries) {
      final remote = entry.value;
      final local = localMap[entry.key];
      final remoteUpdated = DateTime.parse(remote['updated_at']);

      if (local == null || remoteUpdated.isAfter(local.updatedAt)) {
        // Remote is newer or local doesn't exist - pull
        final merged = UnitProgress(
          unitId: remote['unit_id'],
          // exam_passed=true wins (special rule)
          examPassed:
              (local?.examPassed ?? false) || (remote['exam_passed'] ?? false),
          examScore: remote['exam_score'] ?? local?.examScore ?? 0,
          updatedAt: remoteUpdated,
        );
        await progressStore.saveUnitProgress(merged);
        pulled++;
      }
    }

    // Push local changes
    for (final local in localItems) {
      final remote = remoteMap[local.unitId];

      if (remote == null) {
        // Local only - push
        await _upsertUnitProgress(client, userId, local);
        pushed++;
      } else {
        final remoteUpdated = DateTime.parse(remote['updated_at']);
        if (local.updatedAt.isAfter(remoteUpdated)) {
          // Local is newer - push
          await _upsertUnitProgress(client, userId, local);
          pushed++;
        }
      }
    }

    return (pushed: pushed, pulled: pulled);
  }

  Future<void> _upsertUnitProgress(
    SupabaseClient client,
    String userId,
    UnitProgress progress,
  ) async {
    await client.from('unit_progress').upsert({
      'user_id': userId,
      'unit_id': progress.unitId,
      'exam_passed': progress.examPassed,
      'exam_score': progress.examScore,
      'updated_at': progress.updatedAt.toIso8601String(),
    }, onConflict: 'user_id,unit_id');
  }

  /// Sync SRS cards
  Future<({int pushed, int pulled})> _syncSrsCards(
    SupabaseClient client,
    String userId,
  ) async {
    int pushed = 0;
    int pulled = 0;

    // Get local data
    final localItems = await srsStore.getAllCards();
    final localMap = {for (var c in localItems) c.cardId: c};

    // Get remote data
    final remoteData = await client
        .from('srs_cards')
        .select()
        .eq('user_id', userId);

    final remoteMap = <String, Map<String, dynamic>>{};
    for (final row in remoteData) {
      remoteMap[row['card_id']] = row;
    }

    // Merge: pull remote changes
    for (final entry in remoteMap.entries) {
      final remote = entry.value;
      final local = localMap[entry.key];
      final remoteUpdated = DateTime.parse(remote['updated_at']);

      if (local == null || remoteUpdated.isAfter(local.updatedAt)) {
        // Remote is newer or local doesn't exist - pull
        final merged = SrsCard(
          cardId: remote['card_id'],
          unitId: remote['unit_id'],
          phraseId: remote['phrase_id'],
          front: remote['front'],
          back: remote['back'],
          audioId: remote['audio_id'],
          ease: (remote['ease'] as num).toDouble(),
          intervalDays: remote['interval_days'],
          dueAt: DateTime.parse(remote['due_at']),
          reps: remote['reps'],
          lapses: remote['lapses'],
          lastReviewedAt: remote['last_reviewed_at'] != null
              ? DateTime.parse(remote['last_reviewed_at'])
              : null,
          updatedAt: remoteUpdated,
        );
        await srsStore.upsertCards([merged]);
        pulled++;
      }
    }

    // Push local changes
    for (final local in localItems) {
      final remote = remoteMap[local.cardId];

      if (remote == null) {
        // Local only - push
        await _upsertSrsCard(client, userId, local);
        pushed++;
      } else {
        final remoteUpdated = DateTime.parse(remote['updated_at']);
        if (local.updatedAt.isAfter(remoteUpdated)) {
          // Local is newer - push
          await _upsertSrsCard(client, userId, local);
          pushed++;
        }
      }
    }

    return (pushed: pushed, pulled: pulled);
  }

  Future<void> _upsertSrsCard(
    SupabaseClient client,
    String userId,
    SrsCard card,
  ) async {
    await client.from('srs_cards').upsert({
      'user_id': userId,
      'card_id': card.cardId,
      'unit_id': card.unitId,
      'phrase_id': card.phraseId,
      'front': card.front,
      'back': card.back,
      'audio_id': card.audioId,
      'ease': card.ease,
      'interval_days': card.intervalDays,
      'due_at': card.dueAt.toIso8601String(),
      'reps': card.reps,
      'lapses': card.lapses,
      'last_reviewed_at': card.lastReviewedAt?.toIso8601String(),
      'updated_at': card.updatedAt.toIso8601String(),
    }, onConflict: 'user_id,card_id');
  }
  // ... (previous methods)

  /// Sync Practice Stats
  Future<({int pushed, int pulled})> _syncPracticeStats(
    SupabaseClient client,
    String userId,
  ) async {
    int pushed = 0;
    int pulled = 0;

    // Get local
    final local = await progressStore.getUserStats();
    debugPrint(
      'Sync: PracticeStats [LOCAL] - streak: ${local.currentStreak}, totalXp: ${local.totalXp}, updated: ${local.updatedAt}',
    );

    // Get remote
    final remoteResponse = await client
        .from('practice_stats')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (remoteResponse != null) {
      debugPrint(
        'Sync: PracticeStats [REMOTE] - streak: ${remoteResponse['streak_count']}, totalXp: ${remoteResponse['total_xp']}, updated: ${remoteResponse['updated_at']}',
      );

      // Merge
      final remoteUpdated = DateTime.parse(remoteResponse['updated_at']);

      // Check if local is effectively "empty" or "default" (no activity)
      // If local is empty but remote has data, valid remote should win regardless of timestamp
      // (because a fresh install creates a default UserStats with DateTime.now())
      final localIsDefault =
          local.currentStreak == 0 &&
          local.totalXp == 0 &&
          local.lessonsCompleted == 0;
      final remoteHasData =
          (remoteResponse['streak_count'] ?? 0) > 0 ||
          (remoteResponse['total_xp'] ?? 0) > 0;

      // If remote is newer OR (local is default AND remote has data)
      if (local.updatedAt.isBefore(remoteUpdated) ||
          (localIsDefault && remoteHasData)) {
        debugPrint(
          'Sync: PracticeStats [DECISION] -> PULL (Remote newer or local default)',
        );

        // Pull
        final merged = UserStats(
          totalXp: remoteResponse['total_xp'],
          currentStreak: remoteResponse['streak_count'],
          lastActivityDate: remoteResponse['last_activity_date'] != null
              ? DateTime.parse(remoteResponse['last_activity_date'])
              : null,
          lessonsCompleted: remoteResponse['lessons_completed'],
          examsCompleted: remoteResponse['exams_completed'],
          dailyGoalMinutes: remoteResponse['daily_goal'] ?? 10,
          updatedAt: remoteUpdated,
        );
        await progressStore.saveUserStats(merged);

        // Log resulting local state
        debugPrint(
          'Sync: PracticeStats [APPLIED] -> streak: ${merged.currentStreak}',
        );
        pulled++;
      } else if (local.updatedAt.isAfter(remoteUpdated)) {
        debugPrint('Sync: PracticeStats [DECISION] -> PUSH (Local newer)');
        // Push
        await _upsertPracticeStats(client, userId, local);
        pushed++;
      } else {
        debugPrint(
          'Sync: PracticeStats [DECISION] -> NO-OP (Timestamps match)',
        );
      }
    } else {
      debugPrint('Sync: PracticeStats [REMOTE] -> None (Empty)');
      // Remote empty, push local if it has data
      if (local.totalXp > 0 || local.currentStreak > 0) {
        debugPrint(
          'Sync: PracticeStats [DECISION] -> PUSH (Remote empty, local has data)',
        );
        await _upsertPracticeStats(client, userId, local);
        pushed++;
      }
    }

    return (pushed: pushed, pulled: pulled);
  }

  Future<void> _upsertPracticeStats(
    SupabaseClient client,
    String userId,
    UserStats stats,
  ) async {
    debugPrint(
      'Sync: PracticeStats [PUSHING] -> streak: ${stats.currentStreak}, goal: ${stats.dailyGoalMinutes}, updated: ${stats.updatedAt}',
    );
    try {
      await client.from('practice_stats').upsert({
        'user_id': userId,
        'streak_count': stats.currentStreak,
        'last_activity_date': stats.lastActivityDate?.toIso8601String(),
        'total_xp': stats.totalXp,
        'daily_goal': stats.dailyGoalMinutes,
        'lessons_completed': stats.lessonsCompleted,
        'exams_completed': stats.examsCompleted,
        'updated_at': stats.updatedAt.toIso8601String(),
      }, onConflict: 'user_id');
      debugPrint('Sync: PracticeStats [PUSH] -> Success');
    } catch (e) {
      debugPrint('Sync: PracticeStats [PUSH] -> FAILED: $e');
      rethrow;
    }
  }

  /// Sync Certificates
  Future<({int pushed, int pulled})> _syncCertificates(
    SupabaseClient client,
    String userId,
  ) async {
    int pushed = 0;
    int pulled = 0;

    // We need access to CertificateRepository.
    // Ideally injected, but for now we instantiate or access singleton if available.
    // Assuming CertificateRepository has basic Hive access.
    final certRepo = CertificateRepository();
    await certRepo.init();
    final localCerts = certRepo.getAllCertificates();
    final localMap = {for (var c in localCerts) c.id: c};

    // Remote
    final remoteData = await client
        .from('certificates')
        .select()
        .eq('user_id', userId);

    final remoteMap = {for (var r in remoteData) r['id'] as String: r};

    // Pull
    for (final entry in remoteMap.entries) {
      final remote = entry.value;
      final local = localMap[entry.key];

      // Certificates are immutable-ish, check existence.
      // If local missing, insert.
      // NOTE: We do NOT push the file path. We mark it as 'cloud_synced' in path?
      // Or just empty path and let UI regenerate?
      if (local == null) {
        final newCert = CertificateModel(
          id: remote['id'],
          level: remote['level'],
          issuedAt: DateTime.parse(remote['issued_at']),
          filePath: '', // Needs regeneration
          learnerName: remote['learner_name'],
        );
        await certRepo.saveCertificate(newCert);
        pulled++;
      }
    }

    // Push
    for (final local in localCerts) {
      if (!remoteMap.containsKey(local.id)) {
        await client.from('certificates').upsert({
          'user_id': userId,
          'id': local.id,
          'level': local.level,
          'issued_at': local.issuedAt.toIso8601String(),
          'learner_name': local.learnerName,
          'updated_at': local.issuedAt
              .toIso8601String(), // Use issuedAt as updated
        });
        pushed++;
      }
    }

    return (pushed: pushed, pulled: pulled);
  }
}

/// Global sync service instance
final syncService = SyncService();

/// Initialize sync service
Future<void> initSyncService() async {
  await syncService.init();
}
