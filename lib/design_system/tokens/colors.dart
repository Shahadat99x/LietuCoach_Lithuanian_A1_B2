import 'package:flutter/material.dart';

/// App color palette definition.
/// Source of Truth: docs/DESIGN_SYSTEM.md
abstract class AppColors {
  // Surfaces
  static const Color surface0Light = Color(0xFFFAFAFA);
  static const Color surface0Dark = Color(0xFF121212);

  static const Color surface1Light = Color(0xFFFFFFFF);
  static const Color surface1Dark = Color(
    0xFF1E1E1E,
  ); // Levels up to 12% overlay

  static const Color surface2Light = Color(0xFFF5F5F5);
  static const Color surface2Dark = Color(0xFF252525);

  // Semantic
  // Semantic
  static const Color primary = Color(
    0xFF43A047,
  ); // Calm Natural Green (Material 600)
  static const Color primarySoft = Color(0xFFE8F5E9); // Pale Mint (Green 50)
  static const Color secondary = Color(0xFFFFC800); // Amber Achieve
  static const Color success = Color(
    0xFF43A047,
  ); // Same as primary for now, or dedicated

  static const Color danger = Color(0xFFFF4B4B);
  static const Color dangerBite = Color(
    0xFFEA2B2B,
  ); // Darker shade for press/border

  static const Color info = Color(0xFF2B70C9);

  // Text
  static const Color textPrimaryLight = Color(0xFF4B4B4B);
  static const Color textPrimaryDark = Color(0xFFE5E5E5);

  static const Color textSecondaryLight = Color(0xFF777777);
  static const Color textSecondaryDark = Color(0xFFA3A3A3);

  static const Color textTertiaryLight = Color(0xFFAFAFAF);
  static const Color textTertiaryDark = Color(0xFF525252);

  // Borders
  static const Color borderSoftLight = Color(0xFFE5E5E5);
  static const Color borderSoftDark = Color(0xFF333333);

  // Shadows
  static const Color shadowColor = Color.fromRGBO(0, 0, 0, 0.1);
}
