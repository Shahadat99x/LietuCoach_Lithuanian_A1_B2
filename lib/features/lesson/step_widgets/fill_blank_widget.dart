/// FillBlankWidget - Fill in the blank
///
/// Shows sentence with blank and choice buttons.

import 'package:flutter/material.dart';
import '../../../content/content.dart';
import '../../../ui/tokens.dart';
import '../../../ui/components/app_card.dart';

class FillBlankWidget extends StatefulWidget {
  final FillBlankStep step;
  final bool hasAnswered;
  final void Function(String answer) onAnswer;

  const FillBlankWidget({
    super.key,
    required this.step,
    required this.hasAnswered,
    required this.onAnswer,
  });

  @override
  State<FillBlankWidget> createState() => _FillBlankWidgetState();
}

class _FillBlankWidgetState extends State<FillBlankWidget> {
  String? _selectedAnswer;
  late List<String> _choices;

  @override
  void initState() {
    super.initState();
    // Generate choices: correct answer + distractors
    _choices = _generateChoices();
  }

  List<String> _generateChoices() {
    final choices = <String>[widget.step.answer];

    // Add some plausible distractors (simplified - in real app, these would come from content)
    // For now, just use variations
    if (widget.step.answer.length > 2) {
      choices.add('${widget.step.answer}s');
      choices.add(
        widget.step.answer.substring(0, widget.step.answer.length - 1),
      );
    }

    // Ensure we have at least 3 choices
    while (choices.length < 3) {
      choices.add('...');
    }

    choices.shuffle();
    return choices.take(3).toList();
  }

  void _onChoiceTap(String choice) {
    if (widget.hasAnswered) return;
    setState(() {
      _selectedAnswer = choice;
    });
    widget.onAnswer(choice);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;
    final isCorrect =
        _selectedAnswer?.toLowerCase() == widget.step.answer.toLowerCase();

    // Build sentence with blank
    final parts = widget.step.sentence.split(widget.step.blank);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fill in the blank', style: theme.textTheme.headlineSmall),
        const SizedBox(height: Spacing.l),

        // Sentence with blank
        AppCard(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.headlineSmall,
              children: [
                if (parts.isNotEmpty) TextSpan(text: parts[0]),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 80),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.s,
                      vertical: Spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: widget.hasAnswered
                          ? (isCorrect
                                ? semantic.successContainer
                                : semantic.dangerContainer)
                          : theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(Radii.sm),
                      border: Border.all(
                        color: widget.hasAnswered
                            ? (isCorrect ? semantic.success : semantic.danger)
                            : theme.colorScheme.primary,
                      ),
                    ),
                    child: Text(
                      _selectedAnswer ?? '______',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (parts.length > 1) TextSpan(text: parts[1]),
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.l),

        // Choices
        ...List.generate(_choices.length, (index) {
          final choice = _choices[index];
          final isSelected = _selectedAnswer == choice;
          final showAsCorrect =
              widget.hasAnswered &&
              choice.toLowerCase() == widget.step.answer.toLowerCase();

          return Padding(
            padding: const EdgeInsets.only(bottom: Spacing.s),
            child: _ChoiceButton(
              text: choice,
              isSelected: isSelected,
              isCorrect: showAsCorrect,
              showResult: widget.hasAnswered,
              onTap: () => _onChoiceTap(choice),
            ),
          );
        }),
      ],
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool showResult;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.showResult,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;

    Color? backgroundColor;
    Color borderColor = theme.dividerColor;

    if (showResult && isCorrect) {
      backgroundColor = semantic.successContainer;
      borderColor = semantic.success;
    } else if (showResult && isSelected && !isCorrect) {
      backgroundColor = semantic.dangerContainer;
      borderColor = semantic.danger;
    } else if (isSelected) {
      borderColor = theme.colorScheme.primary;
    }

    return Material(
      color: backgroundColor ?? theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(Radii.md),
      child: InkWell(
        onTap: showResult ? null : onTap,
        borderRadius: BorderRadius.circular(Radii.md),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Spacing.m),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          child: Text(
            text,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
