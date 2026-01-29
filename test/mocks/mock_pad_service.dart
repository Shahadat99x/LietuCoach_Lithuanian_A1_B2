import 'dart:async';
import 'package:lietucoach/packs/packs.dart';

class MockPadPackService implements PadPackService {
  @override
  bool isEnabled = false;

  final Map<String, PackStatus> statusMap = {};
  final Map<String, String?> pathMap = {};
  final Map<String, int?> sizeMap = {};

  final _progressControllers = <String, StreamController<DownloadProgress>>{};

  @override
  Future<PackStatus> getPackStatus(String packName) async {
    return statusMap[packName] ?? PackStatus.notInstalled;
  }

  @override
  Future<void> requestDownload(String packName) async {
    // Determine target final status
    final target = PackStatus.installed;

    // Simulate progress
    final controller = _getController(packName);
    controller.add(
      DownloadProgress(
        packName: packName,
        bytesDownloaded: 0,
        totalBytes: 100,
        status: PackStatus.downloading,
      ),
    );

    await Future.delayed(Duration(milliseconds: 10));

    controller.add(
      DownloadProgress(
        packName: packName,
        bytesDownloaded: 100,
        totalBytes: 100,
        status: target,
      ),
    );

    statusMap[packName] = target;
  }

  @override
  Stream<DownloadProgress> downloadProgress(String packName) {
    return _getController(packName).stream;
  }

  @override
  Future<String?> getPackPath(String packName) async {
    return pathMap[packName];
  }

  @override
  Future<void> cancelDownload(String packName) async {}

  @override
  Future<int?> getPackSize(String packName) async => sizeMap[packName];

  StreamController<DownloadProgress> _getController(String packName) {
    return _progressControllers.putIfAbsent(
      packName,
      () => StreamController.broadcast(),
    );
  }

  void dispose() {
    for (var c in _progressControllers.values) {
      c.close();
    }
  }
}
