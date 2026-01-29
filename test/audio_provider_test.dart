/// Audio Provider Tests
///
/// Tests for path resolution and fallback logic.

import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/audio/audio_provider.dart';

void main() {
  group('AudioPathResolver', () {
    test('resolves normal variant path correctly', () {
      final path = AudioPathResolver.resolveAssetPath(
        audioId: 'a1_u01_labas',
        variant: 'normal',
      );

      expect(path, equals('assets/audio/a1/unit_01/a1_u01_labas_normal.ogg'));
    });

    test('resolves slow variant path correctly', () {
      final path = AudioPathResolver.resolveAssetPath(
        audioId: 'a1_u01_sveikas',
        variant: 'slow',
      );

      expect(path, equals('assets/audio/a1/unit_01/a1_u01_sveikas_slow.ogg'));
    });

    test('handles different unit numbers', () {
      final path = AudioPathResolver.resolveAssetPath(
        audioId: 'a1_u05_hello',
        variant: 'normal',
      );

      expect(path, equals('assets/audio/a1/unit_05/a1_u05_hello_normal.ogg'));
    });

    test('handles different levels', () {
      final path = AudioPathResolver.resolveAssetPath(
        audioId: 'a2_u01_phrase',
        variant: 'normal',
      );

      expect(path, equals('assets/audio/a2/unit_01/a2_u01_phrase_normal.ogg'));
    });

    test('resolveFallbackPath returns normal variant', () {
      final path = AudioPathResolver.resolveFallbackPath(
        audioId: 'a1_u01_labas',
      );

      expect(path, equals('assets/audio/a1/unit_01/a1_u01_labas_normal.ogg'));
    });

    test('throws on invalid audioId format', () {
      expect(
        () => AudioPathResolver.resolveAssetPath(
          audioId: 'invalid',
          variant: 'normal',
        ),
        throwsArgumentError,
      );
    });

    test('throws on two-part audioId', () {
      expect(
        () => AudioPathResolver.resolveAssetPath(
          audioId: 'a1_u01',
          variant: 'normal',
        ),
        throwsArgumentError,
      );
    });
  });

  group('AudioPathResolver PAD', () {
    test('resolveFromPackRoot builds correct absolute path', () {
      final path = AudioPathResolver.resolveFromPackRoot(
        packRoot: '/data/app/packs/pack_name',
        audioId: 'a1_u01_labas',
        variant: 'normal',
      );

      expect(
        path,
        equals(
          '/data/app/packs/pack_name/audio/a1/unit_01/a1_u01_labas_normal.ogg',
        ),
      );
    });

    test('resolveFromPackRoot handles slow variant', () {
      final path = AudioPathResolver.resolveFromPackRoot(
        packRoot: '/root',
        audioId: 'a1_u01_test',
        variant: 'slow',
      );

      expect(path, equals('/root/audio/a1/unit_01/a1_u01_test_slow.ogg'));
    });
  });
}
