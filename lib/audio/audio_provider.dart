/// AudioProvider - Abstract interface for audio playback
///
/// Provides a clean abstraction layer for audio playback that can be
/// implemented differently for dev (assets) vs production (PAD).

import 'package:flutter/foundation.dart';

/// Audio playback interface
abstract class AudioProvider {
  /// Initialize the audio provider
  Future<void> init();

  /// Play audio by audioId with optional variant
  ///
  /// [audioId] - The audio identifier (e.g., "a1_u01_labas")
  /// [variant] - The speed variant: "normal" (default) or "slow"
  ///
  /// If [variant] is "slow" but the slow file doesn't exist,
  /// falls back to "normal" automatically.
  Future<void> play({required String audioId, String variant = 'normal'});

  /// Stop any currently playing audio
  Future<void> stop();

  /// Whether audio is currently playing
  ValueListenable<bool> get isPlaying;

  /// Dispose resources
  Future<void> dispose();
}

/// Audio path resolver utility
class AudioPathResolver {
  /// Resolve audioId to asset path
  ///
  /// Pattern: assets/audio/{level}/{unitId}/{audioId}_{variant}.ogg
  ///
  /// Example:
  ///   audioId: "a1_u01_labas", variant: "normal"
  ///   -> "assets/audio/a1/unit_01/a1_u01_labas_normal.ogg"
  static String resolveAssetPath({
    required String audioId,
    String variant = 'normal',
  }) {
    // Extract level and unit from audioId pattern: a1_u01_xxx
    // audioId format: {level}_{unit}_{phrase}
    final parts = audioId.split('_');
    if (parts.length < 3) {
      throw ArgumentError('Invalid audioId format: $audioId');
    }

    final level = parts[0]; // e.g., "a1"
    final unitNum = parts[1]; // e.g., "u01"
    final unitId = 'unit_${unitNum.substring(1)}'; // e.g., "unit_01"

    return 'assets/audio/$level/$unitId/${audioId}_$variant.ogg';
  }

  /// Get fallback path (normal variant) if slow doesn't exist
  static String resolveFallbackPath({required String audioId}) {
    return resolveAssetPath(audioId: audioId, variant: 'normal');
  }

  /// Resolve audio path from a pack's root directory
  ///
  /// packRoot: Absolute path to pack assets root
  /// Returns: {packRoot}/audio/{level}/{unitId}/{audioId}_{variant}.ogg
  static String resolveFromPackRoot({
    required String packRoot,
    required String audioId,
    String variant = 'normal',
  }) {
    // Extract level and unit from audioId
    final parts = audioId.split('_');
    if (parts.length < 3) {
      throw ArgumentError('Invalid audioId format: $audioId');
    }

    final level = parts[0];
    final unitNum = parts[1];
    final unitId = 'unit_${unitNum.substring(1)}';

    // Pack root points to assets/, so we append standard structure
    // standard: audio/a1/unit_01/xxx.ogg
    return '$packRoot/audio/$level/$unitId/${audioId}_$variant.ogg';
  }
}
