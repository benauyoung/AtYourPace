import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

import 'user_model.dart';

part 'waypoint_model.freezed.dart';
part 'waypoint_model.g.dart';

enum WaypointType {
  @JsonValue('stop')
  stop,
  @JsonValue('waypoint')
  waypoint,
  @JsonValue('poi')
  poi,
}

@freezed
class WaypointModel with _$WaypointModel {
  const WaypointModel._();

  const factory WaypointModel({
    required String id,
    required String routeId,
    required int order,
    @LatLngConverter() required LatLng location,
    required String name,
    @Default(30) int triggerRadius,
    @Default(WaypointType.stop) WaypointType type,
    String? stopId,
    @Default(false) bool manualPosition,
    @Default({}) Map<String, dynamic> metadata,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _WaypointModel;

  factory WaypointModel.fromJson(Map<String, dynamic> json) =>
      _$WaypointModelFromJson(json);

  factory WaypointModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WaypointModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  bool get isStop => type == WaypointType.stop;
  bool get isWaypoint => type == WaypointType.waypoint;
  bool get isPoi => type == WaypointType.poi;
  bool get hasLinkedStop => stopId != null;

  double get latitude => location.latitude;
  double get longitude => location.longitude;

  /// Returns color code for trigger radius visualization
  /// Green: small, precise triggers
  /// Yellow: medium triggers
  /// Orange: larger triggers
  /// Red: very large triggers
  String get radiusColor {
    if (triggerRadius <= 50) return 'green';
    if (triggerRadius <= 100) return 'yellow';
    if (triggerRadius <= 200) return 'orange';
    return 'red';
  }

  /// Returns hex color for trigger radius visualization
  int get radiusColorHex {
    if (triggerRadius <= 50) return 0xFF4CAF50; // Green
    if (triggerRadius <= 100) return 0xFFFFEB3B; // Yellow
    if (triggerRadius <= 200) return 0xFFFF9800; // Orange
    return 0xFFF44336; // Red
  }

  /// Check if this waypoint's trigger radius overlaps with another
  bool hasOverlapWith(WaypointModel other) {
    final distance = const Distance().as(
      LengthUnit.Meter,
      location,
      other.location,
    );
    return distance < (triggerRadius + other.triggerRadius);
  }

  /// Check if this waypoint is too close to another (within minimum distance)
  bool isTooCloseTo(WaypointModel other, {double minDistance = 20}) {
    final distance = const Distance().as(
      LengthUnit.Meter,
      location,
      other.location,
    );
    return distance < minDistance;
  }

  /// Calculate distance to another waypoint in meters
  double distanceTo(WaypointModel other) {
    return const Distance().as(
      LengthUnit.Meter,
      location,
      other.location,
    );
  }

  /// Calculate distance to a location in meters
  double distanceToLocation(LatLng otherLocation) {
    return const Distance().as(
      LengthUnit.Meter,
      location,
      otherLocation,
    );
  }
}

/// Converter for LatLng to/from JSON
class LatLngConverter implements JsonConverter<LatLng, Map<String, dynamic>> {
  const LatLngConverter();

  @override
  LatLng fromJson(Map<String, dynamic> json) {
    return LatLng(
      (json['lat'] as num).toDouble(),
      (json['lng'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson(LatLng object) {
    return {
      'lat': object.latitude,
      'lng': object.longitude,
    };
  }
}

/// Converter for nullable LatLng
class NullableLatLngConverter
    implements JsonConverter<LatLng?, Map<String, dynamic>?> {
  const NullableLatLngConverter();

  @override
  LatLng? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return LatLng(
      (json['lat'] as num).toDouble(),
      (json['lng'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic>? toJson(LatLng? object) {
    if (object == null) return null;
    return {
      'lat': object.latitude,
      'lng': object.longitude,
    };
  }
}

extension WaypointTypeExtension on WaypointType {
  String get displayName {
    switch (this) {
      case WaypointType.stop:
        return 'Stop';
      case WaypointType.waypoint:
        return 'Waypoint';
      case WaypointType.poi:
        return 'Point of Interest';
    }
  }

  String get description {
    switch (this) {
      case WaypointType.stop:
        return 'A main stop with audio content';
      case WaypointType.waypoint:
        return 'A navigation point (no content)';
      case WaypointType.poi:
        return 'A point of interest marker';
    }
  }
}
