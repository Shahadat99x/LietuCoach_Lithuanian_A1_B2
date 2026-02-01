import 'package:flutter/material.dart';
import '../../../../ui/tokens.dart';
import '../../../../ui/components/components.dart';

enum RoleStatus { locked, available, completed }

class RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final RoleStatus status;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLocked = status == RoleStatus.locked;
    final isCompleted = status == RoleStatus.completed;

    return ScaleButton(
      onTap: onTap,
      child: AppCard(
        color: isLocked
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : theme.colorScheme.surface,
        child: Row(
          children: [
            // Icon Box
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isLocked
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(Radii.md),
              ),
              child: Icon(
                icon,
                color: isLocked
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: Spacing.m),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isLocked
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Status Icon
            if (isLocked)
              Icon(
                Icons.lock_outline_rounded,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              )
            else if (isCompleted)
              Icon(
                Icons.check_circle_rounded,
                color: Colors.green, // Or theme success color
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}
