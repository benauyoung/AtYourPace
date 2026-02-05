import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../../data/models/pricing_model.dart';
import '../../../../../data/models/stop_model.dart';
import '../../../../../data/models/tour_model.dart';
import '../../../../../data/models/tour_version_model.dart';

/// State for the Tour Editor
class TourEditorState {
  final String? tourId;
  final String? versionId;
  final TourModel? tour;
  final TourVersionModel? version;
  final PricingModel? pricing;
  final List<StopModel> stops;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final bool hasUnsavedChanges;
  final int currentTabIndex;

  const TourEditorState({
    this.tourId,
    this.versionId,
    this.tour,
    this.version,
    this.pricing,
    this.stops = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.hasUnsavedChanges = false,
    this.currentTabIndex = 0,
  });

  TourEditorState copyWith({
    String? tourId,
    String? versionId,
    TourModel? tour,
    TourVersionModel? version,
    PricingModel? pricing,
    List<StopModel>? stops,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
    bool? hasUnsavedChanges,
    int? currentTabIndex,
  }) {
    return TourEditorState(
      tourId: tourId ?? this.tourId,
      versionId: versionId ?? this.versionId,
      tour: tour ?? this.tour,
      version: version ?? this.version,
      pricing: pricing ?? this.pricing,
      stops: stops ?? this.stops,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }

  /// Check if this is a new tour (not yet saved)
  bool get isNewTour => tourId == null;

  /// Check if the tour is published
  bool get isPublished => tour?.isPublished ?? false;

  /// Get the tour title
  String get title => version?.title ?? 'Untitled Tour';

  /// Get the tour description
  String get description => version?.description ?? '';

  /// Get cover image URL
  String? get coverImageUrl => version?.coverImageUrl;

  /// Get tour category
  TourCategory get category => tour?.category ?? TourCategory.history;

  /// Get tour type
  TourType get tourType => tour?.tourType ?? TourType.walking;

  /// Get tour status
  TourStatus get status => tour?.status ?? TourStatus.draft;

  /// Get difficulty
  TourDifficulty get difficulty => version?.difficulty ?? TourDifficulty.moderate;

  /// Get location info
  String? get city => tour?.city;
  String? get region => tour?.region;
  String? get country => tour?.country;

  /// Get pricing info
  bool get isFree => pricing?.isFree ?? true;
  double? get price => pricing?.price;
  String get currency => pricing?.currency ?? 'EUR';

  /// Get stops count
  int get stopsCount => stops.length;

  /// Check if tour has minimum required content
  bool get hasMinimumContent {
    return title.isNotEmpty &&
        description.isNotEmpty &&
        stops.isNotEmpty;
  }

  /// Get validation errors
  List<String> get validationErrors {
    final errors = <String>[];
    if (title.isEmpty || title == 'Untitled Tour') {
      errors.add('Tour title is required');
    }
    if (description.isEmpty) {
      errors.add('Tour description is required');
    }
    if (stops.isEmpty) {
      errors.add('At least one stop is required');
    }
    if (coverImageUrl == null) {
      errors.add('Cover image is recommended');
    }
    return errors;
  }
}

/// Tour Editor Notifier
class TourEditorNotifier extends StateNotifier<TourEditorState> {
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  TourEditorNotifier({
    required FirebaseFirestore firestore,
    String? tourId,
    String? versionId,
  })  : _firestore = firestore,
        super(TourEditorState(
          tourId: tourId,
          versionId: versionId,
        ));

  /// Initialize the editor - load existing tour or prepare for new
  Future<void> initialize() async {
    if (state.tourId == null) {
      // New tour - create default state
      _initializeNewTour();
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Load tour
      final tourDoc = await _firestore
          .collection('tours')
          .doc(state.tourId)
          .get();

      if (!tourDoc.exists) {
        state = state.copyWith(
          isLoading: false,
          error: 'Tour not found',
        );
        return;
      }

      final tour = TourModel.fromFirestore(tourDoc);
      final versionId = state.versionId ?? tour.draftVersionId;

      // Load version
      final versionDoc = await _firestore
          .collection('tours')
          .doc(state.tourId)
          .collection('versions')
          .doc(versionId)
          .get();

      TourVersionModel? version;
      if (versionDoc.exists) {
        version = TourVersionModel.fromFirestore(
          versionDoc,
          tourId: state.tourId!,
        );
      }

      // Load pricing
      final pricingQuery = await _firestore
          .collection('tours')
          .doc(state.tourId)
          .collection('pricing')
          .limit(1)
          .get();

      PricingModel? pricing;
      if (pricingQuery.docs.isNotEmpty) {
        pricing = PricingModel.fromFirestore(pricingQuery.docs.first);
      }

      // Load stops
      final stopsQuery = await _firestore
          .collection('tours')
          .doc(state.tourId)
          .collection('versions')
          .doc(versionId)
          .collection('stops')
          .orderBy('order')
          .get();

      final stops = stopsQuery.docs
          .map((doc) => StopModel.fromFirestore(
                doc,
                tourId: state.tourId!,
                versionId: versionId,
              ))
          .toList();

      state = state.copyWith(
        tour: tour,
        versionId: versionId,
        version: version,
        pricing: pricing,
        stops: stops,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load tour: $e',
      );
    }
  }

