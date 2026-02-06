import 'package:flutter/material.dart';
import '../../design_system/glass/glass.dart';
import '../../ui/tokens.dart';

class CertificateNode extends StatelessWidget {
  final VoidCallback onTap;

  const CertificateNode({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).semanticColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.pagePadding),
      child: Column(
        children: [
          Container(
            width: 3,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSemanticShape.radiusFull),
              color: semantic.accentWarm.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          GlassCard(
            onTap: onTap,
            preferPerformance: true,
            preset: GlassPreset.frost,
            borderRadius: BorderRadius.circular(AppSemanticShape.radiusCard),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(Spacing.s),
                  decoration: BoxDecoration(
                    color: semantic.accentWarm.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: semantic.accentWarm.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Icon(
                    Icons.workspace_premium,
                    color: semantic.accentWarm,
                  ),
                ),
                const SizedBox(width: Spacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Course Complete!',
                        style: AppSemanticTypography.section.copyWith(
                          color: semantic.textPrimary,
                        ),
                      ),
                      Text(
                        'Tap to get your certificate',
                        style: AppSemanticTypography.caption.copyWith(
                          color: semantic.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                GlassPill(
                  minHeight: 0,
                  selected: true,
                  preferPerformance: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSemanticSpacing.space8,
                    vertical: AppSemanticSpacing.space4,
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: semantic.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
