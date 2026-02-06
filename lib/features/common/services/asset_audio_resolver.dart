import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Service to check if audio assets exist in the bundle before playing.
///
/// This avoids "File not found" errors by probing bundle assets directly and
/// caching the results.
class AssetAudioResolver {
  static final AssetAudioResolver _instance = AssetAudioResolver._internal();

  factory AssetAudioResolver() => _instance;

  AssetAudioResolver._internal();

  final Map<String, bool> _existsCache = <String, bool>{};
  final Map<String, Future<bool>> _pendingChecks = <String, Future<bool>>{};
  AssetBundle? _defaultBundle;

  /// Kept for backward compatibility with previous call sites.
  /// No manifest preloading is required; existence is checked lazily.
  Future<void> ensureInitialized(AssetBundle bundle) async {
    _defaultBundle ??= bundle;
    if (kDebugMode) {
      debugPrint('AssetAudioResolver: initialized (lazy mode).');
    }
  }

  /// Checks if the given [assetPath] exists in the bundle asynchronously.
  ///
  /// [assetPath] should be the full path e.g. "assets/audio/roles/..."
  Future<bool> existsAsync(String assetPath, {AssetBundle? bundle}) async {
    final normalizedPath = _normalizePath(assetPath);
    final cached = _existsCache[normalizedPath];
    if (cached != null) {
      return cached;
    }

    final activeBundle = bundle ?? _defaultBundle ?? rootBundle;
    final pending = _pendingChecks[normalizedPath];
    if (pending != null) {
      return pending;
    }

    final checkFuture = _probeAsset(activeBundle, normalizedPath);
    _pendingChecks[normalizedPath] = checkFuture;
    final exists = await checkFuture;
    _existsCache[normalizedPath] = exists;
    _pendingChecks.remove(normalizedPath);

    if (kDebugMode) {
      debugPrint('AssetAudioResolver: "$normalizedPath" exists=$exists');
    }

    return exists;
  }

  Future<List<bool>> existsMany(
    List<String> assetPaths, {
    AssetBundle? bundle,
  }) {
    return Future.wait(
      assetPaths.map((path) => existsAsync(path, bundle: bundle)),
    );
  }

  /// Backward-compatible sync lookup.
  /// Returns cached value only; unknown values default to false.
  bool exists(String assetPath) {
    return _existsCache[_normalizePath(assetPath)] ?? false;
  }

  @visibleForTesting
  void clearCache() {
    _existsCache.clear();
    _pendingChecks.clear();
    _defaultBundle = null;
  }

  Future<bool> _probeAsset(AssetBundle bundle, String assetPath) async {
    try {
      await bundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  String _normalizePath(String assetPath) {
    return assetPath.replaceAll(r'\', '/');
  }
}

/// Global instance
final assetAudioResolver = AssetAudioResolver();
