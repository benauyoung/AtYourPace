import 'package:flutter_test/flutter_test.dart';

import 'package:ayp_tour_guide/data/models/publishing_submission_model.dart';
import 'package:ayp_tour_guide/data/models/review_feedback_model.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('PublishingSubmissionModel', () {
    group('Serialization', () {
      test('fromJson creates model with required fields', () {
        final json = {
          'id': 'submission_1',
          'tourId': 'tour_1',
          'versionId': 'v1',
          'creatorId': 'creator_1',
          'creatorName': 'Test Creator',
          'status': 'submitted',
          'submittedAt': DateTime.now().toIso8601String(),
          'feedback': [],
          'resubmissionCount': 0,
          'creatorIgnoredSuggestions': false,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final submission = PublishingSubmissionModel.fromJson(json);

        expect(submission.id, equals('submission_1'));
        expect(submission.tourId, equals('tour_1'));
        expect(submission.versionId, equals('v1'));
        expect(submission.creatorId, equals('creator_1'));
        expect(submission.creatorName, equals('Test Creator'));
        expect(submission.status, equals(SubmissionStatus.submitted));
      });

      test('fromJson handles optional reviewer fields', () {
        final json = {
          'id': 'submission_1',
          'tourId': 'tour_1',
          'versionId': 'v1',
          'creatorId': 'creator_1',
          'creatorName': 'Test Creator',
          'status': 'under_review',
          'submittedAt': DateTime.now().toIso8601String(),
          'reviewedAt': DateTime.now().toIso8601String(),
          'reviewerId': 'admin_1',
          'reviewerName': 'Admin User',
          'feedback': [],
          'resubmissionCount': 0,
          'creatorIgnoredSuggestions': false,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final submission = PublishingSubmissionModel.fromJson(json);

        expect(submission.reviewerId, equals('admin_1'));
        expect(submission.reviewerName, equals('Admin User'));
        expect(submission.reviewedAt, isNotNull);
      });

      test('fromJson handles rejected submission', () {
        final json = {
          'id': 'submission_1',
          'tourId': 'tour_1',
          'versionId': 'v1',
          'creatorId': 'creator_1',
          'creatorName': 'Test Creator',
          'status': 'rejected',
          'submittedAt': DateTime.now().toIso8601String(),
          'rejectionReason': 'Audio quality too low',
          'feedback': [],
          'resubmissionCount': 0,
          'creatorIgnoredSuggestions': false,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final submission = PublishingSubmissionModel.fromJson(json);

        expect(submission.status, equals(SubmissionStatus.rejected));
        expect(submission.rejectionReason, equals('Audio quality too low'));
      });

      test('toJson serializes correctly', () {
        final submission = createTestPublishingSubmission(
          id: 'submission_1',
          tourId: 'tour_1',
          status: SubmissionStatus.submitted,
        );

        final json = submission.toJson();

        expect(json['id'], equals('submission_1'));
        expect(json['tourId'], equals('tour_1'));
        expect(json['status'], equals('submitted'));
      });

      test('toFirestore removes id field', () {
        final submission = createTestPublishingSubmission(id: 'submission_1');

        final firestoreData = submission.toFirestore();

        expect(firestoreData.containsKey('id'), isFalse);
        expect(firestoreData['tourId'], equals('test_tour_1'));
      });
    });

    group('Status Properties', () {
      test('isPending returns true for submitted and under_review', () {
        final submitted = createTestPublishingSubmission(status: SubmissionStatus.submitted);
        final underReview = createTestPublishingSubmission(status: SubmissionStatus.underReview);
        final approved = createTestPublishingSubmission(status: SubmissionStatus.approved);

        expect(submitted.isPending, isTrue);
        expect(underReview.isPending, isTrue);
        expect(approved.isPending, isFalse);
      });

      test('isApproved returns true for approved status', () {
        final approved = createTestPublishingSubmission(status: SubmissionStatus.approved);
        final submitted = createTestPublishingSubmission(status: SubmissionStatus.submitted);

        expect(approved.isApproved, isTrue);
        expect(submitted.isApproved, isFalse);
      });

      test('isRejected returns true for rejected status', () {
        final rejected = createTestPublishingSubmission(status: SubmissionStatus.rejected);
        expect(rejected.isRejected, isTrue);
      });

      test('needsChanges returns true for changes_requested status', () {
        final changesRequested = createTestPublishingSubmission(status: SubmissionStatus.changesRequested);
        expect(changesRequested.needsChanges, isTrue);
      });

      test('isDraft returns true for draft status', () {
        final draft = createTestPublishingSubmission(status: SubmissionStatus.draft);
        expect(draft.isDraft, isTrue);
      });

      test('isWithdrawn returns true for withdrawn status', () {
        final withdrawn = createTestPublishingSubmission(status: SubmissionStatus.withdrawn);
        expect(withdrawn.isWithdrawn, isTrue);
      });

      test('isFinal returns true for terminal states', () {
        final approved = createTestPublishingSubmission(status: SubmissionStatus.approved);
        final rejected = createTestPublishingSubmission(status: SubmissionStatus.rejected);
        final withdrawn = createTestPublishingSubmission(status: SubmissionStatus.withdrawn);
        final submitted = createTestPublishingSubmission(status: SubmissionStatus.submitted);

        expect(approved.isFinal, isTrue);
        expect(rejected.isFinal, isTrue);
        expect(withdrawn.isFinal, isTrue);
        expect(submitted.isFinal, isFalse);
      });
    });

    group('Resubmission Properties', () {
      test('isResubmission returns true when resubmissionCount > 0', () {
        final resubmission = createTestPublishingSubmission(resubmissionCount: 1);
        final firstSubmission = createTestPublishingSubmission(resubmissionCount: 0);

        expect(resubmission.isResubmission, isTrue);
        expect(firstSubmission.isResubmission, isFalse);
      });
    });

    group('Feedback Properties', () {
      test('hasFeedback returns true when feedback exists', () {
        final feedback = [createTestReviewFeedback()];
        final withFeedback = createTestPublishingSubmission(feedback: feedback);
        final withoutFeedback = createTestPublishingSubmission();

        expect(withFeedback.hasFeedback, isTrue);
        expect(withoutFeedback.hasFeedback, isFalse);
      });

      test('unresolvedFeedback returns unresolved items', () {
        final feedback = [
          createTestReviewFeedback(id: '1', resolved: false),
          createTestReviewFeedback(id: '2', resolved: true),
          createTestReviewFeedback(id: '3', resolved: false),
        ];
        final submission = createTestPublishingSubmission(feedback: feedback);

        expect(submission.unresolvedFeedback.length, equals(2));
      });

      test('requiredFeedback returns required items', () {
        final feedback = [
          createTestReviewFeedback(id: '1', type: FeedbackType.required),
          createTestReviewFeedback(id: '2', type: FeedbackType.suggestion),
          createTestReviewFeedback(id: '3', type: FeedbackType.required),
        ];
        final submission = createTestPublishingSubmission(feedback: feedback);

        expect(submission.requiredFeedback.length, equals(2));
      });

      test('unresolvedRequiredFeedback returns unresolved required items', () {
        final feedback = [
          createTestReviewFeedback(id: '1', type: FeedbackType.required, resolved: false),
          createTestReviewFeedback(id: '2', type: FeedbackType.required, resolved: true),
          createTestReviewFeedback(id: '3', type: FeedbackType.suggestion, resolved: false),
        ];
        final submission = createTestPublishingSubmission(feedback: feedback);

        expect(submission.unresolvedRequiredFeedback.length, equals(1));
      });

      test('allRequiredResolved returns true when all required resolved', () {
        final feedback = [
          createTestReviewFeedback(id: '1', type: FeedbackType.required, resolved: true),
          createTestReviewFeedback(id: '2', type: FeedbackType.suggestion, resolved: false),
        ];
        final submission = createTestPublishingSubmission(feedback: feedback);

        expect(submission.allRequiredResolved, isTrue);
      });

      test('feedbackCountByType returns correct count', () {
        final feedback = [
          createTestReviewFeedback(id: '1', type: FeedbackType.issue),
          createTestReviewFeedback(id: '2', type: FeedbackType.issue),
          createTestReviewFeedback(id: '3', type: FeedbackType.suggestion),
        ];
        final submission = createTestPublishingSubmission(feedback: feedback);

        expect(submission.feedbackCountByType(FeedbackType.issue), equals(2));
        expect(submission.feedbackCountByType(FeedbackType.suggestion), equals(1));
        expect(submission.feedbackCountByType(FeedbackType.compliment), equals(0));
      });
    });

    group('Display Properties', () {
      test('statusDisplay returns correct values', () {
        expect(createTestPublishingSubmission(status: SubmissionStatus.draft).statusDisplay, equals('Draft'));
        expect(createTestPublishingSubmission(status: SubmissionStatus.submitted).statusDisplay, equals('Submitted'));
        expect(createTestPublishingSubmission(status: SubmissionStatus.underReview).statusDisplay, equals('Under Review'));
        expect(createTestPublishingSubmission(status: SubmissionStatus.changesRequested).statusDisplay, equals('Changes Requested'));
        expect(createTestPublishingSubmission(status: SubmissionStatus.approved).statusDisplay, equals('Approved'));
        expect(createTestPublishingSubmission(status: SubmissionStatus.rejected).statusDisplay, equals('Rejected'));
        expect(createTestPublishingSubmission(status: SubmissionStatus.withdrawn).statusDisplay, equals('Withdrawn'));
      });

      test('statusColorHex returns correct colors', () {
        expect(createTestPublishingSubmission(status: SubmissionStatus.draft).statusColorHex, equals(0xFF9E9E9E));
        expect(createTestPublishingSubmission(status: SubmissionStatus.submitted).statusColorHex, equals(0xFF2196F3));
        expect(createTestPublishingSubmission(status: SubmissionStatus.approved).statusColorHex, equals(0xFF4CAF50));
        expect(createTestPublishingSubmission(status: SubmissionStatus.rejected).statusColorHex, equals(0xFFF44336));
      });

      test('statusIcon returns correct icons', () {
        expect(createTestPublishingSubmission(status: SubmissionStatus.draft).statusIcon, equals('edit'));
        expect(createTestPublishingSubmission(status: SubmissionStatus.submitted).statusIcon, equals('send'));
        expect(createTestPublishingSubmission(status: SubmissionStatus.approved).statusIcon, equals('check_circle'));
        expect(createTestPublishingSubmission(status: SubmissionStatus.rejected).statusIcon, equals('cancel'));
      });
    });

    group('Time Properties', () {
      test('timeSinceSubmission returns duration', () {
        final submission = createTestPublishingSubmission(
          submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
        );

        expect(submission.timeSinceSubmission.inHours, greaterThanOrEqualTo(5));
      });

      test('isOlderThan returns true for old submissions', () {
        final submission = createTestPublishingSubmission(
          submittedAt: DateTime.now().subtract(const Duration(days: 3)),
        );

        expect(submission.isOlderThan(const Duration(days: 2)), isTrue);
        expect(submission.isOlderThan(const Duration(days: 5)), isFalse);
      });
    });

    group('Enum Handling', () {
      test('all SubmissionStatus values serialize correctly', () {
        for (final status in SubmissionStatus.values) {
          final submission = createTestPublishingSubmission(status: status);
          final json = submission.toJson();
          final restored = PublishingSubmissionModel.fromJson(json);
          expect(restored.status, equals(status));
        }
      });
    });
  });

  group('SubmissionStatusExtension', () {
    test('displayName returns correct values', () {
      expect(SubmissionStatus.draft.displayName, equals('Draft'));
      expect(SubmissionStatus.submitted.displayName, equals('Submitted'));
      expect(SubmissionStatus.underReview.displayName, equals('Under Review'));
      expect(SubmissionStatus.changesRequested.displayName, equals('Changes Requested'));
      expect(SubmissionStatus.approved.displayName, equals('Approved'));
      expect(SubmissionStatus.rejected.displayName, equals('Rejected'));
      expect(SubmissionStatus.withdrawn.displayName, equals('Withdrawn'));
    });

    test('description returns correct values', () {
      expect(SubmissionStatus.draft.description, contains('prepared'));
      expect(SubmissionStatus.submitted.description, contains('submitted'));
      expect(SubmissionStatus.underReview.description, contains('reviewed'));
      expect(SubmissionStatus.approved.description, contains('approved'));
      expect(SubmissionStatus.rejected.description, contains('rejected'));
    });

    test('canTransitionTo returns correct values', () {
      expect(SubmissionStatus.draft.canTransitionTo, isTrue);
      expect(SubmissionStatus.submitted.canTransitionTo, isTrue);
      expect(SubmissionStatus.underReview.canTransitionTo, isTrue);
      expect(SubmissionStatus.changesRequested.canTransitionTo, isTrue);
      expect(SubmissionStatus.approved.canTransitionTo, isFalse);
      expect(SubmissionStatus.rejected.canTransitionTo, isFalse);
      expect(SubmissionStatus.withdrawn.canTransitionTo, isFalse);
    });
  });
}
