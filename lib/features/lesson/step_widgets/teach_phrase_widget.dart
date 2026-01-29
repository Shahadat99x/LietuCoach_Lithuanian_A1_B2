/// TeachPhraseWidget - Shows new vocabulary with audio
///
/// Non-graded step that introduces a new phrase.

import 'package:flutter/material.dart';
import '../../../content/content.dart';
import '../../../ui/tokens.dart';

class TeachPhraseWidget extends StatelessWidget {
  final TeachPhraseStep step;
  final Item? item;
  final Future<void> Function(String audioId, {String variant}) onPlayAudio;
  final VoidCallback onContinue;

  const TeachPhraseWidget({
    super.key,
    required this.step,
    required this.item,
    required this.onPlayAudio,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (item == null) {
      return Center(
        child: Text('Item not found: ${step.phraseId}'),
      );
    }

    return Column(
      children: [
        const SizedBox(height: Spacing.xl),
        
        // New phrase label
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.m,
            vertical: Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(Radii.full),
          ),
          child: Text(
            'NEW PHRASE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: Spacing.xl),
        
        // Lithuanian phrase (large)
        Text(
          item!.lt,
          style: theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Spacing.m),
        
        // English translation
        if (step.showTranslation) ...[
          Text(
            item!.en,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xl),
        ],
        
        // Audio buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _AudioButton(
              icon: Icons.volume_up,
              label: 'Normal',
              onPressed: () {
                onPlayAudio(item!.audioId, variant: 'normal');
                onContinue();
              },
            ),
            const SizedBox(width: Spacing.m),
            _AudioButton(
              icon: Icons.slow_motion_video,
              label: 'Slow',
              onPressed: () {
                onPlayAudio(item!.audioId, variant: 'slow');
                onContinue();
              },
            ),
          ],
        ),
        
        const SizedBox(height: Spacing.xl),
        
        // Tap to hear instruction
        Text(
          'Tap to hear pronunciation',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _AudioButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _AudioButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(Radii.lg),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(Radii.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.l,
            vertical: Spacing.m,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: theme.colorScheme.primary),
              const SizedBox(height: Spacing.xs),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
