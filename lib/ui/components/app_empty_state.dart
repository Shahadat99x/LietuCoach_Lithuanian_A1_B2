import 'package:flutter/material.dart';
import '../tokens.dart';
import '../components/buttons.dart';

/// Standardized Empty State component
class AppEmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final IconData? icon;
  final Widget? customIcon;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final bool isOffline;

  const AppEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.customIcon,
    this.ctaLabel,
    this.onCta,
    this.isOffline = false,
  });

  factory AppEmptyState.offline({VoidCallback? onRetry}) {
    return AppEmptyState(
      title: 'No Internet Connection',
      message: 'Please check your connection and try again.',
      icon: Icons.wifi_off_rounded,
      ctaLabel: 'Retry',
      onCta: onRetry,
      isOffline: true,
    );
  }

  factory AppEmptyState.comingSoon() {
    return const AppEmptyState(
      title: 'Coming Soon',
      message: 'This feature is under construction.',
      icon: Icons.construction_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (customIcon != null)
              customIcon!
            else if (icon != null)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isOffline
                      ? theme.colorScheme.errorContainer.withValues(alpha: 0.2)
                      : theme.colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: isOffline
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
            const SizedBox(height: Spacing.xl),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: Spacing.s),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (ctaLabel != null && onCta != null) ...[
              const SizedBox(height: Spacing.l),
              PrimaryButton(
                label: ctaLabel!,
                onPressed: onCta,
                icon: isOffline ? Icons.refresh : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
