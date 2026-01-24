import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_config.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/tour_model.dart';
import 'auth_provider.dart';
import 'tour_providers.dart';

/// Provider for managing user's favorite tours
final favoriteTourIdsProvider = StateNotifierProvider<FavoriteTourIdsNotifier, Set<String>>((ref) {
  return FavoriteTourIdsNotifier(ref);
});

class FavoriteTourIdsNotifier extends StateNotifier<Set<String>> {
  final Ref _ref;

  FavoriteTourIdsNotifier(this._ref) : super(_demoFavorites) {
    _loadFavorites();
  }

  // Demo favorites for testing
  static final Set<String> _demoFavorites = {'tour_1', 'tour_3'};

  /// Load favorites from Firestore
  Future<void> _loadFavorites() async {
    if (AppConfig.demoMode) return;

    final user = _ref.read(authStateProvider).value;
    if (user == null) return;

    try {
      final firestore = _ref.read(firestoreProvider);
      final userDoc = await firestore
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        final favoritesData = data?['favoriteTourIds'] as List<dynamic>?;
        if (favoritesData != null) {
          state = Set<String>.from(favoritesData.map((e) => e.toString()));
        }
      }
    } catch (e) {
      // Ignore errors, keep demo favorites
    }
  }

  void toggleFavorite(String tourId) {
    if (state.contains(tourId)) {
      state = {...state}..remove(tourId);
    } else {
      state = {...state, tourId};
    }

    // Persist to Firestore
    if (!AppConfig.demoMode) {
      _persistToFirestore();
    }
  }

  void addFavorite(String tourId) {
    if (!state.contains(tourId)) {
      state = {...state, tourId};
      if (!AppConfig.demoMode) {
        _persistToFirestore();
      }
    }
  }

  void removeFavorite(String tourId) {
    if (state.contains(tourId)) {
      state = {...state}..remove(tourId);
      if (!AppConfig.demoMode) {
        _persistToFirestore();
      }
    }
  }

  Future<void> _persistToFirestore() async {
    final user = _ref.read(authStateProvider).value;
    if (user == null) return;

    try {
      final firestore = _ref.read(firestoreProvider);
      await firestore.collection(FirestoreCollections.users).doc(user.uid).set({
        'favoriteTourIds': state.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Silently fail - favorites will sync on next load
    }
  }
}

/// Check if a specific tour is favorited
final isTourFavoritedProvider = Provider.family<bool, String>((ref, tourId) {
  final favorites = ref.watch(favoriteTourIdsProvider);
  return favorites.contains(tourId);
});

/// Provider for favorite tours with full details
final favoriteTourProvider = FutureProvider<List<TourModel>>((ref) async {
  final favoriteIds = ref.watch(favoriteTourIdsProvider);

  if (favoriteIds.isEmpty) {
    return [];
  }

  // Get all featured tours (in a real app, this would fetch by IDs)
  final allTours = await ref.watch(featuredToursProvider.future);

  return allTours.where((tour) => favoriteIds.contains(tour.id)).toList();
});

/// Number of favorites
final favoritesCountProvider = Provider<int>((ref) {
  return ref.watch(favoriteTourIdsProvider).length;
});
