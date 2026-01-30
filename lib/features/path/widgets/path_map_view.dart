import 'package:flutter/material.dart';
import '../../../../ui/tokens.dart';
import '../models/course_unit_config.dart';
import '../../../../progress/progress.dart';
import '../../../../packs/packs.dart';
import 'map_view/map_node.dart';
import 'map_view/path_painter.dart';

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
    // Determine the last completed/current unit to scroll to?
    // For now, simpler implementation: standard list, maybe use ScrollController if needed later.

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final centerX = screenWidth / 2;
        const itemHeight = 160.0;
        const amplitude = 60.0; // Horizontal sway

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: Spacing.xxl),
          itemCount: courseUnits.length + 1, // +1 for Header
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: Spacing.l),
                child: header ?? const SizedBox.shrink(),
              );
            }

            final unitIndex = index - 1;
            final config = courseUnits[unitIndex];
            final isUnlocked = isUnitUnlocked(unitIndex);
            final completedCount = lessonCompletedCount[config.unitId] ?? 0;
            final uProgress = unitProgress[config.unitId];
            final isCompleted =
                completedCount >= config.lessonCount &&
                (uProgress?.examPassed ?? false);
            // Current is Unlocked BUT Not Completed (or is the specific next one)
            // Logic: isUnlocked && !isCompleted.
            // Wait, if 0 is completed, 1 is unlocked. 1 is current.
            // If 0 is not completed, 0 is current.
            // So isCurrent = isUnlocked && !isCompleted?
            // What if previous is not completed? Then this one isn't unlocked.
            // So yes, isUnlocked && !isCompleted works for "Next to do".
            // Exception: If everything is completed, none is "Current"?
            // Or the last one is "Current" but done?
            // Let's stick to isUnlocked && !isCompleted.
            final isCurrent = isUnlocked && !isCompleted;

            // Calculate Position
            double getXOffset(int i) {
              // Pattern: 0 -> -1 -> 0 -> +1
              final mod = i % 4;
              if (mod == 0) return 0;
              if (mod == 1) return -amplitude;
              if (mod == 2) return 0;
              return amplitude;
            }

            final currentXOffset = getXOffset(unitIndex);
            final currentPoint = Offset(
              centerX + currentXOffset,
              itemHeight / 2,
            );

            // Calculate Next Point for Line
            // If not last unit, draw line to next
            final hasNext = unitIndex < courseUnits.length - 1;
            Offset? nextPoint;
            if (hasNext) {
              final nextXOffset = getXOffset(unitIndex + 1);
              // Next item center relative to THIS item's origin?
              // No, PathPainter draws inside THIS item.
              // We want to draw from local center (currentPoint) to...
              // The next point is at (centerX + nextXOffset, itemHeight + itemHeight/2) relative to top of this item?
              // Yes, exactly itemHeight below the current point's Y?
              // No, currentPoint.dy is itemHeight/2.
              // Next point dy in next item is itemHeight/2.
              // So relative dy is itemHeight.
              nextPoint = Offset(
                centerX + nextXOffset,
                itemHeight + (itemHeight / 2),
              );
            }

            // Color for path
            // If next is unlocked, path is colored.
            // Actually, if THIS is completed, path to next is colored?
            // Or if Next is unlocked?
            final nextUnlocked = hasNext && isUnitUnlocked(unitIndex + 1);
            final pathColor = nextUnlocked
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest;

            return SizedBox(
              height: itemHeight,
              child: Stack(
                children: [
                  // Path Line
                  if (hasNext)
                    CustomPaint(
                      size: Size(
                        screenWidth,
                        itemHeight * 2,
                      ), // Allow drawing outside
                      painter: PathPainter(
                        start: currentPoint,
                        end: nextPoint!,
                        color: pathColor,
                      ),
                    ),

                  // Node
                  Positioned(
                    left:
                        currentPoint.dx - 36, // Center node (assuming 72 width)
                    top: currentPoint.dy - 36,
                    child: MapNode(
                      index: unitIndex,
                      isUnlocked: isUnlocked,
                      isCompleted: isCompleted,
                      isCurrent: isCurrent,
                      onTap: () => onUnitTap(config),
                      onLongPress: () {
                        // Simplify: Long press could show details or just be same as tap for now
                        onUnitTap(config);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
