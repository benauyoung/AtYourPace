import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../data/models/tour_model.dart';

/// Filter options for tour manager
class TourManagerFilters {
  final TourStatus? status;
  final TourCategory? category;
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool showOnlyMine;

  const TourManagerFilters({
    this.status,
    this.category,
    this.searchQuery,
    this.startDate,
    this.endDate,
    this.showOnlyMine = true,
  });

  TourManagerFilters copyWith({
    TourStatus? status,
    bool clearStatus = false,
    TourCategory? category,
    bool clearCategory = false,
    String? searchQuery,
    bool clearSearch = false,
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    bool? showOnlyMine,
  }) {
    return TourManagerFilters(
      status: clearStatus ? null : (status ?? this.status),
      category: clearCategory ? null : (category ?? this.category),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      showOnlyMine: showOnlyMine ?? this.showOnlyMine,
    );
  }

  bool get hasFilters =>
      status != null ||
      category != null ||
      (searchQuery != null && searchQuery!.isNotEmpty) ||
      startDate != null ||
      endDate != null;

  int get filterCount {
    int count = 0;
    if (status != null) count++;
    if (category != null) count++;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    if (startDate != null || endDate != null) count++;
    return count;
  }
}

/// State for tour manager
class TourManagerState {
  final List<TourModel> tours;
  final TourManagerFilters filters;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;
  final int totalCount;
  final TourManagerViewMode viewMode;

  const TourManagerState({
    this.tours = const [],
    this.filters = const TourManagerFilters(),
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.lastDocument,
    this.hasMore = true,
    this.totalCount = 0,
    this.viewMode = TourManagerViewMode.list,
  });

  TourManagerState copyWith({
    List<TourModel>? tours,
    TourManagerFilters? filters,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
    DocumentSnapshot? lastDocument,
    bool? hasMore,
    int? totalCount,
    TourManagerViewMode? viewMode,
  }) {
    return TourManagerState(
      tours: tours ?? this.tours,
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      lastDocument: lastDocument ?? this.lastDocument,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  /// Get tours by status
  List<TourModel> get draftTours =>
      tours.where((t) => t.status == TourStatus.draft).toList();

  List<TourModel> get pendingTours =>
      tours.where((t) => t.status == TourStatus.pendingReview).toList();

  List<TourModel> get approvedTours =>
      tours.where((t) => t.status == TourStatus.approved).toList();

  List<TourModel> get rejectedTours =>
      tours.where((t) => t.status == TourStatus.rejected).toList();

  /// Get stats
  int get draftCount => draftTours.length;
  int get pendingCount => pendingTours.length;
  int get approvedCount => approvedTours.length;
  int get rejectedCount => rejectedTours.length;
}

/// View modes for tour manager
enum TourManagerViewMode {
  list,
  grid,
  analytics,
  calendar,
}

/// Tour manager notifier
class TourManagerNotifier extends StateNotifier<TourManagerState> {
  final FirebaseFirestore _firestore;
  final String? _userId;
  final bool _isAdmin;

  static const int _pageSize = 20;

  TourManagerNotifier({
    required FirebaseFirestore firestore,
    String? userId,
    bool isAdmin = false,
  })  : _firestore = firestore,
        _userId = userId,
        _isAdmin = isAdmin,
        super(const TourManagerState());

  /// Initialize and load tours
  Future<void> initialize() async {
    await loadTours();
  }

  /// Load tours with current filters
  Future<void> loadTours() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      var query = _buildQuery();
      query = query.limit(_pageSize);

      final snapshot = await query.get();
      final tours = snapshot.docs
          .map((doc) => TourModel.fromFirestore(doc))
          .toList();

      state = state.copyWith(
        tours: tours,
        isLoading: false,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        hasMore: snapshot.docs.length == _pageSize,
        totalCount: tours.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load tours: $e',
      );
    }
  }

