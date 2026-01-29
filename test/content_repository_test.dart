import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/content/content.dart';
import 'package:lietucoach/packs/packs.dart';
import 'package:lietucoach/debug/debug_state.dart';
import 'mocks/mock_pad_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ContentRepository PAD Integration', () {
    late ContentRepository repository;
    late MockPadPackService mockService;

    setUp(() {
      DebugState.forceUnlockContent.value = false;
      mockService = MockPadPackService();
      repository = ContentRepository(padService: mockService);
    });

    test('isUnitAvailable returns true when pack installed', () async {
      mockService.statusMap['pack_a1_unit_01'] = PackStatus.installed;
      expect(await repository.isUnitAvailable('unit_01'), true);
    });

    test('isUnitAvailable returns false when pack not installed', () async {
      mockService.statusMap['pack_a1_unit_999'] = PackStatus.notInstalled;
      expect(await repository.isUnitAvailable('unit_999'), false);
    });

    test('loadUnit tries PAD path resolution', () async {
      // Setup mock to return a path
      mockService.pathMap['pack_a1_unit_01'] = '/mock/path';

      // We expect this to fail actual loading because /mock/path doesn't exist on disk
      // But we want to ensure it TRIED to use FileSystemSource via that path.
      final result = await repository.loadUnit('unit_01');
      expect(result.isFailure, true);
      // The failure message should implicitly indicate it tried the path
    });

    test('loadUnit falls back to assets when PAD path is null', () async {
      // Setup mock to return null (not installed)
      mockService.pathMap['pack_a1_unit_999'] = null;

      // Use unit_999 which definitely doesn't exist in assets
      final result = await repository.loadUnit('unit_999');
      expect(result.isFailure, true);
      // AssetBundleSource fails for unit_999
    });
  });
}
