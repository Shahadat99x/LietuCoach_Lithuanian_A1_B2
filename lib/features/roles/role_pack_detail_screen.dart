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
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(Spacing.s),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: theme.colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: Spacing.m),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$completedCount / $totalDialogues completed',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Keep going!', style: theme.textTheme.bodySmall),
                  ],
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
            label: 'Continue',
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
      child: Card(
        // Use standard Card for now, or AppCard
        elevation: 0,
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          initiallyExpanded: true, // Auto-expand for v1 since only Traveler
          title: Text(
            scenario.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${scenario.subtitle} • $done/$total',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          childrenPadding: EdgeInsets.zero,
          children: scenario.dialogues
              .map((d) => _buildDialogueItem(context, d))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildDialogueItem(BuildContext context, RoleDialogue dialogue) {
    final theme = Theme.of(context);
    final isDone = _completedDialogueIds.contains(dialogue.id);

    return InkWell(
      onTap: () => _onDialogueTap(dialogue),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.m,
          vertical: Spacing.m,
        ),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDone
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDone ? Icons.check : Icons.play_arrow_rounded,
                color: isDone
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: Spacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dialogue.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${dialogue.durationMinutes} min • ${dialogue.difficulty}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }
}
