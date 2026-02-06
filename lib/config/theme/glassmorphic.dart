import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_gradients.dart';
import 'app_spacing.dart';
import 'colors.dart';
import 'layering.dart';

/// Parisian Botanical Journal — Glassmorphic & Surface System
///
/// Glass blur is now reserved for bottom sheets, modals, and overlays only.
/// Regular cards use gradient parchment backgrounds with linen borders.
/// Shadows are warm green-tinted charcoal, never blue-gray.
class Glassmorphic {
  Glassmorphic._();

  // ============ CARD SURFACE DECORATIONS (No blur) ============

  /// Standard card — gradient parchment with linen border
  /// Use for: Default cards, content containers
  static BoxDecoration card({double borderRadius = 16.0}) => BoxDecoration(
    gradient: AppGradients.cardParchment,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: AppColors.borderLinen, width: 1.0),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight.withOpacity(0.03), // #2d3a2908
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
    ],
  );

  /// Elevated card — slightly deeper shadow
  /// Use for: Featured items, hover states
  static BoxDecoration cardElevated({double borderRadius = 16.0}) => BoxDecoration(
    gradient: AppGradients.cardParchment,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: AppColors.borderLinen, width: 1.0),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight.withOpacity(0.06),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );

  /// Subtle card — flat parchment, no shadow
  /// Use for: Grouped content, tertiary cards
  static BoxDecoration cardSubtle({double borderRadius = 16.0}) => BoxDecoration(
    color: AppColors.surfaceAlt,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: AppColors.borderLinenLight, width: 0.5),
  );

  // ============ GLASS PANELS (Blur reserved for overlays) ============

  /// Heavy glass — modals, bottom sheets, overlays
  /// 85% opacity, 30px blur
  static BoxDecoration heavy({double borderRadius = AppLayering.glassRadius, Color? tint}) =>
      BoxDecoration(
        color: tint ?? AppColors.glassHeavy,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.borderLinenLight, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  /// Medium glass — kept for backward compatibility
  static BoxDecoration medium({double borderRadius = AppLayering.glassRadius, Color? tint}) =>
      BoxDecoration(
        color: tint ?? AppColors.glassMedium,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.borderLinen, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      );

  /// Light glass — subtle overlays
  static BoxDecoration light({double borderRadius = AppLayering.glassRadius, Color? tint}) =>
      BoxDecoration(
        color: tint ?? AppColors.glassLight,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.borderLinenLight, width: 0.5),
      );

  /// Whisper glass — barely visible overlay
  static BoxDecoration whisper({double borderRadius = AppLayering.glassRadius}) => BoxDecoration(
    color: AppColors.glassWhisper,
    borderRadius: BorderRadius.circular(borderRadius),
  );

  // ============ DARK THEME GLASS ============

  /// Heavy glass for dark theme
  static BoxDecoration heavyDark({double borderRadius = AppLayering.glassRadius}) => BoxDecoration(
    color: AppColors.surfaceDark.withOpacity(0.85),
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: AppColors.highlightDark.withOpacity(0.3), width: 1.0),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowDark.withOpacity(0.3),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  /// Medium glass for dark theme
  static BoxDecoration mediumDark({double borderRadius = AppLayering.glassRadius}) => BoxDecoration(
    color: AppColors.surfaceDark.withOpacity(0.65),
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: AppColors.highlightDark.withOpacity(0.2), width: 1.0),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowDark.withOpacity(0.2),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );

  // ============ SPECIALIZED PANELS ============

  /// Bottom sheet — heavy glass with top-only radius (keeps blur)
  static BoxDecoration bottomSheet({bool isDark = false}) => BoxDecoration(
    color: isDark ? AppColors.surfaceDark.withOpacity(0.90) : AppColors.glassHeavy,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(AppSpacing.radiusXl),
      topRight: Radius.circular(AppSpacing.radiusXl),
    ),
    border: Border(
      top: BorderSide(
        color: isDark ? AppColors.highlightDark.withOpacity(0.3) : AppColors.borderLinen,
        width: 1.0,
      ),
      left: BorderSide(
        color: isDark ? AppColors.highlightDark.withOpacity(0.3) : AppColors.borderLinen,
        width: 1.0,
      ),
      right: BorderSide(
        color: isDark ? AppColors.highlightDark.withOpacity(0.3) : AppColors.borderLinen,
        width: 1.0,
      ),
    ),
    boxShadow: [
      BoxShadow(
        color: (isDark ? AppColors.shadowDark : AppColors.shadowLight).withOpacity(0.10),
        blurRadius: 24,
        offset: const Offset(0, -4),
      ),
    ],
  );

  /// Navigation bar — ivory cream with linen top border
  static BoxDecoration navBar({bool isDark = false}) => BoxDecoration(
    color: isDark ? AppColors.surfaceDark.withOpacity(0.80) : AppColors.background,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(24),
      topRight: Radius.circular(24),
    ),
    border: Border(
      top: BorderSide(
        color: isDark ? AppColors.highlightDark.withOpacity(0.2) : AppColors.borderLinen,
        width: 1.0,
      ),
    ),
    boxShadow: [
      BoxShadow(
        color: (isDark ? AppColors.shadowDark : AppColors.shadowLight).withOpacity(0.06),
        blurRadius: 16,
        offset: const Offset(0, -2),
      ),
    ],
  );

  /// Tour card — gradient parchment with green accent border
  static BoxDecoration tourCard({bool isDark = false}) => BoxDecoration(
    gradient: isDark ? null : AppGradients.cardParchment,
    color: isDark ? AppColors.surfaceDark.withOpacity(0.70) : null,
    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
    border: Border.all(color: AppColors.borderLinen, width: 1.0),
    boxShadow: [
      BoxShadow(
        color: (isDark ? AppColors.shadowDark : AppColors.shadowLight).withOpacity(0.05),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // ============ BLUR FILTER HELPERS ============

  /// Creates a BackdropFilter ImageFilter for the given blur sigma
  static ImageFilter blurFilter(double sigma) => ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);

  /// Standard glass blur (20px)
  static ImageFilter get standardBlur => blurFilter(AppLayering.blurMedium);

  /// Heavy glass blur (30px)
  static ImageFilter get heavyBlur => blurFilter(AppLayering.blurHeavy);

  /// Light glass blur (10px)
  static ImageFilter get lightBlur => blurFilter(AppLayering.blurLight);
}

/// Extension for easy glassmorphic container creation
extension GlassmorphicContainer on Widget {
  /// Wrap widget in a glassmorphic container with backdrop blur
  Widget glassmorphic({
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
    double borderRadius = AppLayering.glassRadius,
    double blurSigma = AppLayering.blurMedium,
    Color? tint,
  }) => ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
      child: Container(
        padding: padding,
        decoration: Glassmorphic.medium(borderRadius: borderRadius, tint: tint),
        child: this,
      ),
    ),
  );
}
