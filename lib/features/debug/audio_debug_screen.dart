/// Audio Debug Screen
///
/// Dev-only screen to test audio playback functionality.
/// Shows sample audio clips from Unit 01 with play/stop controls.

import 'package:flutter/material.dart';
import '../../audio/audio.dart';
import '../../ui/tokens.dart';
import '../../ui/components/app_scaffold.dart';
import '../../ui/components/app_card.dart';

class AudioDebugScreen extends StatefulWidget {
  const AudioDebugScreen({super.key});

  static const routePath = '/debug/audio';

  @override
  State<AudioDebugScreen> createState() => _AudioDebugScreenState();
}

class _AudioDebugScreenState extends State<AudioDebugScreen> {
  late final LocalFileAudioProvider _audioProvider;
  bool _isInitialized = false;
  String? _error;
  String? _lastAction;

  // Sample audio items from Unit 01
  static const _sampleAudios = [
    _AudioSample(
      audioId: 'a1_u01_labas',
      label: 'Labas',
      translation: 'Hello',
    ),
    _AudioSample(
      audioId: 'a1_u01_sveikas',
      label: 'Sveikas',
      translation: 'Hi (informal)',
    ),
    _AudioSample(
      audioId: 'a1_u01_viso_gero',
      label: 'Viso gero',
      translation: 'Goodbye',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    _audioProvider = LocalFileAudioProvider();
    try {
      await _audioProvider.init();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize: $e';
      });
    }
  }

  @override
  void dispose() {
    _audioProvider.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String audioId, String variant) async {
    try {
      setState(() {
        _lastAction = 'Playing $audioId ($variant)...';
        _error = null;
      });
      await _audioProvider.play(audioId: audioId, variant: variant);
      setState(() {
        _lastAction = 'Playing: $audioId ($variant)';
      });
    } catch (e) {
      setState(() {
        _error = 'Playback error: $e';
        _lastAction = null;
      });
    }
  }

  Future<void> _stopAudio() async {
    await _audioProvider.stop();
    setState(() {
      _lastAction = 'Stopped';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: Spacing.m),
        children: [
          // Header
          Text(
            '🔊 Audio Debug',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: Spacing.s),
          Text(
            'Test audio playback from assets',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.l),

          // Status card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _isInitialized ? Icons.check_circle : Icons.pending,
                      color: _isInitialized
                          ? AppColors.success
                          : theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: Spacing.s),
                    Text(
                      _isInitialized ? 'Audio Ready' : 'Initializing...',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: Spacing.s),
                  Text(
                    _error!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ],
                if (_lastAction != null) ...[
                  const SizedBox(height: Spacing.s),
                  ValueListenableBuilder<bool>(
                    valueListenable: _audioProvider.isPlaying,
                    builder: (context, isPlaying, _) {
                      return Row(
                        children: [
                          if (isPlaying)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          if (isPlaying) const SizedBox(width: Spacing.s),
                          Expanded(
                            child: Text(
                              _lastAction!,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: Spacing.l),

          // Audio samples
          Text(
            'Sample Audio',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: Spacing.m),

          ..._sampleAudios.map((sample) => Padding(
                padding: const EdgeInsets.only(bottom: Spacing.m),
                child: _AudioSampleCard(
                  sample: sample,
                  isEnabled: _isInitialized,
                  onPlayNormal: () => _playAudio(sample.audioId, 'normal'),
                  onPlaySlow: () => _playAudio(sample.audioId, 'slow'),
                  onStop: _stopAudio,
                ),
              )),

          const SizedBox(height: Spacing.l),

          // Global stop button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isInitialized ? _stopAudio : null,
              icon: const Icon(Icons.stop),
              label: const Text('Stop All'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: Spacing.xl),

          // Dev note
          Container(
            padding: const EdgeInsets.all(Spacing.m),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ℹ️ Dev-only screen',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  'Audio files are loaded from assets/audio/. '
                  'In production, PAD will provide these files.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioSample {
  final String audioId;
  final String label;
  final String translation;

  const _AudioSample({
    required this.audioId,
    required this.label,
    required this.translation,
  });
}

class _AudioSampleCard extends StatelessWidget {
  final _AudioSample sample;
  final bool isEnabled;
  final VoidCallback onPlayNormal;
  final VoidCallback onPlaySlow;
  final VoidCallback onStop;

  const _AudioSampleCard({
    required this.sample,
    required this.isEnabled,
    required this.onPlayNormal,
    required this.onPlaySlow,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sample.label,
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      sample.translation,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.m),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isEnabled ? onPlayNormal : null,
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Normal'),
                ),
              ),
              const SizedBox(width: Spacing.s),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isEnabled ? onPlaySlow : null,
                  icon: const Icon(Icons.slow_motion_video, size: 18),
                  label: const Text('Slow'),
                ),
              ),
              const SizedBox(width: Spacing.s),
              IconButton(
                onPressed: isEnabled ? onStop : null,
                icon: const Icon(Icons.stop),
                tooltip: 'Stop',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
