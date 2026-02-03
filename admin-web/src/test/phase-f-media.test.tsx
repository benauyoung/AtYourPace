import { MediaGrid } from '@/components/media/media-grid';
import { MediaItem } from '@/components/media/media-item';
import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it, vi } from 'vitest';

// Mock hooks
const mockFiles = [
    {
        name: 'image1.jpg',
        fullPath: 'uploads/image1.jpg',
        url: 'https://example.com/image1.jpg',
    },
    {
        name: 'audio.mp3',
        fullPath: 'uploads/audio.mp3',
        url: 'https://example.com/audio.mp3',
    },
];

const mockDeleteMutate = vi.fn();

vi.mock('@/hooks/use-media', () => ({
    useMediaFiles: vi.fn(),
    useDeleteMedia: () => ({
        mutateAsync: mockDeleteMutate,
    }),
    useUploadMedia: () => ({
        mutateAsync: vi.fn(),
        isPending: false,
    }),
}));

// Mock Toast
const mockToast = vi.fn();
vi.mock('@/hooks/use-toast', () => ({
    useToast: () => ({
        toast: mockToast,
    }),
}));

// Mock Next Image
vi.mock('next/image', () => ({
    default: (props: any) => <img {...props} />,
}));

import { useMediaFiles } from '@/hooks/use-media';

describe('Media Components (Phase F)', () => {
    beforeEach(() => {
        vi.resetAllMocks();
    });

    describe('MediaGrid', () => {
        it('renders loading state initially', () => {
            (useMediaFiles as any).mockReturnValue({
                data: null,
                isLoading: true,
            });

            const { container } = render(<MediaGrid path="uploads" />);
            expect(container.getElementsByClassName('animate-pulse').length).toBeGreaterThan(0);
        });

        it('renders empty state when no files', () => {
            (useMediaFiles as any).mockReturnValue({
                data: [],
                isLoading: false,
            });

            render(<MediaGrid path="uploads" />);
            expect(screen.getByText('No files found in this folder.')).toBeInTheDocument();
        });

        it('renders media items', () => {
            (useMediaFiles as any).mockReturnValue({
                data: mockFiles,
                isLoading: false,
            });

            render(<MediaGrid path="uploads" />);
            expect(screen.getByText('image1.jpg')).toBeInTheDocument();
            expect(screen.getByText('audio.mp3')).toBeInTheDocument();
        });
    });

    describe('MediaItem', () => {
        it('renders image thumbnail for images', () => {
            render(<MediaItem file={mockFiles[0]} />);
            const img = screen.getByAltText('image1.jpg');
            expect(img).toBeInTheDocument();
            expect(img).toHaveAttribute('src', 'https://example.com/image1.jpg');
        });

        it('copies URL to clipboard', async () => {
            // Mock clipboard
            const mockWriteText = vi.fn();
            Object.assign(navigator, {
                clipboard: {
                    writeText: mockWriteText,
                },
            });

            render(<MediaItem file={mockFiles[0]} />);

            // Find copy button (first button in footer)
            const buttons = screen.getAllByRole('button');
            fireEvent.click(buttons[0]); // Copy button

            expect(mockWriteText).toHaveBeenCalledWith('https://example.com/image1.jpg');
            expect(mockToast).toHaveBeenCalledWith(expect.objectContaining({
                title: 'URL Copied',
            }));
        });
    });
});
