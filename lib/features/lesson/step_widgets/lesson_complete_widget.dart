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
    final percentage = totalCount > 0 ? (correctCount / totalCount * 100).round() : 100;
    final isPerfect = correctCount == totalCount;

    return Column(
      children: [
        const SizedBox(height: Spacing.xl),
        
        // Celebration icon
        Container(
          padding: const EdgeInsets.all(Spacing.l),
          decoration: BoxDecoration(
            color: isPerfect 
                ? AppColors.successLight 
                : theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPerfect ? Icons.star : Icons.check_circle,
            size: 64,
            color: isPerfect 
                ? AppColors.success 
                : theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: Spacing.l),
        
        // Completion message
        Text(
          isPerfect ? 'Perfect!' : 'Lesson Complete!',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Spacing.m),
        
        // Score
        if (totalCount > 0) ...[
          Text(
            '$correctCount / $totalCount correct ($percentage%)',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.l),
        ],
        
        // Stats cards
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.book,
                value: '${step.itemsLearned}',
                label: 'Items Learned',
              ),
            ),
            const SizedBox(width: Spacing.m),
            Expanded(
              child: _StatCard(
                icon: Icons.star,
                value: '+${step.xpEarned}',
                label: 'XP Earned',
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.xl),
        
        // Finish button
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            label: 'Continue',
            onPressed: onFinish,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        children: [
          Icon(icon, size: 28, color: theme.colorScheme.primary),
          const SizedBox(height: Spacing.s),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