  /// Load more tours (pagination)
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.lastDocument == null) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      var query = _buildQuery();
      query = query.startAfterDocument(state.lastDocument!).limit(_pageSize);

      final snapshot = await query.get();
      final newTours = snapshot.docs
          .map((doc) => TourModel.fromFirestore(doc))
          .toList();

      state = state.copyWith(
        tours: [...state.tours, ...newTours],
        isLoadingMore: false,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        hasMore: snapshot.docs.length == _pageSize,
        totalCount: state.tours.length + newTours.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: 'Failed to load more tours: $e',
      );
    }
  }

  /// Build Firestore query based on filters
  Query<Map<String, dynamic>> _buildQuery() {
    Query<Map<String, dynamic>> query = _firestore.collection('tours');

    // Filter by creator (unless admin viewing all)
    if (state.filters.showOnlyMine && _userId != null) {
      query = query.where('creatorId', isEqualTo: _userId);
    }

    // Filter by status
    if (state.filters.status != null) {
      query = query.where('status', isEqualTo: state.filters.status!.name);
    }

    // Filter by category
    if (state.filters.category != null) {
      query = query.where('category', isEqualTo: state.filters.category!.name);
    }

    // Order by updated date
    query = query.orderBy('updatedAt', descending: true);

    return query;
  }

  /// Update filters
  void updateFilters(TourManagerFilters filters) {
    state = state.copyWith(filters: filters);
    loadTours();
  }

  /// Set status filter
  void filterByStatus(TourStatus? status) {
    updateFilters(state.filters.copyWith(
      status: status,
      clearStatus: status == null,
    ));
  }

  /// Set category filter
  void filterByCategory(TourCategory? category) {
    updateFilters(state.filters.copyWith(
      category: category,
      clearCategory: category == null,
    ));
  }

  /// Set search query
  void search(String? query) {
    updateFilters(state.filters.copyWith(
      searchQuery: query,
      clearSearch: query == null || query.isEmpty,
    ));
  }

  /// Clear all filters
  void clearFilters() {
    updateFilters(const TourManagerFilters());
  }

  /// Toggle show only mine
  void toggleShowOnlyMine() {
    if (!_isAdmin) return;
    updateFilters(state.filters.copyWith(
      showOnlyMine: !state.filters.showOnlyMine,
    ));
  }

  /// Change view mode
  void setViewMode(TourManagerViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  /// Delete a tour
  Future<bool> deleteTour(String tourId) async {
    try {
      await _firestore.collection('tours').doc(tourId).delete();
      state = state.copyWith(
        tours: state.tours.where((t) => t.id != tourId).toList(),
        totalCount: state.totalCount - 1,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete tour: $e');
      return false;
    }
  }

  /// Duplicate a tour
  Future<String?> duplicateTour(String tourId) async {
    try {
      final original = state.tours.firstWhere((t) => t.id == tourId);
      final newTourRef = _firestore.collection('tours').doc();
      final newVersionId = '${newTourRef.id}_v1';

      final duplicate = TourModel(
        id: newTourRef.id,
        creatorId: _userId ?? original.creatorId,
        creatorName: original.creatorName,
        category: original.category,
        tourType: original.tourType,
        startLocation: original.startLocation,
        geohash: original.geohash,
        city: original.city,
        region: original.region,
        country: original.country,
        status: TourStatus.draft,
        draftVersionId: newVersionId,
        draftVersion: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await newTourRef.set(duplicate.toFirestore());

      // Add to local state
      state = state.copyWith(
        tours: [duplicate, ...state.tours],
        totalCount: state.totalCount + 1,
      );

      return newTourRef.id;
    } catch (e) {
      state = state.copyWith(error: 'Failed to duplicate tour: $e');
      return null;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Refresh tours
  Future<void> refresh() async {
    await loadTours();
  }
}

/// Provider for tour manager
final tourManagerProvider = StateNotifierProvider.autoDispose
    .family<TourManagerNotifier, TourManagerState, ({String? userId, bool isAdmin})>(
  (ref, params) {
    final notifier = TourManagerNotifier(
      firestore: FirebaseFirestore.instance,
      userId: params.userId,
      isAdmin: params.isAdmin,
    );
    // Initialize on creation
    notifier.initialize();
    return notifier;
  },
);

/// Provider for filters only (for widgets that just need filter state)
final tourManagerFiltersProvider = Provider.autoDispose
    .family<TourManagerFilters, ({String? userId, bool isAdmin})>(
  (ref, params) {
    return ref.watch(tourManagerProvider(params)).filters;
  },
);
