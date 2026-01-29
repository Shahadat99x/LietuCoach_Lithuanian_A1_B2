/// ListeningChoiceWidget - Listen and choose
///
/// Play audio and select the correct answer.

import 'package:flutter/material.dart';
import '../../../content/content.dart';
import '../../../ui/tokens.dart';
import '../../../ui/components/app_card.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What do you hear?',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: Spacing.l),
        
        // Audio play button
        Center(
          child: Material(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(Radii.full),
            child: InkWell(
              onTap: onPlayAudio,
              borderRadius: BorderRadius.circular(Radii.full),
              child: Padding(
                padding: const EdgeInsets.all(Spacing.l),
                child: Icon(
                  Icons.volume_up,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Spacing.s),
        Center(
          child: Text(
            'Tap to play',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: Spacing.l),
        
        // Options
        ...List.generate(step.options.length, (index) {
          final isSelected = selectedIndex == index;
          final isCorrect = index == step.correctIndex;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: Spacing.s),
            child: _OptionCard(
              text: step.options[index],
              isSelected: isSelected,
              isCorrect: hasAnswered ? isCorrect : null,
              showResult: hasAnswered,
              onTap: hasAnswered ? null : () => onSelect(index),
            ),
          );
        }),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool? isCorrect;
  final bool showResult;
  final VoidCallback? onTap;

  const _OptionCard({
    required this.text,
    required this.isSelected,
    this.isCorrect,
    required this.showResult,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color? backgroundColor;
    Color borderColor = theme.dividerColor;
    
    if (showResult && isCorrect == true) {
      backgroundColor = AppColors.successLight;
      borderColor = AppColors.success;
    } else if (showResult && isSelected && isCorrect == false) {
      backgroundColor = AppColors.dangerLight;
      borderColor = AppColors.danger;
    } else if (isSelected) {
      borderColor = theme.colorScheme.primary;
    }

    return AppCard(
      color: backgroundColor,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        padding: const EdgeInsets.all(Spacing.m),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                      ? (borderColor)
                      : theme.colorScheme.outline,
                  width: 2,
                ),
                color: isSelected ? borderColor : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: Spacing.m),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
