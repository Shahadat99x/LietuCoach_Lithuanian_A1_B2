/// LietuCoach Theme Configuration
///
/// Material 3 ThemeData built from design tokens.
/// Supports light and dark mode.

import 'package:flutter/material.dart';
import '../design_system/tokens/colors.dart';
import '../design_system/tokens/typography.dart';
import '../design_system/tokens/radius.dart';
import '../design_system/tokens/spacing.dart';

/// Build the app theme from design tokens
ThemeData buildTheme({required Brightness brightness}) {
  final isDark = brightness == Brightness.dark;

  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primarySoft,
    onPrimaryContainer: AppColors.primary, // Darker text on soft bg
    secondary: AppColors.secondary,
    onSecondary: Colors.black,
    secondaryContainer: AppColors.secondary.withValues(alpha: 0.2),
    onSecondaryContainer: AppColors.secondary,
    surface: isDark ? AppColors.surface0Dark : AppColors.surface0Light,
    onSurface: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    surfaceContainerHighest: isDark
        ? AppColors.surface2Dark
        : AppColors.surface2Light,
    onSurfaceVariant: isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight,
    error: AppColors.danger,
    onError: Colors.white,
    errorContainer: AppColors.danger.withValues(alpha: 0.1),
    onErrorContainer: AppColors.danger,
  );

  final textTheme = TextTheme(
    displayLarge: AppTypography.titleLarge.copyWith(
      color: colorScheme.onSurface,
    ),
    headlineLarge: AppTypography.titleLarge.copyWith(
      color: colorScheme.onSurface,
      fontSize: 28, // slight adjustment for headline
    ),
    headlineMedium: AppTypography.titleMedium.copyWith(
      color: colorScheme.onSurface,
    ),
    titleLarge: AppTypography.titleLarge.copyWith(color: colorScheme.onSurface),
    titleMedium: AppTypography.titleMedium.copyWith(
      color: colorScheme.onSurface,
    ),
    bodyLarge: AppTypography.bodyLarge.copyWith(color: colorScheme.onSurface),
    bodyMedium: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurface),
    bodySmall: AppTypography.bodySmall.copyWith(
      color: colorScheme.onSurfaceVariant,
    ),
    labelLarge: AppTypography.labelLarge.copyWith(color: colorScheme.onSurface),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: isDark
        ? AppColors.surface0Dark
        : AppColors.surface0Light,
    appBarTheme: AppBarTheme(
      backgroundColor: isDark
          ? AppColors.surface0Dark
          : AppColors.surface0Light,
      foregroundColor: isDark
          ? AppColors.textPrimaryDark
          : AppColors.textPrimaryLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.titleMedium.copyWith(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
    ),
    cardTheme: CardThemeData(
      color: isDark ? AppColors.surface1Dark : AppColors.surface1Light,
      elevation:
          0, // We control shadow manually usually, but default to 0 for filled cards
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: AppTypography.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        side: BorderSide(color: AppColors.primary),
        textStyle: AppTypography.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTypography.labelLarge,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: isDark
          ? AppColors.surface1Dark
          : AppColors.surface1Light,
      indicatorColor: AppColors.primarySoft,
      labelTextStyle: WidgetStateProperty.all(
        AppTypography.bodySmall.copyWith(fontSize: 12),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.primarySoft.withValues(alpha: 0.3),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: isDark
          ? AppColors.surface2Dark
          : AppColors.surface2Light,
      selectedColor: AppColors.primarySoft,
      labelStyle: AppTypography.bodySmall,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: isDark ? AppColors.borderSoftDark : AppColors.borderSoftLight,
      thickness: 1,
      space: 1,
    ),
  );
}

/// Light theme
final ThemeData lightTheme = buildTheme(brightness: Brightness.light);

/// Dark theme
final ThemeData darkTheme = buildTheme(brightness: Brightness.dark);
