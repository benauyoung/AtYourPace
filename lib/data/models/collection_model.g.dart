// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CollectionModelImpl _$$CollectionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CollectionModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      coverImageUrl: json['coverImageUrl'] as String?,
      tourIds:
          (json['tourIds'] as List<dynamic>).map((e) => e as String).toList(),
      isCurated: json['isCurated'] as bool? ?? true,
      curatorId: json['curatorId'] as String?,
      curatorName: json['curatorName'] as String?,
      isFeatured: json['isFeatured'] as bool? ?? false,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      type: $enumDecodeNullable(_$CollectionTypeEnumMap, json['type']) ??
          CollectionType.geographic,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      city: json['city'] as String?,
      region: json['region'] as String?,
      country: json['country'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$CollectionModelImplToJson(
        _$CollectionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'coverImageUrl': instance.coverImageUrl,
      'tourIds': instance.tourIds,
      'isCurated': instance.isCurated,
      'curatorId': instance.curatorId,
      'curatorName': instance.curatorName,
      'isFeatured': instance.isFeatured,
      'tags': instance.tags,
      'type': _$CollectionTypeEnumMap[instance.type]!,
      'sortOrder': instance.sortOrder,
      'city': instance.city,
      'region': instance.region,
      'country': instance.country,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

const _$CollectionTypeEnumMap = {
  CollectionType.geographic: 'geographic',
  CollectionType.thematic: 'thematic',
  CollectionType.seasonal: 'seasonal',
  CollectionType.custom: 'custom',
};
