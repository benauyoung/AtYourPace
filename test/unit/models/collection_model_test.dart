import 'package:flutter_test/flutter_test.dart';

import 'package:ayp_tour_guide/data/models/collection_model.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('CollectionModel', () {
    group('Serialization', () {
      test('fromJson creates model with required fields', () {
        final json = {
          'id': 'collection_1',
          'name': 'Iconic Paris',
          'description': 'Must-see landmarks',
          'tourIds': ['tour_1', 'tour_2'],
          'isCurated': true,
          'isFeatured': false,
          'tags': ['landmarks', 'famous'],
          'type': 'geographic',
          'sortOrder': 1,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final collection = CollectionModel.fromJson(json);

        expect(collection.id, equals('collection_1'));
        expect(collection.name, equals('Iconic Paris'));
        expect(collection.description, equals('Must-see landmarks'));
        expect(collection.tourIds.length, equals(2));
        expect(collection.isCurated, isTrue);
        expect(collection.type, equals(CollectionType.geographic));
      });

      test('fromJson handles optional location fields', () {
        final json = {
          'id': 'collection_1',
          'name': 'Paris Collection',
          'description': 'Tours in Paris',
          'tourIds': [],
          'isCurated': true,
          'isFeatured': true,
          'tags': [],
          'type': 'geographic',
          'sortOrder': 1,
          'city': 'Paris',
          'region': 'Ile-de-France',
          'country': 'France',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final collection = CollectionModel.fromJson(json);

        expect(collection.city, equals('Paris'));
        expect(collection.region, equals('Ile-de-France'));
        expect(collection.country, equals('France'));
      });

      test('fromJson handles curator fields', () {
        final json = {
          'id': 'collection_1',
          'name': 'Curated Collection',
          'description': 'Curated by admin',
          'tourIds': [],
          'isCurated': true,
          'curatorId': 'admin_1',
          'curatorName': 'Admin User',
          'isFeatured': false,
          'tags': [],
          'type': 'custom',
          'sortOrder': 0,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final collection = CollectionModel.fromJson(json);

        expect(collection.curatorId, equals('admin_1'));
        expect(collection.curatorName, equals('Admin User'));
      });

      test('toJson serializes correctly', () {
        final collection = createTestCollection(
          id: 'collection_1',
          name: 'Test Collection',
          type: CollectionType.thematic,
        );

        final json = collection.toJson();

        expect(json['id'], equals('collection_1'));
        expect(json['name'], equals('Test Collection'));
        expect(json['type'], equals('thematic'));
      });

      test('toFirestore removes id field', () {
        final collection = createTestCollection(id: 'collection_1');

        final firestoreData = collection.toFirestore();

        expect(firestoreData.containsKey('id'), isFalse);
        expect(firestoreData['name'], equals('Test Collection'));
      });
    });

    group('Computed Properties', () {
      test('tourCount returns number of tours', () {
        final collection = createTestCollection(tourIds: ['tour_1', 'tour_2', 'tour_3']);
        expect(collection.tourCount, equals(3));
      });

      test('hasTours returns true when tourIds not empty', () {
        final withTours = createTestCollection(tourIds: ['tour_1']);
        final withoutTours = createTestCollection(tourIds: []);

        expect(withTours.hasTours, isTrue);
        expect(withoutTours.hasTours, isFalse);
      });

      test('isEmpty returns true when no tours', () {
        final empty = createTestCollection(tourIds: []);
        final notEmpty = createTestCollection(tourIds: ['tour_1']);

        expect(empty.isEmpty, isTrue);
        expect(notEmpty.isEmpty, isFalse);
      });

      test('hasCoverImage returns true when coverImageUrl set', () {
        final withCover = createTestCollection(coverImageUrl: 'https://example.com/image.jpg');
        final withoutCover = createTestCollection();

        expect(withCover.hasCoverImage, isTrue);
        expect(withoutCover.hasCoverImage, isFalse);
      });

      test('hasCoverImage returns false for empty string', () {
        final collection = createTestCollection(coverImageUrl: '');
        expect(collection.hasCoverImage, isFalse);
      });

      test('containsTour returns true if tour in collection', () {
        final collection = createTestCollection(tourIds: ['tour_1', 'tour_2']);

        expect(collection.containsTour('tour_1'), isTrue);
        expect(collection.containsTour('tour_3'), isFalse);
      });

      test('locationDisplay returns city first', () {
        final collection = createTestCollection(city: 'Paris', country: 'France');
        expect(collection.locationDisplay, equals('Paris'));
      });

      test('locationDisplay returns region if no city', () {
        final collection = CollectionModel(
          id: 'collection_1',
          name: 'Test',
          description: 'Test',
          tourIds: const [],
          region: 'Provence',
          country: 'France',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(collection.locationDisplay, equals('Provence'));
      });

      test('locationDisplay returns country if no city or region', () {
        final collection = CollectionModel(
          id: 'collection_1',
          name: 'Test',
          description: 'Test',
          tourIds: const [],
          country: 'France',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(collection.locationDisplay, equals('France'));
      });

      test('typeDisplay returns correct values', () {
        expect(createTestCollection(type: CollectionType.geographic).typeDisplay, equals('Geographic'));
        expect(createTestCollection(type: CollectionType.thematic).typeDisplay, equals('Thematic'));
        expect(createTestCollection(type: CollectionType.seasonal).typeDisplay, equals('Seasonal'));
        expect(createTestCollection(type: CollectionType.custom).typeDisplay, equals('Custom'));
      });

      test('typeIcon returns correct icons', () {
        expect(createTestCollection(type: CollectionType.geographic).typeIcon, equals('location_on'));
        expect(createTestCollection(type: CollectionType.thematic).typeIcon, equals('category'));
        expect(createTestCollection(type: CollectionType.seasonal).typeIcon, equals('event'));
        expect(createTestCollection(type: CollectionType.custom).typeIcon, equals('folder'));
      });
    });

    group('Enum Handling', () {
      test('all CollectionType values serialize correctly', () {
        for (final type in CollectionType.values) {
          final collection = createTestCollection(type: type);
          final json = collection.toJson();
          final restored = CollectionModel.fromJson(json);
          expect(restored.type, equals(type));
        }
      });
    });
  });

  group('ParisCollections', () {
    test('predefined contains 10 collections', () {
      expect(ParisCollections.predefined.length, equals(10));
    });

    test('predefined collections have required fields', () {
      for (final data in ParisCollections.predefined) {
        expect(data['name'], isNotNull);
        expect(data['description'], isNotNull);
        expect(data['type'], isNotNull);
        expect(data['tags'], isNotNull);
        expect(data['sortOrder'], isNotNull);
      }
    });

    test('createFromPredefined creates valid CollectionModel', () {
      final data = ParisCollections.predefined.first;
      final collection = ParisCollections.createFromPredefined(
        data,
        id: 'test_id',
        curatorId: 'admin_1',
        curatorName: 'Admin User',
      );

      expect(collection.id, equals('test_id'));
      expect(collection.name, equals(data['name']));
      expect(collection.description, equals(data['description']));
      expect(collection.curatorId, equals('admin_1'));
      expect(collection.curatorName, equals('Admin User'));
      expect(collection.isCurated, isTrue);
      expect(collection.isFeatured, isTrue);
      expect(collection.tourIds, isEmpty);
    });

    test('createFromPredefined handles all types', () {
      final geographic = ParisCollections.predefined.firstWhere((d) => d['type'] == 'geographic');
      final thematic = ParisCollections.predefined.firstWhere((d) => d['type'] == 'thematic');
      final seasonal = ParisCollections.predefined.firstWhere((d) => d['type'] == 'seasonal');

      expect(
        ParisCollections.createFromPredefined(geographic, id: '1', curatorId: 'a', curatorName: 'A').type,
        equals(CollectionType.geographic),
      );
      expect(
        ParisCollections.createFromPredefined(thematic, id: '2', curatorId: 'a', curatorName: 'A').type,
        equals(CollectionType.thematic),
      );
      expect(
        ParisCollections.createFromPredefined(seasonal, id: '3', curatorId: 'a', curatorName: 'A').type,
        equals(CollectionType.seasonal),
      );
    });
  });

  group('CollectionTypeExtension', () {
    test('displayName returns correct values', () {
      expect(CollectionType.geographic.displayName, equals('Geographic'));
      expect(CollectionType.thematic.displayName, equals('Thematic'));
      expect(CollectionType.seasonal.displayName, equals('Seasonal'));
      expect(CollectionType.custom.displayName, equals('Custom'));
    });

    test('description returns correct values', () {
      expect(CollectionType.geographic.description, contains('location'));
      expect(CollectionType.thematic.description, contains('theme'));
      expect(CollectionType.seasonal.description, contains('season'));
      expect(CollectionType.custom.description, contains('Custom'));
    });
  });
}
