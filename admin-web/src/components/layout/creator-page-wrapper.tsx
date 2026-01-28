'use client';

import { useSidebar } from '@/hooks/use-sidebar';
import { ReactNode } from 'react';
import { CreatorHeader } from './creator-header';

interface CreatorPageWrapperProps {
  title: string;
  children: ReactNode;
  noPadding?: boolean;
}

export function CreatorPageWrapper({ title, children, noPadding = false }: CreatorPageWrapperProps) {
  const { open } = useSidebar();

  return (
    <>
      <CreatorHeader title={title} onMenuClick={open} />
      <main className={noPadding ? "flex-1 overflow-hidden relative flex flex-col" : "flex-1 overflow-auto p-4 lg:p-6"}>{children}</main>
    </>
  );
}
