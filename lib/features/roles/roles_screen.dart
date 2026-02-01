/// Roles Screen - Thematic role packs
///
/// TODO (Post-MVP):
/// - Show available role packs (Traveler, Food Delivery, etc.)
/// - Unlock conditions based on progress
/// - Role-specific lessons

import 'package:flutter/material.dart';
import '../../ui/tokens.dart';
import '../../ui/components/components.dart';
import '../path/widgets/lock_bottom_sheet.dart';
import 'widgets/role_card.dart';
import 'role_pack_detail_screen.dart';

class RolesScreen extends StatelessWidget {
  const RolesScreen({super.key});

  void _showLockedSheet(
    BuildContext context,
    String roleTitle,
    int unlockUnit,
  ) {
    LockBottomSheet.show(
      context,
      title: 'Unlock $roleTitle',
      message:
          'Reach Unit $unlockUnit on the Path to unlock\nthis role-playing scenario.',
      actionLabel: 'Got it',
      onAction: () {}, // Optional, or just let default close handle it
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Spacing.pagePadding),
          children: [
            Text(
              'Role Packs',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              'Real-world conversation scenarios',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.l),

            // Role pack cards
            RoleCard(
              title: 'Traveler',
              description: 'Airport, hotel, directions',
              icon: Icons.flight_takeoff_rounded,
              status: RoleStatus.available,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const RolePackDetailScreen(packId: 'traveler_v1'),
                  ),
                );
              },
            ),
            const SizedBox(height: Spacing.m),

            RoleCard(
              title: 'Food Delivery',
              description: 'Ordering, addresses, payments',
              icon: Icons.delivery_dining_rounded,
              status: RoleStatus.locked,
              onTap: () => _showLockedSheet(context, 'Food Delivery', 3),
            ),
            const SizedBox(height: Spacing.m),

            RoleCard(
              title: 'Student Life',
              description: 'University, schedules, registration',
              icon: Icons.school_rounded,
              status: RoleStatus.locked,
              onTap: () => _showLockedSheet(context, 'Student Life', 5),
            ),
            const SizedBox(height: Spacing.m),

            RoleCard(
              title: 'Workplace',
              description: 'Introductions, meetings, emails',
              icon: Icons.work_rounded,
              status: RoleStatus.locked,
              onTap: () => _showLockedSheet(context, 'Workplace', 8),
            ),

            const SizedBox(height: Spacing.xl),

            // Coming Soon / Teaser
            AppCard(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
                  const SizedBox(width: Spacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'More Coming Soon',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'New scenarios added monthly',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
