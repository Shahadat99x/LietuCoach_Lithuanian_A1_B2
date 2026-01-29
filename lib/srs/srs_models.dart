/// SRS Models for spaced repetition
///
/// Core data structures for flashcard scheduling.

/// Rating options for card review
enum SrsRating { hard, good, easy }

/// A flashcard for spaced repetition
class SrsCard {
  /// Stable unique ID: "{level}:{unitId}:{phraseId}"
  final String cardId;
  final String unitId;
  final String phraseId;

  /// Front of card (Lithuanian)
  final String front;

  /// Back of card (English translation)
  final String back;

  /// Audio ID for pronunciation
  final String audioId;

  /// Ease factor (default 2.5, range 1.3-3.0)
  double ease;

  /// Current interval in days
  int intervalDays;

  /// When the card is due for review
  DateTime dueAt;

  /// Last time this card was reviewed
  DateTime? lastReviewedAt;

  /// Number of successful reviews
  int reps;

  /// Number of times the card was forgotten (rated Hard after learning)
  int lapses;

  /// Last modification time (for sync)
  DateTime updatedAt;

  SrsCard({
    required this.cardId,
    required this.unitId,
    required this.phraseId,
    required this.front,
    required this.back,
    required this.audioId,
    this.ease = 2.5,
    this.intervalDays = 0,
    DateTime? dueAt,
    this.lastReviewedAt,
    this.reps = 0,
    this.lapses = 0,
    DateTime? updatedAt,
  }) : dueAt = dueAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Create card ID from components
  static String createId(String level, String unitId, String phraseId) {
    return '$level:$unitId:$phraseId';
  }

  /// Check if card is due for review
  bool get isDue =>
      DateTime.now().isAfter(dueAt) || DateTime.now().isAtSameMomentAs(dueAt);

  /// Check if this is a new card (never reviewed)
  bool get isNew => reps == 0;

  SrsCard copyWith({
    double? ease,
    int? intervalDays,
    DateTime? dueAt,
    DateTime? lastReviewedAt,
    int? reps,
    int? lapses,
    DateTime? updatedAt,
  }) {
    return SrsCard(
      cardId: cardId,
      unitId: unitId,
      phraseId: phraseId,
      front: front,
      back: back,
      audioId: audioId,
      ease: ease ?? this.ease,
      intervalDays: intervalDays ?? this.intervalDays,
      dueAt: dueAt ?? this.dueAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Convert to Map for Hive storage
  Map<String, dynamic> toMap() => {
    'cardId': cardId,
    'unitId': unitId,
    'phraseId': phraseId,
    'front': front,
    'back': back,
    'audioId': audioId,
    'ease': ease,
    'intervalDays': intervalDays,
    'dueAt': dueAt.toIso8601String(),
    'lastReviewedAt': lastReviewedAt?.toIso8601String(),
    'reps': reps,
    'lapses': lapses,
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Create from Map
  factory SrsCard.fromMap(Map<dynamic, dynamic> map) {
    return SrsCard(
      cardId: map['cardId'] as String,
      unitId: map['unitId'] as String,
      phraseId: map['phraseId'] as String,
      front: map['front'] as String,
      back: map['back'] as String,
      audioId: map['audioId'] as String,
      ease: (map['ease'] as num?)?.toDouble() ?? 2.5,
      intervalDays: map['intervalDays'] as int? ?? 0,
      dueAt: map['dueAt'] != null
          ? DateTime.parse(map['dueAt'] as String)
          : DateTime.now(),
      lastReviewedAt: map['lastReviewedAt'] != null
          ? DateTime.parse(map['lastReviewedAt'] as String)
          : null,
      reps: map['reps'] as int? ?? 0,
      lapses: map['lapses'] as int? ?? 0,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}

/// Statistics for SRS cards
class SrsStats {
  final int dueToday;
  final int totalCards;
  final DateTime? nextDue;

  const SrsStats({
    required this.dueToday,
    required this.totalCards,
    this.nextDue,
  });

  factory SrsStats.empty() =>
      const SrsStats(dueToday: 0, totalCards: 0, nextDue: null);
}
