import 'package:flutter/material.dart';

import 'colors.dart';

/// Parisian Botanical Journal Gradient Definitions
///
/// Warm garden-green and parchment gradients inspired by watercolor washes,
/// botanical illustrations, and luxury travel magazines.
class AppGradients {
  AppGradients._();

  // ============ CARD & SURFACE GRADIENTS ============

  /// Card parchment — ivory cream to warm parchment at 145°
  ///
  /// Use for: Default card backgrounds, content containers
  static const LinearGradient cardParchment = LinearGradient(
    begin: Alignment(-0.57, -0.82), // ~145° angle
    end: Alignment(0.57, 0.82),
    colors: [Color(0xFFF5F0E8), Color(0xFFEBE5D8)], // Ivory Cream → Card Parchment
  );

  /// Parchment fade — ivory cream to warm parchment (vertical)
  ///
  /// Use for: Backgrounds, subtle depth, section separators
  static const LinearGradient parchmentFade = LinearGradient(
    colors: [Color(0xFFF5F0E8), Color(0xFFEBE5D8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Header decoration gradient — very subtle green tint fading to ivory
  ///
  /// Use for: Screen headers, hero sections
  static const LinearGradient headerDecoration = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFEEF2EC), // Very light green tint (primary50)
      Color(0xFFF5F0E8), // Ivory Cream
    ],
  );

  // ============ PRIMARY GREEN GRADIENTS ============

  /// Garden green — Deep Garden Green to Dark Ivy
  ///
  /// Use for: Primary buttons, audio player, active states
  static const LinearGradient gardenGreen = LinearGradient(
    colors: [Color(0xFF4A6741), Color(0xFF3D5636)], // Deep Garden Green → Dark Ivy
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Sage highlight — Soft Sage to Deep Garden Green
  ///
  /// Use for: Secondary green elements, hover states
  static const LinearGradient sageHighlight = LinearGradient(
    colors: [Color(0xFF6B8A5E), Color(0xFF4A6741)], // Soft Sage → Deep Garden Green
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============ ACCENT GRADIENTS ============

  /// Antique gold — for star ratings, audio progress, fun-fact accents
  ///
  /// Use for: Rating stars, audio progress bar, premium highlights
  static const LinearGradient accentGold = LinearGradient(
    colors: [Color(0xFFD4BA7A), Color(0xFFC4A55A)], // Light Gold → Antique Gold
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============ OVERLAY GRADIENTS ============

  /// Dark overlay — green-tinted charcoal for image overlays
  ///
  /// Use for: Image overlays, text readability improvements
  static const LinearGradient darkOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x992D3A29), // 60% opacity warm charcoal
    ],
    stops: [0.3, 1.0],
  );

  /// Subtle surface gradient for dark mode
  ///
  /// Use for: Card backgrounds in dark mode
  static const LinearGradient subtleSurface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1E18), // Deep garden night
      Color(0xFF252A22), // Elevated garden dark
    ],
  );

  // ============ WATERCOLOR WASH HELPERS ============

  /// Creates a radial watercolor wash gradient for decorative backgrounds.
  /// Place behind headers/cards at 8–15% opacity.
  static RadialGradient watercolorWash({
    Color color = AppColors.primaryLight,
    double opacity = 0.10,
    double radius = 0.8,
  }) => RadialGradient(colors: [color.withOpacity(opacity), color.withOpacity(0)], radius: radius);

  /// Green watercolor wash — for behind headers
  static RadialGradient get greenWash =>
      watercolorWash(color: AppColors.primaryLight, opacity: 0.12);

  /// Gold watercolor wash — for behind accent elements
  static RadialGradient get goldWash => watercolorWash(color: AppColors.accent, opacity: 0.08);

  // ============ LEGACY ALIASES ============

  /// Legacy alias
  static const LinearGradient goldShimmer = accentGold;
  static const LinearGradient teal = gardenGreen;
  static const LinearGradient mint = sageHighlight;
  static const LinearGradient nature = parchmentFade;
  static const LinearGradient orange = accentGold;
  static const LinearGradient purple = gardenGreen;
  static const LinearGradient warmAmber = accentGold;
  static const LinearGradient inkWash = gardenGreen;
  static const LinearGradient sepiaWash = gardenGreen;
}
