import 'package:flutter/material.dart';
import '../../../ui/tokens.dart';
import '../../../ui/components/components.dart';

class WordChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isPlaceholder; // If true, renders as an empty slot (ghost)
  final bool isSelected; // If true, maybe highlighted (optional)

  const WordChip({
    super.key,
    required this.label,
    this.onTap,
    this.isPlaceholder = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isPlaceholder) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.m,
          vertical: Spacing.s + 4, // Match the height of the real chip
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.transparent), // Keep size
        ),
      );
    }

    return ScaleButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.m,
          vertical: Spacing.s + 2,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              offset: const Offset(0, 2),
              blurRadius: 2,
            ),
          ],
        ),
        child: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
