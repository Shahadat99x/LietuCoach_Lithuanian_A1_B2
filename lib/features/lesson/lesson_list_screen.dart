/// Lesson List Screen - Shows lessons for a unit with progress
///
/// Entry point for lesson selection within a unit.

import 'package:flutter/material.dart';
import '../../content/content.dart';
import '../../progress/progress.dart';
import '../../ui/tokens.dart';
import '../../ui/components/components.dart';
import '../content/content_error_screen.dart';
import 'lesson_runner_screen.dart';
import '../exam/exam_intro_screen.dart';

class LessonListScreen extends StatefulWidget {
  final String unitId;
  final ContentRepository? repository;

  const LessonListScreen({super.key, required this.unitId, this.repository});

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  late final ContentRepository _repository;
  Unit? _unit;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ContentRepository();
    _loadData();
  }

  bool _loading = true;
  Map<String, LessonProgress> _lessonProgress = {};
  UnitProgress? _unitProgress;
  bool _allLessonsCompleted = false;

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      final unitResult = await _repository.loadUnit(widget.unitId).timeout(
        const Duration(seconds: 5),
        onTimeout: () => Result.failure(ContentLoadFailure.unknown(widget.unitId, 'Loading timed out')),
      );

      if (unitResult.isFailure) {
        final failure = unitResult.failure;
        if (!mounted) return;

        if (failure is ContentNotFound) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ContentErrorScreen(
                title: 'Unit coming soon',
                message:
                    'This unit isn’t installed yet. Update the app or download the pack.',
                onRetry: _loadData,
              ),
            ),
          );
          return;
        }

        setState(() {
          _error = failure.toString();
          _loading = false;
        });
        return;
      }

      final unit = unitResult.value;

      // Load progress for each lesson
      final progressList = await progressStore.getUnitLessonProgress(
        widget.unitId,
      );

      final progressMap = <String, LessonProgress>{};
      for (final p in progressList) {
        progressMap[p.lessonId] = p;
      }

      // Load unit progress (exam)
      final unitProgress = await progressStore.getUnitProgress(widget.unitId);

      // Check if all lessons are completed
      final allCompleted = await progressStore.areAllLessonsCompleted(
        widget.unitId,
        unit.lessons.map((l) => l.id).toList(),
      );

      if (!mounted) return;
      setState(() {
        _unit = unit;
        _lessonProgress = progressMap;
        _unitProgress = unitProgress;
        _allLessonsCompleted = allCompleted;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _startLesson(Lesson lesson) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => LessonRunnerScreen(unit: _unit!, lesson: lesson),
          ),
        )
        .then((_) => _loadData()); // Refresh on return
  }

  Future<void> _openExam() async {
    final unit = _unit!;
    final allCompleted = await progressStore.areAllLessonsCompleted(
      widget.unitId,
      unit.lessons.map((l) => l.id).toList(),
    );

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => UnitExamIntroScreen(
              unit: unit,
              allLessonsCompleted: allCompleted,
            ),
          ),
        )
        .then((_) => _loadData()); // Refresh on return
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: _unit?.title ?? 'Loading...',
      showAppBar: true,
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            const SizedBox(height: Spacing.m),
            Text('Failed to load unit', style: theme.textTheme.titleMedium),
            const SizedBox(height: Spacing.s),
            Text(_error!, style: theme.textTheme.bodySmall),
          ],
        ),
      );
    }

    final unit = _unit!;
    final unitProgress = _unitProgress;
    final allLessonsCompleted = _allLessonsCompleted;
    final examPassed = unitProgress?.examPassed ?? false;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: Spacing.m),
        itemCount: unit.lessons.length + 1, // +1 for Exam
        separatorBuilder: (context, index) => const SizedBox(height: Spacing.m),
        itemBuilder: (context, index) {
          if (index < unit.lessons.length) {
            final lesson = unit.lessons[index];
            final progress = _lessonProgress[lesson.id];
            return _LessonCard(
              lesson: lesson,
              lessonNumber: index + 1,
              isCompleted: progress?.completed ?? false,
              score: progress?.score,
              onTap: () => _startLesson(lesson),
            );
          } else {
            // Exam Item
            return _ExamItem(
              isLocked: !allLessonsCompleted,
              isPassed: examPassed,
              score: _unitProgress?.examScore,
              onTap:
                  _openExam, // Always allow tap to see requirements/locked state
            );
          }
        },
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final int lessonNumber;
  final bool isCompleted;
  final int? score;
  final VoidCallback onTap;

  const _LessonCard({
    required this.lesson,
    required this.lessonNumber,
    required this.isCompleted,
    this.score,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          // Lesson number badge or checkmark
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.successLight
                  : theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: isCompleted
                ? Icon(Icons.check, color: AppColors.success, size: 24)
                : Text(
                    '$lessonNumber',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: Spacing.m),
          // Lesson info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lesson.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: Spacing.xs),
                Row(
                  children: [
                    Text(
                      '${lesson.steps.length} steps',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isCompleted && score != null) ...[
                      const SizedBox(width: Spacing.s),
                      Text(
                        '• $score%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Arrow or replay icon
          Icon(
            isCompleted ? Icons.replay : Icons.chevron_right,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _ExamItem extends StatelessWidget {
  final bool isLocked;
  final bool isPassed;
  final int? score;
  final VoidCallback onTap;

  const _ExamItem({
    required this.isLocked,
    required this.isPassed,
    this.score,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color iconInfoColor = theme.colorScheme.primary;
    Color iconBgColor = theme.colorScheme.primaryContainer;
    IconData icon = Icons.quiz;
    String title = 'Unit Exam';
    String subtitle = 'Test your knowledge';

    if (isPassed) {
      iconInfoColor = AppColors.success;
      iconBgColor = AppColors.successLight;
      icon = Icons.workspace_premium; // Or celebration
      title = 'Exam Passed';
      subtitle = 'Score: $score% • Tap to retake';
    } else if (isLocked) {
      iconInfoColor = theme.colorScheme.onSurfaceVariant;
      iconBgColor = theme.colorScheme.surfaceContainerHighest;
      icon = Icons.lock;
      title = 'Unit Exam';
      subtitle = 'Complete all lessons first';
    }

    return AppCard(
      onTap: onTap,
      color: isLocked
          ? theme.colorScheme.surfaceContainerHighest.withAlpha(128)
          : null,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconInfoColor, size: 24),
          ),
          const SizedBox(width: Spacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isPassed
                        ? AppColors.success
                        : (isLocked
                              ? theme.colorScheme.onSurfaceVariant
                              : null),
                    fontWeight: isPassed ? FontWeight.bold : null,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
