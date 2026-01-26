'use client';

import { useAuth } from '@/hooks/use-auth';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';

interface HeaderProps {
  title: string;
}

export function Header({ title }: HeaderProps) {
  const { userData } = useAuth();

  const initials = userData?.displayName
    ?.split(' ')
    .map((n) => n[0])
    .join('')
    .toUpperCase()
    .slice(0, 2) || 'AD';

  return (
    <header className="flex h-16 items-center justify-between border-b bg-card px-6">
      <h2 className="text-2xl font-semibold">{title}</h2>
      <div className="flex items-center gap-3">
        <span className="text-sm text-muted-foreground">
          {userData?.email || 'Admin'}
        </span>
        <Avatar className="h-8 w-8">
          <AvatarFallback className="bg-primary text-primary-foreground text-xs">
            {initials}
          </AvatarFallback>
        </Avatar>
      </div>
    </header>
  );
}
