import 'package:flutter/material.dart';
import '../../../../design_system/glass/glass.dart';
import '../../../../ui/tokens.dart';

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

    return GlassCard(
      preferPerformance: true,
      preset: GlassPreset.frost,
      padding: const EdgeInsets.symmetric(
        vertical: AppSemanticSpacing.space16,
        horizontal: AppSemanticSpacing.space16,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppSemanticTypography.section.copyWith(color: color),
          ),
          const SizedBox(height: AppSemanticSpacing.space8),
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
