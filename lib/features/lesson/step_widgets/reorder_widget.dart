import 'package:flutter/material.dart';
import '../../../content/content.dart';
import '../../../ui/tokens.dart';
import '../widgets/word_chip.dart';

class ReorderWidget extends StatefulWidget {
  final ReorderStep step;
  final bool hasAnswered;
  final void Function(List<int> order) onOrderChanged;

  const ReorderWidget({
    super.key,
    required this.step,
    required this.hasAnswered,
    required this.onOrderChanged,
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
    widget.onOrderChanged(_selectedOrder);
  }

  void _onRemoveWord(int position) {
    if (widget.hasAnswered) return;
    setState(() {
      // Remove this and all subsequent words
      while (_selectedOrder.length > position + 1) {
        _selectedOrder.removeLast();
      }
      if (_selectedOrder.length > position) {
        _selectedOrder.removeAt(position);
      }
    });
    widget.onOrderChanged(_selectedOrder);
  }

  // Helper to check for coloring (visual only, logic in Runner)
  bool _isCorrect() {
    if (_selectedOrder.length != widget.step.correctOrder.length) return false;
    for (int i = 0; i < _selectedOrder.length; i++) {
      if (_selectedOrder[i] != widget.step.correctOrder[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCorrect = _isCorrect();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Arrange the words', style: theme.textTheme.headlineSmall),
        const SizedBox(height: Spacing.l),

        // Answer area (Tray)
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.all(Spacing.m),
          decoration: BoxDecoration(
            color: widget.hasAnswered
                ? (isCorrect ? AppColors.successLight : AppColors.dangerLight)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(
              color: widget.hasAnswered
                  ? (isCorrect ? AppColors.success : AppColors.danger)
                  : theme.dividerColor,
              width: 2,
            ),
          ),
          child: _selectedOrder.isEmpty
              ? Center(
                  child: Text(
                    'Tap words below to build the sentence',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : Wrap(
                  spacing: Spacing.s,
                  runSpacing: Spacing.s,
                  children: List.generate(_selectedOrder.length, (position) {
                    final wordIndex = _selectedOrder[position];
                    return WordChip(
                      label: widget.step.words[wordIndex],
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
            // Show placeholder if used in tray
            return WordChip(
              label: widget.step.words[wordIndex],
              isPlaceholder: isUsed,
              onTap: isUsed ? null : () => _onWordTap(wordIndex),
            );
          }).toList(),
        ),

        // Show correct answer after answering
        if (widget.hasAnswered && !isCorrect) ...[
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
