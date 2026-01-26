'use client';

import { useQuery } from '@tanstack/react-query';
import { getAuditLogs } from '@/lib/firebase/admin';
import { AuditAction } from '@/types';

interface AuditLogsFilters {
  adminId?: string;
  action?: AuditAction;
  targetId?: string;
  limitCount?: number;
}

export function useAuditLogs(filters?: AuditLogsFilters) {
  return useQuery({
    queryKey: ['auditLogs', filters],
    queryFn: () => getAuditLogs(filters),
  });
}
