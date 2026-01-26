'use client';

import { useState } from 'react';
import { format } from 'date-fns';
import { Search, MoreHorizontal, Ban, ShieldCheck, User, Crown } from 'lucide-react';
import { AdminLayout } from '@/components/layout/admin-layout';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
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
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Textarea } from '@/components/ui/textarea';
import { useToast } from '@/hooks/use-toast';
import { useUsers, useUpdateUserRole, useBanUser, useUnbanUser } from '@/hooks/use-users';
import { UserModel, UserRole, roleDisplayNames } from '@/types';

const roleOptions: { value: UserRole | 'all'; label: string }[] = [
  { value: 'all', label: 'All Roles' },
  { value: 'user', label: 'User' },
  { value: 'creator', label: 'Creator' },
  { value: 'admin', label: 'Admin' },
];

function getRoleBadgeVariant(role: UserRole): 'default' | 'secondary' | 'outline' {
  switch (role) {
    case 'admin':
      return 'default';
    case 'creator':
      return 'secondary';
    default:
      return 'outline';
  }
}

function getRoleIcon(role: UserRole) {
  switch (role) {
    case 'admin':
      return <Crown className="h-3 w-3" />;
    case 'creator':
      return <ShieldCheck className="h-3 w-3" />;
    default:
      return <User className="h-3 w-3" />;
  }
}

