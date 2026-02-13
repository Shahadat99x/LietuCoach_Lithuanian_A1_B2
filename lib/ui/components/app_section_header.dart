/// AppSectionHeader — consistent section label for grouped content.
///
/// Used for "GENERAL", "SUPPORT", "Practice Modes", etc.

import 'package:flutter/material.dart';
import '../../design_system/tokens/semantic_tokens.dart';
import '../../design_system/tokens/typography.dart';

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.uppercase = true,
    this.padding,
  });

  final String title;

  /// Whether to uppercase the title (default: true for section labels).
  final bool uppercase;

  /// Override padding. Default: horizontal 8, vertical 12.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;

    return Padding(
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSemanticSpacing.space8,
            vertical: AppSemanticSpacing.space12,
          ),
      child: Text(
        uppercase ? title.toUpperCase() : title,
        style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: semantic.textSecondary,
        ),
      ),
    );
  }
}
