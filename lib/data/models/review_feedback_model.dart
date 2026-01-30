import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart';

part 'review_feedback_model.freezed.dart';
part 'review_feedback_model.g.dart';

enum FeedbackType {
  @JsonValue('issue')
  issue,
  @JsonValue('suggestion')
  suggestion,
  @JsonValue('compliment')
  compliment,
  @JsonValue('required')
  required,
}

enum FeedbackPriority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

@freezed
class ReviewFeedbackModel with _$ReviewFeedbackModel {
  const ReviewFeedbackModel._();

  const factory ReviewFeedbackModel({
    required String id,
    required String submissionId,
    required String reviewerId,
    required String reviewerName,
    required FeedbackType type,
    required String message,
    String? stopId,
    String? stopName,
    @Default(FeedbackPriority.medium) FeedbackPriority priority,
    @Default(false) bool resolved,
    @NullableTimestampConverter() DateTime? resolvedAt,
    String? resolvedBy,
    String? resolutionNote,
    @TimestampConverter() required DateTime createdAt,
  }) = _ReviewFeedbackModel;

  factory ReviewFeedbackModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewFeedbackModelFromJson(json);

  factory ReviewFeedbackModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewFeedbackModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  /// Check if feedback is for a specific stop
  bool get isStopSpecific => stopId != null;

  /// Check if feedback is for the general tour
  bool get isGeneral => stopId == null;

  /// Check if this is a required change (must be addressed)
  bool get isRequired => type == FeedbackType.required;

  /// Check if this is a blocking issue
  bool get isBlocking => type == FeedbackType.required || type == FeedbackType.issue;

  /// Check if this can be ignored
  bool get canBeIgnored => type == FeedbackType.suggestion || type == FeedbackType.compliment;

  /// Get display name for type
  String get typeDisplay {
    switch (type) {
      case FeedbackType.issue:
        return 'Issue';
      case FeedbackType.suggestion:
        return 'Suggestion';
      case FeedbackType.compliment:
        return 'Compliment';
      case FeedbackType.required:
        return 'Required Change';
    }
  }

  /// Get icon name for type
  String get typeIcon {
    switch (type) {
      case FeedbackType.issue:
        return 'error';
      case FeedbackType.suggestion:
        return 'lightbulb';
      case FeedbackType.compliment:
        return 'thumb_up';
      case FeedbackType.required:
        return 'priority_high';
    }
  }

  /// Get color hex for type
  int get typeColorHex {
    switch (type) {
      case FeedbackType.issue:
        return 0xFFFF9800; // Orange
      case FeedbackType.suggestion:
        return 0xFF2196F3; // Blue
      case FeedbackType.compliment:
        return 0xFF4CAF50; // Green
      case FeedbackType.required:
        return 0xFFF44336; // Red
    }
  }

  /// Get formatted location string
  String get locationDisplay {
    if (isStopSpecific && stopName != null) {
      return 'Stop: $stopName';
    } else if (isStopSpecific) {
      return 'Specific Stop';
    }
    return 'General';
  }
}

extension FeedbackTypeExtension on FeedbackType {
  String get displayName {
    switch (this) {
      case FeedbackType.issue:
        return 'Issue';
      case FeedbackType.suggestion:
        return 'Suggestion';
      case FeedbackType.compliment:
        return 'Compliment';
      case FeedbackType.required:
        return 'Required Change';
    }
  }

  String get description {
    switch (this) {
      case FeedbackType.issue:
        return 'A problem that should be fixed';
      case FeedbackType.suggestion:
        return 'An optional improvement idea';
      case FeedbackType.compliment:
        return 'Positive feedback';
      case FeedbackType.required:
        return 'A change that must be made before approval';
    }
  }
}

extension FeedbackPriorityExtension on FeedbackPriority {
  String get displayName {
    switch (this) {
      case FeedbackPriority.low:
        return 'Low';
      case FeedbackPriority.medium:
        return 'Medium';
      case FeedbackPriority.high:
        return 'High';
      case FeedbackPriority.critical:
        return 'Critical';
    }
  }

  int get colorHex {
    switch (this) {
      case FeedbackPriority.low:
        return 0xFF9E9E9E; // Grey
      case FeedbackPriority.medium:
        return 0xFF2196F3; // Blue
      case FeedbackPriority.high:
        return 0xFFFF9800; // Orange
      case FeedbackPriority.critical:
        return 0xFFF44336; // Red
    }
  }
}
