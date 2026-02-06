import 'package:flutter/material.dart';
import '../../../../design_system/glass/glass.dart';
import '../../../../ui/tokens.dart';
import '../../../../ui/components/components.dart';
import '../practice_planner.dart';

class DailyTrainingHero extends StatelessWidget {
  final PracticePlan? plan;
  final VoidCallback onStart;
  final bool isLoading;

  const DailyTrainingHero({
    super.key,
    required this.plan,
    required this.onStart,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;
    final isEmpty = plan?.isEmpty == true;

    return GlassCard(
      preferPerformance: true,
      preset: GlassPreset.frost,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: Spacing.s),
              Text(
                'Recommended for you',
                style: AppSemanticTypography.caption.copyWith(
                  color: semantic.accentPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSemanticSpacing.space16),

          Text(
            'Daily Training Mix',
            style: AppSemanticTypography.section.copyWith(
              color: semantic.textPrimary,
            ),
          ),
          const SizedBox(height: AppSemanticSpacing.space8),

          Text(
            isEmpty
                ? 'Complete more lessons to unlock your personalized training mix.'
                : '${plan?.estimatedMinutes ?? 5} min • Review & Listening',
            style: AppSemanticTypography.body.copyWith(
              color: semantic.textSecondary,
            ),
          ),

          const SizedBox(height: AppSemanticSpacing.space24),

          // Content Chips (Visual flavor)
          if (!isEmpty) ...[
            Wrap(
              spacing: AppSemanticSpacing.space12,
              children: [
                GlassPill(
                  selected: true,
                  preferPerformance: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSemanticSpacing.space12,
                    vertical: AppSemanticSpacing.space8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 16,
                        color: semantic.textPrimary,
                      ),
                      const SizedBox(width: AppSemanticSpacing.space8),
                      Text(
                        'Review',
                        style: AppSemanticTypography.caption.copyWith(
                          color: semantic.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                GlassPill(
                  selected: true,
                  preferPerformance: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSemanticSpacing.space12,
                    vertical: AppSemanticSpacing.space8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.headphones_rounded,
                        size: 16,
                        color: semantic.textPrimary,
                      ),
                      const SizedBox(width: AppSemanticSpacing.space8),
                      Text(
                        'Listening',
                        style: AppSemanticTypography.caption.copyWith(
                          color: semantic.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSemanticSpacing.space24),
          ],

          PrimaryButton(
            label: isEmpty ? 'Continue on Path' : 'Start Session',
            icon: isEmpty ? Icons.map_rounded : Icons.play_arrow_rounded,
            onPressed: isLoading ? null : onStart,
            isLoading: isLoading,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}
