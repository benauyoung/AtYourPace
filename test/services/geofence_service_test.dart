import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/mockito.dart';

import 'package:ayp_tour_guide/services/geofence_service.dart';

import '../helpers/test_helpers.mocks.dart';

void main() {
  late GeofenceService geofenceService;
  late MockLocationService mockLocationService;
  late StreamController<Position> positionController;

  setUp(() {
    mockLocationService = MockLocationService();
    positionController = StreamController<Position>.broadcast();

    // Setup mock location service to return position stream
    when(mockLocationService.positionStream).thenAnswer(
      (_) => positionController.stream,
    );
    when(mockLocationService.startTracking(distanceFilter: anyNamed('distanceFilter')))
        .thenAnswer((_) async => true);

    geofenceService = GeofenceService(mockLocationService);
  });

  tearDown(() {
    geofenceService.stopMonitoring();
    positionController.close();
  });

  group('Geofence Management', () {
    test('adds geofence correctly', () {
      final geofence = Geofence(
        id: 'test_1',
        name: 'Test Geofence',
        latitude: 37.7749,
        longitude: -122.4194,
        radiusMeters: 50.0,
      );

      geofenceService.addGeofence(geofence);

      expect(geofenceService.geofences, contains(geofence));
      expect(geofenceService.geofences.length, equals(1));
    });

    test('adds multiple geofences correctly', () {
      final geofences = [
        Geofence(
          id: 'test_1',
          name: 'Test 1',
          latitude: 37.7749,
          longitude: -122.4194,
          radiusMeters: 50.0,
        ),
        Geofence(
          id: 'test_2',
          name: 'Test 2',
          latitude: 37.7750,
          longitude: -122.4195,
          radiusMeters: 50.0,
        ),
      ];

      geofenceService.addGeofences(geofences);

      expect(geofenceService.geofences.length, equals(2));
    });

    test('removes geofence correctly', () {
      final geofence = Geofence(
        id: 'test_1',
        name: 'Test Geofence',
        latitude: 37.7749,
        longitude: -122.4194,
        radiusMeters: 50.0,
      );

      geofenceService.addGeofence(geofence);
      geofenceService.removeGeofence('test_1');

      expect(geofenceService.geofences, isEmpty);
    });

    test('clears all geofences correctly', () {
      final geofences = [
        Geofence(
          id: 'test_1',
          name: 'Test 1',
          latitude: 37.7749,
          longitude: -122.4194,
          radiusMeters: 50.0,
        ),
        Geofence(
          id: 'test_2',
          name: 'Test 2',
          latitude: 37.7750,
          longitude: -122.4195,
          radiusMeters: 50.0,
        ),
      ];

      geofenceService.addGeofences(geofences);
      geofenceService.clearGeofences();

      expect(geofenceService.geofences, isEmpty);
    });
  });

  group('Geofence Detection', () {
    test('detects enter event when moving into geofence', () async {
      final geofence = Geofence(
        id: 'stop_1',
        name: 'Historic Building',
        latitude: 37.7749,
        longitude: -122.4194,
        radiusMeters: 50.0,
      );

      geofenceService.addGeofence(geofence);

      final events = <GeofenceEvent>[];
      final subscription = geofenceService.eventStream.listen(events.add);

      // Simulate entering the geofence
      final position = Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      geofenceService.checkPosition(position);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(events.length, equals(1));
      expect(events.first.type, equals(GeofenceEventType.enter));
      expect(events.first.geofence.id, equals('stop_1'));
      expect(geofenceService.insideGeofences, contains('stop_1'));

      await subscription.cancel();
    });

    test('detects exit event when moving out of geofence', () async {
      final geofence = Geofence(
        id: 'stop_1',
        name: 'Historic Building',
        latitude: 37.7749,
        longitude: -122.4194,
        radiusMeters: 50.0,
      );

      geofenceService.addGeofence(geofence);

      final events = <GeofenceEvent>[];
      final subscription = geofenceService.eventStream.listen(events.add);

      // First, enter the geofence
      final positionInside = Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      geofenceService.checkPosition(positionInside);
      await Future.delayed(const Duration(milliseconds: 100));

      // Then exit the geofence (move far away)
      final positionOutside = Position(
        latitude: 37.7760,
        longitude: -122.4210,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      geofenceService.checkPosition(positionOutside);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(events.length, equals(2));
      expect(events[0].type, equals(GeofenceEventType.enter));
      expect(events[1].type, equals(GeofenceEventType.exit));
      expect(events[1].geofence.id, equals('stop_1'));
      expect(geofenceService.insideGeofences, isNot(contains('stop_1')));

      await subscription.cancel();
    });

    test('detects dwell event when staying inside geofence', () async {
      geofenceService.dwellDuration = const Duration(milliseconds: 100);

      final geofence = Geofence(
        id: 'stop_1',
        name: 'Historic Building',
        latitude: 37.7749,
        longitude: -122.4194,
        radiusMeters: 50.0,
      );

      geofenceService.addGeofence(geofence);

      final events = <GeofenceEvent>[];
      final subscription = geofenceService.eventStream.listen(events.add);

      final position = Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      // Enter geofence
      geofenceService.checkPosition(position);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(events.length, equals(1));
      expect(events.first.type, equals(GeofenceEventType.enter));

      // Wait for dwell duration and check position again
      await Future.delayed(const Duration(milliseconds: 100));
      geofenceService.checkPosition(position);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(events.length, equals(2));
      expect(events[1].type, equals(GeofenceEventType.dwell));

      await subscription.cancel();
    });

    test('does not trigger duplicate enter events', () async {
      final geofence = Geofence(
        id: 'stop_1',
        name: 'Historic Building',
        latitude: 37.7749,
        longitude: -122.4194,
        radiusMeters: 50.0,
      );

      geofenceService.addGeofence(geofence);

      final events = <GeofenceEvent>[];
      final subscription = geofenceService.eventStream.listen(events.add);

      final position = Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      // Check position multiple times while inside
      geofenceService.checkPosition(position);
      await Future.delayed(const Duration(milliseconds: 50));
      geofenceService.checkPosition(position);
      await Future.delayed(const Duration(milliseconds: 50));
      geofenceService.checkPosition(position);
      await Future.delayed(const Duration(milliseconds: 50));

      // Should only have one enter event
      expect(events.where((e) => e.type == GeofenceEventType.enter).length, equals(1));

      await subscription.cancel();
    });
  });

  group('Geofence Queries', () {
    test('finds nearest geofence correctly', () {
      final geofences = [
        Geofence(
          id: 'stop_1',
          name: 'Far Stop',
          latitude: 37.7800,
          longitude: -122.4300,
          radiusMeters: 50.0,
        ),
        Geofence(
          id: 'stop_2',
          name: 'Close Stop',
          latitude: 37.7750,
          longitude: -122.4195,
          radiusMeters: 50.0,
        ),
        Geofence(
          id: 'stop_3',
          name: 'Middle Stop',
          latitude: 37.7760,
          longitude: -122.4210,
          radiusMeters: 50.0,
        ),
      ];

      geofenceService.addGeofences(geofences);

      // Find nearest from test location
      final result = geofenceService.getNearestGeofence(37.7749, -122.4194);

      expect(result, isNotNull);
      expect(result!.geofence.id, equals('stop_2'));
    });

    test('returns null when no geofences exist', () {
      final result = geofenceService.getNearestGeofence(37.7749, -122.4194);
      expect(result, isNull);
    });

    test('finds geofences within distance', () {
      final geofences = [
        Geofence(
          id: 'stop_1',
          name: 'Close Stop 1',
          latitude: 37.7750,
          longitude: -122.4195,
          radiusMeters: 50.0,
        ),
        Geofence(
          id: 'stop_2',
          name: 'Close Stop 2',
          latitude: 37.7751,
          longitude: -122.4196,
          radiusMeters: 50.0,
        ),
        Geofence(
          id: 'stop_3',
          name: 'Far Stop',
          latitude: 37.8000,
          longitude: -122.4500,
          radiusMeters: 50.0,
        ),
      ];

      geofenceService.addGeofences(geofences);

      // Find geofences within 200 meters
      final results = geofenceService.getGeofencesWithinDistance(
        37.7749,
        -122.4194,
        200.0,
      );

      expect(results.length, equals(2));
      expect(results[0].geofence.id, equals('stop_1'));
      expect(results[1].geofence.id, equals('stop_2'));
      // Results should be sorted by distance
      expect(results[0].distance, lessThanOrEqualTo(results[1].distance));
    });
  });

  group('Geofence class', () {
    test('calculates distance correctly', () {
      final geofence = Geofence(
        id: 'test',
        name: 'Test',
        latitude: 37.7749,
        longitude: -122.4194,
        radiusMeters: 50.0,
      );

      // Distance to same location should be ~0
      final distance1 = geofence.distanceFrom(37.7749, -122.4194);
      expect(distance1, lessThan(1.0));

      // Distance to different location should be non-zero
      final distance2 = geofence.distanceFrom(37.7800, -122.4300);
      expect(distance2, greaterThan(0.0));
    });

    test('contains method works correctly', () {
      final geofence = Geofence(
        id: 'test',
        name: 'Test',
        latitude: 37.7749,
        longitude: -122.4194,
        radiusMeters: 50.0,
      );

      // Center should be inside
      expect(geofence.contains(37.7749, -122.4194), isTrue);

      // Very close point should be inside
      expect(geofence.contains(37.77491, -122.41941), isTrue);

      // Far point should be outside
      expect(geofence.contains(37.7800, -122.4300), isFalse);
    });
  });

  group('Monitoring Control', () {
    test('starts monitoring successfully', () async {
      final result = await geofenceService.startMonitoring();

      expect(result, isTrue);
      expect(geofenceService.isMonitoring, isTrue);
      verify(mockLocationService.startTracking(distanceFilter: anyNamed('distanceFilter')))
          .called(1);
    });

    test('does not start monitoring twice', () async {
      await geofenceService.startMonitoring();
      await geofenceService.startMonitoring();

      // Should only call startTracking once
      verify(mockLocationService.startTracking(distanceFilter: anyNamed('distanceFilter')))
          .called(1);
    });

    test('stops monitoring correctly', () async {
      await geofenceService.startMonitoring();
      geofenceService.stopMonitoring();

      expect(geofenceService.isMonitoring, isFalse);
      verify(mockLocationService.stopTracking()).called(1);
    });

    test('clears state when stopping', () async {
      final geofence = Geofence(
        id: 'test',
        name: 'Test',
        latitude: 37.7749,
        longitude: -122.4194,
        radiusMeters: 50.0,
      );

      geofenceService.addGeofence(geofence);

      // Enter geofence
      final position = Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      geofenceService.checkPosition(position);
      expect(geofenceService.insideGeofences, contains('test'));

      // Stop monitoring should clear inside state
      geofenceService.stopMonitoring();
      expect(geofenceService.insideGeofences, isEmpty);
    });
  });

  group('Rapid Enter/Exit Event Handling', () {
    test('handles rapid enter/exit sequences correctly', () async {
      // Disable cooldown for this test to allow rapid re-entry
      geofenceService.cooldownDuration = Duration.zero;

      final geofence = Geofence(
        id: 'test',
        name: 'Test',
        latitude: 37.7749,
        longitude: -122.4194,
        radiusMeters: 50.0,
      );

      geofenceService.addGeofence(geofence);

      final events = <GeofenceEvent>[];
      final subscription = geofenceService.eventStream.listen(events.add);

      final positionInside = Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      final positionOutside = Position(
        latitude: 37.7800,
        longitude: -122.4300,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      // Rapid enter/exit sequence
      geofenceService.checkPosition(positionInside); // Enter
      geofenceService.checkPosition(positionOutside); // Exit
      geofenceService.checkPosition(positionInside); // Enter
      geofenceService.checkPosition(positionOutside); // Exit
      geofenceService.checkPosition(positionInside); // Enter

      await Future.delayed(const Duration(milliseconds: 100));

      // Should have 5 events: enter, exit, enter, exit, enter
      expect(events.length, equals(5));
      expect(events[0].type, equals(GeofenceEventType.enter));
      expect(events[1].type, equals(GeofenceEventType.exit));
      expect(events[2].type, equals(GeofenceEventType.enter));
      expect(events[3].type, equals(GeofenceEventType.exit));
      expect(events[4].type, equals(GeofenceEventType.enter));

      await subscription.cancel();
    });

    test('handles high-frequency position updates without missing events', () async {
      final geofence = Geofence(
        id: 'test',
        name: 'Test',
        latitude: 37.7749,
        longitude: -122.4194,
        radiusMeters: 50.0,
      );

      geofenceService.addGeofence(geofence);

      final events = <GeofenceEvent>[];
      final subscription = geofenceService.eventStream.listen(events.add);

      // Simulate 20 rapid position updates while inside
      for (var i = 0; i < 20; i++) {
        final position = Position(
          latitude: 37.7749 + (i * 0.0001),
          longitude: -122.4194,
          timestamp: DateTime.now(),
          accuracy: 10.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
        geofenceService.checkPosition(position);
      }

      await Future.delayed(const Duration(milliseconds: 100));

      // Should only have one enter event
      final enterEvents = events.where((e) => e.type == GeofenceEventType.enter).toList();
      expect(enterEvents.length, equals(1));

      await subscription.cancel();
    });
  });

  group('Overlapping Geofences', () {
    test('triggers enter events for all overlapping geofences', () async {
      // Two overlapping geofences centered close together
      final geofences = [
        Geofence(
          id: 'geofence_1',
          name: 'Geofence 1',
          latitude: 37.7749,
          longitude: -122.4194,
          radiusMeters: 100.0,
        ),
        Geofence(
          id: 'geofence_2',
          name: 'Geofence 2',
          latitude: 37.7750,
          longitude: -122.4195,
          radiusMeters: 100.0,
        ),
      ];

      geofenceService.addGeofences(geofences);

      final events = <GeofenceEvent>[];
      final subscription = geofenceService.eventStream.listen(events.add);

      // Position that is inside both geofences
      final position = Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      geofenceService.checkPosition(position);
      await Future.delayed(const Duration(milliseconds: 100));

      // Should have two enter events
      expect(events.length, equals(2));
      expect(events.every((e) => e.type == GeofenceEventType.enter), isTrue);

      // Both geofences should be in insideGeofences
      expect(geofenceService.insideGeofences, containsAll(['geofence_1', 'geofence_2']));

      await subscription.cancel();
    });

    test('handles exit from one overlapping geofence while remaining in another', () async {
      final geofences = [
        Geofence(
          id: 'large_geofence',
          name: 'Large Geofence',
          latitude: 37.7749,
          longitude: -122.4194,
          radiusMeters: 200.0,
        ),
        Geofence(
          id: 'small_geofence',
          name: 'Small Geofence',
          latitude: 37.7749,
          longitude: -122.4194,
          radiusMeters: 30.0,
        ),
      ];

      geofenceService.addGeofences(geofences);

      final events = <GeofenceEvent>[];
      final subscription = geofenceService.eventStream.listen(events.add);

      // Enter both geofences (at center)
      final positionCenter = Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      geofenceService.checkPosition(positionCenter);
      await Future.delayed(const Duration(milliseconds: 50));

      // Move to position inside large but outside small (50m away)
      final positionEdge = Position(
        latitude: 37.7753,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      geofenceService.checkPosition(positionEdge);
      await Future.delayed(const Duration(milliseconds: 100));

      // Should have 2 enters + 1 exit
      final enterEvents = events.where((e) => e.type == GeofenceEventType.enter).toList();
      final exitEvents = events.where((e) => e.type == GeofenceEventType.exit).toList();

      expect(enterEvents.length, equals(2));
      expect(exitEvents.length, equals(1));
      expect(exitEvents.first.geofence.id, equals('small_geofence'));

      // Only large geofence should be in insideGeofences
      expect(geofenceService.insideGeofences, contains('large_geofence'));
      expect(geofenceService.insideGeofences, isNot(contains('small_geofence')));

      await subscription.cancel();
    });
  });

  group('GPS Accuracy Variations', () {
    test('handles position with low accuracy', () async {
      final geofence = Geofence(
        id: 'test',
        name: 'Test',
        latitude: 37.7749,
        longitude: -122.4194,
        radiusMeters: 50.0,
      );

      geofenceService.addGeofence(geofence);

      final events = <GeofenceEvent>[];
      final subscription = geofenceService.eventStream.listen(events.add);

      // Position with low accuracy (100m)
      final lowAccuracyPosition = Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 100.0, // Low accuracy
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      geofenceService.checkPosition(lowAccuracyPosition);
      await Future.delayed(const Duration(milliseconds: 100));

      // Should still trigger enter event (geofence detection uses position, not accuracy)
      expect(events.length, equals(1));
      expect(events.first.type, equals(GeofenceEventType.enter));

      await subscription.cancel();
    });

    test('processes positions with very high accuracy', () async {
      final geofence = Geofence(
        id: 'test',
        name: 'Test',
        latitude: 37.7749,
        longitude: -122.4194,
        radiusMeters: 50.0,
      );

      geofenceService.addGeofence(geofence);

      final events = <GeofenceEvent>[];
      final subscription = geofenceService.eventStream.listen(events.add);

      // Position with high accuracy (1m)
      final highAccuracyPosition = Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 1.0, // High accuracy
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      geofenceService.checkPosition(highAccuracyPosition);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(events.length, equals(1));
      expect(events.first.type, equals(GeofenceEventType.enter));
      expect(events.first.position.accuracy, equals(1.0));

      await subscription.cancel();
    });
  });

  group('Performance with Many Geofences', () {
    test('handles 100+ geofences efficiently', () async {
      // Add 100 geofences
      final geofences = List.generate(
        100,
        (index) => Geofence(
          id: 'geofence_$index',
          name: 'Geofence $index',
          latitude: 37.7749 + (index * 0.001), // Spread out
          longitude: -122.4194,
          radiusMeters: 30.0,
        ),
      );

      geofenceService.addGeofences(geofences);

      expect(geofenceService.geofences.length, equals(100));

      final stopwatch = Stopwatch()..start();

      // Check position against all geofences
      final position = Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      geofenceService.checkPosition(position);

      stopwatch.stop();

      // Should complete within reasonable time (less than 100ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(100));

      // Should enter first geofence
      expect(geofenceService.insideGeofences, contains('geofence_0'));
    });

    test('getNearestGeofence is efficient with many geofences', () {
      final geofences = List.generate(
        100,
        (index) => Geofence(
          id: 'geofence_$index',
          name: 'Geofence $index',
          latitude: 37.7749 + (index * 0.001),
          longitude: -122.4194 + (index * 0.001),
          radiusMeters: 30.0,
        ),
      );

      geofenceService.addGeofences(geofences);

      final stopwatch = Stopwatch()..start();

      final result = geofenceService.getNearestGeofence(37.7749, -122.4194);

      stopwatch.stop();

      expect(result, isNotNull);
      expect(result!.geofence.id, equals('geofence_0'));
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });

    test('getGeofencesWithinDistance filters efficiently', () {
      final geofences = List.generate(
        100,
        (index) => Geofence(
          id: 'geofence_$index',
          name: 'Geofence $index',
          latitude: 37.7749 + (index * 0.01), // ~1km apart
          longitude: -122.4194,
          radiusMeters: 30.0,
        ),
      );

      geofenceService.addGeofences(geofences);

      final stopwatch = Stopwatch()..start();

      // Should only find geofences within 500m
      final results = geofenceService.getGeofencesWithinDistance(
        37.7749,
        -122.4194,
        500.0,
      );

      stopwatch.stop();

      // Should only include nearby geofences
      expect(results.length, lessThan(10));
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });
  });

  group('Edge Cases', () {
    test('handles geofence at exactly radius boundary', () async {
      final geofence = Geofence(
        id: 'test',
        name: 'Test',
        latitude: 37.7749,
        longitude: -122.4194,
        radiusMeters: 100.0,
      );

      geofenceService.addGeofence(geofence);

      // Calculate position exactly at 100m away
      // ~100m north is approximately 0.0009 degrees of latitude
      final positionAtBoundary = Position(
        latitude: 37.7758,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      final distance = geofence.distanceFrom(
        positionAtBoundary.latitude,
        positionAtBoundary.longitude,
      );

      // Check if position is at or near the boundary
      // The contains method uses <= so exactly at boundary should be inside
      expect(distance, closeTo(100.0, 10.0));
    });

    test('handles geofence with zero radius', () {
      final geofence = Geofence(
        id: 'test',
        name: 'Test',
        latitude: 37.7749,
        longitude: -122.4194,
        radiusMeters: 0.0,
      );

      geofenceService.addGeofence(geofence);

      // Only exact center should be inside
      expect(geofence.contains(37.7749, -122.4194), isTrue);
      expect(geofence.contains(37.77491, -122.4194), isFalse);
    });

    test('handles geofence with very large radius', () async {
      final geofence = Geofence(
        id: 'test',
        name: 'Test',
        latitude: 37.7749,
        longitude: -122.4194,
        radiusMeters: 100000.0, // 100km
      );

      geofenceService.addGeofence(geofence);

      final events = <GeofenceEvent>[];
      final subscription = geofenceService.eventStream.listen(events.add);

      // Position 50km away should still be inside
      final position = Position(
        latitude: 38.2749, // ~55km north
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      geofenceService.checkPosition(position);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(events.length, equals(1));
      expect(events.first.type, equals(GeofenceEventType.enter));

      await subscription.cancel();
    });

    test('handles removing geofence while inside', () async {
      final geofence = Geofence(
        id: 'test',
        name: 'Test',
        latitude: 37.7749,
        longitude: -122.4194,
        radiusMeters: 50.0,
      );

      geofenceService.addGeofence(geofence);

      // Enter geofence
      final position = Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      geofenceService.checkPosition(position);
      expect(geofenceService.insideGeofences, contains('test'));

      // Remove geofence while inside
      geofenceService.removeGeofence('test');

      expect(geofenceService.insideGeofences, isEmpty);
      expect(geofenceService.geofences, isEmpty);
    });

    test('dwell event only triggers once per entry', () async {
      geofenceService.dwellDuration = const Duration(milliseconds: 50);

      final geofence = Geofence(
        id: 'test',
        name: 'Test',
        latitude: 37.7749,
        longitude: -122.4194,
        radiusMeters: 50.0,
      );

      geofenceService.addGeofence(geofence);

      final events = <GeofenceEvent>[];
      final subscription = geofenceService.eventStream.listen(events.add);

      final position = Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      // Enter
      geofenceService.checkPosition(position);
      await Future.delayed(const Duration(milliseconds: 100));

      // Multiple position updates after dwell duration
      geofenceService.checkPosition(position);
      await Future.delayed(const Duration(milliseconds: 50));
      geofenceService.checkPosition(position);
      await Future.delayed(const Duration(milliseconds: 50));
      geofenceService.checkPosition(position);
      await Future.delayed(const Duration(milliseconds: 50));

      // Should only have one dwell event
      final dwellEvents = events.where((e) => e.type == GeofenceEventType.dwell).toList();
      expect(dwellEvents.length, equals(1));

      await subscription.cancel();
    });

    test('geofence data is preserved in events', () async {
      final geofence = Geofence(
        id: 'test',
        name: 'Test Geofence',
        latitude: 37.7749,
        longitude: -122.4194,
        radiusMeters: 50.0,
        data: {'stopIndex': 5, 'tourId': 'tour123'},
      );

      geofenceService.addGeofence(geofence);

      final events = <GeofenceEvent>[];
      final subscription = geofenceService.eventStream.listen(events.add);

      final position = Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      geofenceService.checkPosition(position);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(events.first.geofence.data, isNotNull);
      expect(events.first.geofence.data!['stopIndex'], equals(5));
      expect(events.first.geofence.data!['tourId'], equals('tour123'));

      await subscription.cancel();
    });
  });
}
