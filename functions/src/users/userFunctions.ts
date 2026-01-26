import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { sendWelcomeEmail } from '../emails/emailService';

const db = admin.firestore();

/**
 * Triggered when a new user document is created.
 * Sends welcome email if the user has creator role.
 */
export const onUserCreated = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snapshot, context) => {
    const userData = snapshot.data();
    const userId = context.params.userId;

    // Check if this is a creator
    const isCreator =
      userData.role === 'creator' ||
      userData.roles?.includes('creator') ||
      userData.isCreator === true;

    if (!isCreator) {
      functions.logger.info(`User ${userId} is not a creator, skipping welcome email`);
      return;
    }

    if (!userData.email) {
      functions.logger.warn(`User ${userId} has no email, skipping welcome email`);
      return;
    }

    functions.logger.info(`Sending welcome email to new creator ${userId}`);

    await sendWelcomeEmail({
      creatorName: userData.displayName || userData.name || 'Creator',
      creatorEmail: userData.email,
    });

    // Update user document to mark welcome email as sent
    await db.collection('users').doc(userId).update({
      welcomeEmailSent: true,
      welcomeEmailSentAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

/**
 * Triggered when a user document is updated.
 * Sends welcome email if user became a creator and hasn't received one yet.
 */
export const onUserUpdated = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const userId = context.params.userId;

    // Check if user just became a creator
    const wasCreator =
      before.role === 'creator' ||
      before.roles?.includes('creator') ||
      before.isCreator === true;

    const isCreator =
      after.role === 'creator' ||
      after.roles?.includes('creator') ||
      after.isCreator === true;

    // Only send if they just became a creator and haven't received welcome email
    if (!wasCreator && isCreator && !after.welcomeEmailSent) {
      if (!after.email) {
        functions.logger.warn(`User ${userId} has no email, skipping welcome email`);
        return;
      }

      functions.logger.info(`Sending welcome email to newly promoted creator ${userId}`);

      await sendWelcomeEmail({
        creatorName: after.displayName || after.name || 'Creator',
        creatorEmail: after.email,
      });

      // Update user document to mark welcome email as sent
      await change.after.ref.update({
        welcomeEmailSent: true,
        welcomeEmailSentAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  });
