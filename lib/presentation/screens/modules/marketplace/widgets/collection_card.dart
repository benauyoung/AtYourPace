import 'package:flutter/material.dart';

import '../../../../../config/theme/app_spacing.dart';
import '../../../../../config/theme/neumorphic.dart';
import '../../../../../data/models/collection_model.dart';

class CollectionCard extends StatelessWidget {
  final CollectionModel collection;
  final VoidCallback onTap;

  const CollectionCard({super.key, required this.collection, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        decoration: Neumorphic.box(
          color: theme.colorScheme.surface,
          borderRadius: AppSpacing.radiusLg,
          shadows: Neumorphic.subtle,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image Placeholder
            Container(
              height: 120,
              color: theme.colorScheme.primaryContainer,
              child: Center(
                child: Icon(
                  _getIconForType(collection.type),
                  size: 48,
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.5),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    collection.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        collection.city ?? 'Unknown',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(CollectionType type) {
    switch (type) {
      case CollectionType.geographic:
        return Icons.map_outlined;
      case CollectionType.thematic:
        return Icons.local_activity_outlined;
      case CollectionType.seasonal:
        return Icons.wb_sunny_outlined;
      case CollectionType.custom:
        return Icons.bookmark_outline;
    }
  }
}
