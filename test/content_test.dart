/// Content parsing tests

import 'package:flutter_test/flutter_test.dart';
import 'package:lietucoach/content/content.dart';

void main() {
  group('Content Models', () {
    test('Unit.fromJson parses correctly', () {
      final json = {
        'id': 'unit_01',
        'title': 'Test Unit',
        'titleLt': 'Testas',
        'lessons': [
          {
            'id': 'lesson_01',
            'title': 'Test Lesson',
            'steps': [
              {
                'type': 'teach_phrase',
                'phraseId': 'hello',
                'showTranslation': true,
              },
              {
                'type': 'mcq',
                'prompt': 'What means hello?',
                'options': ['Hi', 'Bye', 'Thanks'],
                'correctIndex': 0,
              },
              {
                'type': 'lesson_complete',
                'itemsLearned': 1,
                'xpEarned': 10,
              },
            ],
          },
        ],
        'items': {
          'hello': {
            'lt': 'Labas',
            'en': 'Hello',
            'audioId': 'a1_u01_hello',
          },
        },
      };

      final unit = Unit.fromJson(json);

      expect(unit.id, 'unit_01');
      expect(unit.title, 'Test Unit');
      expect(unit.lessons.length, 1);
      expect(unit.items.length, 1);

      final lesson = unit.lessons.first;
      expect(lesson.id, 'lesson_01');
      expect(lesson.steps.length, 3);

      // Check step types
      expect(lesson.steps[0], isA<TeachPhraseStep>());
      expect(lesson.steps[1], isA<McqStep>());
      expect(lesson.steps[2], isA<LessonCompleteStep>());

      // Check item lookup
      final item = unit.getItem('hello');
      expect(item, isNotNull);
      expect(item!.lt, 'Labas');
      expect(item.audioId, 'a1_u01_hello');
    });

    test('McqStep.isGraded returns true', () {
      final step = McqStep(
        prompt: 'Test',
        options: ['A', 'B', 'C'],
        correctIndex: 0,
      );
      expect(step.isGraded, true);
    });

    test('TeachPhraseStep.isGraded returns false', () {
      final step = TeachPhraseStep(
        phraseId: 'test',
        showTranslation: true,
      );
      expect(step.isGraded, false);
    });

    test('ReorderStep.correctSentence builds correctly', () {
      final step = ReorderStep(
        words: ['world', 'Hello', '!'],
        correctOrder: [1, 0, 2],
      );
      expect(step.correctSentence, 'Hello world !');
    });

    test('Lesson.gradedStepCount excludes non-graded steps', () {
      final lesson = Lesson(
        id: 'test',
        title: 'Test',
        steps: [
          TeachPhraseStep(phraseId: 'a'),
          McqStep(prompt: 'q', options: ['a', 'b'], correctIndex: 0),
          McqStep(prompt: 'q2', options: ['a', 'b'], correctIndex: 1),
          LessonCompleteStep(),
        ],
      );
      expect(lesson.gradedStepCount, 2);
    });
  });

  group('MCQ Scoring Logic', () {
    test('correct answer returns true', () {
      final step = McqStep(
        prompt: 'What is 2+2?',
        options: ['3', '4', '5'],
        correctIndex: 1,
      );

      expect(1 == step.correctIndex, true);
      expect(0 == step.correctIndex, false);
      expect(2 == step.correctIndex, false);
    });

    test('correctIndex is within options bounds', () {
      final step = McqStep(
        prompt: 'Test',
        options: ['A', 'B', 'C'],
        correctIndex: 2,
      );

      expect(step.correctIndex >= 0, true);
      expect(step.correctIndex < step.options.length, true);
    });
  });
}
