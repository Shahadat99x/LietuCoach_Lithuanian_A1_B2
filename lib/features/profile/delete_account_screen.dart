import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../auth/auth.dart';
import '../../design_system/glass/glass.dart';
import '../../ui/components/components.dart';
import '../../ui/tokens.dart';
import '../onboarding/onboarding_screen.dart';
import '../common/services/external_links_service.dart';
import 'services/account_deletion_service.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final AccountDeletionService _deletionService = AccountDeletionService();

  bool _confirmed = false;
  bool _isLoading = false;
  bool _attemptedReauth = false;
  String? _errorMessage;

  Future<void> _startReauth() async {
    final started = await authService.signInWithGoogle();
    if (!mounted) return;

    if (started) {
      setState(() {
        _attemptedReauth = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Re-authenticated. You may now proceed with deletion.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn\'t re-authenticate. You can still continue.'),
        ),
      );
    }
  }

  Future<void> _deleteAccount() async {
    if (_isLoading || !_confirmed) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _deletionService.deleteCurrentAccount(
      attemptedReauth: _attemptedReauth,
    );

    if (!mounted) return;

    if (!result.ok) {
      setState(() {
        _isLoading = false;
        _errorMessage = result.errorMessage;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorMessage ?? 'Something went wrong. Please try again.',
          ),
        ),
      );
      return;
    }

    // Show success message after navigation (uses rootNavigator's scaffold)
    final messenger = ScaffoldMessenger.of(context);
    final successMessage = result.localWarnings.isNotEmpty
        ? 'Account deleted. Some local data may need manual cleanup.'
        : 'Account deleted. You\'ve been signed out.';

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (_) => false,
    );

    messenger.showSnackBar(SnackBar(content: Text(successMessage)));
  }

  Future<void> _copySupportEmail() async {
    await Clipboard.setData(const ClipboardData(text: 'hello@dhossain.com'));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Support email copied.')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;
    final isAuthenticated = authService.isAuthenticated;

    return Scaffold(
      appBar: AppBar(title: const Text('Delete account')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Spacing.pagePadding),
          children: [
            Text(
              'Delete your account',
              style: AppSemanticTypography.title.copyWith(
                color: semantic.textPrimary,
              ),
            ),
            const SizedBox(height: Spacing.m),
            Text(
              'This permanently deletes your cloud account and cannot be undone.',
              style: AppSemanticTypography.body.copyWith(
                color: semantic.textSecondary,
              ),
            ),
            const SizedBox(height: Spacing.l),

            GlassCard(
              preset: GlassPreset.solid,
              preferPerformance: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What will be deleted',
                    style: AppSemanticTypography.section.copyWith(
                      color: semantic.textPrimary,
                    ),
                  ),
                  const SizedBox(height: Spacing.s),
                  ...const [
                    'Profile',
                    'Lesson and unit progress',
                    'SRS cards',
                    'Streak and practice stats',
                    'Certificate metadata',
                  ].map(_DeletionItem.new),
                ],
              ),
            ),
            const SizedBox(height: Spacing.l),

            GlassCard(
              preset: GlassPreset.solid,
              preferPerformance: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Optional security step',
                    style: AppSemanticTypography.section.copyWith(
                      color: semantic.textPrimary,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    'Re-authenticate with Google before deleting (recommended).',
                    style: AppSemanticTypography.caption.copyWith(
                      color: semantic.textSecondary,
                    ),
                  ),
                  const SizedBox(height: Spacing.s),
                  SecondaryButton(
                    label: _attemptedReauth
                        ? 'Re-authentication requested'
                        : 'Re-authenticate with Google',
                    onPressed: _isLoading ? null : _startReauth,
                    isFullWidth: true,
                    icon: Icons.verified_user_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.l),

            CheckboxListTile(
              value: _confirmed,
              onChanged: _isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _confirmed = value ?? false;
                      });
                    },
              title: const Text('I understand this cannot be undone.'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: Spacing.s),

            if (!isAuthenticated)
              Text(
                'You are currently signed out. Sign in first to delete your account.',
                style: AppSemanticTypography.caption.copyWith(
                  color: semantic.danger,
                ),
              ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: Spacing.s),
                child: Text(
                  _errorMessage!,
                  style: AppSemanticTypography.caption.copyWith(
                    color: semantic.danger,
                  ),
                ),
              ),
            const SizedBox(height: Spacing.l),

            PrimaryButton(
              label: 'Delete my account',
              onPressed: (_confirmed && isAuthenticated && !_isLoading)
                  ? _deleteAccount
                  : null,
              isLoading: _isLoading,
              isFullWidth: true,
              backgroundColor: semantic.danger,
              foregroundColor: theme.colorScheme.onError,
              icon: Icons.delete_forever,
            ),
            const SizedBox(height: Spacing.s),

            Center(
              child: TextButton(
                onPressed: _copySupportEmail,
                child: const Text('Contact support: hello@dhossain.com'),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => ExternalLinksService.openUrl(
                  context,
                  ExternalLinksService.dataDeletionUrl,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: semantic.textSecondary,
                ),
                child: const Text('Read data deletion policy'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeletionItem extends StatelessWidget {
  const _DeletionItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '•',
            style: AppSemanticTypography.body.copyWith(
              color: theme.semanticColors.textSecondary,
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: Text(
              text,
              style: AppSemanticTypography.body.copyWith(
                color: theme.semanticColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
