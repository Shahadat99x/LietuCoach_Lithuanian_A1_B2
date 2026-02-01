abstract class RoleContent {
  static const String packPath = 'assets/packs/roles/traveler_v1.json';
}

class RolePack {
  final String id;
  final String title;
  final String level;
  final String description;
  final List<RoleScenario> scenarios;

  RolePack({
    required this.id,
    required this.title,
    required this.level,
    required this.description,
    required this.scenarios,
  });

  factory RolePack.fromJson(Map<String, dynamic> json) {
    return RolePack(
      id: json['id'] as String,
      title: json['title'] as String,
      level: json['level'] as String,
      description: json['description'] as String,
      scenarios: (json['scenarios'] as List)
          .map((e) => RoleScenario.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RoleScenario {
  final String id;
  final String title;
  final String subtitle;
  final List<RoleDialogue> dialogues;

  RoleScenario({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.dialogues,
  });

  factory RoleScenario.fromJson(Map<String, dynamic> json) {
    return RoleScenario(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      dialogues: (json['dialogues'] as List)
          .map((e) => RoleDialogue.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RoleDialogue {
  final String id;
  final String title;
  final int durationMinutes;
  final String difficulty;
  final List<DialogueTurn> turns;
  final List<RoleExercise> exercises;
  final List<RolePhraseCard> takeaways;

  RoleDialogue({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.difficulty,
    required this.turns,
    required this.exercises,
    required this.takeaways,
  });

  factory RoleDialogue.fromJson(Map<String, dynamic> json) {
    return RoleDialogue(
      id: json['id'] as String,
      title: json['title'] as String,
      durationMinutes: json['durationMinutes'] as int,
      difficulty: json['difficulty'] as String,
      turns: (json['turns'] as List)
          .map((e) => DialogueTurn.fromJson(e as Map<String, dynamic>))
          .toList(),
      exercises:
          (json['exercises'] as List?)
              ?.map((e) => RoleExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      takeaways:
          (json['takeaways'] as List?)
              ?.map((e) => RolePhraseCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DialogueTurn {
  final String speaker; // "A" or "B"
  final String ltText;
  final String enText;
  final String audioNormalPath;

  DialogueTurn({
    required this.speaker,
    required this.ltText,
    required this.enText,
    required this.audioNormalPath,
  });

  factory DialogueTurn.fromJson(Map<String, dynamic> json) {
    return DialogueTurn(
      speaker: json['speaker'] as String,
      ltText: json['ltText'] as String,
      enText: json['enText'] as String,
      audioNormalPath: json['audioNormalPath'] as String,
    );
  }
}

class RoleExercise {
  final String type; // "mcq" | "reorder"
  final String? promptLt;
  final String? promptEn;
  final List<String>? optionsLt;
  final List<String>? optionsEn;
  final int? correctIndex;
  final List<String>? correctSequence;

  RoleExercise({
    required this.type,
    this.promptLt,
    this.promptEn,
    this.optionsLt,
    this.optionsEn,
    this.correctIndex,
    this.correctSequence,
  });

  factory RoleExercise.fromJson(Map<String, dynamic> json) {
    return RoleExercise(
      type: json['type'] as String,
      promptLt: json['promptLt'] as String?,
      promptEn: json['promptEn'] as String?,
      optionsLt: (json['optionsLt'] as List?)?.map((e) => e as String).toList(),
      optionsEn: (json['optionsEn'] as List?)?.map((e) => e as String).toList(),
      correctIndex: json['correctIndex'] as int?,
      correctSequence: (json['correctSequence'] as List?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}

class RolePhraseCard {
  final String lt;
  final String en;
  final String audioNormalPath;
  final List<String> tags;

  RolePhraseCard({
    required this.lt,
    required this.en,
    required this.audioNormalPath,
    required this.tags,
  });

  factory RolePhraseCard.fromJson(Map<String, dynamic> json) {
    return RolePhraseCard(
      lt: json['lt'] as String,
      en: json['en'] as String,
      audioNormalPath: json['audioNormalPath'] as String,
      tags: (json['tags'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }
}
