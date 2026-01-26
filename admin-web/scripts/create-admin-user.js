// Script to create admin user document in Firestore
// Run with: node scripts/create-admin-user.js

const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

// Initialize without service account - uses default credentials or emulator
// For production, you'd use: cert(require('./serviceAccountKey.json'))
initializeApp({
  projectId: 'atyourpace-6a6e5',
});

const db = getFirestore();

async function createAdminUser() {
  const userId = 'cDHkMvjyJfR0EjWCb6w1SWa29653';

  const userData = {
    uid: userId,
    email: 'relaylegacy@gmail.com',
    displayName: 'Admin User',
    role: 'admin',
    createdAt: new Date(),
    updatedAt: new Date(),
    preferences: {
      autoPlayAudio: true,
      triggerMode: 'geofence',
      offlineEnabled: false,
    },
  };

  try {
    await db.collection('users').doc(userId).set(userData);
    console.log('Admin user document created successfully!');
    console.log('You can now log in with:');
    console.log('  Email: relaylegacy@gmail.com');
    console.log('  Password: diehard');
  } catch (error) {
    console.error('Error creating user document:', error.message);
    console.log('\nIf you see a credentials error, you need to either:');
    console.log('1. Run: gcloud auth application-default login');
    console.log('2. Or set GOOGLE_APPLICATION_CREDENTIALS to your service account key');
  }

  process.exit(0);
}

createAdminUser();
