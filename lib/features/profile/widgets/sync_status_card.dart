import 'package:flutter/material.dart';
import '../../../../design_system/glass/glass.dart';
import '../../../../ui/tokens.dart';

class SyncStatusCard extends StatelessWidget {
  final String statusMessage;
  final DateTime? lastSyncAt;
  final bool isSyncing;
  final VoidCallback onSync;

  const SyncStatusCard({
    super.key,
    required this.statusMessage,
    required this.lastSyncAt,
    required this.isSyncing,
    required this.onSync,
  });

  String _formatLastSync(DateTime? dt) {
    if (dt == null) return 'Never';
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _headline(String statusMessage) {
    final status = statusMessage.toLowerCase();
    if (status.contains('syncing')) return 'Syncing now';
    if (status.contains('offline')) return 'Offline mode';
    if (status.contains('error')) return 'Sync needs attention';
    if (status.contains('not signed in')) return 'Sign in to sync';
    if (status.contains('synced')) return 'Cloud sync active';
    return 'Sync ready';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;
    final status = statusMessage.toLowerCase();
    final isOffline = status.contains('offline');
    final isError = status.contains('error');
    final isSignedOut = status.contains('not signed in');
    final isSynced = status.contains('synced');

    final iconColor = isSyncing
        ? semantic.accentPrimary
        : isError
        ? semantic.danger
        : isOffline
        ? semantic.accentWarm
        : isSignedOut
        ? semantic.textSecondary
        : semantic.success;

    final iconBg = isSyncing
        ? semantic.accentPrimary.withValues(alpha: 0.14)
        : isError
        ? semantic.dangerContainer
        : isOffline
        ? semantic.accentWarm.withValues(alpha: 0.16)
        : isSignedOut
        ? semantic.surfaceElevated
        : semantic.successContainer;

    return GlassCard(
      preferPerformance: true,
      preset: GlassPreset.frost,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.m),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: isSyncing
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    isError
                        ? Icons.cloud_off_rounded
                        : isOffline
                        ? Icons.wifi_off_rounded
                        : isSignedOut
                        ? Icons.cloud_outlined
                        : isSynced
                        ? Icons.cloud_done_rounded
                        : Icons.cloud_queue_rounded,
                    color: iconColor,
                  ),
          ),
          const SizedBox(width: Spacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _headline(statusMessage),
                  style: AppSemanticTypography.section.copyWith(
                    color: semantic.textPrimary,
                  ),
                ),
                Text(
                  '$statusMessage · Last synced ${_formatLastSync(lastSyncAt)}',
                  style: AppSemanticTypography.caption.copyWith(
                    color: semantic.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: (isSyncing || isSignedOut) ? null : onSync,
            tooltip: 'Sync now',
          ),
        ],
      ),
    );
  }
}
