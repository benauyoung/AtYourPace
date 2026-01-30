import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../models/publishing_submission_model.dart';
import '../models/review_feedback_model.dart';

/// Repository for managing publishing submissions and review workflow.
class PublishingRepository {
  final FirebaseFirestore _firestore;

  PublishingRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Gets the submissions collection reference.
  CollectionReference<Map<String, dynamic>> get _submissionsRef =>
      _firestore.collection(FirestoreCollections.publishingSubmissions);

  /// Gets a submission document reference.
  DocumentReference<Map<String, dynamic>> _submissionRef(String submissionId) =>
      _submissionsRef.doc(submissionId);

  /// Gets the feedback collection for a submission.
  CollectionReference<Map<String, dynamic>> _feedbackRef(String submissionId) =>
      _submissionRef(submissionId)
          .collection(FirestoreCollections.reviewFeedback);

  // ==================== Submission CRUD ====================

  /// Creates a new publishing submission.
  Future<PublishingSubmissionModel> create({
    required PublishingSubmissionModel submission,
  }) async {
    final docRef = _submissionsRef.doc();
    final now = DateTime.now();

    final submissionWithId = submission.copyWith(
      id: docRef.id,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(submissionWithId.toFirestore());
    return submissionWithId;
  }

  /// Gets a submission by ID.
  Future<PublishingSubmissionModel?> get(String submissionId) async {
    final doc = await _submissionRef(submissionId).get();
    if (!doc.exists) return null;

    final submission = PublishingSubmissionModel.fromFirestore(doc);

    // Load feedback
    final feedbackSnapshot = await _feedbackRef(submissionId)
        .orderBy('createdAt', descending: true)
        .get();

    final feedback = feedbackSnapshot.docs
        .map((doc) => ReviewFeedbackModel.fromFirestore(doc))
        .toList();

    return submission.copyWith(feedback: feedback);
  }

  /// Gets a submission by tour ID.
  Future<PublishingSubmissionModel?> getByTourId(String tourId) async {
    final snapshot = await _submissionsRef
        .where('tourId', isEqualTo: tourId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return get(snapshot.docs.first.id);
  }

  /// Gets the latest submission for a tour.
  Future<PublishingSubmissionModel?> getLatestForTour(String tourId) async {
    return getByTourId(tourId);
  }

  /// Updates a submission.
  Future<PublishingSubmissionModel> update({
    required String submissionId,
    required PublishingSubmissionModel submission,
  }) async {
    final updated = submission.copyWith(
      updatedAt: DateTime.now(),
    );

    await _submissionRef(submissionId).update(updated.toFirestore());
    return updated;
  }

  /// Updates submission status.
  Future<void> updateStatus({
    required String submissionId,
    required SubmissionStatus status,
    String? reviewerId,
    String? reviewerName,
    String? rejectionReason,
  }) async {
    final updates = <String, dynamic>{
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (reviewerId != null) {
      updates['reviewerId'] = reviewerId;
      updates['reviewerName'] = reviewerName;
      updates['reviewedAt'] = FieldValue.serverTimestamp();
    }

    if (rejectionReason != null) {
      updates['rejectionReason'] = rejectionReason;
    }

    await _submissionRef(submissionId).update(updates);
  }

  /// Deletes a submission and all its feedback.
  Future<void> delete(String submissionId) async {
    final batch = _firestore.batch();

    // Delete all feedback
    final feedbackSnapshot = await _feedbackRef(submissionId).get();
    for (final doc in feedbackSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete submission
    batch.delete(_submissionRef(submissionId));

    await batch.commit();
  }

  // ==================== Query Methods ====================

  /// Gets all submissions for a creator.
  Future<List<PublishingSubmissionModel>> getCreatorSubmissions(
    String creatorId, {
    int limit = 20,
    SubmissionStatus? status,
  }) async {
    Query<Map<String, dynamic>> query = _submissionsRef
        .where('creatorId', isEqualTo: creatorId)
        .orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    final snapshot = await query.limit(limit).get();

    final submissions = <PublishingSubmissionModel>[];
    for (final doc in snapshot.docs) {
      final submission = await get(doc.id);
      if (submission != null) {
        submissions.add(submission);
      }
    }

    return submissions;
  }

  /// Gets pending submissions (for admin review queue).
  Future<List<PublishingSubmissionModel>> getPendingSubmissions({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _submissionsRef
        .where('status', whereIn: [
          SubmissionStatus.submitted.name,
          SubmissionStatus.underReview.name,
        ])
        .orderBy('submittedAt', descending: false);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.limit(limit).get();

    final submissions = <PublishingSubmissionModel>[];
    for (final doc in snapshot.docs) {
      final submission = await get(doc.id);
      if (submission != null) {
        submissions.add(submission);
      }
    }

    return submissions;
  }

  /// Gets submissions by status.
  Future<List<PublishingSubmissionModel>> getByStatus(
    SubmissionStatus status, {
    int limit = 20,
  }) async {
    final snapshot = await _submissionsRef
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    final submissions = <PublishingSubmissionModel>[];
    for (final doc in snapshot.docs) {
      final submission = await get(doc.id);
      if (submission != null) {
        submissions.add(submission);
      }
    }

    return submissions;
  }

  /// Gets submission count by status.
  Future<Map<SubmissionStatus, int>> getStatusCounts() async {
    final counts = <SubmissionStatus, int>{};

    for (final status in SubmissionStatus.values) {
      final snapshot = await _submissionsRef
          .where('status', isEqualTo: status.name)
          .count()
          .get();
      counts[status] = snapshot.count ?? 0;
    }

    return counts;
  }

  // ==================== Workflow Methods ====================

  /// Submits a tour for review.
  Future<PublishingSubmissionModel> submitForReview({
    required String tourId,
    required String versionId,
    required String creatorId,
    required String creatorName,
    String? tourTitle,
    String? tourDescription,
  }) async {
    final now = DateTime.now();

    return create(
      submission: PublishingSubmissionModel(
        id: '',
        tourId: tourId,
        versionId: versionId,
        creatorId: creatorId,
        creatorName: creatorName,
        status: SubmissionStatus.submitted,
        submittedAt: now,
        tourTitle: tourTitle,
        tourDescription: tourDescription,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// Claims a submission for review (admin).
  Future<void> claimForReview({
    required String submissionId,
    required String reviewerId,
    required String reviewerName,
  }) async {
    await _submissionRef(submissionId).update({
      'status': SubmissionStatus.underReview.name,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Approves a submission (admin).
  Future<void> approve({
    required String submissionId,
    required String reviewerId,
    required String reviewerName,
  }) async {
    await _submissionRef(submissionId).update({
      'status': SubmissionStatus.approved.name,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reviewedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Requests changes on a submission (admin).
  Future<void> requestChanges({
    required String submissionId,
    required String reviewerId,
    required String reviewerName,
  }) async {
    await _submissionRef(submissionId).update({
      'status': SubmissionStatus.changesRequested.name,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reviewedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Rejects a submission (admin).
  Future<void> reject({
    required String submissionId,
    required String reviewerId,
    required String reviewerName,
    required String reason,
  }) async {
    await _submissionRef(submissionId).update({
      'status': SubmissionStatus.rejected.name,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reviewedAt': FieldValue.serverTimestamp(),
      'rejectionReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Withdraws a submission (creator).
  Future<void> withdraw(String submissionId) async {
    await _submissionRef(submissionId).update({
      'status': SubmissionStatus.withdrawn.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Resubmits with justification (creator).
  Future<PublishingSubmissionModel> resubmit({
    required String submissionId,
    required String justification,
    bool ignoredSuggestions = false,
  }) async {
    final existing = await get(submissionId);
    if (existing == null) {
      throw Exception('Submission not found');
    }

    await _submissionRef(submissionId).update({
      'status': SubmissionStatus.submitted.name,
      'submittedAt': FieldValue.serverTimestamp(),
      'resubmissionJustification': justification,
      'resubmissionCount': FieldValue.increment(1),
      'creatorIgnoredSuggestions': ignoredSuggestions,
      'reviewerId': FieldValue.delete(),
      'reviewerName': FieldValue.delete(),
      'reviewedAt': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return (await get(submissionId))!;
  }

  // ==================== Feedback Methods ====================

  /// Adds feedback to a submission.
  Future<ReviewFeedbackModel> addFeedback({
    required String submissionId,
    required ReviewFeedbackModel feedback,
  }) async {
    final docRef = _feedbackRef(submissionId).doc();
    final now = DateTime.now();

    final feedbackWithId = feedback.copyWith(
      id: docRef.id,
      submissionId: submissionId,
      createdAt: now,
    );

    await docRef.set(feedbackWithId.toFirestore());
    return feedbackWithId;
  }

  /// Gets all feedback for a submission.
  Future<List<ReviewFeedbackModel>> getFeedback(String submissionId) async {
    final snapshot = await _feedbackRef(submissionId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ReviewFeedbackModel.fromFirestore(doc))
        .toList();
  }

  /// Marks feedback as resolved.
  Future<void> resolveFeedback({
    required String submissionId,
    required String feedbackId,
    required String resolvedBy,
    String? resolutionNote,
  }) async {
    await _feedbackRef(submissionId).doc(feedbackId).update({
      'resolved': true,
      'resolvedAt': FieldValue.serverTimestamp(),
      'resolvedBy': resolvedBy,
      if (resolutionNote != null) 'resolutionNote': resolutionNote,
    });
  }

  /// Deletes feedback.
  Future<void> deleteFeedback({
    required String submissionId,
    required String feedbackId,
  }) async {
    await _feedbackRef(submissionId).doc(feedbackId).delete();
  }

  // ==================== Stream Methods ====================

  /// Watches a submission for changes.
  Stream<PublishingSubmissionModel?> watchSubmission(String submissionId) {
    return _submissionRef(submissionId).snapshots().asyncMap((doc) async {
      if (!doc.exists) return null;
      return get(doc.id);
    });
  }

  /// Watches pending submissions (admin).
  Stream<List<PublishingSubmissionModel>> watchPendingSubmissions() {
    return _submissionsRef
        .where('status', whereIn: [
          SubmissionStatus.submitted.name,
          SubmissionStatus.underReview.name,
        ])
        .orderBy('submittedAt', descending: false)
        .snapshots()
        .asyncMap((snapshot) async {
          final submissions = <PublishingSubmissionModel>[];
          for (final doc in snapshot.docs) {
            final submission = await get(doc.id);
            if (submission != null) {
              submissions.add(submission);
            }
          }
          return submissions;
        });
  }

  /// Watches creator's submissions.
  Stream<List<PublishingSubmissionModel>> watchCreatorSubmissions(
    String creatorId,
  ) {
    return _submissionsRef
        .where('creatorId', isEqualTo: creatorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final submissions = <PublishingSubmissionModel>[];
          for (final doc in snapshot.docs) {
            final submission = await get(doc.id);
            if (submission != null) {
              submissions.add(submission);
            }
          }
          return submissions;
        });
  }
}
