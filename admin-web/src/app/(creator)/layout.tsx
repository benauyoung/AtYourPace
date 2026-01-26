'use client';

import { useEffect, useState, ReactNode } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/hooks/use-auth';
import { SidebarContext } from '@/hooks/use-sidebar';
import { CreatorSidebar } from '@/components/layout/creator-sidebar';

interface CreatorLayoutProps {
  children: ReactNode;
}

export default function CreatorLayout({ children }: CreatorLayoutProps) {
  const { user, isCreator, isLoading, viewMode } = useAuth();
  const router = useRouter();
  const [sidebarOpen, setSidebarOpen] = useState(false);

  useEffect(() => {
    if (!isLoading) {
      if (!user || !isCreator) {
        router.push('/login');
      } else if (viewMode === 'admin') {
        // If user is viewing as admin, redirect to admin dashboard
        router.push('/dashboard');
      }
    }
  }, [user, isCreator, isLoading, viewMode, router]);

  if (isLoading) {
    return (
      <div className="flex h-screen items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
      </div>
    );
  }

  if (!user || !isCreator || viewMode === 'admin') {
    return null;
  }

  return (
    <SidebarContext.Provider
      value={{
        isOpen: sidebarOpen,
        open: () => setSidebarOpen(true),
        close: () => setSidebarOpen(false),
      }}
    >
      <div className="flex h-screen bg-background">
        <CreatorSidebar isOpen={sidebarOpen} onClose={() => setSidebarOpen(false)} />
        <div className="flex flex-1 flex-col overflow-hidden">
          {children}
        </div>
      </div>
    </SidebarContext.Provider>
  );
}
