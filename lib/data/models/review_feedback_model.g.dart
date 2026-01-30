// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_feedback_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewFeedbackModelImpl _$$ReviewFeedbackModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ReviewFeedbackModelImpl(
      id: json['id'] as String,
      submissionId: json['submissionId'] as String,
      reviewerId: json['reviewerId'] as String,
      reviewerName: json['reviewerName'] as String,
      type: $enumDecode(_$FeedbackTypeEnumMap, json['type']),
      message: json['message'] as String,
      stopId: json['stopId'] as String?,
      stopName: json['stopName'] as String?,
      priority:
          $enumDecodeNullable(_$FeedbackPriorityEnumMap, json['priority']) ??
              FeedbackPriority.medium,
      resolved: json['resolved'] as bool? ?? false,
      resolvedAt:
          const NullableTimestampConverter().fromJson(json['resolvedAt']),
      resolvedBy: json['resolvedBy'] as String?,
      resolutionNote: json['resolutionNote'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$$ReviewFeedbackModelImplToJson(
        _$ReviewFeedbackModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'submissionId': instance.submissionId,
      'reviewerId': instance.reviewerId,
      'reviewerName': instance.reviewerName,
      'type': _$FeedbackTypeEnumMap[instance.type]!,
      'message': instance.message,
      'stopId': instance.stopId,
      'stopName': instance.stopName,
      'priority': _$FeedbackPriorityEnumMap[instance.priority]!,
      'resolved': instance.resolved,
      'resolvedAt':
          const NullableTimestampConverter().toJson(instance.resolvedAt),
      'resolvedBy': instance.resolvedBy,
      'resolutionNote': instance.resolutionNote,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };

const _$FeedbackTypeEnumMap = {
  FeedbackType.issue: 'issue',
  FeedbackType.suggestion: 'suggestion',
  FeedbackType.compliment: 'compliment',
  FeedbackType.required: 'required',
};

const _$FeedbackPriorityEnumMap = {
  FeedbackPriority.low: 'low',
  FeedbackPriority.medium: 'medium',
  FeedbackPriority.high: 'high',
  FeedbackPriority.critical: 'critical',
};
