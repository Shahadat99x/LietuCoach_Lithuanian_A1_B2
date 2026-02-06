import 'package:flutter/material.dart';
import '../../../../design_system/glass/glass.dart';
import '../../../../ui/tokens.dart';

class SettingsSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSectionCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xs,
            vertical: Spacing.s,
          ),
          child: Text(
            title.toUpperCase(),
            style: AppSemanticTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: theme.semanticColors.textSecondary,
            ),
          ),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          preset: GlassPreset.solid,
          preferPerformance: true,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  const GlassDivider(indent: Spacing.m, endIndent: Spacing.m),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
