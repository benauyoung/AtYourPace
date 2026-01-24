import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart';

part 'progress_model.freezed.dart';
part 'progress_model.g.dart';

enum TourProgressStatus {
  @JsonValue('not_started')
  notStarted,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
}

@freezed
class TourProgressModel with _$TourProgressModel {
  const TourProgressModel._();

  const factory TourProgressModel({
    required String id,
    required String tourId,
    required String userId,
    required String versionId,
    @Default(TourProgressStatus.notStarted) TourProgressStatus status,
    @Default(0) int currentStopIndex,
    @Default([]) List<String> completedStops,
    @NullableTimestampConverter() DateTime? startedAt,
    @NullableTimestampConverter() DateTime? completedAt,
    @Default(0) int totalTimeSpent,
    @TimestampConverter() required DateTime lastPlayedAt,
  }) = _TourProgressModel;

  factory TourProgressModel.fromJson(Map<String, dynamic> json) =>
      _$TourProgressModelFromJson(json);

  factory TourProgressModel.fromFirestore(
    DocumentSnapshot doc, {
    required String userId,
  }) {
    final data = doc.data() as Map<String, dynamic>;
    return TourProgressModel.fromJson({
      'id': doc.id,
      'userId': userId,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json.remove('userId');
    return json;
  }

  bool get isCompleted => status == TourProgressStatus.completed;
  bool get isInProgress => status == TourProgressStatus.inProgress;
  bool get isNotStarted => status == TourProgressStatus.notStarted;

  double progressPercentage(int totalStops) {
    if (totalStops == 0) return 0;
    return completedStops.length / totalStops;
  }
}

@freezed
class DownloadedTourModel with _$DownloadedTourModel {
  const DownloadedTourModel._();

  const factory DownloadedTourModel({
    required String id,
    required String tourId,
    required String versionId,
    required String userId,
    @TimestampConverter() required DateTime downloadedAt,
    @TimestampConverter() required DateTime expiresAt,
    required int fileSize,
    @Default(DownloadStatus.complete) DownloadStatus status,
    @Default({}) Map<String, String> localPaths,
  }) = _DownloadedTourModel;

  factory DownloadedTourModel.fromJson(Map<String, dynamic> json) =>
      _$DownloadedTourModelFromJson(json);

  factory DownloadedTourModel.fromFirestore(
    DocumentSnapshot doc, {
    required String userId,
  }) {
    final data = doc.data() as Map<String, dynamic>;
    return DownloadedTourModel.fromJson({
      'id': doc.id,
      'userId': userId,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json.remove('userId');
    json.remove('localPaths');
    return json;
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isComplete => status == DownloadStatus.complete;
  bool get isDownloading => status == DownloadStatus.downloading;

  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

enum DownloadStatus {
  @JsonValue('downloading')
  downloading,
  @JsonValue('complete')
  complete,
  @JsonValue('failed')
  failed,
}

extension DownloadStatusExtension on DownloadStatus {
  String get displayName {
    switch (this) {
      case DownloadStatus.downloading:
        return 'Downloading';
      case DownloadStatus.complete:
        return 'Downloaded';
      case DownloadStatus.failed:
        return 'Failed';
    }
  }
}

extension TourProgressStatusExtension on TourProgressStatus {
  String get displayName {
    switch (this) {
      case TourProgressStatus.notStarted:
        return 'Not Started';
      case TourProgressStatus.inProgress:
        return 'In Progress';
      case TourProgressStatus.completed:
        return 'Completed';
    }
  }
}
