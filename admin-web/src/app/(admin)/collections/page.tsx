'use client';

import { AdminLayout } from '@/components/layout/admin-layout';
import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
} from '@/components/ui/alert-dialog';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader } from '@/components/ui/card';
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Input } from '@/components/ui/input';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from '@/components/ui/table';
import { useCollections, useDeleteCollection } from '@/hooks/use-collections';
import { useToast } from '@/hooks/use-toast';
import { CollectionType } from '@/types';
import { format } from 'date-fns';
import {
    Layers,
    MoreVertical,
    Pencil,
    Plus,
    Search,
    Star,
    Trash
} from 'lucide-react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useState } from 'react';

const collectionTypeDisplayNames: Record<CollectionType, string> = {
    geographic: 'Geographic',
    thematic: 'Thematic',
    seasonal: 'Seasonal',
    custom: 'Custom',
};

export default function CollectionsPage() {
    const router = useRouter();
    const { toast } = useToast();
    const [searchQuery, setSearchQuery] = useState('');
    const [typeFilter, setTypeFilter] = useState<CollectionType | 'all'>('all');
    const [deleteId, setDeleteId] = useState<string | null>(null);

    const { data: collections, isLoading } = useCollections(
        typeFilter !== 'all' ? { type: typeFilter } : undefined
    );

    const deleteMutation = useDeleteCollection();

    const filteredCollections = collections?.filter((collection) =>
        collection.name.toLowerCase().includes(searchQuery.toLowerCase())
    );

    const handleDelete = async () => {
        if (!deleteId) return;

        try {
            await deleteMutation.mutateAsync(deleteId);
            toast({
                title: 'Collection deleted',
                description: 'The collection has been successfully deleted.',
            });
        } catch {
            toast({
                variant: 'destructive',
                title: 'Error',
                description: 'Failed to delete collection. Please try again.',
            });
        } finally {
            setDeleteId(null);
        }
    };

    return (
        <AdminLayout title="Collections">
            <div className="space-y-6">
                <div className="flex items-center justify-between">
                    <h1 className="text-2xl font-bold tracking-tight">Collections</h1>
                    <Link href="/collections/new">
                        <Button>
                            <Plus className="mr-2 h-4 w-4" />
                            New Collection
                        </Button>
                    </Link>
                </div>

                <Card>
                    <CardHeader className="flex flex-row items-center gap-4 space-y-0 p-4">
                        <div className="flex flex-1 items-center gap-2">
                            <Search className="h-4 w-4 text-muted-foreground" />
                            <Input
                                placeholder="Search collections..."
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                                className="max-w-sm"
                            />
                        </div>
                        <Select
                            value={typeFilter}
                            onValueChange={(value) => setTypeFilter(value as CollectionType | 'all')}
                        >
                            <SelectTrigger className="w-[180px]">
                                <SelectValue placeholder="Filter by type" />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem value="all">All Types</SelectItem>
                                <SelectItem value="geographic">Geographic</SelectItem>
                                <SelectItem value="thematic">Thematic</SelectItem>
                                <SelectItem value="seasonal">Seasonal</SelectItem>
                                <SelectItem value="custom">Custom</SelectItem>
                            </SelectContent>
                        </Select>
                    </CardHeader>
                    <CardContent className="p-0">
                        <Table>
                            <TableHeader>
                                <TableRow>
                                    <TableHead>No.</TableHead>
                                    <TableHead>Collection Details</TableHead>
                                    <TableHead>Type</TableHead>
                                    <TableHead className="text-center">Tours</TableHead>
                                    <TableHead className="text-center">Status</TableHead>
                                    <TableHead className="text-right">Actions</TableHead>
                                </TableRow>
                            </TableHeader>
                            <TableBody>
                                {isLoading ? (
                                    <TableRow>
                                        <TableCell colSpan={6} className="h-24 text-center">
                                            <div className="flex items-center justify-center">
                                                <div className="h-6 w-6 animate-spin rounded-full border-2 border-primary border-t-transparent" />
                                            </div>
                                        </TableCell>
                                    </TableRow>
                                ) : filteredCollections?.length === 0 ? (
                                    <TableRow>
                                        <TableCell colSpan={6} className="h-24 text-center">
                                            No collections found.
                                        </TableCell>
                                    </TableRow>
                                ) : (
                                    filteredCollections?.map((collection) => (
                                        <TableRow key={collection.id}>
                                            <TableCell className="font-mono text-xs text-muted-foreground">
                                                {collection.sortOrder}
                                            </TableCell>
                                            <TableCell>
                                                <div className="flex items-center gap-3">
                                                    {collection.coverImageUrl ? (
                                                        // eslint-disable-next-line @next/next/no-img-element
                                                        <img
                                                            src={collection.coverImageUrl}
                                                            alt={collection.name}
                                                            className="h-10 w-10 rounded-lg object-cover"
                                                        />
                                                    ) : (
                                                        <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-muted">
                                                            <Layers className="h-5 w-5 text-muted-foreground" />
                                                        </div>
                                                    )}
                                                    <div>
                                                        <div className="font-medium">{collection.name}</div>
                                                        <div className="text-xs text-muted-foreground">
                                                            Created {format(collection.createdAt, 'MMM d, yyyy')}
                                                        </div>
                                                    </div>
                                                </div>
                                            </TableCell>
                                            <TableCell>
                                                <Badge variant="outline">
                                                    {collectionTypeDisplayNames[collection.type]}
                                                </Badge>
                                            </TableCell>
                                            <TableCell className="text-center">
                                                {collection.tourIds.length}
                                            </TableCell>
                                            <TableCell className="text-center">
                                                <div className="flex items-center justify-center gap-2">
                                                    {collection.isCurated && (
                                                        <Badge variant="secondary" className="gap-1">
                                                            <Star className="h-3 w-3 fill-current" />
                                                            Curated
                                                        </Badge>
                                                    )}
                                                    {collection.isFeatured && (
                                                        <Badge variant="default">Featured</Badge>
                                                    )}
                                                </div>
                                            </TableCell>
                                            <TableCell className="text-right">
                                                <DropdownMenu>
                                                    <DropdownMenuTrigger asChild>
                                                        <Button variant="ghost" size="icon">
                                                            <MoreVertical className="h-4 w-4" />
                                                        </Button>
                                                    </DropdownMenuTrigger>
                                                    <DropdownMenuContent align="end">
                                                        <DropdownMenuItem asChild>
                                                            <Link href={`/collections/${collection.id}`}>
                                                                <Pencil className="mr-2 h-4 w-4" />
                                                                Edit
                                                            </Link>
                                                        </DropdownMenuItem>
                                                        <DropdownMenuItem
                                                            className="text-destructive focus:text-destructive"
                                                            onClick={() => setDeleteId(collection.id)}
                                                        >
                                                            <Trash className="mr-2 h-4 w-4" />
                                                            Delete
                                                        </DropdownMenuItem>
                                                    </DropdownMenuContent>
                                                </DropdownMenu>
                                            </TableCell>
                                        </TableRow>
                                    ))
                                )}
                            </TableBody>
                        </Table>
                    </CardContent>
                </Card>

                <AlertDialog open={!!deleteId} onOpenChange={(open) => !open && setDeleteId(null)}>
                    <AlertDialogContent>
                        <AlertDialogHeader>
                            <AlertDialogTitle>Are you sure?</AlertDialogTitle>
                            <AlertDialogDescription>
                                This action cannot be undone. This will permanently delete the collection.
                                The tours within the collection will not be deleted.
                            </AlertDialogDescription>
                        </AlertDialogHeader>
                        <AlertDialogFooter>
                            <AlertDialogCancel>Cancel</AlertDialogCancel>
                            <AlertDialogAction
                                onClick={handleDelete}
                                className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
                            >
                                Delete
                            </AlertDialogAction>
                        </AlertDialogFooter>
                    </AlertDialogContent>
                </AlertDialog>
            </div>
        </AdminLayout>
    );
}
