import 'package:flutter/material.dart';
import '../models/course_unit_config.dart';
import '../../../../ui/tokens.dart';
import '../../../../progress/progress.dart';
import '../../../../packs/packs.dart';
import 'path_unit_card.dart';

// Copy of `_UnitCard` from path_screen.dart, will be moved here or made public there
// For now, assume we will pass a builder or refactor UnitCard to be public.
// Better: Refactor `_UnitCard` in `path_screen.dart` to be `PathUnitCard` in separate file
// to avoid duplication.

// PLAN:
// 1. Move `_UnitCard` to `widgets/path_unit_card.dart`
// 2. Create `PathListView` using `PathUnitCard`

// Let's assume we do 1 first. But I am prohibited from making parallel edits to same file if dangerous.
// I will create `PathListView` that accepts the data and builds the list.

class PathListView extends StatelessWidget {
  final List<CourseUnitConfig> courseUnits;
  final Function(int index) isUnitUnlocked;
  final Map<String, int> lessonCompletedCount;
  final Map<String, UnitProgress?> unitProgress;
  final Map<String, bool> unitAvailability;
  final Map<String, DownloadProgress?> activeDownloads;
  final Function(CourseUnitConfig config) onUnitTap; // Simplified signature
  final Function(CourseUnitConfig config) onExamTap;
  final Widget? header;
  final Widget? footer;

  const PathListView({
    super.key,
    required this.courseUnits,
    required this.isUnitUnlocked,
    required this.lessonCompletedCount,
    required this.unitProgress,
    required this.unitAvailability,
    required this.activeDownloads,
    required this.onUnitTap,
    required this.onExamTap,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: Spacing.m),
      children: [
        if (header != null) header!,
        const SizedBox(height: Spacing.l),
        for (var i = 0; i < courseUnits.length; i++) ...[
          _buildUnitSection(i),
          if (i < courseUnits.length - 1) const SizedBox(height: Spacing.m),
        ],
        if (footer != null) ...[
          const SizedBox(height: Spacing.xl),
          footer!,
          const SizedBox(height: Spacing.xxl),
        ] else ...[
          const SizedBox(height: Spacing.xxl),
        ],
      ],
    );
  }

  Widget _buildUnitSection(int index) {
    final config = courseUnits[index];
    final isUnlocked = isUnitUnlocked(index);
    final completedCount = lessonCompletedCount[config.unitId] ?? 0;
    final uProgress = unitProgress[config.unitId];
    final isAvailable = unitAvailability[config.unitId] ?? false;
    final downloadProgress = activeDownloads[config.unitId];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.pagePadding),
      child: PathUnitCard(
        config: config,
        index: index,
        isUnlocked: isUnlocked,
        isAvailable: isAvailable,
        downloadProgress: downloadProgress?.progress,
        completedLessons: completedCount,
        examPassed: uProgress?.examPassed ?? false,
        examScore: uProgress?.examScore,
        onTap: () => onUnitTap(config),
        onExamTap: () => onExamTap(config),
      ),
    );
  }
}
