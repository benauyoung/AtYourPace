// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publishing_submission_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PublishingSubmissionModelImpl _$$PublishingSubmissionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PublishingSubmissionModelImpl(
      id: json['id'] as String,
      tourId: json['tourId'] as String,
      versionId: json['versionId'] as String,
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String,
      status: $enumDecode(_$SubmissionStatusEnumMap, json['status']),
      submittedAt: const TimestampConverter().fromJson(json['submittedAt']),
      reviewedAt:
          const NullableTimestampConverter().fromJson(json['reviewedAt']),
      reviewerId: json['reviewerId'] as String?,
      reviewerName: json['reviewerName'] as String?,
      feedback: (json['feedback'] as List<dynamic>?)
              ?.map((e) =>
                  ReviewFeedbackModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      rejectionReason: json['rejectionReason'] as String?,
      resubmissionJustification: json['resubmissionJustification'] as String?,
      resubmissionCount: (json['resubmissionCount'] as num?)?.toInt() ?? 0,
      creatorIgnoredSuggestions:
          json['creatorIgnoredSuggestions'] as bool? ?? false,
      tourTitle: json['tourTitle'] as String?,
      tourDescription: json['tourDescription'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$PublishingSubmissionModelImplToJson(
        _$PublishingSubmissionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tourId': instance.tourId,
      'versionId': instance.versionId,
      'creatorId': instance.creatorId,
      'creatorName': instance.creatorName,
      'status': _$SubmissionStatusEnumMap[instance.status]!,
      'submittedAt': const TimestampConverter().toJson(instance.submittedAt),
      'reviewedAt':
          const NullableTimestampConverter().toJson(instance.reviewedAt),
      'reviewerId': instance.reviewerId,
      'reviewerName': instance.reviewerName,
      'feedback': instance.feedback,
      'rejectionReason': instance.rejectionReason,
      'resubmissionJustification': instance.resubmissionJustification,
      'resubmissionCount': instance.resubmissionCount,
      'creatorIgnoredSuggestions': instance.creatorIgnoredSuggestions,
      'tourTitle': instance.tourTitle,
      'tourDescription': instance.tourDescription,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

const _$SubmissionStatusEnumMap = {
  SubmissionStatus.draft: 'draft',
  SubmissionStatus.submitted: 'submitted',
  SubmissionStatus.underReview: 'under_review',
  SubmissionStatus.changesRequested: 'changes_requested',
  SubmissionStatus.approved: 'approved',
  SubmissionStatus.rejected: 'rejected',
  SubmissionStatus.withdrawn: 'withdrawn',
};
