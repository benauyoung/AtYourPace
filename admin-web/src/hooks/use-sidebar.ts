'use client';

import { createContext, useContext } from 'react';

interface SidebarContextType {
  isOpen: boolean;
  open: () => void;
  close: () => void;
}

export const SidebarContext = createContext<SidebarContextType>({
  isOpen: false,
  open: () => {},
  close: () => {},
});

export function useSidebar() {
  return useContext(SidebarContext);
}
