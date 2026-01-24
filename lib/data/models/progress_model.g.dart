// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TourProgressModelImpl _$$TourProgressModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TourProgressModelImpl(
      id: json['id'] as String,
      tourId: json['tourId'] as String,
      userId: json['userId'] as String,
      versionId: json['versionId'] as String,
      status:
          $enumDecodeNullable(_$TourProgressStatusEnumMap, json['status']) ??
              TourProgressStatus.notStarted,
      currentStopIndex: (json['currentStopIndex'] as num?)?.toInt() ?? 0,
      completedStops: (json['completedStops'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      startedAt: const NullableTimestampConverter().fromJson(json['startedAt']),
      completedAt:
          const NullableTimestampConverter().fromJson(json['completedAt']),
      totalTimeSpent: (json['totalTimeSpent'] as num?)?.toInt() ?? 0,
      lastPlayedAt: const TimestampConverter().fromJson(json['lastPlayedAt']),
    );

Map<String, dynamic> _$$TourProgressModelImplToJson(
        _$TourProgressModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tourId': instance.tourId,
      'userId': instance.userId,
      'versionId': instance.versionId,
      'status': _$TourProgressStatusEnumMap[instance.status]!,
      'currentStopIndex': instance.currentStopIndex,
      'completedStops': instance.completedStops,
      'startedAt':
          const NullableTimestampConverter().toJson(instance.startedAt),
      'completedAt':
          const NullableTimestampConverter().toJson(instance.completedAt),
      'totalTimeSpent': instance.totalTimeSpent,
      'lastPlayedAt': const TimestampConverter().toJson(instance.lastPlayedAt),
    };

const _$TourProgressStatusEnumMap = {
  TourProgressStatus.notStarted: 'not_started',
  TourProgressStatus.inProgress: 'in_progress',
  TourProgressStatus.completed: 'completed',
};

_$DownloadedTourModelImpl _$$DownloadedTourModelImplFromJson(
        Map<String, dynamic> json) =>
    _$DownloadedTourModelImpl(
      id: json['id'] as String,
      tourId: json['tourId'] as String,
      versionId: json['versionId'] as String,
      userId: json['userId'] as String,
      downloadedAt: const TimestampConverter().fromJson(json['downloadedAt']),
      expiresAt: const TimestampConverter().fromJson(json['expiresAt']),
      fileSize: (json['fileSize'] as num).toInt(),
      status: $enumDecodeNullable(_$DownloadStatusEnumMap, json['status']) ??
          DownloadStatus.complete,
      localPaths: (json['localPaths'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$$DownloadedTourModelImplToJson(
        _$DownloadedTourModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tourId': instance.tourId,
      'versionId': instance.versionId,
      'userId': instance.userId,
      'downloadedAt': const TimestampConverter().toJson(instance.downloadedAt),
      'expiresAt': const TimestampConverter().toJson(instance.expiresAt),
      'fileSize': instance.fileSize,
      'status': _$DownloadStatusEnumMap[instance.status]!,
      'localPaths': instance.localPaths,
    };

const _$DownloadStatusEnumMap = {
  DownloadStatus.downloading: 'downloading',
  DownloadStatus.complete: 'complete',
  DownloadStatus.failed: 'failed',
};
