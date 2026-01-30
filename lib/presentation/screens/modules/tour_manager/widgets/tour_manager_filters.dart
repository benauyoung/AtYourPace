import 'package:flutter/material.dart';

import '../../../../../data/models/tour_model.dart';
import '../providers/tour_manager_provider.dart';

/// Filter panel for tour manager
class TourManagerFiltersPanel extends StatelessWidget {
  final TourManagerFilters filters;
  final ValueChanged<TourStatus?> onStatusChanged;
  final ValueChanged<TourCategory?> onCategoryChanged;
  final ValueChanged<String?> onSearchChanged;
  final VoidCallback onClearFilters;
  final bool isAdmin;
  final ValueChanged<bool>? onShowOnlyMineChanged;

  const TourManagerFiltersPanel({
    super.key,
    required this.filters,
    required this.onStatusChanged,
    required this.onCategoryChanged,
    required this.onSearchChanged,
    required this.onClearFilters,
    this.isAdmin = false,
    this.onShowOnlyMineChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search tours...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerLow,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              suffixIcon: filters.searchQuery != null &&
                      filters.searchQuery!.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => onSearchChanged(null),
                    )
                  : null,
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 12),

          // Filter chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Status filter
                _buildFilterDropdown<TourStatus>(
                  context: context,
                  label: 'Status',
                  value: filters.status,
                  items: TourStatus.values,
                  itemLabel: (s) => s.displayName,
                  onChanged: onStatusChanged,
                ),
                const SizedBox(width: 8),

                // Category filter
                _buildFilterDropdown<TourCategory>(
                  context: context,
                  label: 'Category',
                  value: filters.category,
                  items: TourCategory.values,
                  itemLabel: (c) => c.displayName,
                  onChanged: onCategoryChanged,
                ),
                const SizedBox(width: 8),

                // Admin toggle
                if (isAdmin) ...[
                  FilterChip(
                    label: Text(
                      filters.showOnlyMine ? 'My Tours' : 'All Tours',
                    ),
                    selected: !filters.showOnlyMine,
                    onSelected: (_) =>
                        onShowOnlyMineChanged?.call(!filters.showOnlyMine),
                    avatar: Icon(
                      filters.showOnlyMine ? Icons.person : Icons.people,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Clear filters button
                if (filters.hasFilters)
                  ActionChip(
                    label: const Text('Clear'),
                    avatar: const Icon(Icons.clear_all, size: 18),
                    onPressed: onClearFilters,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown<T>({
    required BuildContext context,
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isSelected = value != null;

    return PopupMenuButton<T?>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value != null ? itemLabel(value) : label,
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.outline,
            ),
          ],
        ),
      ),
      onSelected: onChanged,
      itemBuilder: (context) => [
        PopupMenuItem<T?>(
          value: null,
          child: Text('All $label'),
        ),
        const PopupMenuDivider(),
        ...items.map((item) => PopupMenuItem<T?>(
              value: item,
              child: Row(
                children: [
                  if (item == value)
                    Icon(Icons.check, size: 18, color: theme.colorScheme.primary),
                  if (item == value) const SizedBox(width: 8),
                  Text(itemLabel(item)),
                ],
              ),
            )),
      ],
    );
  }
}

/// Quick status filter chips
class TourStatusFilters extends StatelessWidget {
  final TourStatus? selectedStatus;
  final ValueChanged<TourStatus?> onStatusChanged;
  final int draftCount;
  final int pendingCount;
  final int approvedCount;

  const TourStatusFilters({
    super.key,
    this.selectedStatus,
    required this.onStatusChanged,
    this.draftCount = 0,
    this.pendingCount = 0,
    this.approvedCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatusChip(
            context,
            label: 'All',
            count: null,
            isSelected: selectedStatus == null,
            onTap: () => onStatusChanged(null),
          ),
          const SizedBox(width: 8),
          _buildStatusChip(
            context,
            label: 'Drafts',
            count: draftCount,
            color: Colors.grey,
            isSelected: selectedStatus == TourStatus.draft,
            onTap: () => onStatusChanged(TourStatus.draft),
          ),
          const SizedBox(width: 8),
          _buildStatusChip(
            context,
            label: 'Pending',
            count: pendingCount,
            color: Colors.orange,
            isSelected: selectedStatus == TourStatus.pendingReview,
            onTap: () => onStatusChanged(TourStatus.pendingReview),
          ),
          const SizedBox(width: 8),
          _buildStatusChip(
            context,
            label: 'Approved',
            count: approvedCount,
            color: Colors.green,
            isSelected: selectedStatus == TourStatus.approved,
            onTap: () => onStatusChanged(TourStatus.approved),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context, {
    required String label,
    int? count,
    Color? color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? theme.colorScheme.primary).withValues(alpha: 0.2)
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (color ?? theme.colorScheme.primary)
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? (color ?? theme.colorScheme.primary)
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (color ?? theme.colorScheme.primary)
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
