import 'dart:ui';

/// Boutique Editorial Layering System
///
/// Defines the 5-plane Z-index architecture for the "vintage cartographer's desk"
/// visual metaphor. Each plane has specific blur, opacity, and elevation rules.
///
/// Z-Level 0: Parchment Ground — textured background
/// Z-Level 1: Ink Illustration — isometric map / lithograph artwork
/// Z-Level 2: Glass Panels — cards, sheets, modals
/// Z-Level 3: Interactive Layer — buttons, inputs, nav
/// Z-Level 4: Overlay/Toast — snackbars, tooltips, loading
class AppLayering {
  AppLayering._();

  // ============ Z-INDEX LEVELS ============

  /// Parchment Ground — textured background (cream paper)
  static const int zParchmentGround = 0;

  /// Ink Illustration — isometric map / lithograph artwork
  static const int zInkIllustration = 1;

  /// Glass Panels — cards, sheets, modals (frosted glass)
  static const int zGlassPanels = 2;

  /// Interactive Layer — buttons, inputs, navigation
  static const int zInteractive = 3;

  /// Overlay/Toast — snackbars, tooltips, loading screens
  static const int zOverlay = 4;

  // ============ BLUR SIGMA VALUES ============

  /// No blur — for ground and illustration layers
  static const double blurNone = 0.0;

  /// Light blur — subtle glass effect for interactive elements
  static const double blurLight = 10.0;

  /// Medium blur — standard glass panels
  static const double blurMedium = 20.0;

  /// Heavy blur — modals, bottom sheets, overlays
  static const double blurHeavy = 30.0;

  // ============ OPACITY VALUES ============

  /// Full opacity — ground and illustration layers
  static const double opacityFull = 1.0;

  /// Heavy glass — 85% for modals, bottom sheets
  static const double opacityHeavy = 0.85;

  /// Medium glass — 65% for standard cards
  static const double opacityMedium = 0.65;

  /// Light glass — 40% for subtle overlays
  static const double opacityLight = 0.40;

  /// Whisper glass — 15% for background hints
  static const double opacityWhisper = 0.15;

  // ============ CORNER RADIUS ============

  /// Standard glass panel radius
  static const double glassRadius = 32.0;

  /// Interactive element radius
  static const double interactiveRadius = 12.0;

  /// Input field radius
  static const double inputRadius = 10.0;

  // ============ ELEVATION MAPPING ============

  /// Maps Z-level to Material elevation for shadow casting
  static double elevationForLevel(int zLevel) {
    switch (zLevel) {
      case zParchmentGround:
        return 0;
      case zInkIllustration:
        return 0;
      case zGlassPanels:
        return 8;
      case zInteractive:
        return 4;
      case zOverlay:
        return 16;
      default:
        return 0;
    }
  }

  /// Maps Z-level to blur sigma
  static double blurForLevel(int zLevel) {
    switch (zLevel) {
      case zParchmentGround:
        return blurNone;
      case zInkIllustration:
        return blurNone;
      case zGlassPanels:
        return blurMedium;
      case zInteractive:
        return blurLight;
      case zOverlay:
        return blurHeavy;
      default:
        return blurNone;
    }
  }

  /// Maps Z-level to glass opacity
  static double opacityForLevel(int zLevel) {
    switch (zLevel) {
      case zParchmentGround:
        return opacityFull;
      case zInkIllustration:
        return opacityFull;
      case zGlassPanels:
        return opacityMedium;
      case zInteractive:
        return opacityHeavy;
      case zOverlay:
        return opacityHeavy;
      default:
        return opacityFull;
    }
  }

  /// Creates an ImageFilter for the given Z-level
  static ImageFilter? filterForLevel(int zLevel) {
    final sigma = blurForLevel(zLevel);
    if (sigma <= 0) return null;
    return ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
  }
}
