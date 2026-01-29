/// Stub PAD Pack Service
///
/// Fallback implementation for non-Android platforms and development.
/// Unit 01 is always "installed", other units return "not supported".

import 'dart:async';
import 'pad_pack_service.dart';

/// Stub implementation for dev/test and non-Android platforms
class StubPadPackService implements PadPackService {
  @override
  bool get isEnabled => false;

  /// Map of pack names to their simulated status
  final Map<String, PackStatus> _packStatus = {
    'pack_a1_unit_01': PackStatus.installed, // Always available for dev
  };

  @override
  Future<PackStatus> getPackStatus(String packName) async {
    return _packStatus[packName] ?? PackStatus.notSupported;
  }

  @override
  Future<void> requestDownload(String packName) async {
    // In stub mode, we can simulate download completion
    if (_packStatus[packName] == PackStatus.notSupported) {
      throw UnsupportedError('Pack $packName not available on this platform');
    }

    // Simulate instant download for dev
    _packStatus[packName] = PackStatus.installed;
  }

  @override
  Stream<DownloadProgress> downloadProgress(String packName) {
    // Return empty stream - downloads are instant in stub
    return Stream.value(
      DownloadProgress(
        packName: packName,
        bytesDownloaded: 100,
        totalBytes: 100,
        status: PackStatus.installed,
      ),
    );
  }

  @override
  Future<String?> getPackPath(String packName) async {
    // In dev mode, return null - use asset bundle fallback
    // This triggers ContentRepository to use AssetBundleSource
    return null;
  }

  @override
  Future<void> cancelDownload(String packName) async {
    // No-op in stub
  }

  @override
  Future<int?> getPackSize(String packName) async {
    // Return placeholder sizes for UI
    return switch (packName) {
      'pack_a1_unit_01' => 1024 * 1024 * 2, // ~2 MB
      'pack_a1_unit_02' => 1024 * 1024 * 3, // ~3 MB
      _ => null,
    };
  }
}
