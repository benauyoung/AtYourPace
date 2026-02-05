// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TourModelImpl _$$TourModelImplFromJson(Map<String, dynamic> json) =>
    _$TourModelImpl(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String,
      slug: json['slug'] as String?,
      category: $enumDecode(_$TourCategoryEnumMap, json['category']),
      tourType: $enumDecode(_$TourTypeEnumMap, json['tourType']),
      status: $enumDecodeNullable(_$TourStatusEnumMap, json['status']) ??
          TourStatus.draft,
      featured: json['featured'] as bool? ?? false,
      startLocation: const GeoPointConverter().fromJson(json['startLocation']),
      geohash: json['geohash'] as String,
      city: json['city'] as String?,
      region: json['region'] as String?,
      country: json['country'] as String?,
      draftTitle: json['draftTitle'] as String?,
      liveVersionId: json['liveVersionId'] as String?,
      liveVersion: (json['liveVersion'] as num?)?.toInt(),
      draftVersionId: json['draftVersionId'] as String,
      draftVersion: (json['draftVersion'] as num).toInt(),
      stats: json['stats'] == null
          ? const TourStats()
          : TourStats.fromJson(json['stats'] as Map<String, dynamic>),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      publishedAt:
          const NullableTimestampConverter().fromJson(json['publishedAt']),
      lastReviewedAt:
          const NullableTimestampConverter().fromJson(json['lastReviewedAt']),
    );

Map<String, dynamic> _$$TourModelImplToJson(_$TourModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creatorId': instance.creatorId,
      'creatorName': instance.creatorName,
      'slug': instance.slug,
      'category': _$TourCategoryEnumMap[instance.category]!,
      'tourType': _$TourTypeEnumMap[instance.tourType]!,
      'status': _$TourStatusEnumMap[instance.status]!,
      'featured': instance.featured,
      'startLocation': const GeoPointConverter().toJson(instance.startLocation),
      'geohash': instance.geohash,
      'city': instance.city,
      'region': instance.region,
      'country': instance.country,
      'draftTitle': instance.draftTitle,
      'liveVersionId': instance.liveVersionId,
      'liveVersion': instance.liveVersion,
      'draftVersionId': instance.draftVersionId,
      'draftVersion': instance.draftVersion,
      'stats': instance.stats,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'publishedAt':
          const NullableTimestampConverter().toJson(instance.publishedAt),
      'lastReviewedAt':
          const NullableTimestampConverter().toJson(instance.lastReviewedAt),
    };

const _$TourCategoryEnumMap = {
  TourCategory.history: 'history',
  TourCategory.nature: 'nature',
  TourCategory.ghost: 'ghost',
  TourCategory.food: 'food',
  TourCategory.art: 'art',
  TourCategory.architecture: 'architecture',
  TourCategory.other: 'other',
};

const _$TourTypeEnumMap = {
  TourType.walking: 'walking',
  TourType.driving: 'driving',
};

const _$TourStatusEnumMap = {
  TourStatus.draft: 'draft',
  TourStatus.pendingReview: 'pending_review',
  TourStatus.approved: 'approved',
  TourStatus.rejected: 'rejected',
  TourStatus.hidden: 'hidden',
};

_$TourStatsImpl _$$TourStatsImplFromJson(Map<String, dynamic> json) =>
    _$TourStatsImpl(
      totalPlays: (json['totalPlays'] as num?)?.toInt() ?? 0,
      totalDownloads: (json['totalDownloads'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: (json['totalRatings'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TourStatsImplToJson(_$TourStatsImpl instance) =>
    <String, dynamic>{
      'totalPlays': instance.totalPlays,
      'totalDownloads': instance.totalDownloads,
      'averageRating': instance.averageRating,
      'totalRatings': instance.totalRatings,
      'totalRevenue': instance.totalRevenue,
    };
