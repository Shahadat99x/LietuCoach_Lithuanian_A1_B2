import 'package:flutter/material.dart';
import '../../../../ui/tokens.dart';
import '../../../../ui/components/components.dart';

import '../models/course_unit_config.dart';

class PathUnitCard extends StatefulWidget {
  final CourseUnitConfig config;
  final int index;
  final bool isUnlocked;
  final bool isAvailable;
  final double? downloadProgress; // Passed as value 0.0-1.0
  final int completedLessons;
  final bool examPassed;
  final int? examScore;
  final VoidCallback? onTap;
  final VoidCallback? onExamTap;

  const PathUnitCard({
    super.key,
    required this.config,
    required this.index,
    required this.isUnlocked,
    this.isAvailable = true,
    this.downloadProgress,
    required this.completedLessons,
    required this.examPassed,
    this.examScore,
    this.onTap,
    this.onExamTap,
  });

  @override
  State<PathUnitCard> createState() => _PathUnitCardState();
}

class _PathUnitCardState extends State<PathUnitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isUnlocked) _scaleController.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isUnlocked) _scaleController.forward();
  }

  void _onTapCancel() {
    if (widget.isUnlocked) _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = widget.completedLessons / widget.config.lessonCount;
    final isDownloading = widget.downloadProgress != null;

    final containerColor = widget.isUnlocked
        ? theme.colorScheme.surface
        : theme.colorScheme.surfaceContainerHighest.withOpacity(
            0.5,
          ); // Deprecated opacity, but sticking to existing for now, or use withValues(alpha: 0.5)

    // Fix for deprecated member usage if possible, else ignore
    // color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);

    final elevation = widget.isUnlocked ? 2.0 : 0.0;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleController,
        child: AppCard(
          padding: const EdgeInsets.all(Spacing.m), // 16px
          elevation: elevation,
          color: containerColor,
          child: Row(
            children: [
              // Icon Box
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.isUnlocked
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceDim,
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
                alignment: Alignment.center,
                child: isDownloading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          value: widget.downloadProgress,
                        ),
                      )
                    : Icon(
                        widget.isUnlocked
                            ? Icons.menu_book_rounded
                            : Icons.lock_rounded,
                        size: 24,
                        color: widget.isUnlocked
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
              ),
              const SizedBox(width: Spacing.m),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unit ${widget.index + 1}: ${widget.config.title}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: widget.isUnlocked
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: widget.isUnlocked
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    if (widget.isUnlocked)
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutQuart,
                        builder: (context, value, _) =>
                            ProgressBar(value: value, height: 6),
                      )
                    else
                      Text(
                        'Complete Unit ${widget.index}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: Spacing.s),

              // Trailing Status
              if (widget.isUnlocked) _buildStatusChip(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    if (widget.examPassed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 14, color: AppColors.success),
            const SizedBox(width: 4),
            Text(
              widget.examScore != null ? '${widget.examScore}%' : 'Done',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else if (widget.completedLessons >= widget.config.lessonCount &&
        widget.onExamTap != null) {
      return GestureDetector(
        onTap: widget.onExamTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Take Exam',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else {
      // In Progress or just started
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'In Progress',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
  }
}
