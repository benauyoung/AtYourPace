'use client';

import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';
import { ArrowLeft } from 'lucide-react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';

interface CreatorLayoutProps {
    children: React.ReactNode;
    tourId: string;
    className?: string;
    tourTitle?: string;
}

export function CreatorLayout({ children, tourId, className, tourTitle }: CreatorLayoutProps) {
    const pathname = usePathname();

    // Helper to check if a tab is active. 
    // We assume the URL structure is /tour/[tourId]/edit?tab=[tabName] or handled via client state.
    // For simplicity here, we might pass an 'activeTab' prop or let the parent handle the content switching
    // but if we want persistent links, we should likely use query params or sub-routes.
    // Given the implementation plan, we are staying on one page `edit` but switching views.
    // The layout will just provide the buttons that the parent will control, OR the parent uses this layout.

    // Actually, to make this reusable, let's just make it a dumb component that takes "activeTab" and "onTabChange"
    // But wait, the prompt asked for `CreatorLayout`. 
    // Let's implement it as a wrapper that accepts the Navigation implementation.

    return (
        <div className="flex h-screen bg-background">
            {/* Sidebar / Navigation */}
            <aside className="w-64 border-r bg-muted/10 flex flex-col">
                <div className="p-4 border-b h-14 flex items-center">
                    <Link href="/my-tours" className="flex items-center text-sm font-medium text-muted-foreground hover:text-foreground transition-colors">
                        <ArrowLeft className="mr-2 h-4 w-4" />
                        Back to Dashboard
                    </Link>
                </div>

                <div className="p-4">
                    <h2 className="font-semibold px-2 mb-4 truncate" title={tourTitle}>
                        {tourTitle || 'New Tour'}
                    </h2>
                    <nav className="space-y-1">
                        {/* This part will be controlled by the parent page typically, 
                 but for a layout component we can expose slots or proper navigation links if we used subroutes.
                 Since we are doing a Single Page App feel for the editor, we will let the parent pass the nav items.
              */}
                        <div id="creator-nav-slot" />
                    </nav>
                </div>

                <div className="mt-auto p-4 border-t">
                    {/* Footer actions like "Preview" could go here */}
                </div>
            </aside>

            {/* Main Content */}
            <main className={cn("flex-1 overflow-auto", className)}>
                {children}
            </main>
        </div>
    );
}

interface CreatorNavItemProps {
    icon: React.ElementType;
    label: string;
    isActive: boolean;
    onClick: () => void;
}

export function CreatorNavItem({ icon: Icon, label, isActive, onClick }: CreatorNavItemProps) {
    return (
        <Button
            variant={isActive ? "secondary" : "ghost"}
            className={cn("w-full justify-start", isActive && "bg-secondary/50")}
            onClick={onClick}
        >
            <Icon className="mr-2 h-4 w-4" />
            {label}
        </Button>
    );
}
