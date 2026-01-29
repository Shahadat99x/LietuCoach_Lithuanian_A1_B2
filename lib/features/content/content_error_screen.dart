import 'package:flutter/material.dart';
import '../../ui/tokens.dart';
import '../../ui/components/components.dart';

class ContentErrorScreen extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const ContentErrorScreen({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Error',
      showAppBar: true,
      body: Padding(
        padding: const EdgeInsets.all(Spacing.pagePadding),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: Spacing.l),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.m),
              Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.xl),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(label: 'Retry', onPressed: onRetry),
              ),
              const SizedBox(height: Spacing.m),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
