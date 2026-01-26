'use client';

import { useState } from 'react';
import { format } from 'date-fns';
import { Search, FileText, User, Map } from 'lucide-react';
import { AdminLayout } from '@/components/layout/admin-layout';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { useAuditLogs } from '@/hooks/use-audit-logs';
import { AuditAction, actionDisplayNames } from '@/types';

const actionOptions: { value: AuditAction | 'all'; label: string }[] = [
  { value: 'all', label: 'All Actions' },
  { value: 'tourApproved', label: 'Tour Approved' },
  { value: 'tourRejected', label: 'Tour Rejected' },
  { value: 'tourHidden', label: 'Tour Hidden' },
  { value: 'tourUnhidden', label: 'Tour Unhidden' },
  { value: 'tourFeatured', label: 'Tour Featured' },
  { value: 'tourUnfeatured', label: 'Tour Unfeatured' },
  { value: 'userRoleChanged', label: 'Role Changed' },
  { value: 'userBanned', label: 'User Banned' },
  { value: 'userUnbanned', label: 'User Unbanned' },
  { value: 'settingsUpdated', label: 'Settings Updated' },
];

function getActionBadgeVariant(action: AuditAction): 'default' | 'secondary' | 'destructive' | 'outline' {
  if (action.includes('Approved') || action.includes('Unbanned') || action.includes('Unhidden')) {
    return 'default';
  }
  if (action.includes('Rejected') || action.includes('Banned') || action.includes('Hidden')) {
    return 'destructive';
  }
  if (action.includes('Featured') || action.includes('Role')) {
    return 'secondary';
  }
  return 'outline';
}

function getTargetIcon(targetType?: string) {
  switch (targetType) {
    case 'tour':
      return <Map className="h-3 w-3" />;
    case 'user':
      return <User className="h-3 w-3" />;
    default:
      return <FileText className="h-3 w-3" />;
  }
}

export default function AuditLogsPage() {
  const [actionFilter, setActionFilter] = useState<AuditAction | 'all'>('all');
  const [searchQuery, setSearchQuery] = useState('');

  const { data: logs, isLoading } = useAuditLogs({
    action: actionFilter === 'all' ? undefined : actionFilter,
    limitCount: 100,
  });

  const filteredLogs = logs?.filter((log) => {
    if (searchQuery) {
      const search = searchQuery.toLowerCase();
      return (
        log.adminEmail.toLowerCase().includes(search) ||
        log.targetId?.toLowerCase().includes(search)
      );
    }
    return true;
  });

  return (
    <AdminLayout title="Audit Logs">
      <Card>
        <CardHeader>
          <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <CardTitle>Audit Logs</CardTitle>
            <div className="flex items-center gap-2">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  placeholder="Search by admin or target..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full pl-9 sm:w-64"
                />
              </div>
              <Select
                value={actionFilter}
                onValueChange={(v) => setActionFilter(v as AuditAction | 'all')}
              >
                <SelectTrigger className="w-44">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {actionOptions.map((option) => (
                    <SelectItem key={option.value} value={option.value}>
                      {option.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="flex items-center justify-center py-8">
              <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
            </div>
          ) : filteredLogs && filteredLogs.length > 0 ? (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Timestamp</TableHead>
                  <TableHead>Admin</TableHead>
                  <TableHead>Action</TableHead>
                  <TableHead>Target</TableHead>
                  <TableHead>Details</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredLogs.map((log) => (
                  <TableRow key={log.id}>
                    <TableCell className="text-muted-foreground">
                      {format(log.timestamp, 'MMM d, yyyy h:mm a')}
                    </TableCell>
                    <TableCell>
                      <span className="font-medium">{log.adminEmail}</span>
                    </TableCell>
                    <TableCell>
                      <Badge variant={getActionBadgeVariant(log.action)}>
                        {actionDisplayNames[log.action]}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      {log.targetId ? (
                        <div className="flex items-center gap-2">
                          {getTargetIcon(log.targetType)}
                          <span className="font-mono text-xs">
                            {log.targetId.slice(0, 8)}...
                          </span>
                        </div>
                      ) : (
                        <span className="text-muted-foreground">-</span>
                      )}
                    </TableCell>
                    <TableCell>
                      {log.details ? (
                        <div className="max-w-xs truncate text-sm text-muted-foreground">
                          {Object.entries(log.details)
                            .map(([key, value]) => `${key}: ${value}`)
                            .join(', ')}
                        </div>
                      ) : (
                        <span className="text-muted-foreground">-</span>
                      )}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          ) : (
            <div className="py-8 text-center text-muted-foreground">
              No audit logs found
            </div>
          )}
        </CardContent>
      </Card>
    </AdminLayout>
  );
}
