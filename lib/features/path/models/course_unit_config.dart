class CourseUnitConfig {
  final String unitId;
  final String title;
  final int lessonCount;
  final bool hasContent;

  const CourseUnitConfig({
    required this.unitId,
    required this.title,
    required this.lessonCount,
    required this.hasContent,
  });
}

// Ideally this should be in a repository/data layer, but for now keeping configs here or in a constant file.
// Moving the constant list as well would be good, but maybe later.
