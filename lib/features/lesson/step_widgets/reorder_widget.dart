/// ReorderWidget - Tap-to-build sentence order
///
/// MVP: Tap words to add them to the answer in order.

import 'package:flutter/material.dart';
import '../../../content/content.dart';
import '../../../ui/tokens.dart';

class ReorderWidget extends StatefulWidget {
  final ReorderStep step;
  final bool hasAnswered;
  final void Function(List<int> order, bool isCorrect) onComplete;

  const ReorderWidget({
    super.key,
    required this.step,
    required this.hasAnswered,
    required this.onComplete,
  });

  @override
  State<ReorderWidget> createState() => _ReorderWidgetState();
}

class _ReorderWidgetState extends State<ReorderWidget> {
  final List<int> _selectedOrder = [];
  late List<int> _shuffledIndices;

  @override
  void initState() {
    super.initState();
    // Shuffle word display order
    _shuffledIndices = List.generate(widget.step.words.length, (i) => i);
    _shuffledIndices.shuffle();
  }

  void _onWordTap(int wordIndex) {
    if (widget.hasAnswered) return;
    if (_selectedOrder.contains(wordIndex)) return;

    setState(() {
      _selectedOrder.add(wordIndex);
    });

    // Check if complete
    if (_selectedOrder.length == widget.step.words.length) {
      final isCorrect = _checkAnswer();
      widget.onComplete(_selectedOrder, isCorrect);
    }
  }

  void _onRemoveWord(int position) {
    if (widget.hasAnswered) return;
    setState(() {
      // Remove this and all subsequent words
      while (_selectedOrder.length > position) {
        _selectedOrder.removeLast();
      }
    });
  }

  bool _checkAnswer() {
    if (_selectedOrder.length != widget.step.correctOrder.length) {
      return false;
    }
    for (int i = 0; i < _selectedOrder.length; i++) {
      if (_selectedOrder[i] != widget.step.correctOrder[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Arrange the words',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: Spacing.l),
        
        // Answer area
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.all(Spacing.m),
          decoration: BoxDecoration(
            color: widget.hasAnswered
                ? (_checkAnswer() ? AppColors.successLight : AppColors.dangerLight)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(
              color: widget.hasAnswered
                  ? (_checkAnswer() ? AppColors.success : AppColors.danger)
                  : theme.dividerColor,
            ),
          ),
          child: _selectedOrder.isEmpty
              ? Text(
                  'Tap words below to build the sentence',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              : Wrap(
                  spacing: Spacing.s,
                  runSpacing: Spacing.s,
                  children: List.generate(_selectedOrder.length, (position) {
                    final wordIndex = _selectedOrder[position];
                    return _WordChip(
                      word: widget.step.words[wordIndex],
                      isInAnswer: true,
                      onTap: () => _onRemoveWord(position),
                    );
                  }),
                ),
        ),
        const SizedBox(height: Spacing.l),
        
        // Word bank
        Wrap(
          spacing: Spacing.s,
          runSpacing: Spacing.s,
          children: _shuffledIndices.map((wordIndex) {
            final isUsed = _selectedOrder.contains(wordIndex);
            return _WordChip(
              word: widget.step.words[wordIndex],
              isInAnswer: false,
              isDisabled: isUsed,
              onTap: isUsed ? null : () => _onWordTap(wordIndex),
            );
          }).toList(),
        ),
        
        // Show correct answer after answering
        if (widget.hasAnswered && !_checkAnswer()) ...[
          const SizedBox(height: Spacing.l),
          Text(
            'Correct: ${widget.step.correctSentence}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _WordChip extends StatelessWidget {
  final String word;
  final bool isInAnswer;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _WordChip({
    required this.word,
    required this.isInAnswer,
    this.isDisabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isDisabled
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
          : (isInAnswer
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest),
      borderRadius: BorderRadius.circular(Radii.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.m,
            vertical: Spacing.s,
          ),
          child: Text(
            word,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDisabled
                  ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
