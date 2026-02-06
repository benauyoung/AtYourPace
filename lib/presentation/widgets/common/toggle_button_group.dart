import 'package:flutter/material.dart';

import '../../../config/theme/colors.dart';

/// A toggle button group matching Shaka Guide design.
///
/// Features:
/// - Pill-shaped container
/// - Dark teal for selected, outlined for unselected
/// - Smooth animation between states
class ToggleButtonGroup extends StatelessWidget {
  const ToggleButtonGroup({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.backgroundColor,
  });

  /// List of toggle button labels
  final List<String> items;

  /// Currently selected index
  final int selectedIndex;

  /// Callback when selection changes
  final ValueChanged<int> onChanged;

  /// Background color of the container
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.secondary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (index) {
          final isSelected = index == selectedIndex;
          return _ToggleItem(
            label: items[index],
            isSelected: isSelected,
            onTap: () => onChanged(index),
          );
        }),
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  const _ToggleItem({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textOnPrimary : AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// A simpler two-option toggle matching Shaka Guide tabs.
///
/// Use for: Audio Points/Highlights, Purchases/Bookmarks toggles
class DualToggle extends StatelessWidget {
  const DualToggle({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.isLeftSelected,
    required this.onChanged,
  });

  final String leftLabel;
  final String rightLabel;
  final bool isLeftSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DualToggleItem(
            label: leftLabel,
            isSelected: isLeftSelected,
            onTap: () => onChanged(true),
          ),
          _DualToggleItem(
            label: rightLabel,
            isSelected: !isLeftSelected,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _DualToggleItem extends StatelessWidget {
  const _DualToggleItem({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textOnPrimary : AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
