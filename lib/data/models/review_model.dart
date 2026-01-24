import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart';

part 'review_model.freezed.dart';
part 'review_model.g.dart';

@freezed
class ReviewModel with _$ReviewModel {
  const ReviewModel._();

  const factory ReviewModel({
    required String id,
    required String tourId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required int rating,
    String? comment,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _ReviewModel;

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);

  factory ReviewModel.fromFirestore(
    DocumentSnapshot doc, {
    required String tourId,
  }) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel.fromJson({
      'id': doc.id,
      'tourId': tourId,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json.remove('tourId');
    return json;
  }

  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()} year${(diff.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()} month${(diff.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    }
    return 'Just now';
  }
}

/// Model for the admin review queue
@freezed
class ReviewQueueItem with _$ReviewQueueItem {
  const ReviewQueueItem._();

  const factory ReviewQueueItem({
    required String id,
    required String tourId,
    required String versionId,
    required String creatorId,
    required String creatorName,
    required String tourTitle,
    @TimestampConverter() required DateTime submittedAt,
    @Default(ReviewQueueStatus.pending) ReviewQueueStatus status,
    String? assignedTo,
    @Default(0) int priority,
    String? notes,
  }) = _ReviewQueueItem;

  factory ReviewQueueItem.fromJson(Map<String, dynamic> json) =>
      _$ReviewQueueItemFromJson(json);

  factory ReviewQueueItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewQueueItem.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }
}

enum ReviewQueueStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_review')
  inReview,
  @JsonValue('completed')
  completed,
}

extension ReviewQueueStatusExtension on ReviewQueueStatus {
  String get displayName {
    switch (this) {
      case ReviewQueueStatus.pending:
        return 'Pending';
      case ReviewQueueStatus.inReview:
        return 'In Review';
      case ReviewQueueStatus.completed:
        return 'Completed';
    }
  }
}
