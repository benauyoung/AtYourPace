import 'package:flutter/material.dart';

/// Pre-submission checklist widget
class SubmissionChecklist extends StatelessWidget {
  final List<String> errors;
  final VoidCallback? onRefresh;

  const SubmissionChecklist({
    super.key,
    required this.errors,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValid = errors.isEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isValid ? Icons.check_circle : Icons.warning,
                  color: isValid
                      ? Colors.green
                      : theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pre-Submission Checklist',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (onRefresh != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: onRefresh,
                    tooltip: 'Refresh checklist',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (isValid)
              _buildCheckItem(
                context,
                label: 'All requirements met',
                isComplete: true,
              )
            else
              ...errors.map((error) => _buildCheckItem(
                    context,
                    label: error,
                    isComplete: false,
                  )),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isValid
                    ? Colors.green.withValues(alpha: 0.1)
                    : theme.colorScheme.errorContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isValid ? Icons.info_outline : Icons.error_outline,
                    size: 20,
                    color: isValid
                        ? Colors.green
                        : theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isValid
                          ? 'Your tour is ready for submission!'
                          : 'Please fix the issues above before submitting',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isValid
                            ? Colors.green.shade700
                            : theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(
    BuildContext context, {
    required String label,
    required bool isComplete,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: isComplete ? Colors.green : theme.colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isComplete
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Checklist item model
class ChecklistItem {
  final String id;
  final String title;
  final String? description;
  final bool isRequired;
  final bool isComplete;

  const ChecklistItem({
    required this.id,
    required this.title,
    this.description,
    this.isRequired = true,
    this.isComplete = false,
  });
}

/// Detailed checklist with expandable items
class DetailedChecklist extends StatelessWidget {
  final List<ChecklistItem> items;
  final ValueChanged<String>? onItemTap;

  const DetailedChecklist({
    super.key,
    required this.items,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = items.where((i) => i.isComplete).length;
    final requiredCount = items.where((i) => i.isRequired).length;
    final completedRequired =
        items.where((i) => i.isRequired && i.isComplete).length;

    return Card(
      child: Column(
        children: [
          // Progress header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                CircularProgressIndicator(
                  value: completedCount / items.length,
                  backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  strokeWidth: 6,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$completedCount of ${items.length} complete',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        '$completedRequired of $requiredCount required items done',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Items list
          ...items.map((item) => _ChecklistItemTile(
                item: item,
                onTap: onItemTap != null ? () => onItemTap!(item.id) : null,
              )),
        ],
      ),
    );
  }
}

class _ChecklistItemTile extends StatelessWidget {
  final ChecklistItem item;
  final VoidCallback? onTap;

  const _ChecklistItemTile({
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              item.isComplete
                  ? Icons.check_circle
                  : item.isRequired
                      ? Icons.radio_button_unchecked
                      : Icons.remove_circle_outline,
              color: item.isComplete
                  ? Colors.green
                  : item.isRequired
                      ? theme.colorScheme.outline
                      : theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          decoration: item.isComplete
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (item.isRequired) ...[
                        const SizedBox(width: 4),
                        Text(
                          '*',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ],
                    ],
                  ),
                  if (item.description != null)
                    Text(
                      item.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.outline,
              ),
          ],
        ),
      ),
    );
  }
}
