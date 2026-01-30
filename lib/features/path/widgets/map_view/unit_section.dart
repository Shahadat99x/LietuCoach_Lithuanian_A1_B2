import 'package:flutter/material.dart';
import '../../../../ui/tokens.dart';
import '../../models/course_unit_config.dart';
import 'map_node.dart';

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
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: nodeCount,
          separatorBuilder: (_, __) => const SizedBox(height: Spacing.xl),
          itemBuilder: (context, index) {
            final isExam = index == config.lessonCount;

            // State Logic
            bool nodeUnlocked = false;
            bool nodeCompleted = false;
            bool nodeCurrent = false;

            if (!isUnlocked) {
              // Unit locked -> all locked
              nodeUnlocked = false;
            } else {
              if (isExam) {
                // Exam is unlocked if all lessons done
                nodeUnlocked = completedLessons >= config.lessonCount;
                nodeCompleted = examPassed;
                nodeCurrent = nodeUnlocked && !nodeCompleted;
              } else {
                // Lesson node
                nodeUnlocked = index <= completedLessons;
                nodeCompleted = index < completedLessons;
                nodeCurrent = index == completedLessons;
              }
            }

            // Icons
            IconData icon;
            if (isExam) {
              icon = Icons.emoji_events_rounded; // Trophy
            } else if (index % 3 == 0) {
              icon = Icons.menu_book_rounded;
            } else if (index % 3 == 1) {
              icon = Icons.record_voice_over_rounded;
            } else {
              icon = Icons.chat_bubble_rounded;
            }

            // Visual Staggering (Zig-zag)
            // 0: Center, 1: Left, 2: Right, ...
            /*
            alignment logic: 
            index % 2 == 0 ? center : (index % 4 == 1 ? left : right)
            Actually a simple sine wave is nice:
            */
            final double offset =
                40.0 * (index % 2 == 0 ? 0 : (index % 4 == 1 ? -1 : 1));

            return Transform.translate(
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
                    onNodeTap(
                      index,
                    ); // This index needs mapping to lesson ID logic if needed, or just open list
                  }
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
