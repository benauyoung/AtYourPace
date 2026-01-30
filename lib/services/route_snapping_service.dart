import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

import '../data/models/route_model.dart';
import '../data/models/waypoint_model.dart';

/// Result of a route snapping operation.
class SnapRouteResult {
  final List<LatLng> snappedPolyline;
  final double totalDistance;
  final int estimatedDuration;
  final List<LatLng> snappedWaypointLocations;
  final String? errorMessage;

  const SnapRouteResult({
    required this.snappedPolyline,
    required this.totalDistance,
    required this.estimatedDuration,
    required this.snappedWaypointLocations,
    this.errorMessage,
  });

  bool get hasError => errorMessage != null;

  factory SnapRouteResult.error(String message) {
    return SnapRouteResult(
      snappedPolyline: const [],
      totalDistance: 0,
      estimatedDuration: 0,
      snappedWaypointLocations: const [],
      errorMessage: message,
    );
  }
}

/// Service for snapping routes to roads using Mapbox Directions API.
class RouteSnappingService {
  final Dio _dio;
  final String _accessToken;

  static const String _baseUrl =
      'https://api.mapbox.com/directions/v5/mapbox';
  static const int _maxWaypointsPerRequest = 25;

  RouteSnappingService({
    required String mapboxAccessToken,
    Dio? dio,
  })  : _accessToken = mapboxAccessToken,
        _dio = dio ?? Dio();

  /// Snaps waypoints to roads and returns the route polyline.
  Future<SnapRouteResult> snapToRoads({
    required List<WaypointModel> waypoints,
    RouteSnapMode mode = RouteSnapMode.roads,
  }) async {
    if (waypoints.isEmpty) {
      return SnapRouteResult.error('No waypoints provided');
    }

    if (waypoints.length < 2) {
      return SnapRouteResult.error('At least 2 waypoints required');
    }

    if (mode == RouteSnapMode.none || mode == RouteSnapMode.manual) {
      return _directLineRoute(waypoints);
    }

    try {
      // Split into chunks if too many waypoints
      if (waypoints.length > _maxWaypointsPerRequest) {
        return await _snapLargeRoute(waypoints, mode);
      }

      return await _snapRoute(waypoints, mode);
    } catch (e) {
      return SnapRouteResult.error('Route snapping failed: $e');
    }
  }

  /// Snaps a route with up to 25 waypoints.
  Future<SnapRouteResult> _snapRoute(
    List<WaypointModel> waypoints,
    RouteSnapMode mode,
  ) async {
    final profile = _getProfile(mode);
    final coordinates = waypoints
        .map((w) => '${w.location.longitude},${w.location.latitude}')
        .join(';');

    final url = '$_baseUrl/$profile/$coordinates';

    final response = await _dio.get(
      url,
      queryParameters: {
        'access_token': _accessToken,
        'geometries': 'geojson',
        'overview': 'full',
        'steps': 'false',
        'annotations': 'distance,duration',
      },
    );

    if (response.statusCode != 200) {
      return SnapRouteResult.error(
        'Mapbox API error: ${response.statusCode}',
      );
    }

    final data = response.data as Map<String, dynamic>;

    if (data['code'] != 'Ok') {
      return SnapRouteResult.error(
        'Mapbox routing error: ${data['code']} - ${data['message']}',
      );
    }

    final routes = data['routes'] as List<dynamic>;
    if (routes.isEmpty) {
      return SnapRouteResult.error('No route found');
    }

    final route = routes[0] as Map<String, dynamic>;
    final geometry = route['geometry'] as Map<String, dynamic>;
    final coords = geometry['coordinates'] as List<dynamic>;

    final polyline = coords.map((c) {
      final coord = c as List<dynamic>;
      return LatLng(
        (coord[1] as num).toDouble(),
        (coord[0] as num).toDouble(),
      );
    }).toList();

    final distance = (route['distance'] as num).toDouble();
    final duration = (route['duration'] as num).toInt();

    // Extract snapped waypoint locations from legs
    final snappedLocations = <LatLng>[];
    final legs = route['legs'] as List<dynamic>?;
    if (legs != null && legs.isNotEmpty) {
      // First waypoint
      snappedLocations.add(polyline.first);
      // Intermediate waypoints (at leg boundaries)
      for (var i = 0; i < legs.length - 1; i++) {
        // Find the point along the polyline at this distance
        // For simplicity, we use the original waypoint location
        if (i + 1 < waypoints.length) {
          snappedLocations.add(waypoints[i + 1].location);
        }
      }
      // Last waypoint
      snappedLocations.add(polyline.last);
    } else {
      snappedLocations.addAll(waypoints.map((w) => w.location));
    }

    return SnapRouteResult(
      snappedPolyline: polyline,
      totalDistance: distance,
      estimatedDuration: duration,
      snappedWaypointLocations: snappedLocations,
    );
  }

