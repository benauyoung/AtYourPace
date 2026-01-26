'use client';

import { ReactNode } from 'react';
import { CreatorHeader } from './creator-header';
import { useSidebar } from '@/hooks/use-sidebar';

interface CreatorPageWrapperProps {
  title: string;
  children: ReactNode;
}

export function CreatorPageWrapper({ title, children }: CreatorPageWrapperProps) {
  const { open } = useSidebar();

  return (
    <>
      <CreatorHeader title={title} onMenuClick={open} />
      <main className="flex-1 overflow-auto p-4 lg:p-6">{children}</main>
    </>
  );
}
