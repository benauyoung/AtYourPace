// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewModelImpl _$$ReviewModelImplFromJson(Map<String, dynamic> json) =>
    _$ReviewModelImpl(
      id: json['id'] as String,
      tourId: json['tourId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userPhotoUrl: json['userPhotoUrl'] as String?,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$ReviewModelImplToJson(_$ReviewModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tourId': instance.tourId,
      'userId': instance.userId,
      'userName': instance.userName,
      'userPhotoUrl': instance.userPhotoUrl,
      'rating': instance.rating,
      'comment': instance.comment,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

_$ReviewQueueItemImpl _$$ReviewQueueItemImplFromJson(
        Map<String, dynamic> json) =>
    _$ReviewQueueItemImpl(
      id: json['id'] as String,
      tourId: json['tourId'] as String,
      versionId: json['versionId'] as String,
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String,
      tourTitle: json['tourTitle'] as String,
      submittedAt: const TimestampConverter().fromJson(json['submittedAt']),
      status: $enumDecodeNullable(_$ReviewQueueStatusEnumMap, json['status']) ??
          ReviewQueueStatus.pending,
      assignedTo: json['assignedTo'] as String?,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$ReviewQueueItemImplToJson(
        _$ReviewQueueItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tourId': instance.tourId,
      'versionId': instance.versionId,
      'creatorId': instance.creatorId,
      'creatorName': instance.creatorName,
      'tourTitle': instance.tourTitle,
      'submittedAt': const TimestampConverter().toJson(instance.submittedAt),
      'status': _$ReviewQueueStatusEnumMap[instance.status]!,
      'assignedTo': instance.assignedTo,
      'priority': instance.priority,
      'notes': instance.notes,
    };

const _$ReviewQueueStatusEnumMap = {
  ReviewQueueStatus.pending: 'pending',
  ReviewQueueStatus.inReview: 'in_review',
  ReviewQueueStatus.completed: 'completed',
};
