import 'package:flutter/material.dart';

@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  // Backgrounds
  final Color bgPrimary;
  final Color bgSecondary;
  final Color bgTertiary;
  final Color bgPage;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textMuted;
  final Color textWhite;

  // Borders
  final Color border;
  final Color borderLight;
  final Color borderWhite;

  // Glass surfaces
  final Color glassBg;
  final Color glassBgLight;
  final Color glassBorder;
  final Color glassShadow;

  // Status
  final Color successBg;
  final Color successBorder;
  final Color successText;
  final Color warningBg;
  final Color warningBorder;
  final Color warningText;
  final Color errorBg;
  final Color errorBorder;
  final Color errorText;
  final Color infoBg;
  final Color infoBorder;
  final Color infoText;

  // Primary tints (decorative backgrounds)
  final Color primary50;
  final Color primary100;

  // Secondary tints
  final Color secondary50;
  final Color secondary100;

  // Amber tints (pending states)
  final Color amber50;
  final Color amber100;

  // Modal/dialog background
  final Color modalBg;

  // Overlay
  final Color overlay;

  const AppColorsExtension({
    required this.bgPrimary,
    required this.bgSecondary,
    required this.bgTertiary,
    required this.bgPage,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textMuted,
    required this.textWhite,
    required this.border,
    required this.borderLight,
    required this.borderWhite,
    required this.glassBg,
    required this.glassBgLight,
    required this.glassBorder,
    required this.glassShadow,
    required this.successBg,
    required this.successBorder,
    required this.successText,
    required this.warningBg,
    required this.warningBorder,
    required this.warningText,
    required this.errorBg,
    required this.errorBorder,
    required this.errorText,
    required this.infoBg,
    required this.infoBorder,
    required this.infoText,
    required this.primary50,
    required this.primary100,
    required this.secondary50,
    required this.secondary100,
    required this.amber50,
    required this.amber100,
    required this.modalBg,
    required this.overlay,
  });

  static const light = AppColorsExtension(
    bgPrimary: Color(0xFFFFFFFF),
    bgSecondary: Color(0xFFF9FAFB),
    bgTertiary: Color(0xFFF3F4F6),
    bgPage: Color(0xFFF8FAFC),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF4B5563),
    textTertiary: Color(0xFF6B7280),
    textMuted: Color(0xFF9CA3AF),
    textWhite: Color(0xFFFFFFFF),
    border: Color(0xFFE5E7EB),
    borderLight: Color(0x80E5E7EB),
    borderWhite: Color(0x33FFFFFF),
    glassBg: Color(0xB3FFFFFF),
    glassBgLight: Color(0x80FFFFFF),
    glassBorder: Color(0x80E5E7EB),
    glassShadow: Color(0x0D000000),
    successBg: Color(0xFFF0FDF4),
    successBorder: Color(0xFFBBF7D0),
    successText: Color(0xFF15803D),
    warningBg: Color(0xFFFFFBEB),
    warningBorder: Color(0xFFFDE68A),
    warningText: Color(0xFFB45309),
    errorBg: Color(0xFFFEF2F2),
    errorBorder: Color(0xFFFECACA),
    errorText: Color(0xFFDC2626),
    infoBg: Color(0xFFEFF6FF),
    infoBorder: Color(0xFFBFDBFE),
    infoText: Color(0xFF1D4ED8),
    primary50: Color(0xFFFEF2F2),
    primary100: Color(0xFFFEE2E2),
    secondary50: Color(0xFFF0FDF4),
    secondary100: Color(0xFFDCFCE7),
    amber50: Color(0xFFFFFBEB),
    amber100: Color(0xFFFEF3C7),
    modalBg: Color(0xE6FFFFFF),
    overlay: Color(0x80000000),
  );

  static const dark = AppColorsExtension(
    bgPrimary: Color(0xFF121212),
    bgSecondary: Color(0xFF1E1E1E),
    bgTertiary: Color(0xFF2A2A2A),
    bgPage: Color(0xFF0F0F0F),
    textPrimary: Color(0xFFE8E8E8),
    textSecondary: Color(0xFFB0B0B0),
    textTertiary: Color(0xFF8A8A8A),
    textMuted: Color(0xFF666666),
    textWhite: Color(0xFFFFFFFF),
    border: Color(0xFF2E2E2E),
    borderLight: Color(0x802E2E2E),
    borderWhite: Color(0x33FFFFFF),
    glassBg: Color(0xBF1A1A1A),
    glassBgLight: Color(0x801A1A1A),
    glassBorder: Color(0x803A3A3A),
    glassShadow: Color(0x33000000),
    successBg: Color(0xFF1B4332),
    successBorder: Color(0x8015803D),
    successText: Color(0xFF4ADE80),
    warningBg: Color(0xFF4A3520),
    warningBorder: Color(0x80B45309),
    warningText: Color(0xFFFBBF24),
    errorBg: Color(0xFF4A1E1E),
    errorBorder: Color(0x80DC2626),
    errorText: Color(0xFFF87171),
    infoBg: Color(0xFF1A3558),
    infoBorder: Color(0x801D4ED8),
    infoText: Color(0xFF60A5FA),
    primary50: Color(0xFF4A2424),
    primary100: Color(0xFF5E3030),
    secondary50: Color(0xFF1B4332),
    secondary100: Color(0xFF245A3A),
    amber50: Color(0xFF4A3820),
    amber100: Color(0xFF5E4A28),
    modalBg: Color(0xF21E1E1E),
    overlay: Color(0xB3000000),
  );

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? bgPrimary,
    Color? bgSecondary,
    Color? bgTertiary,
    Color? bgPage,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textMuted,
    Color? textWhite,
    Color? border,
    Color? borderLight,
    Color? borderWhite,
    Color? glassBg,
    Color? glassBgLight,
    Color? glassBorder,
    Color? glassShadow,
    Color? successBg,
    Color? successBorder,
    Color? successText,
    Color? warningBg,
    Color? warningBorder,
    Color? warningText,
    Color? errorBg,
    Color? errorBorder,
    Color? errorText,
    Color? infoBg,
    Color? infoBorder,
    Color? infoText,
    Color? primary50,
    Color? primary100,
    Color? secondary50,
    Color? secondary100,
    Color? amber50,
    Color? amber100,
    Color? modalBg,
    Color? overlay,
  }) {
    return AppColorsExtension(
      bgPrimary: bgPrimary ?? this.bgPrimary,
      bgSecondary: bgSecondary ?? this.bgSecondary,
      bgTertiary: bgTertiary ?? this.bgTertiary,
      bgPage: bgPage ?? this.bgPage,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textMuted: textMuted ?? this.textMuted,
      textWhite: textWhite ?? this.textWhite,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
      borderWhite: borderWhite ?? this.borderWhite,
      glassBg: glassBg ?? this.glassBg,
      glassBgLight: glassBgLight ?? this.glassBgLight,
      glassBorder: glassBorder ?? this.glassBorder,
      glassShadow: glassShadow ?? this.glassShadow,
      successBg: successBg ?? this.successBg,
      successBorder: successBorder ?? this.successBorder,
      successText: successText ?? this.successText,
      warningBg: warningBg ?? this.warningBg,
      warningBorder: warningBorder ?? this.warningBorder,
      warningText: warningText ?? this.warningText,
      errorBg: errorBg ?? this.errorBg,
      errorBorder: errorBorder ?? this.errorBorder,
      errorText: errorText ?? this.errorText,
      infoBg: infoBg ?? this.infoBg,
      infoBorder: infoBorder ?? this.infoBorder,
      infoText: infoText ?? this.infoText,
      primary50: primary50 ?? this.primary50,
      primary100: primary100 ?? this.primary100,
      secondary50: secondary50 ?? this.secondary50,
      secondary100: secondary100 ?? this.secondary100,
      amber50: amber50 ?? this.amber50,
      amber100: amber100 ?? this.amber100,
      modalBg: modalBg ?? this.modalBg,
      overlay: overlay ?? this.overlay,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      bgPrimary: Color.lerp(bgPrimary, other.bgPrimary, t)!,
      bgSecondary: Color.lerp(bgSecondary, other.bgSecondary, t)!,
      bgTertiary: Color.lerp(bgTertiary, other.bgTertiary, t)!,
      bgPage: Color.lerp(bgPage, other.bgPage, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textWhite: Color.lerp(textWhite, other.textWhite, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      borderWhite: Color.lerp(borderWhite, other.borderWhite, t)!,
      glassBg: Color.lerp(glassBg, other.glassBg, t)!,
      glassBgLight: Color.lerp(glassBgLight, other.glassBgLight, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassShadow: Color.lerp(glassShadow, other.glassShadow, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      successBorder: Color.lerp(successBorder, other.successBorder, t)!,
      successText: Color.lerp(successText, other.successText, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      warningBorder: Color.lerp(warningBorder, other.warningBorder, t)!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
      errorBg: Color.lerp(errorBg, other.errorBg, t)!,
      errorBorder: Color.lerp(errorBorder, other.errorBorder, t)!,
      errorText: Color.lerp(errorText, other.errorText, t)!,
      infoBg: Color.lerp(infoBg, other.infoBg, t)!,
      infoBorder: Color.lerp(infoBorder, other.infoBorder, t)!,
      infoText: Color.lerp(infoText, other.infoText, t)!,
      primary50: Color.lerp(primary50, other.primary50, t)!,
      primary100: Color.lerp(primary100, other.primary100, t)!,
      secondary50: Color.lerp(secondary50, other.secondary50, t)!,
      secondary100: Color.lerp(secondary100, other.secondary100, t)!,
      amber50: Color.lerp(amber50, other.amber50, t)!,
      amber100: Color.lerp(amber100, other.amber100, t)!,
      modalBg: Color.lerp(modalBg, other.modalBg, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>()!;
}
