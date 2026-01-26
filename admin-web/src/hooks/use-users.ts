'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  getUsers,
  updateUserRole,
  banUser,
  unbanUser,
  getUserStats,
} from '@/lib/firebase/admin';
import { UserRole } from '@/types';

interface UsersFilters {
  role?: UserRole;
  searchQuery?: string;
}

export function useUsers(filters?: UsersFilters) {
  return useQuery({
    queryKey: ['users', filters],
    queryFn: () => getUsers(filters),
  });
}

export function useUserStats() {
  return useQuery({
    queryKey: ['userStats'],
    queryFn: getUserStats,
  });
}

export function useUpdateUserRole() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      userId,
      role,
      reason,
    }: {
      userId: string;
      role: UserRole;
      reason?: string;
    }) => updateUserRole(userId, role, reason),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      queryClient.invalidateQueries({ queryKey: ['userStats'] });
      queryClient.invalidateQueries({ queryKey: ['auditLogs'] });
    },
  });
}

export function useBanUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ userId, reason }: { userId: string; reason?: string }) =>
      banUser(userId, reason),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      queryClient.invalidateQueries({ queryKey: ['userStats'] });
      queryClient.invalidateQueries({ queryKey: ['auditLogs'] });
    },
  });
}

export function useUnbanUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (userId: string) => unbanUser(userId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      queryClient.invalidateQueries({ queryKey: ['userStats'] });
      queryClient.invalidateQueries({ queryKey: ['auditLogs'] });
    },
  });
}
