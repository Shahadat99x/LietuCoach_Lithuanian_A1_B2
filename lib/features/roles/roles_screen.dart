/// Roles Screen - Thematic role packs
///
/// TODO (Post-MVP):
/// - Show available role packs (Traveler, Food Delivery, etc.)
/// - Unlock conditions based on progress
/// - Role-specific lessons

import 'package:flutter/material.dart';
import '../../ui/tokens.dart';
import '../../ui/components/components.dart';
import '../path/path_screen.dart';
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
      title: '$roleTitle is locked',
      message: 'Complete Unit $unlockUnit on Path to unlock this role.',
      actionLabel: 'Go to Path',
      onAction: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PathScreen()));
      },
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
              style: AppSemanticTypography.title.copyWith(
                color: theme.semanticColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSemanticSpacing.space8),
            Text(
              'Real-world conversation scenarios',
              style: AppSemanticTypography.body.copyWith(
                color: theme.semanticColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSemanticSpacing.space24),

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
              unlockHint: 'Finish Unit 3 to unlock',
              onTap: () => _showLockedSheet(context, 'Food Delivery', 3),
            ),
            const SizedBox(height: Spacing.m),

            RoleCard(
              title: 'Student Life',
              description: 'University, schedules, registration',
              icon: Icons.school_rounded,
              status: RoleStatus.locked,
              unlockHint: 'Finish Unit 5 to unlock',
              onTap: () => _showLockedSheet(context, 'Student Life', 5),
            ),
            const SizedBox(height: Spacing.m),

            RoleCard(
              title: 'Workplace',
              description: 'Introductions, meetings, emails',
              icon: Icons.work_rounded,
              status: RoleStatus.locked,
              unlockHint: 'Finish Unit 8 to unlock',
              onTap: () => _showLockedSheet(context, 'Workplace', 8),
            ),

            const SizedBox(height: Spacing.xl),

            ComingSoonCard(
              title: 'More role packs are on the way',
              description: 'New real-world scenarios are added regularly.',
            ),
          ],
        ),
      ),
    );
  }
}
