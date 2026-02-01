/// PillChip - Filter/tag chip with pill shape

import 'package:flutter/material.dart';
import '../tokens.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.color,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine effective color
    final effectiveColor = color ?? theme.colorScheme.primary;
    final bgBase = isSelected
        ? effectiveColor.withValues(alpha: 0.2)
        : theme.colorScheme.surfaceContainerHighest;
    final borderBase = isSelected ? effectiveColor : Colors.transparent;
    final textBase = isSelected
        ? effectiveColor
        : theme.colorScheme.onSurfaceVariant;
    final iconBase = isSelected
        ? effectiveColor
        : theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.m,
          vertical: Spacing.s,
        ),
        decoration: BoxDecoration(
          color: bgBase,
          borderRadius: BorderRadius.circular(Radii.full),
          border: Border.all(
            color: borderBase,
            width: isSelected ? 1.5 : 0.0,
            style: isSelected ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18, // Standardize size (18 or 20 for chips)
                color: iconBase,
              ),
              const SizedBox(width: Spacing.xs),
            ],
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                // Use labelMedium for chips
                color: textBase,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
