import 'package:flutter/material.dart';

import '../../../config/theme/colors.dart';
import '../../../config/theme/typography.dart';

/// A section header with a fleur-de-lis (⚜) motif at low opacity.
///
/// Evokes old Parisian signage and literary culture.
/// The fleur-de-lis appears beside the title at 40% opacity.
///
/// ```dart
/// FleurDeLisHeader(title: 'Featured Tours')
/// FleurDeLisHeader(title: 'PARCOURS', useOverline: true)
/// ```
class FleurDeLisHeader extends StatelessWidget {
  final String title;
  final bool useOverline;
  final TextStyle? titleStyle;
  final EdgeInsetsGeometry padding;
  final double fleurOpacity;

  const FleurDeLisHeader({
    super.key,
    required this.title,
    this.useOverline = false,
    this.titleStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.fleurOpacity = 0.4,
  });

  @override
  Widget build(BuildContext context) {
    final style = titleStyle ??
        (useOverline
            ? AppTypography.sectionOverline
            : Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ));

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Text(
            '⚜',
            style: TextStyle(
              fontSize: useOverline ? 14 : 18,
              color: AppColors.primary.withOpacity(fleurOpacity),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              useOverline ? title.toUpperCase() : title,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}
