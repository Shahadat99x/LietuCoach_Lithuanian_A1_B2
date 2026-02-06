/// MatchWidget - Tap-to-match pairs
///
/// MVP: Sequential matching - tap left, then tap right to pair.

import 'package:flutter/material.dart';
import '../../../content/content.dart';
import '../../../ui/tokens.dart';

class MatchWidget extends StatefulWidget {
  final MatchStep step;
  final bool hasAnswered;
  final void Function(bool isCorrect) onComplete;

  const MatchWidget({
    super.key,
    required this.step,
    required this.hasAnswered,
    required this.onComplete,
  });

  @override
  State<MatchWidget> createState() => _MatchWidgetState();
}

class _MatchWidgetState extends State<MatchWidget> {
  int? _selectedLeftIndex;
  final Map<int, int> _matches = {}; // leftIndex -> rightIndex
  late List<int> _shuffledRightIndices;

  @override
  void initState() {
    super.initState();
    // Shuffle right side for challenge
    _shuffledRightIndices = List.generate(widget.step.pairs.length, (i) => i);
    _shuffledRightIndices.shuffle();
  }

  void _onLeftTap(int index) {
    if (widget.hasAnswered || _matches.containsKey(index)) return;
    setState(() {
      _selectedLeftIndex = index;
    });
  }

  void _onRightTap(int shuffledIndex) {
    if (widget.hasAnswered || _selectedLeftIndex == null) return;
    if (_matches.values.contains(shuffledIndex)) return;

    setState(() {
      _matches[_selectedLeftIndex!] = shuffledIndex;
      _selectedLeftIndex = null;
    });

    // Check if all matched
    if (_matches.length == widget.step.pairs.length) {
      _checkAnswers();
    }
  }

  void _checkAnswers() {
    // Check if all pairs are correctly matched
    bool allCorrect = true;
    for (final entry in _matches.entries) {
      final leftIndex = entry.key;
      final shuffledRightIndex = entry.value;
      final actualRightIndex = _shuffledRightIndices[shuffledRightIndex];
      if (leftIndex != actualRightIndex) {
        allCorrect = false;
        break;
      }
    }
    widget.onComplete(allCorrect);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pairs = widget.step.pairs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Match the pairs', style: theme.textTheme.headlineSmall),
        const SizedBox(height: Spacing.s),
        Text(
          'Tap left, then right to match',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.l),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column
            Expanded(
              child: Column(
                children: List.generate(pairs.length, (index) {
                  final isMatched = _matches.containsKey(index);
                  final isSelected = _selectedLeftIndex == index;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.s),
                    child: _MatchTile(
                      text: pairs[index].left,
                      isSelected: isSelected,
                      isMatched: isMatched,
                      isCorrect: widget.hasAnswered && isMatched
                          ? (index == _shuffledRightIndices[_matches[index]!])
                          : null,
                      onTap: () => _onLeftTap(index),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: Spacing.m),
            // Right column (shuffled)
            Expanded(
              child: Column(
                children: List.generate(pairs.length, (shuffledIndex) {
                  final isMatched = _matches.values.contains(shuffledIndex);
                  final actualIndex = _shuffledRightIndices[shuffledIndex];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.s),
                    child: _MatchTile(
                      text: pairs[actualIndex].right,
                      isSelected: false,
                      isMatched: isMatched,
                      isCorrect: null,
                      onTap: () => _onRightTap(shuffledIndex),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MatchTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isMatched;
  final bool? isCorrect;
  final VoidCallback onTap;

  const _MatchTile({
    required this.text,
    required this.isSelected,
    required this.isMatched,
    this.isCorrect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;

    Color backgroundColor = theme.colorScheme.surfaceContainerHighest;
    Color borderColor = Colors.transparent;

    if (isCorrect == true) {
      backgroundColor = semantic.successContainer;
      borderColor = semantic.success;
    } else if (isCorrect == false) {
      backgroundColor = semantic.dangerContainer;
      borderColor = semantic.danger;
    } else if (isSelected) {
      borderColor = theme.colorScheme.primary;
    } else if (isMatched) {
      backgroundColor = theme.colorScheme.primaryContainer;
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(Radii.md),
      child: InkWell(
        onTap: isMatched ? null : onTap,
        borderRadius: BorderRadius.circular(Radii.md),
        child: Container(
          padding: const EdgeInsets.all(Spacing.m),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isMatched ? theme.colorScheme.onPrimaryContainer : null,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
