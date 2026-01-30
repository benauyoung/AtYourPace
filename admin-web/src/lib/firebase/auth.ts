import {
  signInWithEmailAndPassword,
  signOut as firebaseSignOut,
  onAuthStateChanged,
  User,
} from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
import { auth, db } from './config';
import { UserModel, UserRole } from '@/types';

export interface AuthUser extends User {
  role?: UserRole;
  userData?: UserModel;
}

export interface SignInResult {
  user: User;
  role: UserRole;
  isAdmin: boolean;
  isCreator: boolean;
}

export async function signIn(
  email: string,
  password: string
): Promise<SignInResult> {
  const credential = await signInWithEmailAndPassword(auth, email, password);
  const user = credential.user;

  // Check user role
  const userRef = doc(db, 'users', user.uid);
  let userDoc = await getDoc(userRef);

  // Auto-create user document if it doesn't exist (bypass for initial setup)
  if (!userDoc.exists()) {
    const { setDoc } = await import('firebase/firestore');
    const now = new Date();
    await setDoc(userRef, {
      email: user.email,
      displayName: user.displayName || user.email?.split('@')[0] || 'Admin',
      role: 'admin', // Default to admin for first-time setup
      createdAt: now,
      updatedAt: now,
    });
    userDoc = await getDoc(userRef);
  }

  const userData = userDoc.data()!;
  const role = userData.role as UserRole;
  const isAdmin = role === 'admin';
  const isCreator = role === 'creator' || role === 'admin'; // Admins can also act as creators

  // Only allow admin or creator roles to access the web panel
  if (role === 'user') {
    await firebaseSignOut(auth);
    throw new Error('Creator or admin access required');
  }

  return { user, role, isAdmin, isCreator };
}

export async function signOut(): Promise<void> {
  await firebaseSignOut(auth);
}

export function onAuthChange(callback: (user: User | null) => void): () => void {
  return onAuthStateChanged(auth, callback);
}

export async function checkIsAdmin(userId: string): Promise<boolean> {
  const userDoc = await getDoc(doc(db, 'users', userId));
  if (!userDoc.exists()) return false;
  return userDoc.data().role === 'admin';
}

export async function checkUserRole(userId: string): Promise<{ role: UserRole; isAdmin: boolean; isCreator: boolean }> {
  const userDoc = await getDoc(doc(db, 'users', userId));
  if (!userDoc.exists()) {
    return { role: 'user', isAdmin: false, isCreator: false };
  }
  const role = userDoc.data().role as UserRole;
  return {
    role,
    isAdmin: role === 'admin',
    isCreator: role === 'creator' || role === 'admin',
  };
}
