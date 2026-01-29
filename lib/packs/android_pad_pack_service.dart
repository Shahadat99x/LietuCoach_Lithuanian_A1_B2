/// Android PAD Pack Service
///
/// Production implementation using Play Asset Delivery APIs via method channel.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'pad_pack_service.dart';

/// Android implementation of PAD pack service using method channel
class AndroidPadPackService implements PadPackService {
  static const _channel = MethodChannel('app.lietucoach/pad');
  static const _eventChannel = EventChannel('app.lietucoach/pad_progress');

  /// Whether to actually use PAD or bypass it.
  /// Defaults to false in debug to avoid native overhead/crashes.
  final bool usePad;

  final Map<String, StreamController<DownloadProgress>> _progressControllers =
      {};

  @override
  bool get isEnabled => usePad;

  AndroidPadPackService({this.usePad = kReleaseMode}) {
    if (usePad) {
      _setupProgressListener();
    }
  }

  void _setupProgressListener() {
    _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is Map) {
        final packName = event['packName'] as String?;
        final bytesDownloaded = event['bytesDownloaded'] as int? ?? 0;
        final totalBytes = event['totalBytes'] as int? ?? 0;
        final statusStr = event['status'] as String? ?? 'unknown';

        if (packName != null && _progressControllers.containsKey(packName)) {
          _progressControllers[packName]!.add(
            DownloadProgress(
              packName: packName,
              bytesDownloaded: bytesDownloaded,
              totalBytes: totalBytes,
              status: _parseStatus(statusStr),
            ),
          );

          // Close controller if download completed or failed
          if (statusStr == 'installed' || statusStr == 'failed') {
            _progressControllers[packName]!.close();
            _progressControllers.remove(packName);
          }
        }
      }
    });
  }

  PackStatus _parseStatus(String status) {
    return switch (status) {
      'installed' => PackStatus.installed,
      'not_installed' => PackStatus.notInstalled,
      'downloading' => PackStatus.downloading,
      'failed' => PackStatus.failed,
      'not_supported' => PackStatus.notSupported,
      _ => PackStatus.unknown,
    };
  }

  @override
  Future<PackStatus> getPackStatus(String packName) async {
    if (!usePad) return PackStatus.notSupported;

    try {
      final result = await _channel.invokeMethod<String>('getPackStatus', {
        'packName': packName,
      });
      return _parseStatus(result ?? 'unknown');
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('PAD getPackStatus error: $e');
      }
      return PackStatus.unknown;
    }
  }

  @override
  Future<void> requestDownload(String packName) async {
    if (!usePad) {
      throw PlatformException(
        code: 'PAD_DISABLED',
        message: 'PAD is disabled in debug mode',
      );
    }

    try {
      await _channel.invokeMethod<void>('requestDownload', {
        'packName': packName,
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('PAD requestDownload error: $e');
      }
      rethrow;
    }
  }

  @override
  Stream<DownloadProgress> downloadProgress(String packName) {
    if (!usePad) {
      return Stream.empty();
    }

    if (!_progressControllers.containsKey(packName)) {
      _progressControllers[packName] =
          StreamController<DownloadProgress>.broadcast();
    }
    return _progressControllers[packName]!.stream;
  }

  @override
  Future<String?> getPackPath(String packName) async {
    if (!usePad) return null;

    try {
      final result = await _channel.invokeMethod<String>('getPackPath', {
        'packName': packName,
      });
      return result;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('PAD getPackPath error: $e');
      }
      return null;
    }
  }

  @override
  Future<void> cancelDownload(String packName) async {
    if (!usePad) return;

    try {
      await _channel.invokeMethod<void>('cancelDownload', {
        'packName': packName,
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('PAD cancelDownload error: $e');
      }
    }
  }

  @override
  Future<int?> getPackSize(String packName) async {
    if (!usePad) return null;

    try {
      final result = await _channel.invokeMethod<int>('getPackSize', {
        'packName': packName,
      });
      return result;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('PAD getPackSize error: $e');
      }
      return null;
    }
  }
}
