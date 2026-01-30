import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'review_feedback_model.dart';
import 'user_model.dart';

part 'publishing_submission_model.freezed.dart';
part 'publishing_submission_model.g.dart';

enum SubmissionStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('submitted')
  submitted,
  @JsonValue('under_review')
  underReview,
  @JsonValue('changes_requested')
  changesRequested,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('withdrawn')
  withdrawn,
}

@freezed
class PublishingSubmissionModel with _$PublishingSubmissionModel {
  const PublishingSubmissionModel._();

  const factory PublishingSubmissionModel({
    required String id,
    required String tourId,
    required String versionId,
    required String creatorId,
    required String creatorName,
    required SubmissionStatus status,
    @TimestampConverter() required DateTime submittedAt,
    @NullableTimestampConverter() DateTime? reviewedAt,
    String? reviewerId,
    String? reviewerName,
    @Default([]) List<ReviewFeedbackModel> feedback,
    String? rejectionReason,
    String? resubmissionJustification,
    @Default(0) int resubmissionCount,
    @Default(false) bool creatorIgnoredSuggestions,
    String? tourTitle,
    String? tourDescription,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _PublishingSubmissionModel;

  factory PublishingSubmissionModel.fromJson(Map<String, dynamic> json) =>
      _$PublishingSubmissionModelFromJson(json);

  factory PublishingSubmissionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PublishingSubmissionModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  /// Check if submission is awaiting review
  bool get isPending =>
      status == SubmissionStatus.submitted ||
      status == SubmissionStatus.underReview;

  /// Check if submission is approved
  bool get isApproved => status == SubmissionStatus.approved;

  /// Check if submission is rejected
  bool get isRejected => status == SubmissionStatus.rejected;

  /// Check if changes are requested
  bool get needsChanges => status == SubmissionStatus.changesRequested;

  /// Check if submission is still a draft
  bool get isDraft => status == SubmissionStatus.draft;

  /// Check if submission was withdrawn
  bool get isWithdrawn => status == SubmissionStatus.withdrawn;

  /// Check if submission is in a final state
  bool get isFinal =>
      status == SubmissionStatus.approved ||
      status == SubmissionStatus.rejected ||
      status == SubmissionStatus.withdrawn;

  /// Check if this is a resubmission
  bool get isResubmission => resubmissionCount > 0;

  /// Check if submission has any feedback
  bool get hasFeedback => feedback.isNotEmpty;

  /// Get unresolved feedback items
  List<ReviewFeedbackModel> get unresolvedFeedback =>
      feedback.where((f) => !f.resolved).toList();

  /// Get required feedback items
  List<ReviewFeedbackModel> get requiredFeedback =>
      feedback.where((f) => f.isRequired).toList();

  /// Get unresolved required feedback
  List<ReviewFeedbackModel> get unresolvedRequiredFeedback =>
      feedback.where((f) => f.isRequired && !f.resolved).toList();

  /// Check if all required feedback is resolved
  bool get allRequiredResolved => unresolvedRequiredFeedback.isEmpty;

  /// Get feedback count by type
  int feedbackCountByType(FeedbackType type) =>
      feedback.where((f) => f.type == type).length;

  /// Get status display name
  String get statusDisplay {
    switch (status) {
      case SubmissionStatus.draft:
        return 'Draft';
      case SubmissionStatus.submitted:
        return 'Submitted';
      case SubmissionStatus.underReview:
        return 'Under Review';
      case SubmissionStatus.changesRequested:
        return 'Changes Requested';
      case SubmissionStatus.approved:
        return 'Approved';
      case SubmissionStatus.rejected:
        return 'Rejected';
      case SubmissionStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  /// Get status color hex
  int get statusColorHex {
    switch (status) {
      case SubmissionStatus.draft:
        return 0xFF9E9E9E; // Grey
      case SubmissionStatus.submitted:
        return 0xFF2196F3; // Blue
      case SubmissionStatus.underReview:
        return 0xFFFF9800; // Orange
      case SubmissionStatus.changesRequested:
        return 0xFFFFEB3B; // Yellow
      case SubmissionStatus.approved:
        return 0xFF4CAF50; // Green
      case SubmissionStatus.rejected:
        return 0xFFF44336; // Red
      case SubmissionStatus.withdrawn:
        return 0xFF795548; // Brown
    }
  }

  /// Get status icon name
  String get statusIcon {
    switch (status) {
      case SubmissionStatus.draft:
        return 'edit';
      case SubmissionStatus.submitted:
        return 'send';
      case SubmissionStatus.underReview:
        return 'visibility';
      case SubmissionStatus.changesRequested:
        return 'feedback';
      case SubmissionStatus.approved:
        return 'check_circle';
      case SubmissionStatus.rejected:
        return 'cancel';
      case SubmissionStatus.withdrawn:
        return 'remove_circle';
    }
  }

  /// Get time since submission
  Duration get timeSinceSubmission => DateTime.now().difference(submittedAt);

  /// Check if submission is older than a certain duration
  bool isOlderThan(Duration duration) => timeSinceSubmission > duration;
}

extension SubmissionStatusExtension on SubmissionStatus {
  String get displayName {
    switch (this) {
      case SubmissionStatus.draft:
        return 'Draft';
      case SubmissionStatus.submitted:
        return 'Submitted';
      case SubmissionStatus.underReview:
        return 'Under Review';
      case SubmissionStatus.changesRequested:
        return 'Changes Requested';
      case SubmissionStatus.approved:
        return 'Approved';
      case SubmissionStatus.rejected:
        return 'Rejected';
      case SubmissionStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  String get description {
    switch (this) {
      case SubmissionStatus.draft:
        return 'Tour is being prepared for submission';
      case SubmissionStatus.submitted:
        return 'Tour has been submitted for review';
      case SubmissionStatus.underReview:
        return 'Tour is currently being reviewed';
      case SubmissionStatus.changesRequested:
        return 'Reviewer has requested changes';
      case SubmissionStatus.approved:
        return 'Tour has been approved for publishing';
      case SubmissionStatus.rejected:
        return 'Tour submission was rejected';
      case SubmissionStatus.withdrawn:
        return 'Creator withdrew the submission';
    }
  }

  bool get canTransitionTo {
    switch (this) {
      case SubmissionStatus.draft:
        return true;
      case SubmissionStatus.submitted:
        return true;
      case SubmissionStatus.underReview:
        return true;
      case SubmissionStatus.changesRequested:
        return true;
      case SubmissionStatus.approved:
      case SubmissionStatus.rejected:
      case SubmissionStatus.withdrawn:
        return false;
    }
  }
}
