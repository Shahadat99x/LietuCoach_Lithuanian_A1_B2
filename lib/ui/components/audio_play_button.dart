/// AudioPlayButton - Play/pause button for audio (UI only)
///
/// Does not contain playback logic; that will be added in Phase 1.5.
/// Accepts onPressed callback for parent to handle.

import 'package:flutter/material.dart';
import '../tokens.dart';

class AudioPlayButton extends StatelessWidget {
  const AudioPlayButton({
    super.key,
    required this.onPressed,
    this.isPlaying = false,
    this.size = 48,
    this.showLabel = false,
    this.label,
  });

  final VoidCallback onPressed;
  final bool isPlaying;
  final double size;
  final bool showLabel;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final button = Material(
      color: theme.colorScheme.primaryContainer,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: theme.colorScheme.primary,
            size: size * 0.5,
          ),
        ),
      ),
    );

    if (!showLabel) {
      return button;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button,
        const SizedBox(height: Spacing.xs),
        Text(
          label ?? (isPlaying ? 'Pause' : 'Play'),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Slow audio button variant
class SlowAudioButton extends StatelessWidget {
  const SlowAudioButton({
    super.key,
    required this.onPressed,
    this.isPlaying = false,
    this.size = 40,
  });

  final VoidCallback onPressed;
  final bool isPlaying;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.slow_motion_video_rounded,
            color: theme.colorScheme.onSurfaceVariant,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
