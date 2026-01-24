// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_version_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TourVersionModelImpl _$$TourVersionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TourVersionModelImpl(
      id: json['id'] as String,
      tourId: json['tourId'] as String,
      versionNumber: (json['versionNumber'] as num).toInt(),
      versionType:
          $enumDecodeNullable(_$VersionTypeEnumMap, json['versionType']) ??
              VersionType.draft,
      title: json['title'] as String,
      description: json['description'] as String,
      coverImageUrl: json['coverImageUrl'] as String?,
      duration: json['duration'] as String?,
      distance: json['distance'] as String?,
      difficulty:
          $enumDecodeNullable(_$TourDifficultyEnumMap, json['difficulty']) ??
              TourDifficulty.moderate,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      route: json['route'] == null
          ? null
          : TourRoute.fromJson(json['route'] as Map<String, dynamic>),
      submittedAt:
          const NullableTimestampConverter().fromJson(json['submittedAt']),
      reviewedAt:
          const NullableTimestampConverter().fromJson(json['reviewedAt']),
      reviewedBy: json['reviewedBy'] as String?,
      reviewNotes: json['reviewNotes'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$TourVersionModelImplToJson(
        _$TourVersionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tourId': instance.tourId,
      'versionNumber': instance.versionNumber,
      'versionType': _$VersionTypeEnumMap[instance.versionType]!,
      'title': instance.title,
      'description': instance.description,
      'coverImageUrl': instance.coverImageUrl,
      'duration': instance.duration,
      'distance': instance.distance,
      'difficulty': _$TourDifficultyEnumMap[instance.difficulty]!,
      'languages': instance.languages,
      'route': instance.route,
      'submittedAt':
          const NullableTimestampConverter().toJson(instance.submittedAt),
      'reviewedAt':
          const NullableTimestampConverter().toJson(instance.reviewedAt),
      'reviewedBy': instance.reviewedBy,
      'reviewNotes': instance.reviewNotes,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

const _$VersionTypeEnumMap = {
  VersionType.draft: 'draft',
  VersionType.live: 'live',
  VersionType.archived: 'archived',
};

const _$TourDifficultyEnumMap = {
  TourDifficulty.easy: 'easy',
  TourDifficulty.moderate: 'moderate',
  TourDifficulty.challenging: 'challenging',
};

_$TourRouteImpl _$$TourRouteImplFromJson(Map<String, dynamic> json) =>
    _$TourRouteImpl(
      encodedPolyline: json['encodedPolyline'] as String?,
      boundingBox: json['boundingBox'] == null
          ? null
          : BoundingBox.fromJson(json['boundingBox'] as Map<String, dynamic>),
      waypoints: (json['waypoints'] as List<dynamic>?)
              ?.map((e) => RouteWaypoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$TourRouteImplToJson(_$TourRouteImpl instance) =>
    <String, dynamic>{
      'encodedPolyline': instance.encodedPolyline,
      'boundingBox': instance.boundingBox,
      'waypoints': instance.waypoints,
    };

_$BoundingBoxImpl _$$BoundingBoxImplFromJson(Map<String, dynamic> json) =>
    _$BoundingBoxImpl(
      northeast: const GeoPointConverter().fromJson(json['northeast']),
      southwest: const GeoPointConverter().fromJson(json['southwest']),
    );

Map<String, dynamic> _$$BoundingBoxImplToJson(_$BoundingBoxImpl instance) =>
    <String, dynamic>{
      'northeast': const GeoPointConverter().toJson(instance.northeast),
      'southwest': const GeoPointConverter().toJson(instance.southwest),
    };

_$RouteWaypointImpl _$$RouteWaypointImplFromJson(Map<String, dynamic> json) =>
    _$RouteWaypointImpl(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );

Map<String, dynamic> _$$RouteWaypointImplToJson(_$RouteWaypointImpl instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
    };
