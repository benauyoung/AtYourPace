import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:ayp_tour_guide/data/models/route_model.dart';
import 'package:ayp_tour_guide/data/models/waypoint_model.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('RouteModel', () {
    group('Serialization', () {
      test('fromJson creates model with required fields', () {
        final json = <String, dynamic>{
          'id': 'route_1',
          'tourId': 'tour_1',
          'versionId': 'v1',
          'waypoints': <Map<String, dynamic>>[],
          'routePolyline': <Map<String, dynamic>>[],
          'snapMode': 'roads',
          'totalDistance': 2500.0,
          'estimatedDuration': 3600,
          'metadata': <String, dynamic>{},
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final route = RouteModel.fromJson(json);

        expect(route.id, equals('route_1'));
        expect(route.tourId, equals('tour_1'));
        expect(route.versionId, equals('v1'));
        expect(route.snapMode, equals(RouteSnapMode.roads));
        expect(route.totalDistance, equals(2500.0));
        expect(route.estimatedDuration, equals(3600));
      });

      test('toJson serializes correctly', () {
        final route = createTestRoute(
          id: 'route_1',
          tourId: 'tour_1',
          versionId: 'v1',
          totalDistance: 2500,
          estimatedDuration: 3600,
          waypoints: [],
        );

        final json = route.toJson();

        expect(json['id'], equals('route_1'));
        expect(json['tourId'], equals('tour_1'));
        expect(json['totalDistance'], equals(2500));
        expect(json['estimatedDuration'], equals(3600));
      });

      test('toFirestore removes id field', () {
        final route = createTestRoute(id: 'route_1');

        final firestoreData = route.toFirestore();

        expect(firestoreData.containsKey('id'), isFalse);
        expect(firestoreData['tourId'], equals('test_tour_1'));
      });
    });

    group('Computed Properties', () {
      test('waypointCount returns correct count', () {
        final route = createTestRoute(waypoints: createTestWaypoints(count: 5));
        expect(route.waypointCount, equals(5));
      });

      test('stopCount returns count of stop-type waypoints', () {
        final waypoints = [
          createTestWaypoint(order: 0, type: WaypointType.stop),
          createTestWaypoint(order: 1, type: WaypointType.waypoint),
          createTestWaypoint(order: 2, type: WaypointType.stop),
          createTestWaypoint(order: 3, type: WaypointType.poi),
        ];
        final route = createTestRoute(waypoints: waypoints);
        expect(route.stopCount, equals(2));
      });

      test('hasWaypoints returns true when waypoints exist', () {
        final route = createTestRoute(waypoints: createTestWaypoints(count: 3));
        expect(route.hasWaypoints, isTrue);
      });

      test('hasWaypoints returns false when empty', () {
        final route = createTestRoute(waypoints: []);
        expect(route.hasWaypoints, isFalse);
      });

      test('hasPolyline returns true when polyline exists', () {
        final route = createTestRoute(
          routePolyline: [LatLng(48.8566, 2.3522), LatLng(48.8576, 2.3532)],
        );
        expect(route.hasPolyline, isTrue);
      });

      test('hasPolyline returns false when empty', () {
        final route = createTestRoute(routePolyline: []);
        expect(route.hasPolyline, isFalse);
      });

      test('startPoint returns first waypoint location', () {
        final waypoints = createTestWaypoints(count: 3, startLat: 48.8566, startLng: 2.3522);
        final route = createTestRoute(waypoints: waypoints);

        expect(route.startPoint, isNotNull);
        expect(route.startPoint!.latitude, equals(48.8566));
      });

      test('startPoint returns null when no waypoints', () {
        final route = createTestRoute(waypoints: []);
        expect(route.startPoint, isNull);
      });

      test('endPoint returns last waypoint location', () {
        final waypoints = createTestWaypoints(count: 3, startLat: 48.8566, startLng: 2.3522);
        final route = createTestRoute(waypoints: waypoints);

        expect(route.endPoint, isNotNull);
        expect(route.endPoint!.latitude, greaterThan(48.8566));
      });

      test('distanceFormatted returns meters for short distances', () {
        final route = createTestRoute(totalDistance: 500);
        expect(route.distanceFormatted, equals('500m'));
      });

      test('distanceFormatted returns km for long distances', () {
        final route = createTestRoute(totalDistance: 2500);
        expect(route.distanceFormatted, equals('2.5km'));
      });

      test('durationFormatted returns minutes for short duration', () {
        final route = createTestRoute(estimatedDuration: 1800);
        expect(route.durationFormatted, equals('30min'));
      });

      test('durationFormatted returns hours and minutes for long duration', () {
        final route = createTestRoute(estimatedDuration: 5400);
        expect(route.durationFormatted, equals('1h 30min'));
      });

      test('durationShort returns short format', () {
        final route = createTestRoute(estimatedDuration: 5400);
        expect(route.durationShort, equals('1h 30m'));
      });

      test('isSnappingEnabled returns true for roads mode', () {
        final route = createTestRoute(snapMode: RouteSnapMode.roads);
        expect(route.isSnappingEnabled, isTrue);
      });

      test('isSnappingEnabled returns true for walking mode', () {
        final route = createTestRoute(snapMode: RouteSnapMode.walking);
        expect(route.isSnappingEnabled, isTrue);
      });

      test('isSnappingEnabled returns false for none mode', () {
        final route = createTestRoute(snapMode: RouteSnapMode.none);
        expect(route.isSnappingEnabled, isFalse);
      });

      test('centerPoint calculates center of waypoints', () {
        final waypoints = [
          createTestWaypoint(order: 0, latitude: 48.8500, longitude: 2.3500),
          createTestWaypoint(order: 1, latitude: 48.8600, longitude: 2.3600),
        ];
        final route = createTestRoute(waypoints: waypoints);

        expect(route.centerPoint, isNotNull);
        expect(route.centerPoint!.latitude, closeTo(48.855, 0.001));
        expect(route.centerPoint!.longitude, closeTo(2.355, 0.001));
      });

      test('centerPoint returns null when no waypoints', () {
        final route = createTestRoute(waypoints: []);
        expect(route.centerPoint, isNull);
      });
    });

    group('Overlap Detection', () {
      test('overlappingWaypoints detects overlapping waypoints', () {
        final waypoints = [
          createTestWaypoint(order: 0, latitude: 48.8566, longitude: 2.3522, triggerRadius: 50),
          createTestWaypoint(order: 1, latitude: 48.8567, longitude: 2.3523, triggerRadius: 50),
        ];
        final route = createTestRoute(waypoints: waypoints);

        expect(route.overlappingWaypoints, isNotEmpty);
      });

      test('hasOverlappingWaypoints returns true when overlaps exist', () {
        final waypoints = [
          createTestWaypoint(order: 0, latitude: 48.8566, longitude: 2.3522, triggerRadius: 50),
          createTestWaypoint(order: 1, latitude: 48.8567, longitude: 2.3523, triggerRadius: 50),
        ];
        final route = createTestRoute(waypoints: waypoints);

        expect(route.hasOverlappingWaypoints, isTrue);
      });

      test('hasOverlappingWaypoints returns false when no overlaps', () {
        final waypoints = [
          createTestWaypoint(order: 0, latitude: 48.8566, longitude: 2.3522, triggerRadius: 30),
          createTestWaypoint(order: 1, latitude: 48.8600, longitude: 2.3600, triggerRadius: 30),
        ];
        final route = createTestRoute(waypoints: waypoints);

        expect(route.hasOverlappingWaypoints, isFalse);
      });
    });

    group('Enum Handling', () {
      test('all RouteSnapMode values serialize correctly', () {
        for (final mode in RouteSnapMode.values) {
          final route = createTestRoute(snapMode: mode, waypoints: []);
          final json = route.toJson();
          final restored = RouteModel.fromJson(json);
          expect(restored.snapMode, equals(mode));
        }
      });
    });
  });

  group('LatLngListConverter', () {
    const converter = LatLngListConverter();

    test('fromJson creates list of LatLng from JSON', () {
      final json = <dynamic>[
        <String, dynamic>{'lat': 48.8566, 'lng': 2.3522},
        <String, dynamic>{'lat': 48.8576, 'lng': 2.3532},
      ];

      final result = converter.fromJson(json);

      expect(result.length, equals(2));
      expect(result[0].latitude, equals(48.8566));
      expect(result[1].latitude, equals(48.8576));
    });

    test('toJson serializes list of LatLng to JSON', () {
      final latLngs = [
        LatLng(48.8566, 2.3522),
        LatLng(48.8576, 2.3532),
      ];

      final result = converter.toJson(latLngs);

      expect(result.length, equals(2));
      expect((result[0] as Map)['lat'], equals(48.8566));
      expect((result[1] as Map)['lat'], equals(48.8576));
    });
  });

  group('RouteSnapModeExtension', () {
    test('displayName returns correct values', () {
      expect(RouteSnapMode.none.displayName, equals('No Snapping'));
      expect(RouteSnapMode.roads.displayName, equals('Snap to Roads'));
      expect(RouteSnapMode.walking.displayName, equals('Walking Path'));
      expect(RouteSnapMode.manual.displayName, equals('Manual'));
    });

    test('description returns correct values', () {
      expect(RouteSnapMode.none.description, contains('Direct'));
      expect(RouteSnapMode.roads.description, contains('drivable'));
      expect(RouteSnapMode.walking.description, contains('walking'));
      expect(RouteSnapMode.manual.description, contains('Manually'));
    });
  });
}
