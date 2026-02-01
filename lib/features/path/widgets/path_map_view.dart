/// Map view implementation for the learning path.
import 'package:flutter/material.dart';
import '../../../../ui/tokens.dart';
import '../models/course_unit_config.dart';
import '../../../../progress/progress.dart';
import '../../../../packs/packs.dart';
import '../models/map_ui_models.dart';
import 'map_view/path_section_layout.dart';
import 'lock_bottom_sheet.dart';

class PathMapView extends StatelessWidget {
  final List<CourseUnitConfig> courseUnits;
  final bool Function(int index) isUnitUnlocked;
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

    // Frosted/Translucent surface for Map View
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? Colors.black : Colors.white;
    // Reduce opacity to ensure aurora is visible (was 0.6)
    final opacity = isDark ? 0.3 : 0.2;

    // Convert Data
    final sections = MapDataMapper.buildSections(
      courseUnits: courseUnits,
      lessonCompletedCount: lessonCompletedCount,
      unitProgress: unitProgress,
      isUnitUnlocked: isUnitUnlocked,
    );

    return Container(
      decoration: BoxDecoration(color: surfaceColor.withValues(alpha: opacity)),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          Spacing.pagePadding,
          Spacing.m,
          Spacing.pagePadding,
          bottomPadding,
        ),
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
                    padding: const EdgeInsets.only(top: Spacing.xl),
                    child: footer!,
                  )
                : const SizedBox.shrink();
          }

          final section = sections[index - 1]; // Offset index
          return PathSectionLayout(
            section: section,
            onNodeTap: (node) {
              if (node.state == PathNodeState.locked) {
                LockBottomSheet.show(
                  context,
                  title: 'Lesson Locked',
                  message:
                      'Complete the previous lesson or unit to unlock this content.',
                );
              } else {
                // Find config for this unit
                final config = courseUnits[index - 1]; // Assume mapped 1:1

                if (node.type == PathNodeType.exam) {
                  onExamTap(config);
                } else {
                  // Assuming Node Index maps effectively to Lesson Index if we ignore exam
                  // In DataMapper: nodes are 0..lessonCount.
                  // Call generic onUnitTap which usually resumes/starts?
                  // OR we need to pass strict lesson index.
                  // Original just called onUnitTap(config) which handles "Continue".
                  // Let's stick to that for safe resume.
                  onUnitTap(config);
                }
              }
            },
          );
        },
      ),
    );
  }
}
