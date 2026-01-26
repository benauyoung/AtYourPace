'use client';

import { MobileSidebarTrigger } from './creator-sidebar';
import { ThemeToggle } from './theme-toggle';

interface CreatorHeaderProps {
  title: string;
  onMenuClick: () => void;
}

export function CreatorHeader({ title, onMenuClick }: CreatorHeaderProps) {
  return (
    <header className="flex h-16 items-center justify-between border-b bg-card px-4 lg:px-6">
      <div className="flex items-center gap-4">
        <MobileSidebarTrigger onClick={onMenuClick} />
        <h1 className="text-xl font-semibold">{title}</h1>
      </div>
      <div className="flex items-center gap-2">
        <ThemeToggle />
      </div>
    </header>
  );
}
