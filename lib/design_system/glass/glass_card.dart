import 'package:flutter/material.dart';
import '../tokens/semantic_tokens.dart';
import 'glass_style.dart';
import 'glass_surface.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    this.child,
    this.leading,
    this.trailing,
    this.title,
    this.subtitle,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blurSigma,
    this.overlayOpacity,
    this.preset = GlassPreset.frost,
    this.preferPerformance = false,
    this.reduceMotion = false,
  });

  final Widget? child;
  final Widget? leading;
  final Widget? trailing;
  final String? title;
  final String? subtitle;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final double? blurSigma;
  final double? overlayOpacity;
  final GlassPreset preset;
  final bool preferPerformance;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius =
        borderRadius ?? BorderRadius.circular(AppSemanticShape.radiusCard);
    final insets = padding ?? const EdgeInsets.all(AppSemanticSpacing.space16);

    final content = child ?? _buildDefaultContent(theme);
    final body = onTap != null
        ? Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              customBorder: RoundedRectangleBorder(borderRadius: radius),
              child: Padding(padding: insets, child: content),
            ),
          )
        : Padding(padding: insets, child: content);

    return GlassSurface(
      margin: margin,
      borderRadius: radius,
      blurSigma: blurSigma,
      overlayOpacity: overlayOpacity,
      preset: preset,
      preferPerformance: preferPerformance,
      reduceMotion: reduceMotion,
      child: body,
    );
  }

  Widget _buildDefaultContent(ThemeData theme) {
    return Row(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AppSemanticSpacing.space12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.semanticColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSemanticSpacing.space4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.semanticColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSemanticSpacing.space12),
          trailing!,
        ],
      ],
    );
  }
}
