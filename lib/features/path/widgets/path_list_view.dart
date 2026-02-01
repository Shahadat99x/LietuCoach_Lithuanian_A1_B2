/// List view implementation for the learning path.
import 'package:flutter/material.dart';
import '../models/course_unit_config.dart';
import '../../../../ui/tokens.dart';
import '../../../../progress/progress.dart';
import '../../../../packs/packs.dart';
import '../models/map_ui_models.dart';
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
  final bool Function(int index) isUnitUnlocked;
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
    // Convert Data using the same mapper as Map View
    final sections = MapDataMapper.buildSections(
      courseUnits: courseUnits,
      lessonCompletedCount: lessonCompletedCount,
      unitProgress: unitProgress,
      isUnitUnlocked: isUnitUnlocked,
    );

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: Spacing.m),
      itemCount: sections.length + 2, // Header + Sections + Footer
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            children: [
              if (header != null) header!,
              const SizedBox(height: Spacing.l),
            ],
          );
        }

        if (index == sections.length + 1) {
          return footer != null
              ? Padding(
                  padding: const EdgeInsets.only(
                    top: Spacing.xl,
                    bottom: Spacing.xxl,
                  ),
                  child: footer!,
                )
              : const SizedBox(height: Spacing.xxl);
        }

        final section = sections[index - 1];
        return _buildUnitSection(context, section, index - 1);
      },
    );
  }

  Widget _buildUnitSection(
    BuildContext context,
    PathMapUnitSection section,
    int index,
  ) {
    final config = courseUnits[index];
    final isAvailable = unitAvailability[config.unitId] ?? false;
    final downloadProgress = activeDownloads[config.unitId];

    // Determine overall unit state from section
    // In our model, a unit is "Current" if any node is current,
    // or "Completed" if exam is completed.
    // For the list view, we can just pass the section and handles logic in the card.

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.pagePadding,
        vertical: Spacing.s,
      ),
      child: PathUnitCard(
        section: section,
        isAvailable: isAvailable,
        hasContent: config.hasContent,
        downloadProgress: downloadProgress?.progress,
        onTap: () => onUnitTap(config),
        onExamTap: () => onExamTap(config),
      ),
    );
  }
}
