import { initializeApp, getApps } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';
import { getFunctions } from 'firebase/functions';

const firebaseConfig = {
  apiKey: 'AIzaSyA0DIMgU5RwGoKedE68K4iWTft1XAuXs9c',
  appId: '1:144690156112:web:623a40fd0b8345b460f755',
  messagingSenderId: '144690156112',
  projectId: 'atyourpace-6a6e5',
  authDomain: 'atyourpace-6a6e5.firebaseapp.com',
  storageBucket: 'atyourpace-6a6e5.firebasestorage.app',
  measurementId: 'G-4P0NJDRL77',
};

// Initialize Firebase
const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApps()[0];

export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);
export const functions = getFunctions(app);

export default app;
