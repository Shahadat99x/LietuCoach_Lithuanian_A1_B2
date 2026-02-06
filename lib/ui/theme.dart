/// LietuCoach Theme Configuration
///
/// Material 3 ThemeData built from semantic design tokens.

import 'package:flutter/material.dart';
import '../design_system/tokens/semantic_tokens.dart';
import '../design_system/tokens/typography.dart';
import '../design_system/tokens/radius.dart';
import '../design_system/tokens/spacing.dart';

ThemeData buildTheme({required Brightness brightness}) {
  final semantic = brightness == Brightness.dark
      ? AppSemanticColors.dark()
      : AppSemanticColors.light();

  final base = ColorScheme.fromSeed(
    seedColor: semantic.accentPrimary,
    brightness: brightness,
  );

  final colorScheme = base.copyWith(
    primary: semantic.accentPrimary,
    onPrimary: semantic.buttonPrimaryText,
    primaryContainer: semantic.successContainer,
    onPrimaryContainer: semantic.accentPrimary,
    secondary: semantic.accentWarm,
    onSecondary: semantic.textPrimary,
    secondaryContainer: semantic.chipBg,
    onSecondaryContainer: semantic.chipText,
    tertiaryContainer: semantic.bgElevated,
    onTertiaryContainer: semantic.textPrimary,
    error: semantic.danger,
    onError: Colors.white,
    errorContainer: semantic.dangerContainer,
    onErrorContainer: semantic.danger,
    surface: semantic.surface,
    onSurface: semantic.textPrimary,
    onSurfaceVariant: semantic.textSecondary,
    outline: semantic.borderStrong,
    outlineVariant: semantic.borderSubtle,
    shadow: semantic.shadowSoft,
    surfaceContainerLowest: semantic.bgElevated,
    surfaceContainerLow: semantic.surface,
    surfaceContainer: semantic.surfaceCard,
    surfaceContainerHigh: semantic.surfaceCard,
    surfaceContainerHighest: semantic.surfaceElevated,
  );

  final textTheme = TextTheme(
    displayLarge: AppTypography.titleLarge.copyWith(
      color: semantic.textPrimary,
    ),
    headlineLarge: AppTypography.titleLarge.copyWith(
      color: semantic.textPrimary,
      fontSize: 28,
    ),
    headlineMedium: AppTypography.titleMedium.copyWith(
      color: semantic.textPrimary,
    ),
    headlineSmall: AppTypography.titleMedium.copyWith(
      color: semantic.textPrimary,
      fontSize: 18,
    ),
    titleLarge: AppTypography.titleLarge.copyWith(color: semantic.textPrimary),
    titleMedium: AppTypography.titleMedium.copyWith(
      color: semantic.textPrimary,
    ),
    titleSmall: AppTypography.bodySmall.copyWith(
      color: semantic.textPrimary,
      fontWeight: FontWeight.w700,
    ),
    bodyLarge: AppTypography.bodyLarge.copyWith(color: semantic.textPrimary),
    bodyMedium: AppTypography.bodyMedium.copyWith(color: semantic.textPrimary),
    bodySmall: AppTypography.bodySmall.copyWith(color: semantic.textSecondary),
    labelLarge: AppTypography.labelLarge.copyWith(color: semantic.textPrimary),
    labelMedium: AppTypography.bodySmall.copyWith(
      color: semantic.textSecondary,
      fontWeight: FontWeight.w700,
    ),
    labelSmall: AppTypography.caption.copyWith(color: semantic.textTertiary),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: semantic.bg,
    extensions: [semantic],
    appBarTheme: AppBarTheme(
      backgroundColor: semantic.bg,
      foregroundColor: semantic.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.titleMedium.copyWith(
        color: semantic.textPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: semantic.surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: semantic.buttonPrimaryBg,
        foregroundColor: semantic.buttonPrimaryText,
        disabledBackgroundColor: semantic.surfaceElevated,
        disabledForegroundColor: semantic.textTertiary,
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
        foregroundColor: semantic.accentPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        side: BorderSide(color: semantic.borderStrong),
        textStyle: AppTypography.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: semantic.accentPrimary,
        textStyle: AppTypography.labelLarge,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: semantic.surfaceCard,
      indicatorColor: semantic.successContainer,
      labelTextStyle: WidgetStateProperty.all(
        AppTypography.bodySmall.copyWith(fontSize: 12),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: semantic.accentPrimary,
      linearTrackColor: semantic.surfaceElevated,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: semantic.chipBg,
      selectedColor: semantic.successContainer,
      labelStyle: AppTypography.bodySmall.copyWith(color: semantic.chipText),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: semantic.borderSubtle,
      thickness: 1,
      space: 1,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: semantic.surfaceCard,
      showDragHandle: true,
    ),
  );
}

final ThemeData lightTheme = buildTheme(brightness: Brightness.light);
final ThemeData darkTheme = buildTheme(brightness: Brightness.dark);
