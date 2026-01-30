/// Map view implementation for the learning path.
import 'package:flutter/material.dart';
import '../../../../ui/tokens.dart';
import '../models/course_unit_config.dart';
import '../../../../progress/progress.dart';
import '../../../../packs/packs.dart';
import 'map_view/unit_section.dart';

class PathMapView extends StatelessWidget {
  final List<CourseUnitConfig> courseUnits;
  final Function(int index) isUnitUnlocked;
  final Map<String, int> lessonCompletedCount;
  final Map<String, UnitProgress?> unitProgress;
  final Map<String, bool> unitAvailability;
  final Map<String, DownloadProgress?> activeDownloads;
  final Function(CourseUnitConfig config) onUnitTap;
  final Function(CourseUnitConfig config) onExamTap;
  final Widget? header;
  final Widget? footer;

  const PathMapView({
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
    // Add bottom padding for FAB or just general spacing
    final bottomPadding = MediaQuery.of(context).padding.bottom + Spacing.xxl;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        Spacing.pagePadding,
        Spacing.m,
        Spacing.pagePadding,
        bottomPadding,
      ),
      children: [
        if (header != null) header!,
        const SizedBox(height: Spacing.l),

        ...courseUnits.asMap().entries.map((entry) {
          final index = entry.key;
          final config = entry.value;

          return UnitSection(
            config: config,
            completedLessons: lessonCompletedCount[config.unitId] ?? 0,
            isUnlocked: isUnitUnlocked(index),
            examPassed: unitProgress[config.unitId]?.examPassed ?? false,
            onNodeTap: (_) => onUnitTap(config),
            onExamTap: () => onExamTap(config),
          );
        }),

        if (footer != null) ...[const SizedBox(height: Spacing.xl), footer!],
      ],
    );
  }
}
