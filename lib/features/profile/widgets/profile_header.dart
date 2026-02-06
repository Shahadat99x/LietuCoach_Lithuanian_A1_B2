import 'package:flutter/material.dart';
import '../../../../design_system/glass/glass.dart';
import '../../../../ui/tokens.dart';
import '../../../../ui/components/components.dart';

class ProfileHeader extends StatelessWidget {
  final String? displayName;
  final String? email;
  final String? avatarUrl;
  final bool isAuthenticated;
  final bool isLoading;
  final VoidCallback onEdit;

  const ProfileHeader({
    super.key,
    required this.displayName,
    required this.email,
    required this.isAuthenticated,
    this.avatarUrl,
    this.isLoading = false,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!isAuthenticated) {
      final semantic = theme.semanticColors;
      return GlassCard(
        preferPerformance: true,
        preset: GlassPreset.frost,
        child: Column(
          children: [
            const SizedBox(height: AppSemanticSpacing.space16),
            Image.asset(
              'assets/branding/logo_mark_1024.png',
              width: 80,
              height: 80,
            ),
            const SizedBox(height: AppSemanticSpacing.space16),
            Text(
              'Create a Profile',
              style: AppSemanticTypography.section.copyWith(
                color: semantic.textPrimary,
              ),
            ),
            const SizedBox(height: AppSemanticSpacing.space12),
            Text(
              'Save your progress and sync across devices.',
              style: AppSemanticTypography.body.copyWith(
                color: semantic.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSemanticSpacing.space24),
            PrimaryButton(
              label: 'Sign In / Register',
              icon: Icons.login_rounded,
              onPressed: onEdit, // Reusing onEdit as sign-in trigger
              isFullWidth: true,
            ),
            const SizedBox(height: AppSemanticSpacing.space16),
          ],
        ),
      );
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: avatarUrl == null
                  ? Text(
                      (displayName ?? 'U').substring(0, 1).toUpperCase(),
                      style: AppSemanticTypography.title.copyWith(
                        color: theme.semanticColors.accentPrimary,
                      ),
                    )
                  : null,
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  size: 14,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.m),
        Text(
          displayName ?? 'User',
          style: AppSemanticTypography.section.copyWith(
            color: theme.semanticColors.textPrimary,
          ),
        ),
        if (email != null)
          Text(
            email!,
            style: AppSemanticTypography.body.copyWith(
              color: theme.semanticColors.textSecondary,
            ),
          ),
      ],
    );
  }
}
