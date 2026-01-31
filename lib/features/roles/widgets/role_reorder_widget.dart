import 'package:flutter/material.dart';
import '../../../ui/tokens.dart';
import '../../lesson/widgets/word_chip.dart';
import '../domain/role_model.dart';

class RoleReorderWidget extends StatefulWidget {
  final RoleExercise exercise;
  final bool hasAnswered;
  final void Function(List<String> order) onOrderChanged;

  const RoleReorderWidget({
    super.key,
    required this.exercise,
    required this.hasAnswered,
    required this.onOrderChanged,
  });

  @override
  State<RoleReorderWidget> createState() => _RoleReorderWidgetState();
}

class _RoleReorderWidgetState extends State<RoleReorderWidget> {
  late List<String> _shuffledWords;

  @override
  void initState() {
    super.initState();
    // Correct sequence is in correctSequence
    // We need to shuffle them.
    final words = List<String>.from(widget.exercise.correctSequence ?? []);
    words.shuffle();
    _shuffledWords = words;
  }

  // Refactor to use indices to handle duplicate words correctly
  final List<int> _selectedIndices = [];

  void _onWordTapIndex(int index) {
    if (widget.hasAnswered) return;
    if (_selectedIndices.contains(index)) return;

    setState(() {
      _selectedIndices.add(index);
    });
    _notify();
  }

  void _onRemoveIndex(int position) {
    if (widget.hasAnswered) return;
    setState(() {
      if (_selectedIndices.length > position) {
        _selectedIndices.removeAt(position);
        // Do we remove subsequent ones? Main app ReorderWidget does.
        // Let's keep it simple: just remove the tapped one.
      }
    });
    _notify();
  }

  void _notify() {
    final words = _selectedIndices.map((i) => _shuffledWords[i]).toList();
    widget.onOrderChanged(words);
  }

  bool _isCorrect() {
    final currentWords = _selectedIndices
        .map((i) => _shuffledWords[i])
        .toList();
    final correct = widget.exercise.correctSequence ?? [];
    if (currentWords.length != correct.length) return false;
    for (int i = 0; i < currentWords.length; i++) {
      if (currentWords[i] != correct[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prompt =
        widget.exercise.promptLt ?? widget.exercise.promptEn ?? 'Translate';
    final isCorrect = _isCorrect();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(prompt, style: theme.textTheme.headlineSmall),
        const SizedBox(height: Spacing.l),

        // Tray
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
          child: _selectedIndices.isEmpty
              ? Center(
                  child: Text(
                    'Tap words to build sentence',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : Wrap(
                  spacing: Spacing.s,
                  runSpacing: Spacing.s,
                  children: List.generate(_selectedIndices.length, (pos) {
                    final index = _selectedIndices[pos];
                    return WordChip(
                      label: _shuffledWords[index],
                      onTap: () => _onRemoveIndex(pos),
                    );
                  }),
                ),
        ),
        const SizedBox(height: Spacing.l),

        // Word Bank
        Wrap(
          spacing: Spacing.s,
          runSpacing: Spacing.s,
          children: List.generate(_shuffledWords.length, (index) {
            final isUsed = _selectedIndices.contains(index);
            return WordChip(
              label: _shuffledWords[index],
              isPlaceholder: isUsed,
              onTap: isUsed ? null : () => _onWordTapIndex(index),
            );
          }),
        ),

        // Correction
        if (widget.hasAnswered && !isCorrect) ...[
          const SizedBox(height: Spacing.l),
          Text(
            'Correct: ${widget.exercise.correctSequence?.join(" ")}',
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
