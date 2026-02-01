/// LietuCoach Design Tokens (DEPRECATED SHIM)
///
/// This file is a facade for the new Design System tokens in `lib/design_system/tokens/`.
/// It exists to maintain backward compatibility while we migrate the app.
///
/// New code should import `package:lietucoach/design_system/tokens/*.dart` directly.

import 'package:flutter/material.dart';
import '../design_system/tokens/spacing.dart' as spacing_ds;
import '../design_system/tokens/radius.dart' as radius_ds;
import '../design_system/tokens/colors.dart' as colors_ds;
import '../design_system/tokens/typography.dart' as typography_ds;

/// Spacing scale (logical pixels)
abstract final class Spacing {
  static const double xxs = spacing_ds.AppSpacing.xxs;
  static const double xs = spacing_ds.AppSpacing.xs;
  static const double s = spacing_ds.AppSpacing.s;
  static const double m = spacing_ds.AppSpacing.m;
  static const double l = spacing_ds.AppSpacing.l;
  static const double xl = spacing_ds.AppSpacing.xl;
  static const double xxl = spacing_ds.AppSpacing.xxl;

  /// Page padding (horizontal)
  static const double pagePadding = spacing_ds.AppSpacing.m;

  /// Section spacing (vertical between sections)
  static const double sectionSpacing = spacing_ds.AppSpacing.xl;
}

/// Border radii
abstract final class Radii {
  static const double sm = radius_ds.AppRadius.sm;
  static const double md = radius_ds.AppRadius.md;
  static const double lg = radius_ds.AppRadius.lg;
  static const double xl = radius_ds.AppRadius.xl;
  static const double xxl = radius_ds.AppRadius.xl; // Map to XL
  static const double full = radius_ds.AppRadius.full;

  static const Radius smRadius = Radius.circular(sm);
  static const Radius mdRadius = Radius.circular(md);
  static const Radius lgRadius = Radius.circular(lg);
  static const Radius xlRadius = Radius.circular(xl);
}

/// Color palette
abstract final class AppColors {
  // Primary brand colors
  static const Color primary = colors_ds.AppColors.primary;
  static const Color primaryLight = colors_ds.AppColors.primarySoft;
  static const Color primaryDark = Color(
    0xFF388E3C,
  ); // Legacy, keep literal or approximate
  static const Color onPrimary = Colors.white;

  // Secondary accent
  static const Color secondary = colors_ds.AppColors.secondary;
  static const Color onSecondary = Colors.black;

  // Surface colors (light mode)
  static const Color surface =
      colors_ds.AppColors.surface1Light; // Card surface
  static const Color surfaceVariant = colors_ds.AppColors.surface2Light;
  static const Color onSurface = colors_ds.AppColors.textPrimaryLight;
  static const Color onSurfaceVariant = colors_ds.AppColors.textSecondaryLight;

  // Background
  static const Color background = colors_ds.AppColors.surface0Light;
  static const Color onBackground = colors_ds.AppColors.textPrimaryLight;

  // Semantic colors
  static const Color success = colors_ds.AppColors.primary;
  static const Color successLight = colors_ds.AppColors.primarySoft;
  static const Color danger = colors_ds.AppColors.danger;
  static const Color dangerLight = Color(0xFFFFEBEE); // Legacy
  static const Color warning = colors_ds.AppColors.secondary;
  static const Color warningLight = Color(0xFFFFF3E0); // Legacy
  static const Color info = colors_ds.AppColors.info;
  static const Color infoLight = Color(0xFFE3F2FD); // Legacy

  // Text colors
  static const Color textPrimary = colors_ds.AppColors.textPrimaryLight;
  static const Color textSecondary = colors_ds.AppColors.textSecondaryLight;
  static const Color textHint = colors_ds.AppColors.textTertiaryLight;

  // Dark mode variants
  static const Color surfaceDark = colors_ds.AppColors.surface1Dark;
  static const Color surfaceVariantDark = colors_ds.AppColors.surface2Dark;
  static const Color backgroundDark = colors_ds.AppColors.surface0Dark;
}

/// Typography styles
abstract final class AppTypography {
  static const String fontFamily = 'Nunito';

  // Mapping old styles to new hierarchy
  static const TextStyle displayLarge =
      typography_ds.AppTypography.titleLarge; // Was 32, now 24
  static const TextStyle headlineLarge =
      typography_ds.AppTypography.titleLarge; // Was 24, now 24
  static const TextStyle headlineMedium =
      typography_ds.AppTypography.titleMedium; // Was 20, now 20
  static const TextStyle titleLarge =
      typography_ds.AppTypography.bodyLarge; // Was 18, now 18
  static const TextStyle titleMedium =
      typography_ds.AppTypography.bodyMedium; // Was 16, now 16 (approx)

  static const TextStyle bodyLarge = typography_ds.AppTypography.bodyLarge;
  static const TextStyle bodyMedium = typography_ds.AppTypography.bodyMedium;
  static const TextStyle bodySmall = typography_ds.AppTypography.bodySmall;

  static const TextStyle labelLarge = typography_ds.AppTypography.labelLarge;

  static const TextStyle caption = typography_ds.AppTypography.caption;
}

/// Elevation values
abstract final class Elevations {
  static const double none = 0;
  static const double sm = 1;
  static const double md = 2;
  static const double lg = 4;
  static const double xl = 8;
}

/// Animation durations
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 600);
}
