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
  const userDoc = await getDoc(doc(db, 'users', user.uid));
  if (!userDoc.exists()) {
    await firebaseSignOut(auth);
    throw new Error('User account not found');
  }

  const userData = userDoc.data();
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
