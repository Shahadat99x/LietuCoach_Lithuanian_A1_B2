import 'package:flutter/material.dart';
import '../../practice/practice_stats_service.dart';
import '../../../ui/tokens.dart';
import '../../../ui/components/components.dart';
import '../../../progress/progress.dart';

class PathHeader extends StatefulWidget {
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
  State<PathHeader> createState() => _PathHeaderState();
}

class _PathHeaderState extends State<PathHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _enterController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 600,
      ), // Slightly slower for elegance
    );

    _fadeAnimation = CurvedAnimation(
      parent: _enterController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.1), // Slide up from ~10% height
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic),
        );

    // Trigger animation
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Responsive layout decision
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.pagePadding,
                    Spacing.m,
                    Spacing.pagePadding,
                    0, // Reduced bottom padding
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Learning Path',
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
                      if (widget.trailing != null) widget.trailing!,
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.l),

                // Dashboard Content
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.pagePadding,
                  ),
                  child: isWide
                      ? IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _ContinueCard(
                                  onTap: widget.isContinueEnabled
                                      ? widget.onContinue
                                      : null,
                                  label: widget.continueLabel,
                                  subLabel: widget.continueSubLabel,
                                ),
                              ),
                              const SizedBox(width: Spacing.m),
                              Expanded(flex: 2, child: _StatsColumn()),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _ContinueCard(
                              onTap: widget.isContinueEnabled
                                  ? widget.onContinue
                                  : null,
                              label: widget.continueLabel,
                              subLabel: widget.continueSubLabel,
                            ),
                            const SizedBox(height: Spacing.m),
                            _StatsColumn(),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatsColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
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
                stats != null && practiceStatsService.isStreakActive(stats);

            return Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.track_changes,
                    color: theme.colorScheme.primary, // Fixed param name
                    value: '$minutes/$goal',
                    label: 'min',
                    // progress: ... (removed as standard StatCard doesn't support progress bar yet, or add it back)
                  ),
                ),
                const SizedBox(width: Spacing.m),
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department,
                    color: isStreakActive
                        ? AppColors.danger
                        : theme
                              .colorScheme
                              .onSurfaceVariant, // Fixed param name
                    value: '$streak',
                    label: 'streak',
                    // isHighlighted: ... (removed)
                  ),
                ),
              ],
            );
          },
        );
      },
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
    final isDark = theme.brightness == Brightness.dark;

    return ScaleButton(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surfaceContainer
              : Colors.white, // Surface 2
          borderRadius: BorderRadius.circular(Radii.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Left Accent Strip
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: colorScheme.primary, // Solid accent
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.m,
                  vertical: Spacing.s,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Resume Button Pillar
            Padding(
              padding: const EdgeInsets.only(right: Spacing.m),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.m,
                  vertical: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'RESUME',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final double iconSize;
  // final double? progress; // Removed unused
  // final bool? isHighlighted; // Removed unused

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.m,
        vertical: Spacing.m,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: iconSize, color: color),
              const Spacer(),
            ],
          ),
          const SizedBox(height: Spacing.s),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              // Consistent Typography
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              // Consistent Typography
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
