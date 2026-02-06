import 'package:flutter/material.dart';
import '../tokens/semantic_tokens.dart';
import 'glass_style.dart';
import 'glass_surface.dart';
import '../../ui/components/scale_button.dart';

class GlassPill extends StatelessWidget {
  const GlassPill({
    super.key,
    required this.child,
    this.selected = false,
    this.onTap,
    this.padding,
    this.margin,
    this.blurSigma,
    this.minHeight,
    this.preset = GlassPreset.frost,
    this.preferPerformance = false,
  });

  final Widget child;
  final bool selected;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? blurSigma;
  final double? minHeight;
  final GlassPreset preset;
  final bool preferPerformance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(AppSemanticShape.radiusFull);
    final semantic = theme.semanticColors;

    final content = PressScale(
      enabled: onTap != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: RoundedRectangleBorder(borderRadius: radius),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: minHeight ?? (onTap != null ? 48 : 0),
            ),
            child: Padding(
              padding:
                  padding ??
                  const EdgeInsets.symmetric(
                    horizontal: AppSemanticSpacing.space12,
                    vertical: AppSemanticSpacing.space8,
                  ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );

    return GlassSurface(
      margin: margin,
      borderRadius: radius,
      blurSigma: blurSigma,
      preset: preset,
      overlayOpacity: selected
          ? semantic.glassOverlayOpacity + 0.08
          : semantic.glassOverlayOpacity,
      border: Border.fromBorderSide(
        GlassStyle.borderSide(theme, selected: selected, preset: preset),
      ),
      shadow: selected
          ? GlassStyle.shadow(theme, elevated: true, preset: preset)
          : GlassStyle.shadow(theme, preset: preset),
      preferPerformance: preferPerformance,
      child: content,
    );
  }
}
