/// Lesson Runner Screen - Step-by-step lesson flow
///
/// Core vertical slice: renders steps, handles answers, tracks score.

import 'package:flutter/material.dart' hide Step;
import 'package:flutter/services.dart';
import '../../audio/audio.dart';
import '../../content/content.dart';
import '../../progress/progress.dart';
import '../../srs/srs.dart';
import '../../ui/tokens.dart';
import '../../ui/components/components.dart';
import '../practice/practice_stats_service.dart';
import 'step_widgets/step_widgets.dart';
import 'widgets/exercise_shell.dart';
import 'widgets/bottom_result_sheet.dart';

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
  // Double-submit protection
  bool _isProcessing = false;

  // Step answer state
  bool _hasAnswered = false;
  bool _wasCorrect = false;
  dynamic _selectedAnswer;

  Step get _currentStep => widget.lesson.steps[_currentStepIndex];
  bool get _isLastStep => _currentStepIndex >= widget.lesson.steps.length - 1;

  // Progress animates forward if the user has answered correctly, even before clicking continue
  double get _progress {
    final base = _currentStepIndex.toDouble();
    final bonus = (_hasAnswered && _wasCorrect) ? 1.0 : 0.0;
    return (base + bonus) / widget.lesson.steps.length;
  }

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

  void _nextStep() {
    if (_isProcessing) return;

    if (_isLastStep) {
      _completeLesson();
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Small delay to prevent accidental double-taps if the UI hasn't rebuilt yet
    Future.delayed(AppMotion.fast, () {
      if (mounted) {
        setState(() {
          _currentStepIndex++;
          _hasAnswered = false;
          _wasCorrect = false;
          _selectedAnswer = null;
          _isProcessing = false;
        });
      }
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

    // Record Practice Stats
    await practiceStatsService.recordPracticeEvent(
      type: PracticeEventType.lessonCompletion,
      xpDelta: xpEarned,
      minutesDelta:
          5, // Estimate 5 mins per lesson for now, or track actual duration
    );

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
    return ExerciseShell(
      progress: _progress,
      title: widget.lesson.title,
      onClose: () => _showExitConfirmation(context),
      content: _buildStepWidget(),
      footer: _buildFooter(),
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
          // For teach phrase, immediate continue is fine,
          // OR we could just mark answered and let footer handle "Continue".
          // Current TeachPhraseWidget usually has its own layout.
          // We should ideally let it just fill the content and use the footer for "Continue".
          // But TeachPhraseWidget has its own "Continue" logic often?
          // Actually existing widget calls onContinue immediately.
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
            setState(() {
              _selectedAnswer = index;
            });
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
        onOrderChanged: (order) {
          if (!_hasAnswered) {
            setState(() => _selectedAnswer = order);
          }
        },
      ),
      FillBlankStep s => FillBlankWidget(
        step: s,
        hasAnswered: _hasAnswered,
        onAnswer: (answer) {
          setState(() {
            _selectedAnswer = answer;
          });
        },
        // We need to support 'onSelect' style for FillBlank if we want "Check" button?
        // FillBlank usually needs user to type/select then Check.
        // Current FillBlankWidget might call onAnswer immediately?
        // Let's assume it updates value.
      ),
      ListeningChoiceStep s => ListeningChoiceWidget(
        step: s,
        selectedIndex: _selectedAnswer as int?,
        hasAnswered: _hasAnswered,
        onPlayAudio: () => _playAudio(s.audioId),
        onSelect: (index) {
          if (!_hasAnswered) {
            setState(() {
              _selectedAnswer = index;
            });
          }
        },
      ),
      DialogueChoiceStep s => DialogueChoiceWidget(
        step: s,
        selectedIndex: _selectedAnswer as int?,
        hasAnswered: _hasAnswered,
        onSelect: (index) {
          if (!_hasAnswered) {
            setState(() {
              _selectedAnswer = index;
            });
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

  Widget _buildFooter() {
    if (_currentStep is LessonCompleteStep) {
      return const SizedBox.shrink(); // Widget handles its own footer or is fullscreen
    }

    if (_hasAnswered && _currentStep.isGraded) {
      String? message;
      if (_wasCorrect) {
        message = 'Good job!';
      } else {
        message = _getCorrectAnswerText(_currentStep);
      }

      return BottomResultSheet(
        state: _wasCorrect ? ResultState.correct : ResultState.incorrect,
        title: _wasCorrect ? 'Correct!' : 'Incorrect',
        message: message,
        onContinue: _nextStep,
      );
    }

    // Default Footer (Check/Continue)
    final label = _getButtonLabel();
    final canProceed = _canProceed();

    // If it's TeachPhrase, usually we just show "Continue" always?
    // If it's graded, we show "Check" but only if selected.

    // For TeachPhrase, we might want "Continue" enabled always?
    // Current logic: _canProceed returns _hasAnswered.
    // TeachPhraseWidget sets _hasAnswered=true on some action?
    // We might need to auto-enable for TeachPhrase.

    return Container(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s),
      width: double.infinity,
      child: PrimaryButton(
        label: label,
        onPressed: canProceed
            ? () {
                if (_currentStep.isGraded && !_hasAnswered) {
                  _checkAnswer();
                } else {
                  _nextStep();
                }
              }
            : null,
      ),
    );
  }

  void _checkAnswer() {
    // Logic to check answer based on step type
    bool isCorrect = false;
    final step = _currentStep;

    if (step is McqStep) {
      isCorrect = (_selectedAnswer == step.correctIndex);
      // Update selected answer for highlighting?
      // _selectedAnswer is already set. Widget uses it.
    } else if (step is ListeningChoiceStep) {
      isCorrect = (_selectedAnswer == step.correctIndex);
    } else if (step is DialogueChoiceStep) {
      isCorrect = (_selectedAnswer == step.correctIndex);
    } else if (step is FillBlankStep) {
      isCorrect =
          (_selectedAnswer.toString().toLowerCase() ==
          step.answer.toLowerCase());
    } else if (step is ReorderStep) {
      if (_selectedAnswer is! List<int>) {
        isCorrect = false;
      } else {
        final order = _selectedAnswer as List<int>;
        if (order.length != step.correctOrder.length) {
          isCorrect = false;
        } else {
          isCorrect = true;
          for (int i = 0; i < order.length; i++) {
            if (order[i] != step.correctOrder[i]) {
              isCorrect = false;
              break;
            }
          }
        }
      }
    }
    // Match and Reorder matchers call _onAnswer directly for now.

    _onAnswer(_selectedAnswer, isCorrect);
  }

  // _onAnswer now just updates state
  void _onAnswer(dynamic answer, bool isCorrect) {
    if (_hasAnswered) return;
    if (isCorrect) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.mediumImpact();
    }

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

  String _getButtonLabel() {
    if (!_hasAnswered && _currentStep.isGraded) {
      return 'Check';
    }
    return _isLastStep ? 'Finish' : 'Continue';
  }

  bool _canProceed() {
    if (!_currentStep.isGraded) {
      return true; // Always allow continue for teach steps (or wait for audio?)
    }
    // For graded, need selection to "Check"
    if (!_hasAnswered) {
      return _selectedAnswer != null;
    }
    return true; // If answered, can continue
  }

  String? _getCorrectAnswerText(Step step) {
    if (step is McqStep) {
      return 'Correct answer: ${step.options[step.correctIndex]}';
    } else if (step is ListeningChoiceStep) {
      return 'Correct answer: ${step.options[step.correctIndex]}';
    } else if (step is DialogueChoiceStep) {
      return 'Correct answer: ${step.options[step.correctIndex]}';
    } else if (step is FillBlankStep) {
      return 'Correct answer: ${step.answer}';
    } else if (step is ReorderStep) {
      return 'Correct answer: ${step.correctSentence}';
    } else if (step is MatchStep) {
      // Match step is usually auto-graded pair by pair,
      // but if we show a general fail:
      return null;
    }
    return null;
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
