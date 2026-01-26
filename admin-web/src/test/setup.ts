import '@testing-library/jest-dom';
import { vi } from 'vitest';

// Mock next/navigation
vi.mock('next/navigation', () => ({
  useRouter: () => ({
    push: vi.fn(),
    replace: vi.fn(),
    back: vi.fn(),
  }),
  usePathname: () => '/my-tours',
  useSearchParams: () => new URLSearchParams(),
}));

// Mock Firebase
vi.mock('@/lib/firebase/config', () => ({
  auth: {
    currentUser: null,
  },
  db: {},
  storage: {},
}));
