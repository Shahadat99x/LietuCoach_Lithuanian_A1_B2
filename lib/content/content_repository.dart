/// ContentRepository - Loads content packs from assets
///
/// Dev-only implementation that loads from Flutter assets.
/// In Phase 6+, this will use Play Asset Delivery (PAD).

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import '../../packs/packs.dart';
import 'content_source.dart';
import 'models.dart';
import 'content_failure.dart';
import '../debug/debug_state.dart';

/// Repository for loading content packs
class ContentRepository {
  final Map<String, Unit> _unitCache = {};

  // In a real app with DI, this would be injected.
  // For now, we lazily instantiate the platform-appropriate service.
  late final PadPackService _padService;
  final ContentSource? _assetSourceOverride;

  ContentRepository({PadPackService? padService, ContentSource? assetSource})
    : _assetSourceOverride = assetSource {
    if (padService != null) {
      _padService = padService;
    } else {
      // Simple platform check (can be improved)
      if (Platform.isAndroid) {
        _padService = AndroidPadPackService();
      } else {
        _padService = StubPadPackService();
      }
    }
  }

  /// Whether PAD is enabled and active in the underlying service
  bool get isPadEnabled => _padService.isEnabled;

  /// The underlying PAD service (exposed for progress streams etc)
  @visibleForTesting
  PadPackService get padService => _padService;

  /// Load a unit by ID
  ///
  /// Returns cached unit if already loaded.
  /// Tries PAD pack first, then assets fallback.
  Future<Result<Unit, ContentLoadFailure>> loadUnit(String unitId) async {
    if (_unitCache.containsKey(unitId)) {
      return Result.success(_unitCache[unitId]!);
    }

    // 1. Determine pack name from unitId (convention: pack_a1_unit_XX)
    // unitId format: unit_01
    final packName = 'pack_a1_$unitId';

    // 2. Resolve content source
    ContentSource source;
    final packPath = await _padService.getPackPath(packName);

    if (packPath != null) {
      // Pack is installed - load from file system
      source = FileSystemSource(packPath);
    } else {
      // Fallback to assets (dev mode or install-time fallback)
      source = AssetBundleSource();
    }

    // 3. Construct path
    // Relative path consistent across both sources
    final relativePath = 'content/a1/$unitId/unit.json';

    try {
      if (await source.exists(relativePath)) {
        final jsonString = await source.loadString(relativePath);
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final unit = Unit.fromJson(json);
        _unitCache[unitId] = unit;
        return Result.success(unit);
      } else {
        return Result.failure(ContentLoadFailure.notFound(unitId));
      }
    } catch (e) {
      if (e is FlutterError && e.message.contains('Asset not found')) {
        return Result.failure(ContentLoadFailure.notFound(unitId));
      }
      return Result.failure(ContentLoadFailure.unknown(unitId, e.toString()));
    }
  }

  /// Check if a unit is available (installed, in assets, or forced via debug)
  Future<bool> isUnitAvailable(String unitId) async {
    // Debug bypass
    if (DebugState.forceUnlockContent.value) return true;

    final packName = 'pack_a1_$unitId';
    final status = await _padService.getPackStatus(packName);

    if (status == PackStatus.installed) return true;

    // Fallback: Check assets (e.g. Unit 01 bundled or dev mode)
    final relativePath = 'content/a1/$unitId/unit.json';
    final assetSource = _assetSourceOverride ?? AssetBundleSource();
    return await assetSource.exists(relativePath);
  }

  /// Request download for a unit
  Future<void> downloadUnit(String unitId) async {
    final packName = 'pack_a1_$unitId';
    await _padService.requestDownload(packName);
  }

  /// Get download stream
  Stream<DownloadProgress> downloadProgress(String unitId) {
    final packName = 'pack_a1_$unitId';
    return _padService.downloadProgress(packName);
  }

  /// Get a specific lesson from a unit
  Future<Lesson?> getLesson(String unitId, String lessonId) async {
    final result = await loadUnit(unitId);
    if (result.isFailure) return null;
    final unit = result.value;
    return unit.lessons.where((l) => l.id == lessonId).firstOrNull;
  }

  /// Clear cached content
  void clearCache() {
    _unitCache.clear();
  }
}

/// Exception thrown when content loading fails
class ContentLoadException implements Exception {
  final String message;
  ContentLoadException(this.message);

  @override
  String toString() => 'ContentLoadException: $message';
}
