import 'package:flutter/material.dart';

import '../../../config/theme/colors.dart';

/// A price badge widget matching Shaka Guide style.
///
/// Displays a price with mint/teal background in the top-left corner of tour cards.
class PriceBadge extends StatelessWidget {
  const PriceBadge({
    super.key,
    required this.price,
    this.currency = '\$',
    this.backgroundColor,
    this.textColor,
  });

  /// The price value to display
  final double price;

  /// Currency symbol (defaults to $)
  final String currency;

  /// Background color (defaults to mint teal)
  final Color? backgroundColor;

  /// Text color (defaults to white)
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$currency${price.toStringAsFixed(2)}',
        style: TextStyle(
          color: textColor ?? AppColors.textOnPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// A free badge for free tours
class FreeBadge extends StatelessWidget {
  const FreeBadge({super.key, this.backgroundColor, this.textColor});

  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'FREE',
        style: TextStyle(
          color: textColor ?? AppColors.textOnPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// A category badge for displaying tour category
class CategoryBadge extends StatelessWidget {
  const CategoryBadge({super.key, required this.label, this.backgroundColor, this.textColor});

  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: textColor ?? AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
