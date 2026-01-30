// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RouteModelImpl _$$RouteModelImplFromJson(Map<String, dynamic> json) =>
    _$RouteModelImpl(
      id: json['id'] as String,
      tourId: json['tourId'] as String,
      versionId: json['versionId'] as String,
      waypoints: (json['waypoints'] as List<dynamic>)
          .map((e) => WaypointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      routePolyline: json['routePolyline'] == null
          ? const []
          : const LatLngListConverter().fromJson(json['routePolyline'] as List),
      snapMode: $enumDecodeNullable(_$RouteSnapModeEnumMap, json['snapMode']) ??
          RouteSnapMode.roads,
      totalDistance: (json['totalDistance'] as num).toDouble(),
      estimatedDuration: (json['estimatedDuration'] as num).toInt(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$RouteModelImplToJson(_$RouteModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tourId': instance.tourId,
      'versionId': instance.versionId,
      'waypoints': instance.waypoints,
      'routePolyline':
          const LatLngListConverter().toJson(instance.routePolyline),
      'snapMode': _$RouteSnapModeEnumMap[instance.snapMode]!,
      'totalDistance': instance.totalDistance,
      'estimatedDuration': instance.estimatedDuration,
      'metadata': instance.metadata,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

const _$RouteSnapModeEnumMap = {
  RouteSnapMode.none: 'none',
  RouteSnapMode.roads: 'roads',
  RouteSnapMode.walking: 'walking',
  RouteSnapMode.manual: 'manual',
};
