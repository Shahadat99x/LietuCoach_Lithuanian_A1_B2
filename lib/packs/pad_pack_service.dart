/// Play Asset Delivery Pack Service
///
/// Abstract interface for managing PAD content packs.
/// Implementations: AndroidPadPackService (prod), StubPadPackService (dev/test).

/// Pack installation status
enum PackStatus {
  /// Pack is installed and ready to use
  installed,

  /// Pack is available for download but not yet installed
  notInstalled,

  /// Pack is currently being downloaded
  downloading,

  /// Download failed - can retry
  failed,

  /// Pack not available on this platform (e.g., non-Android)
  notSupported,

  /// Unknown status
  unknown,
}

/// Download progress for a pack
class DownloadProgress {
  final String packName;
  final int bytesDownloaded;
  final int totalBytes;
  final PackStatus status;

  const DownloadProgress({
    required this.packName,
    required this.bytesDownloaded,
    required this.totalBytes,
    required this.status,
  });

  double get progress => totalBytes > 0 ? bytesDownloaded / totalBytes : 0;

  @override
  String toString() =>
      'DownloadProgress($packName: ${(progress * 100).toStringAsFixed(1)}%)';
}

/// Abstract interface for PAD pack management
abstract class PadPackService {
  /// Whether PAD is enabled and active
  bool get isEnabled;

  /// Get the current status of a pack
  Future<PackStatus> getPackStatus(String packName);

  /// Request download of an on-demand pack
  ///
  /// Returns immediately - use [downloadProgress] to track progress.
  /// Throws if pack doesn't exist or is install-time.
  Future<void> requestDownload(String packName);

  /// Stream of download progress for a pack
  ///
  /// Emits progress updates during download.
  /// Complete when download finishes or fails.
  Stream<DownloadProgress> downloadProgress(String packName);

  /// Get the absolute file system path to an installed pack
  ///
  /// Returns null if pack is not installed.
  /// Path points to the assets root within the pack.
  Future<String?> getPackPath(String packName);

  /// Cancel an in-progress download
  Future<void> cancelDownload(String packName);

  /// Get estimated pack size in bytes (for UI display)
  Future<int?> getPackSize(String packName);
}
