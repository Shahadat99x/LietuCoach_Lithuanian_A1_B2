/// LessonCompleteWidget - Summary screen after lesson
///
/// Shows score and completion message.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../content/content.dart';
import '../../../design_system/glass/glass.dart';
import '../../../ui/tokens.dart';
import '../../../ui/components/components.dart';

class LessonCompleteWidget extends StatefulWidget {
  final LessonCompleteStep step;
  final int correctCount;
  final int totalCount;
  final VoidCallback onFinish;

  const LessonCompleteWidget({
    super.key,
    required this.step,
    required this.correctCount,
    required this.totalCount,
    required this.onFinish,
  });

  @override
  State<LessonCompleteWidget> createState() => _LessonCompleteWidgetState();
}

class _LessonCompleteWidgetState extends State<LessonCompleteWidget> {
  bool _sentHaptic = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sentHaptic) return;
    _sentHaptic = true;
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).semanticColors;
    final reduceMotion = AppMotion.reduceMotionOf(context);
    final percentage = widget.totalCount > 0
        ? (widget.correctCount / widget.totalCount * 100).round()
        : 100;
    final isPerfect = widget.correctCount == widget.totalCount;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: Spacing.xl),

            // Celebration Icon (Animated Pop)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: reduceMotion ? AppMotion.fast : AppMotion.emphasis,
              curve: AppMotion.curve(context, AppMotion.emphasisOut),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Transform.scale(scale: value, child: child),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(Spacing.xxl),
                decoration: BoxDecoration(
                  color: (isPerfect ? semantic.success : semantic.accentPrimary)
                      .withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        (isPerfect ? semantic.success : semantic.accentPrimary)
                            .withValues(alpha: 0.35),
                    width: 3,
                  ),
                ),
                child: Icon(
                  isPerfect ? Icons.star_rounded : Icons.check_circle_rounded,
                  size: 80,
                  color: isPerfect ? semantic.success : semantic.accentPrimary,
                ),
              ),
            ),

            const SizedBox(height: Spacing.xxl),

            // Calm Semantic Headers
            Text(
              isPerfect ? 'Perfect!' : 'Lesson Complete',
              style: AppSemanticTypography.title.copyWith(
                color: semantic.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: Spacing.m),

            Text(
              isPerfect
                  ? 'You made no mistakes.'
                  : 'You scored $percentage% accuracy.',
              style: AppSemanticTypography.body.copyWith(
                color: semantic.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: Spacing.xxl),

            // Premium Stats Row
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSemanticSpacing.space16,
              runSpacing: AppSemanticSpacing.space16,
              children: [
                _StatCard(
                  icon: Icons.bolt_rounded,
                  value: widget.step.xpEarned,
                  label: 'XP',
                  color: semantic.accentWarm,
                  animateValue: true,
                ),
                _StatCard(
                  icon: Icons.track_changes_rounded,
                  value: percentage,
                  label: 'Accuracy',
                  suffix: '%',
                  color: isPerfect ? semantic.success : semantic.accentPrimary,
                ),
              ],
            ),

            const SizedBox(height: Spacing.xxl),

            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.pagePadding,
              ),
              child: PrimaryButton(
                label: 'CONTINUE',
                onPressed: widget.onFinish,
                isFullWidth: true,
              ),
            ),
            const SizedBox(height: Spacing.xl),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final String suffix;
  final Color color;
  final bool animateValue;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.suffix = '',
    required this.color,
    this.animateValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).semanticColors;
    final reduceMotion = AppMotion.reduceMotionOf(context);

    return SizedBox(
      width: 132, // Slightly wider
      child: GlassCard(
        preferPerformance: true,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSemanticSpacing.space16,
          vertical: AppSemanticSpacing.space24,
        ),
        // More opaque/solid feel for "active" look
        preset: GlassPreset.solid,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSemanticSpacing.space12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: AppSemanticSpacing.space16),
            if (animateValue)
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: value),
                duration: reduceMotion ? AppMotion.fast : AppMotion.emphasis,
                curve: AppMotion.curve(context, AppMotion.easeOut),
                builder: (context, val, child) {
                  return Text(
                    '$val$suffix',
                    style: AppSemanticTypography.title.copyWith(
                      // Emphasized value
                      color: semantic.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                    ),
                  );
                },
              )
            else
              Text(
                '$value$suffix',
                style: AppSemanticTypography.title.copyWith(
                  color: semantic.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
            const SizedBox(height: AppSemanticSpacing.space4),
            Text(
              label.toUpperCase(),
              style: AppSemanticTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: semantic.textSecondary,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
