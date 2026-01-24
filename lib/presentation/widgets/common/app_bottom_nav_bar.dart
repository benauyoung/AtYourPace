import 'package:flutter/material.dart';

import '../../../config/theme/colors.dart';

/// Custom bottom navigation bar matching Shaka Guide design.
///
/// Features:
/// - Dark teal background
/// - Rounded top corners
/// - Mint accent for selected items
/// - Clean icons with labels
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = const [],
  });

  /// Currently selected index
  final int currentIndex;

  /// Callback when an item is tapped
  final ValueChanged<int> onTap;

  /// Navigation items
  final List<AppBottomNavItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary, // Dark teal
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: _NavItem(
                  icon: item.icon,
                  activeIcon: item.activeIcon,
                  label: item.label,
                  isSelected: isSelected,
                  onTap: () => onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? AppColors.secondary // Mint for selected
        : Colors.white.withOpacity(0.7); // Faded white for unselected

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? (activeIcon ?? icon) : icon,
              color: color,
              size: isSelected ? 26 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Item for AppBottomNavBar
class AppBottomNavItem {
  const AppBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });

  /// Icon to display when not selected
  final IconData icon;

  /// Icon to display when selected (optional, defaults to [icon])
  final IconData? activeIcon;

  /// Label text
  final String label;
}
