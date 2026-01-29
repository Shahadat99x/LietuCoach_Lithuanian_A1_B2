import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/progress/progress.dart';
import 'package:lietucoach/sync/sync_service.dart';

// Test logic for LWW merge for UserStats (Practice Stats) and Certificates
// This simulates the logic inside SyncService without needing Supabase mocking

void main() {
  group('UserStats Sync Logic', () {
    test('UserStats has functioning updatedAt', () {
      final now = DateTime.now();
      final stats = UserStats(updatedAt: now);
      expect(stats.updatedAt, now);
      
      final copy = UserStats.fromMap(stats.toMap());
      expect(copy.updatedAt.isAtSameMomentAs(now), true);
    });

    test('LWW Merge Logic Simulation', () {
      // Setup timeline
      final t0 = DateTime(2025, 1, 1, 10, 0);
      final t1 = DateTime(2025, 1, 1, 11, 0); // Newer

      // Local is older
      final local = UserStats(
        totalXp: 100,
        updatedAt: t0,
      );

      // Remote is newer
      final remote = UserStats(
        totalXp: 200,
        updatedAt: t1,
      );

      // Logic from SyncService:
      // if (local.updatedAt.isBefore(remoteUpdated)) -> Pull (Keep Remote)
      UserStats merged;
      if (local.updatedAt.isBefore(remote.updatedAt)) {
        merged = remote;
      } else {
        merged = local;
      }

      expect(merged.totalXp, 200); // Remote won
    });

    test('LWW Push Logic Simulation', () {
       // Setup timeline
      final t0 = DateTime(2025, 1, 1, 10, 0); // Older
      final t1 = DateTime(2025, 1, 1, 11, 0); // Newer

      // Local is newer
      final local = UserStats(
        totalXp: 300,
        updatedAt: t1,
      );

      // Remote is older
      final remote = UserStats(
        totalXp: 200,
        updatedAt: t0,
      );

      bool shouldPush = false;
      if (local.updatedAt.isAfter(remote.updatedAt)) {
        shouldPush = true;
      }

      expect(shouldPush, true);
    });
  });
}
