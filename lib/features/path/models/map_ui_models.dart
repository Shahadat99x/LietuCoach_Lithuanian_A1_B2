import '../../../../progress/progress.dart';
import 'course_unit_config.dart';

enum PathNodeState { locked, current, completed }

enum PathNodeType { lesson, speaking, review, exam }

/// A strictly UI-focused model for a single node on the map.
class PathMapNode {
  final String id;
  final int index;
  final PathNodeType type;
  final PathNodeState state;
  final String label;
  final bool isExam;

  const PathMapNode({
    required this.id,
    required this.index,
    required this.type,
    required this.state,
    required this.label,
    this.isExam = false,
  });
}

/// A strict UI model for a section of the path (one unit).
class PathMapUnitSection {
  final String unitId;
  final String title;
  final String subTitle;
  final int progressCount;
  final int totalCount;
  final List<PathMapNode> nodes;

  const PathMapUnitSection({
    required this.unitId,
    required this.title,
    required this.subTitle,
    required this.progressCount,
    required this.totalCount,
    required this.nodes,
  });
}

/// Maps configuration and user stats to strict UI models.
class MapDataMapper {
  static List<PathMapUnitSection> buildSections({
    required List<CourseUnitConfig> courseUnits,
    required Map<String, int> lessonCompletedCount,
    required Map<String, UnitProgress?> unitProgress,
    required bool Function(int unitIndex) isUnitUnlocked,
  }) {
    return courseUnits.asMap().entries.map((entry) {
      final unitIndex = entry.key;
      final config = entry.value;
      final completedLessons = lessonCompletedCount[config.unitId] ?? 0;
      final isUnlocked = isUnitUnlocked(unitIndex);
      final examPassed = unitProgress[config.unitId]?.examPassed ?? false;

      // Determine nodes
      final List<PathMapNode> nodes = [];
      final int totalCount = config.lessonCount + 1; // Lessons + Exam

      for (int i = 0; i < totalCount; i++) {
        final isExam = i == config.lessonCount;

        // Determine State
        PathNodeState state = PathNodeState.locked;
        if (isUnlocked) {
          if (isExam) {
            if (examPassed) {
              state = PathNodeState.completed;
            } else if (completedLessons >= config.lessonCount) {
              state = PathNodeState.current;
            } else {
              state = PathNodeState.locked;
            }
          } else {
            if (i < completedLessons) {
              state = PathNodeState.completed;
            } else if (i == completedLessons) {
              state = PathNodeState.current;
            } else {
              state = PathNodeState.locked;
            }
          }
        }

        // Determine Type (Deterministically mixed for visual variety)
        PathNodeType type = PathNodeType.lesson;
        if (isExam) {
          type = PathNodeType.exam;
        } else if (i % 4 == 2) {
          type = PathNodeType.speaking;
        } else if (i % 4 == 3) {
          type = PathNodeType.review;
        }

        nodes.add(
          PathMapNode(
            id: '${config.unitId}_node_$i',
            index: i,
            type: type,
            state: state,
            label: isExam ? 'Exam' : 'Lesson ${i + 1}',
            isExam: isExam,
          ),
        );
      }

      return PathMapUnitSection(
        unitId: config.unitId,
        title: config.title,
        subTitle: 'UNIT ${unitIndex + 1}',
        progressCount: completedLessons,
        totalCount: config.lessonCount,
        nodes: nodes,
      );
    }).toList();
  }
}
