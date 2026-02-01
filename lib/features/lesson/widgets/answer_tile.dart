import 'package:flutter/material.dart';
import '../../../ui/tokens.dart';
import '../../../ui/components/components.dart';

enum AnswerState { defaultState, selected, correct, incorrect, disabled }

class AnswerTile extends StatelessWidget {
  final String text;
  final AnswerState state;
  final VoidCallback? onTap;
  final String?
  shortcutLabel; // e.g. "1", "A" if we want keyboard shortcuts later

  const AnswerTile({
    super.key,
    required this.text,
    this.state = AnswerState.defaultState,
    this.onTap,
    this.shortcutLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Design Tokens mapped to states
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    double borderWidth = 1.0;

    switch (state) {
      case AnswerState.correct:
        backgroundColor = AppColors.successLight;
        borderColor = AppColors.success; // Or darker shade
        textColor = AppColors.success;
        borderWidth = 2.0;
        break;
      case AnswerState.incorrect:
        backgroundColor = AppColors.dangerLight;
        borderColor = AppColors.danger;
        textColor = AppColors.danger;
        borderWidth = 2.0;
        break;
      case AnswerState.selected:
        backgroundColor = theme.colorScheme.primaryContainer.withValues(
          alpha: 0.3,
        );
        borderColor = theme.colorScheme.primary;
        textColor = theme.colorScheme.primary;
        borderWidth = 2.0;
        break;
      case AnswerState.disabled:
        backgroundColor = theme.colorScheme.surfaceContainerLow;
        borderColor = theme.colorScheme.outline.withValues(alpha: 0.2);
        textColor = theme.colorScheme.onSurface.withValues(alpha: 0.38);
        borderWidth = 1.0;
        break;
      case AnswerState.defaultState:
        backgroundColor = theme.colorScheme.surface;
        borderColor = theme.colorScheme.outlineVariant;
        textColor = theme.colorScheme.onSurface;
        break;
    }

    String semanticLabel = text;
    if (state == AnswerState.selected) semanticLabel = 'Selected: $text';
    if (state == AnswerState.correct) semanticLabel = 'Correct: $text';
    if (state == AnswerState.incorrect) semanticLabel = 'Incorrect: $text';
    if (state == AnswerState.disabled) semanticLabel = 'Disabled: $text';

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: state != AnswerState.disabled,
      selected: state == AnswerState.selected,
      child: ScaleButton(
        onTap: state == AnswerState.disabled ? null : onTap,
        child: AppCard(
          color: backgroundColor,
          padding: EdgeInsets.zero,
          elevation: state == AnswerState.defaultState ? 2.0 : 0.0,
          // flatten when colored/selected? or keep elevation?
          // Duolingo usually flattens selected items or gives them a thick "3D" bottom border.
          // For now, let's keep it simple.
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.m,
              vertical: Spacing.m + 2, // Slightly taller for touch target
            ),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: borderWidth),
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Row(
              children: [
                if (shortcutLabel != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      shortcutLabel!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.m),
                ],

                Expanded(
                  child: Text(
                    text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: textColor,
                      fontWeight:
                          state == AnswerState.selected ||
                              state == AnswerState.correct ||
                              state == AnswerState.incorrect
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),

                // Trailing Status Icon (optional but good for accessibility/clarity)
                if (state == AnswerState.correct)
                  const Icon(Icons.check_circle, color: AppColors.success),
                if (state == AnswerState.incorrect)
                  const Icon(Icons.cancel, color: AppColors.danger),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
