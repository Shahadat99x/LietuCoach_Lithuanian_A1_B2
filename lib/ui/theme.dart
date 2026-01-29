/// LietuCoach Theme Configuration
///
/// Material 3 ThemeData built from design tokens.
/// Supports light and dark mode.

import 'package:flutter/material.dart';
import 'tokens.dart';

/// Build the app theme from design tokens
ThemeData buildTheme({required Brightness brightness}) {
  final isDark = brightness == Brightness.dark;

  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondary.withValues(alpha: 0.2),
    onSecondaryContainer: AppColors.secondary,
    surface: isDark ? AppColors.surfaceDark : AppColors.surface,
    onSurface: isDark ? Colors.white : AppColors.onSurface,
    surfaceContainerHighest:
        isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
    onSurfaceVariant:
        isDark ? Colors.white70 : AppColors.onSurfaceVariant,
    error: AppColors.danger,
    onError: Colors.white,
    errorContainer: AppColors.danger.withValues(alpha: 0.2),
    onErrorContainer: AppColors.danger,
  );

  final textTheme = TextTheme(
    displayLarge: AppTypography.displayLarge.copyWith(
      color: colorScheme.onSurface,
    ),
    headlineLarge: AppTypography.headlineLarge.copyWith(
      color: colorScheme.onSurface,
    ),
    headlineMedium: AppTypography.headlineMedium.copyWith(
      color: colorScheme.onSurface,
    ),
    titleLarge: AppTypography.titleLarge.copyWith(
      color: colorScheme.onSurface,
    ),
    titleMedium: AppTypography.titleMedium.copyWith(
      color: colorScheme.onSurface,
    ),
    bodyLarge: AppTypography.bodyLarge.copyWith(
      color: colorScheme.onSurface,
    ),
    bodyMedium: AppTypography.bodyMedium.copyWith(
      color: colorScheme.onSurface,
    ),
    bodySmall: AppTypography.bodySmall.copyWith(
      color: colorScheme.onSurfaceVariant,
    ),
    labelLarge: AppTypography.labelLarge.copyWith(
      color: colorScheme.onSurface,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor:
        isDark ? AppColors.backgroundDark : AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: Elevations.sm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.l,
          vertical: Spacing.m,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
        textStyle: AppTypography.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.l,
          vertical: Spacing.m,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
        side: BorderSide(color: colorScheme.primary),
        textStyle: AppTypography.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        textStyle: AppTypography.labelLarge,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primaryContainer,
      labelTextStyle: WidgetStateProperty.all(
        AppTypography.bodySmall.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colorScheme.primary,
      linearTrackColor: colorScheme.surfaceContainerHighest,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerHighest,
      selectedColor: colorScheme.primaryContainer,
      labelStyle: AppTypography.bodySmall,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.s,
        vertical: Spacing.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.full),
      ),
    ),
  );
}

/// Light theme
final ThemeData lightTheme = buildTheme(brightness: Brightness.light);

/// Dark theme
final ThemeData darkTheme = buildTheme(brightness: Brightness.dark);
