import 'package:flutter/material.dart';
import '../../../ui/tokens.dart';
import '../../lesson/widgets/answer_tile.dart';
import '../domain/role_model.dart';

class RoleMcqWidget extends StatelessWidget {
  final RoleExercise exercise;
  final int? selectedIndex;
  final bool hasAnswered;
  final void Function(int) onSelect;

  const RoleMcqWidget({
    super.key,
    required this.exercise,
    required this.selectedIndex,
    required this.hasAnswered,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use promptLt (Lithuanian) as primary or promptEn depending on design.
    // Prompt says: "Questions can be in English UI (promptEn), but options can be English".
    // Let's use promptLt if available, else promptEn. Or display both?
    // "Understand" section: promptEn, optionsEn (to test comprehension).
    // "Respond" section: promptEn (Translate...), optionsLt.
    // The model has both.

    final prompt = exercise.promptLt ?? exercise.promptEn ?? '';
    final options = exercise.optionsLt ?? exercise.optionsEn ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prompt
        Text(prompt, style: theme.textTheme.headlineSmall),
        const SizedBox(height: Spacing.l),

        // Options
        ...List.generate(options.length, (index) {
          final isSelected = selectedIndex == index;
          final isCorrect = index == exercise.correctIndex;

          AnswerState state = AnswerState.defaultState;
          if (hasAnswered) {
            // For feedback
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
              text: options[index],
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
