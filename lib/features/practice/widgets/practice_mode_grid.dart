import 'package:flutter/material.dart';
import '../../../../design_system/glass/glass.dart';
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
          color: AppColors.primary,
          onTap: onListeningTap,
        ),
        _ModeTile(
          icon: Icons.record_voice_over_rounded,
          label: 'Speaking',
          color: AppColors.info,
          isLocked: true,
          unlockHint: 'Finish a lesson to unlock',
          onTap: onSpeakingTap,
        ),
        _ModeTile(
          icon: Icons.bolt_rounded,
          label: 'Difficult Words',
          color: AppColors.danger,
          isLocked: true,
          unlockHint: 'Finish a lesson to unlock',
          onTap: onWordsTap,
        ),
        _ModeTile(
          icon: Icons.history_edu_rounded,
          label: 'Mistakes',
          color: AppColors.secondary,
          isLocked: true,
          unlockHint: 'Finish a lesson to unlock',
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
  final String unlockHint;

  const _ModeTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isLocked = false,
    this.unlockHint = 'Finish a lesson to unlock',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = isLocked
        ? theme.colorScheme.onSurfaceVariant
        : color;

    return ScaleButton(
      onTap: onTap,
      child: GlassCard(
        preferPerformance: true,
        preset: GlassPreset.solid,
        padding: const EdgeInsets.all(AppSemanticSpacing.space16),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSemanticSpacing.space16),
                  decoration: BoxDecoration(
                    color: isLocked
                        ? theme.semanticColors.surfaceElevated
                        : effectiveColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Opacity(
                    opacity: isLocked ? AppDisabledStyle.lockedOpacity : 1,
                    child: Icon(icon, size: 28, color: effectiveColor),
                  ),
                ),
                const SizedBox(height: AppSemanticSpacing.space16),
                Text(
                  label,
                  style: AppSemanticTypography.body.copyWith(
                    color: isLocked
                        ? theme.semanticColors.textSecondary
                        : theme.semanticColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isLocked) ...[
                  const SizedBox(height: AppSemanticSpacing.space8),
                  Text(
                    unlockHint,
                    style: AppSemanticTypography.caption.copyWith(
                      color: theme.semanticColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
            if (isLocked)
              const Positioned(top: 0, right: 0, child: LockedBadge()),
          ],
        ),
      ),
    );
  }
}
