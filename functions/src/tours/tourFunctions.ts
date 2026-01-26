import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { sendTourApprovedEmail, sendTourRejectedEmail } from '../emails/emailService';

const db = admin.firestore();

/**
 * Triggered when a tour is submitted for review.
 * Creates an entry in the review queue and notifies admins.
 */
export const onTourSubmitted = functions.firestore
  .document('tours/{tourId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const tourId = context.params.tourId;

    // Check if status changed to pending_review
    if (before.status !== 'pending_review' && after.status === 'pending_review') {
      functions.logger.info(`Tour ${tourId} submitted for review`);

      // Get the draft version to include the title
      const draftVersionDoc = await db
        .collection('tours')
        .doc(tourId)
        .collection('versions')
        .doc(after.draftVersionId)
        .get();

      const draftVersion = draftVersionDoc.data();

      // Create entry in review queue
      await db.collection('reviewQueue').add({
        tourId,
        versionId: after.draftVersionId,
        creatorId: after.creatorId,
        creatorName: after.creatorName,
        tourTitle: draftVersion?.title || 'Untitled Tour',
        submittedAt: admin.firestore.FieldValue.serverTimestamp(),
        status: 'pending',
        priority: 0,
      });

      // TODO: Send push notification to admins
      // TODO: Send email notification to admins

      functions.logger.info(`Review queue entry created for tour ${tourId}`);
    }
  });

/**
 * Triggered when an admin approves a tour.
 * Promotes the draft version to live.
 */
export const onTourApproved = functions.firestore
  .document('tours/{tourId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const tourId = context.params.tourId;

    // Check if status changed to approved
    if (before.status !== 'approved' && after.status === 'approved') {
      functions.logger.info(`Tour ${tourId} approved`);

      const batch = db.batch();
      const tourRef = db.collection('tours').doc(tourId);

      // Archive the old live version if it exists
      if (before.liveVersionId && before.liveVersionId !== after.draftVersionId) {
        const oldLiveRef = tourRef
          .collection('versions')
          .doc(before.liveVersionId);
        batch.update(oldLiveRef, {
          versionType: 'archived',
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      // Promote draft to live
      const draftRef = tourRef.collection('versions').doc(after.draftVersionId);
      batch.update(draftRef, {
        versionType: 'live',
        reviewedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Update tour metadata
      batch.update(tourRef, {
        liveVersionId: after.draftVersionId,
        liveVersion: after.draftVersion,
        publishedAt:
          before.liveVersionId === null
            ? admin.firestore.FieldValue.serverTimestamp()
            : before.publishedAt,
        lastReviewedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // Mark review queue item as completed
      const reviewQueueSnapshot = await db
        .collection('reviewQueue')
        .where('tourId', '==', tourId)
        .where('versionId', '==', after.draftVersionId)
        .where('status', '!=', 'completed')
        .get();

      for (const doc of reviewQueueSnapshot.docs) {
        await doc.ref.update({
          status: 'completed',
        });
      }

      // Send notification to creator about approval
      const draftVersionDoc = await db
        .collection('tours')
        .doc(tourId)
        .collection('versions')
        .doc(after.draftVersionId)
        .get();

      const draftVersion = draftVersionDoc.data();

      // Get creator email from users collection
      const creatorDoc = await db.collection('users').doc(after.creatorId).get();
      const creator = creatorDoc.data();

      if (creator?.email && draftVersion?.title) {
        await sendTourApprovedEmail({
          creatorName: after.creatorName || creator.displayName || 'Creator',
          creatorEmail: creator.email,
          tourTitle: draftVersion.title,
          tourId,
          notes: after.reviewNotes,
        });
      }

      functions.logger.info(`Tour ${tourId} promoted to live`);
    }
  });

/**
 * Triggered when an admin rejects a tour.
 * Sends feedback to the creator.
 */
export const onTourRejected = functions.firestore
  .document('tours/{tourId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const tourId = context.params.tourId;

    // Check if status changed to rejected
    if (before.status !== 'rejected' && after.status === 'rejected') {
      functions.logger.info(`Tour ${tourId} rejected`);

      // Mark review queue item as completed
      const reviewQueueSnapshot = await db
        .collection('reviewQueue')
        .where('tourId', '==', tourId)
        .where('status', '!=', 'completed')
        .get();

      for (const doc of reviewQueueSnapshot.docs) {
        await doc.ref.update({
          status: 'completed',
        });
      }

      // Update the draft version with review notes
      if (after.draftVersionId) {
        await db
          .collection('tours')
          .doc(tourId)
          .collection('versions')
          .doc(after.draftVersionId)
          .update({
            reviewedAt: admin.firestore.FieldValue.serverTimestamp(),
            // reviewNotes should be set by the admin when rejecting
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
      }

      // Send notification to creator about rejection with feedback
      const draftVersionDoc = await db
        .collection('tours')
        .doc(tourId)
        .collection('versions')
        .doc(after.draftVersionId)
        .get();

      const draftVersion = draftVersionDoc.data();

      // Get creator email from users collection
      const creatorDoc = await db.collection('users').doc(after.creatorId).get();
      const creator = creatorDoc.data();

      if (creator?.email && draftVersion?.title) {
        await sendTourRejectedEmail({
          creatorName: after.creatorName || creator.displayName || 'Creator',
          creatorEmail: creator.email,
          tourTitle: draftVersion.title,
          tourId,
          reason: after.rejectionReason || 'Your tour needs some changes before it can be approved.',
        });
      }

      functions.logger.info(`Tour ${tourId} rejection processed`);
    }
  });