export default function UsersPage() {
  const { toast } = useToast();
  const [searchQuery, setSearchQuery] = useState('');
  const [roleFilter, setRoleFilter] = useState<UserRole | 'all'>('all');
  const [selectedUser, setSelectedUser] = useState<UserModel | null>(null);
  const [roleDialogOpen, setRoleDialogOpen] = useState(false);
  const [banDialogOpen, setBanDialogOpen] = useState(false);
  const [newRole, setNewRole] = useState<UserRole>('user');
  const [banReason, setBanReason] = useState('');

  const { data: users, isLoading } = useUsers({
    role: roleFilter === 'all' ? undefined : roleFilter,
    searchQuery: searchQuery || undefined,
  });

  const updateRoleMutation = useUpdateUserRole();
  const banMutation = useBanUser();
  const unbanMutation = useUnbanUser();

  const handleRoleChange = async () => {
    if (!selectedUser) return;

    try {
      await updateRoleMutation.mutateAsync({
        userId: selectedUser.uid,
        role: newRole,
      });
      toast({
        title: 'Role updated',
        description: `User role changed to ${roleDisplayNames[newRole]}.`,
      });
      setRoleDialogOpen(false);
      setSelectedUser(null);
    } catch {
      toast({
        variant: 'destructive',
        title: 'Error',
        description: 'Failed to update role. Please try again.',
      });
    }
  };

  const handleBan = async () => {
    if (!selectedUser) return;

    try {
      await banMutation.mutateAsync({
        userId: selectedUser.uid,
        reason: banReason || undefined,
      });
      toast({
        title: 'User banned',
        description: 'The user has been banned from the platform.',
      });
      setBanDialogOpen(false);
      setSelectedUser(null);
      setBanReason('');
    } catch {
      toast({
        variant: 'destructive',
        title: 'Error',
        description: 'Failed to ban user. Please try again.',
      });
    }
  };

  const handleUnban = async (user: UserModel) => {
    try {
      await unbanMutation.mutateAsync(user.uid);
      toast({
        title: 'User unbanned',
        description: 'The user can now access the platform again.',
      });
    } catch {
      toast({
        variant: 'destructive',
        title: 'Error',
        description: 'Failed to unban user. Please try again.',
      });
    }
  };

  const filteredUsers = users?.filter((user) => {
    if (searchQuery) {
      const search = searchQuery.toLowerCase();
      return (
        user.email.toLowerCase().includes(search) ||
        user.displayName.toLowerCase().includes(search)
      );
    }
    return true;
  });

  return (
    <AdminLayout title="Users">
      <Card>
        <CardHeader>
          <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <CardTitle>Users ({filteredUsers?.length ?? 0})</CardTitle>
            <div className="flex items-center gap-2">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  placeholder="Search by name or email..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full pl-9 sm:w-64"
                />
              </div>
              <Select
                value={roleFilter}
                onValueChange={(v) => setRoleFilter(v as UserRole | 'all')}
              >
                <SelectTrigger className="w-36">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {roleOptions.map((option) => (
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
          ) : filteredUsers && filteredUsers.length > 0 ? (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>User</TableHead>
                  <TableHead>Role</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Creator Stats</TableHead>
                  <TableHead>Joined</TableHead>
                  <TableHead className="w-[70px]"></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredUsers.map((user) => (
                  <TableRow key={user.uid}>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <Avatar className="h-8 w-8">
                          <AvatarFallback className="text-xs">
                            {user.displayName
                              .split(' ')
                              .map((n) => n[0])
                              .join('')
                              .toUpperCase()
                              .slice(0, 2)}
                          </AvatarFallback>
                        </Avatar>
                        <div>
                          <div className="font-medium">{user.displayName}</div>
                          <div className="text-sm text-muted-foreground">
                            {user.email}
                          </div>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge
                        variant={getRoleBadgeVariant(user.role)}
                        className="gap-1"
                      >
                        {getRoleIcon(user.role)}
                        {roleDisplayNames[user.role]}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      {user.banned ? (
                        <Badge variant="destructive">Banned</Badge>
                      ) : (
                        <Badge variant="outline">Active</Badge>
                      )}
                    </TableCell>
                    <TableCell>
                      {user.creatorProfile ? (
                        <div className="text-sm text-muted-foreground">
                          {user.creatorProfile.totalTours} tours,{' '}
                          {user.creatorProfile.totalDownloads} downloads
                        </div>
                      ) : (
                        <span className="text-sm text-muted-foreground">-</span>
                      )}
                    </TableCell>
                    <TableCell className="text-muted-foreground">
                      {format(user.createdAt, 'MMM d, yyyy')}
                    </TableCell>
                    <TableCell>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="icon">
                            <MoreHorizontal className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuItem
                            onClick={() => {
                              setSelectedUser(user);
                              setNewRole(user.role);
                              setRoleDialogOpen(true);
                            }}
                          >
                            <ShieldCheck className="mr-2 h-4 w-4" />
                            Change Role
                          </DropdownMenuItem>
                          <DropdownMenuSeparator />
                          {user.banned ? (
                            <DropdownMenuItem onClick={() => handleUnban(user)}>
                              <ShieldCheck className="mr-2 h-4 w-4" />
                              Unban
                            </DropdownMenuItem>
                          ) : (
                            <DropdownMenuItem
                              onClick={() => {
                                setSelectedUser(user);
                                setBanDialogOpen(true);
                              }}
                              className="text-destructive"
                            >
                              <Ban className="mr-2 h-4 w-4" />
                              Ban User
                            </DropdownMenuItem>
                          )}
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          ) : (
            <div className="py-8 text-center text-muted-foreground">
              No users found
            </div>
          )}
        </CardContent>
      </Card>

      {/* Change Role Dialog */}
      <Dialog open={roleDialogOpen} onOpenChange={setRoleDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Change User Role</DialogTitle>
            <DialogDescription>
              Change the role for {selectedUser?.displayName}
            </DialogDescription>
          </DialogHeader>
          <Select value={newRole} onValueChange={(v) => setNewRole(v as UserRole)}>
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="user">User</SelectItem>
              <SelectItem value="creator">Creator</SelectItem>
              <SelectItem value="admin">Admin</SelectItem>
            </SelectContent>
          </Select>
          <DialogFooter>
            <Button variant="outline" onClick={() => setRoleDialogOpen(false)}>
              Cancel
            </Button>
            <Button
              onClick={handleRoleChange}
              disabled={updateRoleMutation.isPending}
            >
              {updateRoleMutation.isPending ? 'Updating...' : 'Update Role'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Ban Dialog */}
      <Dialog open={banDialogOpen} onOpenChange={setBanDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Ban User</DialogTitle>
            <DialogDescription>
              This will prevent {selectedUser?.displayName} from accessing the
              platform. You can optionally provide a reason.
            </DialogDescription>
          </DialogHeader>
          <Textarea
            placeholder="Reason for ban (optional)..."
            value={banReason}
            onChange={(e) => setBanReason(e.target.value)}
            rows={3}
          />
          <DialogFooter>
            <Button variant="outline" onClick={() => setBanDialogOpen(false)}>
              Cancel
            </Button>
            <Button
              variant="destructive"
              onClick={handleBan}
              disabled={banMutation.isPending}
            >
              {banMutation.isPending ? 'Banning...' : 'Ban User'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </AdminLayout>
  );
}
