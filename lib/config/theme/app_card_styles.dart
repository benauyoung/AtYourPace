import 'package:flutter/material.dart';

import '../../core/extensions/context_extensions.dart';
import 'app_spacing.dart';

/// Card decoration styles for consistent design across the app.
///
/// Provides pre-built BoxDecoration styles for different card types:
/// - [elevated]: Standard card with subtle shadow
/// - [glass]: Glassmorphic effect for overlays
/// - [gradient]: Gradient background for featured content
/// - [outlined]: Bordered card without shadow
class AppCardStyles {
  AppCardStyles._();

  /// Elevated card with soft shadow
  ///
  /// Use for: Standard cards, content containers
  static BoxDecoration elevated(BuildContext context) => BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: AppSpacing.cardRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  /// Glassmorphic card for overlays
  ///
  /// Use for: Modal overlays, floating panels, overlay controls
  static BoxDecoration glass(BuildContext context) => BoxDecoration(
        color: context.colorScheme.surface.withOpacity(0.7),
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(
          color: context.isDark
              ? Colors.white.withOpacity(0.2)
              : Colors.black.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  /// Gradient card for featured content
  ///
  /// Use for: Featured items, highlights, call-to-action cards
  ///
  /// Example:
  /// ```dart
  /// Container(
  ///   decoration: AppCardStyles.gradient(AppGradients.ocean),
  ///   child: ...
  /// )
  /// ```
  static BoxDecoration gradient(LinearGradient gradient) => BoxDecoration(
        gradient: gradient,
        borderRadius: AppSpacing.cardRadius,
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      );

  /// Outlined card with border
  ///
  /// Use for: Secondary cards, selected states
  static BoxDecoration outlined(BuildContext context, {Color? borderColor}) =>
      BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(
          color: borderColor ?? context.colorScheme.outline,
          width: 1.5,
        ),
      );

  /// Subtle card with very light background
  ///
  /// Use for: Grouped content, tertiary cards
  static BoxDecoration subtle(BuildContext context) => BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: AppSpacing.cardRadius,
      );

  /// Elevated card with colored shadow (for emphasis)
  ///
  /// Use for: Important cards, featured items
  static BoxDecoration elevatedColored(
    BuildContext context, {
    required Color shadowColor,
  }) =>
      BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: AppSpacing.cardRadius,
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: shadowColor.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      );

  /// Image overlay gradient
  ///
  /// Use for: Images that need text overlays for readability
  static BoxDecoration imageOverlay({
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
    double opacity = 0.7,
  }) =>
      BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(opacity),
          ],
          stops: const [0.3, 1.0],
        ),
      );

  /// Tour card style - Clean white with soft shadow
  ///
  /// Use for: Tour cards in grid/list views (matches Shaka Guide style)
  static BoxDecoration tourCard(BuildContext context) => BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  /// List item card - Subtle elevation for list items
  ///
  /// Use for: Download list items, purchase history items
  static BoxDecoration listItem(BuildContext context) => BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  /// Bottom sheet style - Rounded top corners
  ///
  /// Use for: Modal bottom sheets, sliding panels
  static BoxDecoration bottomSheet(BuildContext context) => BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      );

  /// Navigation bar container - Dark teal with rounded top corners
  ///
  /// Use for: Custom bottom navigation bar container
  static BoxDecoration navBar() => const BoxDecoration(
        color: Color(0xFF1E3D4C), // AppColors.primary
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      );

  /// Price badge style - Mint teal background
  ///
  /// Use for: Price tags on tour cards
  static BoxDecoration priceBadge() => BoxDecoration(
        color: const Color(0xFF5DD4B3), // AppColors.secondary (mint)
        borderRadius: BorderRadius.circular(8),
      );

  /// Toggle button selected style
  ///
  /// Use for: Selected state of toggle buttons (like Shaka Guide tabs)
  static BoxDecoration toggleSelected(BuildContext context) => BoxDecoration(
        color: const Color(0xFF1E3D4C), // AppColors.primary (dark teal)
        borderRadius: BorderRadius.circular(24),
      );

  /// Toggle button unselected style
  ///
  /// Use for: Unselected state of toggle buttons
  static BoxDecoration toggleUnselected(BuildContext context) => BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF1E3D4C), // AppColors.primary
          width: 1.5,
        ),
      );
}
