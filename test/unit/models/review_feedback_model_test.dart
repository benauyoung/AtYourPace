import 'package:flutter_test/flutter_test.dart';

import 'package:ayp_tour_guide/data/models/review_feedback_model.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('ReviewFeedbackModel', () {
    group('Serialization', () {
      test('fromJson creates model with required fields', () {
        final json = {
          'id': 'feedback_1',
          'submissionId': 'submission_1',
          'reviewerId': 'admin_1',
          'reviewerName': 'Admin User',
          'type': 'suggestion',
          'message': 'Consider adding more details',
          'priority': 'medium',
          'resolved': false,
          'createdAt': DateTime.now().toIso8601String(),
        };

        final feedback = ReviewFeedbackModel.fromJson(json);

        expect(feedback.id, equals('feedback_1'));
        expect(feedback.submissionId, equals('submission_1'));
        expect(feedback.reviewerId, equals('admin_1'));
        expect(feedback.reviewerName, equals('Admin User'));
        expect(feedback.type, equals(FeedbackType.suggestion));
        expect(feedback.message, equals('Consider adding more details'));
        expect(feedback.priority, equals(FeedbackPriority.medium));
        expect(feedback.resolved, isFalse);
      });

      test('fromJson handles optional stop fields', () {
        final json = {
          'id': 'feedback_1',
          'submissionId': 'submission_1',
          'reviewerId': 'admin_1',
          'reviewerName': 'Admin User',
          'type': 'issue',
          'message': 'Audio is too quiet',
          'stopId': 'stop_3',
          'stopName': 'Eiffel Tower',
          'priority': 'high',
          'resolved': false,
          'createdAt': DateTime.now().toIso8601String(),
        };

        final feedback = ReviewFeedbackModel.fromJson(json);

        expect(feedback.stopId, equals('stop_3'));
        expect(feedback.stopName, equals('Eiffel Tower'));
      });

      test('fromJson handles resolved feedback', () {
        final resolvedAt = DateTime.now();
        final json = {
          'id': 'feedback_1',
          'submissionId': 'submission_1',
          'reviewerId': 'admin_1',
          'reviewerName': 'Admin User',
          'type': 'issue',
          'message': 'Fixed issue',
          'priority': 'medium',
          'resolved': true,
          'resolvedAt': resolvedAt.toIso8601String(),
          'resolvedBy': 'creator_1',
          'resolutionNote': 'Fixed the audio',
          'createdAt': DateTime.now().toIso8601String(),
        };

        final feedback = ReviewFeedbackModel.fromJson(json);

        expect(feedback.resolved, isTrue);
        expect(feedback.resolvedBy, equals('creator_1'));
        expect(feedback.resolutionNote, equals('Fixed the audio'));
      });

      test('toJson serializes correctly', () {
        final feedback = createTestReviewFeedback(
          id: 'feedback_1',
          submissionId: 'submission_1',
          type: FeedbackType.issue,
          message: 'Test message',
          priority: FeedbackPriority.high,
        );

        final json = feedback.toJson();

        expect(json['id'], equals('feedback_1'));
        expect(json['type'], equals('issue'));
        expect(json['priority'], equals('high'));
      });

      test('toFirestore removes id field', () {
        final feedback = createTestReviewFeedback(id: 'feedback_1');

        final firestoreData = feedback.toFirestore();

        expect(firestoreData.containsKey('id'), isFalse);
        expect(firestoreData['submissionId'], equals('submission_1'));
      });
    });

    group('Computed Properties', () {
      test('isStopSpecific returns true when stopId is set', () {
        final feedback = createTestReviewFeedback(stopId: 'stop_1');
        expect(feedback.isStopSpecific, isTrue);
        expect(feedback.isGeneral, isFalse);
      });

      test('isGeneral returns true when stopId is null', () {
        final feedback = createTestReviewFeedback();
        expect(feedback.isGeneral, isTrue);
        expect(feedback.isStopSpecific, isFalse);
      });

      test('isRequired returns true for required type', () {
        final feedback = createTestReviewFeedback(type: FeedbackType.required);
        expect(feedback.isRequired, isTrue);
      });

      test('isBlocking returns true for required and issue types', () {
        final required = createTestReviewFeedback(type: FeedbackType.required);
        final issue = createTestReviewFeedback(type: FeedbackType.issue);
        final suggestion = createTestReviewFeedback(type: FeedbackType.suggestion);

        expect(required.isBlocking, isTrue);
        expect(issue.isBlocking, isTrue);
        expect(suggestion.isBlocking, isFalse);
      });

      test('canBeIgnored returns true for suggestion and compliment', () {
        final suggestion = createTestReviewFeedback(type: FeedbackType.suggestion);
        final compliment = createTestReviewFeedback(type: FeedbackType.compliment);
        final required = createTestReviewFeedback(type: FeedbackType.required);

        expect(suggestion.canBeIgnored, isTrue);
        expect(compliment.canBeIgnored, isTrue);
        expect(required.canBeIgnored, isFalse);
      });

      test('typeDisplay returns correct values', () {
        expect(createTestReviewFeedback(type: FeedbackType.issue).typeDisplay, equals('Issue'));
        expect(createTestReviewFeedback(type: FeedbackType.suggestion).typeDisplay, equals('Suggestion'));
        expect(createTestReviewFeedback(type: FeedbackType.compliment).typeDisplay, equals('Compliment'));
        expect(createTestReviewFeedback(type: FeedbackType.required).typeDisplay, equals('Required Change'));
      });

      test('typeIcon returns correct values', () {
        expect(createTestReviewFeedback(type: FeedbackType.issue).typeIcon, equals('error'));
        expect(createTestReviewFeedback(type: FeedbackType.suggestion).typeIcon, equals('lightbulb'));
        expect(createTestReviewFeedback(type: FeedbackType.compliment).typeIcon, equals('thumb_up'));
        expect(createTestReviewFeedback(type: FeedbackType.required).typeIcon, equals('priority_high'));
      });

      test('typeColorHex returns correct colors', () {
        expect(createTestReviewFeedback(type: FeedbackType.issue).typeColorHex, equals(0xFFFF9800));
        expect(createTestReviewFeedback(type: FeedbackType.suggestion).typeColorHex, equals(0xFF2196F3));
        expect(createTestReviewFeedback(type: FeedbackType.compliment).typeColorHex, equals(0xFF4CAF50));
        expect(createTestReviewFeedback(type: FeedbackType.required).typeColorHex, equals(0xFFF44336));
      });

      test('locationDisplay returns stop name when available', () {
        final feedback = createTestReviewFeedback(stopId: 'stop_1', stopName: 'Eiffel Tower');
        expect(feedback.locationDisplay, equals('Stop: Eiffel Tower'));
      });

      test('locationDisplay returns General when no stop', () {
        final feedback = createTestReviewFeedback();
        expect(feedback.locationDisplay, equals('General'));
      });
    });

    group('Enum Handling', () {
      test('all FeedbackType values serialize correctly', () {
        for (final type in FeedbackType.values) {
          final feedback = createTestReviewFeedback(type: type);
          final json = feedback.toJson();
          final restored = ReviewFeedbackModel.fromJson(json);
          expect(restored.type, equals(type));
        }
      });

      test('all FeedbackPriority values serialize correctly', () {
        for (final priority in FeedbackPriority.values) {
          final feedback = createTestReviewFeedback(priority: priority);
          final json = feedback.toJson();
          final restored = ReviewFeedbackModel.fromJson(json);
          expect(restored.priority, equals(priority));
        }
      });
    });
  });

  group('FeedbackTypeExtension', () {
    test('displayName returns correct values', () {
      expect(FeedbackType.issue.displayName, equals('Issue'));
      expect(FeedbackType.suggestion.displayName, equals('Suggestion'));
      expect(FeedbackType.compliment.displayName, equals('Compliment'));
      expect(FeedbackType.required.displayName, equals('Required Change'));
    });

    test('description returns correct values', () {
      expect(FeedbackType.issue.description, contains('problem'));
      expect(FeedbackType.suggestion.description, contains('optional'));
      expect(FeedbackType.compliment.description, contains('Positive'));
      expect(FeedbackType.required.description, contains('must be made'));
    });
  });

  group('FeedbackPriorityExtension', () {
    test('displayName returns correct values', () {
      expect(FeedbackPriority.low.displayName, equals('Low'));
      expect(FeedbackPriority.medium.displayName, equals('Medium'));
      expect(FeedbackPriority.high.displayName, equals('High'));
      expect(FeedbackPriority.critical.displayName, equals('Critical'));
    });

    test('colorHex returns correct colors', () {
      expect(FeedbackPriority.low.colorHex, equals(0xFF9E9E9E));
      expect(FeedbackPriority.medium.colorHex, equals(0xFF2196F3));
      expect(FeedbackPriority.high.colorHex, equals(0xFFFF9800));
      expect(FeedbackPriority.critical.colorHex, equals(0xFFF44336));
    });
  });
}
