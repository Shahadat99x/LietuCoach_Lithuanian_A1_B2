/// ProgressBar - Simple linear progress indicator

import 'package:flutter/material.dart';
import '../tokens.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.backgroundColor,
    this.progressColor,
    this.borderRadius,
    this.showLabel = false,
  });

  /// Progress value between 0.0 and 1.0
  final double value;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final double? borderRadius;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedValue = value.clamp(0.0, 1.0);

    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? Radii.full),
      child: LinearProgressIndicator(
        value: clampedValue,
        minHeight: height,
        backgroundColor:
            backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(
          progressColor ?? theme.colorScheme.primary,
        ),
      ),
    );

    if (!showLabel) {
      return bar;
    }

    return Row(
      children: [
        Expanded(child: bar),
        const SizedBox(width: Spacing.s),
        Text(
          '${(clampedValue * 100).round()}%',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
