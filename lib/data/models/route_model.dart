import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

import 'user_model.dart';
import 'waypoint_model.dart';

part 'route_model.freezed.dart';
part 'route_model.g.dart';

enum RouteSnapMode {
  @JsonValue('none')
  none,
  @JsonValue('roads')
  roads,
  @JsonValue('walking')
  walking,
  @JsonValue('manual')
  manual,
}

@freezed
class RouteModel with _$RouteModel {
  const RouteModel._();

  const factory RouteModel({
    required String id,
    required String tourId,
    required String versionId,
    required List<WaypointModel> waypoints,
    @LatLngListConverter() @Default([]) List<LatLng> routePolyline,
    @Default(RouteSnapMode.roads) RouteSnapMode snapMode,
    required double totalDistance,
    required int estimatedDuration,
    @Default({}) Map<String, dynamic> metadata,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _RouteModel;

  factory RouteModel.fromJson(Map<String, dynamic> json) =>
      _$RouteModelFromJson(json);

  factory RouteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RouteModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  /// Number of waypoints in this route
  int get waypointCount => waypoints.length;

  /// Number of stops (waypoints with content) in this route
  int get stopCount => waypoints.where((w) => w.isStop).length;

  /// Check if the route has any waypoints
  bool get hasWaypoints => waypoints.isNotEmpty;

  /// Check if the route has a polyline
  bool get hasPolyline => routePolyline.isNotEmpty;

  /// Get the starting point of the route
  LatLng? get startPoint => waypoints.isNotEmpty ? waypoints.first.location : null;

  /// Get the ending point of the route
  LatLng? get endPoint => waypoints.isNotEmpty ? waypoints.last.location : null;

  /// Format distance for display
  String get distanceFormatted {
    if (totalDistance < 1000) {
      return '${totalDistance.toStringAsFixed(0)}m';
    }
    return '${(totalDistance / 1000).toStringAsFixed(1)}km';
  }

  /// Format duration for display
  String get durationFormatted {
    final hours = estimatedDuration ~/ 3600;
    final minutes = (estimatedDuration % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  /// Get a short duration string
  String get durationShort {
    final hours = estimatedDuration ~/ 3600;
    final minutes = (estimatedDuration % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Check if route snapping is enabled
  bool get isSnappingEnabled =>
      snapMode == RouteSnapMode.roads || snapMode == RouteSnapMode.walking;

  /// Get the center point of the route (for map centering)
  LatLng? get centerPoint {
    if (waypoints.isEmpty) return null;

    double minLat = double.infinity;
    double maxLat = double.negativeInfinity;
    double minLng = double.infinity;
    double maxLng = double.negativeInfinity;

    for (final waypoint in waypoints) {
      final lat = waypoint.location.latitude;
      final lng = waypoint.location.longitude;
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    return LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
  }

  /// Get waypoints that have overlapping trigger radii.
  /// Returns a list of waypoint pairs that overlap.
  List<(WaypointModel, WaypointModel)> get overlappingWaypoints {
    final overlaps = <(WaypointModel, WaypointModel)>[];
    for (var i = 0; i < waypoints.length; i++) {
      for (var j = i + 1; j < waypoints.length; j++) {
        if (waypoints[i].hasOverlapWith(waypoints[j])) {
          overlaps.add((waypoints[i], waypoints[j]));
        }
      }
    }
    return overlaps;
  }

  /// Check if any waypoints have overlapping trigger radii
  bool get hasOverlappingWaypoints => overlappingWaypoints.isNotEmpty;
}

/// Converter for LatLng list to/from JSON.
class LatLngListConverter implements JsonConverter<List<LatLng>, List<dynamic>> {
  const LatLngListConverter();

  @override
  List<LatLng> fromJson(List<dynamic> json) {
    return json
        .map((e) => LatLng(
              (e['lat'] as num).toDouble(),
              (e['lng'] as num).toDouble(),
            ))
        .toList();
  }

  @override
  List<dynamic> toJson(List<LatLng> object) {
    return object
        .map((e) => {
              'lat': e.latitude,
              'lng': e.longitude,
            })
        .toList();
  }
}

extension RouteSnapModeExtension on RouteSnapMode {
  String get displayName {
    switch (this) {
      case RouteSnapMode.none:
        return 'No Snapping';
      case RouteSnapMode.roads:
        return 'Snap to Roads';
      case RouteSnapMode.walking:
        return 'Walking Path';
      case RouteSnapMode.manual:
        return 'Manual';
    }
  }

  String get description {
    switch (this) {
      case RouteSnapMode.none:
        return 'Direct lines between waypoints';
      case RouteSnapMode.roads:
        return 'Snap route to drivable roads';
      case RouteSnapMode.walking:
        return 'Snap to walking paths and sidewalks';
      case RouteSnapMode.manual:
        return 'Manually drawn route';
    }
  }
}
