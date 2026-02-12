import 'package:flutter/material.dart';
import '../common/services/external_links_service.dart';
import 'widgets/settings_section_card.dart';

import '../../ui/tokens.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;

    return Scaffold(
      appBar: AppBar(title: const Text('About LietuCoach')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Spacing.pagePadding),
          children: [
            // App Icon and Version
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/branding/logo_mark_1024.png',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: Spacing.m),
                  Text(
                    'LietuCoach',
                    style: AppSemanticTypography.title.copyWith(
                      color: semantic.textPrimary,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    'Version 1.0.0',
                    style: AppSemanticTypography.body.copyWith(
                      color: semantic.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.xl),

            // Summary
            Text(
              'LietuCoach is a free, offline-friendly Lithuanian language learning app.',
              style: AppSemanticTypography.body.copyWith(
                color: semantic.textPrimary,
              ),
            ),
            const SizedBox(height: Spacing.m),
            _buildBulletPoint(
              context,
              'Progress is saved locally on your device.',
            ),
            _buildBulletPoint(
              context,
              'Optional Google sign-in to sync progress across devices.',
            ),
            _buildBulletPoint(
              context,
              'No ads, no payments, no analytics, no location tracking.',
              isBold: true,
            ),
            _buildBulletPoint(
              context,
              'You can delete your account at any time (Profile → Delete Account).',
            ),
            _buildBulletPoint(
              context,
              'Full policies are available on our website.',
            ),

            const SizedBox(height: Spacing.xl),

            // Legal Links
            SettingsSectionCard(
              title: 'Legal & Support',
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: () => ExternalLinksService.openUrl(
                    context,
                    ExternalLinksService.privacyPolicyUrl,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Terms of Use'),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: () => ExternalLinksService.openUrl(
                    context,
                    ExternalLinksService.termsUrl,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Data Deletion'),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: () => ExternalLinksService.openUrl(
                    context,
                    ExternalLinksService.dataDeletionUrl,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.mail_outline),
                  title: const Text('Contact Support'),
                  subtitle: const Text(ExternalLinksService.supportEmail),
                  onTap: () => ExternalLinksService.openEmail(context),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xl),

            Center(
              child: Text(
                '© 2024 LietuCoach',
                style: AppSemanticTypography.caption.copyWith(
                  color: semantic.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(
    BuildContext context,
    String text, {
    bool isBold = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: AppSemanticTypography.body.copyWith(
              color: theme.semanticColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppSemanticTypography.body.copyWith(
                color: theme.semanticColors.textPrimary,
                fontWeight: isBold ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
