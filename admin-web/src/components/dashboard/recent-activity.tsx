'use client';

import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { useAuditLogs } from '@/hooks/use-audit-logs';
import { AuditLogEntry } from '@/types';
import { formatDistanceToNow } from 'date-fns';

export function RecentActivity() {
    const { data: logs, isLoading } = useAuditLogs({ limitCount: 5 });

    if (isLoading) {
        return <ActivitySkeleton />;
    }

    return (
        <Card className="col-span-4 lg:col-span-3">
            <CardHeader>
                <CardTitle>Recent Activity</CardTitle>
                <CardDescription>
                    Latest actions performed by system administrators.
                </CardDescription>
            </CardHeader>
            <CardContent>
                <div className="space-y-8">
                    {logs && logs.length > 0 ? (
                        logs.map((log) => <ActivityItem key={log.id} log={log} />)
                    ) : (
                        <p className="text-sm text-muted-foreground text-center py-4">No recent activity.</p>
                    )}
                </div>
            </CardContent>
        </Card>
    );
}

function ActivityItem({ log }: { log: AuditLogEntry }) {
    const initials = log.adminEmail.slice(0, 2).toUpperCase();

    return (
        <div className="flex items-center">
            <Avatar className="h-9 w-9">
                <AvatarImage src={`https://avatar.vercel.sh/${log.adminEmail}`} alt={log.adminEmail} />
                <AvatarFallback>{initials}</AvatarFallback>
            </Avatar>
            <div className="ml-4 space-y-1">
                <p className="text-sm font-medium leading-none">{formatActionText(log)}</p>
                <p className="text-xs text-muted-foreground">
                    {log.adminEmail} • {formatDistanceToNow(log.timestamp, { addSuffix: true })}
                </p>
            </div>
        </div>
    );
}

function formatActionText(log: AuditLogEntry): string {
    switch (log.action) {
        case 'tourApproved': return `Approved tour ${log.targetId ? formatTargetId(log.targetId) : ''}`;
        case 'tourRejected': return `Rejected tour ${log.targetId ? formatTargetId(log.targetId) : ''}`;
        case 'tourHidden': return `Hid tour ${log.targetId ? formatTargetId(log.targetId) : ''}`;
        case 'tourUnhidden': return `Unhid tour ${log.targetId ? formatTargetId(log.targetId) : ''}`;
        case 'tourFeatured': return `Featured tour ${log.targetId ? formatTargetId(log.targetId) : ''}`;
        case 'tourUnfeatured': return `Unfeatured tour ${log.targetId ? formatTargetId(log.targetId) : ''}`;
        case 'userBanned': return `Banned user ${log.targetId ? formatTargetId(log.targetId) : ''}`;
        case 'userUnbanned': return `Unbanned user ${log.targetId ? formatTargetId(log.targetId) : ''}`;
        case 'userRoleChanged': return `Changed role for user ${log.targetId ? formatTargetId(log.targetId) : ''}`;
        case 'settingsUpdated': return 'Updated system settings';
        default: return log.action;
    }
}

function formatTargetId(id: string) {
    return `#${id.slice(0, 6)}`;
}

function ActivitySkeleton() {
    return (
        <Card className="col-span-4 lg:col-span-3">
            <CardHeader>
                <div className="h-6 w-32 bg-muted rounded animate-pulse" />
                <div className="h-4 w-48 bg-muted rounded animate-pulse mt-2" />
            </CardHeader>
            <CardContent>
                <div className="space-y-8">
                    {[1, 2, 3, 4, 5].map((i) => (
                        <div key={i} className="flex items-center">
                            <div className="h-9 w-9 rounded-full bg-muted animate-pulse" />
                            <div className="ml-4 space-y-2">
                                <div className="h-4 w-48 bg-muted rounded animate-pulse" />
                                <div className="h-3 w-32 bg-muted rounded animate-pulse" />
                            </div>
                        </div>
                    ))}
                </div>
            </CardContent>
        </Card>
    );
}
