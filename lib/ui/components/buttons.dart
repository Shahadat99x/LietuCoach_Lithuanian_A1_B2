/// Button components - PrimaryButton and SecondaryButton

import 'package:flutter/material.dart';
import '../tokens.dart';
import 'scale_button.dart';

/// PrimaryButton - Filled button for primary actions
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final button = ElevatedButton(
      // If loading, keep enabled style but disable interaction
      onPressed: isLoading ? () {} : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? theme.colorScheme.primary,
        foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
        disabledBackgroundColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.12,
        ),
        disabledForegroundColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.38,
        ),
        elevation: onPressed == null ? 0 : 2,
        animationDuration: AppMotion.duration(
          context,
          AppMotion.normal,
          reduced: AppMotion.fast,
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                // Ensure spinner is visible against primary background
                color: foregroundColor ?? theme.colorScheme.onPrimary,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: Spacing.s),
                ],
                Text(label),
              ],
            ),
    );

    if (isFullWidth) {
      return PressScale(
        enabled: onPressed != null && !isLoading,
        child: SizedBox(width: double.infinity, child: button),
      );
    }

    return PressScale(enabled: onPressed != null && !isLoading, child: button);
  }
}

/// SecondaryButton - Outlined button for secondary actions
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isFullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        animationDuration: AppMotion.duration(
          context,
          AppMotion.normal,
          reduced: AppMotion.fast,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: Spacing.s),
          ],
          Text(label),
        ],
      ),
    );

    if (isFullWidth) {
      return PressScale(
        enabled: onPressed != null,
        child: SizedBox(width: double.infinity, child: button),
      );
    }

    return PressScale(enabled: onPressed != null, child: button);
  }
}
