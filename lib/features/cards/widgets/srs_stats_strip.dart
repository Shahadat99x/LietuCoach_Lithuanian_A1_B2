import 'package:flutter/material.dart';
import '../../../../ui/tokens.dart';
import '../../../../ui/components/components.dart';

class SrsStatsStrip extends StatelessWidget {
  final int dueCount;
  final int totalCount;
  final bool isLoading;

  const SrsStatsStrip({
    super.key,
    required this.dueCount,
    required this.totalCount,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Due Today',
            value: isLoading ? '-' : '$dueCount',
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: Spacing.m),
        Expanded(
          child: _StatCard(
            label: 'Total Cards',
            value: isLoading ? '-' : '$totalCount',
            color: theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.symmetric(
        vertical: Spacing.m,
        horizontal: Spacing.m,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
