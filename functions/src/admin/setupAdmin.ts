import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * One-time setup function to create the initial admin user.
 * This should be called once to bootstrap the admin account.
 *
 * Call via: https://us-central1-atyourpace-6a6e5.cloudfunctions.net/setupInitialAdmin
 */
export const setupInitialAdmin = functions.https.onRequest(async (req, res) => {
  // Only allow POST requests
  if (req.method !== 'POST') {
    res.status(405).send('Method not allowed');
    return;
  }

  const userId = 'cDHkMvjyJfR0EjWCb6w1SWa29653';
  const email = 'relaylegacy@gmail.com';

  try {
    // Check if user already exists
    const existingUser = await db.collection('users').doc(userId).get();
    if (existingUser.exists) {
      res.status(200).json({
        success: true,
        message: 'Admin user already exists',
        userId
      });
      return;
    }

    // Create the admin user document
    const userData = {
      uid: userId,
      email: email,
      displayName: 'Admin User',
      role: 'admin',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      preferences: {
        autoPlayAudio: true,
        triggerMode: 'geofence',
        offlineEnabled: false,
      },
    };

    await db.collection('users').doc(userId).set(userData);

    res.status(200).json({
      success: true,
      message: 'Admin user created successfully',
      userId,
      email
    });
  } catch (error) {
    console.error('Error creating admin user:', error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});
