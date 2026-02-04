'use client';

import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog';
import { StorageFile } from '@/lib/firebase/storage';
import { MediaGrid } from './media-grid';

interface MediaPickerDialogProps {
    open: boolean;
    onOpenChange: (open: boolean) => void;
    onSelect: (file: StorageFile) => void;
    path?: string;
}

export function MediaPickerDialog({
    open,
    onOpenChange,
    onSelect,
    path = 'media', // Default path, can be overridden
}: MediaPickerDialogProps) {
    const handleSelect = (file: StorageFile) => {
        onSelect(file);
        onOpenChange(false);
    };

    return (
        <Dialog open={open} onOpenChange={onOpenChange}>
            <DialogContent className="max-w-4xl max-h-[80vh] overflow-hidden flex flex-col">
                <DialogHeader>
                    <DialogTitle>Select Media</DialogTitle>
                    <DialogDescription>
                        Choose an image from your library.
                    </DialogDescription>
                </DialogHeader>

                <div className="flex-1 overflow-y-auto p-1">
                    <MediaGrid path={path} onSelect={handleSelect} />
                </div>
            </DialogContent>
        </Dialog>
    );
}
