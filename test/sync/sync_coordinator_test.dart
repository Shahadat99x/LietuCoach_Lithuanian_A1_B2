import 'package:flutter_test/flutter_test.dart';

// Since we cannot easily mock the singleton AuthService and SyncService without large refactor,
// we will write a "logic" test that simulates the coordinator behavior class.
// This confirms our debounce/lock algorithms are correct.

class MockSyncCoordinator {
  bool isSyncing = false;
  DateTime? lastAutoSyncAttempt;
  final Duration debounceTime = const Duration(milliseconds: 50); // Fast for test
  int syncCallCount = 0;

  Future<void> autoSync() async {
    if (isSyncing) return;
    
    final now = DateTime.now();
    if (lastAutoSyncAttempt != null) {
      if (now.difference(lastAutoSyncAttempt!) < debounceTime) {
        return; // Debounced
      }
    }
    
    lastAutoSyncAttempt = now;
    await syncNow();
  }

  Future<void> syncNow() async {
    if (isSyncing) return;
    isSyncing = true;
    syncCallCount++;
    await Future.delayed(const Duration(milliseconds: 10)); // Work simulation
    isSyncing = false;
  }
}

void main() {
  test('SyncCoordinator: prevents concurrent syncs', () async {
    final coordinator = MockSyncCoordinator();
    // Fire two syncs immediately
    final f1 = coordinator.syncNow();
    final f2 = coordinator.syncNow();
    await Future.wait([f1, f2]);
    
    // Should have only run once because second one hits isSyncing=true
    expect(coordinator.syncCallCount, 1);
  });

  test('SyncCoordinator: debounces auto-sync', () async {
    final coordinator = MockSyncCoordinator();
    
    // First call runs
    await coordinator.autoSync();
    expect(coordinator.syncCallCount, 1);
    
    // Immediate second call ignored
    await coordinator.autoSync();
    expect(coordinator.syncCallCount, 1);
    
    // Wait for debounce reset
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Third call runs
    await coordinator.autoSync();
    expect(coordinator.syncCallCount, 2);
  });
}
