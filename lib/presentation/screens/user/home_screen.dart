import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/tour_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/recommendations_provider.dart';
import '../../providers/tour_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final featuredTours = ref.watch(featuredToursProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user?.displayName.split(' ').first ?? 'Explorer'}!',
              style: context.textTheme.titleMedium,
            ),
            Text(
              'Ready for your next adventure?',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go(RouteNames.discover),
            tooltip: 'Search',
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () => context.go(RouteNames.favorites),
                tooltip: 'Favorites',
              ),
              // Badge showing favorites count
              Positioned(
                right: 4,
                top: 4,
                child: Consumer(
                  builder: (context, ref, _) {
                    final count = ref.watch(favoritesCountProvider);
                    if (count == 0) return const SizedBox();
                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        count > 9 ? '9+' : count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(featuredToursProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Featured tours section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Tours',
                      style: context.textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () => context.go(RouteNames.discover),
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              featuredTours.when(
                data: (tours) {
                  if (tours.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No featured tours available'),
                    );
                  }
                  return SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: tours.length,
                      itemBuilder: (context, index) {
                        final tour = tours[index];
                        return _FeaturedTourCard(
                          tour: tour,
                          onTap: () => context.go(
                            RouteNames.tourDetailsPath(tour.id),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading tours: $error'),
                ),
              ),
              const SizedBox(height: 24),

              // Recommended for you section
              _RecommendedSection(),
              const SizedBox(height: 24),

              // Categories section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Browse by Category',
                  style: context.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: TourCategory.values.map((category) {
                    return _CategoryCard(
                      category: category,
                      onTap: () {
                        // TODO: Navigate to category
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Quick actions for creators
              if (user?.isCreator ?? false) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Creator Tools',
                    style: context.textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.add_box),
                      title: const Text('Create New Tour'),
                      subtitle: const Text('Start building your next adventure'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => context.go(RouteNames.createTour),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.dashboard),
                      title: const Text('Creator Dashboard'),
                      subtitle: const Text('Manage your tours'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => context.go(RouteNames.creatorDashboard),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedTourCard extends StatelessWidget {
  final TourModel tour;
  final VoidCallback onTap;

  const _FeaturedTourCard({
    required this.tour,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image placeholder
              Container(
                height: 120,
                color: context.colorScheme.primaryContainer,
                child: Center(
                  child: Icon(
                    tour.tourType == TourType.walking
                        ? Icons.directions_walk
                        : Icons.directions_car,
                    size: 48,
                    color: context.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tour.category.displayName,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tour.stats.averageRating.toStringAsFixed(1),
                            style: context.textTheme.labelSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          '${tour.city ?? 'Unknown'}, ${tour.country ?? ''}',
                          style: context.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'by ${tour.creatorName}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final TourCategory category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getCategoryIcon(category),
                size: 32,
                color: context.primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                category.displayName,
                style: context.textTheme.labelMedium,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(TourCategory category) {
    switch (category) {
      case TourCategory.history:
        return Icons.account_balance;
      case TourCategory.nature:
        return Icons.park;
      case TourCategory.ghost:
        return Icons.nightlight;
      case TourCategory.food:
        return Icons.restaurant;
      case TourCategory.art:
        return Icons.palette;
      case TourCategory.architecture:
        return Icons.location_city;
      case TourCategory.other:
        return Icons.category;
    }
  }
}

class _RecommendedSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(recommendedToursProvider);

    return recommendationsAsync.when(
      data: (recommendations) {
        if (recommendations.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Recommended for You',
                    style: context.textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  final rec = recommendations[index];
                  return _RecommendedTourCard(
                    recommendation: rec,
                    onTap: () => context.go(
                      RouteNames.tourDetailsPath(rec.tour.id),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _RecommendedTourCard extends StatelessWidget {
  final TourRecommendation recommendation;
  final VoidCallback onTap;

  const _RecommendedTourCard({
    required this.recommendation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tour = recommendation.tour;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Container(
                height: 80,
                color: context.colorScheme.tertiaryContainer,
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        tour.category.icon,
                        size: 36,
                        color: context.colorScheme.onTertiaryContainer,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome, size: 10, color: Colors.white),
                            const SizedBox(width: 2),
                            Text(
                              'For You',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tour.city ?? 'Unknown',
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      if (recommendation.reasons.isNotEmpty)
                        Text(
                          recommendation.reasons.first,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const Spacer(),
                      Row(
                        children: [
                          if (tour.stats.averageRating > 0) ...[
                            const Icon(Icons.star, size: 12, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              tour.stats.averageRating.toStringAsFixed(1),
                              style: context.textTheme.labelSmall,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Icon(
                            tour.tourType.icon,
                            size: 12,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            tour.tourType.displayName,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
