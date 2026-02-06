import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../config/theme/colors.dart';
import '../../../config/theme/glassmorphic.dart';
import '../../../config/theme/layering.dart';

/// A reusable glassmorphic container widget that applies
/// BackdropFilter blur and frosted glass decoration.
///
/// Wraps content in a frosted glass pane that floats over
/// the ink illustration backdrop. Includes RepaintBoundary
/// for performance isolation.
///
/// Usage:
/// ```dart
/// GlassPanel(
///   level: GlassLevel.medium,
///   child: Text('Content on glass'),
/// )
/// ```
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.level = GlassLevel.medium,
    this.padding,
    this.borderRadius,
    this.margin,
    this.width,
    this.height,
    this.tint,
  });

  /// The content to display on the glass panel.
  final Widget child;

  /// The glass intensity level.
  final GlassLevel level;

  /// Internal padding. Defaults to EdgeInsets.all(20).
  final EdgeInsetsGeometry? padding;

  /// Corner radius. Defaults to 32pt (AppLayering.glassRadius).
  final double? borderRadius;

  /// External margin around the panel.
  final EdgeInsetsGeometry? margin;

  /// Fixed width constraint.
  final double? width;

  /// Fixed height constraint.
  final double? height;

  /// Custom tint color for the glass.
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? AppLayering.glassRadius;
    final sigma = _sigmaForLevel(level);
    final decoration = _decorationForLevel(level, isDark);

    return RepaintBoundary(
      child: Container(
        margin: margin,
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: Container(
              padding: padding ?? const EdgeInsets.all(20),
              decoration: decoration,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  double _sigmaForLevel(GlassLevel level) {
    switch (level) {
      case GlassLevel.heavy:
        return AppLayering.blurHeavy;
      case GlassLevel.medium:
        return AppLayering.blurMedium;
      case GlassLevel.light:
        return AppLayering.blurLight;
      case GlassLevel.whisper:
        return 5.0;
    }
  }

  BoxDecoration _decorationForLevel(GlassLevel level, bool isDark) {
    final radius = borderRadius ?? AppLayering.glassRadius;

    if (isDark) {
      switch (level) {
        case GlassLevel.heavy:
          return Glassmorphic.heavyDark(borderRadius: radius);
        case GlassLevel.medium:
          return Glassmorphic.mediumDark(borderRadius: radius);
        case GlassLevel.light:
          return Glassmorphic.light(
            borderRadius: radius,
            tint: AppColors.surfaceDark.withOpacity(0.40),
          );
        case GlassLevel.whisper:
          return Glassmorphic.whisper(borderRadius: radius);
      }
    }

    switch (level) {
      case GlassLevel.heavy:
        return Glassmorphic.heavy(borderRadius: radius, tint: tint);
      case GlassLevel.medium:
        return Glassmorphic.medium(borderRadius: radius, tint: tint);
      case GlassLevel.light:
        return Glassmorphic.light(borderRadius: radius, tint: tint);
      case GlassLevel.whisper:
        return Glassmorphic.whisper(borderRadius: radius);
    }
  }
}

/// Glass intensity levels matching the layering system.
enum GlassLevel {
  /// 85% opacity, 30px blur — modals, bottom sheets
  heavy,

  /// 65% opacity, 20px blur — standard cards, panels
  medium,

  /// 40% opacity, 15px blur — subtle overlays
  light,

  /// 15% opacity, 5px blur — barely visible hints
  whisper,
}
