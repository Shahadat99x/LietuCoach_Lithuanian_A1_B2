import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'typography.dart';

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.bg,
    required this.bgElevated,
    required this.surface,
    required this.surfaceCard,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.borderSubtle,
    required this.borderStrong,
    required this.shadowSoft,
    required this.accentPrimary,
    required this.accentWarm,
    required this.danger,
    required this.success,
    required this.successContainer,
    required this.dangerContainer,
    required this.chipBg,
    required this.chipText,
    required this.buttonPrimaryBg,
    required this.buttonPrimaryText,
    required this.glassOverlay,
    required this.glassOverlaySelected,
    required this.glassBlurSigma,
    required this.glassOverlayOpacity,
    required this.glassBorderOpacity,
    required this.glassShadowOpacity,
  });

  final Color bg;
  final Color bgElevated;
  final Color surface;
  final Color surfaceCard;
  final Color surfaceElevated;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color borderSubtle;
  final Color borderStrong;
  final Color shadowSoft;
  final Color accentPrimary;
  final Color accentWarm;
  final Color danger;
  final Color success;
  final Color successContainer;
  final Color dangerContainer;
  final Color chipBg;
  final Color chipText;
  final Color buttonPrimaryBg;
  final Color buttonPrimaryText;
  final Color glassOverlay;
  final Color glassOverlaySelected;
  final double glassBlurSigma;
  final double glassOverlayOpacity;
  final double glassBorderOpacity;
  final double glassShadowOpacity;

  factory AppSemanticColors.light() {
    return const AppSemanticColors(
      bg: Color(0xFFF7F8F6),
      bgElevated: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      surfaceCard: Color(0xFFFFFFFF),
      surfaceElevated: Color(0xFFEEF2EE),
      textPrimary: Color(0xFF1F2722),
      textSecondary: Color(0xFF5A6660),
      textTertiary: Color(0xFF7D8882),
      borderSubtle: Color(0xFFD8DFDA),
      borderStrong: Color(0xFFA9B5AE),
      shadowSoft: Color.fromRGBO(16, 24, 20, 0.08),
      accentPrimary: Color(0xFF43A047),
      accentWarm: Color(0xFFD9A93F),
      danger: Color(0xFFD84C4C),
      success: Color(0xFF43A047),
      successContainer: Color(0xFFDDF2DF),
      dangerContainer: Color(0xFFF9E0E0),
      chipBg: Color(0xFFECF1ED),
      chipText: Color(0xFF3A463F),
      buttonPrimaryBg: Color(0xFF43A047),
      buttonPrimaryText: Color(0xFFFFFFFF),
      glassOverlay: Color(0xFFFFFFFF),
      glassOverlaySelected: Color(0xFF43A047),
      glassBlurSigma: 16.0,
      glassOverlayOpacity: 0.12,
      glassBorderOpacity: 0.16,
      glassShadowOpacity: 0.16,
    );
  }

  factory AppSemanticColors.dark() {
    return const AppSemanticColors(
      bg: Color(0xFF141816),
      bgElevated: Color(0xFF1A1F1C),
      surface: Color(0xFF1C221F),
      surfaceCard: Color(0xFF232B27),
      surfaceElevated: Color(0xFF2A332E),
      textPrimary: Color(0xFFE9EFEA),
      textSecondary: Color(0xFFB7C1BA),
      textTertiary: Color(0xFF8C9790),
      borderSubtle: Color(0xFF2F3934),
      borderStrong: Color(0xFF4B5751),
      shadowSoft: Color.fromRGBO(0, 0, 0, 0.35),
      accentPrimary: Color(0xFF57B15F),
      accentWarm: Color(0xFFCFA452),
      danger: Color(0xFFF06A6A),
      success: Color(0xFF5CCB70),
      successContainer: Color(0xFF1E3B27),
      dangerContainer: Color(0xFF452325),
      chipBg: Color(0xFF2A342F),
      chipText: Color(0xFFD6E0D9),
      buttonPrimaryBg: Color(0xFF57B15F),
      buttonPrimaryText: Color(0xFF0D140F),
      glassOverlay: Color(0xFF111614),
      glassOverlaySelected: Color(0xFF57B15F),
      glassBlurSigma: 18.0,
      glassOverlayOpacity: 0.24,
      glassBorderOpacity: 0.55,
      glassShadowOpacity: 0.80,
    );
  }

  @override
  AppSemanticColors copyWith({
    Color? bg,
    Color? bgElevated,
    Color? surface,
    Color? surfaceCard,
    Color? surfaceElevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? borderSubtle,
    Color? borderStrong,
    Color? shadowSoft,
    Color? accentPrimary,
    Color? accentWarm,
    Color? danger,
    Color? success,
    Color? successContainer,
    Color? dangerContainer,
    Color? chipBg,
    Color? chipText,
    Color? buttonPrimaryBg,
    Color? buttonPrimaryText,
    Color? glassOverlay,
    Color? glassOverlaySelected,
    double? glassBlurSigma,
    double? glassOverlayOpacity,
    double? glassBorderOpacity,
    double? glassShadowOpacity,
  }) {
    return AppSemanticColors(
      bg: bg ?? this.bg,
      bgElevated: bgElevated ?? this.bgElevated,
      surface: surface ?? this.surface,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderStrong: borderStrong ?? this.borderStrong,
      shadowSoft: shadowSoft ?? this.shadowSoft,
      accentPrimary: accentPrimary ?? this.accentPrimary,
      accentWarm: accentWarm ?? this.accentWarm,
      danger: danger ?? this.danger,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      chipBg: chipBg ?? this.chipBg,
      chipText: chipText ?? this.chipText,
      buttonPrimaryBg: buttonPrimaryBg ?? this.buttonPrimaryBg,
      buttonPrimaryText: buttonPrimaryText ?? this.buttonPrimaryText,
      glassOverlay: glassOverlay ?? this.glassOverlay,
      glassOverlaySelected: glassOverlaySelected ?? this.glassOverlaySelected,
      glassBlurSigma: glassBlurSigma ?? this.glassBlurSigma,
      glassOverlayOpacity: glassOverlayOpacity ?? this.glassOverlayOpacity,
      glassBorderOpacity: glassBorderOpacity ?? this.glassBorderOpacity,
      glassShadowOpacity: glassShadowOpacity ?? this.glassShadowOpacity,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      bg: Color.lerp(bg, other.bg, t)!,
      bgElevated: Color.lerp(bgElevated, other.bgElevated, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      shadowSoft: Color.lerp(shadowSoft, other.shadowSoft, t)!,
      accentPrimary: Color.lerp(accentPrimary, other.accentPrimary, t)!,
      accentWarm: Color.lerp(accentWarm, other.accentWarm, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      chipBg: Color.lerp(chipBg, other.chipBg, t)!,
      chipText: Color.lerp(chipText, other.chipText, t)!,
      buttonPrimaryBg: Color.lerp(buttonPrimaryBg, other.buttonPrimaryBg, t)!,
      buttonPrimaryText: Color.lerp(
        buttonPrimaryText,
        other.buttonPrimaryText,
        t,
      )!,
      glassOverlay: Color.lerp(glassOverlay, other.glassOverlay, t)!,
      glassOverlaySelected: Color.lerp(
        glassOverlaySelected,
        other.glassOverlaySelected,
        t,
      )!,
      glassBlurSigma: lerpDouble(glassBlurSigma, other.glassBlurSigma, t)!,
      glassOverlayOpacity: lerpDouble(
        glassOverlayOpacity,
        other.glassOverlayOpacity,
        t,
      )!,
      glassBorderOpacity: lerpDouble(
        glassBorderOpacity,
        other.glassBorderOpacity,
        t,
      )!,
      glassShadowOpacity: lerpDouble(
        glassShadowOpacity,
        other.glassShadowOpacity,
        t,
      )!,
    );
  }
}

extension ThemeSemanticExtension on ThemeData {
  AppSemanticColors get semanticColors =>
      extension<AppSemanticColors>() ??
      (brightness == Brightness.dark
          ? AppSemanticColors.dark()
          : AppSemanticColors.light());
}

abstract final class AppSemanticShape {
  static const double radiusControl = 12.0;
  static const double radiusCard = 16.0;
  static const double radiusHero = 24.0;
  static const double radiusFull = 999.0;
}

abstract final class AppSemanticSpacing {
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
}

abstract final class AppSemanticTypography {
  static const TextStyle title = AppTypography.titleLarge;
  static const TextStyle section = AppTypography.titleMedium;
  static const TextStyle body = AppTypography.bodyMedium;
  static const TextStyle caption = AppTypography.caption;
}

/// Locked / disabled visual constants — single source of truth.
abstract final class AppDisabledStyle {
  /// Opacity for locked items (cards, tiles)
  static const double lockedOpacity = 0.7;

  /// Opacity for fully disabled / unavailable items
  static const double disabledOpacity = 0.5;

  /// Lock icon size in badges
  static const double lockIconSize = 12.0;
}
