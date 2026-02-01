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
    final effectiveProgressColor = progressColor ?? theme.colorScheme.primary;

    final bar = Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius ?? Radii.full),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: clampedValue),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutQuart,
                builder: (context, val, _) {
                  return Container(
                    width: constraints.maxWidth * val,
                    height: height,
                    decoration: BoxDecoration(
                      color: effectiveProgressColor,
                      borderRadius: BorderRadius.circular(
                        borderRadius ?? Radii.full,
                      ),
                      boxShadow: [
                        // Subtle 3D effect (highlight on top part of the bar)
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.3),
                          offset: const Offset(0, -2),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
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
