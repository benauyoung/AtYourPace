import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:ayp_tour_guide/data/models/waypoint_model.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('WaypointModel', () {
    group('Serialization', () {
      test('fromJson creates model with required fields', () {
        final json = <String, dynamic>{
          'id': 'waypoint_1',
          'routeId': 'route_1',
          'order': 0,
          'location': <String, dynamic>{'lat': 48.8566, 'lng': 2.3522},
          'name': 'Eiffel Tower',
          'triggerRadius': 30,
          'type': 'stop',
          'manualPosition': false,
          'metadata': <String, dynamic>{},
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final waypoint = WaypointModel.fromJson(json);

        expect(waypoint.id, equals('waypoint_1'));
        expect(waypoint.routeId, equals('route_1'));
        expect(waypoint.order, equals(0));
        expect(waypoint.name, equals('Eiffel Tower'));
        expect(waypoint.triggerRadius, equals(30));
        expect(waypoint.type, equals(WaypointType.stop));
      });

      test('fromJson handles location correctly', () {
        final json = <String, dynamic>{
          'id': 'waypoint_1',
          'routeId': 'route_1',
          'order': 0,
          'location': <String, dynamic>{'lat': 48.8566, 'lng': 2.3522},
          'name': 'Test',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final waypoint = WaypointModel.fromJson(json);

        expect(waypoint.location.latitude, equals(48.8566));
        expect(waypoint.location.longitude, equals(2.3522));
      });

      test('toJson serializes correctly', () {
        final waypoint = createTestWaypoint(
          id: 'waypoint_1',
          routeId: 'route_1',
          order: 0,
          name: 'Test Waypoint',
          latitude: 48.8566,
          longitude: 2.3522,
        );

        final json = waypoint.toJson();

        expect(json['id'], equals('waypoint_1'));
        expect(json['routeId'], equals('route_1'));
        expect(json['order'], equals(0));
        expect(json['location']['lat'], equals(48.8566));
        expect(json['location']['lng'], equals(2.3522));
      });

      test('toFirestore removes id field', () {
        final waypoint = createTestWaypoint(id: 'waypoint_1');

        final firestoreData = waypoint.toFirestore();

        expect(firestoreData.containsKey('id'), isFalse);
        expect(firestoreData['routeId'], equals('route_1'));
      });
    });

    group('Computed Properties', () {
      test('isStop returns true for stop type', () {
        final waypoint = createTestWaypoint(type: WaypointType.stop);
        expect(waypoint.isStop, isTrue);
        expect(waypoint.isWaypoint, isFalse);
        expect(waypoint.isPoi, isFalse);
      });

      test('isWaypoint returns true for waypoint type', () {
        final waypoint = createTestWaypoint(type: WaypointType.waypoint);
        expect(waypoint.isWaypoint, isTrue);
        expect(waypoint.isStop, isFalse);
      });

      test('isPoi returns true for poi type', () {
        final waypoint = createTestWaypoint(type: WaypointType.poi);
        expect(waypoint.isPoi, isTrue);
      });

      test('hasLinkedStop returns true when stopId is set', () {
        final waypoint = createTestWaypoint(stopId: 'stop_1');
        expect(waypoint.hasLinkedStop, isTrue);
      });

      test('hasLinkedStop returns false when stopId is null', () {
        final waypoint = createTestWaypoint();
        expect(waypoint.hasLinkedStop, isFalse);
      });

      test('latitude and longitude getters work', () {
        final waypoint = createTestWaypoint(latitude: 48.8566, longitude: 2.3522);
        expect(waypoint.latitude, equals(48.8566));
        expect(waypoint.longitude, equals(2.3522));
      });

      test('radiusColor returns green for small radius', () {
        final waypoint = createTestWaypoint(triggerRadius: 30);
        expect(waypoint.radiusColor, equals('green'));
      });

      test('radiusColor returns yellow for medium radius', () {
        final waypoint = createTestWaypoint(triggerRadius: 75);
        expect(waypoint.radiusColor, equals('yellow'));
      });

      test('radiusColor returns orange for large radius', () {
        final waypoint = createTestWaypoint(triggerRadius: 150);
        expect(waypoint.radiusColor, equals('orange'));
      });

      test('radiusColor returns red for very large radius', () {
        final waypoint = createTestWaypoint(triggerRadius: 250);
        expect(waypoint.radiusColor, equals('red'));
      });

      test('radiusColorHex returns correct colors', () {
        expect(createTestWaypoint(triggerRadius: 30).radiusColorHex, equals(0xFF4CAF50));
        expect(createTestWaypoint(triggerRadius: 75).radiusColorHex, equals(0xFFFFEB3B));
        expect(createTestWaypoint(triggerRadius: 150).radiusColorHex, equals(0xFFFF9800));
        expect(createTestWaypoint(triggerRadius: 250).radiusColorHex, equals(0xFFF44336));
      });
    });

    group('Distance Calculations', () {
      test('hasOverlapWith detects overlapping waypoints', () {
        final waypoint1 = createTestWaypoint(
          latitude: 48.8566,
          longitude: 2.3522,
          triggerRadius: 50,
        );
        final waypoint2 = createTestWaypoint(
          latitude: 48.8567,
          longitude: 2.3523,
          triggerRadius: 50,
        );

        expect(waypoint1.hasOverlapWith(waypoint2), isTrue);
      });

      test('hasOverlapWith returns false for distant waypoints', () {
        final waypoint1 = createTestWaypoint(
          latitude: 48.8566,
          longitude: 2.3522,
          triggerRadius: 30,
        );
        final waypoint2 = createTestWaypoint(
          latitude: 48.8600,
          longitude: 2.3600,
          triggerRadius: 30,
        );

        expect(waypoint1.hasOverlapWith(waypoint2), isFalse);
      });

      test('isTooCloseTo detects close waypoints', () {
        final waypoint1 = createTestWaypoint(
          latitude: 48.8566,
          longitude: 2.3522,
        );
        final waypoint2 = createTestWaypoint(
          latitude: 48.85665,
          longitude: 2.35225,
        );

        expect(waypoint1.isTooCloseTo(waypoint2, minDistance: 20), isTrue);
      });

      test('distanceTo calculates distance in meters', () {
        final waypoint1 = createTestWaypoint(
          latitude: 48.8566,
          longitude: 2.3522,
        );
        final waypoint2 = createTestWaypoint(
          latitude: 48.8576,
          longitude: 2.3532,
        );

        final distance = waypoint1.distanceTo(waypoint2);
        expect(distance, greaterThan(0));
        expect(distance, lessThan(200));
      });

      test('distanceToLocation calculates distance to LatLng', () {
        final waypoint = createTestWaypoint(
          latitude: 48.8566,
          longitude: 2.3522,
        );

        final distance = waypoint.distanceToLocation(LatLng(48.8576, 2.3532));
        expect(distance, greaterThan(0));
      });
    });

    group('Enum Handling', () {
      test('all WaypointType values serialize correctly', () {
        for (final type in WaypointType.values) {
          final waypoint = createTestWaypoint(type: type);
          final json = waypoint.toJson();
          final restored = WaypointModel.fromJson(json);
          expect(restored.type, equals(type));
        }
      });
    });
  });

  group('LatLngConverter', () {
    const converter = LatLngConverter();

    test('fromJson creates LatLng from map', () {
      final map = {'lat': 48.8566, 'lng': 2.3522};

      final result = converter.fromJson(map);

      expect(result.latitude, equals(48.8566));
      expect(result.longitude, equals(2.3522));
    });

    test('toJson serializes LatLng to map', () {
      final latLng = LatLng(48.8566, 2.3522);

      final result = converter.toJson(latLng);

      expect(result['lat'], equals(48.8566));
      expect(result['lng'], equals(2.3522));
    });
  });

  group('NullableLatLngConverter', () {
    const converter = NullableLatLngConverter();

    test('fromJson returns null for null input', () {
      final result = converter.fromJson(null);
      expect(result, isNull);
    });

    test('fromJson creates LatLng from map', () {
      final map = {'lat': 48.8566, 'lng': 2.3522};
      final result = converter.fromJson(map);

      expect(result, isNotNull);
      expect(result!.latitude, equals(48.8566));
    });

    test('toJson returns null for null input', () {
      final result = converter.toJson(null);
      expect(result, isNull);
    });
  });

  group('WaypointTypeExtension', () {
    test('displayName returns correct values', () {
      expect(WaypointType.stop.displayName, equals('Stop'));
      expect(WaypointType.waypoint.displayName, equals('Waypoint'));
      expect(WaypointType.poi.displayName, equals('Point of Interest'));
    });

    test('description returns correct values', () {
      expect(WaypointType.stop.description, contains('audio'));
      expect(WaypointType.waypoint.description, contains('navigation'));
      expect(WaypointType.poi.description, contains('interest'));
    });
  });
}
