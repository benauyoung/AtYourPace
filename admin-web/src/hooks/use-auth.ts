'use client';

import { useState, useEffect, createContext, useContext } from 'react';
import { User } from 'firebase/auth';
import { onAuthChange, checkUserRole } from '@/lib/firebase/auth';
import { getCurrentUserData } from '@/lib/firebase/admin';
import { UserModel, UserRole } from '@/types';

type ViewMode = 'admin' | 'creator';

interface AuthContextType {
  user: User | null;
  userData: UserModel | null;
  role: UserRole | null;
  isAdmin: boolean;
  isCreator: boolean;
  isLoading: boolean;
  error: string | null;
  viewMode: ViewMode;
  setViewMode: (mode: ViewMode) => void;
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  userData: null,
  role: null,
  isAdmin: false,
  isCreator: false,
  isLoading: true,
  error: null,
  viewMode: 'creator',
  setViewMode: () => {},
});

export function useAuth() {
  return useContext(AuthContext);
}

export function useAuthState() {
  const [viewMode, setViewMode] = useState<ViewMode>('creator');
  const [state, setState] = useState<Omit<AuthContextType, 'viewMode' | 'setViewMode'>>({
    user: null,
    userData: null,
    role: null,
    isAdmin: false,
    isCreator: false,
    isLoading: true,
    error: null,
  });

  useEffect(() => {
    const unsubscribe = onAuthChange(async (user) => {
      if (user) {
        try {
          const { role, isAdmin, isCreator } = await checkUserRole(user.uid);

          // Only allow admin or creator roles
          if (!isAdmin && !isCreator) {
            setState({
              user: null,
              userData: null,
              role: null,
              isAdmin: false,
              isCreator: false,
              isLoading: false,
              error: 'Creator or admin access required',
            });
            return;
          }

          const userData = await getCurrentUserData();
          setState({
            user,
            userData,
            role,
            isAdmin,
            isCreator,
            isLoading: false,
            error: null,
          });
        } catch (error) {
          setState({
            user: null,
            userData: null,
            role: null,
            isAdmin: false,
            isCreator: false,
            isLoading: false,
            error: error instanceof Error ? error.message : 'Failed to verify user status',
          });
        }
      } else {
        setState({
          user: null,
          userData: null,
          role: null,
          isAdmin: false,
          isCreator: false,
          isLoading: false,
          error: null,
        });
      }
    });

    return unsubscribe;
  }, []);

  return { ...state, viewMode, setViewMode };
}

export { AuthContext };
export type { ViewMode };
