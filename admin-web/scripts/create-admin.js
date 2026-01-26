/**
 * Script to create a test admin account
 *
 * Usage:
 *   node scripts/create-admin.js
 *
 * Uses Application Default Credentials from Firebase CLI login
 */

const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

// Configuration
const TEST_ADMIN_EMAIL = 'admin@test.com';
const TEST_ADMIN_PASSWORD = 'admin123';
const TEST_ADMIN_NAME = 'Test Admin';
const PROJECT_ID = 'atyourpace-6a6e5';

// Look for service account key first
const serviceAccountPaths = [
  path.join(__dirname, '..', 'service-account.json'),
  path.join(__dirname, '..', '..', 'service-account.json'),
  path.join(__dirname, '..', 'serviceAccountKey.json'),
  path.join(__dirname, '..', '..', 'serviceAccountKey.json'),
];

let serviceAccountPath = null;
for (const p of serviceAccountPaths) {
  if (fs.existsSync(p)) {
    serviceAccountPath = p;
    break;
  }
}

// Initialize Firebase Admin
if (serviceAccountPath) {
  const serviceAccount = require(serviceAccountPath);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  console.log('Using service account credentials');
} else {
  // Use Application Default Credentials (from Firebase CLI or gcloud)
  admin.initializeApp({
    projectId: PROJECT_ID,
  });
  console.log('Using Application Default Credentials');
}

const auth = admin.auth();
const db = admin.firestore();

async function createAdminUser() {
  console.log('Creating test admin account...');
  console.log(`  Email: ${TEST_ADMIN_EMAIL}`);
  console.log(`  Password: ${TEST_ADMIN_PASSWORD}`);
  console.log('');

  try {
    // Check if user already exists
    let user;
    try {
      user = await auth.getUserByEmail(TEST_ADMIN_EMAIL);
      console.log('User already exists in Auth, updating...');
    } catch (e) {
      if (e.code === 'auth/user-not-found') {
        // Create new user
        user = await auth.createUser({
          email: TEST_ADMIN_EMAIL,
          password: TEST_ADMIN_PASSWORD,
          displayName: TEST_ADMIN_NAME,
          emailVerified: true,
        });
        console.log('Created user in Firebase Auth');
      } else {
        throw e;
      }
    }

    // Create/update user document in Firestore
    const userDoc = {
      email: TEST_ADMIN_EMAIL,
      displayName: TEST_ADMIN_NAME,
      role: 'admin',
      preferences: {
        autoPlayAudio: true,
        triggerMode: 'geofence',
        offlineEnabled: true,
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await db.collection('users').doc(user.uid).set(userDoc, { merge: true });
    console.log('Created/updated user document in Firestore');

    console.log('');
    console.log('✓ Admin account created successfully!');
    console.log('');
    console.log('You can now log in with:');
    console.log(`  Email: ${TEST_ADMIN_EMAIL}`);
    console.log(`  Password: ${TEST_ADMIN_PASSWORD}`);

  } catch (error) {
    console.error('Error creating admin user:', error.message);
    process.exit(1);
  }

  process.exit(0);
}

createAdminUser();
