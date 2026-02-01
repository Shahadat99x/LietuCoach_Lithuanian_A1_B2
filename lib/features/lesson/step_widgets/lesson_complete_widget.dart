/// LessonCompleteWidget - Summary screen after lesson
///
/// Shows score and completion message.

import 'package:flutter/material.dart';
import '../../../content/content.dart';
import '../../../ui/tokens.dart';
import '../../../ui/components/components.dart';

class LessonCompleteWidget extends StatelessWidget {
  final LessonCompleteStep step;
  final int correctCount;
  final int totalCount;
  final VoidCallback onFinish;

  const LessonCompleteWidget({
    super.key,
    required this.step,
    required this.correctCount,
    required this.totalCount,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = totalCount > 0
        ? (correctCount / totalCount * 100).round()
        : 100;
    final isPerfect = correctCount == totalCount;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: Spacing.xl),

            // Celebration Icon (Animated Pop)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 1),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                padding: const EdgeInsets.all(Spacing.xxl),
                decoration: BoxDecoration(
                  color:
                      (isPerfect
                              ? AppColors.success
                              : theme.colorScheme.primary)
                          .withValues(alpha: 0.1), // Subtle glow background
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        (isPerfect
                                ? AppColors.success
                                : theme.colorScheme.primary)
                            .withValues(alpha: 0.3),
                    width: 4,
                  ),
                ),
                child: Icon(
                  isPerfect ? Icons.star_rounded : Icons.check_circle_rounded,
                  size: 80,
                  color: isPerfect
                      ? AppColors.success
                      : theme.colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(height: Spacing.xxl),

            // Calm Semantic Headers
            Text(
              isPerfect ? 'Perfect!' : 'Lesson Complete',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                // Neutral text color (Day: Black, Night: White) - Premium Feel
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: Spacing.m),

            Text(
              isPerfect
                  ? 'You made no mistakes.'
                  : 'You scored $percentage% accuracy.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: Spacing.xxl),

            // Premium Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatCard(
                  icon: Icons.bolt_rounded,
                  value: step.xpEarned,
                  label: 'XP',
                  color: AppColors.secondary, // Amber for XP
                  animateValue: true,
                ),
                const SizedBox(width: Spacing.m),
                _StatCard(
                  icon: Icons.track_changes_rounded,
                  value: percentage,
                  label: 'Accuracy',
                  suffix: '%',
                  color: isPerfect
                      ? AppColors.success
                      : theme.colorScheme.primary,
                ),
              ],
            ),

            const SizedBox(height: Spacing.xxl),

            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.pagePadding,
              ),
              child: PrimaryButton(
                label: 'CONTINUE',
                onPressed: onFinish,
                isFullWidth: true,
              ),
            ),
            const SizedBox(height: Spacing.xl),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final String suffix;
  final Color color;
  final bool animateValue;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.suffix = '',
    required this.color,
    this.animateValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Surface2 (Card Color) used for Premium Cards
    final cardColor = theme.cardTheme.color;

    return Container(
      width: 120,
      padding: const EdgeInsets.all(Spacing.l),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.xl),
        // Subtle Border
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        // Subtle Shadow
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: Spacing.s),

          if (animateValue)
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: value),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutExpo,
              builder: (context, val, child) {
                return Text(
                  '$val$suffix',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                );
              },
            )
          else
            Text(
              '$value$suffix',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),

          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
