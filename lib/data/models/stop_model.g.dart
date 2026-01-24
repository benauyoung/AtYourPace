// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stop_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StopModelImpl _$$StopModelImplFromJson(Map<String, dynamic> json) =>
    _$StopModelImpl(
      id: json['id'] as String,
      tourId: json['tourId'] as String,
      versionId: json['versionId'] as String,
      order: (json['order'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      location: const GeoPointConverter().fromJson(json['location']),
      geohash: json['geohash'] as String,
      triggerRadius: (json['triggerRadius'] as num?)?.toInt() ?? 30,
      media: json['media'] == null
          ? const StopMedia()
          : StopMedia.fromJson(json['media'] as Map<String, dynamic>),
      navigation: json['navigation'] == null
          ? null
          : StopNavigation.fromJson(json['navigation'] as Map<String, dynamic>),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$StopModelImplToJson(_$StopModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tourId': instance.tourId,
      'versionId': instance.versionId,
      'order': instance.order,
      'name': instance.name,
      'description': instance.description,
      'location': const GeoPointConverter().toJson(instance.location),
      'geohash': instance.geohash,
      'triggerRadius': instance.triggerRadius,
      'media': instance.media,
      'navigation': instance.navigation,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

_$StopMediaImpl _$$StopMediaImplFromJson(Map<String, dynamic> json) =>
    _$StopMediaImpl(
      audioUrl: json['audioUrl'] as String?,
      audioSource:
          $enumDecodeNullable(_$AudioSourceEnumMap, json['audioSource']) ??
              AudioSource.recorded,
      audioDuration: (json['audioDuration'] as num?)?.toInt(),
      audioText: json['audioText'] as String?,
      voiceId: json['voiceId'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => StopImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      videoUrl: json['videoUrl'] as String?,
    );

Map<String, dynamic> _$$StopMediaImplToJson(_$StopMediaImpl instance) =>
    <String, dynamic>{
      'audioUrl': instance.audioUrl,
      'audioSource': _$AudioSourceEnumMap[instance.audioSource]!,
      'audioDuration': instance.audioDuration,
      'audioText': instance.audioText,
      'voiceId': instance.voiceId,
      'images': instance.images,
      'videoUrl': instance.videoUrl,
    };

const _$AudioSourceEnumMap = {
  AudioSource.recorded: 'recorded',
  AudioSource.elevenlabs: 'elevenlabs',
  AudioSource.uploaded: 'uploaded',
};

_$StopImageImpl _$$StopImageImplFromJson(Map<String, dynamic> json) =>
    _$StopImageImpl(
      url: json['url'] as String,
      caption: json['caption'] as String?,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$StopImageImplToJson(_$StopImageImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'caption': instance.caption,
      'order': instance.order,
    };

_$StopNavigationImpl _$$StopNavigationImplFromJson(Map<String, dynamic> json) =>
    _$StopNavigationImpl(
      arrivalInstruction: json['arrivalInstruction'] as String?,
      parkingInfo: json['parkingInfo'] as String?,
      direction: json['direction'] as String?,
    );

Map<String, dynamic> _$$StopNavigationImplToJson(
        _$StopNavigationImpl instance) =>
    <String, dynamic>{
      'arrivalInstruction': instance.arrivalInstruction,
      'parkingInfo': instance.parkingInfo,
      'direction': instance.direction,
    };
