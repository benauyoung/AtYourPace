import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/collection_model.dart';

/// Provider for all collections (mocked for now)
final collectionsProvider = FutureProvider<List<CollectionModel>>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 500));

  // Return predefined Paris collections
  return ParisCollections.predefined.asMap().entries.map((entry) {
    final index = entry.key;
    final data = entry.value;

    // Assign some mock tour IDs based on index
    final tourIds = List.generate(
      3 + (index % 3), // 3 to 5 tours per collection
      (i) => 'tour_paris_${(index * 3) + i}',
    );

    return CollectionModel.createFromPredefined(
      data,
      id: 'collection_paris_$index',
      curatorId: 'system',
      curatorName: 'AYP Team',
    ).copyWith(tourIds: tourIds);
  }).toList();
});

/// Provider for featured collections (subset)
final featuredCollectionsProvider = FutureProvider<List<CollectionModel>>((ref) async {
  final collections = await ref.watch(collectionsProvider.future);
  return collections.where((c) => c.isFeatured).take(5).toList();
});

/// Provider for a single collection by ID
final collectionByIdProvider = FutureProvider.family<CollectionModel?, String>((ref, id) async {
  final collections = await ref.watch(collectionsProvider.future);
  try {
    return collections.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
});
