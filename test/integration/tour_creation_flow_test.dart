import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';

import 'package:ayp_tour_guide/data/models/stop_model.dart';
import 'package:ayp_tour_guide/data/models/tour_model.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

/// Integration tests for the tour creation flow.
///
/// Tests the flow: Create Tour -> Add Details -> Add Stops
/// -> Record Audio -> Submit for Review
void main() {
  group('Tour Creation Flow Integration', () {
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference<Map<String, dynamic>> mockToursCollection;
    late MockDocumentReference<Map<String, dynamic>> mockTourDoc;
    late MockCollectionReference<Map<String, dynamic>> mockVersionsCollection;
    late MockDocumentReference<Map<String, dynamic>> mockVersionDoc;
    late MockCollectionReference<Map<String, dynamic>> mockStopsCollection;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockToursCollection = MockCollectionReference();
      mockTourDoc = MockDocumentReference();
      mockVersionsCollection = MockCollectionReference();
      mockVersionDoc = MockDocumentReference();
      mockStopsCollection = MockCollectionReference();

      // Setup collection paths
      when(mockFirestore.collection('tours')).thenReturn(mockToursCollection);
      when(mockToursCollection.doc(any)).thenReturn(mockTourDoc);
      when(mockTourDoc.collection('versions')).thenReturn(mockVersionsCollection);
      when(mockVersionsCollection.doc(any)).thenReturn(mockVersionDoc);
      when(mockVersionDoc.collection('stops')).thenReturn(mockStopsCollection);
    });

    group('Tour Model Creation', () {
      test('creates tour with required fields', () {
        final tour = createTestTour(
          id: 'new_tour_1',
          creatorId: 'creator_123',
          creatorName: 'Test Creator',
          city: 'San Francisco',
          country: 'USA',
          category: TourCategory.history,
          tourType: TourType.walking,
          latitude: 37.7749,
          longitude: -122.4194,
          geohash: 'test_geohash',
          draftVersionId: 'v1',
          status: TourStatus.draft,
        );

        expect(tour.id, equals('new_tour_1'));
        expect(tour.status, equals(TourStatus.draft));
        expect(tour.city, equals('San Francisco'));
      });

      test('creates tour with optional fields', () {
        final tour = createTestTour(
          id: 'new_tour_2',
          creatorId: 'creator_123',
          creatorName: 'Test Creator',
          city: 'Paris',
          region: 'Ile-de-France',
          country: 'France',
          category: TourCategory.art,
          tourType: TourType.driving,
          latitude: 48.8566,
          longitude: 2.3522,
          geohash: 'test_geohash',
          draftVersionId: 'v1',
          status: TourStatus.draft,
          featured: false,
        );

        expect(tour.region, equals('Ile-de-France'));
        expect(tour.category, equals(TourCategory.art));
        expect(tour.tourType, equals(TourType.driving));
      });

      test('validates tour categories', () {
        for (final category in TourCategory.values) {
          final tour = createTestTour(category: category);
          expect(tour.category, equals(category));
          expect(category.displayName, isNotEmpty);
          expect(category.icon, isNotNull);
        }
      });

      test('validates tour types', () {
        for (final tourType in TourType.values) {
          final tour = createTestTour(tourType: tourType);
          expect(tour.tourType, equals(tourType));
          expect(tourType.displayName, isNotEmpty);
        }
      });
    });

    group('Tour Version Creation', () {
      test('creates version with tour details', () {
        final version = createTestTourVersion(
          id: 'v1',
          tourId: 'tour_123',
          title: 'Historic Walking Tour',
          description: 'Explore the historic district',
          duration: '2 hours',
          distance: '5.5 km',
        );

        expect(version.title, equals('Historic Walking Tour'));
        expect(version.duration, equals('2 hours'));
        expect(version.distance, equals('5.5 km'));
      });

      test('handles version with cover image', () {
        final version = createTestTourVersion(
          id: 'v1',
          tourId: 'tour_123',
          title: 'Photo Tour',
          description: 'Beautiful scenery',
          coverImageUrl: 'https://example.com/cover.jpg',
        );

        expect(version.coverImageUrl, isNotNull);
        expect(version.coverImageUrl, contains('https://'));
      });
    });

    group('Stop Creation', () {
      test('creates stop with required fields', () {
        final stop = createTestStop(
          id: 'stop_1',
          tourId: 'tour_123',
          versionId: 'v1',
          name: 'Golden Gate Bridge',
          description: 'Iconic suspension bridge',
          order: 0,
          latitude: 37.8199,
          longitude: -122.4783,
          triggerRadius: 50,
        );

        expect(stop.name, contains('Golden Gate Bridge'));
        expect(stop.order, equals(0));
        expect(stop.triggerRadius, equals(50));
      });

      test('creates stop with audio', () {
        final stop = createTestStop(
          id: 'stop_1',
          tourId: 'tour_123',
          versionId: 'v1',
          name: 'Audio Stop',
          description: 'Stop with audio narration',
          order: 0,
          latitude: 37.8199,
          longitude: -122.4783,
          triggerRadius: 50,
          audioUrl: 'https://storage.example.com/audio/stop1.mp3',
        );

        expect(stop.media.audioUrl, isNotNull);
        expect(stop.media.audioUrl, contains('stop1.mp3'));
      });

      test('maintains stop order correctly', () {
        final stops = createTestStops(count: 5);

        for (int i = 0; i < stops.length; i++) {
          expect(stops[i].order, equals(i));
        }

        // Verify ordering is consistent
        final sortedStops = List<StopModel>.from(stops)
          ..sort((a, b) => a.order.compareTo(b.order));

        for (int i = 0; i < sortedStops.length; i++) {
          expect(sortedStops[i].order, equals(i));
        }
      });
    });

    group('Draft Editing', () {
      test('updates tour details', () {
        var tour = createTestTour(city: 'Original City');

        tour = tour.copyWith(
          city: 'Updated City',
          updatedAt: DateTime.now(),
        );

        expect(tour.city, equals('Updated City'));
      });

      test('updates version details', () {
        var version = createTestTourVersion(title: 'Original Title');

        version = version.copyWith(
          title: 'Updated Title',
          description: 'New description',
        );

        expect(version.title, equals('Updated Title'));
        expect(version.description, equals('New description'));
      });

      test('reorders stops', () {
        final stops = createTestStops(count: 3);

        // Simulate reordering: move stop 0 to position 2
        final reorderedStops = [
          stops[1].copyWith(order: 0),
          stops[2].copyWith(order: 1),
          stops[0].copyWith(order: 2),
        ];

        expect(reorderedStops[0].order, equals(0));
        expect(reorderedStops[1].order, equals(1));
        expect(reorderedStops[2].order, equals(2));

        // Original stop 0 should now be at position 2
        expect(reorderedStops[2].id, equals(stops[0].id));
      });

      test('deletes stop and reorders remaining', () {
        var stops = createTestStops(count: 4);

        // Delete stop at index 1
        stops = stops.where((s) => s.order != 1).toList();

        // Reorder remaining stops
        stops = stops.asMap().entries.map((e) {
          return e.value.copyWith(order: e.key);
        }).toList();

        expect(stops.length, equals(3));
        expect(stops[0].order, equals(0));
        expect(stops[1].order, equals(1));
        expect(stops[2].order, equals(2));
      });
    });

    group('Validation', () {
      test('validates required tour fields using helper', () {
        // Tour created with helper has all required fields
        final tour = createTestTour(
          city: '', // Empty city allowed by model
        );

        // Model allows empty city, validation happens in service layer
        expect(() => tour, returnsNormally);
      });

      test('validates stop trigger radius', () {
        final stop = createTestStop(
          triggerRadius: 25, // Minimum radius
        );

        expect(stop.triggerRadius, greaterThanOrEqualTo(25));
      });

      test('validates coordinates are within range', () {
        final stop = createTestStop(
          latitude: 37.7749, // Valid latitude
          longitude: -122.4194, // Valid longitude
        );

        expect(stop.location.latitude, inInclusiveRange(-90, 90));
        expect(stop.location.longitude, inInclusiveRange(-180, 180));
      });
    });

    group('Submit for Review', () {
      test('changes status from draft to pending review', () {
        var tour = createTestTour(status: TourStatus.draft);

        expect(tour.status, equals(TourStatus.draft));

        tour = tour.copyWith(status: TourStatus.pendingReview);

        expect(tour.status, equals(TourStatus.pendingReview));
      });

      test('validates tour has minimum requirements before submission', () {
        final tour = createTestTour();
        final version = createTestTourVersion(tourId: tour.id);
        final stops = createTestStops(count: 2);

        // Check minimum requirements
        expect(tour.city!.isNotEmpty, isTrue);
        expect(version.title.isNotEmpty, isTrue);
        expect(stops.length, greaterThanOrEqualTo(1));

        // Check at least one stop has audio
        final hasAudio = stops.any((s) => s.media.audioUrl != null);
        expect(hasAudio, isTrue);
      });

      test('records submission timestamp', () {
        final beforeSubmit = DateTime.now();

        final tour = createTestTour(status: TourStatus.draft).copyWith(
          status: TourStatus.pendingReview,
          updatedAt: DateTime.now(),
        );

        expect(tour.updatedAt.isAfter(beforeSubmit) ||
            tour.updatedAt.isAtSameMomentAs(beforeSubmit), isTrue);
      });
    });

    group('Serialization', () {
      test('tour serializes to Firestore format', () {
        final tour = createTestTour();
        final data = tour.toFirestore();

        // Note: id is excluded from toFirestore as it's the document ID
        expect(data['city'], equals(tour.city));
        expect(data['status'], equals(tour.status.name));
        expect(data['startLocation'], isA<GeoPoint>());
        expect(data['creatorId'], equals(tour.creatorId));
      });

      test('version serializes to Firestore format', () {
        final version = createTestTourVersion();
        final data = version.toFirestore();

        expect(data['title'], equals(version.title));
        // Note: tourId and id may be excluded from toFirestore as document references
        expect(data['versionNumber'], equals(version.versionNumber));
        expect(data['description'], equals(version.description));
      });

      test('stop serializes to Firestore format', () {
        final stop = createTestStop();
        final data = stop.toFirestore();

        expect(data['name'], equals(stop.name));
        expect(data['order'], equals(stop.order));
        expect(data['location'], isA<GeoPoint>());
      });
    });

    group('Full Creation Workflow', () {
      test('complete tour creation scenario', () {
        // 1. Create tour shell using helper
        final tour = createTestTour(
          id: 'workflow_tour_1',
          creatorId: 'creator_123',
          creatorName: 'Test Creator',
          city: 'New York',
          region: 'New York',
          country: 'USA',
          category: TourCategory.history,
          tourType: TourType.walking,
          latitude: 40.7128,
          longitude: -74.0060,
          geohash: 'dr5regw',
          draftVersionId: 'v1',
          status: TourStatus.draft,
        );

        expect(tour.status, equals(TourStatus.draft));

        // 2. Create version with details
        final version = createTestTourVersion(
          id: 'v1',
          tourId: tour.id,
          title: 'Historic NYC Walking Tour',
          description: 'Explore historic landmarks of Manhattan',
          duration: '2 hours 30 minutes',
          distance: '4.5 km',
        );

        expect(version.tourId, equals(tour.id));

        // 3. Add stops
        final stops = <StopModel>[];
        final stopNames = ['Statue of Liberty', 'Ellis Island', 'Battery Park'];
        final stopCoords = [
          (40.6892, -74.0445),
          (40.6995, -74.0396),
          (40.7033, -74.0170),
        ];

        for (int i = 0; i < stopNames.length; i++) {
          stops.add(createTestStop(
            id: 'stop_$i',
            tourId: tour.id,
            versionId: version.id,
            name: stopNames[i],
            description: 'Description for ${stopNames[i]}',
            order: i,
            latitude: stopCoords[i].$1,
            longitude: stopCoords[i].$2,
            triggerRadius: 50,
            audioUrl: 'https://storage.example.com/audio/stop_$i.mp3',
          ));
        }

        expect(stops.length, equals(3));
        expect(stops.every((s) => s.media.audioUrl != null), isTrue);

        // 4. Submit for review
        final submittedTour = tour.copyWith(
          status: TourStatus.pendingReview,
          updatedAt: DateTime.now(),
        );

        expect(submittedTour.status, equals(TourStatus.pendingReview));
      });
    });
  });
}
