/// AudioButton - Play/pause button for audio (UI only)
///
/// Handles Normal and Slow variants, plus Loading and Playing states.
/// Does not contain playback logic (pure UI).

import 'package:flutter/material.dart';

enum AudioButtonVariant { normal, slow }

class AudioButton extends StatelessWidget {
  const AudioButton({
    super.key,
    required this.onPressed,
    this.variant = AudioButtonVariant.normal,
    this.isPlaying = false,
    this.isLoading = false,
    this.isDisabled = false,
    this.size = 56, // Slightly larger base size
  });

  final VoidCallback? onPressed;
  final AudioButtonVariant variant;
  final bool isPlaying;
  final bool isLoading;
  final bool isDisabled;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSlow = variant == AudioButtonVariant.slow;

    // Colors based on variant
    final Color solidColor = isSlow
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.primaryContainer;

    final Color iconColor = isSlow
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.primary;

    // Reduce size for slow variant if not overridden?
    // Usually slow button is smaller.
    final effectiveSize = isSlow ? size * 0.8 : size;

    return Semantics(
      label: isSlow ? 'Play slowly' : 'Play audio',
      button: true,
      enabled: !isDisabled,
      child: Material(
        color: isDisabled ? theme.colorScheme.surfaceContainerLow : solidColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: (isDisabled || isLoading) ? null : onPressed,
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: effectiveSize,
            height: effectiveSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isPlaying ? Border.all(color: iconColor, width: 2) : null,
            ),
            padding: EdgeInsets.all(effectiveSize * 0.25), // Icon padding
            child: isLoading
                ? CircularProgressIndicator(strokeWidth: 2, color: iconColor)
                : Icon(
                    _getIcon(),
                    color: isDisabled
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                        : iconColor,
                    size: effectiveSize * 0.5,
                  ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    if (isPlaying) {
      return Icons.stop_rounded;
    }
    if (variant == AudioButtonVariant.slow) {
      return Icons.speed_rounded;
    }
    return Icons.volume_up_rounded;
  }
}
