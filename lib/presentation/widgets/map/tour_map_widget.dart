import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../config/mapbox_config.dart';

/// A reusable map widget for displaying tour routes and stops
class TourMapWidget extends StatefulWidget {
  /// Initial center position
  final Position? initialCenter;

  /// Initial zoom level
  final double initialZoom;

  /// Map style to use
  final String? mapStyle;

  /// Route polyline coordinates (list of [lng, lat] pairs)
  final List<List<double>>? routeCoordinates;

  /// Stop markers to display
  final List<StopMarker>? stops;

  /// Current user position
  final Position? userPosition;

  /// Whether to show user location indicator
  final bool showUserLocation;

  /// Whether the map is interactive (can be panned/zoomed)
  final bool interactive;

  /// Callback when map is created
  final void Function(MapboxMap)? onMapCreated;

  /// Callback when a stop marker is tapped
  final void Function(StopMarker)? onStopTapped;

  /// Callback when map is tapped
  final void Function(Position)? onMapTapped;

  /// Callback when map is long pressed
  final void Function(Position)? onMapLongPressed;

  const TourMapWidget({
    super.key,
    this.initialCenter,
    this.initialZoom = MapboxConfig.defaultZoom,
    this.mapStyle,
    this.routeCoordinates,
    this.stops,
    this.userPosition,
    this.showUserLocation = true,
    this.interactive = true,
    this.onMapCreated,
    this.onStopTapped,
    this.onMapTapped,
    this.onMapLongPressed,
  });

  @override
  State<TourMapWidget> createState() => _TourMapWidgetState();
}

class _TourMapWidgetState extends State<TourMapWidget> {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  PolylineAnnotationManager? _polylineAnnotationManager;
  final Map<String, StopMarker> _markerMap = {};

  @override
  void didUpdateWidget(TourMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update route if changed
    if (widget.routeCoordinates != oldWidget.routeCoordinates) {
      _updateRoute();
    }

    // Update stops if changed
    if (widget.stops != oldWidget.stops) {
      _updateStops();
    }

    // Update user position if changed
    if (widget.userPosition != oldWidget.userPosition &&
        widget.userPosition != null) {
      _flyToPosition(widget.userPosition!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = widget.initialCenter ??
        Position(MapboxConfig.defaultLongitude, MapboxConfig.defaultLatitude);

    return MapWidget(
      key: const ValueKey('tour_map'),
      cameraOptions: CameraOptions(
        center: Point(coordinates: center),
        zoom: widget.initialZoom,
      ),
      styleUri: widget.mapStyle ?? MapboxConfig.defaultStyle,
      onMapCreated: _onMapCreated,
      onTapListener: widget.onMapTapped != null ? _onMapTapped : null,
      onLongTapListener:
          widget.onMapLongPressed != null ? _onMapLongPressed : null,
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    // Create annotation managers
    _pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();
    _polylineAnnotationManager =
        await mapboxMap.annotations.createPolylineAnnotationManager();

    // Set up tap listener for markers
    _pointAnnotationManager?.addOnPointAnnotationClickListener(
      _PointAnnotationClickListener(
        markerMap: _markerMap,
        onStopTapped: widget.onStopTapped,
      ),
    );

    // Enable user location if requested
    if (widget.showUserLocation) {
      await _enableUserLocation();
    }

    // Draw initial route and stops
    _updateRoute();
    _updateStops();

    widget.onMapCreated?.call(mapboxMap);
  }

  Future<void> _enableUserLocation() async {
    await _mapboxMap?.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        showAccuracyRing: true,
      ),
    );
  }

  void _onMapTapped(MapContentGestureContext context) {
    final coords = context.point.coordinates;
    widget.onMapTapped?.call(coords);
  }

  void _onMapLongPressed(MapContentGestureContext context) {
    final coords = context.point.coordinates;
    widget.onMapLongPressed?.call(coords);
  }

  Future<void> _updateRoute() async {
    if (_polylineAnnotationManager == null) return;

    // Clear existing route
    await _polylineAnnotationManager?.deleteAll();

    if (widget.routeCoordinates == null || widget.routeCoordinates!.isEmpty) {
      return;
    }

    // Create polyline from coordinates
    final coordinates = widget.routeCoordinates!
        .map((coord) => Position(coord[0], coord[1]))
        .toList();

    await _polylineAnnotationManager?.create(
      PolylineAnnotationOptions(
        geometry: LineString(coordinates: coordinates),
        lineColor: Colors.blue.value,
        lineWidth: 4.0,
        lineOpacity: 0.8,
      ),
    );
  }

  Future<void> _updateStops() async {
    if (_pointAnnotationManager == null) return;

    // Clear existing markers
    await _pointAnnotationManager?.deleteAll();
    _markerMap.clear();

    if (widget.stops == null || widget.stops!.isEmpty) return;

    for (final stop in widget.stops!) {
      final annotation = await _pointAnnotationManager?.create(
        PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(stop.longitude, stop.latitude),
          ),
          iconSize: 1.5,
          textField: stop.name,
          textOffset: [0, 1.5],
          textSize: 12,
        ),
      );

      if (annotation != null) {
        _markerMap[annotation.id] = stop;
      }
    }
  }

  Future<void> _flyToPosition(Position position) async {
    await _mapboxMap?.flyTo(
      CameraOptions(
        center: Point(coordinates: position),
        zoom: widget.initialZoom,
      ),
      MapAnimationOptions(duration: 1000),
    );
  }

  /// Public method to fit map to show all stops
  Future<void> fitToStops() async {
    if (widget.stops == null || widget.stops!.isEmpty || _mapboxMap == null) {
      return;
    }

    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;

    for (final stop in widget.stops!) {
      if (stop.latitude < minLat) minLat = stop.latitude;
      if (stop.latitude > maxLat) maxLat = stop.latitude;
      if (stop.longitude < minLng) minLng = stop.longitude;
      if (stop.longitude > maxLng) maxLng = stop.longitude;
    }

    final bounds = CoordinateBounds(
      southwest: Point(coordinates: Position(minLng, minLat)),
      northeast: Point(coordinates: Position(maxLng, maxLat)),
      infiniteBounds: false,
    );

    await _mapboxMap?.setCamera(
      await _mapboxMap!.cameraForCoordinateBounds(
        bounds,
        MbxEdgeInsets(top: 50, left: 50, bottom: 50, right: 50),
        null,
        null,
        null,
        null,
      ),
    );
  }

  /// Public method to center on user location
  Future<void> centerOnUserLocation() async {
    if (widget.userPosition != null) {
      await _flyToPosition(widget.userPosition!);
    }
  }

  @override
  void dispose() {
    _markerMap.clear();
    super.dispose();
  }
}

/// Data class for stop markers
class StopMarker {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int order;
  final bool isCompleted;
  final bool isCurrent;
  final double? triggerRadius;

  const StopMarker({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.order,
    this.isCompleted = false,
    this.isCurrent = false,
    this.triggerRadius,
  });
}

/// Click listener for point annotations
class _PointAnnotationClickListener
    implements OnPointAnnotationClickListener {
  final Map<String, StopMarker> markerMap;
  final void Function(StopMarker)? onStopTapped;

  _PointAnnotationClickListener({
    required this.markerMap,
    this.onStopTapped,
  });

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    final stop = markerMap[annotation.id];
    if (stop != null) {
      onStopTapped?.call(stop);
    }
  }
}
