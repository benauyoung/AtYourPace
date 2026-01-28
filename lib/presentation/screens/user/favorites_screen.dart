import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_names.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/skeleton_loader.dart';
import '../../widgets/tour/tour_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteTourProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: favoritesAsync.when(
        data: (tours) {
          if (tours.isEmpty) {
            return EmptyState.noFavorites(
              onExplore: () => context.go(RouteNames.discover),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tours.length,
            itemBuilder: (context, index) {
              final tour = tours[index];
              return Padding(
                key: ValueKey(tour.id),
                padding: const EdgeInsets.only(bottom: 16),
                child: TourCard(
                  tour: tour,
                  onTap: () => context.push(RouteNames.tourDetailsPath(tour.id)),
                  showFavoriteButton: true,
                ),
              );
            },
          );
        },
        loading: () => SkeletonList.tourCards(count: 4),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(favoriteTourProvider),
        ),
      ),
    );
  }
}
