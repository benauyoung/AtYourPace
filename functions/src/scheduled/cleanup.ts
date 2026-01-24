import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Scheduled function to clean up expired tour downloads.
 * Runs daily at midnight UTC.
 */
export const cleanupExpiredDownloads = functions.pubsub
  .schedule('0 0 * * *') // Run at midnight UTC every day
  .timeZone('UTC')
  .onRun(async () => {
    functions.logger.info('Starting expired downloads cleanup');

    const now = admin.firestore.Timestamp.now();
    let totalDeleted = 0;

    try {
      // Get all users
      const usersSnapshot = await db.collection('users').get();

      for (const userDoc of usersSnapshot.docs) {
        const userId = userDoc.id;

        // Get expired downloads for this user
        const expiredDownloads = await db
          .collection('users')
          .doc(userId)
          .collection('downloads')
          .where('expiresAt', '<', now)
          .get();

        if (expiredDownloads.empty) {
          continue;
        }

        const batch = db.batch();

        for (const downloadDoc of expiredDownloads.docs) {
          batch.delete(downloadDoc.ref);
          totalDeleted++;
        }

        await batch.commit();
        functions.logger.info(
          `Deleted ${expiredDownloads.size} expired downloads for user ${userId}`
        );
      }

      functions.logger.info(
        `Cleanup completed. Total expired downloads deleted: ${totalDeleted}`
      );
    } catch (error) {
      functions.logger.error('Error during cleanup:', error);
      throw error;
    }
  });

/**
 * Scheduled function to clean up old rate limit records.
 * Runs hourly to keep the collection size manageable.
 */
export const cleanupRateLimits = functions.pubsub
  .schedule('0 * * * *') // Run at the start of every hour
  .timeZone('UTC')
  .onRun(async () => {
    functions.logger.info('Starting rate limits cleanup');

    // Delete records older than 1 hour
    const oneHourAgo = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 60 * 60 * 1000)
    );

    try {
      const oldRecords = await db
        .collection('rateLimits')
        .doc('elevenlabs')
        .collection('requests')
        .where('requestedAt', '<', oneHourAgo)
        .limit(500) // Process in batches to avoid timeout
        .get();

      if (oldRecords.empty) {
        functions.logger.info('No old rate limit records to clean up');
        return;
      }

      const batch = db.batch();
      oldRecords.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      functions.logger.info(
        `Deleted ${oldRecords.size} old rate limit records`
      );
    } catch (error) {
      functions.logger.error('Error during rate limits cleanup:', error);
      throw error;
    }
  });
