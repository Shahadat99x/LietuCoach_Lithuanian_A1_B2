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
    final reduceMotion = AppMotion.reduceMotionOf(context);
    final clampedValue = value.clamp(0.0, 1.0);
    final effectiveProgressColor = progressColor ?? theme.colorScheme.primary;
    final radius = BorderRadius.circular(borderRadius ?? Radii.full);

    final bar = Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: radius,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ClipRRect(
            borderRadius: radius,
            child: AnimatedFractionallySizedBox(
              duration: reduceMotion ? AppMotion.fast : AppMotion.slow,
              curve: AppMotion.curve(context, AppMotion.easeOut),
              alignment: Alignment.centerLeft,
              widthFactor: clampedValue,
              child: Container(
                width: constraints.maxWidth,
                height: height,
                decoration: BoxDecoration(
                  color: effectiveProgressColor,
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.3),
                      offset: const Offset(0, -2),
                      blurRadius: 0,
                      spreadRadius: -2,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    if (!showLabel) {
      return bar;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        bar,
        const SizedBox(height: Spacing.xs),
        Text(
          '${(clampedValue * 100).round()}%',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
