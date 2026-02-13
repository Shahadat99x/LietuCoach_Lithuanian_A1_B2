import 'package:flutter/material.dart';
import '../../../../design_system/glass/glass.dart';
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
    final semantic = theme.semanticColors;

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
    final Color backgroundColor;
    final double elevation;
    final double opacity;

    if (!hasContent) {
      backgroundColor = semantic.surfaceElevated;
      elevation = 0.0;
      opacity = AppDisabledStyle.disabledOpacity;
    } else if (isCurrent) {
      backgroundColor = semantic.surfaceCard;
      elevation = 2.5;
      opacity = 1;
    } else if (isLocked) {
      backgroundColor = semantic.surfaceElevated.withValues(alpha: 0.8);
      elevation = 0.0;
      opacity = AppDisabledStyle.lockedOpacity;
    } else {
      backgroundColor = semantic.surfaceCard;
      elevation = 1.2;
      opacity = 1;
    }

    return ScaleButton(
      onTap: hasContent ? onTap : null,
      child: AppCard(
        padding: const EdgeInsets.all(Spacing.m),
        elevation: elevation,
        color: backgroundColor,
        child: Opacity(
          opacity: hasContent ? opacity : AppDisabledStyle.disabledOpacity,
          child: Row(
            children: [
              _buildLeadingIcon(
                context,
                isLocked,
                isCompleted,
                isDownloading,
                hasContent,
              ),
              const SizedBox(width: Spacing.m),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isCurrent) ...[
                          GlassPill(
                            selected: true,
                            minHeight: 0,
                            preferPerformance: true,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSemanticSpacing.space8,
                              vertical: AppSemanticSpacing.space4,
                            ),
                            child: Text(
                              'NEXT',
                              style: AppSemanticTypography.caption.copyWith(
                                color: semantic.textPrimary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSemanticSpacing.space8),
                        ],
                        Expanded(
                          child: Text(
                            hasContent
                                ? '${section.subTitle}: ${section.title}'
                                : '${section.subTitle}: Coming Soon',
                            style: AppSemanticTypography.body.copyWith(
                              fontWeight: isCurrent
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isLocked || !hasContent
                                  ? semantic.textSecondary
                                  : semantic.textPrimary,
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
                        style: AppSemanticTypography.caption.copyWith(
                          color: isCompleted
                              ? semantic.accentPrimary
                              : semantic.textSecondary,
                          fontWeight: isCompleted
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                      ),
                    ] else
                      Text(
                        !hasContent
                            ? 'New content being developed'
                            : 'Unlock previous units to continue',
                        style: AppSemanticTypography.caption.copyWith(
                          color: semantic.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: Spacing.s),

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
    final semantic = theme.semanticColors;

    if (!hasContent) {
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: semantic.surfaceElevated,
          borderRadius: BorderRadius.circular(AppSemanticShape.radiusControl),
          border: Border.all(color: semantic.borderSubtle),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.auto_awesome_rounded,
          size: 24,
          color: semantic.textSecondary,
        ),
      );
    }
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: isLocked
            ? semantic.surfaceElevated
            : (isCompleted ? semantic.successContainer : semantic.chipBg),
        borderRadius: BorderRadius.circular(AppSemanticShape.radiusControl),
        border: Border.all(
          color: isLocked ? semantic.borderSubtle : semantic.borderSubtle,
        ),
      ),
      alignment: Alignment.center,
      child: isDownloading
          ? SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                value: downloadProgress,
                color: semantic.accentPrimary,
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
                  ? semantic.textTertiary
                  : (isCompleted
                        ? semantic.accentPrimary
                        : semantic.accentWarm),
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
    final semantic = theme.semanticColors;

    String label;
    IconData? icon;

    if (isCompleted) {
      label = 'DONE';
      icon = Icons.check_circle;
    } else if (isCurrent) {
      final lessonsDone = section.progressCount >= section.totalCount;
      if (lessonsDone) {
        return GlassPill(
          minHeight: 0,
          selected: true,
          preferPerformance: true,
          onTap: onExamTap,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSemanticSpacing.space12,
            vertical: AppSemanticSpacing.space8,
          ),
          child: Text(
            'EXAM',
            style: AppSemanticTypography.caption.copyWith(
              color: semantic.textPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        );
      }
      label = 'START';
    } else {
      label = 'LOCKED';
    }

    return GlassPill(
      minHeight: 0,
      selected: isCurrent || isCompleted,
      preferPerformance: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSemanticSpacing.space8,
        vertical: AppSemanticSpacing.space4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: semantic.textSecondary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppSemanticTypography.caption.copyWith(
              color: isLocked ? semantic.textTertiary : semantic.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
