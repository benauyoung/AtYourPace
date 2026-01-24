import 'package:flutter/material.dart';

/// Spacing and layout constants for consistent spacing throughout the app.
///
/// Provides a standardized spacing scale and commonly used padding/margins.
/// Use these instead of hardcoded values for better consistency and easier maintenance.
class AppSpacing {
  AppSpacing._();

  // Base spacing scale
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Semantic spacing
  static const double sectionGap = 32.0; // Between major sections
  static const double componentGap = 16.0; // Between components
  static const double listItemGap = 12.0; // Between list items
  static const double iconTextGap = 8.0; // Between icons and text

  // Padding presets
  static const EdgeInsets screenPadding = EdgeInsets.all(20);
  static const EdgeInsets cardPadding = EdgeInsets.all(20);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 28,
    vertical: 18,
  );
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 18,
  );
  static const EdgeInsets listPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 12,
  );

  // Border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 999.0; // Pill shape

  // Border radius presets
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius chipRadius = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius dialogRadius = BorderRadius.all(Radius.circular(radiusXxl));

  // Elevation
  static const double elevationXs = 1.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;

  // Icon sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  static const double iconXxl = 64.0;
}
