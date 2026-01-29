import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/content/content.dart';
import 'package:lietucoach/packs/packs.dart';
import 'mocks/mock_pad_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ContentRepository PAD Integration', () {
    late ContentRepository repository;
    late MockPadPackService mockService;

    setUp(() {
      mockService = MockPadPackService();
      repository = ContentRepository(padService: mockService);
    });

    test('isUnitAvailable returns true when pack installed', () async {
      mockService.statusMap['pack_a1_unit_01'] = PackStatus.installed;
      expect(await repository.isUnitAvailable('unit_01'), true);
    });

    test('isUnitAvailable returns false when pack not installed', () async {
      mockService.statusMap['pack_a1_unit_01'] = PackStatus.notInstalled;
      expect(await repository.isUnitAvailable('unit_01'), false);
    });

    test('loadUnit tries PAD path resolution', () async {
      // Setup mock to return a path
      mockService.pathMap['pack_a1_unit_01'] = '/mock/path';

      // We expect this to fail actual loading because /mock/path doesn't exist on disk
      // But we want to ensure it TRIED to use FileSystemSource via that path.
      // Since we can't easily mock the internal ContentSource creation without more abstraction,
      // we check if it throws the expected error containing the path.

      try {
        await repository.loadUnit('unit_01');
        fail('Should have thrown ContentLoadException');
      } catch (e) {
        expect(e, isA<ContentLoadException>());
        // Verify it tried to load from the file system source
        expect(e.toString(), contains('FileSystemSource'));
      }
    });

    test('loadUnit falls back to assets when PAD path is null', () async {
      // Setup mock to return null (not installed)
      mockService.pathMap['pack_a1_unit_01'] = null;

      try {
        await repository.loadUnit('unit_01');
        fail('Should have thrown ContentLoadException');
      } catch (e) {
        // Should try AssetBundleSource
        expect(e.toString(), contains('AssetBundleSource'));
      }
    });
  });
}
