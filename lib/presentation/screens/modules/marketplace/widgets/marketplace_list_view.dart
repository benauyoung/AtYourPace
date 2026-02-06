import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/theme/app_spacing.dart';
import '../../../../../config/theme/colors.dart';
import '../../../../../core/constants/route_names.dart';
import '../../../../../data/models/tour_model.dart';
import '../../../../providers/collections_provider.dart';
import '../../../../widgets/common/error_view.dart';
import '../../../../widgets/common/skeleton_loader.dart';
import '../../../../widgets/tour/tour_card.dart';
import '../view_models/marketplace_view_model.dart';
import 'collection_card.dart';

class MarketplaceListView extends ConsumerWidget {
  const MarketplaceListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final collectionsAsync = ref.watch(featuredCollectionsProvider);
    // Use filtered tours from ViewModel
    final filteredToursAsync = ref.watch(marketplaceProvider.select((s) => s.filteredTours));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(featuredCollectionsProvider);
        // Re-trigger filter logic (which refreshes base tours)
        ref.invalidate(marketplaceProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),

            // 1. Collections Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Curated Collections',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to all collections
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            SizedBox(
              height: 220,
              child: collectionsAsync.when(
                data: (collections) {
                  if (collections.isEmpty) {
                    return const Center(child: Text('No collections found'));
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: collections.length,
                    itemBuilder: (context, index) {
                      final collection = collections[index];
                      return CollectionCard(
                        collection: collection,
                        onTap: () {
                          context.go('${RouteNames.discover}/collection/${collection.id}');
                        },
                      );
                    },
                  );
                },
                loading:
                    () => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      itemCount: 3,
                      itemBuilder:
                          (context, index) => Container(
                            width: 200,
                            margin: const EdgeInsets.only(right: AppSpacing.md),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                              border: Border.all(color: AppColors.glassBorder, width: 0.5),
                            ),
                          ),
                    ),
                error: (e, _) => Center(child: Text('Error loading collections')),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // 2. Categories Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'Browse by Category',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children:
                    TourCategory.values.map((category) {
                      final isSelected = ref.watch(
                        marketplaceProvider.select((s) => s.selectedCategory == category),
                      );
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        child: _CategoryPill(
                          category: category,
                          isSelected: isSelected,
                          onTap: () {
                            ref.read(marketplaceProvider.notifier).setCategory(category);
                          },
                        ),
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // 3. Featured Tours List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Tours',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (ref.watch(
                    marketplaceProvider.select(
                      (s) => s.searchQuery.isNotEmpty || s.selectedCategory != null,
                    ),
                  ))
                    filteredToursAsync.when(
                      data:
                          (tours) =>
                              Text('${tours.length} results', style: theme.textTheme.labelMedium),
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            filteredToursAsync.when(
              data: (tours) {
                if (tours.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Text('No tours found matching your search.'),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: tours.length,
                  itemBuilder: (context, index) {
                    final tour = tours[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: TourCard(
                        tour: tour,
                        onTap: () => context.push(RouteNames.tourDetailsPath(tour.id)),
                      ),
                    );
                  },
                );
              },
              loading: () => SkeletonList.tourCards(count: 3),
              error: (e, _) => ErrorView(message: e.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final TourCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryPill({required this.category, this.isSelected = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : AppColors.glassBorder,
            width: isSelected ? 2 : 0.5,
          ),
          boxShadow:
              isSelected
                  ? []
                  : [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category.icon,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              category.displayName,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
