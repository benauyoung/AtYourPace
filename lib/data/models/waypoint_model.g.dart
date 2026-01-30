// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waypoint_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WaypointModelImpl _$$WaypointModelImplFromJson(Map<String, dynamic> json) =>
    _$WaypointModelImpl(
      id: json['id'] as String,
      routeId: json['routeId'] as String,
      order: (json['order'] as num).toInt(),
      location: const LatLngConverter()
          .fromJson(json['location'] as Map<String, dynamic>),
      name: json['name'] as String,
      triggerRadius: (json['triggerRadius'] as num?)?.toInt() ?? 30,
      type: $enumDecodeNullable(_$WaypointTypeEnumMap, json['type']) ??
          WaypointType.stop,
      stopId: json['stopId'] as String?,
      manualPosition: json['manualPosition'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$WaypointModelImplToJson(_$WaypointModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'routeId': instance.routeId,
      'order': instance.order,
      'location': const LatLngConverter().toJson(instance.location),
      'name': instance.name,
      'triggerRadius': instance.triggerRadius,
      'type': _$WaypointTypeEnumMap[instance.type]!,
      'stopId': instance.stopId,
      'manualPosition': instance.manualPosition,
      'metadata': instance.metadata,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

const _$WaypointTypeEnumMap = {
  WaypointType.stop: 'stop',
  WaypointType.waypoint: 'waypoint',
  WaypointType.poi: 'poi',
};
