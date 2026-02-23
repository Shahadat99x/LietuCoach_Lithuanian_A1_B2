import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../auth/auth_service.dart';
import '../../config/env.dart';
import '../../sync/sync_service.dart';
import '../../ui/tokens.dart';
import '../../ui/components/components.dart';
import '../../ui/theme/theme_controller.dart';
import 'delete_account_screen.dart';
import 'widgets/profile_header.dart';
import 'widgets/sync_status_card.dart';
import 'widgets/settings_section_card.dart';
import 'about_screen.dart';
import '../common/services/external_links_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.authServiceOverride,
    this.syncServiceOverride,
  });

  final AuthService? authServiceOverride;
  final SyncService? syncServiceOverride;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthService _authService;
  late final SyncService _syncService;

  int _debugTapCount = 0;
  bool _showAuthDebug = false;

  void _onProfileTapped() {
    _debugTapCount++;
    if (_debugTapCount >= 5) {
      setState(() {
        _showAuthDebug = !_showAuthDebug;
        _debugTapCount = 0;
      });
    }
  }

  Widget _buildAuthDebugPanel(AuthState authState) {
    if (!_showAuthDebug) return const SizedBox.shrink();

    final session = Supabase.instance.client.auth.currentSession;
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AUTH DEBUG PANEL',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Supabase Configured: ${Env.isSupabaseConfigured}',
            style: const TextStyle(color: Colors.black),
          ),
          Text(
            'hasSession: ${session != null}',
            style: const TextStyle(color: Colors.black),
          ),
          Text(
            'authState.status: ${authState.status.name}',
            style: const TextStyle(color: Colors.black),
          ),
          Text(
            'currentUser: ${session?.user.email ?? "null"}',
            style: const TextStyle(color: Colors.black),
          ),
          Text(
            'App Mode: ${kReleaseMode ? "RELEASE" : "DEBUG"}',
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _authService = widget.authServiceOverride ?? authService;
    _syncService = widget.syncServiceOverride ?? syncService;
    _authService.addListener(_onStateChanged);
    _syncService.addListener(_onStateChanged);
    debugPrint(
      'ProfileScreen: [INIT] authState=${_authService.state.status}, '
      'email=${_authService.state.email}, mounted=$mounted',
    );
  }

  @override
  void dispose() {
    _authService.removeListener(_onStateChanged);
    _syncService.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    debugPrint(
      'ProfileScreen: [LISTENER] _onStateChanged fired, '
      'authState=${_authService.state.status}, '
      'email=${_authService.state.email}, mounted=$mounted',
    );
    if (mounted) setState(() {});
  }

  void _handleSignIn() async {
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign in failed: $e')));
      }
    }
  }

  void _handleSignOut() async {
    await _authService.signOut();
  }

  void _handleSync() async {
    await _syncService.syncNow();
  }

  void _showAbout() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AboutScreen()));
  }

  Future<void> _openDeleteAccount() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const DeleteAccountScreen()));
  }

  Future<void> _showAppearanceSheet(ThemeController controller) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.s),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Appearance'),
                  subtitle: const Text('Choose app theme'),
                ),
                RadioGroup<AppThemeMode>(
                  groupValue: controller.mode,
                  onChanged: (value) async {
                    if (value == null) return;
                    await controller.setMode(value);
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                  },
                  child: Column(
                    children: [
                      for (final mode in AppThemeMode.values)
                        RadioListTile<AppThemeMode>(
                          value: mode,
                          title: Text(mode.label),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = ThemeControllerScope.of(context);
    final authState = _authService.state;
    debugPrint(
      'ProfileScreen: [BUILD] status=${authState.status}, '
      'email=${authState.email}, isAuthenticated=${authState.isAuthenticated}',
    );

    // Properties from services
    final isAuthenticated = authState.isAuthenticated;
    final displayName = authState.displayName;
    final email = authState.email;
    final avatarUrl = authState.avatarUrl;

    final syncStatus = _syncService.statusMessage;
    final lastSync = _syncService.lastSyncAt;
    final isSyncing = _syncService.isSyncing;
    final authError = authState.errorMessage;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Spacing.pagePadding),
          children: [
            GestureDetector(
              onTap: _onProfileTapped,
              child: Text(
                'Profile',
                style: AppSemanticTypography.title.copyWith(
                  color: theme.semanticColors.textPrimary,
                ),
              ),
            ),
            if (_showAuthDebug) _buildAuthDebugPanel(authState),
            const SizedBox(height: AppSemanticSpacing.space24),

            // Header
            ProfileHeader(
              displayName: displayName,
              email: email,
              avatarUrl: avatarUrl,
              isAuthenticated: isAuthenticated,
              onEdit: isAuthenticated
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Edit profile coming soon'),
                        ),
                      );
                    }
                  : _handleSignIn,
            ),
            const SizedBox(height: Spacing.xl),

            // Sync Status
            if (isAuthenticated) ...[
              SyncStatusCard(
                statusMessage: syncStatus,
                lastSyncAt: lastSync,
                isSyncing: isSyncing,
                onSync: _handleSync,
              ),
              const SizedBox(height: Spacing.l),
            ],

            // Settings Sections
            SettingsSectionCard(
              title: 'General',
              children: [
                AppListTile(
                  leading: Icons.notifications_outlined,
                  title: const Text('Notifications'),
                  trailing: Switch(value: true, onChanged: (v) {}),
                ),
                AppListTile(
                  leading: Icons.volume_up_outlined,
                  title: const Text('Sound Effects'),
                  trailing: Switch(value: true, onChanged: (v) {}),
                ),
                AppListTile(
                  leading: Icons.dark_mode_outlined,
                  title: const Text('Appearance'),
                  subtitle: Text(themeController.mode.label),
                  showChevron: true,
                  onTap: () => _showAppearanceSheet(themeController),
                ),
              ],
            ),
            const SizedBox(height: Spacing.l),

            SettingsSectionCard(
              title: 'Support',
              children: [
                AppListTile(
                  leading: Icons.help_outline,
                  title: const Text('Help Center'),
                  showChevron: true,
                  onTap: () => ExternalLinksService.openUrl(
                    context,
                    ExternalLinksService.supportUrl,
                  ),
                ),
                AppListTile(
                  leading: Icons.info_outline,
                  title: const Text('About LietuCoach'),
                  trailing: Text(
                    'v1.0.0',
                    style: AppSemanticTypography.caption.copyWith(
                      color: theme.semanticColors.textTertiary,
                    ),
                  ),
                  showChevron: true,
                  onTap: _showAbout,
                ),
              ],
            ),
            if (isAuthenticated) ...[
              const SizedBox(height: Spacing.l),
              SettingsSectionCard(
                title: 'Account',
                children: [
                  AppListTile(
                    leading: Icons.logout,
                    leadingColor: theme.colorScheme.error,
                    title: Text(
                      'Sign Out',
                      style: AppSemanticTypography.body.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    onTap: _handleSignOut,
                  ),
                  AppListTile(
                    leading: Icons.delete_forever_outlined,
                    leadingColor: theme.colorScheme.error,
                    title: Text(
                      'Delete account',
                      style: AppSemanticTypography.body.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    subtitle: const Text(
                      'Permanently remove account and cloud data',
                    ),
                    showChevron: true,
                    onTap: _openDeleteAccount,
                  ),
                ],
              ),
            ],
            if (!isAuthenticated) ...[
              const SizedBox(height: Spacing.l),
              EmptyStateCard(
                icon: Icons.cloud_off_rounded,
                title: 'Sync is paused',
                description:
                    authError ??
                    'Sign in to back up progress and keep your streak safe.',
                primaryActionLabel: 'Sign in to sync',
                onPrimaryAction: _handleSignIn,
              ),
            ],
            const SizedBox(height: Spacing.xl),
          ],
        ),
      ),
    );
  }
}
