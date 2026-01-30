import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Submission status types
 */
type SubmissionStatus =
  | 'draft'
  | 'submitted'
  | 'under_review'
  | 'changes_requested'
  | 'approved'
  | 'rejected'
  | 'withdrawn';

/**
 * Triggered when a new publishing submission is created.
 * Notifies admins and updates tour status.
 */
export const onSubmissionCreated = functions.firestore
  .document('publishingSubmissions/{submissionId}')
  .onCreate(async (snapshot, context) => {
    const submission = snapshot.data();
    const submissionId = context.params.submissionId;

    functions.logger.info(`New submission created: ${submissionId}`, {
      tourId: submission.tourId,
      creatorId: submission.creatorId,
    });

    // Update the tour status to pending_review
    await db.collection('tours').doc(submission.tourId).update({
      status: 'pending_review',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Create audit log entry
    await db.collection('auditLogs').add({
      action: 'submission_created',
      targetId: submission.tourId,
      targetType: 'tour',
      submissionId,
      creatorId: submission.creatorId,
      creatorName: submission.creatorName,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    // TODO: Send notification to admins
    // TODO: Send confirmation email to creator

    functions.logger.info(`Submission ${submissionId} processed successfully`);
  });

/**
 * Triggered when a submission is updated.
 * Handles status transitions and notifications.
 */
export const onSubmissionUpdated = functions.firestore
  .document('publishingSubmissions/{submissionId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const submissionId = context.params.submissionId;

    const oldStatus = before.status as SubmissionStatus;
    const newStatus = after.status as SubmissionStatus;

    // If status didn't change, nothing to do
    if (oldStatus === newStatus) {
      return;
    }

    functions.logger.info(`Submission ${submissionId} status changed: ${oldStatus} -> ${newStatus}`);

    switch (newStatus) {
      case 'under_review':
        await handleUnderReview(submissionId, after);
        break;
      case 'changes_requested':
        await handleChangesRequested(submissionId, after);
        break;
      case 'approved':
        await handleApproved(submissionId, after);
        break;
      case 'rejected':
        await handleRejected(submissionId, after);
        break;
      case 'withdrawn':
        await handleWithdrawn(submissionId, after);
        break;
      case 'submitted':
        // Resubmission
        if (oldStatus === 'changes_requested') {
          await handleResubmission(submissionId, after);
        }
        break;
    }
  });

/**
 * Handle submission claimed for review.
 */
async function handleUnderReview(submissionId: string, submission: FirebaseFirestore.DocumentData) {
  functions.logger.info(`Submission ${submissionId} is now under review by ${submission.reviewerName}`);

  // Create audit log
  await db.collection('auditLogs').add({
    action: 'submission_under_review',
    targetId: submission.tourId,
    targetType: 'tour',
    submissionId,
    reviewerId: submission.reviewerId,
    reviewerName: submission.reviewerName,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  // TODO: Send notification to creator that their submission is being reviewed
}

/**
 * Handle changes requested on a submission.
 */
async function handleChangesRequested(submissionId: string, submission: FirebaseFirestore.DocumentData) {
  functions.logger.info(`Changes requested for submission ${submissionId}`);

  // Update tour status back to draft
  await db.collection('tours').doc(submission.tourId).update({
    status: 'draft',
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Create audit log
  await db.collection('auditLogs').add({
    action: 'submission_changes_requested',
    targetId: submission.tourId,
    targetType: 'tour',
    submissionId,
    reviewerId: submission.reviewerId,
    reviewerName: submission.reviewerName,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Send notification to creator
  const creator = await db.collection('users').doc(submission.creatorId).get();
  const creatorData = creator.data();

  if (creatorData?.email) {
    // TODO: Send email with feedback details
    functions.logger.info(`Would send changes requested email to ${creatorData.email}`);
  }
}

/**
 * Handle submission approved.
 */
async function handleApproved(submissionId: string, submission: FirebaseFirestore.DocumentData) {
  functions.logger.info(`Submission ${submissionId} approved`);

  const batch = db.batch();
  const tourRef = db.collection('tours').doc(submission.tourId);

  // Get tour data
  const tourDoc = await tourRef.get();
  const tourData = tourDoc.data();

  if (!tourData) {
    functions.logger.error(`Tour ${submission.tourId} not found`);
    return;
  }

  // Update tour status to approved
  batch.update(tourRef, {
    status: 'approved',
    approvedAt: admin.firestore.FieldValue.serverTimestamp(),
    lastReviewedAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Archive old live version if exists
  if (tourData.liveVersionId && tourData.liveVersionId !== submission.versionId) {
    const oldLiveRef = tourRef.collection('versions').doc(tourData.liveVersionId);
    batch.update(oldLiveRef, {
      versionType: 'archived',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  // Promote submitted version to live
  const versionRef = tourRef.collection('versions').doc(submission.versionId);
  batch.update(versionRef, {
    versionType: 'live',
    reviewedAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Update live version reference
  batch.update(tourRef, {
    liveVersionId: submission.versionId,
    publishedAt: tourData.liveVersionId === null
      ? admin.firestore.FieldValue.serverTimestamp()
      : tourData.publishedAt,
  });

  await batch.commit();

  // Create audit log
  await db.collection('auditLogs').add({
    action: 'submission_approved',
    targetId: submission.tourId,
    targetType: 'tour',
    submissionId,
    reviewerId: submission.reviewerId,
    reviewerName: submission.reviewerName,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Send notification to creator
  const creator = await db.collection('users').doc(submission.creatorId).get();
  const creatorData = creator.data();

  if (creatorData?.email) {
    // TODO: Send approval email
    functions.logger.info(`Would send approval email to ${creatorData.email}`);
  }

  functions.logger.info(`Tour ${submission.tourId} promoted to live`);
}

/**
 * Handle submission rejected.
 */
async function handleRejected(submissionId: string, submission: FirebaseFirestore.DocumentData) {
  functions.logger.info(`Submission ${submissionId} rejected`);

  // Update tour status to rejected
  await db.collection('tours').doc(submission.tourId).update({
    status: 'rejected',
    rejectedAt: admin.firestore.FieldValue.serverTimestamp(),
    rejectionReason: submission.rejectionReason,
    lastReviewedAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Create audit log
  await db.collection('auditLogs').add({
    action: 'submission_rejected',
    targetId: submission.tourId,
    targetType: 'tour',
    submissionId,
    reviewerId: submission.reviewerId,
    reviewerName: submission.reviewerName,
    reason: submission.rejectionReason,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Send notification to creator
  const creator = await db.collection('users').doc(submission.creatorId).get();
  const creatorData = creator.data();

  if (creatorData?.email) {
    // TODO: Send rejection email with reason
    functions.logger.info(`Would send rejection email to ${creatorData.email}`);
  }
}

/**
 * Handle submission withdrawn by creator.
 */
async function handleWithdrawn(submissionId: string, submission: FirebaseFirestore.DocumentData) {
  functions.logger.info(`Submission ${submissionId} withdrawn by creator`);

  // Update tour status back to draft
  await db.collection('tours').doc(submission.tourId).update({
    status: 'draft',
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Create audit log
  await db.collection('auditLogs').add({
    action: 'submission_withdrawn',
    targetId: submission.tourId,
    targetType: 'tour',
    submissionId,
    creatorId: submission.creatorId,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Handle resubmission after changes.
 */
async function handleResubmission(submissionId: string, submission: FirebaseFirestore.DocumentData) {
  functions.logger.info(`Submission ${submissionId} resubmitted (attempt ${submission.resubmissionCount})`);

  // Update tour status to pending_review
  await db.collection('tours').doc(submission.tourId).update({
    status: 'pending_review',
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Create audit log
  await db.collection('auditLogs').add({
    action: 'submission_resubmitted',
    targetId: submission.tourId,
    targetType: 'tour',
    submissionId,
    creatorId: submission.creatorId,
    resubmissionCount: submission.resubmissionCount,
    ignoredSuggestions: submission.creatorIgnoredSuggestions,
    justification: submission.resubmissionJustification,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  // TODO: Notify admins of resubmission
}

/**
 * Triggered when feedback is added to a submission.
 * Notifies the creator.
 */
export const onFeedbackCreated = functions.firestore
  .document('publishingSubmissions/{submissionId}/reviewFeedback/{feedbackId}')
  .onCreate(async (snapshot, context) => {
    const feedback = snapshot.data();
    const submissionId = context.params.submissionId;
    const feedbackId = context.params.feedbackId;

    functions.logger.info(`New feedback ${feedbackId} added to submission ${submissionId}`);

    // Get submission to find creator
    const submissionDoc = await db.collection('publishingSubmissions').doc(submissionId).get();
    const submission = submissionDoc.data();

    if (!submission) {
      functions.logger.error(`Submission ${submissionId} not found`);
      return;
    }

    // Create audit log
    await db.collection('auditLogs').add({
      action: 'feedback_added',
      targetId: submission.tourId,
      targetType: 'tour',
      submissionId,
      feedbackId,
      feedbackType: feedback.type,
      reviewerId: feedback.reviewerId,
      reviewerName: feedback.reviewerName,
      stopId: feedback.stopId || null,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    // TODO: Send real-time notification to creator
  });
