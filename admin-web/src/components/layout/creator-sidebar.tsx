'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  Map,
  PlusCircle,
  BarChart3,
  LogOut,
  Menu,
  X,
} from 'lucide-react';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import { signOut } from '@/lib/firebase/auth';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/hooks/use-auth';
import { RoleSwitcher } from './role-switcher';

const navItems = [
  { href: '/my-tours', label: 'My Tours', icon: Map },
  { href: '/tour/new', label: 'Create Tour', icon: PlusCircle },
  { href: '/analytics', label: 'Analytics', icon: BarChart3 },
];

interface CreatorSidebarProps {
  isOpen?: boolean;
  onClose?: () => void;
}

export function CreatorSidebar({ isOpen, onClose }: CreatorSidebarProps) {
  const pathname = usePathname();
  const router = useRouter();
  const { isAdmin, userData } = useAuth();

  const handleSignOut = async () => {
    await signOut();
    router.push('/login');
  };

  return (
    <>
      {/* Mobile overlay */}
      {isOpen && (
        <div
          className="fixed inset-0 z-40 bg-black/50 lg:hidden"
          onClick={onClose}
        />
      )}

      {/* Sidebar */}
      <aside
        className={cn(
          'fixed inset-y-0 left-0 z-50 flex h-screen w-64 flex-col border-r bg-card transition-transform lg:static lg:translate-x-0',
          isOpen ? 'translate-x-0' : '-translate-x-full'
        )}
      >
        {/* Logo / Header */}
        <div className="flex h-16 items-center justify-between border-b px-6">
          <Link href="/my-tours" className="flex items-center gap-2">
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary">
              <Map className="h-4 w-4 text-primary-foreground" />
            </div>
            <span className="text-lg font-semibold">Tour Creator</span>
          </Link>
          <Button
            variant="ghost"
            size="icon"
            className="lg:hidden"
            onClick={onClose}
          >
            <X className="h-4 w-4" />
          </Button>
        </div>

        {/* User info */}
        {userData && (
          <div className="border-b px-4 py-3">
            <p className="text-sm font-medium truncate">{userData.displayName}</p>
            <p className="text-xs text-muted-foreground truncate">{userData.email}</p>
          </div>
        )}

        {/* Navigation */}
        <nav className="flex-1 space-y-1 p-4">
          {navItems.map((item) => {
            const isActive = pathname === item.href || pathname.startsWith(`${item.href}/`);
            return (
              <Link
                key={item.href}
                href={item.href}
                onClick={onClose}
                className={cn(
                  'flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors',
                  isActive
                    ? 'bg-primary text-primary-foreground'
                    : 'text-muted-foreground hover:bg-muted hover:text-foreground'
                )}
              >
                <item.icon className="h-4 w-4" />
                {item.label}
              </Link>
            );
          })}
        </nav>

        {/* Bottom section */}
        <div className="border-t p-4 space-y-2">
          {/* Role switcher for admins */}
          {isAdmin && <RoleSwitcher />}

          <Button
            variant="ghost"
            className="w-full justify-start gap-3 text-muted-foreground"
            onClick={handleSignOut}
          >
            <LogOut className="h-4 w-4" />
            Sign Out
          </Button>
        </div>
      </aside>
    </>
  );
}

export function MobileSidebarTrigger({ onClick }: { onClick: () => void }) {
  return (
    <Button
      variant="ghost"
      size="icon"
      className="lg:hidden"
      onClick={onClick}
    >
      <Menu className="h-5 w-5" />
      <span className="sr-only">Open menu</span>
    </Button>
  );
}
