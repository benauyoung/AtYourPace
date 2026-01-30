import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../data/models/publishing_submission_model.dart';
import '../../../../../data/models/review_feedback_model.dart';

/// State for publishing workflow
class PublishingState {
  final PublishingSubmissionModel? submission;
  final List<ReviewFeedbackModel> feedback;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final List<String> checklistErrors;

  const PublishingState({
    this.submission,
    this.feedback = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.checklistErrors = const [],
  });

  PublishingState copyWith({
    PublishingSubmissionModel? submission,
    List<ReviewFeedbackModel>? feedback,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
    List<String>? checklistErrors,
  }) {
    return PublishingState(
      submission: submission ?? this.submission,
      feedback: feedback ?? this.feedback,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      checklistErrors: checklistErrors ?? this.checklistErrors,
    );
  }

  bool get hasSubmission => submission != null;
  bool get isPending => submission?.status == SubmissionStatus.submitted;
  bool get isInReview => submission?.status == SubmissionStatus.underReview;
  bool get isApproved => submission?.status == SubmissionStatus.approved;
  bool get isRejected => submission?.status == SubmissionStatus.rejected;
  bool get needsChanges => submission?.status == SubmissionStatus.changesRequested;
  bool get hasFeedback => feedback.isNotEmpty;
  bool get canSubmit => checklistErrors.isEmpty;
}

/// Publishing workflow notifier
class PublishingNotifier extends StateNotifier<PublishingState> {
  final FirebaseFirestore _firestore;
  final String tourId;
  final String versionId;

  PublishingNotifier({
    required FirebaseFirestore firestore,
    required this.tourId,
    required this.versionId,
  })  : _firestore = firestore,
        super(const PublishingState());

  /// Initialize and load submission status
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Load existing submission
      final submissionQuery = await _firestore
          .collection('publishing_submissions')
          .where('tourId', isEqualTo: tourId)
          .where('versionId', isEqualTo: versionId)
          .orderBy('submittedAt', descending: true)
          .limit(1)
          .get();

