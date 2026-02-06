/// DialogueChoiceWidget - Choose response in dialogue context
///
/// Shows context and options for dialogue response.

import 'package:flutter/material.dart';
import '../../../content/content.dart';
import '../../../ui/tokens.dart';
import '../widgets/answer_tile.dart';

class DialogueChoiceWidget extends StatelessWidget {
  final DialogueChoiceStep step;
  final int? selectedIndex;
  final bool hasAnswered;
  final void Function(int) onSelect;

  const DialogueChoiceWidget({
    super.key,
    required this.step,
    required this.selectedIndex,
    required this.hasAnswered,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose the best response',
          style: AppSemanticTypography.section.copyWith(
            color: semantic.textPrimary,
          ),
        ),
        const SizedBox(height: AppSemanticSpacing.space24),

        // Context bubble
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSemanticSpacing.space16),
          decoration: BoxDecoration(
            color: semantic.surfaceElevated,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(Radii.lg),
              topRight: Radius.circular(Radii.lg),
              bottomRight: Radius.circular(Radii.lg),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    'Other person says:',
                    style: AppSemanticTypography.caption.copyWith(
                      color: semantic.accentPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSemanticSpacing.space12),
              Text(
                step.context,
                style: AppSemanticTypography.body.copyWith(
                  color: semantic.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSemanticSpacing.space24),

        Text(
          'Your response:',
          style: AppSemanticTypography.caption.copyWith(
            color: semantic.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSemanticSpacing.space12),

        // Options
        ...List.generate(step.options.length, (index) {
          final isSelected = selectedIndex == index;
          final isCorrect = index == step.correctIndex;
          var state = AnswerState.defaultState;
          if (hasAnswered) {
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
              text: step.options[index],
              state: state,
              leadingKind: AnswerLeadingKind.radio,
              showTrailingStateIcon: hasAnswered,
              onTap: hasAnswered ? null : () => onSelect(index),
            ),
          );
        }),
      ],
    );
  }
}
