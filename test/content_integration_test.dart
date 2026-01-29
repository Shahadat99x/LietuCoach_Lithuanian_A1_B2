import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/content/content.dart';
import 'package:lietucoach/debug/debug_state.dart';
import 'mocks/mock_pad_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Content Integration', () {
    late ContentRepository repository;
    late MockPadPackService mockService;

    setUp(() {
      DebugState.forceUnlockContent.value = false;
      mockService = MockPadPackService();
      // Setup mock to verify we fall back to assets
      mockService.pathMap['pack_a1_unit_03'] = null; // Ensure no PAD override
      repository = ContentRepository(padService: mockService);
    });

    test('Loads A1 Unit 03 from assets', () async {
      // This test confirms that:
      // 1. unit_03.json exists in assets (via pubspec)
      // 2. ContentRepository parses it correctly
      // 3. The content matches expected structure

      final result = await repository.loadUnit('unit_03');

      expect(
        result.isSuccess,
        true,
        reason:
            'Failed to load Unit 03: ${result.isFailure ? result.failure : "unknown"}',
      );

      final unit = result.value;
      expect(unit.id, 'unit_03');
      expect(unit.title, contains('Introductions 2')); // Matches my creation
      expect(unit.lessons.length, 2);
    });
  });
}
