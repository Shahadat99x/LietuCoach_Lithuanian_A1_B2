import 'package:flutter/material.dart';
import '../../auth/auth_service.dart';
import '../../sync/sync_service.dart';
import '../../ui/tokens.dart';
import 'widgets/profile_header.dart';
import 'widgets/sync_status_card.dart';
import 'widgets/settings_section_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Services are singletons
  final _authService = authService;
  final _syncService = syncService;

  @override
  void initState() {
    super.initState();
    _authService.addListener(_onStateChanged);
    _syncService.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _authService.removeListener(_onStateChanged);
    _syncService.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = _authService.state;

    // Properties from services
    final isAuthenticated = authState.isAuthenticated;
    final displayName = authState.displayName;
    final email = authState.email;
    final avatarUrl = authState.avatarUrl;

    final syncStatus = _syncService.statusMessage;
    final lastSync = _syncService.lastSyncAt;
    final isSyncing = _syncService.isSyncing;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Spacing.pagePadding),
          children: [
            Text(
              'Profile',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.l),

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

            // Sync Status (Only if authenticated)
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
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  trailing: Switch(value: true, onChanged: (v) {}),
                ),
                ListTile(
                  leading: const Icon(Icons.volume_up_outlined),
                  title: const Text('Sound Effects'),
                  trailing: Switch(value: true, onChanged: (v) {}),
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark Mode'),
                  trailing: Switch(value: false, onChanged: (v) {}),
                ),
              ],
            ),
            const SizedBox(height: Spacing.l),

            SettingsSectionCard(
              title: 'Support',
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help Center'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About LietuCoach'),
                  trailing: const Text('v1.0.0'),
                  onTap: () {},
                ),
                if (isAuthenticated)
                  ListTile(
                    leading: Icon(Icons.logout, color: theme.colorScheme.error),
                    title: Text(
                      'Sign Out',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    onTap: _handleSignOut,
                  ),
              ],
            ),
            const SizedBox(height: Spacing.xl),
          ],
        ),
      ),
    );
  }
}
