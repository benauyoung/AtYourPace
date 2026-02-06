
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:ayp_tour_guide/services/location_service.dart';
import '../../helpers/mock_services.dart';

void main() {
  group('LocationService', () {
    late FakeLocationService locationService;

    setUp(() {
      locationService = FakeLocationService();
    });

    tearDown(() {
      locationService.dispose();
    });

    group('Permission Handling', () {
      test('checkPermission returns current permission status', () async {
        locationService.setPermission(LocationPermission.whileInUse);

        final permission = await locationService.checkPermission();

        expect(permission, equals(LocationPermission.whileInUse));
      });

      test('checkPermission returns denied when permission is denied', () async {
        locationService.setPermission(LocationPermission.denied);

        final permission = await locationService.checkPermission();

        expect(permission, equals(LocationPermission.denied));
      });

      test('requestPermission grants permission when denied', () async {
        locationService.setPermission(LocationPermission.denied);

        final permission = await locationService.requestPermission();

        expect(permission, equals(LocationPermission.whileInUse));
      });

      test('requestPermission returns existing permission when already granted', () async {
        locationService.setPermission(LocationPermission.always);

        final permission = await locationService.requestPermission();

        expect(permission, equals(LocationPermission.always));
      });

      test('requestPermission does not change deniedForever status', () async {
        locationService.setPermission(LocationPermission.deniedForever);

        final permission = await locationService.requestPermission();

        expect(permission, equals(LocationPermission.deniedForever));
      });
    });

    group('Position Tracking', () {
      test('getCurrentPosition returns position when service enabled', () async {
        locationService.setServiceEnabled(true);
        locationService.setPermission(LocationPermission.whileInUse);
        final testPosition = createTestPosition(latitude: 40.0, longitude: -74.0);
        locationService.setCurrentPosition(testPosition);

        final position = await locationService.getCurrentPosition();

        expect(position, isNotNull);
        expect(position!.latitude, equals(40.0));
        expect(position.longitude, equals(-74.0));
      });

      test('getCurrentPosition returns null when service disabled', () async {
        locationService.setServiceEnabled(false);

        final position = await locationService.getCurrentPosition();

        expect(position, isNull);
      });

      test('getCurrentPosition returns null when permission denied', () async {
        locationService.setServiceEnabled(true);
        locationService.setPermission(LocationPermission.denied);

        final position = await locationService.getCurrentPosition();

        expect(position, isNull);
      });

      test('getCurrentPosition returns null when permission deniedForever', () async {
        locationService.setServiceEnabled(true);
        locationService.setPermission(LocationPermission.deniedForever);

        final position = await locationService.getCurrentPosition();

        expect(position, isNull);
      });

      test('getCurrentPosition uses default position when none set', () async {
        locationService.setServiceEnabled(true);
        locationService.setPermission(LocationPermission.whileInUse);

        final position = await locationService.getCurrentPosition();

        expect(position, isNotNull);
        expect(position!.latitude, equals(37.7749)); // Default
      });
    });

    group('Position Stream', () {
      test('positionStream emits position updates', () async {
        final positions = <Position>[];
        final subscription = locationService.positionStream.listen(positions.add);

        locationService.emitPosition(createTestPosition(latitude: 40.0));
        locationService.emitPosition(createTestPosition(latitude: 41.0));
        locationService.emitPosition(createTestPosition(latitude: 42.0));

        await Future.delayed(const Duration(milliseconds: 50));

        expect(positions.length, equals(3));
        expect(positions[0].latitude, equals(40.0));
        expect(positions[1].latitude, equals(41.0));
        expect(positions[2].latitude, equals(42.0));

        await subscription.cancel();
      });

      test('startTracking returns true when successful', () async {
        locationService.setServiceEnabled(true);
        locationService.setPermission(LocationPermission.whileInUse);

        final started = await locationService.startTracking();

        expect(started, isTrue);
        expect(locationService.isTracking, isTrue);
      });

      test('startTracking returns false when service disabled', () async {
        locationService.setServiceEnabled(false);

        final started = await locationService.startTracking();

        expect(started, isFalse);
        expect(locationService.isTracking, isFalse);
      });

      test('startTracking returns false when permission denied', () async {
        locationService.setServiceEnabled(true);
        locationService.setPermission(LocationPermission.denied);

        // Request permission will fail since it's deniedForever
        locationService.setPermission(LocationPermission.deniedForever);
        final started = await locationService.startTracking();

        expect(started, isFalse);
      });

      test('stopTracking stops tracking', () async {
        await locationService.startTracking();
        expect(locationService.isTracking, isTrue);

        locationService.stopTracking();

        expect(locationService.isTracking, isFalse);
      });

      test('setCurrentPosition emits to stream when tracking', () async {
        final positions = <Position>[];
        final subscription = locationService.positionStream.listen(positions.add);

        await locationService.startTracking();
        locationService.setCurrentPosition(createTestPosition(latitude: 50.0));

        await Future.delayed(const Duration(milliseconds: 50));

        expect(positions.length, equals(1));
        expect(positions[0].latitude, equals(50.0));

        await subscription.cancel();
      });
    });

    group('Distance Calculations', () {
      test('distanceBetween calculates distance correctly', () {
        // San Francisco to Oakland (approximately 12-13 km)
        final distance = locationService.distanceBetween(
          37.7749, -122.4194, // SF
          37.8044, -122.2712, // Oakland
        );

        expect(distance, greaterThan(10000)); // > 10km
        expect(distance, lessThan(15000)); // < 15km
      });

      test('distanceBetween returns 0 for same location', () {
        final distance = locationService.distanceBetween(
          37.7749, -122.4194,
          37.7749, -122.4194,
        );

        expect(distance, equals(0));
      });

      test('distanceBetween handles short distances', () {
        // ~100 meters apart
        final distance = locationService.distanceBetween(
          37.7749, -122.4194,
          37.7758, -122.4194,
        );

        expect(distance, greaterThan(90));
        expect(distance, lessThan(110));
      });
    });

    group('Bearing Calculations', () {
      test('bearingBetween calculates bearing correctly', () {
        // Point directly north
        final bearing = locationService.bearingBetween(
          37.7749, -122.4194,
          37.8749, -122.4194,
        );

        // Should be close to 0 (north)
        expect(bearing, closeTo(0, 5));
      });

      test('bearingBetween calculates east bearing', () {
        final bearing = locationService.bearingBetween(
          37.7749, -122.4194,
          37.7749, -122.3194,
        );

        // Should be close to 90 (east)
        expect(bearing, closeTo(90, 5));
      });

      test('bearingBetween calculates south bearing', () {
        final bearing = locationService.bearingBetween(
          37.7749, -122.4194,
          37.6749, -122.4194,
        );

        // Should be close to 180 (south)
        expect(bearing, closeTo(180, 5));
      });

      test('bearingBetween calculates west bearing', () {
        final bearing = locationService.bearingBetween(
          37.7749, -122.4194,
          37.7749, -122.5194,
        );

        // Should be close to -90 or 270 (west)
        expect(bearing.abs(), closeTo(90, 5));
      });
    });

    group('Service Status', () {
      test('isLocationServiceEnabled returns service status', () async {
        locationService.setServiceEnabled(true);

        expect(await locationService.isLocationServiceEnabled(), isTrue);

        locationService.setServiceEnabled(false);

        expect(await locationService.isLocationServiceEnabled(), isFalse);
      });

      test('openLocationSettings returns true', () async {
        final result = await locationService.openLocationSettings();

        expect(result, isTrue);
      });

      test('openAppSettings returns true', () async {
        final result = await locationService.openAppSettings();

        expect(result, isTrue);
      });
    });
  });

  group('Position Extensions', () {
    test('toLatLng converts position to map', () {
      final position = createTestPosition(latitude: 40.0, longitude: -74.0);

      final map = position.toLatLng();

      expect(map['latitude'], equals(40.0));
      expect(map['longitude'], equals(-74.0));
    });

    test('isWithinRadius returns true when inside radius', () {
      final position = createTestPosition(latitude: 37.7749, longitude: -122.4194);

      // Same location
      final result = position.isWithinRadius(37.7749, -122.4194, 50);

      expect(result, isTrue);
    });

    test('isWithinRadius returns true at edge of radius', () {
      final position = createTestPosition(latitude: 37.7749, longitude: -122.4194);

      // ~10 meters away
      final result = position.isWithinRadius(37.77499, -122.41941, 50);

      expect(result, isTrue);
    });

    test('isWithinRadius returns false when outside radius', () {
      final position = createTestPosition(latitude: 37.7749, longitude: -122.4194);

      // ~1km away
      final result = position.isWithinRadius(37.7849, -122.4194, 50);

      expect(result, isFalse);
    });
  });

  group('createTestPosition Helper', () {
    test('creates position with default values', () {
      final position = createTestPosition();

      expect(position.latitude, equals(37.7749));
      expect(position.longitude, equals(-122.4194));
      expect(position.accuracy, equals(10.0));
    });

    test('creates position with custom values', () {
      final position = createTestPosition(
        latitude: 40.0,
        longitude: -74.0,
        accuracy: 5.0,
        altitude: 100.0,
        heading: 90.0,
        speed: 5.0,
      );

      expect(position.latitude, equals(40.0));
      expect(position.longitude, equals(-74.0));
      expect(position.accuracy, equals(5.0));
      expect(position.altitude, equals(100.0));
      expect(position.heading, equals(90.0));
      expect(position.speed, equals(5.0));
    });

    test('creates position with custom timestamp', () {
      final timestamp = DateTime(2025, 1, 1, 12, 0, 0);
      final position = createTestPosition(timestamp: timestamp);

      expect(position.timestamp, equals(timestamp));
    });
  });
}
