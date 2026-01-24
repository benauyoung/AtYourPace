import * as admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp();

// Export tour functions
export { onTourSubmitted, onTourApproved, onTourRejected } from './tours/tourFunctions';

// Export audio functions
export { generateElevenLabsAudio } from './audio/elevenLabsAudio';

// Export scheduled functions
export { cleanupExpiredDownloads } from './scheduled/cleanup';
