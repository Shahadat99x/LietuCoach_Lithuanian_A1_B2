import 'package:flutter/material.dart';
import '../../../../ui/tokens.dart';
import '../../../../ui/components/components.dart';
import '../practice_planner.dart';

class DailyTrainingHero extends StatelessWidget {
  final PracticePlan? plan;
  final VoidCallback onStart;
  final bool isLoading;

  const DailyTrainingHero({
    super.key,
    required this.plan,
    required this.onStart,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = plan?.isEmpty == true;

    return AppCard(
      // Standard Surface2 for calm feel (Step 4)
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: Spacing.s),
              Text(
                'Recommended for you',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.m),

          Text(
            'Daily Training Mix',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Spacing.xs),

          Text(
            isEmpty
                ? 'Complete more lessons to unlock your personalized training mix.'
                : '${plan?.estimatedMinutes ?? 5} min • Review & Listening',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: Spacing.l),

          // Content Chips (Visual flavor)
          if (!isEmpty) ...[
            Wrap(
              spacing: Spacing.s,
              children: [
                AppChip(
                  icon: Icons.refresh_rounded,
                  label: 'Review',
                  color: Colors.orange,
                  isSelected: true, // Highlights with the color
                ),
                AppChip(
                  icon: Icons.headphones_rounded,
                  label: 'Listening',
                  color: Colors.purple,
                  isSelected: true,
                ),
              ],
            ),
            const SizedBox(height: Spacing.l),
          ],

          PrimaryButton(
            label: isEmpty ? 'Continue on Path' : 'Start Session',
            icon: isEmpty ? Icons.map_rounded : Icons.play_arrow_rounded,
            onPressed: isLoading ? null : onStart,
            isLoading: isLoading,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}
