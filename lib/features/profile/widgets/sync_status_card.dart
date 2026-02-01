import 'package:flutter/material.dart';
import '../../../../ui/tokens.dart';
import '../../../../ui/components/components.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.m),
            decoration: BoxDecoration(
              color: isSyncing
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: isSyncing
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.cloud_done_rounded, color: Colors.green),
          ),
          const SizedBox(width: Spacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSyncing ? 'Syncing...' : 'Cloud Sync Active',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Last synced: ${_formatLastSync(lastSyncAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: isSyncing ? null : onSync,
            tooltip: 'Sync now',
          ),
        ],
      ),
    );
  }
}
