import 'package:flutter/material.dart';

/// Minimalist Spacing System
///
/// Generous whitespace for breathability and visual comfort.
/// Based on an 8px grid with larger increments for sections.
class AppSpacing {
  AppSpacing._();

  // ============ BASE SCALE (8px grid) ============

  static const double xxs = 4.0; // Micro spacing
  static const double xs = 8.0; // Tight
  static const double sm = 12.0; // Small
  static const double md = 16.0; // Default
  static const double lg = 24.0; // Comfortable
  static const double xl = 32.0; // Generous
  static const double xxl = 48.0; // Section
  static const double xxxl = 64.0; // Hero

  // ============ SEMANTIC SPACING ============

  /// Between major page sections
  static const double sectionGap = 48.0;

  /// Between components within a section
  static const double componentGap = 24.0;

  /// Between list items
  static const double listItemGap = 16.0;

  /// Between icon and text
  static const double iconTextGap = 12.0;

  /// Between inline elements
  static const double inlineGap = 8.0;

  // ============ PADDING PRESETS ============

  /// Screen-level padding (generous)
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 24, vertical: 20);

  /// Card internal padding (spacious)
  static const EdgeInsets cardPadding = EdgeInsets.all(24);

  /// Compact card padding
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(16);

  /// Button padding (comfortable touch target)
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 32, vertical: 16);

  /// Input field padding
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 18);

  /// List item padding
  static const EdgeInsets listPadding = EdgeInsets.symmetric(horizontal: 24, vertical: 16);

  /// Bottom sheet padding
  static const EdgeInsets sheetPadding = EdgeInsets.fromLTRB(24, 24, 24, 40);

  /// Dialog padding
  static const EdgeInsets dialogPadding = EdgeInsets.all(28);

  // ============ BORDER RADIUS ============

  /// Extra small - subtle rounding
  static const double radiusXs = 6.0;

  /// Small - inputs, small cards
  static const double radiusSm = 10.0;

  /// Medium - buttons, interactive elements
  static const double radiusMd = 12.0;

  /// Large - cards, panels
  static const double radiusLg = 16.0;

  /// Extra large - modals, sheets
  static const double radiusXl = 24.0;

  /// Badge radius
  static const double radiusBadge = 20.0;

  /// Full - pills, circular
  static const double radiusFull = 999.0;

  // ============ BORDER RADIUS PRESETS ============

  /// Card radius (16pt)
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(radiusLg));

  /// Button radius (12pt)
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(radiusMd));

  /// Input field radius (10pt)
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(radiusSm));

  /// Chip/tag radius
  static const BorderRadius chipRadius = BorderRadius.all(Radius.circular(radiusFull));

  /// Badge radius (20pt)
  static const BorderRadius badgeRadius = BorderRadius.all(Radius.circular(radiusBadge));

  /// Dialog radius (24pt)
  static const BorderRadius dialogRadius = BorderRadius.all(Radius.circular(radiusXl));

  /// Bottom sheet radius (24pt top only)
  static const BorderRadius sheetRadius = BorderRadius.only(
    topLeft: Radius.circular(radiusXl),
    topRight: Radius.circular(radiusXl),
  );

  // ============ ICON SIZES ============

  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  static const double iconXxl = 72.0;

  // ============ TOUCH TARGETS ============

  /// Minimum touch target (accessibility)
  static const double minTouchTarget = 48.0;

  /// Comfortable touch target
  static const double touchTarget = 56.0;

  /// Large touch target
  static const double largeTouchTarget = 64.0;

  // ============ CONTENT WIDTHS ============

  /// Maximum content width for readability
  static const double maxContentWidth = 600.0;

  /// Wide content width
  static const double wideContentWidth = 800.0;

  /// Full bleed breakpoint
  static const double fullBleedBreakpoint = 400.0;
}
