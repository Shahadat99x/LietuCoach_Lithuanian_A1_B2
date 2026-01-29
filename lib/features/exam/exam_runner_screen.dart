/// Exam Runner Screen
///
/// Runs through exam questions with scoring.

import 'dart:math';
import 'package:flutter/material.dart';
import '../../audio/audio.dart';
import '../../content/content.dart';
import '../../ui/tokens.dart';
import '../../ui/components/components.dart';
import 'exam_generator.dart';
import 'exam_result_screen.dart';

class ExamRunnerScreen extends StatefulWidget {
  final Unit unit;

  const ExamRunnerScreen({
    super.key,
    required this.unit,
  });

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
    if (_hasAnswered) return;

    setState(() {
      _selectedAnswer = index;
      _hasAnswered = true;
      _wasCorrect = index == _currentQuestion.correctIndex;
      if (_wasCorrect) _correctCount++;
    });
  }

  void _nextQuestion() {
    if (_isLastQuestion) {
      _showResults();
      return;
    }

    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
      _hasAnswered = false;
      _wasCorrect = false;
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Exam'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitConfirmation(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress
            Padding(
              padding: const EdgeInsets.all(Spacing.m),
              child: Column(
                children: [
                  ProgressBar(value: _progress),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    'Question ${_currentIndex + 1} of ${_questions.length}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            
            // Question content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Spacing.pagePadding),
                child: _buildQuestionContent(theme),
              ),
            ),
            
            // Bottom section
            _buildBottomSection(theme),
          ],
        ),
      ),
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
            child: Material(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(Radii.full),
              child: InkWell(
                onTap: () => _playAudio(question.audioId!),
                borderRadius: BorderRadius.circular(Radii.full),
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.l),
                  child: Icon(
                    Icons.volume_up,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
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
        Text(
          question.prompt,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: Spacing.l),
        
        // Options
        ...List.generate(question.options.length, (index) {
          final isSelected = _selectedAnswer == index;
          final isCorrect = index == question.correctIndex;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: Spacing.s),
            child: _OptionCard(
              text: question.options[index],
              isSelected: isSelected,
              isCorrect: _hasAnswered ? isCorrect : null,
              showResult: _hasAnswered,
              onTap: () => _onSelectAnswer(index),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(Spacing.pagePadding),
      decoration: BoxDecoration(
        color: _hasAnswered
            ? (_wasCorrect ? AppColors.successLight : AppColors.dangerLight)
            : theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_hasAnswered) ...[
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
          
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: _isLastQuestion ? 'See Results' : 'Next',
              onPressed: _hasAnswered ? _nextQuestion : null,
            ),
          ),
        ],
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

class _OptionCard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool? isCorrect;
  final bool showResult;
  final VoidCallback onTap;

  const _OptionCard({
    required this.text,
    required this.isSelected,
    this.isCorrect,
    required this.showResult,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color? backgroundColor;
    Color borderColor = theme.dividerColor;
    
    if (showResult && isCorrect == true) {
      backgroundColor = AppColors.successLight;
      borderColor = AppColors.success;
    } else if (showResult && isSelected && isCorrect == false) {
      backgroundColor = AppColors.dangerLight;
      borderColor = AppColors.danger;
    } else if (isSelected) {
      borderColor = theme.colorScheme.primary;
    }

    return Material(
      color: backgroundColor ?? theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(Radii.md),
      child: InkWell(
        onTap: showResult ? null : onTap,
        borderRadius: BorderRadius.circular(Radii.md),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Spacing.m),
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          child: Text(
            text,
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
