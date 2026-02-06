import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final prompt = exercise.promptLt ?? exercise.promptEn ?? '';
    final options = exercise.optionsLt ?? exercise.optionsEn ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(prompt, style: AppSemanticTypography.section),
        const SizedBox(height: AppSemanticSpacing.space4),
        Text(
          'Choose one answer',
          style: AppSemanticTypography.caption.copyWith(
            color: theme.semanticColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSemanticSpacing.space12),

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
              leadingKind: AnswerLeadingKind.badge,
              shortcutLabel: String.fromCharCode(65 + index), // A, B, C...
              onTap: hasAnswered
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      onSelect(index);
                    },
            ),
          );
        }),
      ],
    );
  }
}