      PublishingSubmissionModel? submission;
      if (submissionQuery.docs.isNotEmpty) {
        submission = PublishingSubmissionModel.fromFirestore(
          submissionQuery.docs.first,
        );

        // Load feedback for this submission
        final feedbackQuery = await _firestore
            .collection('publishing_submissions')
            .doc(submission.id)
            .collection('feedback')
            .orderBy('createdAt', descending: true)
            .get();

        final feedback = feedbackQuery.docs
            .map((doc) => ReviewFeedbackModel.fromFirestore(doc))
            .toList();

        state = state.copyWith(
          submission: submission,
          feedback: feedback,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }

      // Validate checklist
      await _validateChecklist();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load submission: $e',
      );
    }
  }

  /// Validate pre-submission checklist
  Future<void> _validateChecklist() async {
    final errors = <String>[];

    try {
      // Check tour version exists
      final versionDoc = await _firestore
          .collection('tours')
          .doc(tourId)
          .collection('versions')
          .doc(versionId)
          .get();

      if (!versionDoc.exists) {
        errors.add('Tour version not found');
        state = state.copyWith(checklistErrors: errors);
        return;
      }

      final versionData = versionDoc.data()!;

      // Check title
      if (versionData['title'] == null ||
          (versionData['title'] as String).isEmpty) {
        errors.add('Tour title is required');
      }

      // Check description
      if (versionData['description'] == null ||
          (versionData['description'] as String).isEmpty) {
        errors.add('Tour description is required');
      }

      // Check cover image
      if (versionData['coverImageUrl'] == null) {
        errors.add('Cover image is required');
      }

      // Check stops
      final stopsQuery = await _firestore
          .collection('tours')
          .doc(tourId)
          .collection('versions')
          .doc(versionId)
          .collection('stops')
          .get();

      if (stopsQuery.docs.isEmpty) {
        errors.add('At least one stop is required');
      } else {
        // Check each stop has audio
        int stopsWithoutAudio = 0;
        for (final stopDoc in stopsQuery.docs) {
          final stopData = stopDoc.data();
          final media = stopData['media'] as Map<String, dynamic>?;
          if (media == null || media['audioUrl'] == null) {
            stopsWithoutAudio++;
          }
        }
        if (stopsWithoutAudio > 0) {
          errors.add('$stopsWithoutAudio stop(s) missing audio narration');
        }
      }

      state = state.copyWith(checklistErrors: errors);
    } catch (e) {
      errors.add('Failed to validate: $e');
      state = state.copyWith(checklistErrors: errors);
    }
  }

  /// Submit tour for review
  Future<bool> submitForReview({String? notes}) async {
    if (!state.canSubmit) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final now = DateTime.now();
      final submissionRef = _firestore.collection('publishing_submissions').doc();

      final submission = PublishingSubmissionModel(
        id: submissionRef.id,
        tourId: tourId,
        versionId: versionId,
        creatorId: '', // Will be set by server
        creatorName: '', // Will be set by server
        status: SubmissionStatus.submitted,
        resubmissionJustification: notes,
        submittedAt: now,
        createdAt: now,
        updatedAt: now,
      );

      await submissionRef.set(submission.toFirestore());

      // Update tour status
      await _firestore.collection('tours').doc(tourId).update({
        'status': 'pending_review',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      state = state.copyWith(
        submission: submission,
        isSubmitting: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to submit: $e',
      );
      return false;
    }
  }

  /// Withdraw submission
  Future<bool> withdrawSubmission() async {
    if (state.submission == null) return false;

    try {
      await _firestore
          .collection('publishing_submissions')
          .doc(state.submission!.id)
          .update({
        'status': 'withdrawn',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update tour status back to draft
      await _firestore.collection('tours').doc(tourId).update({
        'status': 'draft',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      state = state.copyWith(
        submission: state.submission!.copyWith(
          status: SubmissionStatus.withdrawn,
        ),
      );

      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to withdraw: $e');
      return false;
    }
  }

  /// Resubmit after changes
  Future<bool> resubmit({String? justification}) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      // Validate again
      await _validateChecklist();
      if (!state.canSubmit) {
        state = state.copyWith(isSubmitting: false);
        return false;
      }

      final now = DateTime.now();
      final submissionRef = _firestore.collection('publishing_submissions').doc();

      final submission = PublishingSubmissionModel(
        id: submissionRef.id,
        tourId: tourId,
        versionId: versionId,
        creatorId: '',
        creatorName: '',
        status: SubmissionStatus.submitted,
        resubmissionJustification: justification,
        resubmissionCount: (state.submission?.resubmissionCount ?? 0) + 1,
        submittedAt: now,
        createdAt: now,
        updatedAt: now,
      );

      await submissionRef.set(submission.toFirestore());

      // Update tour status
      await _firestore.collection('tours').doc(tourId).update({
        'status': 'pending_review',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      state = state.copyWith(
        submission: submission,
        feedback: [], // Clear old feedback
        isSubmitting: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to resubmit: $e',
      );
      return false;
    }
  }

  /// Refresh checklist
  Future<void> refreshChecklist() async {
    await _validateChecklist();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Review queue state for admin
class ReviewQueueState {
  final List<PublishingSubmissionModel> submissions;
  final bool isLoading;
  final String? error;
  final SubmissionStatus? filterStatus;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  const ReviewQueueState({
    this.submissions = const [],
    this.isLoading = false,
    this.error,
    this.filterStatus,
    this.lastDocument,
    this.hasMore = true,
  });

  ReviewQueueState copyWith({
    List<PublishingSubmissionModel>? submissions,
    bool? isLoading,
    String? error,
    bool clearError = false,
    SubmissionStatus? filterStatus,
    bool clearFilter = false,
    DocumentSnapshot? lastDocument,
    bool? hasMore,
  }) {
    return ReviewQueueState(
      submissions: submissions ?? this.submissions,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      filterStatus: clearFilter ? null : (filterStatus ?? this.filterStatus),
      lastDocument: lastDocument ?? this.lastDocument,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  int get pendingCount =>
      submissions.where((s) => s.status == SubmissionStatus.submitted).length;
  int get inReviewCount =>
      submissions.where((s) => s.status == SubmissionStatus.underReview).length;
}

/// Review queue notifier for admin
class ReviewQueueNotifier extends StateNotifier<ReviewQueueState> {
  final FirebaseFirestore _firestore;
  static const int _pageSize = 20;

  ReviewQueueNotifier({required FirebaseFirestore firestore})
      : _firestore = firestore,
        super(const ReviewQueueState());

  /// Load submissions
  Future<void> loadSubmissions() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      var query = _firestore
          .collection('publishing_submissions')
          .orderBy('submittedAt', descending: true);

      if (state.filterStatus != null) {
        query = query.where('status', isEqualTo: state.filterStatus!.name);
      }

      final snapshot = await query.limit(_pageSize).get();

      final submissions = snapshot.docs
          .map((doc) => PublishingSubmissionModel.fromFirestore(doc))
          .toList();

      state = state.copyWith(
        submissions: submissions,
        isLoading: false,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        hasMore: snapshot.docs.length == _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load submissions: $e',
      );
    }
  }

  /// Load more submissions
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore || state.lastDocument == null) return;

    state = state.copyWith(isLoading: true);

    try {
      var query = _firestore
          .collection('publishing_submissions')
          .orderBy('submittedAt', descending: true)
          .startAfterDocument(state.lastDocument!);

      if (state.filterStatus != null) {
        query = query.where('status', isEqualTo: state.filterStatus!.name);
      }

      final snapshot = await query.limit(_pageSize).get();

      final newSubmissions = snapshot.docs
          .map((doc) => PublishingSubmissionModel.fromFirestore(doc))
          .toList();

      state = state.copyWith(
        submissions: [...state.submissions, ...newSubmissions],
        isLoading: false,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        hasMore: snapshot.docs.length == _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load more: $e',
      );
    }
  }

  /// Filter by status
  void filterByStatus(SubmissionStatus? status) {
    state = state.copyWith(
      filterStatus: status,
      clearFilter: status == null,
      submissions: [],
      lastDocument: null,
      hasMore: true,
    );
    loadSubmissions();
  }

  /// Refresh
  Future<void> refresh() async {
    state = state.copyWith(
      submissions: [],
      lastDocument: null,
      hasMore: true,
    );
    await loadSubmissions();
  }
}

/// Tour review state for admin reviewing a specific submission
class TourReviewState {
  final PublishingSubmissionModel? submission;
  final List<ReviewFeedbackModel> feedback;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final bool isPreviewMode;

  const TourReviewState({
    this.submission,
    this.feedback = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.isPreviewMode = true,
  });

  TourReviewState copyWith({
    PublishingSubmissionModel? submission,
    List<ReviewFeedbackModel>? feedback,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
    bool? isPreviewMode,
  }) {
    return TourReviewState(
      submission: submission ?? this.submission,
      feedback: feedback ?? this.feedback,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
      isPreviewMode: isPreviewMode ?? this.isPreviewMode,
    );
  }
}

/// Tour review notifier for admin
class TourReviewNotifier extends StateNotifier<TourReviewState> {
  final FirebaseFirestore _firestore;
  final String submissionId;

  TourReviewNotifier({
    required FirebaseFirestore firestore,
    required this.submissionId,
  })  : _firestore = firestore,
        super(const TourReviewState());

  /// Initialize and load submission
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final submissionDoc = await _firestore
          .collection('publishing_submissions')
          .doc(submissionId)
          .get();

      if (!submissionDoc.exists) {
        state = state.copyWith(
          isLoading: false,
          error: 'Submission not found',
        );
        return;
      }

      final submission = PublishingSubmissionModel.fromFirestore(submissionDoc);

      // Load feedback
      final feedbackQuery = await _firestore
          .collection('publishing_submissions')
          .doc(submissionId)
          .collection('feedback')
          .orderBy('createdAt', descending: true)
          .get();

      final feedback = feedbackQuery.docs
          .map((doc) => ReviewFeedbackModel.fromFirestore(doc))
          .toList();

      // Mark as under review if submitted
      if (submission.status == SubmissionStatus.submitted) {
        await _firestore
            .collection('publishing_submissions')
            .doc(submissionId)
            .update({
          'status': 'under_review',
          'reviewStartedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      state = state.copyWith(
        submission: submission.copyWith(
          status: submission.status == SubmissionStatus.submitted
              ? SubmissionStatus.underReview
              : submission.status,
        ),
        feedback: feedback,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load submission: $e',
      );
    }
  }

  /// Toggle preview mode
  void togglePreviewMode() {
    state = state.copyWith(isPreviewMode: !state.isPreviewMode);
  }

  /// Add feedback
  Future<bool> addFeedback({
    required String comment,
    required FeedbackType type,
    String? stopId,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final now = DateTime.now();
      final feedbackRef = _firestore
          .collection('publishing_submissions')
          .doc(submissionId)
          .collection('feedback')
          .doc();

      final feedback = ReviewFeedbackModel(
        id: feedbackRef.id,
        submissionId: submissionId,
        reviewerId: '', // Set by auth
        reviewerName: '', // Set by auth
        type: type,
        message: comment,
        stopId: stopId,
        createdAt: now,
      );

      await feedbackRef.set(feedback.toFirestore());

      state = state.copyWith(
        feedback: [feedback, ...state.feedback],
        isSaving: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to add feedback: $e',
      );
      return false;
    }
  }

  /// Approve submission
  Future<bool> approve() async {
    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final now = DateTime.now();

      // Update submission
      await _firestore
          .collection('publishing_submissions')
          .doc(submissionId)
          .update({
        'status': 'approved',
        'reviewedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update tour status
      await _firestore
          .collection('tours')
          .doc(state.submission!.tourId)
          .update({
        'status': 'approved',
        'liveVersionId': state.submission!.versionId,
        'publishedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      state = state.copyWith(
        submission: state.submission!.copyWith(
          status: SubmissionStatus.approved,
          reviewedAt: now,
        ),
        isSaving: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to approve: $e',
      );
      return false;
    }
  }

  /// Reject submission
  Future<bool> reject({required String reason}) async {
    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final now = DateTime.now();

      // Update submission
      await _firestore
          .collection('publishing_submissions')
          .doc(submissionId)
          .update({
        'status': 'rejected',
        'rejectionReason': reason,
        'reviewedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update tour status
      await _firestore
          .collection('tours')
          .doc(state.submission!.tourId)
          .update({
        'status': 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      state = state.copyWith(
        submission: state.submission!.copyWith(
          status: SubmissionStatus.rejected,
          rejectionReason: reason,
          reviewedAt: now,
        ),
        isSaving: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to reject: $e',
      );
      return false;
    }
  }

  /// Request changes
  Future<bool> requestChanges() async {
    if (state.feedback.isEmpty) {
      state = state.copyWith(error: 'Add feedback before requesting changes');
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final now = DateTime.now();

      // Update submission
      await _firestore
          .collection('publishing_submissions')
          .doc(submissionId)
          .update({
        'status': 'changes_requested',
        'reviewedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update tour status
      await _firestore
          .collection('tours')
          .doc(state.submission!.tourId)
          .update({
        'status': 'draft',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      state = state.copyWith(
        submission: state.submission!.copyWith(
          status: SubmissionStatus.changesRequested,
          reviewedAt: now,
        ),
        isSaving: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to request changes: $e',
      );
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Providers
final publishingProvider = StateNotifierProvider.autoDispose
    .family<PublishingNotifier, PublishingState, ({String tourId, String versionId})>(
  (ref, params) {
    final notifier = PublishingNotifier(
      firestore: FirebaseFirestore.instance,
      tourId: params.tourId,
      versionId: params.versionId,
    );
    notifier.initialize();
    return notifier;
  },
);

final reviewQueueProvider =
    StateNotifierProvider.autoDispose<ReviewQueueNotifier, ReviewQueueState>(
  (ref) {
    final notifier = ReviewQueueNotifier(
      firestore: FirebaseFirestore.instance,
    );
    notifier.loadSubmissions();
    return notifier;
  },
);

final tourReviewProvider = StateNotifierProvider.autoDispose
    .family<TourReviewNotifier, TourReviewState, String>(
  (ref, submissionId) {
    final notifier = TourReviewNotifier(
      firestore: FirebaseFirestore.instance,
      submissionId: submissionId,
    );
    notifier.initialize();
    return notifier;
  },
);
