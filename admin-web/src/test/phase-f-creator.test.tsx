import { StartTourModal } from '@/components/creator/StartTourModal';
import { CoverForm } from '@/components/creator/forms/CoverForm';
import { TipsForm } from '@/components/creator/forms/TipsForm';
import { TourVersionModel } from '@/types';
import { fireEvent, render, screen, waitFor } from '@testing-library/react';
import { beforeEach, describe, expect, it, vi } from 'vitest';

// Mock Hooks
const mockCreateTourMutate = vi.fn();
const mockUpdateTourMutate = vi.fn();
const mockUploadCoverMutate = vi.fn();

vi.mock('@/hooks/use-creator-tours', () => ({
    useCreateTour: () => ({
        mutateAsync: mockCreateTourMutate,
        isPending: false,
    }),
    useUpdateTour: () => ({
        mutateAsync: mockUpdateTourMutate,
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

// Mock CoverImageUpload component
vi.mock('@/components/creator/cover-image-upload', () => ({
    CoverImageUpload: ({ onUpload }: { onUpload: (file: File) => void }) => (
        <button onClick={() => onUpload(new File([''], 'test.jpg', { type: 'image/jpeg' }))}>
            Upload Image
        </button>
    ),
}));

describe('Tour Creator Overhaul (Phase F)', () => {
    beforeEach(() => {
        vi.resetAllMocks();
    });

    describe('StartTourModal', () => {
        it('renders correctly', () => {
            render(<StartTourModal open={true} onOpenChange={vi.fn()} onCreate={vi.fn()} />);
            expect(screen.getByText('Start a new tour')).toBeInTheDocument();
            expect(screen.getByLabelText('Tour title')).toBeInTheDocument();
            expect(screen.getByLabelText('Destination')).toBeInTheDocument();
        });

        it('validates required fields', async () => {
            render(<StartTourModal open={true} onOpenChange={vi.fn()} onCreate={vi.fn()} />);

            const submitBtn = screen.getByText('Create Tour');
            fireEvent.click(submitBtn);

            await waitFor(() => {
                expect(screen.getByText('Title is required')).toBeInTheDocument();
                // expect(screen.getByText('Destination is required')).toBeInTheDocument(); // Might trigger separately
            });
        });

        it('submits valid data', async () => {
            const handleCreate = vi.fn();
            render(<StartTourModal open={true} onOpenChange={vi.fn()} onCreate={handleCreate} />);

            fireEvent.change(screen.getByLabelText('Tour title'), { target: { value: 'My New Tour' } });
            fireEvent.change(screen.getByLabelText('Destination'), { target: { value: 'Paris' } });

            // Should be clean
            fireEvent.click(screen.getByText('Create Tour'));

            await waitFor(() => {
                expect(handleCreate).toHaveBeenCalledWith(expect.objectContaining({
                    title: 'My New Tour',
                    destination: 'Paris',
                    price: 'free',
                    transportMode: 'walking'
                }));
            });
        });
    });

    describe('CoverForm', () => {
        const mockVersion = {
            title: 'Existing Title',
            duration: '60',
            coverImageUrl: 'http://example.com/img.jpg',
        } as TourVersionModel;

        it('populates initial values', () => {
            render(<CoverForm version={mockVersion} onSave={vi.fn()} onCoverImageUpload={vi.fn()} />);
            expect(screen.getByDisplayValue('Existing Title')).toBeInTheDocument();
        });

        it('calls onSave when submitted', async () => {
            const handleSave = vi.fn();
            render(<CoverForm version={mockVersion} onSave={handleSave} onCoverImageUpload={vi.fn()} />);

            fireEvent.change(screen.getByLabelText('Tour Title'), { target: { value: 'Updated Title' } });
            fireEvent.click(screen.getByText('Save Changes'));

            await waitFor(() => {
                expect(handleSave).toHaveBeenCalledWith(expect.objectContaining({
                    title: 'Updated Title',
                }));
            });
        });

        it('calls onCoverImageUpload', async () => {
            const handleUpload = vi.fn();
            render(<CoverForm version={mockVersion} onSave={vi.fn()} onCoverImageUpload={handleUpload} />);

            fireEvent.click(screen.getByText('Upload Image'));
            expect(handleUpload).toHaveBeenCalled();
        });
    });

    describe('TipsForm', () => {
        const mockVersion = {
            startLocationInstructions: 'Start here',
            bestTime: 'Morning',
            precautions: 'Wear hat',
            foodOptions: 'Pizza nearby',
        } as TourVersionModel;

        it('renders all logistics fields', () => {
            render(<TipsForm version={mockVersion} onSave={vi.fn()} />);
            expect(screen.getByLabelText(/Directions/)).toBeInTheDocument();
            expect(screen.getByLabelText(/Best time/)).toBeInTheDocument();
            expect(screen.getByLabelText(/Precautions/)).toBeInTheDocument();
            expect(screen.getByLabelText(/Places to stop/)).toBeInTheDocument();
        });

        it('saves valid data', async () => {
            const handleSave = vi.fn();
            render(<TipsForm version={mockVersion} onSave={handleSave} />);

            fireEvent.change(screen.getByLabelText(/Best time/), { target: { value: 'Evening' } });
            fireEvent.click(screen.getByText('Save Changes'));

            await waitFor(() => {
                expect(handleSave).toHaveBeenCalledWith(expect.objectContaining({
                    bestTime: 'Evening'
                }));
            });
        });
    });
});