  /// Handles routes with more than 25 waypoints by chunking.
  Future<SnapRouteResult> _snapLargeRoute(
    List<WaypointModel> waypoints,
    RouteSnapMode mode,
  ) async {
    final allPolylines = <LatLng>[];
    final allSnappedLocations = <LatLng>[];
    double totalDistance = 0;
    int totalDuration = 0;

    // Process in chunks with overlap
    const chunkSize = 24; // Leave room for connection
    var start = 0;

    while (start < waypoints.length) {
      final end = math.min(start + chunkSize, waypoints.length);
      final chunk = waypoints.sublist(start, end);

      final result = await _snapRoute(chunk, mode);
      if (result.hasError) {
        return result;
      }

      // Add polyline points (skip first if not the first chunk)
      if (allPolylines.isEmpty) {
        allPolylines.addAll(result.snappedPolyline);
      } else {
        allPolylines.addAll(result.snappedPolyline.skip(1));
      }

      // Add snapped locations
      if (allSnappedLocations.isEmpty) {
        allSnappedLocations.addAll(result.snappedWaypointLocations);
      } else {
        allSnappedLocations.addAll(result.snappedWaypointLocations.skip(1));
      }

      totalDistance += result.totalDistance;
      totalDuration += result.estimatedDuration;

      // Move to next chunk, with overlap of 1
      start = end - 1;
      if (start == waypoints.length - 1) break;
    }

    return SnapRouteResult(
      snappedPolyline: allPolylines,
      totalDistance: totalDistance,
      estimatedDuration: totalDuration,
      snappedWaypointLocations: allSnappedLocations,
    );
  }

  /// Creates a direct line route without snapping.
  SnapRouteResult _directLineRoute(List<WaypointModel> waypoints) {
    final polyline = waypoints.map((w) => w.location).toList();
    final distance = _calculateTotalDistance(polyline);
    final duration = _estimateDuration(distance);

    return SnapRouteResult(
      snappedPolyline: polyline,
      totalDistance: distance,
      estimatedDuration: duration,
      snappedWaypointLocations: polyline,
    );
  }

  /// Gets the Mapbox profile for the snap mode.
  String _getProfile(RouteSnapMode mode) {
    switch (mode) {
      case RouteSnapMode.roads:
        return 'driving';
      case RouteSnapMode.walking:
        return 'walking';
      default:
        return 'driving';
    }
  }

  /// Calculates total distance of a polyline in meters.
  double _calculateTotalDistance(List<LatLng> points) {
    if (points.length < 2) return 0;

    double total = 0;
    const distance = Distance();

    for (var i = 0; i < points.length - 1; i++) {
      total += distance.as(LengthUnit.Meter, points[i], points[i + 1]);
    }

    return total;
  }

  /// Estimates duration based on distance (walking speed ~5 km/h).
  int _estimateDuration(double distanceMeters) {
    const walkingSpeedMps = 5000 / 3600; // 5 km/h in m/s
    return (distanceMeters / walkingSpeedMps).round();
  }

