import 'package:flutter/material.dart';

import 'colors.dart';

class AppTypography {
  AppTypography._();

  // Dual-font system for personality and readability
  static const String headingFont = 'PlusJakartaSans'; // Modern, geometric for headlines
  static const String bodyFont = 'Inter'; // Readable for body text

  // Enhanced weight scale
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight regular = FontWeight.w400;

  static TextTheme get textTheme => const TextTheme(
        displayLarge: TextStyle(
          fontFamily: headingFont,
          fontSize: 64, // Increased from 57
          fontWeight: FontWeight.w800, // Extra bold
          letterSpacing: -1.5, // Tighter spacing
          height: 1.12,
        ),
        displayMedium: TextStyle(
          fontFamily: headingFont,
          fontSize: 52, // Increased from 45
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          height: 1.16,
        ),
        displaySmall: TextStyle(
          fontFamily: headingFont,
          fontSize: 40, // Increased from 36
          fontWeight: FontWeight.w700, // Bold
          letterSpacing: 0,
          height: 1.22,
        ),
        headlineLarge: TextStyle(
          fontFamily: headingFont,
          fontSize: 32,
          fontWeight: FontWeight.w700, // Bold
          letterSpacing: 0,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontFamily: headingFont,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.29,
        ),
        headlineSmall: TextStyle(
          fontFamily: headingFont,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.33,
        ),
        titleLarge: TextStyle(
          fontFamily: bodyFont, // Inter for titles
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.27,
        ),
        titleMedium: TextStyle(
          fontFamily: bodyFont,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          height: 1.50,
        ),
        titleSmall: TextStyle(
          fontFamily: bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        bodyLarge: TextStyle(
          fontFamily: bodyFont, // Inter for body text
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.60, // Improved from 1.50
        ),
        bodyMedium: TextStyle(
          fontFamily: bodyFont,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.60, // Improved from 1.43
        ),
        bodySmall: TextStyle(
          fontFamily: bodyFont,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.50, // Improved from 1.33
        ),
        labelLarge: TextStyle(
          fontFamily: bodyFont, // Inter for labels
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        labelMedium: TextStyle(
          fontFamily: bodyFont,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.33,
        ),
        labelSmall: TextStyle(
          fontFamily: bodyFont,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.45,
        ),
      );

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
}