  void _initializeNewTour() {
    final now = DateTime.now();
    state = state.copyWith(
      version: TourVersionModel(
        id: '',
        tourId: '',
        versionNumber: 1,
        title: '',
        description: '',
        createdAt: now,
        updatedAt: now,
      ),
      pricing: PricingModel(
        id: '',
        tourId: '',
        createdAt: now,
        updatedAt: now,
      ),
      stops: [],
    );
  }

  /// Update basic info
  void updateBasicInfo({
    String? title,
    String? description,
    TourCategory? category,
    TourType? tourType,
    TourDifficulty? difficulty,
    String? city,
    String? region,
    String? country,
  }) {
    final updatedVersion = state.version?.copyWith(
      title: title ?? state.version!.title,
      description: description ?? state.version!.description,
      difficulty: difficulty ?? state.version!.difficulty,
      updatedAt: DateTime.now(),
    );

    // For tour-level fields, we need to track them separately
    // since TourModel is immutable and tied to Firestore
    state = state.copyWith(
      version: updatedVersion,
      hasUnsavedChanges: true,
    );
  }

  /// Update title
  void updateTitle(String title) {
    if (state.version == null) return;
    state = state.copyWith(
      version: state.version!.copyWith(
        title: title,
        updatedAt: DateTime.now(),
      ),
      hasUnsavedChanges: true,
    );
  }

  /// Update description
  void updateDescription(String description) {
    if (state.version == null) return;
    state = state.copyWith(
      version: state.version!.copyWith(
        description: description,
        updatedAt: DateTime.now(),
      ),
      hasUnsavedChanges: true,
    );
  }

  /// Update cover image
  void updateCoverImage(String? imageUrl) {
    if (state.version == null) return;
    state = state.copyWith(
      version: state.version!.copyWith(
        coverImageUrl: imageUrl,
        updatedAt: DateTime.now(),
      ),
      hasUnsavedChanges: true,
    );
  }

  /// Update pricing
  void updatePricing({
    PricingType? type,
    double? price,
    String? currency,
  }) {
    if (state.pricing == null) return;
    state = state.copyWith(
      pricing: state.pricing!.copyWith(
        type: type ?? state.pricing!.type,
        price: price ?? state.pricing!.price,
        currency: currency ?? state.pricing!.currency,
        updatedAt: DateTime.now(),
      ),
      hasUnsavedChanges: true,
    );
  }

  /// Set pricing to free
  void setFree() {
    updatePricing(type: PricingType.free, price: null);
  }

  /// Set pricing to paid
  void setPaid(double price, {String currency = 'EUR'}) {
    updatePricing(type: PricingType.paid, price: price, currency: currency);
  }

  /// Update stops list
  void updateStops(List<StopModel> stops) {
    state = state.copyWith(
      stops: stops,
      hasUnsavedChanges: true,
    );
  }

  /// Add a stop
  void addStop(StopModel stop) {
    final updatedStops = [...state.stops, stop];
    state = state.copyWith(
      stops: updatedStops,
      hasUnsavedChanges: true,
    );
  }

  /// Remove a stop
  void removeStop(int index) {
    if (index < 0 || index >= state.stops.length) return;
    final updatedStops = [...state.stops]..removeAt(index);
    // Reorder remaining stops
    for (var i = index; i < updatedStops.length; i++) {
      updatedStops[i] = updatedStops[i].copyWith(order: i);
    }
    state = state.copyWith(
      stops: updatedStops,
      hasUnsavedChanges: true,
    );
  }

