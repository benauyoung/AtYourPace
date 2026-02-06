import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';
import 'app_gradients.dart';
import 'app_spacing.dart';
import 'colors.dart';
import 'glassmorphic.dart';
import 'layering.dart';

/// Parisian Botanical Journal Card Styles
///
/// Cards use subtle linear gradients (ivory→parchment at 145°) with linen borders.
/// Shadows are warm green-tinted charcoal (#2d3a29), never blue-gray.
/// Border-radius: 14–16px for cards, 10–12px for buttons, 20px for badges.
class AppCardStyles {
  AppCardStyles._();

  /// Elevated card — gradient parchment with green-tinted shadow
  ///
  /// Use for: Standard cards, content containers
  static BoxDecoration elevated(BuildContext context) => BoxDecoration(
    gradient: context.isDark ? null : AppGradients.cardParchment,
    color: context.isDark ? AppColors.surfaceDark.withOpacity(0.70) : null,
    borderRadius: AppSpacing.cardRadius,
    border: Border.all(
      color: context.isDark ? AppColors.highlightDark.withOpacity(0.2) : AppColors.borderLinen,
      width: 1.0,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight.withOpacity(0.03),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
    ],
  );

  /// Glassmorphic card — heavy frosted glass for overlays (blur preserved)
  ///
  /// Use for: Modal overlays, floating panels, overlay controls
  static BoxDecoration glass(BuildContext context) =>
      context.isDark ? Glassmorphic.heavyDark() : Glassmorphic.heavy();

  /// Gradient card for featured content
  ///
  /// Use for: Featured items, highlights, call-to-action cards
  static BoxDecoration gradient(LinearGradient gradient) => BoxDecoration(
    gradient: gradient,
    borderRadius: AppSpacing.cardRadius,
    border: Border.all(color: AppColors.borderLinen, width: 1.0),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight.withOpacity(0.06),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );

  /// Outlined card — green-bordered parchment
  ///
  /// Use for: Secondary cards, selected states
  static BoxDecoration outlined(BuildContext context, {Color? borderColor}) => BoxDecoration(
    color: context.isDark ? AppColors.surfaceDark.withOpacity(0.50) : AppColors.surface,
    borderRadius: AppSpacing.cardRadius,
    border: Border.all(color: borderColor ?? AppColors.primary.withOpacity(0.4), width: 1.5),
  );

  /// Subtle card — flat parchment, minimal border
  ///
  /// Use for: Grouped content, tertiary cards
  static BoxDecoration subtle(BuildContext context) => BoxDecoration(
    color: context.isDark ? AppColors.surfaceVariantDark.withOpacity(0.3) : AppColors.surfaceAlt,
    borderRadius: AppSpacing.cardRadius,
    border: Border.all(color: AppColors.borderLinenLight, width: 0.5),
  );

  /// Elevated card with colored shadow (for emphasis)
  ///
  /// Use for: Important cards, featured items
  static BoxDecoration elevatedColored(
    BuildContext context, {
    required Color shadowColor,
  }) => BoxDecoration(
    gradient: context.isDark ? null : AppGradients.cardParchment,
    color: context.isDark ? AppColors.surfaceDark.withOpacity(0.75) : null,
    borderRadius: AppSpacing.cardRadius,
    border: Border.all(color: AppColors.borderLinen, width: 1.0),
    boxShadow: [
      BoxShadow(color: shadowColor.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
      BoxShadow(color: shadowColor.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8)),
    ],
  );

  /// Image overlay — green-tinted charcoal gradient for text readability
  ///
  /// Use for: Images that need text overlays for readability
  static BoxDecoration imageOverlay({
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
    double opacity = 0.7,
  }) => BoxDecoration(
    gradient: LinearGradient(
      begin: begin,
      end: end,
      colors: [Colors.transparent, AppColors.textPrimary.withOpacity(opacity)],
      stops: const [0.3, 1.0],
    ),
  );

  /// Tour card — gradient parchment with linen border
  ///
  /// Use for: Tour cards in grid/list views
  static BoxDecoration tourCard(BuildContext context) =>
      context.isDark ? Glassmorphic.tourCard(isDark: true) : Glassmorphic.tourCard();

  /// List item card — subtle parchment elevation
  ///
  /// Use for: Download list items, purchase history items
  static BoxDecoration listItem(BuildContext context) => BoxDecoration(
    color: context.isDark ? AppColors.surfaceDark.withOpacity(0.60) : AppColors.surface,
    borderRadius: BorderRadius.circular(AppLayering.interactiveRadius),
    border: Border.all(color: AppColors.borderLinenLight, width: 0.5),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight.withOpacity(0.03),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  /// Bottom sheet — heavy glass with top radius (blur preserved)
  ///
  /// Use for: Modal bottom sheets, sliding panels
  static BoxDecoration bottomSheet(BuildContext context) =>
      Glassmorphic.bottomSheet(isDark: context.isDark);

  /// Navigation bar — ivory cream with linen top border
  ///
  /// Use for: Custom bottom navigation bar container
  static BoxDecoration navBar({bool isDark = false}) => Glassmorphic.navBar(isDark: isDark);

  /// Audio player card — dark green with gold progress accent
  ///
  /// Use for: Audio player, primary interactive moment
  static BoxDecoration audioPlayer() => BoxDecoration(
    gradient: AppGradients.gardenGreen,
    borderRadius: AppSpacing.cardRadius,
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryDark.withOpacity(0.2),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );

  /// Fun-fact card — dashed gold left border, warm parchment bg
  ///
  /// Use for: "Le saviez-vous?" / fun-fact callout cards
  static BoxDecoration funFact() => BoxDecoration(
    color: AppColors.surfaceAlt,
    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
    border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 1.0),
  );

  /// Next stop card — parchment with dashed border feel
  ///
  /// Use for: "Prochaine étape" navigation cards
  static BoxDecoration nextStop() => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
    border: Border.all(color: AppColors.borderLinen, width: 1.0),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight.withOpacity(0.03),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  /// Badge/pill — semi-transparent green background
  ///
  /// Use for: Category badges, status pills
  static BoxDecoration badge({Color? color}) => BoxDecoration(
    color: (color ?? AppColors.primary).withOpacity(0.12),
    borderRadius: AppSpacing.badgeRadius,
    border: Border.all(color: (color ?? AppColors.primary).withOpacity(0.2), width: 1.0),
  );

  /// Price badge — garden green background
  ///
  /// Use for: Price tags on tour cards
  static BoxDecoration priceBadge() => BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.primaryDark.withOpacity(0.3), width: 1.0),
  );

  /// Toggle button selected — garden green fill
  ///
  /// Use for: Selected state of toggle buttons
  static BoxDecoration toggleSelected(BuildContext context) => BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  /// Toggle button unselected — parchment with green border
  ///
  /// Use for: Unselected state of toggle buttons
  static BoxDecoration toggleUnselected(BuildContext context) => BoxDecoration(
    color: context.isDark ? AppColors.surfaceDark.withOpacity(0.50) : AppColors.surface,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.0),
  );
}
