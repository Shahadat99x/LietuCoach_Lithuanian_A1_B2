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
    final semantic = theme.semanticColors;
    final prompt =
        widget.exercise.promptLt ?? widget.exercise.promptEn ?? 'Translate';
    final isCorrect = _isCorrect();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(prompt, style: AppSemanticTypography.section)),
            TextButton.icon(
              onPressed: widget.hasAnswered || _selectedIndices.isEmpty
                  ? null
                  : _onReset,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: AppSemanticSpacing.space4),
        Text(
          'Tap words to build the sentence',
          style: AppSemanticTypography.caption.copyWith(
            color: semantic.textSecondary,
          ),
        ),
        const SizedBox(height: AppSemanticSpacing.space12),

        // Tray
        AnimatedSize(
          duration: AppMotion.normal,
          curve: AppMotion.easeOut,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 84),
            padding: const EdgeInsets.all(Spacing.m),
            decoration: BoxDecoration(
              color: widget.hasAnswered
                  ? (isCorrect
                        ? semantic.successContainer
                        : semantic.dangerContainer)
                  : semantic.surfaceElevated,
              borderRadius: BorderRadius.circular(AppSemanticShape.radiusCard),
              border: Border.all(
                color: widget.hasAnswered
                    ? (isCorrect ? semantic.success : semantic.danger)
                    : semantic.borderSubtle,
                width: 1.5,
              ),
            ),
            child: _selectedIndices.isEmpty
                ? Center(
                    child: Text(
                      'Tap words to build sentence',
                      style: AppSemanticTypography.body.copyWith(
                        color: semantic.textSecondary,
                      ),
                    ),
                  )
                : Wrap(
                    spacing: Spacing.s,
                    runSpacing: Spacing.s,
                    children: List.generate(_selectedIndices.length, (pos) {
                      final index = _selectedIndices[pos];
                      return AnimatedScale(
                        key: ValueKey('tray_${index}_$pos'),
                        scale: 1.0,
                        duration: AppMotion.fast,
                        curve: AppMotion.easeOut,
                        child: WordChip(
                          label: _shuffledWords[index],
                          isSelected: true,
                          onTap: () => _onRemoveIndex(pos),
                        ),
                      );
                    }),
                  ),
          ),
        ),
        const SizedBox(height: Spacing.l),

        // Word Bank
        Wrap(
          spacing: Spacing.s,
          runSpacing: Spacing.s,
          children: List.generate(_shuffledWords.length, (index) {
            final isUsed = _selectedIndices.contains(index);
            return AnimatedOpacity(
              duration: AppMotion.fast,
              opacity: isUsed ? 0.55 : 1,
              child: AnimatedScale(
                duration: AppMotion.fast,
                scale: isUsed ? 0.92 : 1,
                curve: AppMotion.easeOut,
                child: WordChip(
                  label: _shuffledWords[index],
                  isPlaceholder: isUsed,
                  onTap: isUsed ? null : () => _onWordTapIndex(index),
                ),
              ),
            );
          }),
        ),

        // Correction
        if (widget.hasAnswered && !isCorrect) ...[
          const SizedBox(height: Spacing.l),
          Text(
            'Correct: ${widget.exercise.correctSequence?.join(" ")}',
            style: AppSemanticTypography.body.copyWith(
              color: semantic.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  void _onReset() {
    setState(() {
      _selectedIndices.clear();
    });
    _notify();
  }
}
