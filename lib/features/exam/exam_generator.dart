/// Unit Exam Generator
///
/// Auto-generates exam questions from unit items.

import 'dart:math';
import '../../content/content.dart';

/// Exam question types
enum ExamQuestionType {
  listeningChoice,
  translateToLt,
  translateToEn,
}

/// Generated exam question
class ExamQuestion {
  final ExamQuestionType type;
  final String prompt;
  final String? audioId;
  final List<String> options;
  final int correctIndex;

  const ExamQuestion({
    required this.type,
    required this.prompt,
    this.audioId,
    required this.options,
    required this.correctIndex,
  });
}

/// Generates exam from unit items
class ExamGenerator {
  final Random _random;

  ExamGenerator({Random? random}) : _random = random ?? Random();

  /// Generate exam questions from unit
  List<ExamQuestion> generate(Unit unit, {int questionCount = 12}) {
    final items = unit.items.entries.toList();
    if (items.isEmpty) return [];

    final questions = <ExamQuestion>[];
    final usedItemKeys = <String>{};

    // Shuffle items
    items.shuffle(_random);

    // Generate questions until we reach target count
    for (final entry in items) {
      if (questions.length >= questionCount) break;
      if (usedItemKeys.contains(entry.key)) continue;

      final item = entry.value;
      final questionType = ExamQuestionType.values[_random.nextInt(3)];

      final question = _generateQuestion(
        type: questionType,
        item: item,
        allItems: items.map((e) => e.value).toList(),
      );

      if (question != null) {
        questions.add(question);
        usedItemKeys.add(entry.key);
      }
    }

    // If we need more questions, reuse items with different types
    if (questions.length < questionCount) {
      for (final entry in items) {
        if (questions.length >= questionCount) break;

        final item = entry.value;
        // Try a different question type
        for (final type in ExamQuestionType.values) {
          if (questions.length >= questionCount) break;

          // Check if this type was already used for this item
          final alreadyUsed = questions.any(
            (q) => q.prompt.contains(item.lt) || q.prompt.contains(item.en),
          );
          if (alreadyUsed) continue;

          final question = _generateQuestion(
            type: type,
            item: item,
            allItems: items.map((e) => e.value).toList(),
          );

          if (question != null) {
            questions.add(question);
            break;
          }
        }
      }
    }

    // Shuffle final questions
    questions.shuffle(_random);
    return questions.take(questionCount).toList();
  }

  ExamQuestion? _generateQuestion({
    required ExamQuestionType type,
    required Item item,
    required List<Item> allItems,
  }) {
    switch (type) {
      case ExamQuestionType.listeningChoice:
        return _generateListeningChoice(item, allItems);
      case ExamQuestionType.translateToLt:
        return _generateTranslateToLt(item, allItems);
      case ExamQuestionType.translateToEn:
        return _generateTranslateToEn(item, allItems);
    }
  }

  ExamQuestion _generateListeningChoice(Item item, List<Item> allItems) {
    final distractors = _getDistractors(item, allItems, 3);
    final options = [item.lt, ...distractors.map((d) => d.lt)];
    options.shuffle(_random);
    final correctIndex = options.indexOf(item.lt);

    return ExamQuestion(
      type: ExamQuestionType.listeningChoice,
      prompt: 'What do you hear?',
      audioId: item.audioId,
      options: options,
      correctIndex: correctIndex,
    );
  }

  ExamQuestion _generateTranslateToLt(Item item, List<Item> allItems) {
    final distractors = _getDistractors(item, allItems, 3);
    final options = [item.lt, ...distractors.map((d) => d.lt)];
    options.shuffle(_random);
    final correctIndex = options.indexOf(item.lt);

    return ExamQuestion(
      type: ExamQuestionType.translateToLt,
      prompt: 'Translate to Lithuanian: "${item.en}"',
      options: options,
      correctIndex: correctIndex,
    );
  }

  ExamQuestion _generateTranslateToEn(Item item, List<Item> allItems) {
    final distractors = _getDistractors(item, allItems, 3);
    final options = [item.en, ...distractors.map((d) => d.en)];
    options.shuffle(_random);
    final correctIndex = options.indexOf(item.en);

    return ExamQuestion(
      type: ExamQuestionType.translateToEn,
      prompt: 'Translate to English: "${item.lt}"',
      options: options,
      correctIndex: correctIndex,
    );
  }

  List<Item> _getDistractors(Item correct, List<Item> all, int count) {
    final others = all.where((i) => i.lt != correct.lt).toList();
    others.shuffle(_random);
    return others.take(count).toList();
  }
}
