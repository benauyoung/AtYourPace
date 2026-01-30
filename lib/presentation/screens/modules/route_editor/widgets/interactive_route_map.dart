import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

import '../../../../../config/mapbox_config.dart';
import '../../../../../data/models/waypoint_model.dart';
import '../providers/route_editor_provider.dart';

/// Interactive map for route editing
class InteractiveRouteMap extends ConsumerStatefulWidget {
  final String tourId;
  final String versionId;
  final String? routeId;
  final void Function(LatLng location)? onMapTapped;
  final void Function(LatLng location)? onMapLongPressed;
  final void Function(int index)? onWaypointTapped;
  final void Function(int index, LatLng newLocation)? onWaypointDragged;

  const InteractiveRouteMap({
    super.key,
    required this.tourId,
    required this.versionId,
    this.routeId,
    this.onMapTapped,
    this.onMapLongPressed,
    this.onWaypointTapped,
    this.onWaypointDragged,
  });

  @override
  ConsumerState<InteractiveRouteMap> createState() => InteractiveRouteMapState();
}

/// State for InteractiveRouteMap - public to allow access via GlobalKey
class InteractiveRouteMapState extends ConsumerState<InteractiveRouteMap> {
  mapbox.MapboxMap? _mapboxMap;
  mapbox.PointAnnotationManager? _waypointManager;
  mapbox.PolylineAnnotationManager? _routeLineManager;
  mapbox.CircleAnnotationManager? _radiusCircleManager;

  final Map<String, int> _annotationIdToWaypointIndex = {};

