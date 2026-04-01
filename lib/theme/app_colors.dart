import 'package:flutter/material.dart';

/// Brand and theme-independent colors.
/// For theme-sensitive colors (bg, text, border, glass, status variants),
/// use `context.colors` from [AppColorsExtension].
class AppColors {
  AppColors._();

  // Primary (Red - matching website)
  static const Color primary50 = Color(0xFFFEF2F2);
  static const Color primary100 = Color(0xFFFEE2E2);
  static const Color primary200 = Color(0xFFFECACA);
  static const Color primary300 = Color(0xFFFCA5A5);
  static const Color primary400 = Color(0xFFF87171);
  static const Color primary500 = Color(0xFFEF4444);
  static const Color primary = Color(0xFFDC2626);
  static const Color primary700 = Color(0xFFB91C1C);
  static const Color primary800 = Color(0xFF991B1B);

  // Secondary (Green)
  static const Color secondary = Color(0xFF22C55E);
  static const Color secondary700 = Color(0xFF15803D);

  // Status (base hues only — bg/border/text variants are in AppColorsExtension)
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Payment providers
  static const Color payme = Color(0xFF12B5B0);
  static const Color click = Color(0xFF0058FF);
  static const Color uzum = Color(0xFF7B2FBE);

  // Amber accent (pending states)
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);

  // Emerald (CEFR exam type)
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857);

  // Telegram
  static const Color telegram = Color(0xFF0088CC);

  // Google
  static const Color google = Color(0xFF4285F4);
}
