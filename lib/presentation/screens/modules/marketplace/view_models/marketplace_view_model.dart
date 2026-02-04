import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../data/models/collection_model.dart';
import '../../../../data/models/tour_model.dart';
import '../../../providers/tour_providers.dart';

part 'marketplace_view_model.freezed.dart';

@freezed
class MarketplaceState with _$MarketplaceState {
  const factory MarketplaceState({
    @Default('') String searchQuery,
    @Default(null) TourCategory? selectedCategory,
    @Default(null) TourType? selectedTourType,
    @Default(false) bool isMapView,
    @Default(AsyncValue.loading()) AsyncValue<List<TourModel>> filteredTours,
    @Default([]) List<CollectionModel> visibleCollections,
  }) = _MarketplaceState;
}

class MarketplaceViewModel extends StateNotifier<MarketplaceState> {
  final Ref ref;

  MarketplaceViewModel(this.ref) : super(const MarketplaceState()) {
    _initHelper();
  }

  void _initHelper() {
    // Listen to tour updates and apply initial filters
    ref.listen(featuredToursProvider, (previous, next) {
      next.whenData((tours) {
        state = state.copyWith(filteredTours: AsyncValue.data(tours));
      });
    });
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void setCategory(TourCategory? category) {
    if (state.selectedCategory == category) {
      state = state.copyWith(selectedCategory: null);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
    _applyFilters();
  }

  void setTourType(TourType? type) {
    if (state.selectedTourType == type) {
      state = state.copyWith(selectedTourType: null);
    } else {
      state = state.copyWith(selectedTourType: type);
    }
    _applyFilters();
  }

  void toggleViewMode() {
    state = state.copyWith(isMapView: !state.isMapView);
  }

  Future<void> _applyFilters() async {
    // Start loading
    // state = state.copyWith(filteredTours: const AsyncValue.loading());

    try {
      // Get base tours (in real app, this might search API)
      final allTours = await ref.read(featuredToursProvider.future);

      final filtered =
          allTours.where((tour) {
            // Search Query
            if (state.searchQuery.isNotEmpty) {
              final query = state.searchQuery.toLowerCase();
              final matchesCity = tour.city?.toLowerCase().contains(query) ?? false;
              final matchesCountry = tour.country?.toLowerCase().contains(query) ?? false;

              if (!matchesCity && !matchesCountry) return false;
            }

            // Category
            if (state.selectedCategory != null) {
              if (tour.category != state.selectedCategory) return false;
            }

            // Tour Type
            if (state.selectedTourType != null) {
              if (tour.tourType != state.selectedTourType) return false;
            }

            return true;
          }).toList();

      state = state.copyWith(filteredTours: AsyncValue.data(filtered));
    } catch (e, st) {
      state = state.copyWith(filteredTours: AsyncValue.error(e, st));
    }
  }
}

final marketplaceProvider = StateNotifierProvider<MarketplaceViewModel, MarketplaceState>((ref) {
  return MarketplaceViewModel(ref);
});
