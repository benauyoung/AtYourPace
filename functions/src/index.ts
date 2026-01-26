import * as admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp();

// Export tour functions
export { onTourSubmitted, onTourApproved, onTourRejected } from './tours/tourFunctions';

// Export user functions (email notifications)
export { onUserCreated, onUserUpdated } from './users/userFunctions';

// Export audio functions
export { generateElevenLabsAudio } from './audio/elevenLabsAudio';

// Export scheduled functions
export { cleanupExpiredDownloads } from './scheduled/cleanup';

// Export admin setup function (temporary - remove after initial setup)
export { setupInitialAdmin } from './admin/setupAdmin';

// Export seed data function (temporary - remove after testing)
export { seedTestTour, seedClamartTour } from './admin/seedData';
