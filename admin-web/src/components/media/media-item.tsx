'use client';

import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
    AlertDialogTrigger,
} from '@/components/ui/alert-dialog';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardFooter } from '@/components/ui/card';
import { useDeleteMedia } from '@/hooks/use-media';
import { useToast } from '@/hooks/use-toast';
import { StorageFile } from '@/lib/firebase/storage';
import { Copy, FileAudio, Trash2 } from 'lucide-react';
import Image from 'next/image';

interface MediaItemProps {
    file: StorageFile;
    onSelect?: (file: StorageFile) => void;
}

export function MediaItem({ file, onSelect }: MediaItemProps) {
    const { toast } = useToast();
    const deleteMutation = useDeleteMedia();

    const isImage = file.name.match(/\.(jpg|jpeg|png|gif|webp)$/i);

    const handleCopyUrl = () => {
        navigator.clipboard.writeText(file.url);
        toast({
            title: 'URL Copied',
            description: 'Image URL copied to clipboard',
        });
    };

    const handleDelete = async () => {
        try {
            await deleteMutation.mutateAsync(file.fullPath);
            toast({
                title: 'File deleted',
                description: 'The file has been permanently removed.',
            });
        } catch {
            toast({
                variant: 'destructive',
                title: 'Error',
                description: 'Failed to delete file.',
            });
        }
    };

    return (
        <Card className="overflow-hidden group">
            <CardContent className="p-0 aspect-square relative bg-muted/20 flex items-center justify-center">
                {isImage ? (
                    <div className="relative w-full h-full">
                        <Image
                            src={file.url}
                            alt={file.name}
                            fill
                            className="object-cover transition-transform group-hover:scale-105"
                        />
                    </div>
                ) : (
                    <FileAudio className="h-12 w-12 text-muted-foreground" />
                )}
            </CardContent>
            <CardFooter className="p-3 flex items-center justify-between bg-card border-t">
                <div className="truncate text-xs font-medium w-24" title={file.name}>
                    {file.name}
                </div>
                <div className="flex gap-1">
                    {onSelect && (
                        <Button variant="secondary" size="sm" className="h-6 text-xs" onClick={() => onSelect(file)}>
                            Select
                        </Button>
                    )}
                    <Button variant="ghost" size="icon" className="h-6 w-6" onClick={handleCopyUrl}>
                        <Copy className="h-3 w-3" />
                    </Button>

                    <AlertDialog>
                        <AlertDialogTrigger asChild>
                            <Button variant="ghost" size="icon" className="h-6 w-6 text-destructive hover:text-destructive">
                                <Trash2 className="h-3 w-3" />
                            </Button>
                        </AlertDialogTrigger>
                        <AlertDialogContent>
                            <AlertDialogHeader>
                                <AlertDialogTitle>Delete File?</AlertDialogTitle>
                                <AlertDialogDescription>
                                    This action cannot be undone. This will permanently delete <b>{file.name}</b>.
                                </AlertDialogDescription>
                            </AlertDialogHeader>
                            <AlertDialogFooter>
                                <AlertDialogCancel>Cancel</AlertDialogCancel>
                                <AlertDialogAction onClick={handleDelete} className="bg-destructive hover:bg-destructive/90">
                                    Delete
                                </AlertDialogAction>
                            </AlertDialogFooter>
                        </AlertDialogContent>
                    </AlertDialog>
                </div>
            </CardFooter>
        </Card>
    );
}
