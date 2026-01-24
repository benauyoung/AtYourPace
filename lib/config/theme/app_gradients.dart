import 'package:flutter/material.dart';

/// Gradient definitions for the app - Fresh Shaka Guide inspired palette.
///
/// Provides pre-defined gradients for consistent use across the application.
/// Each gradient is designed for specific use cases:
/// - [teal]: Navigation bars, primary UI elements
/// - [mint]: CTA buttons, highlights, success states
/// - [nature]: Header decorations, tropical feel
class AppGradients {
  AppGradients._();

  /// Teal gradient - Dark teal navy
  ///
  /// Use for: Navigation bars, primary buttons, dark UI elements
  static const LinearGradient teal = LinearGradient(
    colors: [Color(0xFF1E3D4C), Color(0xFF2C5364)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Mint gradient - Fresh mint teal
  ///
  /// Use for: CTA buttons, highlights, action elements
  static const LinearGradient mint = LinearGradient(
    colors: [Color(0xFF5DD4B3), Color(0xFF7DE4C8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Nature gradient - Soft green for tropical feel
  ///
  /// Use for: Header decorations, success states, nature elements
  static const LinearGradient nature = LinearGradient(
    colors: [Color(0xFF90BE6D), Color(0xFF43AA8B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Orange gradient - Warm orange for prices
  ///
  /// Use for: Price badges, sale highlights, attention grabbers
  static const LinearGradient orange = LinearGradient(
    colors: [Color(0xFFFF9F43), Color(0xFFFFBE76)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Purple gradient - Violet to purple
  ///
  /// Use for: Premium features, special content
  static const LinearGradient purple = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark gradient - For overlays and shadows
  ///
  /// Use for: Image overlays, text readability improvements
  static const LinearGradient darkOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x99000000), // 60% opacity black
    ],
    stops: [0.3, 1.0],
  );

  /// Header decoration gradient - Soft green fade
  ///
  /// Use for: Screen headers with palm tree/tropical decorations
  static const LinearGradient headerDecoration = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE8F5E9), // Very light green
      Color(0xFFF5F7F9), // Background color
    ],
  );

  /// Subtle gradient for elevated surfaces
  ///
  /// Use for: Card backgrounds in dark mode
  static const LinearGradient subtleSurface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1F35),
      Color(0xFF242938),
    ],
  );
}
