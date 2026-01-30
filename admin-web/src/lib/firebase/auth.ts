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

  // Skip Firestore check - treat all authenticated users as admin for now
  return { user, role: 'admin', isAdmin: true, isCreator: true };
}

export async function signOut(): Promise<void> {
  await firebaseSignOut(auth);
}

export function onAuthChange(callback: (user: User | null) => void): () => void {
  return onAuthStateChanged(auth, callback);
}

export async function checkIsAdmin(userId: string): Promise<boolean> {
  // Skip Firestore check - treat all authenticated users as admin for now
  return true;
}

export async function checkUserRole(userId: string): Promise<{ role: UserRole; isAdmin: boolean; isCreator: boolean }> {
  // Skip Firestore check - treat all authenticated users as admin for now
  return { role: 'admin', isAdmin: true, isCreator: true };
}
