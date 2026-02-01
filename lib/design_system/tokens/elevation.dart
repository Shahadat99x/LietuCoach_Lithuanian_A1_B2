import 'package:flutter/material.dart';
import 'colors.dart';

/// App shadows and elevations.
/// Source of Truth: docs/DESIGN_SYSTEM.md
abstract class AppShadows {
  // Soft, diffuse shadow (Modern)
  static final List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // Elevated / Floating
  static final List<BoxShadow> floating = [
    BoxShadow(
      color: AppColors.shadowColor.withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
      spreadRadius: 2,
    ),
  ];

  // Solid "Gamified" Lip (Duolingo style)
  static Color getLipColor(Color baseColor) {
    // Determine a darker shade correctly
    final hsl = HSLColor.fromColor(baseColor);
    return hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor();
  }
}
