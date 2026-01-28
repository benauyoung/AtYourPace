import 'package:flutter/material.dart';

/// Neumorphic design system with dual-shadow effects
///
/// Creates soft, extruded UI elements that appear to push out from
/// or sink into the background surface.
class Neumorphic {
  Neumorphic._();

  // ============ LIGHT THEME SHADOWS ============

  /// Light source shadow (top-left highlight)
  static Color get lightHighlight => Colors.white.withOpacity(0.8);

  /// Ambient shadow (bottom-right depth)
  static Color get lightShadow => const Color(0xFFD1D9E6).withOpacity(0.6);

  /// Raised element - appears to float above surface
  static List<BoxShadow> raised({
    double intensity = 1.0,
    double blur = 20,
    double spread = 0,
    Offset offset = const Offset(8, 8),
  }) => [
    BoxShadow(
      color: lightHighlight.withOpacity(0.8 * intensity),
      offset: Offset(-offset.dx, -offset.dy),
      blurRadius: blur,
      spreadRadius: spread,
    ),
    BoxShadow(
      color: lightShadow.withOpacity(0.6 * intensity),
      offset: offset,
      blurRadius: blur,
      spreadRadius: spread,
    ),
  ];

  /// Pressed/inset element - appears sunken into surface
  static List<BoxShadow> inset({
    double intensity = 1.0,
    double blur = 15,
  }) => [
    BoxShadow(
      color: lightShadow.withOpacity(0.5 * intensity),
      offset: const Offset(4, 4),
      blurRadius: blur,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: lightHighlight.withOpacity(0.7 * intensity),
      offset: const Offset(-4, -4),
      blurRadius: blur,
      spreadRadius: -2,
    ),
  ];

  /// Subtle raised - for cards and containers
  static List<BoxShadow> get subtle => raised(intensity: 0.5, blur: 15, offset: const Offset(6, 6));

  /// Strong raised - for buttons and interactive elements
  static List<BoxShadow> get strong => raised(intensity: 1.0, blur: 25, offset: const Offset(10, 10));

  /// Flat - no shadow, for pressed states
  static List<BoxShadow> get flat => [];

  // ============ DARK THEME SHADOWS ============

  /// Dark theme highlight (subtle glow)
  static Color get darkHighlight => const Color(0xFF3A3F4D).withOpacity(0.4);

  /// Dark theme shadow (deep shadow)
  static Color get darkShadow => const Color(0xFF0A0C10).withOpacity(0.7);

  /// Raised element for dark theme
  static List<BoxShadow> raisedDark({
    double intensity = 1.0,
    double blur = 20,
    Offset offset = const Offset(8, 8),
  }) => [
    BoxShadow(
      color: darkHighlight.withOpacity(0.4 * intensity),
      offset: Offset(-offset.dx, -offset.dy),
      blurRadius: blur,
    ),
    BoxShadow(
      color: darkShadow.withOpacity(0.7 * intensity),
      offset: offset,
      blurRadius: blur,
    ),
  ];

  // ============ DECORATION HELPERS ============

  /// Neumorphic box decoration for light theme
  static BoxDecoration box({
    Color? color,
    double borderRadius = 20,
    List<BoxShadow>? shadows,
    Border? border,
  }) => BoxDecoration(
    color: color ?? const Color(0xFFF0F4F8),
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: shadows ?? subtle,
    border: border,
  );

  /// Neumorphic box decoration for dark theme
  static BoxDecoration boxDark({
    Color? color,
    double borderRadius = 20,
    List<BoxShadow>? shadows,
    Border? border,
  }) => BoxDecoration(
    color: color ?? const Color(0xFF1E2433),
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: shadows ?? raisedDark(),
    border: border,
  );

  /// Circular neumorphic decoration (for buttons, avatars)
  static BoxDecoration circle({
    Color? color,
    List<BoxShadow>? shadows,
  }) => BoxDecoration(
    color: color ?? const Color(0xFFF0F4F8),
    shape: BoxShape.circle,
    boxShadow: shadows ?? subtle,
  );

  /// Pill-shaped neumorphic decoration (for chips, tags)
  static BoxDecoration pill({
    Color? color,
    List<BoxShadow>? shadows,
  }) => BoxDecoration(
    color: color ?? const Color(0xFFF0F4F8),
    borderRadius: BorderRadius.circular(999),
    boxShadow: shadows ?? raised(intensity: 0.4, blur: 12, offset: const Offset(4, 4)),
  );

  /// Inset/pressed neumorphic decoration
  static BoxDecoration insetBox({
    Color? color,
    double borderRadius = 16,
  }) => BoxDecoration(
    color: color ?? const Color(0xFFE8ECF0),
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: inset(),
  );
}

/// Extension for easy neumorphic container creation
extension NeumorphicContainer on Widget {
  /// Wrap widget in a neumorphic container
  Widget neumorphic({
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
    double borderRadius = 20,
    Color? color,
    List<BoxShadow>? shadows,
  }) => Container(
    padding: padding,
    decoration: Neumorphic.box(
      color: color,
      borderRadius: borderRadius,
      shadows: shadows,
    ),
    child: this,
  );
}
