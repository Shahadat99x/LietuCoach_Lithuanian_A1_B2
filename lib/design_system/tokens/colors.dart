import 'package:flutter/material.dart';

/// App color palette definition.
/// Source of Truth: docs/DESIGN_SYSTEM.md
abstract class AppColors {
  // Surfaces
  static const Color surface0Light = Color(0xFFF7F8F6);
  static const Color surface0Dark = Color(0xFF141816);

  static const Color surface1Light = Color(0xFFFFFFFF);
  static const Color surface1Dark = Color(0xFF232B27);

  static const Color surface2Light = Color(0xFFEEF2EE);
  static const Color surface2Dark = Color(0xFF2A332E);

  // Semantic
  static const Color primary = Color(0xFF43A047);
  static const Color primarySoft = Color(0xFFDDF2DF);
  static const Color secondary = Color(0xFFD9A93F);
  static const Color success = Color(0xFF43A047);

  static const Color danger = Color(0xFFD84C4C);
  static const Color dangerBite = Color(0xFFB83E3E);

  static const Color info = Color(0xFF2B70C9);

  // Text
  static const Color textPrimaryLight = Color(0xFF1F2722);
  static const Color textPrimaryDark = Color(0xFFE9EFEA);

  static const Color textSecondaryLight = Color(0xFF5A6660);
  static const Color textSecondaryDark = Color(0xFFB7C1BA);

  static const Color textTertiaryLight = Color(0xFF7D8882);
  static const Color textTertiaryDark = Color(0xFF8C9790);

  // Borders
  static const Color borderSoftLight = Color(0xFFD8DFDA);
  static const Color borderSoftDark = Color(0xFF2F3934);
  static const Color borderStrongLight = Color(0xFFA9B5AE);
  static const Color borderStrongDark = Color(0xFF4B5751);

  // Shadows
  static const Color shadowColor = Color.fromRGBO(16, 24, 20, 0.08);
}
