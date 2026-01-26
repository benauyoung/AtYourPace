'use client';

import { useEffect, ReactNode } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/hooks/use-auth';
import { Sidebar } from './sidebar';
import { Header } from './header';

interface AdminLayoutProps {
  children: ReactNode;
  title: string;
}

export function AdminLayout({ children, title }: AdminLayoutProps) {
  const { user, isAdmin, isLoading, viewMode, setViewMode } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!isLoading) {
      if (!user || !isAdmin) {
        router.push('/login');
      } else if (viewMode === 'creator') {
        // If user is viewing as creator, redirect to creator dashboard
        router.push('/my-tours');
      } else {
        // Ensure viewMode is set to admin when in admin routes
        setViewMode('admin');
      }
    }
  }, [user, isAdmin, isLoading, viewMode, setViewMode, router]);

  if (isLoading) {
    return (
      <div className="flex h-screen items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
      </div>
    );
  }

  if (!user || !isAdmin || viewMode === 'creator') {
    return null;
  }

  return (
    <div className="flex h-screen bg-background">
      <Sidebar />
      <div className="flex flex-1 flex-col overflow-hidden">
        <Header title={title} />
        <main className="flex-1 overflow-auto p-6">{children}</main>
      </div>
    </div>
  );
}
