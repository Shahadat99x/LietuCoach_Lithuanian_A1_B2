import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/features/common/services/asset_audio_resolver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssetAudioResolver', () {
    final resolver = AssetAudioResolver();
    const existingRoleAudioPath =
        'assets/audio/roles/traveler/airport/checkin_01.mp3';
    const missingRoleAudioPath =
        'assets/audio/roles/traveler/airport/does_not_exist.mp3';

    setUp(() {
      resolver.clearCache();
    });

    test('existsAsync returns true for bundled role audio asset', () async {
      await resolver.ensureInitialized(rootBundle);

      final exists = await resolver.existsAsync(existingRoleAudioPath);

      expect(exists, isTrue);
    });

    test('existsAsync returns false for missing asset path', () async {
      await resolver.ensureInitialized(rootBundle);

      final exists = await resolver.existsAsync(missingRoleAudioPath);

      expect(exists, isFalse);
    });

    test('cache remains stable across repeated lookups', () async {
      await resolver.ensureInitialized(rootBundle);

      final first = await resolver.existsAsync(existingRoleAudioPath);
      final second = await resolver.existsAsync(existingRoleAudioPath);
      final cachedSyncLookup = resolver.exists(
        r'assets\audio\roles\traveler\airport\checkin_01.mp3',
      );

      expect(first, isTrue);
      expect(second, isTrue);
      expect(cachedSyncLookup, isTrue);
    });
  });
}
