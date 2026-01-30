import 'package:flutter/material.dart';
import '../../practice/practice_stats_service.dart';
import '../../../ui/tokens.dart';
import '../../../ui/components/components.dart';
import '../../../progress/progress.dart';

class PathHeader extends StatelessWidget {
  final VoidCallback? onContinue;
  final String continueLabel;
  final String continueSubLabel;
  final bool isContinueEnabled;
  final Widget? trailing;

  const PathHeader({
    super.key,
    this.onContinue,
    this.continueLabel = 'Continue Learning',
    this.continueSubLabel = 'Next Lesson',
    this.isContinueEnabled = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.pagePadding),
          child: Row(
            // Changed from Column to Row to accommodate trailing widget
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Learning Path', // Could vary by user selected course in future
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: Spacing.xxs),
                    Text(
                      'A1 Level — Beginner',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        const SizedBox(height: Spacing.l),

        // Stats & Action Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.pagePadding),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Continue Card (Main CTA)
                Expanded(
                  flex: 3,
                  child: _ContinueCard(
                    onTap: isContinueEnabled ? onContinue : null,
                    label: continueLabel,
                    subLabel: continueSubLabel,
                  ),
                ),
                const SizedBox(width: Spacing.m),

                // Stats Column
                Expanded(
                  flex: 2,
                  child: AnimatedBuilder(
                    animation: practiceStatsService,
                    builder: (context, _) {
                      return FutureBuilder<UserStats>(
                        future: practiceStatsService.stats,
                        builder: (context, snapshot) {
                          final stats = snapshot.data;
                          final streak = stats?.currentStreak ?? 0;
                          final minutes = stats?.minutesToday ?? 0;
                          final goal = stats?.dailyGoalMinutes ?? 15;
                          final isStreakActive =
                              stats != null &&
                              practiceStatsService.isStreakActive(stats);

                          return Column(
                            children: [
                              // Daily Goal
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.track_changes,
                                  iconColor: theme.colorScheme.primary,
                                  value: '$minutes/$goal',
                                  label: 'min',
                                  progress: (minutes / goal).clamp(0.0, 1.0),
                                ),
                              ),
                              const SizedBox(height: Spacing.xs),
                              // Streak
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.local_fire_department,
                                  iconColor: isStreakActive
                                      ? AppColors.danger
                                      : theme.colorScheme.onSurfaceVariant,
                                  value: '$streak',
                                  label: 'day streak',
                                  isHighlighted: isStreakActive,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ContinueCard extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;
  final String subLabel;

  const _ContinueCard({
    required this.onTap,
    required this.label,
    required this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      onTap: onTap,
      color: colorScheme.primaryContainer,
      padding: const EdgeInsets.all(Spacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.xs),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          const Spacer(),
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Spacing.xxs),
          Text(
            subLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimaryContainer.withOpacity(0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final double? progress;
  final bool isHighlighted;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.progress,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.s,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme
            .colorScheme
            .surfaceContainerHighest, // Use slightly darker/lighter surface
        borderRadius: BorderRadius.circular(Radii.md), // Match other cards
        border: isHighlighted
            ? Border.all(color: iconColor.withOpacity(0.3))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (progress != null) ...[
                  const SizedBox(height: 2),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 3,
                      backgroundColor: theme.colorScheme.surfaceDim,
                      valueColor: AlwaysStoppedAnimation(iconColor),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
