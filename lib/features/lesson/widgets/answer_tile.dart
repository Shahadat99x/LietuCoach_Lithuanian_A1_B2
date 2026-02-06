import 'package:flutter/material.dart';
import '../../../ui/tokens.dart';

enum AnswerState { defaultState, selected, correct, incorrect, disabled }

enum AnswerLeadingKind { none, badge, radio }

class AnswerTile extends StatefulWidget {
  final String text;
  final AnswerState state;
  final VoidCallback? onTap;
  final String? shortcutLabel;
  final AnswerLeadingKind leadingKind;
  final bool showTrailingStateIcon;

  const AnswerTile({
    super.key,
    required this.text,
    this.state = AnswerState.defaultState,
    this.onTap,
    this.shortcutLabel,
    this.leadingKind = AnswerLeadingKind.none,
    this.showTrailingStateIcon = true,
  });

  @override
  State<AnswerTile> createState() => _AnswerTileState();
}

class _AnswerTileState extends State<AnswerTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;
    final reduceMotion = AppMotion.reduceMotionOf(context);
    final transitionDuration = reduceMotion ? AppMotion.fast : AppMotion.normal;
    final radius = BorderRadius.circular(AppSemanticShape.radiusControl);

    Color backgroundColor;
    Color borderColor;
    Color textColor;
    double borderWidth = 1.0;
    final bool isEmphasized =
        widget.state == AnswerState.selected ||
        widget.state == AnswerState.correct ||
        widget.state == AnswerState.incorrect;

    switch (widget.state) {
      case AnswerState.correct:
        backgroundColor = semantic.successContainer;
        borderColor = semantic.success;
        textColor = semantic.textPrimary;
        borderWidth = 2.0;
        break;
      case AnswerState.incorrect:
        backgroundColor = semantic.dangerContainer;
        borderColor = semantic.danger;
        textColor = semantic.textPrimary;
        borderWidth = 2.0;
        break;
      case AnswerState.selected:
        backgroundColor = semantic.accentPrimary.withValues(alpha: 0.14);
        borderColor = semantic.accentPrimary;
        textColor = semantic.textPrimary;
        borderWidth = 2.0;
        break;
      case AnswerState.disabled:
        backgroundColor = semantic.surfaceElevated.withValues(alpha: 0.7);
        borderColor = semantic.borderSubtle.withValues(alpha: 0.7);
        textColor = semantic.textSecondary.withValues(alpha: 0.75);
        borderWidth = 1.0;
        break;
      case AnswerState.defaultState:
        backgroundColor = semantic.surfaceCard;
        borderColor = semantic.borderSubtle;
        textColor = semantic.textPrimary;
        break;
    }

    String semanticLabel = widget.text;
    if (widget.state == AnswerState.selected) {
      semanticLabel = 'Selected: ${widget.text}';
    }
    if (widget.state == AnswerState.correct) {
      semanticLabel = 'Correct: ${widget.text}';
    }
    if (widget.state == AnswerState.incorrect) {
      semanticLabel = 'Incorrect: ${widget.text}';
    }
    if (widget.state == AnswerState.disabled) {
      semanticLabel = 'Disabled: ${widget.text}';
    }

    final shape = RoundedRectangleBorder(
      borderRadius: radius,
      side: BorderSide(color: borderColor, width: borderWidth),
    );
    final shadowAlpha = theme.brightness == Brightness.dark ? 0.3 : 0.1;
    final animatedScale = _isPressed
        ? AppMotion.scaleValue(context, AppMotion.scalePress)
        : AppMotion.scaleRest;

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: widget.state != AnswerState.disabled,
      selected: widget.state == AnswerState.selected,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: AnimatedScale(
          scale: animatedScale,
          duration: reduceMotion ? AppMotion.instant : AppMotion.fast,
          curve: AppMotion.curve(context, AppMotion.easeOut),
          child: Material(
            color: Colors.transparent,
            child: AnimatedContainer(
              duration: transitionDuration,
              curve: AppMotion.curve(context, AppMotion.easeOut),
              decoration: ShapeDecoration(
                color: backgroundColor,
                shape: shape,
                shadows: [
                  if (widget.state == AnswerState.defaultState)
                    BoxShadow(
                      color: semantic.shadowSoft.withValues(alpha: shadowAlpha),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              child: InkWell(
                onTap: widget.state == AnswerState.disabled
                    ? null
                    : widget.onTap,
                onHighlightChanged: (highlighted) {
                  if (widget.state == AnswerState.disabled) return;
                  if (_isPressed == highlighted) return;
                  setState(() => _isPressed = highlighted);
                },
                customBorder: shape,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSemanticSpacing.space16,
                    vertical: AppSemanticSpacing.space12,
                  ),
                  child: Row(
                    children: [
                      if (widget.leadingKind == AnswerLeadingKind.badge &&
                          widget.shortcutLabel != null) ...[
                        _AnswerBadge(
                          label: widget.shortcutLabel!,
                          textColor: textColor,
                          borderColor: semantic.borderSubtle,
                          backgroundColor: semantic.surfaceElevated,
                        ),
                        const SizedBox(width: AppSemanticSpacing.space12),
                      ],
                      if (widget.leadingKind == AnswerLeadingKind.radio) ...[
                        _AnswerRadio(
                          state: widget.state,
                          activeColor: borderColor,
                          inactiveColor: semantic.borderStrong,
                          checkColor: semantic.buttonPrimaryText,
                        ),
                        const SizedBox(width: AppSemanticSpacing.space12),
                      ],
                      Expanded(
                        child: AnimatedDefaultTextStyle(
                          duration: transitionDuration,
                          curve: AppMotion.curve(context, AppMotion.easeOut),
                          style: AppSemanticTypography.body.copyWith(
                            color: textColor,
                            fontWeight: isEmphasized
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          child: Text(widget.text),
                        ),
                      ),
                      if (widget.showTrailingStateIcon &&
                          widget.state == AnswerState.correct)
                        Icon(Icons.check_circle, color: semantic.success),
                      if (widget.showTrailingStateIcon &&
                          widget.state == AnswerState.incorrect)
                        Icon(Icons.cancel, color: semantic.danger),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerBadge extends StatelessWidget {
  const _AnswerBadge({
    required this.label,
    required this.textColor,
    required this.borderColor,
    required this.backgroundColor,
  });

  final String label;
  final Color textColor;
  final Color borderColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSemanticSpacing.space8,
        vertical: AppSemanticSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppSemanticShape.radiusControl),
      ),
      child: Text(
        label,
        style: AppSemanticTypography.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AnswerRadio extends StatelessWidget {
  const _AnswerRadio({
    required this.state,
    required this.activeColor,
    required this.inactiveColor,
    required this.checkColor,
  });

  final AnswerState state;
  final Color activeColor;
  final Color inactiveColor;
  final Color checkColor;

  @override
  Widget build(BuildContext context) {
    final isFilled =
        state == AnswerState.selected ||
        state == AnswerState.correct ||
        state == AnswerState.incorrect;
    final color = isFilled ? activeColor : inactiveColor;

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        color: isFilled ? color : Colors.transparent,
      ),
      child: isFilled ? Icon(Icons.check, size: 14, color: checkColor) : null,
    );
  }
}
