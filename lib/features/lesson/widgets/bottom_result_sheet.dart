import 'package:flutter/material.dart';
import '../../../design_system/glass/glass.dart';
import '../../../ui/tokens.dart';
import '../../../ui/components/components.dart';

enum ResultState { correct, incorrect }

class BottomResultSheet extends StatelessWidget {
  final ResultState state;
  final String title;
  final String? message;
  final VoidCallback onContinue;
  final String continueLabel;

  const BottomResultSheet({
    super.key,
    required this.state,
    required this.title,
    this.message,
    required this.onContinue,
    this.continueLabel = 'Continue',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;
    final isCorrect = state == ResultState.correct;

    // Premium Logic:
    // Background: Surface2 (Calm)
    // Accents: Green (Success) / Red (Error) for Icons & Status Text
    // Text: Neutral High-Emphasis for details

    final accentColor = isCorrect ? semantic.success : semantic.danger;

    final icon = isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final iconBgColor = accentColor.withValues(alpha: 0.1);

    return SizedBox(
      width: double.infinity,
      child: GlassSurface(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Radii.xl),
        ),
        clipBehavior: Clip.antiAlias,
        blurSigma: 14,
        preferPerformance: true,
        shadow: GlassStyle.shadow(theme, elevated: true),
        padding: const EdgeInsets.only(
          left: Spacing.pagePadding,
          right: Spacing.pagePadding,
          top: Spacing.m,
          bottom: Spacing.l,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(Spacing.s),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accentColor, size: 28),
                ),
                const SizedBox(width: Spacing.m),
                Expanded(
                  child: Text(
                    title,
                    style: AppSemanticTypography.section.copyWith(
                      color:
                          accentColor, // Use accent for title (Correct/Incorrect)
                    ),
                  ),
                ),
              ],
            ),

            if (message != null) ...[
              const SizedBox(height: Spacing.s),
              Padding(
                padding: const EdgeInsets.only(
                  left: 48 + Spacing.s,
                ), // Align with text start
                child: Text(
                  message!,
                  style: AppSemanticTypography.body.copyWith(
                    color: theme.semanticColors.textPrimary,
                  ),
                ),
              ),
            ],

            const SizedBox(height: Spacing.l),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: continueLabel.toUpperCase(),
                onPressed: onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
