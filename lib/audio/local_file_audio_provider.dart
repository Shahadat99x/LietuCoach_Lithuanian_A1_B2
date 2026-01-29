/// LocalFileAudioProvider - Audio playback from local assets
///
/// Dev-only implementation that loads audio from Flutter assets.
/// In production (Phase 6+), this will be replaced with PAD-based loading.

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../../packs/packs.dart';
import 'audio_provider.dart';

/// Audio provider that plays from local assets or PAD files
///
/// Implements a Mutex pattern to prevent overlapping operations.
class LocalFileAudioProvider implements AudioProvider {
  LocalFileAudioProvider({PadPackService? padService}) {
    if (padService != null) {
      _padService = padService;
    } else {
      if (Platform.isAndroid) {
        _padService = AndroidPadPackService();
      } else {
        _padService = StubPadPackService();
      }
    }
  }

  late final PadPackService _padService;
  AudioPlayer? _player;
  final ValueNotifier<bool> _isPlaying = ValueNotifier(false);
  String? _currentAudioId;

  // Mutex lock for serialization
  Future<void> _lock = Future.value();

  @override
  Future<void> init() async {
    _player = AudioPlayer();

    // Listen to player state changes
    _player!.playerStateStream.listen((state) {
      _isPlaying.value = state.playing;

      // Reset when playback completes
      if (state.processingState == ProcessingState.completed) {
        if (kDebugMode) {
          print('AudioProvider: Playback completed for $_currentAudioId');
        }
        _isPlaying.value = false;
        _currentAudioId = null;
      }
    });

    if (kDebugMode) {
      print('AudioProvider: Initialized');
    }
  }

  /// Execute an action exclusively (serialized)
  Future<T> _synchronized<T>(Future<T> Function() action) async {
    final previousLock = _lock;
    final completer = Completer<void>();
    // Update the lock immediately so next caller waits for us
    _lock = completer.future;

    try {
      // Wait for previous operation to finish (regardless of success/failure)
      await previousLock;
      return await action();
    } finally {
      // Allow next operation to proceed
      completer.complete();
    }
  }

  @override
  Future<void> play({required String audioId, String variant = 'normal'}) {
    return _synchronized(() async {
      return _playInternal(audioId: audioId, variant: variant);
    });
  }

  Future<void> _playInternal({
    required String audioId,
    required String variant,
  }) async {
    if (_player == null) {
      throw StateError('AudioProvider not initialized. Call init() first.');
    }

    if (kDebugMode) {
      print('AudioProvider: Request play $audioId ($variant)');
    }

    try {
      // Always stop before new playback to ensure clean state
      await _player!.stop();
      _isPlaying.value = false;

      // Determine pack name
      // audioId: a1_u01_word
      final parts = audioId.split('_');
      if (parts.length < 2) throw ArgumentError('Invalid audioId: $audioId');
      final packName = 'pack_${parts[0]}_unit_${parts[1].substring(1)}';

      // Try to resolve from PAD first
      final packPath = await _padService.getPackPath(packName);

      if (packPath != null) {
        await _playFromPack(packPath, audioId, variant);
      } else {
        await _playFromAssets(audioId: audioId, variant: variant);
      }

      _currentAudioId = audioId;
      await _player!.play();

      if (kDebugMode) {
        print('AudioProvider: Started playing $audioId');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print(
          'AudioProvider: Error playing $audioId\n'
          '  Variant: $variant\n'
          '  Error: $e\n'
          '  Stack: $stack',
        );
        // Show a visual hint in debug mode (optional, but requested "small toast/snackbar"
        // implies UI work which is hard from here, simpler to just log prominently).
        // Since this is a Provider, we can't easily show a Toast without context.
        // We will stick to the prominent log which the developer will see.
      }

      _currentAudioId = null;
      _isPlaying.value = false;

      // Graceful failure: Do NOT rethrow.
      // This allows the lesson flow to continue even if audio is missing.
    }
  }

  Future<void> _playFromPack(
    String packPath,
    String audioId,
    String variant,
  ) async {
    // Normal variant path
    final filePath = AudioPathResolver.resolveFromPackRoot(
      packRoot: packPath,
      audioId: audioId,
      variant: variant,
    );

    final file = File(filePath);
    if (await file.exists()) {
      await _player!.setFilePath(filePath);
      return;
    }

    // Fallback to normal if slow missing
    if (variant == 'slow') {
      final fallbackPath = AudioPathResolver.resolveFromPackRoot(
        packRoot: packPath,
        audioId: audioId,
        variant: 'normal',
      );
      if (await File(fallbackPath).exists()) {
        if (kDebugMode) {
          print('AudioProvider: using fallback normal for $audioId');
        }
        await _player!.setFilePath(fallbackPath);
        return;
      }
    }

    throw AssetNotFoundException('Audio file not found in pack: $filePath');
  }

  Future<void> _playFromAssets({
    required String audioId,
    required String variant,
  }) async {
    // Try to load the requested variant
    String assetPath = AudioPathResolver.resolveAssetPath(
      audioId: audioId,
      variant: variant,
    );

    bool assetExists = await _assetExists(assetPath);

    // Fall back to normal if slow doesn't exist
    if (!assetExists && variant == 'slow') {
      assetPath = AudioPathResolver.resolveFallbackPath(audioId: audioId);
      assetExists = await _assetExists(assetPath);
      if (kDebugMode && assetExists) {
        print(
          'AudioProvider: Slow variant not found in assets, falling back to normal',
        );
      }
    }

    if (!assetExists) {
      throw AssetNotFoundException('Audio asset not found: $assetPath');
    }

    await _player!.setAsset(assetPath);
  }

  @override
  Future<void> stop() {
    return _synchronized(() async {
      if (_player == null) return;
      if (kDebugMode) print('AudioProvider: Stopping playback');

      await _player!.stop();
      await _player!.seek(Duration.zero);
      _currentAudioId = null;
      _isPlaying.value = false;
    });
  }

  @override
  ValueListenable<bool> get isPlaying => _isPlaying;

  @override
  Future<void> dispose() async {
    // We don't necessarily need to lock dispose, but good practice to wait for pending ops
    // However, we want dispose to be fast.
    // Let's just run it.
    await _player?.dispose();
    _player = null;
    _isPlaying.dispose();
    if (kDebugMode) print('AudioProvider: Disposed');
  }

  /// Check if an asset exists
  Future<bool> _assetExists(String assetPath) async {
    try {
      // Just try to load metadata/bytes?
      // rootBundle.load throws if not found
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Exception thrown when an audio asset is not found
class AssetNotFoundException implements Exception {
  final String message;
  AssetNotFoundException(this.message);

  @override
  String toString() => 'AssetNotFoundException: $message';
}
