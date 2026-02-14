import 'dart:ui';
import 'package:flutter/material.dart';
import '../tokens/semantic_tokens.dart';
import '../tokens/motion.dart';
import 'glass_style.dart';

class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.margin,
    this.blurSigma,
    this.overlayOpacity,
    this.preset = GlassPreset.frost,
    this.border,
    this.shadow,
    this.clipBehavior = Clip.antiAlias,
    this.preferPerformance = false,
    this.reduceMotion = false,
    this.enableBlur = true,
    this.useRepaintBoundary = false,
  });

  final Widget child;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? blurSigma;
  final double? overlayOpacity;
  final GlassPreset preset;
  final BoxBorder? border;
  final List<BoxShadow>? shadow;
  final Clip clipBehavior;
  final bool preferPerformance;
  final bool reduceMotion;
  final bool enableBlur;
  final bool useRepaintBoundary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adaptiveReduceMotion =
        reduceMotion || AppMotion.reduceMotionOf(context);

    final radius =
        borderRadius ?? BorderRadius.circular(AppSemanticShape.radiusCard);
    final sigma = enableBlur
        ? GlassStyle.blurSigma(
            theme,
            overrideSigma: blurSigma,
            preferPerformance: preferPerformance,
            reduceMotion: adaptiveReduceMotion,
            preset: preset,
          )
        : 0.0;

    final decorated = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: GlassStyle.overlayColor(
          theme,
          overlayOpacity: overlayOpacity,
          preset: preset,
        ),
        gradient: GlassStyle.gradient(theme, preset: preset),
        border:
            border ??
            Border.fromBorderSide(GlassStyle.borderSide(theme, preset: preset)),
        boxShadow: shadow ?? GlassStyle.shadow(theme, preset: preset),
        borderRadius: radius,
      ),
      child: child,
    );

    Widget glassBody;
    if (sigma > 0) {
      glassBody = ClipRRect(
        borderRadius: radius,
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: decorated,
        ),
      );
    } else {
      glassBody = ClipRRect(
        borderRadius: radius,
        clipBehavior: clipBehavior,
        child: decorated,
      );
    }

    if (useRepaintBoundary) {
      glassBody = RepaintBoundary(child: glassBody);
    }

    if (margin != null) {
      return Padding(padding: margin!, child: glassBody);
    }

    return glassBody;
  }
}
