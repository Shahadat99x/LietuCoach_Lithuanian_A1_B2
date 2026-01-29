/// Lesson Runner Screen - Step-by-step lesson flow
///
/// Core vertical slice: renders steps, handles answers, tracks score.

import 'package:flutter/material.dart' hide Step;
import '../../audio/audio.dart';
import '../../content/content.dart';
import '../../progress/progress.dart';
import '../../srs/srs.dart';
import '../../ui/tokens.dart';
import '../../ui/components/components.dart';
import 'step_widgets/step_widgets.dart';

class LessonRunnerScreen extends StatefulWidget {
  final Unit unit;
  final Lesson lesson;

  const LessonRunnerScreen({
    super.key,
    required this.unit,
    required this.lesson,
  });

  @override
  State<LessonRunnerScreen> createState() => _LessonRunnerScreenState();
}

class _LessonRunnerScreenState extends State<LessonRunnerScreen> {
  late final LocalFileAudioProvider _audioProvider;
  int _currentStepIndex = 0;
  int _correctCount = 0;
  int _attemptedCount = 0;

  // Step answer state
  bool _hasAnswered = false;
  bool _wasCorrect = false;
  dynamic _selectedAnswer;

  Step get _currentStep => widget.lesson.steps[_currentStepIndex];
  bool get _isLastStep => _currentStepIndex >= widget.lesson.steps.length - 1;
  double get _progress => (_currentStepIndex + 1) / widget.lesson.steps.length;

  @override
  void initState() {
    super.initState();
    _audioProvider = LocalFileAudioProvider();
    _audioProvider.init();
  }

  @override
  void dispose() {
    _audioProvider.dispose();
    super.dispose();
  }

  void _onAnswer(dynamic answer, bool isCorrect) {
    setState(() {
      _selectedAnswer = answer;
      _hasAnswered = true;
      _wasCorrect = isCorrect;
      if (_currentStep.isGraded) {
        _attemptedCount++;
        if (isCorrect) _correctCount++;
      }
    });
  }

  void _nextStep() {
    if (_isLastStep) {
      // Lesson complete - save progress and pop back
      _completeLesson();
      return;
    }

    setState(() {
      _currentStepIndex++;
      _hasAnswered = false;
      _wasCorrect = false;
      _selectedAnswer = null;
    });
  }

