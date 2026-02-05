import 'package:flutter/material.dart';
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
      return AppCard(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        child: Column(
          children: [
            const SizedBox(height: Spacing.m),
            Image.asset(
              'assets/branding/logo_mark_1024.png',
              width: 80,
              height: 80,
            ),
            const SizedBox(height: Spacing.m),
            Text(
              'Create a Profile',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.s),
            const Text(
              'Save your progress and sync across devices.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.l),
            PrimaryButton(
              label: 'Sign In / Register',
              icon: Icons.login_rounded,
              onPressed: onEdit, // Reusing onEdit as sign-in trigger
              isFullWidth: true,
            ),
            const SizedBox(height: Spacing.m),
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
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: theme.colorScheme.primary,
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
                child: const Icon(Icons.edit, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.m),
        Text(
          displayName ?? 'User',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (email != null)
          Text(
            email!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
