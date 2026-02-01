import 'package:flutter/material.dart';
import '../../ui/tokens.dart';
import '../../ui/components/components.dart';
import '../../ui/components/app_card.dart';
import 'domain/role_model.dart';
import 'data/role_repository.dart';
import 'service/role_progress_service.dart';
import 'role_dialogue_player_screen.dart'; // Will implement in Phase 3

class RolePackDetailScreen extends StatefulWidget {
  final String packId;

  const RolePackDetailScreen({super.key, required this.packId});

  @override
  State<RolePackDetailScreen> createState() => _RolePackDetailScreenState();
}

class _RolePackDetailScreenState extends State<RolePackDetailScreen> {
  RolePack? _pack;
  bool _isLoading = true;
  List<String> _completedDialogueIds = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    // Mimic delay or just load
    try {
      // In v1 we only have traveler_v1, logic to pick correct pack can be here
      // For now, loadTravelerPack is hardcoded in repo
      final pack = await roleRepository.loadTravelerPack();
      final completed = await roleProgressService.getCompletedDialogueIds();

      setState(() {
        _pack = pack;
        _completedDialogueIds = completed;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
      setState(() => _isLoading = false);
    }
  }

  void _onDialogueTap(RoleDialogue dialogue) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) =>
                RoleDialoguePlayerScreen(dialogue: dialogue, pack: _pack!),
          ),
        )
        .then((_) => _loadData()); // Refresh progress on return
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_pack == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Pack not found')),
      );
    }

    final pack = _pack!;
    final totalDialogues = pack.scenarios.fold(
      0,
      (sum, s) => sum + s.dialogues.length,
    );
    final completedCount = _completedDialogueIds.where((id) {
      // Filter IDs that actually belong to this pack
      return pack.scenarios.any((s) => s.dialogues.any((d) => d.id == id));
    }).length;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(pack.title),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.pagePadding),
        children: [
          // Header
          Text(
            pack.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.m),

          // Progress
          AppCard(
            color: theme.colorScheme.surfaceContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_graph_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: Spacing.s),
                    Text(
                      'Your Progress',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.m),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: totalDialogues > 0
                        ? completedCount / totalDialogues
                        : 0.0,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.s),
                Text(
                  '$completedCount of $totalDialogues dialogues completed',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.l),

          // Scenarios
          ...pack.scenarios.map(
            (scenario) => _buildScenarioItem(context, scenario),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.pagePadding),
          child: PrimaryButton(
            onPressed: () {
              // Find next incomplete dialogue
              RoleDialogue? nextDialogue;
              for (var s in pack.scenarios) {
                for (var d in s.dialogues) {
                  if (!_completedDialogueIds.contains(d.id)) {
                    nextDialogue = d;
                    break;
                  }
                }
                if (nextDialogue != null) break;
              }

              if (nextDialogue != null) {
                _onDialogueTap(nextDialogue);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All dialogues completed! Great job!'),
                  ),
                );
              }
            },
            label: 'Continue Journey',
            icon: Icons.play_arrow_rounded,
            isFullWidth: true,
          ),
        ),
      ),
    );
  }

  Widget _buildScenarioItem(BuildContext context, RoleScenario scenario) {
    final theme = Theme.of(context);

    // Check if scenario is roughly started/done
    final total = scenario.dialogues.length;
    final done = scenario.dialogues
        .where((d) => _completedDialogueIds.contains(d.id))
        .length;

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.xs,
              vertical: Spacing.s,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.folder_open_rounded,
                  size: 20,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: Spacing.s),
                Text(
                  scenario.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '$done/$total',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.lg),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: scenario.dialogues
                  .map((d) => _buildDialogueItem(context, d))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogueItem(BuildContext context, RoleDialogue dialogue) {
    final theme = Theme.of(context);
    final isDone = _completedDialogueIds.contains(dialogue.id);

    return InkWell(
      onTap: () => _onDialogueTap(dialogue),
      child: Container(
        padding: const EdgeInsets.all(Spacing.m),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(Spacing.xs),
              decoration: BoxDecoration(
                color: isDone
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 20,
                color: isDone
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: Spacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dialogue.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${dialogue.durationMinutes} min • ${dialogue.difficulty}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.s),
            if (isDone)
              AppChip(
                label: 'DONE',
                color: theme.colorScheme.primary,
                isSelected: true,
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.outlineVariant,
              ),
          ],
        ),
      ),
    );
  }
}