  /// Calculates distance between two points in meters.
  double calculateDistance(LatLng from, LatLng to) {
    return const Distance().as(LengthUnit.Meter, from, to);
  }

  /// Estimates walking duration between two points in seconds.
  int estimateWalkingDuration(LatLng from, LatLng to) {
    final distance = calculateDistance(from, to);
    return _estimateDuration(distance);
  }

  /// Checks if a point is on or near the route polyline.
  bool isPointOnRoute(
    LatLng point,
    List<LatLng> polyline, {
    double tolerance = 50,
  }) {
    for (var i = 0; i < polyline.length - 1; i++) {
      final distance = _distanceToSegment(point, polyline[i], polyline[i + 1]);
      if (distance <= tolerance) {
        return true;
      }
    }
    return false;
  }

  /// Calculates distance from a point to a line segment.
  double _distanceToSegment(LatLng point, LatLng start, LatLng end) {
    const distance = Distance();

    final segmentLength = distance.as(LengthUnit.Meter, start, end);
    if (segmentLength == 0) {
      return distance.as(LengthUnit.Meter, point, start);
    }

    // Project point onto line segment
    final t = math.max(
      0,
      math.min(
        1,
        ((point.latitude - start.latitude) * (end.latitude - start.latitude) +
                (point.longitude - start.longitude) *
                    (end.longitude - start.longitude)) /
            (segmentLength * segmentLength / 111000 / 111000), // Approx degrees
      ),
    );

    final projection = LatLng(
      start.latitude + t * (end.latitude - start.latitude),
      start.longitude + t * (end.longitude - start.longitude),
    );

    return distance.as(LengthUnit.Meter, point, projection);
  }

  /// Simplifies a polyline using Douglas-Peucker algorithm.
  List<LatLng> simplifyPolyline(List<LatLng> points, {double tolerance = 5}) {
    if (points.length < 3) return points;

    // Find the point with the maximum distance from the line
    double maxDistance = 0;
    int maxIndex = 0;

    final first = points.first;
    final last = points.last;

    for (var i = 1; i < points.length - 1; i++) {
      final distance = _distanceToSegment(points[i], first, last);
      if (distance > maxDistance) {
        maxDistance = distance;
        maxIndex = i;
      }
    }

    // If max distance is greater than tolerance, recursively simplify
    if (maxDistance > tolerance) {
      final left = simplifyPolyline(
        points.sublist(0, maxIndex + 1),
        tolerance: tolerance,
      );
      final right = simplifyPolyline(
        points.sublist(maxIndex),
        tolerance: tolerance,
      );

      return [...left.sublist(0, left.length - 1), ...right];
    }

    return [first, last];
  }

  /// Encodes a polyline using Google's polyline algorithm.
  String encodePolyline(List<LatLng> points) {
    final result = StringBuffer();

    int plat = 0;
    int plng = 0;

    for (final point in points) {
      final lat = (point.latitude * 1e5).round();
      final lng = (point.longitude * 1e5).round();

      _encodeValue(lat - plat, result);
      _encodeValue(lng - plng, result);

      plat = lat;
      plng = lng;
    }

    return result.toString();
  }

  void _encodeValue(int value, StringBuffer result) {
    var v = value < 0 ? ~(value << 1) : (value << 1);

    while (v >= 0x20) {
      result.writeCharCode((0x20 | (v & 0x1f)) + 63);
      v >>= 5;
    }

    result.writeCharCode(v + 63);
  }

  /// Decodes a polyline encoded with Google's polyline algorithm.
  List<LatLng> decodePolyline(String encoded) {
    final points = <LatLng>[];
    var index = 0;
    var lat = 0;
    var lng = 0;

    while (index < encoded.length) {
      var shift = 0;
      var result = 0;

      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }
}
