import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ayp_tour_guide/data/models/route_model.dart';
import 'package:ayp_tour_guide/data/models/waypoint_model.dart';
import 'package:ayp_tour_guide/data/repositories/route_repository.dart';
import 'package:ayp_tour_guide/presentation/screens/modules/route_editor/providers/route_editor_provider.dart';
import 'package:ayp_tour_guide/services/route_snapping_service.dart';
import '../../helpers/test_helpers.dart';

class MockRouteRepository extends Mock implements RouteRepository {}

class MockRouteSnappingService extends Mock implements RouteSnappingService {}

void main() {
  late MockRouteRepository mockRouteRepository;
  late MockRouteSnappingService mockSnappingService;
  late RouteEditorNotifier notifier;

  setUp(() {
    mockRouteRepository = MockRouteRepository();
    mockSnappingService = MockRouteSnappingService();

    notifier = RouteEditorNotifier(
      tourId: 'tour_1',
      versionId: 'version_1',
      routeId: null,
      routeRepository: mockRouteRepository,
      snappingService: mockSnappingService,
    );
  });

  setUpAll(() {
    registerFallbackValue(
      createTestRoute(
        id: 'fallback_route',
        tourId: 'fallback_tour',
        versionId: 'fallback_version',
        waypoints: <WaypointModel>[],
      ),
    );
    registerFallbackValue(RouteSnapMode.roads);
    registerFallbackValue(<WaypointModel>[]);
  });

  group('RouteEditorState', () {
    test('initial state has correct default values', () {
      expect(notifier.state.tourId, equals('tour_1'));
      expect(notifier.state.versionId, equals('version_1'));
      expect(notifier.state.routeId, isNull);
      expect(notifier.state.waypoints, isEmpty);
      expect(notifier.state.polyline, isEmpty);
      expect(notifier.state.snapMode, equals(RouteSnapMode.roads));
      expect(notifier.state.canUndo, isFalse);
      expect(notifier.state.canRedo, isFalse);
      expect(notifier.state.hasUnsavedChanges, isFalse);
    });

    test('distanceFormatted returns meters for short distances', () {
      final state = RouteEditorState(
        tourId: 'tour_1',
        versionId: 'version_1',
        totalDistance: 500,
      );
      expect(state.distanceFormatted, equals('500m'));
    });

    test('distanceFormatted returns km for long distances', () {
      final state = RouteEditorState(
        tourId: 'tour_1',
        versionId: 'version_1',
        totalDistance: 2500,
      );
      expect(state.distanceFormatted, equals('2.5km'));
    });

    test('durationFormatted returns minutes only for short duration', () {
      final state = RouteEditorState(
        tourId: 'tour_1',
        versionId: 'version_1',
        estimatedDuration: 1800,
      );
      expect(state.durationFormatted, equals('30min'));
    });

    test('durationFormatted returns hours and minutes for long duration', () {
      final state = RouteEditorState(
        tourId: 'tour_1',
        versionId: 'version_1',
        estimatedDuration: 5400,
      );
      expect(state.durationFormatted, equals('1h 30min'));
    });

    test('hasChanges is alias for hasUnsavedChanges', () {
      final state = RouteEditorState(
        tourId: 'tour_1',
        versionId: 'version_1',
        hasUnsavedChanges: true,
      );
      expect(state.hasChanges, equals(state.hasUnsavedChanges));
    });
  });

  group('RouteEditorNotifier - Waypoint Operations', () {
    test('addWaypoint adds waypoint to state', () async {
      when(() => mockSnappingService.snapToRoads(
            waypoints: any(named: 'waypoints'),
            mode: any(named: 'mode'),
          )).thenAnswer((_) async => SnapRouteResult(
            snappedPolyline: <LatLng>[],
            totalDistance: 0,
            estimatedDuration: 0,
            snappedWaypointLocations: <LatLng>[],
          ));

      await notifier.addWaypoint(LatLng(48.8566, 2.3522));

      expect(notifier.state.waypoints.length, equals(1));
      expect(notifier.state.waypoints.first.latitude, closeTo(48.8566, 0.001));
      expect(notifier.state.hasUnsavedChanges, isTrue);
    });

    test('addWaypoint with custom name and type', () async {
      when(() => mockSnappingService.snapToRoads(
            waypoints: any(named: 'waypoints'),
            mode: any(named: 'mode'),
          )).thenAnswer((_) async => SnapRouteResult(
            snappedPolyline: <LatLng>[],
            totalDistance: 0,
            estimatedDuration: 0,
            snappedWaypointLocations: <LatLng>[],
          ));

      await notifier.addWaypoint(
        LatLng(48.8566, 2.3522),
        name: 'Eiffel Tower',
        type: WaypointType.poi,
      );

      expect(notifier.state.waypoints.first.name, equals('Eiffel Tower'));
      expect(notifier.state.waypoints.first.type, equals(WaypointType.poi));
    });

    test('removeWaypoint removes waypoint at index', () async {
      when(() => mockSnappingService.snapToRoads(
            waypoints: any(named: 'waypoints'),
            mode: any(named: 'mode'),
          )).thenAnswer((_) async => SnapRouteResult(
            snappedPolyline: <LatLng>[],
            totalDistance: 0,
            estimatedDuration: 0,
            snappedWaypointLocations: <LatLng>[],
          ));

      await notifier.addWaypoint(LatLng(48.8566, 2.3522));
      await notifier.addWaypoint(LatLng(48.8600, 2.3600));

      expect(notifier.state.waypoints.length, equals(2));

      await notifier.removeWaypoint(0);

      expect(notifier.state.waypoints.length, equals(1));
    });

    test('updateTriggerRadius updates waypoint trigger radius', () async {
      when(() => mockSnappingService.snapToRoads(
            waypoints: any(named: 'waypoints'),
            mode: any(named: 'mode'),
          )).thenAnswer((_) async => SnapRouteResult(
            snappedPolyline: <LatLng>[],
            totalDistance: 0,
            estimatedDuration: 0,
            snappedWaypointLocations: <LatLng>[],
          ));

      await notifier.addWaypoint(LatLng(48.8566, 2.3522));
      notifier.updateTriggerRadius(0, 50);

      expect(notifier.state.waypoints.first.triggerRadius, equals(50));
    });

    test('updateWaypointName updates waypoint name', () async {
      when(() => mockSnappingService.snapToRoads(
            waypoints: any(named: 'waypoints'),
            mode: any(named: 'mode'),
          )).thenAnswer((_) async => SnapRouteResult(
            snappedPolyline: <LatLng>[],
            totalDistance: 0,
            estimatedDuration: 0,
            snappedWaypointLocations: <LatLng>[],
          ));

      await notifier.addWaypoint(LatLng(48.8566, 2.3522));
      notifier.updateWaypointName(0, 'New Name');

      expect(notifier.state.waypoints.first.name, equals('New Name'));
    });

    test('updateWaypointType updates waypoint type', () async {
      when(() => mockSnappingService.snapToRoads(
            waypoints: any(named: 'waypoints'),
            mode: any(named: 'mode'),
          )).thenAnswer((_) async => SnapRouteResult(
            snappedPolyline: <LatLng>[],
            totalDistance: 0,
            estimatedDuration: 0,
            snappedWaypointLocations: <LatLng>[],
          ));

      await notifier.addWaypoint(LatLng(48.8566, 2.3522), type: WaypointType.stop);
      notifier.updateWaypointType(0, WaypointType.poi);

      expect(notifier.state.waypoints.first.type, equals(WaypointType.poi));
    });

    test('selectWaypoint sets selectedWaypointIndex', () async {
      when(() => mockSnappingService.snapToRoads(
            waypoints: any(named: 'waypoints'),
            mode: any(named: 'mode'),
          )).thenAnswer((_) async => SnapRouteResult(
            snappedPolyline: <LatLng>[],
            totalDistance: 0,
            estimatedDuration: 0,
            snappedWaypointLocations: <LatLng>[],
          ));

      await notifier.addWaypoint(LatLng(48.8566, 2.3522));
      notifier.selectWaypoint(0);

      expect(notifier.state.selectedWaypointIndex, equals(0));
    });

    test('selectWaypoint with null clears selection', () {
      notifier.selectWaypoint(null);
      expect(notifier.state.selectedWaypointIndex, isNull);
    });
  });

  group('RouteEditorNotifier - Undo/Redo', () {
    test('undo restores previous state', () async {
      when(() => mockSnappingService.snapToRoads(
            waypoints: any(named: 'waypoints'),
            mode: any(named: 'mode'),
          )).thenAnswer((_) async => SnapRouteResult(
            snappedPolyline: <LatLng>[],
            totalDistance: 0,
            estimatedDuration: 0,
            snappedWaypointLocations: <LatLng>[],
          ));

      await notifier.addWaypoint(LatLng(48.8566, 2.3522));

      expect(notifier.state.waypoints.length, equals(1));
      expect(notifier.state.canUndo, isTrue);

      await notifier.undo();

      expect(notifier.state.waypoints.length, equals(0));
      expect(notifier.state.canRedo, isTrue);
    });

    test('redo restores undone state', () async {
      when(() => mockSnappingService.snapToRoads(
            waypoints: any(named: 'waypoints'),
            mode: any(named: 'mode'),
          )).thenAnswer((_) async => SnapRouteResult(
            snappedPolyline: <LatLng>[],
            totalDistance: 0,
            estimatedDuration: 0,
            snappedWaypointLocations: <LatLng>[],
          ));

      await notifier.addWaypoint(LatLng(48.8566, 2.3522));
      await notifier.undo();
      await notifier.redo();

      expect(notifier.state.waypoints.length, equals(1));
    });

    test('new action clears redo stack', () async {
      when(() => mockSnappingService.snapToRoads(
            waypoints: any(named: 'waypoints'),
            mode: any(named: 'mode'),
          )).thenAnswer((_) async => SnapRouteResult(
            snappedPolyline: <LatLng>[],
            totalDistance: 0,
            estimatedDuration: 0,
            snappedWaypointLocations: <LatLng>[],
          ));

      await notifier.addWaypoint(LatLng(48.8566, 2.3522));
      await notifier.undo();

      expect(notifier.state.canRedo, isTrue);

      await notifier.addWaypoint(LatLng(48.8600, 2.3600));

      expect(notifier.state.canRedo, isFalse);
    });
  });

  group('RouteEditorNotifier - Snap Mode', () {
    test('setSnapMode updates snap mode', () async {
      when(() => mockSnappingService.snapToRoads(
            waypoints: any(named: 'waypoints'),
            mode: any(named: 'mode'),
          )).thenAnswer((_) async => SnapRouteResult(
            snappedPolyline: <LatLng>[],
            totalDistance: 0,
            estimatedDuration: 0,
            snappedWaypointLocations: <LatLng>[],
          ));

      await notifier.setSnapMode(RouteSnapMode.walking);

      expect(notifier.state.snapMode, equals(RouteSnapMode.walking));
      expect(notifier.state.hasUnsavedChanges, isTrue);
    });

    test('setSnapMode with same mode does nothing', () async {
      final initialChangeCount = notifier.state.hasUnsavedChanges;

      await notifier.setSnapMode(RouteSnapMode.roads);

      expect(notifier.state.hasUnsavedChanges, equals(initialChangeCount));
    });
  });

  group('RouteEditorNotifier - Save', () {
    test('save creates new route when routeId is null', () async {
      when(() => mockSnappingService.snapToRoads(
            waypoints: any(named: 'waypoints'),
            mode: any(named: 'mode'),
          )).thenAnswer((_) async => SnapRouteResult(
            snappedPolyline: <LatLng>[],
            totalDistance: 100,
            estimatedDuration: 60,
            snappedWaypointLocations: <LatLng>[],
          ));

      when(() => mockRouteRepository.create(
            tourId: any(named: 'tourId'),
            versionId: any(named: 'versionId'),
            route: any(named: 'route'),
          )).thenAnswer((_) async => createTestRoute(
            id: 'new_route_id',
            tourId: 'tour_1',
            versionId: 'version_1',
            waypoints: <WaypointModel>[],
          ));

      await notifier.addWaypoint(LatLng(48.8566, 2.3522));

      final success = await notifier.save();

      expect(success, isTrue);
      expect(notifier.state.routeId, equals('new_route_id'));
      expect(notifier.state.hasUnsavedChanges, isFalse);
    });

    test('save returns false with empty waypoints', () async {
      final success = await notifier.save();

      expect(success, isFalse);
      expect(notifier.state.error, isNotNull);
    });

    test('save updates existing route when routeId is set', () async {
      final existingNotifier = RouteEditorNotifier(
        tourId: 'tour_1',
        versionId: 'version_1',
        routeId: 'existing_route',
        routeRepository: mockRouteRepository,
        snappingService: mockSnappingService,
      );

      when(() => mockSnappingService.snapToRoads(
            waypoints: any(named: 'waypoints'),
            mode: any(named: 'mode'),
          )).thenAnswer((_) async => SnapRouteResult(
            snappedPolyline: <LatLng>[],
            totalDistance: 100,
            estimatedDuration: 60,
            snappedWaypointLocations: <LatLng>[],
          ));

      when(() => mockRouteRepository.update(
            versionId: any(named: 'versionId'),
            routeId: any(named: 'routeId'),
            route: any(named: 'route'),
            updateWaypoints: any(named: 'updateWaypoints'),
          )).thenAnswer((_) async => createTestRoute(
            id: 'existing_route',
            tourId: 'tour_1',
            versionId: 'version_1',
            waypoints: <WaypointModel>[],
          ));

      await existingNotifier.addWaypoint(LatLng(48.8566, 2.3522));

      final success = await existingNotifier.save();

      expect(success, isTrue);
      expect(existingNotifier.state.hasUnsavedChanges, isFalse);
    });
  });

  group('RouteEditorNotifier - Clear Route', () {
    test('clearRoute removes all waypoints', () async {
      when(() => mockSnappingService.snapToRoads(
            waypoints: any(named: 'waypoints'),
            mode: any(named: 'mode'),
          )).thenAnswer((_) async => SnapRouteResult(
            snappedPolyline: <LatLng>[],
            totalDistance: 0,
            estimatedDuration: 0,
            snappedWaypointLocations: <LatLng>[],
          ));

      await notifier.addWaypoint(LatLng(48.8566, 2.3522));
      await notifier.addWaypoint(LatLng(48.8600, 2.3600));

      expect(notifier.state.waypoints.length, equals(2));

      await notifier.clearRoute();

      expect(notifier.state.waypoints, isEmpty);
      expect(notifier.state.polyline, isEmpty);
      expect(notifier.state.totalDistance, equals(0));
    });
  });

  group('RouteEditorState - Overlapping Detection', () {
    test('overlappingWaypointIndices detects overlapping waypoints', () {
      final waypoints = [
        createTestWaypoint(order: 0, latitude: 48.8566, longitude: 2.3522, triggerRadius: 50),
        createTestWaypoint(order: 1, latitude: 48.8567, longitude: 2.3523, triggerRadius: 50),
      ];

      final state = RouteEditorState(
        tourId: 'tour_1',
        versionId: 'version_1',
        waypoints: waypoints,
      );

      expect(state.overlappingWaypointIndices, contains(0));
      expect(state.overlappingWaypointIndices, contains(1));
      expect(state.hasOverlappingWaypoints, isTrue);
    });

    test('overlappingWaypointIndices returns empty when no overlaps', () {
      final waypoints = [
        createTestWaypoint(order: 0, latitude: 48.8566, longitude: 2.3522, triggerRadius: 30),
        createTestWaypoint(order: 1, latitude: 48.8700, longitude: 2.3700, triggerRadius: 30),
      ];

      final state = RouteEditorState(
        tourId: 'tour_1',
        versionId: 'version_1',
        waypoints: waypoints,
      );

      expect(state.overlappingWaypointIndices, isEmpty);
      expect(state.hasOverlappingWaypoints, isFalse);
    });
  });
}