  /// Reorder stops
  void reorderStops(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    final updatedStops = [...state.stops];
    final stop = updatedStops.removeAt(oldIndex);
    updatedStops.insert(newIndex, stop);
    // Update order for all stops
    for (var i = 0; i < updatedStops.length; i++) {
      updatedStops[i] = updatedStops[i].copyWith(order: i);
    }
    state = state.copyWith(
      stops: updatedStops,
      hasUnsavedChanges: true,
    );
  }

  /// Change current tab
  void setCurrentTab(int index) {
    state = state.copyWith(currentTabIndex: index);
  }

  /// Save the tour
  Future<bool> save() async {
    if (state.version == null) {
      state = state.copyWith(error: 'No tour data to save');
      return false;
    }

    // Prevent saving tours that are pending review or approved
    if (!state.isNewTour && state.tour != null && !state.tour!.isEditable) {
      state = state.copyWith(
        error: 'This tour cannot be edited in its current status',
      );
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final now = DateTime.now();

      if (state.isNewTour) {
        // Create new tour
        final tourId = _uuid.v4();
        final versionId = _uuid.v4();

        // Create tour document
        final tour = TourModel(
          id: tourId,
          creatorId: '', // Will be set by auth
          creatorName: '', // Will be set by auth
          category: TourCategory.history, // Default
          tourType: TourType.walking, // Default
          startLocation: const GeoPoint(0, 0), // Will be set from first stop
          geohash: '',
          draftVersionId: versionId,
          draftVersion: 1,
          createdAt: now,
          updatedAt: now,
        );

        // Create version document
        final version = state.version!.copyWith(
          id: versionId,
          tourId: tourId,
          createdAt: now,
          updatedAt: now,
        );

        // Create pricing document
        final pricing = state.pricing!.copyWith(
          id: _uuid.v4(),
          tourId: tourId,
          createdAt: now,
          updatedAt: now,
        );

        // Batch write
        final batch = _firestore.batch();

        batch.set(
          _firestore.collection('tours').doc(tourId),
          tour.toFirestore(),
        );

        batch.set(
          _firestore
              .collection('tours')
              .doc(tourId)
              .collection('versions')
              .doc(versionId),
          version.toFirestore(),
        );

        batch.set(
          _firestore
              .collection('tours')
              .doc(tourId)
              .collection('pricing')
              .doc(pricing.id),
          pricing.toFirestore(),
        );

        // Save stops
        for (final stop in state.stops) {
          final stopId = stop.id.isEmpty ? _uuid.v4() : stop.id;
          batch.set(
            _firestore
                .collection('tours')
                .doc(tourId)
                .collection('versions')
                .doc(versionId)
                .collection('stops')
                .doc(stopId),
            stop.copyWith(id: stopId).toFirestore(),
          );
        }

        await batch.commit();

        state = state.copyWith(
          tourId: tourId,
          versionId: versionId,
          tour: tour,
          version: version,
          pricing: pricing,
          isSaving: false,
          hasUnsavedChanges: false,
        );
      } else {
        // Update existing tour
        final batch = _firestore.batch();

        // Update version
        if (state.version != null) {
          batch.update(
            _firestore
                .collection('tours')
                .doc(state.tourId)
                .collection('versions')
                .doc(state.versionId),
            state.version!.copyWith(updatedAt: now).toFirestore(),
          );
        }

        // Update pricing
        if (state.pricing != null && state.pricing!.id.isNotEmpty) {
          batch.update(
            _firestore
                .collection('tours')
                .doc(state.tourId)
                .collection('pricing')
                .doc(state.pricing!.id),
            state.pricing!.copyWith(updatedAt: now).toFirestore(),
          );
        }

        // Update tour timestamp
        batch.update(
          _firestore.collection('tours').doc(state.tourId),
          {'updatedAt': FieldValue.serverTimestamp()},
        );

        await batch.commit();

        state = state.copyWith(
          isSaving: false,
          hasUnsavedChanges: false,
        );
      }

      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to save tour: $e',
      );
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Discard changes
  void discardChanges() {
    initialize();
  }
}

/// Provider for tour editor state
final tourEditorProvider = StateNotifierProvider.autoDispose
    .family<TourEditorNotifier, TourEditorState, ({String? tourId, String? versionId})>(
  (ref, params) {
    return TourEditorNotifier(
      firestore: FirebaseFirestore.instance,
      tourId: params.tourId,
      versionId: params.versionId,
    );
  },
);
