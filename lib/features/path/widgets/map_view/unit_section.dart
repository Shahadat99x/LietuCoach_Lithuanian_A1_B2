import 'package:flutter/material.dart';
import '../../../../ui/tokens.dart';
import '../../models/course_unit_config.dart';
import 'map_node.dart';
import 'unit_path_painter.dart';

class UnitSection extends StatelessWidget {
  final CourseUnitConfig config;
  final int completedLessons;
  final bool isUnlocked;
  final bool examPassed;
  final ValueChanged<int> onNodeTap;
  final VoidCallback onExamTap;

  const UnitSection({
    super.key,
    required this.config,
    required this.completedLessons,
    required this.isUnlocked,
    required this.examPassed,
    required this.onNodeTap,
    required this.onExamTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine nodes
    // Nodes 0..(N-1) are lessons
    // Node N is exam
    final nodeCount = config.lessonCount + 1;

    return Column(
      children: [
        // Unit Title Chip
        Container(
          margin: const EdgeInsets.symmetric(vertical: Spacing.l),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.m,
            vertical: Spacing.s,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          child: Column(
            children: [
              Text(
                'UNIT ${config.unitId.split('_').last}', // Simple extraction or pass index
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                config.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Nodes Path
        Stack(
          children: [
            // Painter
            Positioned.fill(
              child: CustomPaint(
                painter: UnitPathPainter(
                  nodeCount: nodeCount,
                  nodeSize: 72.0,
                  spacing: 32.0, // Spacing.xl
                  getOffset: (index) =>
                      40.0 * (index % 2 == 0 ? 0 : (index % 4 == 1 ? -1 : 1)),
                ),
              ),
            ),

            // Nodes
            Column(
              children: List.generate(nodeCount, (index) {
                final isExam = index == config.lessonCount;

                // State Logic
                bool nodeUnlocked = false;
                bool nodeCompleted = false;
                bool nodeCurrent = false;

                if (!isUnlocked) {
                  nodeUnlocked = false;
                } else {
                  if (isExam) {
                    nodeUnlocked = completedLessons >= config.lessonCount;
                    nodeCompleted = examPassed;
                    nodeCurrent = nodeUnlocked && !nodeCompleted;
                  } else {
                    nodeUnlocked = index <= completedLessons;
                    nodeCompleted = index < completedLessons;
                    nodeCurrent = index == completedLessons;
                  }
                }

                // Icons
                IconData icon;
                if (isExam) {
                  icon = Icons.emoji_events_rounded;
                } else if (index % 3 == 0) {
                  icon = Icons.menu_book_rounded;
                } else if (index % 3 == 1) {
                  icon = Icons.record_voice_over_rounded;
                } else {
                  icon = Icons.chat_bubble_rounded;
                }

                final double offset =
                    40.0 * (index % 2 == 0 ? 0 : (index % 4 == 1 ? -1 : 1));

                return Container(
                  margin: EdgeInsets.only(
                    bottom: index == nodeCount - 1 ? 0 : Spacing.xl,
                  ),
                  child: Transform.translate(
                    offset: Offset(offset, 0),
                    child: MapNode(
                      index: index,
                      isUnlocked: nodeUnlocked,
                      isCompleted: nodeCompleted,
                      isCurrent: nodeCurrent,
                      icon: icon,
                      onTap: () {
                        if (isExam) {
                          onExamTap();
                        } else {
                          onNodeTap(index);
                        }
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ],
    );
  }
}
