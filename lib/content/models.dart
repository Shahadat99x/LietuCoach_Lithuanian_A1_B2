/// Content Models for LietuCoach
///
/// Typed data models for content packs (units, lessons, steps, items).
/// Aligned with docs/CONTENT_SCHEMA.json.

/// Vocabulary/phrase item
class Item {
  final String lt;
  final String en;
  final String audioId;

  const Item({
    required this.lt,
    required this.en,
    required this.audioId,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      lt: json['lt'] as String,
      en: json['en'] as String,
      audioId: json['audioId'] as String,
    );
  }
}

/// Base step class with type discriminator
sealed class Step {
  final String type;

  const Step({required this.type});

  factory Step.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'teach_phrase' => TeachPhraseStep.fromJson(json),
      'mcq' => McqStep.fromJson(json),
      'match' => MatchStep.fromJson(json),
      'reorder' => ReorderStep.fromJson(json),
      'fill_blank' => FillBlankStep.fromJson(json),
      'listening_choice' => ListeningChoiceStep.fromJson(json),
      'dialogue_choice' => DialogueChoiceStep.fromJson(json),
      'lesson_complete' => LessonCompleteStep.fromJson(json),
      _ => throw ArgumentError('Unknown step type: $type'),
    };
  }

  /// Whether this step requires user answer (graded)
  bool get isGraded => this is! TeachPhraseStep && this is! LessonCompleteStep;
}

class TeachPhraseStep extends Step {
  final String phraseId;
  final bool showTranslation;

  const TeachPhraseStep({
    required this.phraseId,
    this.showTranslation = true,
  }) : super(type: 'teach_phrase');

  factory TeachPhraseStep.fromJson(Map<String, dynamic> json) {
    return TeachPhraseStep(
      phraseId: json['phraseId'] as String,
      showTranslation: json['showTranslation'] as bool? ?? true,
    );
  }
}

class McqStep extends Step {
  final String prompt;
  final List<String> options;
  final int correctIndex;

  const McqStep({
    required this.prompt,
    required this.options,
    required this.correctIndex,
  }) : super(type: 'mcq');

  factory McqStep.fromJson(Map<String, dynamic> json) {
    return McqStep(
      prompt: json['prompt'] as String,
      options: (json['options'] as List).cast<String>(),
      correctIndex: json['correctIndex'] as int,
    );
  }
}

class MatchStep extends Step {
  final List<MatchPair> pairs;

  const MatchStep({required this.pairs}) : super(type: 'match');

  factory MatchStep.fromJson(Map<String, dynamic> json) {
    return MatchStep(
      pairs: (json['pairs'] as List)
          .map((p) => MatchPair.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MatchPair {
  final String left;
  final String right;

  const MatchPair({required this.left, required this.right});

  factory MatchPair.fromJson(Map<String, dynamic> json) {
    return MatchPair(
      left: json['left'] as String,
      right: json['right'] as String,
    );
  }
}

class ReorderStep extends Step {
  final List<String> words;
  final List<int> correctOrder;

  const ReorderStep({
    required this.words,
    required this.correctOrder,
  }) : super(type: 'reorder');

  factory ReorderStep.fromJson(Map<String, dynamic> json) {
    return ReorderStep(
      words: (json['words'] as List).cast<String>(),
      correctOrder: (json['correctOrder'] as List).cast<int>(),
    );
  }

  /// Get the correctly ordered sentence
  String get correctSentence =>
      correctOrder.map((i) => words[i]).join(' ');
}

class FillBlankStep extends Step {
  final String sentence;
  final String blank;
  final String answer;

  const FillBlankStep({
    required this.sentence,
    required this.blank,
    required this.answer,
  }) : super(type: 'fill_blank');

  factory FillBlankStep.fromJson(Map<String, dynamic> json) {
    return FillBlankStep(
      sentence: json['sentence'] as String,
      blank: json['blank'] as String,
      answer: json['answer'] as String,
    );
  }
}

class ListeningChoiceStep extends Step {
  final String audioId;
  final List<String> options;
  final int correctIndex;

  const ListeningChoiceStep({
    required this.audioId,
    required this.options,
    required this.correctIndex,
  }) : super(type: 'listening_choice');

  factory ListeningChoiceStep.fromJson(Map<String, dynamic> json) {
    return ListeningChoiceStep(
      audioId: json['audioId'] as String,
      options: (json['options'] as List).cast<String>(),
      correctIndex: json['correctIndex'] as int,
    );
  }
}

class DialogueChoiceStep extends Step {
  final String context;
  final List<String> options;
  final int correctIndex;

  const DialogueChoiceStep({
    required this.context,
    required this.options,
    required this.correctIndex,
  }) : super(type: 'dialogue_choice');

  factory DialogueChoiceStep.fromJson(Map<String, dynamic> json) {
    return DialogueChoiceStep(
      context: json['context'] as String,
      options: (json['options'] as List).cast<String>(),
      correctIndex: json['correctIndex'] as int,
    );
  }
}

class LessonCompleteStep extends Step {
  final int itemsLearned;
  final int xpEarned;

  const LessonCompleteStep({
    this.itemsLearned = 0,
    this.xpEarned = 0,
  }) : super(type: 'lesson_complete');

  factory LessonCompleteStep.fromJson(Map<String, dynamic> json) {
    return LessonCompleteStep(
      itemsLearned: json['itemsLearned'] as int? ?? 0,
      xpEarned: json['xpEarned'] as int? ?? 0,
    );
  }
}

/// Lesson containing steps
class Lesson {
  final String id;
  final String title;
  final String? titleLt;
  final List<Step> steps;

  const Lesson({
    required this.id,
    required this.title,
    this.titleLt,
    required this.steps,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      titleLt: json['titleLt'] as String?,
      steps: (json['steps'] as List)
          .map((s) => Step.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Count of graded steps (excludes teach_phrase and lesson_complete)
  int get gradedStepCount => steps.where((s) => s.isGraded).length;
}

/// Unit containing lessons and items
class Unit {
  final String id;
  final String title;
  final String? titleLt;
  final List<Lesson> lessons;
  final Map<String, Item> items;

  const Unit({
    required this.id,
    required this.title,
    this.titleLt,
    required this.lessons,
    required this.items,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as Map<String, dynamic>;
    final items = <String, Item>{};
    for (final entry in itemsJson.entries) {
      items[entry.key] = Item.fromJson(entry.value as Map<String, dynamic>);
    }

    return Unit(
      id: json['id'] as String,
      title: json['title'] as String,
      titleLt: json['titleLt'] as String?,
      lessons: (json['lessons'] as List)
          .map((l) => Lesson.fromJson(l as Map<String, dynamic>))
          .toList(),
      items: items,
    );
  }

  /// Get item by phraseId
  Item? getItem(String phraseId) => items[phraseId];
}