  @override
  void dispose() {
    _waypointManager = null;
    _routeLineManager = null;
    _radiusCircleManager = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = (
      tourId: widget.tourId,
      versionId: widget.versionId,
      routeId: widget.routeId,
    );
    final routeState = ref.watch(routeEditorProvider(params));

    // Update annotations when state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAnnotations(routeState);
    });

    return Stack(
      children: [
        mapbox.MapWidget(
          key: const ValueKey('route_editor_map'),
          styleUri: MapboxConfig.styleStreets,
          cameraOptions: mapbox.CameraOptions(
            center: mapbox.Point(
              coordinates: mapbox.Position(
                MapboxConfig.defaultCenter.longitude,
                MapboxConfig.defaultCenter.latitude,
              ),
            ),
            zoom: MapboxConfig.defaultZoom,
          ),
          onMapCreated: _onMapCreated,
          onTapListener: _onMapTap,
          onLongTapListener: _onMapLongTap,
        ),
        // Loading overlay
        if (routeState.isSnapping)
          Container(
            color: Colors.black26,
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 16),
                      Text('Calculating route...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        // Route stats overlay
        Positioned(
          left: 16,
          bottom: 16,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.straighten, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    routeState.distanceFormatted,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.schedule, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    routeState.durationFormatted,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.place, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${routeState.waypoints.length} stops',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Overlap warning
        if (routeState.hasOverlappingWaypoints)
          Positioned(
            left: 16,
            top: 16,
            child: Card(
              color: Colors.orange.shade100,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, size: 16, color: Colors.orange.shade800),
                    const SizedBox(width: 8),
                    Text(
                      '${routeState.overlappingWaypoints.length} overlapping triggers',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _onMapCreated(mapbox.MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    // Create annotation managers
    _radiusCircleManager = await mapboxMap.annotations.createCircleAnnotationManager();
    _routeLineManager = await mapboxMap.annotations.createPolylineAnnotationManager();
    _waypointManager = await mapboxMap.annotations.createPointAnnotationManager();

    // Set up click listener for waypoints
    _waypointManager?.addOnPointAnnotationClickListener(
      _WaypointClickListener(
        annotationIdToIndex: _annotationIdToWaypointIndex,
        onWaypointTapped: widget.onWaypointTapped,
      ),
    );

    // Initial annotation update
    final params = (
      tourId: widget.tourId,
      versionId: widget.versionId,
      routeId: widget.routeId,
    );
    final routeState = ref.read(routeEditorProvider(params));
    await _updateAnnotations(routeState);

    // Fit to waypoints if any exist
    if (routeState.waypoints.isNotEmpty) {
      await _fitToWaypoints(routeState.waypoints);
    }
  }

  void _onMapTap(mapbox.MapContentGestureContext context) {
    final coordinates = context.point.coordinates;
    final location = LatLng(coordinates.lat.toDouble(), coordinates.lng.toDouble());
    widget.onMapTapped?.call(location);
  }

  void _onMapLongTap(mapbox.MapContentGestureContext context) {
    final coordinates = context.point.coordinates;
    final location = LatLng(coordinates.lat.toDouble(), coordinates.lng.toDouble());
    widget.onMapLongPressed?.call(location);
  }

  Future<void> _updateAnnotations(RouteEditorState state) async {
    if (_mapboxMap == null) return;

    await _updateRadiusCircles(state.waypoints);
    await _updateRouteLine(state.polyline);
    await _updateWaypointMarkers(state.waypoints, state.selectedWaypointIndex);
  }

  Future<void> _updateRadiusCircles(List<WaypointModel> waypoints) async {
    if (_radiusCircleManager == null) return;

    await _radiusCircleManager!.deleteAll();

    final circles = waypoints.map((waypoint) {
      return mapbox.CircleAnnotationOptions(
        geometry: mapbox.Point(
          coordinates: mapbox.Position(
            waypoint.longitude,
            waypoint.latitude,
          ),
        ),
        circleRadius: _metersToPixels(waypoint.triggerRadius.toDouble()),
        circleColor: waypoint.radiusColorHex,
        circleOpacity: 0.3,
        circleStrokeWidth: 2,
        circleStrokeColor: waypoint.radiusColorHex,
        circleStrokeOpacity: 0.6,
      );
    }).toList();

    if (circles.isNotEmpty) {
      await _radiusCircleManager!.createMulti(circles);
    }
  }

  Future<void> _updateRouteLine(List<LatLng> polyline) async {
    if (_routeLineManager == null) return;

    await _routeLineManager!.deleteAll();

    if (polyline.length < 2) return;

    final coordinates = polyline
        .map((p) => mapbox.Position(p.longitude, p.latitude))
        .toList();

    await _routeLineManager!.create(
      mapbox.PolylineAnnotationOptions(
        geometry: mapbox.LineString(coordinates: coordinates),
        lineColor: 0xFF2196F3, // Blue
        lineWidth: 4,
        lineOpacity: 0.8,
      ),
    );
  }

  Future<void> _updateWaypointMarkers(List<WaypointModel> waypoints, int? selectedIndex) async {
    if (_waypointManager == null) return;

    await _waypointManager!.deleteAll();
    _annotationIdToWaypointIndex.clear();

    final markers = <mapbox.PointAnnotationOptions>[];

    for (var i = 0; i < waypoints.length; i++) {
      final waypoint = waypoints[i];
      final isSelected = i == selectedIndex;

      markers.add(
        mapbox.PointAnnotationOptions(
          geometry: mapbox.Point(
            coordinates: mapbox.Position(
              waypoint.longitude,
              waypoint.latitude,
            ),
          ),
          iconSize: isSelected ? 1.5 : 1.0,
          iconColor: _getWaypointColor(waypoint.type, isSelected),
          textField: '${i + 1}',
          textSize: 12,
          textColor: 0xFFFFFFFF,
          textOffset: [0, -0.5],
        ),
      );
    }

    if (markers.isNotEmpty) {
      final annotations = await _waypointManager!.createMulti(markers);
      for (var i = 0; i < annotations.length; i++) {
        final annotation = annotations[i];
        final annotationId = annotation?.id;
        if (annotationId != null) {
          _annotationIdToWaypointIndex[annotationId] = i;
        }
      }
    }
  }

  int _getWaypointColor(WaypointType type, bool isSelected) {
    if (isSelected) return 0xFFFF5722; // Orange for selected

    switch (type) {
      case WaypointType.stop:
        return 0xFF2196F3; // Blue
      case WaypointType.waypoint:
        return 0xFF9E9E9E; // Grey
      case WaypointType.poi:
        return 0xFF4CAF50; // Green
    }
  }

  double _metersToPixels(double meters) {
    // Approximate conversion at default zoom level
    // This should be adjusted based on actual zoom
    return meters / 5;
  }

  Future<void> _fitToWaypoints(List<WaypointModel> waypoints) async {
    if (_mapboxMap == null || waypoints.isEmpty) return;

    if (waypoints.length == 1) {
      await _mapboxMap!.flyTo(
        mapbox.CameraOptions(
          center: mapbox.Point(
            coordinates: mapbox.Position(
              waypoints.first.longitude,
              waypoints.first.latitude,
            ),
          ),
          zoom: 15,
        ),
        mapbox.MapAnimationOptions(duration: 500),
      );
      return;
    }

    // Calculate bounds
    var minLat = double.infinity;
    var maxLat = double.negativeInfinity;
    var minLng = double.infinity;
    var maxLng = double.negativeInfinity;

    for (final waypoint in waypoints) {
      minLat = math.min(minLat, waypoint.latitude);
      maxLat = math.max(maxLat, waypoint.latitude);
      minLng = math.min(minLng, waypoint.longitude);
      maxLng = math.max(maxLng, waypoint.longitude);
    }

    // Add padding
    final latPadding = (maxLat - minLat) * 0.2;
    final lngPadding = (maxLng - minLng) * 0.2;

    await _mapboxMap!.cameraForCoordinateBounds(
      mapbox.CoordinateBounds(
        southwest: mapbox.Point(
          coordinates: mapbox.Position(minLng - lngPadding, minLat - latPadding),
        ),
        northeast: mapbox.Point(
          coordinates: mapbox.Position(maxLng + lngPadding, maxLat + latPadding),
        ),
        infiniteBounds: false,
      ),
      mapbox.MbxEdgeInsets(top: 50, left: 50, bottom: 50, right: 50),
      null, // bearing
      null, // pitch
      null, // maxZoom
      null, // offset
    ).then((cameraOptions) {
      _mapboxMap!.flyTo(
        cameraOptions,
        mapbox.MapAnimationOptions(duration: 500),
      );
    });
  }

  /// Public method to fit map to current waypoints
  Future<void> fitToWaypoints() async {
    final params = (
      tourId: widget.tourId,
      versionId: widget.versionId,
      routeId: widget.routeId,
    );
    final routeState = ref.read(routeEditorProvider(params));
    await _fitToWaypoints(routeState.waypoints);
  }

  /// Public method to center on a specific waypoint
  Future<void> centerOnWaypoint(int index) async {
    final params = (
      tourId: widget.tourId,
      versionId: widget.versionId,
      routeId: widget.routeId,
    );
    final routeState = ref.read(routeEditorProvider(params));

    if (index >= 0 && index < routeState.waypoints.length) {
      final waypoint = routeState.waypoints[index];
      await _mapboxMap?.flyTo(
        mapbox.CameraOptions(
          center: mapbox.Point(
            coordinates: mapbox.Position(
              waypoint.longitude,
              waypoint.latitude,
            ),
          ),
          zoom: 17,
        ),
        mapbox.MapAnimationOptions(duration: 500),
      );
    }
  }
}

/// Click listener for waypoint annotations
class _WaypointClickListener extends mapbox.OnPointAnnotationClickListener {
  final Map<String, int> annotationIdToIndex;
  final void Function(int index)? onWaypointTapped;

  _WaypointClickListener({
    required this.annotationIdToIndex,
    this.onWaypointTapped,
  });

  @override
  void onPointAnnotationClick(mapbox.PointAnnotation annotation) {
    final index = annotationIdToIndex[annotation.id];
    if (index != null) {
      onWaypointTapped?.call(index);
    }
  }
}
