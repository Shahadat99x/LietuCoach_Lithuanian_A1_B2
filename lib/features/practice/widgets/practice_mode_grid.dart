import 'package:flutter/material.dart';
import '../../../../ui/tokens.dart';
import '../../../../ui/components/components.dart';

class PracticeModeGrid extends StatelessWidget {
  final VoidCallback onListeningTap;
  final VoidCallback onSpeakingTap;
  final VoidCallback onMistakesTap;
  final VoidCallback onWordsTap;

  const PracticeModeGrid({
    super.key,
    required this.onListeningTap,
    required this.onSpeakingTap,
    required this.onMistakesTap,
    required this.onWordsTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: Spacing.m,
      mainAxisSpacing: Spacing.m,
      childAspectRatio: 1.1,
      children: [
        _ModeTile(
          icon: Icons.headphones_rounded,
          label: 'Listening',
          color: Colors.purple,
          onTap: onListeningTap,
        ),
        _ModeTile(
          icon: Icons.record_voice_over_rounded,
          label: 'Speaking',
          color: Colors.blue,
          isLocked: true,
          onTap: onSpeakingTap,
        ),
        _ModeTile(
          icon: Icons.bolt_rounded,
          label: 'Difficult Words',
          color: Colors.red,
          isLocked: true,
          onTap: onWordsTap,
        ),
        _ModeTile(
          icon: Icons.history_edu_rounded,
          label: 'Mistakes',
          color: Colors.orange,
          isLocked: true,
          onTap: onMistakesTap,
        ),
      ],
    );
  }
}

class _ModeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isLocked;

  const _ModeTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = isLocked
        ? theme.colorScheme.onSurfaceVariant
        : color;

    return ScaleButton(
      onTap: onTap,
      child: AppCard(
        color: isLocked
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : theme.colorScheme.surface,
        padding: const EdgeInsets.all(Spacing.m),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(Spacing.m),
              decoration: BoxDecoration(
                color: isLocked
                    ? theme.colorScheme.surfaceContainerHighest
                    : effectiveColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLocked ? Icons.lock_rounded : icon,
                size: 28,
                color: isLocked
                    ? theme.colorScheme.onSurfaceVariant
                    : effectiveColor,
              ),
            ),
            const SizedBox(height: Spacing.m),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isLocked
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
