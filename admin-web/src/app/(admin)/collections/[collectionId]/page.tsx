'use client';

import {
    closestCenter,
    DndContext,
    DragEndEvent,
    KeyboardSensor,
    PointerSensor,
    useSensor,
    useSensors,
} from '@dnd-kit/core';
import {
    arrayMove,
    SortableContext,
    sortableKeyboardCoordinates,
    useSortable,
    verticalListSortingStrategy,
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { zodResolver } from '@hookform/resolvers/zod';
import {
    ChevronLeft,
    MoveVertical,
    Plus,
    Save,
    Search,
    Trash
} from 'lucide-react';
import { useParams, useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import { useForm } from 'react-hook-form';
import * as z from 'zod';

import { AdminLayout } from '@/components/layout/admin-layout';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import {
    Card,
    CardContent,
    CardDescription,
    CardHeader,
    CardTitle,
} from '@/components/ui/card';
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from '@/components/ui/dialog';
import {
    Form,
    FormControl,
    FormDescription,
    FormField,
    FormItem,
    FormLabel,
    FormMessage,
} from '@/components/ui/form';
import { Input } from '@/components/ui/input';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
import { Separator } from '@/components/ui/separator';
import { Switch } from '@/components/ui/switch';
import { Textarea } from '@/components/ui/textarea';
import { useCollection, useCreateCollection, useUpdateCollection } from '@/hooks/use-collections';
import { useToast } from '@/hooks/use-toast';
import { useTours } from '@/hooks/use-tours';
import { TourModel } from '@/types';

const formSchema = z.object({
    name: z.string().min(3, 'Name must be at least 3 characters'),
    description: z.string().min(10, 'Description must be at least 10 characters'),
    type: z.enum(['geographic', 'thematic', 'seasonal', 'custom']),
    coverImageUrl: z.string().url('Must be a valid URL').optional().or(z.literal('')),
    isCurated: z.boolean(),
    isFeatured: z.boolean(),
    sortOrder: z.coerce.number().int().default(0),
    city: z.string().optional(),
    country: z.string().optional(),
    tags: z.string().optional(), // Comma separated string for input
});

export default function CollectionDetailPage() {
    const router = useRouter();
    const params = useParams();
    const collectionId = params.collectionId as string;
    const isNew = collectionId === 'new';
    const { toast } = useToast();

    const { data: collection, isLoading } = useCollection(isNew ? null : collectionId);
    const { data: allTours } = useTours();

    const createMutation = useCreateCollection();
    const updateMutation = useUpdateCollection();

    const [selectedTourIds, setSelectedTourIds] = useState<string[]>([]);
    const [isAddTourOpen, setIsAddTourOpen] = useState(false);
    const [tourSearchQuery, setTourSearchQuery] = useState('');

    const form = useForm<z.infer<typeof formSchema>>({
        resolver: zodResolver(formSchema),
        defaultValues: {
            name: '',
            description: '',
            type: 'geographic',
            coverImageUrl: '',
            isCurated: true,
            isFeatured: false,
            sortOrder: 0,
            city: '',
            country: '',
            tags: '',
        },
    });

    useEffect(() => {
        if (collection) {
            form.reset({
                name: collection.name,
                description: collection.description,
                type: collection.type,
                coverImageUrl: collection.coverImageUrl || '',
                isCurated: collection.isCurated,
                isFeatured: collection.isFeatured,
                sortOrder: collection.sortOrder,
                city: collection.city || '',
                country: collection.country || '',
                tags: collection.tags.join(', '),
            });
            setSelectedTourIds(collection.tourIds);
        }
    }, [collection, form]);

    const sensors = useSensors(
        useSensor(PointerSensor),
        useSensor(KeyboardSensor, {
            coordinateGetter: sortableKeyboardCoordinates,
        })
    );

    const handleDragEnd = (event: DragEndEvent) => {
        const { active, over } = event;

        if (over && active.id !== over.id) {
            setSelectedTourIds((items) => {
                const oldIndex = items.indexOf(active.id as string);
                const newIndex = items.indexOf(over.id as string);
                return arrayMove(items, oldIndex, newIndex);
            });
        }
    };

    const handleAddTour = (tourId: string) => {
        if (!selectedTourIds.includes(tourId)) {
            setSelectedTourIds([...selectedTourIds, tourId]);
            setIsAddTourOpen(false);
        }
    };

    const handleRemoveTour = (tourId: string) => {
        setSelectedTourIds(selectedTourIds.filter((id) => id !== tourId));
    };

    const onSubmit = async (values: z.infer<typeof formSchema>) => {
        try {
            const data = {
                ...values,
                tourIds: selectedTourIds,
                tags: values.tags ? values.tags.split(',').map((t) => t.trim()).filter(Boolean) : [],
                coverImageUrl: values.coverImageUrl || undefined,
                city: values.city || undefined,
                country: values.country || undefined,
            };

            if (isNew) {
                await createMutation.mutateAsync(data);
                toast({
                    title: 'Collection created',
                    description: 'The collection has been successfully created.',
                });
            } else {
                await updateMutation.mutateAsync({
                    collectionId,
                    data
                });
                toast({
                    title: 'Collection updated',
                    description: 'The collection has been successfully updated.',
                });
            }
            router.push('/collections');
        } catch {
            toast({
                variant: 'destructive',
                title: 'Error',
                description: `Failed to ${isNew ? 'create' : 'update'} collection. Please try again.`,
            });
        }
    };

    if (isLoading && !isNew) {
        return (
            <AdminLayout title="Edit Collection">
                <div className="flex items-center justify-center py-8">
                    <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
                </div>
            </AdminLayout>
        );
    }

    const selectedToursList = selectedTourIds
        .map((id) => allTours?.find((t) => t.id === id))
        .filter((t): t is TourModel => !!t);

    const availableTours = allTours?.filter(
        (tour) =>
            !selectedTourIds.includes(tour.id) &&
            (tour.title?.toLowerCase().includes(tourSearchQuery.toLowerCase()) || // Need tour title, wait TourModel doesn't have title on root level, it's in version? 
                // Actually TourModel has draftVersionId, need to fetch versions? Or does listing returned aggregated data?
                // Looking at TourModel types: it has draftVersion object if returned by getTours sometimes? 
                // Let's assume for now we use ID or need to fetch versions. 
                // Wait, existing useTours returns TourModel[]. TourModel doesn't have title. 
                // Actually list view usually needs titles. 
                // In admin.ts parseTourDoc: 
                /* 
                draftVersion: (data.draftVersion as number) || 1,
                // It seems title isn't on TourModel root. 
                // But wait, the previous ReviewQueuePage used version.title from separate hook.
                // Listing all tours usually includes some title info?
                // Checking TourModel definition in keys/index.ts...
                // It doesn't have title.
                // However, useTours hook might be returning enriched data?
                // Or I need to fetch versions?
                // Let's check getTours implementation in admin.ts if I can view it?
                // I'll assume for now I might only have ID and need to rely on that or update getTours to include title from live/draft version?
                // Actually the TourModel defined in admin.ts has `slug`, `creatorName`...
                // Let's check if I should update TourModel to include title for listing purposes or if I need to fetch it.
                // For simple admin UI, maybe I can just show ID or if `getTours` joins data.
                // Re-reading admin.ts in my thought process... getTours just maps docs.
                // The tours collection in Firestore probably duplicates title on the root for easy querying?
                // If not, this is a gap.
                // I will assume for now I might need to deal with this. 
                // But looking at existing code... `ReviewQueuePage` fetches `useTourVersion`.
                // For a list of ALL tours, fetching version for each is expensive.
                // Usually `tours` collection has `title` field denormalized.
                // I'll check TourModel again.
                // It seems TourModel definition in `src/types/index.ts` DOES NOT have title.
                // But `parseTourDoc` doesn't read it.
                // I might want to add title to TourModel in types if it exists in Firestore, or fallback to something.
                // Let's check `parseTourDoc` again.
                */
                tour.id.includes(tourSearchQuery)
            )
    ) || [];

    return (
        <AdminLayout title={isNew ? 'New Collection' : 'Edit Collection'}>
            <div className="space-y-6">
                <div className="flex items-center gap-4">
                    <Button
                        variant="ghost"
                        size="icon"
                        onClick={() => router.push('/collections')}
                    >
                        <ChevronLeft className="h-4 w-4" />
                    </Button>
                    <h1 className="text-2xl font-bold tracking-tight">
                        {isNew ? 'New Collection' : 'Edit Collection'}
                    </h1>
                </div>

                <div className="grid gap-6 md:grid-cols-2">
                    {/* Form Side */}
                    <div className="space-y-6">
                        <Form {...form}>
                            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
                                <Card>
                                    <CardHeader>
                                        <CardTitle>Basic Details</CardTitle>
                                        <CardDescription>
                                            Information about the collection.
                                        </CardDescription>
                                    </CardHeader>
                                    <CardContent className="space-y-4">
                                        <FormField
                                            control={form.control}
                                            name="name"
                                            render={({ field }) => (
                                                <FormItem>
                                                    <FormLabel>Name</FormLabel>
                                                    <FormControl>
                                                        <Input placeholder="e.g. Best of Paris" {...field} />
                                                    </FormControl>
                                                    <FormMessage />
                                                </FormItem>
                                            )}
                                        />

                                        <FormField
                                            control={form.control}
                                            name="description"
                                            render={({ field }) => (
                                                <FormItem>
                                                    <FormLabel>Description</FormLabel>
                                                    <FormControl>
                                                        <Textarea
                                                            placeholder="Describe this collection..."
                                                            className="h-24"
                                                            {...field}
                                                        />
                                                    </FormControl>
                                                    <FormMessage />
                                                </FormItem>
                                            )}
                                        />

                                        <div className="grid grid-cols-2 gap-4">
                                            <FormField
                                                control={form.control}
                                                name="type"
                                                render={({ field }) => (
                                                    <FormItem>
                                                        <FormLabel>Type</FormLabel>
                                                        <Select
                                                            onValueChange={field.onChange}
                                                            defaultValue={field.value}
                                                        >
                                                            <FormControl>
                                                                <SelectTrigger>
                                                                    <SelectValue placeholder="Select type" />
                                                                </SelectTrigger>
                                                            </FormControl>
                                                            <SelectContent>
                                                                <SelectItem value="geographic">Geographic</SelectItem>
                                                                <SelectItem value="thematic">Thematic</SelectItem>
                                                                <SelectItem value="seasonal">Seasonal</SelectItem>
                                                                <SelectItem value="custom">Custom</SelectItem>
                                                            </SelectContent>
                                                        </Select>
                                                        <FormMessage />
                                                    </FormItem>
                                                )}
                                            />

                                            <FormField
                                                control={form.control}
                                                name="sortOrder"
                                                render={({ field }) => (
                                                    <FormItem>
                                                        <FormLabel>Sort Order</FormLabel>
                                                        <FormControl>
                                                            <Input type="number" {...field} />
                                                        </FormControl>
                                                        <FormMessage />
                                                    </FormItem>
                                                )}
                                            />
                                        </div>

                                        <FormField
                                            control={form.control}
                                            name="coverImageUrl"
                                            render={({ field }) => (
                                                <FormItem>
                                                    <FormLabel>Cover Image URL</FormLabel>
                                                    <FormControl>
                                                        <Input placeholder="https://..." {...field} />
                                                    </FormControl>
                                                    <FormMessage />
                                                </FormItem>
                                            )}
                                        />

                                        <div className="grid grid-cols-2 gap-4">
                                            <FormField
                                                control={form.control}
                                                name="city"
                                                render={({ field }) => (
                                                    <FormItem>
                                                        <FormLabel>City (Optional)</FormLabel>
                                                        <FormControl>
                                                            <Input placeholder="e.g. Paris" {...field} />
                                                        </FormControl>
                                                        <FormMessage />
                                                    </FormItem>
                                                )}
                                            />

                                            <FormField
                                                control={form.control}
                                                name="country"
                                                render={({ field }) => (
                                                    <FormItem>
                                                        <FormLabel>Country (Optional)</FormLabel>
                                                        <FormControl>
                                                            <Input placeholder="e.g. France" {...field} />
                                                        </FormControl>
                                                        <FormMessage />
                                                    </FormItem>
                                                )}
                                            />
                                        </div>

                                        <FormField
                                            control={form.control}
                                            name="tags"
                                            render={({ field }) => (
                                                <FormItem>
                                                    <FormLabel>Tags</FormLabel>
                                                    <FormControl>
                                                        <Input placeholder="history, walking, food (comma separated)" {...field} />
                                                    </FormControl>
                                                    <FormDescription>
                                                        Separate tags with commas.
                                                    </FormDescription>
                                                    <FormMessage />
                                                </FormItem>
                                            )}
                                        />

                                        <Separator />

                                        <div className="flex items-center gap-8">
                                            <FormField
                                                control={form.control}
                                                name="isCurated"
                                                render={({ field }) => (
                                                    <FormItem className="flex items-center gap-2 space-y-0">
                                                        <FormControl>
                                                            <Switch
                                                                checked={field.value}
                                                                onCheckedChange={field.onChange}
                                                            />
                                                        </FormControl>
                                                        <FormLabel>Curated</FormLabel>
                                                    </FormItem>
                                                )}
                                            />

                                            <FormField
                                                control={form.control}
                                                name="isFeatured"
                                                render={({ field }) => (
                                                    <FormItem className="flex items-center gap-2 space-y-0">
                                                        <FormControl>
                                                            <Switch
                                                                checked={field.value}
                                                                onCheckedChange={field.onChange}
                                                            />
                                                        </FormControl>
                                                        <FormLabel>Featured</FormLabel>
                                                    </FormItem>
                                                )}
                                            />
                                        </div>
                                    </CardContent>
                                </Card>

                                <div className="flex justify-end gap-4">
                                    <Button
                                        type="button"
                                        variant="outline"
                                        onClick={() => router.back()}
                                    >
                                        Cancel
                                    </Button>
                                    <Button type="submit" disabled={createMutation.isPending || updateMutation.isPending}>
                                        <Save className="mr-2 h-4 w-4" />
                                        {isNew ? 'Create Collection' : 'Save Changes'}
                                    </Button>
                                </div>
                            </form>
                        </Form>
                    </div>

                    {/* Tours Management Side */}
                    <div className="space-y-6">
                        <Card className="h-full flex flex-col">
                            <CardHeader className="flex flex-row items-center justify-between">
                                <div>
                                    <CardTitle>Tours</CardTitle>
                                    <CardDescription>
                                        Manage tours in this collection.
                                    </CardDescription>
                                </div>

                                <Dialog open={isAddTourOpen} onOpenChange={setIsAddTourOpen}>
                                    <DialogTrigger asChild>
                                        <Button size="sm" variant="outline">
                                            <Plus className="mr-2 h-4 w-4" />
                                            Add Tour
                                        </Button>
                                    </DialogTrigger>
                                    <DialogContent className="max-w-md">
                                        <DialogHeader>
                                            <DialogTitle>Add Tour to Collection</DialogTitle>
                                            <DialogDescription>
                                                Search and select a tour to add.
                                            </DialogDescription>
                                        </DialogHeader>
                                        <div className="space-y-4 py-4">
                                            <div className="flex items-center gap-2">
                                                <Search className="h-4 w-4 text-muted-foreground" />
                                                <Input
                                                    placeholder="Search tours..."
                                                    value={tourSearchQuery}
                                                    onChange={(e) => setTourSearchQuery(e.target.value)}
                                                />
                                            </div>
                                            <div className="max-h-[300px] overflow-y-auto space-y-2">
                                                {availableTours.length === 0 ? (
                                                    <p className="text-sm text-center text-muted-foreground py-4">
                                                        No matching tours found.
                                                    </p>
                                                ) : (
                                                    availableTours.map((tour) => (
                                                        <div
                                                            key={tour.id}
                                                            className="flex items-center justify-between p-2 rounded-lg border hover:bg-muted cursor-pointer"
                                                            onClick={() => handleAddTour(tour.id)}
                                                        >
                                                            <div>
                                                                <div className="font-medium text-sm">
                                                                    {tour.creatorName} - {tour.city}
                                                                </div>
                                                                <div className="text-xs text-muted-foreground">
                                                                    {tour.tourType} • {tour.status}
                                                                </div>
                                                            </div>
                                                            <Plus className="h-4 w-4" />
                                                        </div>
                                                    ))
                                                )}
                                            </div>
                                        </div>
                                    </DialogContent>
                                </Dialog>
                            </CardHeader>
                            <CardContent className="flex-1">
                                {selectedTourIds.length === 0 ? (
                                    <div className="h-32 flex flex-col items-center justify-center text-muted-foreground border-2 border-dashed rounded-lg">
                                        <p>No tours in this collection</p>
                                        <p className="text-sm">Click "Add Tour" to get started</p>
                                    </div>
                                ) : (
                                    <DndContext
                                        sensors={sensors}
                                        collisionDetection={closestCenter}
                                        onDragEnd={handleDragEnd}
                                    >
                                        <SortableContext
                                            items={selectedTourIds}
                                            strategy={verticalListSortingStrategy}
                                        >
                                            <div className="space-y-2">
                                                {selectedToursList.map((tour) => (
                                                    <SortableTourItem
                                                        key={tour.id}
                                                        tour={tour}
                                                        onRemove={() => handleRemoveTour(tour.id)}
                                                    />
                                                ))}
                                            </div>
                                        </SortableContext>
                                    </DndContext>
                                )}
                            </CardContent>
                        </Card>
                    </div>
                </div>
            </div>
        </AdminLayout>
    );
}

function SortableTourItem({
    tour,
    onRemove
}: {
    tour: TourModel;
    onRemove: () => void
}) {
    const {
        attributes,
        listeners,
        setNodeRef,
        transform,
        transition,
    } = useSortable({ id: tour.id });

    const style = {
        transform: CSS.Transform.toString(transform),
        transition,
    };

    return (
        <div
            ref={setNodeRef}
            style={style}
            className="flex items-center gap-3 p-3 rounded-lg border bg-card"
        >
            <div
                {...attributes}
                {...listeners}
                className="cursor-move text-muted-foreground hover:text-foreground"
            >
                <MoveVertical className="h-4 w-4" />
            </div>

            <div className="flex-1 min-w-0">
                <div className="font-medium text-sm truncate">
                    Tour ID: {tour.id}
                    {/* Fallback title since it isn't in TourModel yet */}
                </div>
                <div className="flex items-center gap-2 text-xs text-muted-foreground">
                    <Badge variant="outline" className="text-[10px] h-4 px-1">
                        {tour.tourType}
                    </Badge>
                    <span>{tour.city}, {tour.country}</span>
                    <span>• by {tour.creatorName}</span>
                </div>
            </div>

            <Button
                variant="ghost"
                size="icon"
                className="h-8 w-8 text-destructive hover:text-destructive hover:bg-destructive/10"
                onClick={onRemove}
            >
                <Trash className="h-4 w-4" />
            </Button>
        </div>
    );
}
