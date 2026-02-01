/// Unit Exam Intro Screen
///
/// Shows exam requirements and start button.

import 'package:flutter/material.dart';
import '../../content/content.dart';
import '../../ui/tokens.dart';
import '../../ui/components/components.dart';
import 'exam_runner_screen.dart';

class UnitExamIntroScreen extends StatelessWidget {
  final Unit unit;
  final bool allLessonsCompleted;

  const UnitExamIntroScreen({
    super.key,
    required this.unit,
    required this.allLessonsCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Spacing.pagePadding),
                child: Column(
                  children: [
                    const SizedBox(height: Spacing.xl),
                    // Hero Icon
                    Container(
                      padding: const EdgeInsets.all(Spacing.xxl),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.2,
                          ),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: Spacing.xxl),

                    // Title
                    Text(
                      'Unit ${unit.id.split('_').last} Exam',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.s),
                    Text(
                      unit.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.xxl),

                    // Requirements Card
                    Container(
                      padding: const EdgeInsets.all(Spacing.m),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(Radii.lg),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: Spacing.m),
                            child: Text(
                              'TO PASS THIS EXAM',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          _RequirementRow(
                            icon: Icons.checklist_rounded,
                            text: 'Complete all lessons',
                            isMet: allLessonsCompleted,
                            activeColor: theme.colorScheme.primary,
                          ),
                          const Divider(height: Spacing.l),
                          const _RequirementRow(
                            icon: Icons.timer_outlined,
                            text: '12 Questions',
                            isMet: true, // Always met as info
                            hideCheck: true,
                          ),
                          const Divider(height: Spacing.l),
                          const _RequirementRow(
                            icon: Icons.percent_rounded,
                            text: 'Score 80% or higher',
                            isMet: true,
                            hideCheck: true,
                          ),
                        ],
                      ),
                    ),

                    if (!allLessonsCompleted) ...[
                      const SizedBox(height: Spacing.l),
                      Container(
                        padding: const EdgeInsets.all(Spacing.m),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(Radii.md),
                          border: Border.all(color: AppColors.warning),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lock_rounded,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: Spacing.m),
                            Expanded(
                              child: Text(
                                'Complete all lessons in this unit to unlock the exam.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors
                                      .brown[900], // High contrast on warning
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(Spacing.pagePadding),
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: allLessonsCompleted ? 'Start Exam' : 'Locked',
                  icon: allLessonsCompleted
                      ? Icons.play_arrow_rounded
                      : Icons.lock_outline,
                  onPressed: allLessonsCompleted
                      ? () => _startExam(context)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startExam(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ExamRunnerScreen(unit: unit)),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool? isMet;
  final bool hideCheck;
  final Color? activeColor;

  const _RequirementRow({
    required this.icon,
    required this.text,
    this.isMet,
    this.hideCheck = false,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = (isMet == true)
        ? (activeColor ?? theme.colorScheme.onSurface)
        : theme.colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(width: Spacing.m),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: color,
              fontWeight: (isMet == true && !hideCheck)
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
        if (!hideCheck && isMet != null)
          Icon(
            isMet! ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 24,
            color: isMet! ? AppColors.success : theme.colorScheme.outline,
          ),
      ],
    );
  }
}
