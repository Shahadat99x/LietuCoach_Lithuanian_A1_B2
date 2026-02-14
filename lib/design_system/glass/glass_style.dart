import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../tokens/semantic_tokens.dart';

enum GlassPreset { frost, smoke, solid }

class GlassStyle {
  static GlassPreset _effectivePreset(ThemeData theme, GlassPreset preset) {
    if (preset == GlassPreset.frost && theme.brightness == Brightness.dark) {
      return GlassPreset.smoke;
    }
    return preset;
  }

  static double blurSigma(
    ThemeData theme, {
    double? overrideSigma,
    bool preferPerformance = false,
    bool reduceMotion = false,
    GlassPreset preset = GlassPreset.frost,
  }) {
    final semantic = theme.semanticColors;
    final effectivePreset = _effectivePreset(theme, preset);
    double raw;
    if (effectivePreset == GlassPreset.solid) {
      raw = 0.0;
    } else if (effectivePreset == GlassPreset.smoke &&
        theme.brightness == Brightness.light) {
      raw = overrideSigma ?? (semantic.glassBlurSigma + 2);
    } else {
      raw = overrideSigma ?? semantic.glassBlurSigma;
    }
    if (preferPerformance || reduceMotion) {
      return math.min(raw, 8.0);
    }
    return raw;
  }

  static Color overlayColor(
    ThemeData theme, {
    bool selected = false,
    double? overlayOpacity,
    GlassPreset preset = GlassPreset.frost,
  }) {
    final semantic = theme.semanticColors;
    final effectivePreset = _effectivePreset(theme, preset);

    if (effectivePreset == GlassPreset.solid) {
      final alpha = theme.brightness == Brightness.dark ? 0.94 : 0.96;
      return semantic.surfaceCard.withValues(alpha: alpha);
    }

    final base = selected
        ? semantic.glassOverlaySelected
        : semantic.glassOverlay;
    final defaultOpacity = switch (effectivePreset) {
      GlassPreset.frost => semantic.glassOverlayOpacity,
      GlassPreset.smoke when theme.brightness == Brightness.light => math.min(
        semantic.glassOverlayOpacity + 0.06,
        0.18,
      ),
      GlassPreset.smoke => semantic.glassOverlayOpacity,
      GlassPreset.solid => semantic.glassOverlayOpacity,
    };
    final opacity = overlayOpacity ?? defaultOpacity;
    return base.withValues(alpha: opacity);
  }

  static BorderSide borderSide(
    ThemeData theme, {
    bool selected = false,
    double? opacity,
    GlassPreset preset = GlassPreset.frost,
  }) {
    final semantic = theme.semanticColors;
    final effectivePreset = _effectivePreset(theme, preset);
    final color = selected ? semantic.accentPrimary : semantic.borderSubtle;
    final defaultOpacity = switch (effectivePreset) {
      GlassPreset.frost => semantic.glassBorderOpacity,
      GlassPreset.smoke when theme.brightness == Brightness.light => math.min(
        semantic.glassBorderOpacity + 0.05,
        0.24,
      ),
      GlassPreset.smoke => semantic.glassBorderOpacity,
      GlassPreset.solid when theme.brightness == Brightness.dark => 0.28,
      GlassPreset.solid => 0.18,
    };
    final alpha = opacity ?? defaultOpacity;
    return BorderSide(color: color.withValues(alpha: alpha), width: 1);
  }

  static List<BoxShadow> shadow(
    ThemeData theme, {
    bool elevated = false,
    double? opacity,
    GlassPreset preset = GlassPreset.frost,
  }) {
    final semantic = theme.semanticColors;
    final effectivePreset = _effectivePreset(theme, preset);
    final defaultOpacity = switch (effectivePreset) {
      GlassPreset.frost => semantic.glassShadowOpacity,
      GlassPreset.smoke when theme.brightness == Brightness.light => math.min(
        semantic.glassShadowOpacity + 0.06,
        0.24,
      ),
      GlassPreset.smoke => semantic.glassShadowOpacity,
      GlassPreset.solid when theme.brightness == Brightness.dark => 0.22,
      GlassPreset.solid => 0.12,
    };
    final shadowOpacity = opacity ?? defaultOpacity;
    final blurRadius = switch (effectivePreset) {
      GlassPreset.frost => elevated ? 14.0 : 9.0,
      GlassPreset.smoke => elevated ? 18.0 : 12.0,
      GlassPreset.solid => elevated ? 12.0 : 8.0,
    };
    final offsetY = switch (effectivePreset) {
      GlassPreset.frost => elevated ? 6.0 : 3.0,
      GlassPreset.smoke => elevated ? 8.0 : 4.0,
      GlassPreset.solid => elevated ? 5.0 : 2.0,
    };
    return [
      BoxShadow(
        color: semantic.shadowSoft.withValues(alpha: shadowOpacity),
        blurRadius: blurRadius,
        offset: Offset(0, offsetY),
      ),
    ];
  }

  static LinearGradient? gradient(
    ThemeData theme, {
    GlassPreset preset = GlassPreset.frost,
  }) {
    final effectivePreset = _effectivePreset(theme, preset);
    if (effectivePreset == GlassPreset.solid) return null;

    final isDark = theme.brightness == Brightness.dark;
    final overlayColor = theme.semanticColors.glassOverlay;

    // Top-left shine effect
    final double startOpacity = switch (effectivePreset) {
      GlassPreset.frost => isDark ? 0.12 : 0.45,
      GlassPreset.smoke => isDark ? 0.18 : 0.35,
      _ => 0.0,
    };

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        overlayColor.withValues(alpha: startOpacity),
        overlayColor.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 1.0],
    );
  }
}
