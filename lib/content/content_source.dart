/// Content Source Abstraction
///
/// Allows loading content from different sources:
/// 1. AssetBundleSource (development / Unit 01 fallback)
/// 2. FileSystemSource (production PAD packs)

import 'dart:io';
import 'package:flutter/services.dart';

/// Abstract source for reading content files
abstract class ContentSource {
  /// Check if a file exists at the given path
  Future<bool> exists(String path);

  /// Load string content from a file
  Future<String> loadString(String path);

  /// Get root prefix for this source (debug only)
  String get rootPrefix;
}

/// Source that reads from Flutter AssetBundle (dev / fallback)
class AssetBundleSource implements ContentSource {
  @override
  String get rootPrefix => 'assets/';

  @override
  Future<bool> exists(String path) async {
    try {
      // AssetManifest is the only way to check existence in assets
      // Optimized: caches manifest after first load if needed,
      // but for now we rely on try-catch load as simple check
      await rootBundle.load('$rootPrefix$path');
      return true;
    } catch (e) {
      if (path.contains('unit_01')) {
        print('Asset check failed for $rootPrefix$path: $e');
      }
      return false;
    }
  }

  @override
  Future<String> loadString(String path) {
    return rootBundle.loadString('$rootPrefix$path');
  }
}

/// Source that reads from local file system (PAD packs)
class FileSystemSource implements ContentSource {
  final String _rootPath;

  FileSystemSource(this._rootPath);

  @override
  String get rootPrefix => _rootPath;

  @override
  Future<bool> exists(String path) {
    // path is relative, join with root
    final file = File('$_rootPath/$path');
    return file.exists();
  }

  @override
  Future<String> loadString(String path) {
    final file = File('$_rootPath/$path');
    return file.readAsString();
  }
}
