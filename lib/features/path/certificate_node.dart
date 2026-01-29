import 'package:flutter/material.dart';
import '../../ui/tokens.dart';

class CertificateNode extends StatelessWidget {
  final VoidCallback onTap;

  const CertificateNode({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.pagePadding),
      child: Column(
        children: [
          Container(width: 2, height: 24, color: theme.dividerColor),
          const SizedBox(height: Spacing.xs),
          Material(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(Radii.md),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(Radii.md),
              child: Padding(
                padding: const EdgeInsets.all(Spacing.m),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(Spacing.s),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: Spacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Course Complete!',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.brown.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Tap to get your certificate',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.brown.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.brown),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
