/// Roles Screen - Thematic role packs
///
/// TODO (Post-MVP):
/// - Show available role packs (Traveler, Food Delivery, etc.)
/// - Unlock conditions based on progress
/// - Role-specific lessons

import 'package:flutter/material.dart';
import '../../ui/tokens.dart';
import '../../ui/components/components.dart';

class RolesScreen extends StatelessWidget {
  const RolesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: Spacing.m),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.pagePadding),
            child: Text(
              'Role Packs',
              style: theme.textTheme.headlineLarge,
            ),
          ),
          const SizedBox(height: Spacing.s),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.pagePadding),
            child: Text(
              'Learn vocabulary for specific situations',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: Spacing.l),

          // Role pack cards
          _buildRoleCard(context, 'Traveler', Icons.flight, 'Airport, hotel, directions', true),
          _buildRoleCard(context, 'Food Delivery', Icons.delivery_dining, 'Ordering, addresses, payments', true),
          _buildRoleCard(context, 'Student', Icons.school, 'University, schedules, registration', true),
          _buildRoleCard(context, 'Worker', Icons.work, 'Workplace basics, introductions', true),

          const SizedBox(height: Spacing.l),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.pagePadding),
            child: AppCard(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.construction, color: theme.colorScheme.primary),
                      const SizedBox(width: Spacing.s),
                      Text('Post-MVP TODO', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: Spacing.s),
                  const Text('• Unlock based on A1 progress'),
                  const Text('• Role-specific lesson content'),
                  const Text('• Role completion certificates'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    bool isLocked,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.pagePadding,
        vertical: Spacing.xs,
      ),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isLocked
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(Radii.md),
              ),
              child: Icon(
                icon,
                color: isLocked
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: Spacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isLocked)
              Icon(
                Icons.lock_outline,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}
