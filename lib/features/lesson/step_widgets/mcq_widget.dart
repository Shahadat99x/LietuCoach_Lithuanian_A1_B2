/// McqWidget - Multiple choice question
///
/// Graded step with radio-style options.

import 'package:flutter/material.dart';
import '../../../content/content.dart';
import '../../../ui/tokens.dart';
import '../widgets/answer_tile.dart';

class McqWidget extends StatelessWidget {
  final McqStep step;
  final int? selectedIndex;
  final bool hasAnswered;
  final void Function(int) onSelect;

  const McqWidget({
    super.key,
    required this.step,
    required this.selectedIndex,
    required this.hasAnswered,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prompt
        Text(step.prompt, style: theme.textTheme.headlineSmall),
        const SizedBox(height: Spacing.l),

        // Options
        ...List.generate(step.options.length, (index) {
          final isSelected = selectedIndex == index;
          final isCorrect = index == step.correctIndex;

          AnswerState state = AnswerState.defaultState;
          if (hasAnswered) {
            if (isCorrect) {
              state = AnswerState.correct;
            } else if (isSelected) {
              state = AnswerState.incorrect;
            } else {
              state = AnswerState.disabled; // or default?
            }
          } else if (isSelected) {
            state = AnswerState.selected;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: Spacing.s),
            child: AnswerTile(
              text: step.options[index],
              state: state,
              shortcutLabel: String.fromCharCode(65 + index), // A, B, C...
              onTap: hasAnswered ? null : () => onSelect(index),
            ),
          );
        }),
      ],
    );
  }
}
