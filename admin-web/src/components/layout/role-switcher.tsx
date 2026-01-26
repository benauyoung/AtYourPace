'use client';

import { useRouter } from 'next/navigation';
import { Shield, Pencil } from 'lucide-react';
import { useAuth } from '@/hooks/use-auth';
import { Button } from '@/components/ui/button';

export function RoleSwitcher() {
  const { isAdmin, viewMode, setViewMode } = useAuth();
  const router = useRouter();

  if (!isAdmin) {
    return null;
  }

  const isInCreatorMode = viewMode === 'creator';

  const handleSwitch = () => {
    if (isInCreatorMode) {
      // Switch to admin mode
      setViewMode('admin');
      router.push('/dashboard');
    } else {
      // Switch to creator mode
      setViewMode('creator');
      router.push('/my-tours');
    }
  };

  return (
    <Button
      variant="outline"
      size="sm"
      className="w-full justify-start gap-2"
      onClick={handleSwitch}
    >
      {isInCreatorMode ? (
        <>
          <Shield className="h-4 w-4" />
          Switch to Admin
        </>
      ) : (
        <>
          <Pencil className="h-4 w-4" />
          Switch to Creator
        </>
      )}
    </Button>
  );
}
