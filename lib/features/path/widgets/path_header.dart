import 'package:flutter/material.dart';
import '../../../design_system/glass/glass.dart';
import '../../practice/practice_stats_service.dart';
import '../../../ui/tokens.dart';
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
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _reduceMotion = false;
    _enterController = AnimationController(
      vsync: this,
      duration: AppMotion.slow,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _enterController,
      curve: const Interval(0.0, 0.7, curve: AppMotion.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, AppMotion.fadeOffsetMedium),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _enterController, curve: AppMotion.easeOut),
        );

    // Trigger animation
    _enterController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = AppMotion.reduceMotionOf(context);
    if (reduceMotion == _reduceMotion) return;
    _reduceMotion = reduceMotion;
    final targetDuration = _reduceMotion ? AppMotion.instant : AppMotion.slow;
    if (_enterController.duration != targetDuration) {
      _enterController.duration = targetDuration;
    }
    if (_reduceMotion) {
      _enterController.value = 1;
    } else if (_enterController.value == 0) {
      _enterController.forward();
    }
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
                              style: AppSemanticTypography.caption.copyWith(
                                color: theme.semanticColors.accentPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSemanticSpacing.space4),
                            Text(
                              'A1 Level — Beginner',
                              style: AppSemanticTypography.title.copyWith(
                                color: theme.semanticColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.trailing != null) widget.trailing!,
                    ],
                  ),
                ),
                const SizedBox(height: AppSemanticSpacing.space24),

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
                        ? theme.semanticColors.danger
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
    return GlassCard(
      onTap: onTap,
      preset: GlassPreset.frost,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(AppSemanticShape.radiusHero),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 80),
        child: Row(
          children: [
            // Left Accent Strip
            Container(width: 6, color: colorScheme.primary),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSemanticSpacing.space16,
                  vertical: AppSemanticSpacing.space12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: AppSemanticTypography.section.copyWith(
                        color: theme.semanticColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subLabel,
                      style: AppSemanticTypography.caption.copyWith(
                        color: theme.semanticColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: Spacing.m),
              child: GlassPill(
                selected: true,
                preferPerformance: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSemanticSpacing.space16,
                  vertical: AppSemanticSpacing.space8,
                ),
                child: Text(
                  'RESUME',
                  style: AppSemanticTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.semanticColors.textPrimary,
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

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      preferPerformance: true,
      preset: GlassPreset.frost,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSemanticSpacing.space16,
        vertical: AppSemanticSpacing.space16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: color),
              const Spacer(),
            ],
          ),
          const SizedBox(height: AppSemanticSpacing.space12),
          Text(
            value,
            style: AppSemanticTypography.section.copyWith(
              color: theme.semanticColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: AppSemanticTypography.caption.copyWith(
              color: theme.semanticColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
