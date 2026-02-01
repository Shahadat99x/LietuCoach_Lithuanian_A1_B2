/// Exam Runner Screen
///
/// Runs through exam questions with scoring.

import 'dart:math';
import 'package:flutter/material.dart';
import '../../audio/audio.dart';
import '../../content/content.dart';
import '../../ui/tokens.dart';
import '../../ui/components/components.dart';
import '../lesson/widgets/exercise_shell.dart';
import '../lesson/widgets/bottom_result_sheet.dart';
import '../lesson/widgets/answer_tile.dart';
import 'exam_generator.dart';
import 'exam_result_screen.dart';

class ExamRunnerScreen extends StatefulWidget {
  final Unit unit;

  const ExamRunnerScreen({super.key, required this.unit});

  @override
  State<ExamRunnerScreen> createState() => _ExamRunnerScreenState();
}

class _ExamRunnerScreenState extends State<ExamRunnerScreen> {
  late final LocalFileAudioProvider _audioProvider;
  late final List<ExamQuestion> _questions;

  int _currentIndex = 0;
  int _correctCount = 0;
  int? _selectedAnswer;
  bool _hasAnswered = false;
  bool _wasCorrect = false;
  bool _isProcessing = false;

  ExamQuestion get _currentQuestion => _questions[_currentIndex];
  bool get _isLastQuestion => _currentIndex >= _questions.length - 1;
  double get _progress => (_currentIndex + 1) / _questions.length;

  @override
  void initState() {
    super.initState();
    _audioProvider = LocalFileAudioProvider();
    _audioProvider.init();

    // Generate exam questions
    final generator = ExamGenerator(random: Random());
    _questions = generator.generate(widget.unit, questionCount: 12);
  }

  @override
  void dispose() {
    _audioProvider.dispose();
    super.dispose();
  }

  void _onSelectAnswer(int index) {
    if (_hasAnswered || _isProcessing) return;

    setState(() {
      _selectedAnswer = index;
    });
  }

  void _checkAnswer() {
    if (_hasAnswered || _isProcessing) return;
    if (_selectedAnswer == null) return;

    setState(() {
      _isProcessing = true;
      _hasAnswered = true;
      _wasCorrect = _selectedAnswer == _currentQuestion.correctIndex;
      if (_wasCorrect) _correctCount++;
      _isProcessing = false; // logic sync, frame renders next
    });
  }

  void _nextQuestion() {
    if (_isProcessing) return;

    if (_isLastQuestion) {
      _showResults();
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Small delay for safety
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _currentIndex++;
          _selectedAnswer = null;
          _hasAnswered = false;
          _wasCorrect = false;
          _isProcessing = false;
        });
      }
    });
  }

  void _showResults() {
    final score = (_correctCount / _questions.length * 100).round();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ExamResultScreen(
          unit: widget.unit,
          score: score,
          correctCount: _correctCount,
          totalCount: _questions.length,
        ),
      ),
    );
  }

  Future<void> _playAudio(String audioId) async {
    await _audioProvider.play(audioId: audioId, variant: 'normal');
  }

  @override
  Widget build(BuildContext context) {
    return ExerciseShell(
      progress: _progress,
      title: 'Unit Exam',
      onClose: () => _showExitConfirmation(context),
      content: _buildQuestionContent(Theme.of(context)),
      footer: _buildFooter(Theme.of(context)),
    );
  }

  Widget _buildQuestionContent(ThemeData theme) {
    final question = _currentQuestion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Audio button for listening questions
        if (question.type == ExamQuestionType.listeningChoice &&
            question.audioId != null) ...[
          Center(
            child: AudioButton(
              variant: AudioButtonVariant.normal,
              isPlaying: false,
              isLoading: false,
              isDisabled: false,
              onPressed: () => _playAudio(question.audioId!),
            ),
          ),
          const SizedBox(height: Spacing.s),
          Center(
            child: Text(
              'Tap to play',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: Spacing.l),
        ],

        // Prompt
        Text(question.prompt, style: theme.textTheme.headlineSmall),
        const SizedBox(height: Spacing.l),

        // Options
        ...List.generate(question.options.length, (index) {
          final isSelected = _selectedAnswer == index;
          final isCorrect = index == question.correctIndex;

          AnswerState state = AnswerState.defaultState;
          if (_hasAnswered) {
            if (isCorrect) {
              state = AnswerState.correct;
            } else if (isSelected) {
              state = AnswerState.incorrect;
            } else {
              state = AnswerState.disabled;
            }
          } else if (isSelected) {
            state = AnswerState.selected;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: Spacing.s),
            child: AnswerTile(
              text: question.options[index],
              state: state,
              shortcutLabel: String.fromCharCode(65 + index),
              onTap: _hasAnswered ? null : () => _onSelectAnswer(index),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    if (_hasAnswered) {
      return BottomResultSheet(
        state: _wasCorrect ? ResultState.correct : ResultState.incorrect,
        title: _wasCorrect ? 'Correct!' : 'Incorrect',
        message: _wasCorrect
            ? 'Good job!'
            : 'The correct answer was option ${String.fromCharCode(65 + _currentQuestion.correctIndex)}',
        onContinue: _nextQuestion,
      );
    }

    // Check Button
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s),
      width: double.infinity,
      child: PrimaryButton(
        label: 'Check',
        onPressed: _selectedAnswer != null ? _checkAnswer : null,
      ),
    );
  }

  Future<void> _showExitConfirmation(BuildContext context) async {
    final navigator = Navigator.of(context);
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Exit Exam?'),
        content: const Text('Your progress will be lost.'),
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
