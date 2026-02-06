import 'package:flutter/material.dart';
import '../../../../design_system/glass/glass.dart';
import '../../../../ui/tokens.dart';
import '../../../../ui/components/components.dart';

enum RoleStatus { locked, available, completed }

class RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final RoleStatus status;
  final String? unlockHint;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.status,
    this.unlockHint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;
    final isLocked = status == RoleStatus.locked;
    final isCompleted = status == RoleStatus.completed;

    return ScaleButton(
      onTap: onTap,
      child: Opacity(
        opacity: isLocked ? 0.93 : 1,
        child: GlassCard(
          preferPerformance: true,
          preset: GlassPreset.solid,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Box
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isLocked
                      ? semantic.surfaceElevated
                      : semantic.successContainer,
                  borderRadius: BorderRadius.circular(
                    AppSemanticShape.radiusControl,
                  ),
                ),
                child: Icon(
                  icon,
                  color: isLocked
                      ? semantic.textSecondary
                      : semantic.accentPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: Spacing.m),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppSemanticTypography.section.copyWith(
                        color: semantic.textPrimary,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      description,
                      style: AppSemanticTypography.caption.copyWith(
                        color: semantic.textSecondary,
                      ),
                    ),
                    if (isLocked) ...[
                      const SizedBox(height: AppSemanticSpacing.space8),
                      Text(
                        unlockHint ?? 'Finish a lesson to unlock this',
                        style: AppSemanticTypography.caption.copyWith(
                          color: semantic.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: Spacing.s),
              if (isLocked)
                GlassPill(
                  minHeight: 0,
                  selected: false,
                  preferPerformance: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSemanticSpacing.space8,
                    vertical: AppSemanticSpacing.space4,
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    size: 14,
                    color: semantic.textSecondary,
                  ),
                )
              else if (isCompleted)
                Icon(Icons.check_circle_rounded, color: semantic.success)
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: semantic.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
