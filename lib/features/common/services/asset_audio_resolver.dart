import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Service to check if audio assets exist in the bundle before playing.
///
/// This avoids "File not found" errors by checking the AssetManifest.
class AssetAudioResolver {
  static final AssetAudioResolver _instance = AssetAudioResolver._internal();

  factory AssetAudioResolver() => _instance;

  AssetAudioResolver._internal();

  Set<String>? _assetKeys;
  bool _initialized = false;

  /// Initializes the resolver by loading the AssetManifest.
  /// Should be called at app startup or before first use.
  Future<void> ensureInitialized(AssetBundle bundle) async {
    if (_initialized) return;

    try {
      final manifestJson = await bundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest =
          jsonDecode(manifestJson) as Map<String, dynamic>;
      _assetKeys = manifest.keys.toSet();
      _initialized = true;
      debugPrint(
        'AssetAudioResolver: Initialized with ${_assetKeys?.length} assets.',
      );
    } catch (e) {
      debugPrint('AssetAudioResolver: Failed to load manifest: $e');
      _assetKeys = {};
    }
  }

  /// Checks if the given [assetPath] exists in the bundle.
  ///
  /// [assetPath] should be the full path e.g. "assets/audio/roles/..."
  bool exists(String assetPath) {
    if (!_initialized) {
      debugPrint(
        'AssetAudioResolver: WARNING - checking "$assetPath" before initialization.',
      );
      // Fail safe or try to assume true? False is safer to prevent crash.
      return false;
    }
    // Normalize path? Flutter assets are usually case-sensitive and separators standard.
    // AssetManifest keys usually strictly match the path in pubspec (or file system).
    return _assetKeys?.contains(assetPath) ?? false;
  }
}

/// Global instance
final assetAudioResolver = AssetAudioResolver();
