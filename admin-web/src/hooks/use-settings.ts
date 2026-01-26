'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { getAppSettings, updateAppSettings } from '@/lib/firebase/admin';
import { AppSettings } from '@/types';

export function useAppSettings() {
  return useQuery({
    queryKey: ['appSettings'],
    queryFn: getAppSettings,
  });
}

export function useUpdateAppSettings() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (settings: Partial<AppSettings>) => updateAppSettings(settings),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['appSettings'] });
      queryClient.invalidateQueries({ queryKey: ['auditLogs'] });
    },
  });
}
