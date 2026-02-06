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
    final bottomPadding = MediaQuery.of(context).padding.bottom + Spacing.xxl;
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;

    final sections = MapDataMapper.buildSections(
      courseUnits: courseUnits,
      lessonCompletedCount: lessonCompletedCount,
      unitProgress: unitProgress,
      isUnitUnlocked: isUnitUnlocked,
    );

    return Container(
      decoration: BoxDecoration(
        color: semantic.bg.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.74 : 0.66,
        ),
      ),
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
                final lockMessage = node.isExam
                    ? 'Complete all lessons in ${section.subTitle} to unlock the exam.'
                    : 'Complete ${section.subTitle} to unlock ${node.label.toLowerCase()}.';
                LockBottomSheet.show(
                  context,
                  title: 'Keep Going!',
                  message: lockMessage,
                );
              } else {
                final config = courseUnits[index - 1]; // Assume mapped 1:1

                if (node.type == PathNodeType.exam) {
                  onExamTap(config);
                } else {
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
