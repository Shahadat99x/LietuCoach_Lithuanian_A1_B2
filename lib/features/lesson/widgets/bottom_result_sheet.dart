import 'package:flutter/material.dart';
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
    final isCorrect = state == ResultState.correct;

    // Premium Logic:
    // Background: Surface2 (Calm)
    // Accents: Green (Success) / Red (Error) for Icons & Status Text
    // Text: Neutral High-Emphasis for details

    final accentColor = isCorrect ? AppColors.success : AppColors.danger;

    // Surface2 (slightly elevated from bg)
    final backgroundColor = theme.cardTheme.color;

    final icon = isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final iconBgColor = accentColor.withValues(alpha: 0.1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: Spacing.pagePadding,
        right: Spacing.pagePadding,
        top: Spacing.m,
        bottom: Spacing.l, // Extra bottom padding for safety
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
        // Optional top rounded corners
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Radii.xl),
        ),
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
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color:
                        accentColor, // Use accent for title (Correct/Incorrect)
                    fontWeight: FontWeight.bold,
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
                style: theme.textTheme.bodyLarge?.copyWith(
                  color:
                      theme.colorScheme.onSurface, // Neutral text for message
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
              // For Fail state, maybe use a "Danger" variant button?
              // Or keep it Primary (Continuity).
              // Let's stick to Primary for consistent forward motion.
            ),
          ),
        ],
      ),
    );
  }
}
