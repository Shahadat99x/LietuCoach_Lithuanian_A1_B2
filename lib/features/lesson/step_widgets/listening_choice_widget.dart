/// ListeningChoiceWidget - Listen and choose
///
/// Play audio and select the correct answer.

import 'package:flutter/material.dart';
import '../../../content/content.dart';
import '../../../ui/tokens.dart';
import '../widgets/answer_tile.dart';

class ListeningChoiceWidget extends StatelessWidget {
  final ListeningChoiceStep step;
  final int? selectedIndex;
  final bool hasAnswered;
  final VoidCallback onPlayAudio;
  final void Function(int) onSelect;

  const ListeningChoiceWidget({
    super.key,
    required this.step,
    required this.selectedIndex,
    required this.hasAnswered,
    required this.onPlayAudio,
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
          'What do you hear?',
          style: AppSemanticTypography.section.copyWith(
            color: semantic.textPrimary,
          ),
        ),
        const SizedBox(height: AppSemanticSpacing.space24),

        // Audio play button
        Center(
          child: Material(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(Radii.full),
            child: InkWell(
              onTap: onPlayAudio,
              borderRadius: BorderRadius.circular(Radii.full),
              child: Padding(
                padding: const EdgeInsets.all(AppSemanticSpacing.space24),
                child: Icon(
                  Icons.volume_up,
                  size: 48,
                  color: semantic.accentPrimary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSemanticSpacing.space12),
        Center(
          child: Text(
            'Tap to play',
            style: AppSemanticTypography.caption.copyWith(
              color: semantic.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppSemanticSpacing.space24),

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
