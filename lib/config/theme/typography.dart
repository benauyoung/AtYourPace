import 'package:flutter/material.dart';

import 'colors.dart';

/// Minimalist Typography with Geist Font Family
///
/// Geist Sans - Clean, modern sans-serif for UI
/// Geist Mono - Monospace for data, codes, numbers
class AppTypography {
  AppTypography._();

  // ============ FONT FAMILIES ============

  /// Primary font - Geist Sans for all UI text
  static const String primaryFont = 'GeistSans';

  /// Mono font - Geist Mono for data, timestamps, codes
  static const String monoFont = 'GeistMono';

  /// Fallback - Plus Jakarta Sans
  static const String fallbackFont = 'PlusJakartaSans';

  // ============ FONT WEIGHTS ============

  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // ============ TEXT THEME ============

  /// Minimalist text theme with generous line heights
  static TextTheme get textTheme => const TextTheme(
    // Display styles - Large, impactful headers
    displayLarge: TextStyle(
      fontFamily: primaryFont,
      fontSize: 56,
      fontWeight: FontWeight.w300, // Light for elegance
      letterSpacing: -1.5,
      height: 1.1,
    ),
    displayMedium: TextStyle(
      fontFamily: primaryFont,
      fontSize: 44,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.8,
      height: 1.15,
    ),
    displaySmall: TextStyle(
      fontFamily: primaryFont,
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.5,
      height: 1.2,
    ),

    // Headlines - Section headers
    headlineLarge: TextStyle(
      fontFamily: primaryFont,
      fontSize: 32,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.3,
      height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontFamily: primaryFont,
      fontSize: 28,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.2,
      height: 1.3,
    ),
    headlineSmall: TextStyle(
      fontFamily: primaryFont,
      fontSize: 24,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 1.35,
    ),

    // Titles - Component headers
    titleLarge: TextStyle(
      fontFamily: primaryFont,
      fontSize: 20,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 1.4,
    ),
    titleMedium: TextStyle(
      fontFamily: primaryFont,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.5,
    ),
    titleSmall: TextStyle(
      fontFamily: primaryFont,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.45,
    ),

    // Body - Content text with excellent readability
    bodyLarge: TextStyle(
      fontFamily: primaryFont,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      height: 1.6, // Generous line height for readability
    ),
    bodyMedium: TextStyle(
      fontFamily: primaryFont,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.1,
      height: 1.6,
    ),
    bodySmall: TextStyle(
      fontFamily: primaryFont,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.2,
      height: 1.5,
    ),

    // Labels - UI elements, buttons, chips
    labelLarge: TextStyle(
      fontFamily: primaryFont,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.4,
    ),
    labelMedium: TextStyle(
      fontFamily: primaryFont,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.3,
      height: 1.35,
    ),
    labelSmall: TextStyle(
      fontFamily: primaryFont,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.4,
      height: 1.3,
    ),
  );

  // ============ MONOSPACE STYLES ============

  /// Monospace style for data display
  static TextStyle mono({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) => TextStyle(
    fontFamily: monoFont,
    fontSize: fontSize,
    fontWeight: fontWeight,
    letterSpacing: 0,
    height: 1.5,
    color: color,
    fontFeatures: const [
      FontFeature.tabularFigures(), // Aligned numbers
    ],
  );

  /// Monospace for timestamps
  static TextStyle get timestamp => mono(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  /// Monospace for durations
  static TextStyle get duration => mono(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  /// Monospace for distances
  static TextStyle get distance => mono(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  /// Monospace for prices
  static TextStyle get price => mono(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // ============ THEMED TEXT THEMES ============

  static TextTheme applyColorToTextTheme(TextTheme theme, Color color) {
    return theme.apply(
      bodyColor: color,
      displayColor: color,
    );
  }

  static TextTheme get lightTextTheme =>
      applyColorToTextTheme(textTheme, AppColors.textPrimary);

  static TextTheme get darkTextTheme =>
      applyColorToTextTheme(textTheme, AppColors.textPrimaryDark);

  // ============ HEADING PRESETS ============

  /// Hero heading - largest, most impactful
  static TextStyle hero({Color? color}) => TextStyle(
    fontFamily: primaryFont,
    fontSize: 48,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.5,
    height: 1.1,
    color: color ?? AppColors.textPrimary,
  );

  /// Section heading
  static TextStyle section({Color? color}) => TextStyle(
    fontFamily: primaryFont,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
    color: color ?? AppColors.textPrimary,
  );

  /// Overline - small caps style labels
  static TextStyle overline({Color? color}) => TextStyle(
    fontFamily: primaryFont,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    height: 1.5,
    color: color ?? AppColors.textTertiary,
  );
}
