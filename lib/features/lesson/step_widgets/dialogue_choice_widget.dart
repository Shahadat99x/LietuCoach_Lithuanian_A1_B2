/// DialogueChoiceWidget - Choose response in dialogue context
///
/// Shows context and options for dialogue response.

import 'package:flutter/material.dart';
import '../../../content/content.dart';
import '../../../ui/tokens.dart';
import '../../../ui/components/app_card.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose the best response',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: Spacing.l),
        
        // Context bubble
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Spacing.m),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
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
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.s),
              Text(
                step.context,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.l),
        
        Text(
          'Your response:',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.s),
        
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
                      ? borderColor
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
