import 'package:flutter/material.dart';
import '../../../ui/tokens.dart';

class WordChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isPlaceholder; // If true, renders as an empty slot (ghost)
  final bool isSelected; // If true, maybe highlighted (optional)

  const WordChip({
    super.key,
    required this.label,
    this.onTap,
    this.isPlaceholder = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;
    final radius = BorderRadius.circular(AppSemanticShape.radiusFull);

    final color = isPlaceholder
        ? semantic.surfaceElevated.withValues(alpha: 0.55)
        : (isSelected
              ? semantic.accentPrimary.withValues(alpha: 0.16)
              : semantic.surfaceCard);
    final borderColor = isPlaceholder
        ? semantic.borderSubtle.withValues(alpha: 0.8)
        : (isSelected ? semantic.accentPrimary : semantic.borderSubtle);
    final textColor = isPlaceholder
        ? semantic.textTertiary
        : semantic.textPrimary;

    return Opacity(
      opacity: isPlaceholder ? 0.8 : 1,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: radius,
            border: Border.all(color: borderColor),
            boxShadow: [
              if (!isPlaceholder)
                BoxShadow(
                  color: semantic.shadowSoft.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.24 : 0.08,
                  ),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: InkWell(
            onTap: isPlaceholder ? null : onTap,
            borderRadius: radius,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSemanticSpacing.space16,
                  vertical: AppSemanticSpacing.space12,
                ),
                child: Text(
                  label,
                  style: AppSemanticTypography.body.copyWith(
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
