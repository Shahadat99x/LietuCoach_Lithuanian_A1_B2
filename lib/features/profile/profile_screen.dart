/// Profile Screen - User profile and settings
///
/// Shows signed-in user info, auth controls, and sync status.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../auth/auth.dart';
import '../../srs/srs.dart';
import '../../sync/sync.dart';
import '../../ui/tokens.dart';
import '../../ui/components/components.dart';
import '../debug/audio_debug_screen.dart';
import '../../features/certificate/certificate.dart';
import '../../debug/debug_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Flag mainly for manual sync feedback, but we rely on SyncService state
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    authService.addListener(_onAuthChange);
    syncService.addListener(_onSyncChange);
  }

  @override
  void dispose() {
    authService.removeListener(_onAuthChange);
    syncService.removeListener(_onSyncChange);
    super.dispose();
  }

  void _onSyncChange() {
    if (mounted) setState(() {});
  }

  void _onAuthChange() {
    if (mounted) {
      if (authService.state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.state.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      setState(() {});
    }
  }

  Future<void> _signInWithGoogle() async {
    final success = await authService.signInWithGoogle();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in failed. Please try again.')),
      );
    }
  }

  Future<void> _signOut() async {
    await authService.signOut();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Signed out')));
    }
  }

  Future<void> _syncNow() async {
    if (!authService.isAuthenticated) return;
    
    // UI is updated via listener, but we can set local loading state if strictly needed
    setState(() => _isSyncing = true);
    try {
      final result = await syncService.syncNow();
      if (mounted) {
         if (result.success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Synced: ${result.message}')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sync failed: ${result.message}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Sync error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _debugPrintSrsCounts(BuildContext context) async {
    final stats = await srsStore.getStats();
    final count = await srsStore.getAllCardsCount();
    final due = await srsStore.getDueCards(limit: 100);

    debugPrint('=== SRS DEBUG ===');
    debugPrint('Total cards in store: $count');
    debugPrint('Stats total: ${stats.totalCards}');
    debugPrint('Stats due today: ${stats.dueToday}');
    debugPrint('Due cards fetched: ${due.length}');
    for (final card in due) {
      debugPrint('  - ${card.cardId}: ${card.front} (due: ${card.dueAt})');
    }
    debugPrint('=================');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('SRS: Total=$count, Due=${stats.dueToday}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _formatLastSync(DateTime? lastSync) {
    if (lastSync == null) return 'Never';
    final diff = DateTime.now().difference(lastSync);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAuthenticated = authService.isAuthenticated;
    final user = authService.state;

    return AppScaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: Spacing.m),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.pagePadding,
            ),
            child: Text('Profile', style: theme.textTheme.headlineLarge),
          ),
          const SizedBox(height: Spacing.l),

          // User card
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.pagePadding,
            ),
            child: AppCard(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? Icon(
                            Icons.person,
                            size: 40,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                  ),
                  const SizedBox(height: Spacing.m),
                  Text(
                    isAuthenticated
                        ? (user.displayName ?? 'User')
                        : 'Guest User',
                    style: theme.textTheme.titleLarge,
                  ),
                  if (isAuthenticated && user.email != null) ...[
                    const SizedBox(height: Spacing.xs),
                    Text(
                      user.email!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (!isAuthenticated) ...[
                    const SizedBox(height: Spacing.xs),
                    Text(
                      'Sign in to sync your progress',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: Spacing.m),
                  if (isAuthenticated)
                    SecondaryButton(
                      label: 'Sign Out',
                      icon: Icons.logout,
                      onPressed: _signOut,
                    )
                  else
                    PrimaryButton(
                      label: 'Sign in with Google',
                      onPressed: _signInWithGoogle,
                      isFullWidth: true,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.l),

          // Sync section (only when signed in)
          if (isAuthenticated) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.pagePadding,
              ),
              child: Text('Cloud Sync', style: theme.textTheme.titleMedium),
            ),
            const SizedBox(height: Spacing.s),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.pagePadding,
              ),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.cloud_done,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: Spacing.s),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status: ${syncService.statusMessage}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: syncService.isSyncing 
                                      ? theme.colorScheme.primary 
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Last sync: ${_formatLastSync(syncService.lastSyncAt)}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (syncService.isSyncing)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.sync),
                            onPressed: syncService.isSyncing ? null : _syncNow,
                            tooltip: 'Sync now',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.l),
          ],

          // Certificates Section
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.pagePadding,
            ),
            child: Text('Certificates', style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: Spacing.s),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.pagePadding,
            ),
            child: AppCard(
              padding: EdgeInsets.zero,
              child: FutureBuilder<List<CertificateModel>>(
                future: () async {
                  final s = CertificateService();
                  await s.init();
                  return s.getCertificates();
                }(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(Spacing.m),
                      child: Text(
                        'No certificates yet. Complete exams to earn them!',
                      ),
                    );
                  }

                  return Column(
                    children: snapshot.data!.map<Widget>((
                      CertificateModel cert,
                    ) {
                      return _buildSettingTile(
                        context,
                        'A1 Certificate', // Title
                        Icons.workspace_premium,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CertificateScreen(
                                userName: cert.learnerName,
                                userId: 'guest_user',
                                date: cert.issuedAt,
                                certificateId: cert.id,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: Spacing.l),

          // Settings section
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.pagePadding,
            ),
            child: Text('Settings', style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: Spacing.s),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.pagePadding,
            ),
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSettingTile(
                    context,
                    'Dark Mode',
                    Icons.dark_mode,
                    trailing: Switch(
                      value: theme.brightness == Brightness.dark,
                      onChanged: null, // TODO: Implement theme toggle
                    ),
                  ),
                  const Divider(height: 1),
                  _buildSettingTile(
                    context,
                    'Notifications',
                    Icons.notifications,
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  const Divider(height: 1),
                  _buildSettingTile(
                    context,
                    'About',
                    Icons.info,
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  const Divider(height: 1),
                  _buildSettingTile(
                    context,
                    'Audio Debug',
                    Icons.speaker_notes,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AudioDebugScreen(),
                        ),
                      );
                    },
                  ),
                  if (kDebugMode) ...[
                    const Divider(height: 1),
                    _buildSettingTile(
                      context,
                      'Debug: Print SRS Counts',
                      Icons.bug_report,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _debugPrintSrsCounts(context),
                    ),
                    const Divider(height: 1),
                    ValueListenableBuilder<bool>(
                      valueListenable: DebugState.forceUnlockContent,
                      builder: (context, isForced, _) {
                        return _buildSettingTile(
                          context,
                          'Debug: Force Unlock Content',
                          Icons.lock_open,
                          trailing: Switch(
                            value: isForced,
                            onChanged: (val) {
                              DebugState.forceUnlockContent.value = val;
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    IconData icon, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      title: Text(title),
      trailing: trailing,
      onTap: onTap ?? (trailing is Icon ? () {} : null),
    );
  }
}
