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
      appBar: AppBar(
        title: Text('${unit.title} Exam'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Spacing.l),
              
              // Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(Spacing.l),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.quiz,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.l),
              
              // Title
              Center(
                child: Text(
                  'Unit Exam',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.s),
              Center(
                child: Text(
                  unit.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.xl),
              
              // Requirements
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requirements',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: Spacing.m),
                    _RequirementRow(
                      icon: Icons.school,
                      text: 'Complete all lessons',
                      isMet: allLessonsCompleted,
                    ),
                    const SizedBox(height: Spacing.s),
                    _RequirementRow(
                      icon: Icons.percent,
                      text: 'Score at least 80% to pass',
                      isMet: null, // Not applicable yet
                    ),
                    const SizedBox(height: Spacing.s),
                    _RequirementRow(
                      icon: Icons.timer,
                      text: '12 questions',
                      isMet: null,
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Action button
              if (!allLessonsCompleted) ...[
                AppCard(
                  color: AppColors.warningLight,
                  child: Row(
                    children: [
                      Icon(Icons.lock, color: AppColors.warning),
                      const SizedBox(width: Spacing.m),
                      Expanded(
                        child: Text(
                          'Complete all lessons first to unlock the exam.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.m),
              ],
              
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Start Exam',
                  onPressed: allLessonsCompleted
                      ? () => _startExam(context)
                      : null,
                ),
              ),
              const SizedBox(height: Spacing.m),
            ],
          ),
        ),
      ),
    );
  }

  void _startExam(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ExamRunnerScreen(unit: unit),
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool? isMet;

  const _RequirementRow({
    required this.icon,
    required this.text,
    this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color iconColor = theme.colorScheme.onSurfaceVariant;
    if (isMet == true) iconColor = AppColors.success;
    if (isMet == false) iconColor = AppColors.danger;

    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: Spacing.s),
        Expanded(
          child: Text(text, style: theme.textTheme.bodyMedium),
        ),
        if (isMet != null)
          Icon(
            isMet! ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: isMet! ? AppColors.success : AppColors.danger,
          ),
      ],
    );
  }
}
