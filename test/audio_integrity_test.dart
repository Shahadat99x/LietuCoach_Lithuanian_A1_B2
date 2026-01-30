import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/audio/audio_provider.dart';

void main() {
  test(
    'All audio IDs in unit.json have corresponding assets in assets/audio',
    () async {
      final contentDir = Directory('content/a1');
      if (!contentDir.existsSync()) {
        fail('Content directory not found at ${contentDir.path}');
      }

      final units = contentDir.listSync().whereType<Directory>();
      final missingAssets = <String>[];

      for (final unit in units) {
        final unitId = unit.path
            .split(Platform.pathSeparator)
            .last; // e.g., unit_03
        // Handle ID extraction carefully if path uses / or \
        final cleanUnitId = unit.uri.pathSegments.lastWhere(
          (s) => s.isNotEmpty,
        );

        final jsonFile = File('${unit.path}/unit.json');
        if (!jsonFile.existsSync()) continue;

        final jsonContent = jsonDecode(jsonFile.readAsStringSync());
        final items = jsonContent['items'] as Map<String, dynamic>?;

        if (items == null) continue;

        items.forEach((phraseId, data) {
          if (data is Map && data.containsKey('audioId')) {
            final audioId = data['audioId'] as String;

            // Use the actual resolver to get the expected path
            // Note: AudioPathResolver returns 'assets/audio/...', which matches project root
            final resolvedPath = AudioPathResolver.resolveAssetPath(
              audioId: audioId,
            );

            final assetFile = File(resolvedPath);
            if (!assetFile.existsSync()) {
              missingAssets.add('$unitId: $audioId -> $resolvedPath');
            }
          }
        });
      }

      if (missingAssets.isNotEmpty) {
        fail('Missing audio assets:\n${missingAssets.join('\n')}');
      }
    },
  );
}
