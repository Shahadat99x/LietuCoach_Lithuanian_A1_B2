/// Progress Models for local persistence
///
/// Stores lesson completion, exam results, and user stats.

/// Progress for a single lesson
class LessonProgress {
  final String unitId;
  final String lessonId;
  bool completed;
  int score; // percentage 0-100
  int xpEarned;
  DateTime updatedAt;

  LessonProgress({
    required this.unitId,
    required this.lessonId,
    this.completed = false,
    this.score = 0,
    this.xpEarned = 0,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  /// Composite key for storage
  String get key => '${unitId}_$lessonId';

  LessonProgress copyWith({
    bool? completed,
    int? score,
    int? xpEarned,
  }) {
    return LessonProgress(
      unitId: unitId,
      lessonId: lessonId,
      completed: completed ?? this.completed,
      score: score ?? this.score,
      xpEarned: xpEarned ?? this.xpEarned,
      updatedAt: DateTime.now(),
    );
  }

  /// Convert to Map for Hive storage
  Map<String, dynamic> toMap() => {
        'unitId': unitId,
        'lessonId': lessonId,
        'completed': completed,
        'score': score,
        'xpEarned': xpEarned,
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// Create from Map
  factory LessonProgress.fromMap(Map<dynamic, dynamic> map) {
    return LessonProgress(
      unitId: map['unitId'] as String,
      lessonId: map['lessonId'] as String,
      completed: map['completed'] as bool? ?? false,
      score: map['score'] as int? ?? 0,
      xpEarned: map['xpEarned'] as int? ?? 0,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }
}

/// Progress for a unit (exam status)
class UnitProgress {
  final String unitId;
  bool examPassed;
  int examScore; // percentage 0-100
  DateTime? examPassedAt;
  DateTime updatedAt;

  UnitProgress({
    required this.unitId,
    this.examPassed = false,
    this.examScore = 0,
    this.examPassedAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  UnitProgress copyWith({
    bool? examPassed,
    int? examScore,
    DateTime? examPassedAt,
  }) {
    return UnitProgress(
      unitId: unitId,
      examPassed: examPassed ?? this.examPassed,
      examScore: examScore ?? this.examScore,
      examPassedAt: examPassedAt ?? this.examPassedAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Convert to Map for Hive storage
  Map<String, dynamic> toMap() => {
        'unitId': unitId,
        'examPassed': examPassed,
        'examScore': examScore,
        'examPassedAt': examPassedAt?.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// Create from Map
  factory UnitProgress.fromMap(Map<dynamic, dynamic> map) {
    return UnitProgress(
      unitId: map['unitId'] as String,
      examPassed: map['examPassed'] as bool? ?? false,
      examScore: map['examScore'] as int? ?? 0,
      examPassedAt: map['examPassedAt'] != null
          ? DateTime.parse(map['examPassedAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }
}

/// User aggregate stats (optional, TODO for Phase 5)
class UserStats {
  int totalXp;
  int currentStreak;
  DateTime? lastActivityDate;
  int lessonsCompleted;
  int examsCompleted;
  DateTime updatedAt;

  UserStats({
    this.totalXp = 0,
    this.currentStreak = 0,
    this.lastActivityDate,
    this.lessonsCompleted = 0,
    this.examsCompleted = 0,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  /// Convert to Map for Hive storage
  Map<String, dynamic> toMap() => {
        'totalXp': totalXp,
        'currentStreak': currentStreak,
        'lastActivityDate': lastActivityDate?.toIso8601String(),
        'lessonsCompleted': lessonsCompleted,
        'examsCompleted': examsCompleted,
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// Create from Map
  factory UserStats.fromMap(Map<dynamic, dynamic> map) {
    return UserStats(
      totalXp: map['totalXp'] as int? ?? 0,
      currentStreak: map['currentStreak'] as int? ?? 0,
      lastActivityDate: map['lastActivityDate'] != null
          ? DateTime.parse(map['lastActivityDate'] as String)
          : null,
      lessonsCompleted: map['lessonsCompleted'] as int? ?? 0,
      examsCompleted: map['examsCompleted'] as int? ?? 0,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}
