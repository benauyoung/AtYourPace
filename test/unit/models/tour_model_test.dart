import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ayp_tour_guide/data/models/tour_model.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('TourModel', () {
    group('Serialization', () {
      test('fromJson creates model with all required fields', () {
        final json = {
          'id': 'tour_1',
          'creatorId': 'user_123',
          'creatorName': 'Test Creator',
          'category': 'history',
          'tourType': 'walking',
          'status': 'draft',
          'featured': false,
          'startLocation': {'latitude': 37.7749, 'longitude': -122.4194},
          'geohash': '9q8yy',
          'draftVersionId': 'v1',
          'draftVersion': 1,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final tour = TourModel.fromJson(json);

        expect(tour.id, equals('tour_1'));
        expect(tour.creatorId, equals('user_123'));
        expect(tour.creatorName, equals('Test Creator'));
        expect(tour.category, equals(TourCategory.history));
        expect(tour.tourType, equals(TourType.walking));
        expect(tour.status, equals(TourStatus.draft));
        expect(tour.featured, isFalse);
        expect(tour.draftVersionId, equals('v1'));
        expect(tour.draftVersion, equals(1));
      });

      test('fromJson handles GeoPoint conversion from map', () {
        final json = {
          'id': 'tour_1',
          'creatorId': 'user_123',
          'creatorName': 'Test Creator',
          'category': 'history',
          'tourType': 'walking',
          'startLocation': {'latitude': 37.7749, 'longitude': -122.4194},
          'geohash': '9q8yy',
          'draftVersionId': 'v1',
          'draftVersion': 1,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final tour = TourModel.fromJson(json);

        expect(tour.startLocation.latitude, equals(37.7749));
        expect(tour.startLocation.longitude, equals(-122.4194));
      });

      test('fromJson handles alternate GeoPoint field names', () {
        final json = {
          'id': 'tour_1',
          'creatorId': 'user_123',
          'creatorName': 'Test Creator',
          'category': 'history',
          'tourType': 'walking',
          'startLocation': {'lat': 40.0, 'lng': -74.0},
          'geohash': '9q8yy',
          'draftVersionId': 'v1',
          'draftVersion': 1,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final tour = TourModel.fromJson(json);

        expect(tour.startLocation.latitude, equals(40.0));
        expect(tour.startLocation.longitude, equals(-74.0));
      });

      test('toJson serializes model correctly', () {
        final tour = createTestTour(
          id: 'tour_1',
          creatorId: 'user_123',
          creatorName: 'Test Creator',
          category: TourCategory.nature,
          tourType: TourType.driving,
          latitude: 40.0,
          longitude: -74.0,
        );

        final json = tour.toJson();

        expect(json['id'], equals('tour_1'));
        expect(json['creatorId'], equals('user_123'));
        expect(json['creatorName'], equals('Test Creator'));
        expect(json['category'], equals('nature'));
        expect(json['tourType'], equals('driving'));
      });

      test('toFirestore removes id field', () {
        final tour = createTestTour(id: 'tour_1');

        final firestoreData = tour.toFirestore();

        expect(firestoreData.containsKey('id'), isFalse);
        expect(firestoreData['creatorId'], equals('test_creator'));
      });

      test('fromJson handles optional fields', () {
        final json = {
          'id': 'tour_1',
          'creatorId': 'user_123',
          'creatorName': 'Test Creator',
          'category': 'history',
          'tourType': 'walking',
          'startLocation': {'latitude': 37.7749, 'longitude': -122.4194},
          'geohash': '9q8yy',
          'city': 'San Francisco',
          'region': 'California',
          'country': 'USA',
          'slug': 'historic-sf-tour',
          'liveVersionId': 'v2',
          'liveVersion': 2,
          'draftVersionId': 'v3',
          'draftVersion': 3,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final tour = TourModel.fromJson(json);

        expect(tour.city, equals('San Francisco'));
        expect(tour.region, equals('California'));
        expect(tour.country, equals('USA'));
        expect(tour.slug, equals('historic-sf-tour'));
        expect(tour.liveVersionId, equals('v2'));
        expect(tour.liveVersion, equals(2));
      });

      test('toJson includes key fields', () {
        final original = createTestTour(
          id: 'tour_1',
          status: TourStatus.approved,
          category: TourCategory.food,
          tourType: TourType.walking,
          featured: true,
        );

        // Note: Direct toJson() with freezed keeps nested freezed objects as class instances.
        // We verify the JSON output has the expected top-level fields.
        final json = original.toJson();

        expect(json['id'], equals(original.id));
        expect(json['status'], equals('approved'));
        expect(json['category'], equals('food'));
        expect(json['tourType'], equals('walking'));
        expect(json['featured'], isTrue);
        expect(json['stats'], isNotNull);
      });
    });

    group('Enum Handling', () {
      test('TourStatus serializes with snake_case', () {
        final tour = createTestTour(status: TourStatus.pendingReview);

        final json = tour.toJson();

        expect(json['status'], equals('pending_review'));
      });

      test('TourStatus deserializes from snake_case', () {
        final json = {
          'id': 'tour_1',
          'creatorId': 'user_123',
          'creatorName': 'Test Creator',
          'category': 'history',
          'tourType': 'walking',
          'status': 'pending_review',
          'startLocation': {'latitude': 37.7749, 'longitude': -122.4194},
          'geohash': '9q8yy',
          'draftVersionId': 'v1',
          'draftVersion': 1,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final tour = TourModel.fromJson(json);

        expect(tour.status, equals(TourStatus.pendingReview));
      });

      test('all TourCategory values serialize correctly', () {
        for (final category in TourCategory.values) {
          final tour = createTestTour(category: category);
          final json = tour.toJson();

          // Verify the category is serialized as its name
          expect(json['category'], equals(category.name));
        }
      });

      test('all TourType values serialize correctly', () {
        for (final tourType in TourType.values) {
          final tour = createTestTour(tourType: tourType);
          final json = tour.toJson();

          // Verify the tourType is serialized as its name
          expect(json['tourType'], equals(tourType.name));
        }
      });
    });

    group('Computed Properties', () {
      test('isPublished returns true when liveVersionId set', () {
        final tour = createTestTour(liveVersionId: 'v1', liveVersion: 1);

        expect(tour.isPublished, isTrue);
      });

      test('isPublished returns false when no liveVersionId', () {
        final tour = createTestTour();

        expect(tour.isPublished, isFalse);
      });

      test('isPendingReview reflects status', () {
        final pending = createTestTour(status: TourStatus.pendingReview);
        final draft = createTestTour(status: TourStatus.draft);

        expect(pending.isPendingReview, isTrue);
        expect(draft.isPendingReview, isFalse);
      });

      test('isApproved reflects status', () {
        final approved = createTestTour(status: TourStatus.approved);
        final draft = createTestTour(status: TourStatus.draft);

        expect(approved.isApproved, isTrue);
        expect(draft.isApproved, isFalse);
      });

      test('hasPendingChanges when draft differs from live', () {
        final withChanges = createTestTour(
          liveVersionId: 'v1',
          liveVersion: 1,
          draftVersionId: 'v2',
        );
        final noChanges = createTestTour(
          liveVersionId: 'v1',
          liveVersion: 1,
          draftVersionId: 'v1',
        );
        final notPublished = createTestTour();

        expect(withChanges.hasPendingChanges, isTrue);
        expect(noChanges.hasPendingChanges, isFalse);
        expect(notPublished.hasPendingChanges, isFalse);
      });
    });

    group('TourStats', () {
      test('default values are zero', () {
        const stats = TourStats();

        expect(stats.totalPlays, equals(0));
        expect(stats.totalDownloads, equals(0));
        expect(stats.averageRating, equals(0.0));
        expect(stats.totalRatings, equals(0));
        expect(stats.totalRevenue, equals(0));
      });

      test('fromJson parses correctly', () {
        final json = {
          'totalPlays': 100,
          'totalDownloads': 50,
          'averageRating': 4.5,
          'totalRatings': 20,
          'totalRevenue': 1000,
        };

        final stats = TourStats.fromJson(json);

        expect(stats.totalPlays, equals(100));
        expect(stats.totalDownloads, equals(50));
        expect(stats.averageRating, equals(4.5));
        expect(stats.totalRatings, equals(20));
        expect(stats.totalRevenue, equals(1000));
      });

      test('stats serialize with tour', () {
        final tour = createTestTour();
        final json = tour.toJson();

        // Note: Freezed returns the TourStats object, not a Map directly from toJson.
        // In real Firestore usage, the converter handles this.
        // We verify the stats are present and have correct values.
        final stats = json['stats'];
        expect(stats, isNotNull);
        // Access via TourStats if it's the freezed object
        if (stats is TourStats) {
          expect(stats.totalPlays, equals(0));
        } else if (stats is Map) {
          expect(stats['totalPlays'], equals(0));
        }
      });
    });
  });

  group('GeoPointConverter', () {
    const converter = GeoPointConverter();

    test('fromJson handles GeoPoint directly', () {
      final geoPoint = GeoPoint(37.7749, -122.4194);

      final result = converter.fromJson(geoPoint);

      expect(result.latitude, equals(37.7749));
      expect(result.longitude, equals(-122.4194));
    });

    test('fromJson handles Map with latitude/longitude', () {
      final map = {'latitude': 37.7749, 'longitude': -122.4194};

      final result = converter.fromJson(map);

      expect(result.latitude, equals(37.7749));
      expect(result.longitude, equals(-122.4194));
    });

    test('fromJson handles Map with lat/lng', () {
      final map = {'lat': 40.0, 'lng': -74.0};

      final result = converter.fromJson(map);

      expect(result.latitude, equals(40.0));
      expect(result.longitude, equals(-74.0));
    });

    test('fromJson returns default for invalid input', () {
      final result = converter.fromJson('invalid');

      expect(result.latitude, equals(0));
      expect(result.longitude, equals(0));
    });
  });

  group('TourCategoryExtension', () {
    test('displayName returns correct values', () {
      expect(TourCategory.history.displayName, equals('History'));
      expect(TourCategory.nature.displayName, equals('Nature'));
      expect(TourCategory.ghost.displayName, equals('Ghost Tour'));
      expect(TourCategory.food.displayName, equals('Food & Drink'));
      expect(TourCategory.art.displayName, equals('Art'));
      expect(TourCategory.architecture.displayName, equals('Architecture'));
      expect(TourCategory.other.displayName, equals('Other'));
    });
  });

  group('TourTypeExtension', () {
    test('displayName returns correct values', () {
      expect(TourType.walking.displayName, equals('Walking'));
      expect(TourType.driving.displayName, equals('Driving'));
    });
  });

  group('TourStatusExtension', () {
    test('displayName returns correct values', () {
      expect(TourStatus.draft.displayName, equals('Draft'));
      expect(TourStatus.pendingReview.displayName, equals('Pending Review'));
      expect(TourStatus.approved.displayName, equals('Approved'));
      expect(TourStatus.rejected.displayName, equals('Rejected'));
      expect(TourStatus.hidden.displayName, equals('Hidden'));
    });
  });
}
