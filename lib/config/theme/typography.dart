import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// Parisian Botanical Journal Typography — All-Serif System
///
/// Display/Headlines: Playfair Display (Bold & Italic) — tour titles, screen headers, POI names
///   Tight letter-spacing at -0.02em.
/// Body/UI Text: Cormorant Garamond (400–700) — descriptions, labels, navigation, buttons
///   Elegant but highly legible at small sizes.
/// Labels & Caps: Cormorant Garamond at 10–11px, uppercase, letter-spacing 0.08–0.2em
///   Refined engraved-invitation feel for metadata and category labels.
///
/// No sans-serif fonts anywhere. The all-serif approach is distinctly Parisian.
class AppTypography {
  AppTypography._();

  // ============ FONT FAMILIES ============

  /// Display serif - Playfair Display for headlines & titles
  static String get displayFont => GoogleFonts.playfairDisplay().fontFamily!;

  /// Body serif - Cormorant Garamond for body, labels, navigation, buttons
  static String get bodyFont => GoogleFonts.cormorantGaramond().fontFamily!;

  /// Accent serif - Cormorant Garamond italic for quotes & annotations
  static String get accentFont => GoogleFonts.cormorantGaramond().fontFamily!;

  /// Legacy aliases for backward compatibility
  static String get primaryFont => displayFont;
  static String get monoFont => bodyFont;
  static String get fallbackFont => 'PlusJakartaSans';

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

  /// All-serif text theme: Playfair Display for display/headlines/titles,
  /// Cormorant Garamond for body/labels
  static TextTheme get textTheme {
    final display = GoogleFonts.playfairDisplayTextTheme();
    final body = GoogleFonts.cormorantGaramondTextTheme();

    return TextTheme(
      // Display styles - Playfair Display Bold, tight letter-spacing (-0.02em)
      displayLarge: display.displayLarge?.copyWith(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.12, // -0.02em × 56
        height: 1.1,
      ),
      displayMedium: display.displayMedium?.copyWith(
        fontSize: 44,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.88, // -0.02em × 44
        height: 1.15,
      ),
      displaySmall: display.displaySmall?.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.72, // -0.02em × 36
        height: 1.2,
      ),

      // Headlines - Playfair Display, section headers, -0.02em
      headlineLarge: display.headlineLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.64, // -0.02em × 32
        height: 1.25,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.56, // -0.02em × 28
        height: 1.3,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.48, // -0.02em × 24
        height: 1.35,
      ),

      // Titles - Playfair Display, component headers, -0.02em
      titleLarge: display.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4, // -0.02em × 20
        height: 1.4,
      ),
      titleMedium: display.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.32, // -0.02em × 16
        height: 1.5,
      ),
      titleSmall: display.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.28, // -0.02em × 14
        height: 1.45,
      ),

      // Body - Cormorant Garamond, elegant and legible
      bodyLarge: body.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.6,
      ),
      bodyMedium: body.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.6,
      ),
      bodySmall: body.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.5,
      ),

      // Labels - Cormorant Garamond, UI elements
      labelLarge: body.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        height: 1.4,
      ),
      labelMedium: body.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        height: 1.35,
      ),
      labelSmall: body.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        height: 1.3,
      ),
    );
  }

  // ============ ACCENT STYLES (Cormorant Garamond Italic) ============

  /// Italic accent style for quotes and annotations
  static TextStyle accent({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) => GoogleFonts.cormorantGaramond(
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontStyle: FontStyle.italic,
    letterSpacing: 0.05,
    height: 1.5,
    color: color,
  );

  /// Pull quote style
  static TextStyle get quote =>
      accent(fontSize: 20, fontWeight: FontWeight.w400, color: AppColors.textSecondary);

  /// Annotation / helper text
  static TextStyle get annotation =>
      accent(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textTertiary);

  // ============ LABEL CAPS — Engraved Invitation Style ============

  /// Uppercase label for metadata, categories, and section overlines.
  /// Cormorant Garamond 10–11px, uppercase, letter-spacing 0.08–0.2em.
  static TextStyle labelCaps({
    double fontSize = 11,
    FontWeight fontWeight = FontWeight.w700,
    double letterSpacing = 1.5, // ~0.14em at 11px
    Color? color,
  }) => GoogleFonts.cormorantGaramond(
    fontSize: fontSize,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    height: 1.3,
    color: color ?? AppColors.textTertiary,
  );
  // Note: Apply .toUpperCase() to the text string when using this style.

  /// Category label — small caps feel, wider spacing
  static TextStyle get categoryLabel => labelCaps(
    fontSize: 10,
    letterSpacing: 2.0, // ~0.2em
    color: AppColors.textTertiary,
  );

  /// Section overline — "PROCHAINE ÉTAPE", "PARCOURS 01", etc.
  static TextStyle get sectionOverline =>
      labelCaps(fontSize: 11, letterSpacing: 1.8, color: AppColors.textTertiary);

  // ============ DATA DISPLAY STYLES ============

  /// Tabular style for numeric data display (Cormorant Garamond)
  static TextStyle mono({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) => GoogleFonts.cormorantGaramond(
    fontSize: fontSize,
    fontWeight: fontWeight,
    letterSpacing: 0.05,
    height: 1.5,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Timestamps
  static TextStyle get timestamp =>
      mono(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textTertiary);

  /// Durations
  static TextStyle get duration => mono(fontSize: 14, fontWeight: FontWeight.w700);

  /// Distances
  static TextStyle get distance => mono(fontSize: 13, fontWeight: FontWeight.w700);

  /// Prices
  static TextStyle get price => mono(fontSize: 16, fontWeight: FontWeight.w700);

  // ============ THEMED TEXT THEMES ============

  static TextTheme applyColorToTextTheme(TextTheme theme, Color color) {
    return theme.apply(bodyColor: color, displayColor: color);
  }

  static TextTheme get lightTextTheme => applyColorToTextTheme(textTheme, AppColors.textPrimary);

  static TextTheme get darkTextTheme => applyColorToTextTheme(textTheme, AppColors.textPrimaryDark);

  // ============ HEADING PRESETS ============

  /// Hero heading - largest, most impactful (Playfair Display Bold)
  static TextStyle hero({Color? color}) => GoogleFonts.playfairDisplay(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.96, // -0.02em × 48
    height: 1.1,
    color: color ?? AppColors.textPrimary,
  );

  /// Section heading (Playfair Display Italic)
  static TextStyle section({Color? color}) => GoogleFonts.playfairDisplay(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    letterSpacing: -0.4, // -0.02em × 20
    height: 1.4,
    color: color ?? AppColors.textPrimary,
  );

  /// Overline - uppercase engraved-invitation labels (Cormorant Garamond)
  static TextStyle overline({Color? color}) => GoogleFonts.cormorantGaramond(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.8,
    height: 1.5,
    color: color ?? AppColors.textTertiary,
  );
}