  Future<void> _completeLesson() async {
    // Calculate score
    final score = _attemptedCount > 0
        ? (_correctCount / _attemptedCount * 100).round()
        : 100;

    // XP calculation (simple: 10 per graded step)
    final xpEarned = widget.lesson.gradedStepCount * 10;

    // Save progress
    final progress = LessonProgress(
      unitId: widget.unit.id,
      lessonId: widget.lesson.id,
      completed: true,
      score: score,
      xpEarned: xpEarned,
    );
    await progressStore.saveLessonProgress(progress);

    // Create SRS cards from teach_phrase steps
    await _createSrsCards();

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  /// Create SRS cards for vocabulary introduced in this lesson
  Future<void> _createSrsCards() async {
    final cardsToCreate = <SrsCard>[];

    debugPrint('SRS: Creating cards for lesson ${widget.lesson.id}');
    debugPrint('SRS: Lesson has ${widget.lesson.steps.length} steps');

    for (final step in widget.lesson.steps) {
      if (step is TeachPhraseStep) {
        final phraseId = step.phraseId;
        debugPrint('SRS: Found teach_phrase step with phraseId: $phraseId');

        final item = widget.unit.getItem(phraseId);
        if (item == null) {
          debugPrint('SRS: WARNING - Item not found for phraseId: $phraseId');
          continue;
        }

        // Create card ID: a1:unit_01:labas
        final cardId = SrsCard.createId('a1', widget.unit.id, phraseId);

        // Check if card already exists
        final existing = await srsStore.getCard(cardId);
        if (existing != null) {
          debugPrint('SRS: Card already exists: $cardId');
          continue; // Don't recreate
        }

        final card = SrsCard(
          cardId: cardId,
          unitId: widget.unit.id,
          phraseId: phraseId,
          front: item.lt,
          back: item.en,
          audioId: item.audioId,
          // New cards are due immediately
          dueAt: DateTime.now(),
        );
        cardsToCreate.add(card);
        debugPrint('SRS: Will create card: $cardId (${item.lt} -> ${item.en})');
      }
    }

    if (cardsToCreate.isNotEmpty) {
      await srsStore.upsertCards(cardsToCreate);
      debugPrint('SRS: Created ${cardsToCreate.length} new cards');

      // Verify cards were saved
      final stats = await srsStore.getStats();
      debugPrint(
        'SRS: After save - Total: ${stats.totalCards}, Due: ${stats.dueToday}',
      );

      // Notify listeners (CardsScreen, PracticeScreen) to refresh
      notifySrsCardsChanged();
    } else {
      debugPrint('SRS: No new cards to create');
    }
  }

  Future<void> _playAudio(String audioId, {String variant = 'normal'}) async {
    await _audioProvider.play(audioId: audioId, variant: variant);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitConfirmation(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.all(Spacing.m),
              child: Column(
                children: [
                  ProgressBar(value: _progress),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    'Step ${_currentStepIndex + 1} of ${widget.lesson.steps.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // Step content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Spacing.pagePadding),
                child: _buildStepWidget(),
              ),
            ),

            // Feedback + action button
            _buildBottomSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStepWidget() {
    final step = _currentStep;

    return switch (step) {
      TeachPhraseStep s => TeachPhraseWidget(
        step: s,
        item: widget.unit.getItem(s.phraseId),
        onPlayAudio: _playAudio,
        onContinue: () {
          if (!_hasAnswered) {
            setState(() => _hasAnswered = true);
          }
        },
      ),
      McqStep s => McqWidget(
        step: s,
        selectedIndex: _selectedAnswer as int?,
        hasAnswered: _hasAnswered,
        onSelect: (index) {
          if (!_hasAnswered) {
            _onAnswer(index, index == s.correctIndex);
          }
        },
      ),
      MatchStep s => MatchWidget(
        step: s,
        hasAnswered: _hasAnswered,
        onComplete: (isCorrect) {
          if (!_hasAnswered) {
            _onAnswer(true, isCorrect);
          }
        },
      ),
      ReorderStep s => ReorderWidget(
        step: s,
        hasAnswered: _hasAnswered,
        onComplete: (order, isCorrect) {
          if (!_hasAnswered) {
            _onAnswer(order, isCorrect);
          }
        },
      ),
      FillBlankStep s => FillBlankWidget(
        step: s,
        hasAnswered: _hasAnswered,
        onAnswer: (answer) {
          if (!_hasAnswered) {
            _onAnswer(answer, answer.toLowerCase() == s.answer.toLowerCase());
          }
        },
      ),
      ListeningChoiceStep s => ListeningChoiceWidget(
        step: s,
        selectedIndex: _selectedAnswer as int?,
        hasAnswered: _hasAnswered,
        onPlayAudio: () => _playAudio(s.audioId),
        onSelect: (index) {
          if (!_hasAnswered) {
            _onAnswer(index, index == s.correctIndex);
          }
        },
      ),
      DialogueChoiceStep s => DialogueChoiceWidget(
        step: s,
        selectedIndex: _selectedAnswer as int?,
        hasAnswered: _hasAnswered,
        onSelect: (index) {
          if (!_hasAnswered) {
            _onAnswer(index, index == s.correctIndex);
          }
        },
      ),
      LessonCompleteStep s => LessonCompleteWidget(
        step: s,
        correctCount: _correctCount,
        totalCount: _attemptedCount,
        onFinish: () => _completeLesson(),
      ),
    };
  }

  Widget _buildBottomSection(ThemeData theme) {
    // Don't show bottom section for lesson_complete (has its own button)
    if (_currentStep is LessonCompleteStep) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(Spacing.pagePadding),
      decoration: BoxDecoration(
        color: _hasAnswered
            ? (_wasCorrect ? AppColors.successLight : AppColors.dangerLight)
            : theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Feedback text
          if (_hasAnswered && _currentStep.isGraded) ...[
            Row(
              children: [
                Icon(
                  _wasCorrect ? Icons.check_circle : Icons.cancel,
                  color: _wasCorrect ? AppColors.success : AppColors.danger,
                ),
                const SizedBox(width: Spacing.s),
                Text(
                  _wasCorrect ? 'Correct!' : 'Incorrect',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _wasCorrect ? AppColors.success : AppColors.danger,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.m),
          ],

          // Action button
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: _getButtonLabel(),
              onPressed: _canProceed() ? _nextStep : null,
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonLabel() {
    if (!_hasAnswered && _currentStep.isGraded) {
      return 'Check';
    }
    return _isLastStep ? 'Finish' : 'Continue';
  }

  bool _canProceed() {
    // For non-graded steps (teach_phrase), always allow
    if (!_currentStep.isGraded) {
      return _hasAnswered;
    }
    // For graded steps, must have answered
    return _hasAnswered;
  }

  Future<void> _showExitConfirmation(BuildContext context) async {
    final navigator = Navigator.of(context);
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Exit Lesson?'),
        content: const Text('Your progress in this lesson will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      navigator.pop();
    }
  }
}
