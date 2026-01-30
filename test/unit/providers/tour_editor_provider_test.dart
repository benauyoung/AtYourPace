import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ayp_tour_guide/data/models/pricing_model.dart';
import 'package:ayp_tour_guide/data/models/stop_model.dart';
import 'package:ayp_tour_guide/data/models/tour_model.dart';
import 'package:ayp_tour_guide/data/models/tour_version_model.dart';
import 'package:ayp_tour_guide/presentation/screens/modules/content_editor/providers/tour_editor_provider.dart';

// Mocks
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore mockFirestore;

  setUpAll(() {
    registerFallbackValue(TourCategory.history);
    registerFallbackValue(TourType.walking);
    registerFallbackValue(TourDifficulty.moderate);
  });

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
  });

  group('TourEditorState', () {
    test('should have correct default values', () {
      const state = TourEditorState();

      expect(state.tourId, isNull);
      expect(state.versionId, isNull);
      expect(state.tour, isNull);
      expect(state.version, isNull);
      expect(state.pricing, isNull);
      expect(state.stops, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.isSaving, isFalse);
      expect(state.error, isNull);
      expect(state.hasUnsavedChanges, isFalse);
      expect(state.currentTabIndex, equals(0));
    });

    test('isNewTour should return true when tourId is null', () {
      const state = TourEditorState();
      expect(state.isNewTour, isTrue);
    });

    test('isNewTour should return false when tourId is set', () {
      const state = TourEditorState(tourId: 'tour-123');
      expect(state.isNewTour, isFalse);
    });

    test('title should return version title or default', () {
      const stateWithoutVersion = TourEditorState();
      expect(stateWithoutVersion.title, equals('Untitled Tour'));

      final now = DateTime.now();
      final stateWithVersion = TourEditorState(
        version: TourVersionModel(
          id: 'v1',
          tourId: 't1',
          versionNumber: 1,
          title: 'My Tour',
          description: '',
          createdAt: now,
          updatedAt: now,
        ),
      );
      expect(stateWithVersion.title, equals('My Tour'));
    });

    test('hasMinimumContent should check title, description, and stops', () {
      const emptyState = TourEditorState();
      expect(emptyState.hasMinimumContent, isFalse);

      final now = DateTime.now();
      final completeState = TourEditorState(
        version: TourVersionModel(
          id: 'v1',
          tourId: 't1',
          versionNumber: 1,
          title: 'My Tour',
          description: 'A description',
          createdAt: now,
          updatedAt: now,
        ),
        stops: [
          StopModel(
            id: 's1',
            tourId: 't1',
            versionId: 'v1',
            order: 0,
            name: 'Stop 1',
            location: const GeoPoint(0, 0),
            geohash: 'abc123',
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );
      expect(completeState.hasMinimumContent, isTrue);
    });

    test('validationErrors should return list of issues', () {
      const emptyState = TourEditorState();
      final errors = emptyState.validationErrors;

      expect(errors, contains('Tour title is required'));
      expect(errors, contains('Tour description is required'));
      expect(errors, contains('At least one stop is required'));
      expect(errors, contains('Cover image is recommended'));
    });

    test('copyWith should preserve existing values', () {
      const original = TourEditorState(
        tourId: 'tour-1',
        isLoading: true,
      );

      final copied = original.copyWith(versionId: 'v-1');

      expect(copied.tourId, equals('tour-1'));
      expect(copied.versionId, equals('v-1'));
      expect(copied.isLoading, isTrue);
    });

    test('copyWith with clearError should set error to null', () {
      const state = TourEditorState(error: 'Some error');
      final cleared = state.copyWith(clearError: true);
      expect(cleared.error, isNull);
    });
  });

  group('TourEditorNotifier', () {
    test('should initialize with provided parameters', () {
      final notifier = TourEditorNotifier(
        firestore: mockFirestore,
        tourId: 'tour-123',
        versionId: 'version-456',
      );

      expect(notifier.state.tourId, equals('tour-123'));
      expect(notifier.state.versionId, equals('version-456'));
    });

    test('updateTitle should update version title', () {
      final notifier = TourEditorNotifier(firestore: mockFirestore);

      // Initialize with a version
      final now = DateTime.now();
      notifier.state = notifier.state.copyWith(
        version: TourVersionModel(
          id: 'v1',
          tourId: 't1',
          versionNumber: 1,
          title: '',
          description: '',
          createdAt: now,
          updatedAt: now,
        ),
      );

      notifier.updateTitle('New Title');

      expect(notifier.state.version?.title, equals('New Title'));
      expect(notifier.state.hasUnsavedChanges, isTrue);
    });

    test('updateDescription should update version description', () {
      final notifier = TourEditorNotifier(firestore: mockFirestore);

      final now = DateTime.now();
      notifier.state = notifier.state.copyWith(
        version: TourVersionModel(
          id: 'v1',
          tourId: 't1',
          versionNumber: 1,
          title: '',
          description: '',
          createdAt: now,
          updatedAt: now,
        ),
      );

      notifier.updateDescription('New Description');

      expect(notifier.state.version?.description, equals('New Description'));
      expect(notifier.state.hasUnsavedChanges, isTrue);
    });

    test('updateCoverImage should update version coverImageUrl', () {
      final notifier = TourEditorNotifier(firestore: mockFirestore);

      final now = DateTime.now();
      notifier.state = notifier.state.copyWith(
        version: TourVersionModel(
          id: 'v1',
          tourId: 't1',
          versionNumber: 1,
          title: '',
          description: '',
          createdAt: now,
          updatedAt: now,
        ),
      );

      notifier.updateCoverImage('https://example.com/image.jpg');

      expect(
        notifier.state.version?.coverImageUrl,
        equals('https://example.com/image.jpg'),
      );
      expect(notifier.state.hasUnsavedChanges, isTrue);
    });

    test('setFree should update pricing to free', () {
      final notifier = TourEditorNotifier(firestore: mockFirestore);

      final now = DateTime.now();
      notifier.state = notifier.state.copyWith(
        pricing: PricingModel(
          id: 'p1',
          tourId: 't1',
          type: PricingType.paid,
          price: 9.99,
          createdAt: now,
          updatedAt: now,
        ),
      );

      notifier.setFree();

      expect(notifier.state.pricing?.type, equals(PricingType.free));
      // Price is set to null via updatePricing call
      expect(notifier.state.hasUnsavedChanges, isTrue);
    });

    test('setPaid should update pricing with price', () {
      final notifier = TourEditorNotifier(firestore: mockFirestore);

      final now = DateTime.now();
      notifier.state = notifier.state.copyWith(
        pricing: PricingModel(
          id: 'p1',
          tourId: 't1',
          createdAt: now,
          updatedAt: now,
        ),
      );

      notifier.setPaid(4.99, currency: 'USD');

      expect(notifier.state.pricing?.type, equals(PricingType.paid));
      expect(notifier.state.pricing?.price, equals(4.99));
      expect(notifier.state.pricing?.currency, equals('USD'));
      expect(notifier.state.hasUnsavedChanges, isTrue);
    });

    test('addStop should add stop to list', () {
      final notifier = TourEditorNotifier(firestore: mockFirestore);
      final now = DateTime.now();
      final stop = StopModel(
        id: 's1',
        tourId: 't1',
        versionId: 'v1',
        order: 0,
        name: 'Test Stop',
        location: const GeoPoint(48.8566, 2.3522),
        geohash: 'u09tvw',
        createdAt: now,
        updatedAt: now,
      );

      notifier.addStop(stop);

      expect(notifier.state.stops.length, equals(1));
      expect(notifier.state.stops.first.name, equals('Test Stop'));
      expect(notifier.state.hasUnsavedChanges, isTrue);
    });

    test('removeStop should remove stop at index', () {
      final notifier = TourEditorNotifier(firestore: mockFirestore);
      final now = DateTime.now();
      final stops = [
        StopModel(
          id: 's1',
          tourId: 't1',
          versionId: 'v1',
          order: 0,
          name: 'Stop 1',
          location: const GeoPoint(0, 0),
          geohash: 'abc',
          createdAt: now,
          updatedAt: now,
        ),
        StopModel(
          id: 's2',
          tourId: 't1',
          versionId: 'v1',
          order: 1,
          name: 'Stop 2',
          location: const GeoPoint(0, 0),
          geohash: 'def',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      notifier.state = notifier.state.copyWith(stops: stops);
      notifier.removeStop(0);

      expect(notifier.state.stops.length, equals(1));
      expect(notifier.state.stops.first.name, equals('Stop 2'));
      expect(notifier.state.stops.first.order, equals(0)); // Reordered
    });

    test('reorderStops should move stop to new position', () {
      final notifier = TourEditorNotifier(firestore: mockFirestore);
      final now = DateTime.now();
      final stops = [
        StopModel(
          id: 's1',
          tourId: 't1',
          versionId: 'v1',
          order: 0,
          name: 'Stop 1',
          location: const GeoPoint(0, 0),
          geohash: 'abc',
          createdAt: now,
          updatedAt: now,
        ),
        StopModel(
          id: 's2',
          tourId: 't1',
          versionId: 'v1',
          order: 1,
          name: 'Stop 2',
          location: const GeoPoint(0, 0),
          geohash: 'def',
          createdAt: now,
          updatedAt: now,
        ),
        StopModel(
          id: 's3',
          tourId: 't1',
          versionId: 'v1',
          order: 2,
          name: 'Stop 3',
          location: const GeoPoint(0, 0),
          geohash: 'ghi',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      notifier.state = notifier.state.copyWith(stops: stops);
      notifier.reorderStops(0, 2); // Move first to third position
      // After reorder: removeAt(0) -> [Stop 2, Stop 3], insert(2, Stop 1) -> [Stop 2, Stop 3, Stop 1]

      expect(notifier.state.stops[0].name, equals('Stop 2'));
      expect(notifier.state.stops[1].name, equals('Stop 3'));
      expect(notifier.state.stops[2].name, equals('Stop 1'));

      // Check orders are updated
      expect(notifier.state.stops[0].order, equals(0));
      expect(notifier.state.stops[1].order, equals(1));
      expect(notifier.state.stops[2].order, equals(2));
    });

    test('setCurrentTab should update tab index', () {
      final notifier = TourEditorNotifier(firestore: mockFirestore);

      notifier.setCurrentTab(2);

      expect(notifier.state.currentTabIndex, equals(2));
    });

    test('clearError should remove error message', () {
      final notifier = TourEditorNotifier(firestore: mockFirestore);
      notifier.state = notifier.state.copyWith(error: 'Test error');

      notifier.clearError();

      expect(notifier.state.error, isNull);
    });
  });

  group('TourEditorState getters', () {
    test('stopsCount should return number of stops', () {
      final now = DateTime.now();
      final state = TourEditorState(
        stops: [
          StopModel(
            id: 's1',
            tourId: 't1',
            versionId: 'v1',
            order: 0,
            name: 'Stop 1',
            location: const GeoPoint(0, 0),
            geohash: 'abc',
            createdAt: now,
            updatedAt: now,
          ),
          StopModel(
            id: 's2',
            tourId: 't1',
            versionId: 'v1',
            order: 1,
            name: 'Stop 2',
            location: const GeoPoint(0, 0),
            geohash: 'def',
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );

      expect(state.stopsCount, equals(2));
    });

    test('isFree should check pricing type', () {
      const stateWithoutPricing = TourEditorState();
      expect(stateWithoutPricing.isFree, isTrue);

      final now = DateTime.now();
      final stateWithFreePricing = TourEditorState(
        pricing: PricingModel(
          id: 'p1',
          tourId: 't1',
          type: PricingType.free,
          createdAt: now,
          updatedAt: now,
        ),
      );
      expect(stateWithFreePricing.isFree, isTrue);

      final stateWithPaidPricing = TourEditorState(
        pricing: PricingModel(
          id: 'p2',
          tourId: 't1',
          type: PricingType.paid,
          price: 9.99,
          createdAt: now,
          updatedAt: now,
        ),
      );
      expect(stateWithPaidPricing.isFree, isFalse);
    });

    test('category should return tour category or default', () {
      const stateWithoutTour = TourEditorState();
      expect(stateWithoutTour.category, equals(TourCategory.history));
    });

    test('tourType should return tour type or default', () {
      const stateWithoutTour = TourEditorState();
      expect(stateWithoutTour.tourType, equals(TourType.walking));
    });

    test('difficulty should return version difficulty or default', () {
      const stateWithoutVersion = TourEditorState();
      expect(stateWithoutVersion.difficulty, equals(TourDifficulty.moderate));
    });
  });
}
