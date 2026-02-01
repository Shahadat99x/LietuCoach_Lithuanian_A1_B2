import 'package:flutter/material.dart';
import '../../../../ui/tokens.dart';
import '../../../../ui/components/components.dart';
import '../models/map_ui_models.dart';

class PathUnitCard extends StatelessWidget {
  final PathMapUnitSection section;
  final bool isAvailable;
  final bool hasContent;
  final double? downloadProgress;
  final VoidCallback? onTap;
  final VoidCallback? onExamTap;

  const PathUnitCard({
    super.key,
    required this.section,
    required this.isAvailable,
    this.hasContent = true,
    this.downloadProgress,
    this.onTap,
    this.onExamTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine overall state
    // A unit is "Completed" if all nodes are completed (or exam passed)
    // A unit is "Current" if any node is current
    // Otherwise "Locked"
    final isCompleted = section.nodes.every(
      (n) => n.state == PathNodeState.completed,
    );
    final isCurrent = section.nodes.any(
      (n) => n.state == PathNodeState.current,
    );
    final isLocked =
        !isCurrent &&
        !isCompleted &&
        section.nodes.every((n) => n.state == PathNodeState.locked);

    final progress = section.progressCount / section.totalCount;
    final isDownloading = downloadProgress != null;

    // Visual Tokens
    // Surface1 for Locked/Completed, Surface2 for Current (Duolingo style highlight)
    final Color backgroundColor;
    final double elevation;

    if (!hasContent) {
      backgroundColor = theme.colorScheme.surfaceVariant.withValues(alpha: 0.3);
      elevation = 0.0;
    } else if (isCurrent) {
      backgroundColor = theme.colorScheme.surfaceContainer;
      elevation = 4.0;
    } else if (isLocked) {
      backgroundColor = theme.colorScheme.surfaceContainerLow.withValues(
        alpha: 0.5,
      );
      elevation = 0.0;
    } else {
      backgroundColor = theme.colorScheme.surfaceContainerLow;
      elevation = 2.0;
    }

    return ScaleButton(
      onTap: hasContent ? onTap : null,
      child: AppCard(
        padding: const EdgeInsets.all(Spacing.m),
        elevation: elevation,
        color: backgroundColor,
        child: Opacity(
          opacity: hasContent ? 1.0 : 0.6,
          child: Row(
            children: [
              // Icon / Badge
              _buildLeadingIcon(
                context,
                isLocked,
                isCompleted,
                isDownloading,
                hasContent,
              ),
              const SizedBox(width: Spacing.m),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hasContent
                                ? '${section.subTitle}: ${section.title}'
                                : '${section.subTitle}: Coming Soon',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isLocked || !hasContent
                                  ? theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.6)
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.xs),

                    if (hasContent && !isLocked) ...[
                      // Progress Bar
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutQuart,
                        builder: (context, value, _) =>
                            ProgressBar(value: value, height: 8),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCompleted
                            ? 'Completed'
                            : '${section.progressCount}/${section.totalCount} Lessons',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isCompleted
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isCompleted
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ] else
                      Text(
                        !hasContent
                            ? 'New content being developed'
                            : 'Unlock previous units to continue',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: Spacing.s),

              // Status Chip
              if (hasContent)
                _buildStatusChip(context, isLocked, isCurrent, isCompleted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(
    BuildContext context,
    bool isLocked,
    bool isCompleted,
    bool isDownloading,
    bool hasContent,
  ) {
    final theme = Theme.of(context);

    if (!hasContent) {
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceDim,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.auto_awesome_rounded,
          size: 24,
          color: theme.colorScheme.outline,
        ),
      );
    }
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: isLocked
            ? theme.colorScheme.surfaceDim
            : (isCompleted
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.secondaryContainer),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      alignment: Alignment.center,
      child: isDownloading
          ? SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                value: downloadProgress,
                color: theme.colorScheme.primary,
              ),
            )
          : Icon(
              isLocked
                  ? Icons.lock_rounded
                  : (isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.play_arrow_rounded),
              size: 28,
              color: isLocked
                  ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                  : (isCompleted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.secondary),
            ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    bool isLocked,
    bool isCurrent,
    bool isCompleted,
  ) {
    final theme = Theme.of(context);

    String label;
    Color chipColor;
    Color textColor;
    IconData? icon;

    if (isCompleted) {
      label = 'DONE';
      chipColor = theme.colorScheme.primaryContainer;
      textColor = theme.colorScheme.primary;
      icon = Icons.check_circle;
    } else if (isCurrent) {
      // Option to take exam if lessons are done
      final lessonsDone = section.progressCount >= section.totalCount;
      if (lessonsDone) {
        return ScaleButton(
          onTap: onExamTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(Radii.full),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'EXAM',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
        );
      }
      label = 'START';
      chipColor = theme.colorScheme.secondaryContainer;
      textColor = theme.colorScheme.secondary;
    } else {
      label = 'LOCKED';
      chipColor = theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.3,
      );
      textColor = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
